/**************************************
@ filename    : id.sv
@ author      : yyrwkk
@ create time : 2024/08/13 14:32:24
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module id (
    input  logic [`N_INST_ADDR-1:0]    i_pc                 ,
    input  logic [`N_INST_DATA-1:0]    i_inst               ,

    // input regfile value
    input  logic [`N_REG-1:0]          i_reg_0_data         ,
    input  logic [`N_REG-1:0]          i_reg_1_data         ,

    // output regfile read ctrl signal
    output logic [`N_REG_ADDR-1:0]     o_reg_0_addr         ,
    output logic                       o_reg_0_ren          ,
    output logic [`N_REG_ADDR-1:0]     o_reg_1_addr         ,
    output logic                       o_reg_1_ren          ,

    // output signal to execute state 
    output logic [`N_ALU_OP-1:0]       o_alu_op             ,  // operator sub type  --> or , and , xor ...
    output logic [`N_ALU_SEL-1:0]      o_alu_sel            ,  // operator type      --> logic , arithmetic operation

    output logic [`N_REG-1:0]          o_op_reg_0           ,  // operate data 0
    output logic [`N_REG-1:0]          o_op_reg_1           ,  // operate data 1

    output logic                       o_reg_wen            ,  // dst reg w enable signal
    output logic [`N_REG_ADDR-1:0]     o_reg_waddr          ,  // dst reg addr

    // input signal from ex stage
    input  logic                       i_ex_wen             ,
    input  logic [`N_REG_ADDR-1:0]     i_ex_waddr           ,
    input  logic [`N_REG-1:0]          i_ex_wdata           ,
    // input signal from mem stage
    input  logic                       i_mem_wen            ,
    input  logic [`N_REG_ADDR-1:0]     i_mem_waddr          ,
    input  logic [`N_REG-1:0]          i_mem_wdata          ,
    
    output logic                       o_streq              ,

    output logic                       o_branch_vld         ,
    output logic [`N_INST_ADDR-1:0]    o_branch_addr        ,

    output logic                       o_delayslot_vld      ,
    output logic [`N_INST_ADDR-1:0]    o_link_addr          ,
 
    output logic                       o_next_delayslot_vld ,
    input  logic                       i_delayslot_vld      ,
    
    output logic [`N_INST_DATA-1:0]    o_inst               ,
    
    input  logic [`N_ALU_OP-1:0]       i_ex_aluop           ,

    output logic [31:0]                o_except_type        ,
    output logic [`N_INST_ADDR-1:0]    o_curr_inst_addr     
);

logic [`N_INST_OP-1:0]     op0;
logic [`N_INST_SUB_OP-1:0] op1;
logic [`N_INST_OP-1:0]     op2;
logic [`N_INST_SUB_OP-1:0] op3;

assign op0 = i_inst[31:26];
assign op1 = i_inst[10:6] ;
assign op2 = i_inst[5:0]  ;
assign op3 = i_inst[20:16];

logic [`N_REG-1:0] imm  ;  // immediate data

logic [`N_REG-1:0] imm_sll2_signed_ext ;   // ( imm << 2 ) -> signed extend
logic [`N_INST_ADDR-1:0] pc_plus_8; 
logic [`N_INST_ADDR-1:0] pc_plus_4;

assign pc_plus_4 = i_pc + 'd4;  // the 1nd instruction after the current instruction -> address
assign pc_plus_8 = i_pc + 'd8;  // the 2nd instruction after the current instruction -> address

assign imm_sll2_signed_ext = {{14{i_inst[15]}},i_inst[15:0],2'b00};

assign o_inst = i_inst;

logic stallreq_for_loadrelate_reg0;  // reg0 whether have load relate
logic stallreq_for_loadrelate_reg1;  // reg1 whether have load relate
logic pre_inst_is_load            ;  // whether last instruction is load

logic excpet_type_is_syscall ;
logic excpet_type_is_eret    ;
logic except_type_is_invalid ;

// excepttype_o 's low 8 bit is for extern interrupt 
// 8'bit -> whether syscall
// 9'bit -> whetehr invalid instruct 
// 12bit -> whether eret , eret is a special exception , return exception
assign o_except_type = {19'b0,excpet_type_is_eret,2'b0,except_type_is_invalid,excpet_type_is_syscall,8'b0};
assign o_curr_inst_addr = i_pc; // current instruct 's address

// i_ex_aluop -> is load
assign pre_inst_is_load = (
                            (i_ex_aluop == `EXE_LB_OP)  || 
                            (i_ex_aluop == `EXE_LBU_OP) || 
                            (i_ex_aluop == `EXE_LH_OP)  || 
                            (i_ex_aluop == `EXE_LHU_OP) || 
                            (i_ex_aluop == `EXE_LW_OP)  || 
                            (i_ex_aluop == `EXE_LWR_OP) || 
                            (i_ex_aluop == `EXE_LWL_OP) || 
                            (i_ex_aluop == `EXE_LL_OP)  || 
                            (i_ex_aluop == `EXE_SC_OP) 
                          ) ? 1'b1 :1'b0;

// reg0 whether have load relate                         
always_comb begin
    if( (pre_inst_is_load == 1'b1) && (i_ex_waddr == o_reg_0_addr) && (o_reg_0_ren == `READ_ENABLE)) begin
        stallreq_for_loadrelate_reg0  = 1'b1;
    end else begin
        stallreq_for_loadrelate_reg0  = 1'b0;
    end
end

// reg1 whether have load relate                         
always_comb begin
    if( (pre_inst_is_load == 1'b1) && (i_ex_waddr == o_reg_1_addr) && (o_reg_1_ren == `READ_ENABLE)) begin
        stallreq_for_loadrelate_reg1  = 1'b1;
    end else begin
        stallreq_for_loadrelate_reg1  = 1'b0;
    end
end

// decode instruct
always_comb begin
    o_alu_op    = `EXE_NOP_OP ;
    o_alu_sel   = `EXE_RES_NOP;

    o_reg_waddr = i_inst[15:11];
    o_reg_wen   = `WRITE_DISABLE;

    o_reg_0_ren = `READ_DISABLE;
    o_reg_1_ren = `READ_DISABLE;

    o_reg_0_addr= i_inst[25:21];
    o_reg_1_addr= i_inst[20:16];

    imm         = 'b0;

    o_link_addr          = 'b0;
    o_branch_addr        = 'b0;
    o_branch_vld         = `NO_BRANCH;
    o_next_delayslot_vld = `NOT_DELAY_SLOT;

    excpet_type_is_syscall = 1'b0;
    excpet_type_is_eret    = 1'b0;
    except_type_is_invalid = `INST_INVALID;

    case( op0 )
    `EXE_SPECIAL : begin
        if( op1 == 'b0 ) begin
            case ( op2 ) 
            `EXE_TEQ: begin // teq
                o_reg_wen = `WRITE_DISABLE;
                o_alu_op  = `EXE_TEQ_OP;
                o_alu_sel = `EXE_RES_NOP;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_TGE: begin // teq
                o_reg_wen = `WRITE_DISABLE;
                o_alu_op  = `EXE_TGE_OP;
                o_alu_sel = `EXE_RES_NOP;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_TGEU: begin
                o_reg_wen = `WRITE_DISABLE;
                o_alu_op  = `EXE_TGEU_OP;
                o_alu_sel = `EXE_RES_NOP;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_TLT: begin
                o_reg_wen = `WRITE_DISABLE;
                o_alu_op  = `EXE_TLT_OP;
                o_alu_sel = `EXE_RES_NOP;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_TLTU: begin 
                o_reg_wen = `WRITE_DISABLE;
                o_alu_op  = `EXE_TLTU_OP;
                o_alu_sel = `EXE_RES_NOP;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_TNE: begin 
                o_reg_wen = `WRITE_DISABLE;
                o_alu_op  = `EXE_TNE_OP;
                o_alu_sel = `EXE_RES_NOP;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_SYSCALL: begin
                o_reg_wen = `WRITE_DISABLE;
                o_alu_op  = `EXE_SYSCALL_OP;
                o_alu_sel = `EXE_RES_NOP;
                o_reg_0_ren = `READ_DISABLE;
                o_reg_1_ren = `READ_DISABLE;
                except_type_is_invalid = `INST_VALID;
                excpet_type_is_syscall = 1'b1;
            end
            `EXE_OR: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_OR_OP;
                o_alu_sel   = `EXE_RES_LOGIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_AND: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_AND_OP;
                o_alu_sel   = `EXE_RES_LOGIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_XOR: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_XOR_OP;
                o_alu_sel   = `EXE_RES_LOGIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_NOR: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_NOR_OP;
                o_alu_sel   = `EXE_RES_LOGIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_SLLV: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_SLL_OP;
                o_alu_sel   = `EXE_RES_SHIFT;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_SRLV: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_SRL_OP;
                o_alu_sel   = `EXE_RES_SHIFT;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_SRAV: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_SRA_OP;
                o_alu_sel   = `EXE_RES_SHIFT;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_SYNC: begin
                o_reg_wen   = `WRITE_DISABLE;
                o_alu_op    = `EXE_NOP_OP;
                o_alu_sel   = `EXE_RES_NOP;
                o_reg_0_ren = `READ_DISABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_MFHI: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_MFHI_OP ;
                o_alu_sel   = `EXE_RES_MOVE;
                o_reg_0_ren = `WRITE_DISABLE;
                o_reg_1_ren = `WRITE_DISABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_MFLO: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_MFLO_OP ;
                o_alu_sel   = `EXE_RES_MOVE;
                o_reg_0_ren = `WRITE_DISABLE;
                o_reg_1_ren = `WRITE_DISABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_MTHI: begin
                o_reg_wen   = `WRITE_DISABLE;
                o_alu_op    = `EXE_MTHI_OP ;
                o_alu_sel   = `EXE_RES_MOVE;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `WRITE_DISABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_MTLO: begin
                o_reg_wen   = `WRITE_DISABLE;
                o_alu_op    = `EXE_MTLO_OP ;
                o_alu_sel   = `EXE_RES_MOVE;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `WRITE_DISABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_MOVN: begin
                o_alu_op    = `EXE_MOVN_OP;
                o_alu_sel   = `EXE_RES_MOVE;
                o_reg_0_ren = `READ_ENABLE ;
                o_reg_1_ren = `READ_ENABLE ;
                except_type_is_invalid = `INST_VALID;
                if( o_op_reg_1 != 'b0 ) begin
                    o_reg_wen = `WRITE_ENABLE;
                end else begin
                    o_reg_wen = `WRITE_DISABLE;
                end
            end
            `EXE_MOVZ: begin
                o_alu_op  =  `EXE_MOVZ_OP;
                o_alu_sel =  `EXE_RES_MOVE;
                o_reg_0_ren = `READ_ENABLE ;
                o_reg_1_ren = `READ_ENABLE ;
                except_type_is_invalid = `INST_VALID;
                if( o_op_reg_1 == 'b0 ) begin
                    o_reg_wen = `WRITE_ENABLE;
                end else begin
                    o_reg_wen = `WRITE_DISABLE;
                end
            end
            `EXE_SLT: begin  
                o_reg_wen = `WRITE_ENABLE;
                o_alu_op  = `EXE_SLT_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_SLTU: begin
                o_reg_wen = `WRITE_ENABLE;
                o_alu_op  = `EXE_SLTU_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_ADD: begin
                o_reg_wen = `WRITE_ENABLE;
                o_alu_op  = `EXE_ADD_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_ADDU: begin 
                o_reg_wen = `WRITE_ENABLE;
                o_alu_op  = `EXE_ADDU_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_SUB: begin
                o_reg_wen = `WRITE_ENABLE;
                o_alu_op  = `EXE_SUB_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_SUBU: begin
                o_reg_wen = `WRITE_ENABLE;
                o_alu_op  = `EXE_SUBU_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_MULT: begin
                o_reg_wen = `WRITE_DISABLE;
                o_alu_op  = `EXE_MULT_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;  // not used in fact
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_MULTU: begin
                o_reg_wen = `WRITE_DISABLE;
                o_alu_op  = `EXE_MULTU_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;  // not used in fact
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_DIV: begin  
                o_reg_wen = `WRITE_DISABLE;
                o_alu_op  = `EXE_DIV_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;  // not used in fact
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_DIVU: begin 
                o_reg_wen = `WRITE_DISABLE;
                o_alu_op  = `EXE_DIVU_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;  // not used in fact
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_JR: begin                        // jr instructor
                o_reg_wen   = `WRITE_DISABLE;
                o_alu_op    = `EXE_NOP_OP;
                o_alu_sel   = `EXE_RES_NOP;
                o_reg_0_ren = `READ_ENABLE; 
                o_reg_1_ren = `READ_DISABLE;
                o_link_addr = 'b0;  
                o_branch_addr = o_op_reg_0;       // use latest reg_0
                o_branch_vld  = `BRANCH;
                o_next_delayslot_vld = `DELAY_SLOT;
                except_type_is_invalid = `INST_VALID;
            end
            `EXE_JALR: begin                      // jalr instructor 
                o_reg_wen   = `WRITE_ENABLE ;
                o_alu_op    = `EXE_JALR_OP;
                o_alu_sel   = `EXE_RES_JUMP_BRANCH;
                o_reg_0_ren = `READ_ENABLE; 
                o_reg_1_ren = `READ_DISABLE;
                o_reg_waddr = i_inst[15:11];
                o_link_addr = pc_plus_8;
                o_branch_addr = o_op_reg_0;
                o_branch_vld  = `BRANCH;
                o_next_delayslot_vld = `DELAY_SLOT;
                except_type_is_invalid = `INST_VALID;
            end
            default: begin
            end
            endcase
        end else begin
        end
    end
    `EXE_SPECIAL2: begin
        case( op2 ) 
        `EXE_CLZ: begin
            o_reg_wen = `WRITE_ENABLE;
            o_alu_op  = `EXE_CLZ_OP;
            o_alu_sel = `EXE_RES_ARITHMETIC;
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_DISABLE;
            except_type_is_invalid = `INST_VALID;
        end
        `EXE_CLO: begin
            o_reg_wen = `WRITE_ENABLE;
            o_alu_op  = `EXE_CLO_OP;
            o_alu_sel = `EXE_RES_ARITHMETIC;
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_DISABLE;
            except_type_is_invalid = `INST_VALID;
        end
        `EXE_MUL: begin
            o_reg_wen = `WRITE_ENABLE;
            o_alu_op  = `EXE_MUL_OP;
            o_alu_sel = `EXE_RES_MUL;
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_ENABLE;
            except_type_is_invalid = `INST_VALID;
        end
        `EXE_MADD: begin
            o_reg_wen = `WRITE_DISABLE;
            o_alu_op  = `EXE_MADD_OP;
            o_alu_sel = `EXE_RES_MUL; 
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_ENABLE;
            except_type_is_invalid = `INST_VALID;
        end
        `EXE_MADDU: begin
            o_reg_wen = `WRITE_DISABLE;
            o_alu_op  = `EXE_MADDU_OP;
            o_alu_sel = `EXE_RES_MUL; 
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_ENABLE;
            except_type_is_invalid = `INST_VALID;
        end
        `EXE_MSUB: begin
            o_reg_wen = `WRITE_DISABLE;
            o_alu_op  = `EXE_MSUB_OP;
            o_alu_sel = `EXE_RES_MUL; 
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_ENABLE;
            except_type_is_invalid = `INST_VALID;
        end
        `EXE_MSUBU: begin
            o_reg_wen = `WRITE_DISABLE;
            o_alu_op  = `EXE_MSUBU_OP;
            o_alu_sel = `EXE_RES_MUL; 
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_ENABLE;
            except_type_is_invalid = `INST_VALID;
        end
        default: begin
        end
        endcase
    end
    `EXE_ORI:  begin // ori instruct
        o_reg_wen = `WRITE_ENABLE ;
        // operator type
        o_alu_sel = `EXE_RES_LOGIC ;
        // operator sub type
        o_alu_op  = `EXE_OR_OP;
        // need read rs reg
        o_reg_0_ren = `READ_ENABLE;
        o_reg_0_addr= i_inst[25:21];
        o_reg_1_ren = `READ_DISABLE;
        o_reg_1_addr= `NOP_REG_ADDR;
        except_type_is_invalid = `INST_VALID;

        imm         = {16'b0, i_inst[15:0]};
        o_reg_waddr = i_inst[20:16];  
    end 
    `EXE_ANDI: begin
        except_type_is_invalid = `INST_VALID;
        o_reg_wen = `WRITE_ENABLE ;
        o_alu_sel = `EXE_RES_LOGIC ;
        o_alu_op  = `EXE_AND_OP;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_0_addr= i_inst[25:21];
        o_reg_1_ren = `READ_DISABLE;
        o_reg_1_addr= `NOP_REG_ADDR;
        imm         = {16'b0, i_inst[15:0]};
        o_reg_waddr = i_inst[20:16];  
    end
    `EXE_XORI: begin
        except_type_is_invalid = `INST_VALID;
        o_reg_wen = `WRITE_ENABLE ;
        o_alu_sel = `EXE_RES_LOGIC ;
        o_alu_op  = `EXE_XOR_OP;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_0_addr= i_inst[25:21];
        o_reg_1_ren = `READ_DISABLE;
        o_reg_1_addr= `NOP_REG_ADDR;
        imm         = {16'b0, i_inst[15:0]};
        o_reg_waddr = i_inst[20:16];  
    end
    `EXE_LUI: begin
        o_reg_wen = `WRITE_ENABLE ;
        except_type_is_invalid = `INST_VALID;
        o_alu_sel = `EXE_RES_LOGIC ;
        o_alu_op  = `EXE_OR_OP;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_0_addr= i_inst[25:21];
        o_reg_1_ren = `READ_DISABLE;
        o_reg_1_addr= `NOP_REG_ADDR;
        imm         = {i_inst[15:0],16'b0};
        o_reg_waddr = i_inst[20:16];  
    end
    `EXE_PREF: begin
        o_reg_wen = `WRITE_DISABLE ;
        o_alu_sel = `EXE_RES_NOP ;
        o_alu_op  = `EXE_NOP_OP;
        o_reg_0_ren = `READ_DISABLE;
        o_reg_0_addr= `NOP_REG_ADDR;
        o_reg_1_ren = `READ_DISABLE;
        o_reg_1_addr= `NOP_REG_ADDR;
        imm         = 'b0;
        o_reg_waddr = `NOP_REG_ADDR;  
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_SLTI: begin
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_SLT_OP;
        o_alu_sel = `EXE_RES_ARITHMETIC;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_DISABLE;
        imm         = {{16{i_inst[15]}},i_inst[15:0]};
        o_reg_waddr = i_inst[20:16];
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_SLTIU: begin
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_SLTU_OP;
        o_alu_sel = `EXE_RES_ARITHMETIC;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_DISABLE;
        imm         = {{16{i_inst[15]}},i_inst[15:0]};
        o_reg_waddr = i_inst[20:16];
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_ADDI : begin
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_ADDI_OP;
        o_alu_sel = `EXE_RES_ARITHMETIC;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_DISABLE;
        imm         = {{16{i_inst[15]}},i_inst[15:0]};
        o_reg_waddr = i_inst[20:16];
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_ADDIU: begin
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_ADDIU_OP;
        o_alu_sel = `EXE_RES_ARITHMETIC;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_DISABLE;
        imm         = {{16{i_inst[15]}},i_inst[15:0]};
        o_reg_waddr = i_inst[20:16];
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_J: begin // j
        o_reg_wen = `WRITE_DISABLE;
        o_alu_op  = `EXE_NOP_OP;
        o_alu_sel = `EXE_RES_NOP;
        o_reg_0_ren  = `READ_DISABLE;
        o_reg_1_ren  = `READ_DISABLE;
        o_link_addr  = 'b0;
        o_branch_vld = `BRANCH;
        o_next_delayslot_vld = `DELAY_SLOT;
        o_branch_addr= {pc_plus_4[31:28],i_inst[25:0],2'b00}; 
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_JAL: begin  // jal
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_JAL_OP;
        o_alu_sel = `EXE_RES_JUMP_BRANCH;
        o_reg_0_ren  = `READ_DISABLE;
        o_reg_1_ren  = `READ_DISABLE;
        o_reg_waddr  = 5'd31;
        o_link_addr  = pc_plus_8;
        o_branch_vld = `BRANCH;
        o_next_delayslot_vld = `DELAY_SLOT;
        o_branch_addr= {pc_plus_4[31:28],i_inst[25:0],2'b00};
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_BEQ: begin // beq
        o_reg_wen = `WRITE_DISABLE;
        o_alu_op  = `EXE_NOP_OP   ;
        o_alu_sel = `EXE_RES_NOP;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_ENABLE;
        except_type_is_invalid = `INST_VALID;
        if( o_op_reg_0 == o_op_reg_1 ) begin
            o_branch_addr = pc_plus_4 + imm_sll2_signed_ext;
            o_branch_vld  = `BRANCH;
            o_next_delayslot_vld = `DELAY_SLOT;
        end else begin
            o_branch_addr = 'b0;
            o_branch_vld  = `NO_BRANCH;
            o_next_delayslot_vld = `NOT_DELAY_SLOT;
        end
    end
    `EXE_BGTZ: begin // bgtz
        o_reg_wen = `WRITE_DISABLE;
        o_alu_op  = `EXE_NOP_OP;
        o_alu_sel = `EXE_RES_NOP;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_DISABLE;
        if( ( o_op_reg_0[31]==1'b0 ) && ( o_op_reg_0 != 'b0 )) begin // > 0
            o_branch_addr = pc_plus_4 + imm_sll2_signed_ext;
            o_branch_vld  = `BRANCH;
            o_next_delayslot_vld = `DELAY_SLOT;
        end else begin
            o_branch_addr = 'b0;
            o_branch_vld  = `NO_BRANCH;
            o_next_delayslot_vld = `NOT_DELAY_SLOT;
        end
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_BLEZ: begin // blez  --> = 0
        o_reg_wen = `WRITE_DISABLE;
        o_alu_op  = `EXE_NOP_OP;
        o_alu_sel = `EXE_RES_NOP;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_DISABLE;
        if( ( o_op_reg_0[31]==1'b1 ) || ( o_op_reg_0 == 'b0 )) begin // <0 || =0
            o_branch_addr = pc_plus_4 + imm_sll2_signed_ext;
            o_branch_vld  = `BRANCH;
            o_next_delayslot_vld = `DELAY_SLOT;
        end else begin
            o_branch_addr = 'b0;
            o_branch_vld  = `NO_BRANCH;
            o_next_delayslot_vld = `NOT_DELAY_SLOT;
        end
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_BNE: begin  
        o_reg_wen = `WRITE_DISABLE;
        o_alu_op  = `EXE_NOP_OP   ;  // fix
        o_alu_sel = `EXE_RES_NOP;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_ENABLE;
        if( o_op_reg_0 != o_op_reg_1 ) begin
            o_branch_addr = pc_plus_4 + imm_sll2_signed_ext;
            o_branch_vld  = `BRANCH;
            o_next_delayslot_vld = `DELAY_SLOT;
        end else begin
            o_branch_addr = 'b0;
            o_branch_vld  = `NO_BRANCH;
            o_next_delayslot_vld = `NOT_DELAY_SLOT;
        end
        except_type_is_invalid = `INST_VALID;
    end

    `EXE_REGIMM: begin 
        case( op3 )
        `EXE_BGEZ: begin  
            o_reg_wen = `WRITE_DISABLE;
            o_alu_op  = `EXE_NOP_OP;
            o_alu_sel = `EXE_RES_NOP;
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_DISABLE;
            if( o_op_reg_0[31] == 1'b0 ) begin
                o_branch_addr = pc_plus_4 + imm_sll2_signed_ext;
                o_branch_vld  = `BRANCH;
                o_next_delayslot_vld = `DELAY_SLOT;
            end else begin
                o_branch_addr = 'b0;
                o_branch_vld  = `NO_BRANCH;
                o_next_delayslot_vld = `NOT_DELAY_SLOT;
            end
            except_type_is_invalid = `INST_VALID;
        end
        `EXE_BGEZAL: begin 
            o_reg_wen = `WRITE_ENABLE;
            o_alu_op  = `EXE_BGEZAL_OP;
            o_alu_sel = `EXE_RES_JUMP_BRANCH;
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_DISABLE;
            o_link_addr = pc_plus_8;
            o_reg_waddr = 5'd31;
            if( o_op_reg_0[31] == 1'b0 ) begin
                o_branch_addr = pc_plus_4 + imm_sll2_signed_ext;
                o_branch_vld  = `BRANCH;
                o_next_delayslot_vld = `DELAY_SLOT;
            end else begin
                o_branch_addr = 'b0;
                o_branch_vld  = `NO_BRANCH;
                o_next_delayslot_vld = `NOT_DELAY_SLOT;
            end
            except_type_is_invalid = `INST_VALID;
        end
        `EXE_BLTZ: begin  
            o_reg_wen = `WRITE_DISABLE;
            o_alu_op  = `EXE_NOP_OP;
            o_alu_sel = `EXE_RES_NOP;
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_DISABLE;
            if( o_op_reg_0[31] == 1'b1 ) begin
                o_branch_addr = pc_plus_4 + imm_sll2_signed_ext;
                o_branch_vld  = `BRANCH;
                o_next_delayslot_vld = `DELAY_SLOT;
            end else begin
                o_branch_addr = 'b0;
                o_branch_vld  = `NO_BRANCH;
                o_next_delayslot_vld = `NOT_DELAY_SLOT;
            end
            except_type_is_invalid = `INST_VALID;
        end
        `EXE_BLTZAL: begin
            o_reg_wen = `WRITE_ENABLE;
            o_alu_op  = `EXE_BLTZAL_OP;
            o_alu_sel = `EXE_RES_JUMP_BRANCH;
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_DISABLE;
            o_link_addr = pc_plus_8;
            o_reg_waddr = 5'd31;
            if( o_op_reg_0[31] == 1'b1 ) begin
                o_branch_addr = pc_plus_4 + imm_sll2_signed_ext;
                o_branch_vld  = `BRANCH;
                o_next_delayslot_vld = `DELAY_SLOT;
            end else begin
                o_branch_addr = 'b0;
                o_branch_vld  = `NO_BRANCH;
                o_next_delayslot_vld = `NOT_DELAY_SLOT;
            end
            except_type_is_invalid = `INST_VALID;
        end
        `EXE_TEQI: begin
            o_reg_wen = `WRITE_DISABLE;
            o_alu_op  = `EXE_TEQI_OP;
            o_alu_sel = `EXE_RES_NOP;
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_DISABLE;
            imm         = {{16{i_inst[15]}},i_inst[15:0]};
            except_type_is_invalid = `INST_VALID;
        end
        `EXE_TGEI: begin
            o_reg_wen = `WRITE_DISABLE;
            o_alu_op  = `EXE_TGEI_OP;
            o_alu_sel = `EXE_RES_NOP;
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_DISABLE;
            imm         = {{16{i_inst[15]}},i_inst[15:0]};
            except_type_is_invalid = `INST_VALID;
        end
        `EXE_TGEIU: begin
            o_reg_wen = `WRITE_DISABLE;
            o_alu_op  = `EXE_TGEIU_OP;
            o_alu_sel = `EXE_RES_NOP;
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_DISABLE;
            imm         = {{16{i_inst[15]}},i_inst[15:0]};
            except_type_is_invalid = `INST_VALID;
        end
        `EXE_TLTI: begin
            o_reg_wen = `WRITE_DISABLE;
            o_alu_op  = `EXE_TLTI_OP;
            o_alu_sel = `EXE_RES_NOP;
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_DISABLE;
            imm         = {{16{i_inst[15]}},i_inst[15:0]};
            except_type_is_invalid = `INST_VALID;
        end
        `EXE_TLTIU: begin
            o_reg_wen = `WRITE_DISABLE;
            o_alu_op  = `EXE_TLTIU_OP;
            o_alu_sel = `EXE_RES_NOP;
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_DISABLE;
            imm         = {{16{i_inst[15]}},i_inst[15:0]};
            except_type_is_invalid = `INST_VALID;
        end
        `EXE_TNEI: begin
            o_reg_wen = `WRITE_DISABLE;
            o_alu_op  = `EXE_TNEI_OP;
            o_alu_sel = `EXE_RES_NOP;
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_DISABLE;
            imm         = {{16{i_inst[15]}},i_inst[15:0]};
            except_type_is_invalid = `INST_VALID;
        end
        default: begin 
        end
        endcase
    end
    `EXE_LB: begin
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_LB_OP;
        o_alu_sel = `EXE_RES_LOAD_STORE;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_DISABLE;
        o_reg_waddr = i_inst[20:16];
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_LBU: begin
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_LBU_OP;
        o_alu_sel = `EXE_RES_LOAD_STORE;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_DISABLE;
        o_reg_waddr = i_inst[20:16];
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_LH: begin
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_LH_OP;
        o_alu_sel = `EXE_RES_LOAD_STORE;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_DISABLE;
        o_reg_waddr = i_inst[20:16];
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_LHU: begin
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_LHU_OP;
        o_alu_sel = `EXE_RES_LOAD_STORE;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_DISABLE;
        o_reg_waddr = i_inst[20:16];
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_LW: begin
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_LW_OP;
        o_alu_sel = `EXE_RES_LOAD_STORE;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_DISABLE;
        o_reg_waddr = i_inst[20:16];
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_LWL: begin
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_LWL_OP;
        o_alu_sel = `EXE_RES_LOAD_STORE;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_ENABLE;
        o_reg_waddr = i_inst[20:16];
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_LWR: begin
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_LWR_OP;
        o_alu_sel = `EXE_RES_LOAD_STORE;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_ENABLE;
        o_reg_waddr = i_inst[20:16];
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_SB: begin
        o_reg_wen = `WRITE_DISABLE;
        o_alu_op  = `EXE_SB_OP;
        o_alu_sel = `EXE_RES_LOAD_STORE;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_ENABLE;
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_SH: begin
        o_reg_wen = `WRITE_DISABLE;
        o_alu_op  = `EXE_SH_OP;
        o_alu_sel = `EXE_RES_LOAD_STORE;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_ENABLE;
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_SW: begin
        o_reg_wen = `WRITE_DISABLE;
        o_alu_op  = `EXE_SW_OP;
        o_alu_sel = `EXE_RES_LOAD_STORE;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_ENABLE;
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_SWL: begin
        o_reg_wen = `WRITE_DISABLE;
        o_alu_op  = `EXE_SWL_OP;
        o_alu_sel = `EXE_RES_LOAD_STORE;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_ENABLE;
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_SWR:begin
        o_reg_wen = `WRITE_DISABLE;
        o_alu_op  = `EXE_SWR_OP;
        o_alu_sel = `EXE_RES_LOAD_STORE;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_ENABLE;
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_LL: begin 
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_LL_OP;
        o_alu_sel = `EXE_RES_LOAD_STORE;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_DISABLE;
        o_reg_waddr = i_inst[20:16];
        except_type_is_invalid = `INST_VALID;
    end
    `EXE_SC: begin 
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_SC_OP;
        o_alu_sel = `EXE_RES_LOAD_STORE;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_ENABLE;
        o_reg_waddr = i_inst[20:16];
        except_type_is_invalid = `INST_VALID;
    end

    default: begin
    end
    endcase

    if( i_inst[31:21] == 'b0) begin
        case( op2 )
        `EXE_SLL: begin
            o_reg_wen   = `WRITE_ENABLE ;
            o_reg_waddr = i_inst[15:11];
            o_alu_sel   = `EXE_RES_SHIFT;
            o_alu_op    = `EXE_SLL_OP ;
            o_reg_0_ren = `READ_DISABLE;
            o_reg_1_ren = `READ_ENABLE;
            imm[4:0]    = i_inst[10:6];
            except_type_is_invalid = `INST_VALID;
        end
        `EXE_SRL: begin
            o_reg_wen   = `WRITE_ENABLE ;
            o_reg_waddr = i_inst[15:11];
            o_alu_sel   = `EXE_RES_SHIFT;
            o_alu_op    = `EXE_SRL_OP ;
            o_reg_0_ren = `READ_DISABLE;
            o_reg_1_ren = `READ_ENABLE;
            imm[4:0]    = i_inst[10:6];
            except_type_is_invalid = `INST_VALID;
        end
        `EXE_SRA: begin
            o_reg_wen   = `WRITE_ENABLE ;
            o_reg_waddr = i_inst[15:11];
            o_alu_sel   = `EXE_RES_SHIFT;
            o_alu_op    = `EXE_SRA_OP ;
            o_reg_0_ren = `READ_DISABLE;
            o_reg_1_ren = `READ_ENABLE;
            imm[4:0]    = i_inst[10:6];
            except_type_is_invalid = `INST_VALID;
        end
        endcase 
    end else begin
    end

    if( i_inst[31:21] == 11'b0100_000_0000 && i_inst[10:0] == 11'b0 ) begin
        o_alu_op    = `EXE_MFC0_OP;
        o_alu_sel   = `EXE_RES_MOVE;
        o_reg_waddr = i_inst[20:16];
        o_reg_wen   = `WRITE_ENABLE;
        o_reg_0_ren = `READ_DISABLE;
        o_reg_1_ren = `READ_DISABLE;
        except_type_is_invalid = `INST_VALID;
    end else if( i_inst[31:21] == 11'b0100_000_0100 && i_inst[10:0] == 11'b0 ) begin
        o_alu_op    = `EXE_MTC0_OP;
        o_alu_sel   = `EXE_RES_MOVE;
        o_reg_wen   = `WRITE_DISABLE;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_0_addr= i_inst[20:16];
        o_reg_1_ren = `READ_DISABLE;
        except_type_is_invalid = `INST_VALID;
    end else if( i_inst == `EXE_ERET )begin // eret
        o_reg_wen   = `WRITE_DISABLE;
        o_alu_op    = `EXE_ERET_OP;
        o_alu_sel   = `EXE_RES_NOP;
        o_reg_0_ren = `READ_DISABLE;
        o_reg_1_ren = `READ_DISABLE;
        except_type_is_invalid = `INST_VALID;
        excpet_type_is_eret    = 1'b1;
    end else begin

    end
end

// operate data 0 logic
// add 2 case
// 1. if Regfile read port 0 --> read_addr == ex_waddr :  ex_wdata -> o_op_reg_0 
// 2. if Regfile read port 0 --> read_addr == mem_waddr:  mem_wdata-> o_op_reg_0
always_comb begin
    if( (o_reg_0_ren == 1'b1) && (i_ex_wen == 1'b1 ) && ( i_ex_waddr == o_reg_0_addr ) ) begin
        o_op_reg_0 = i_ex_wdata;
    end else if( (o_reg_0_ren == 1'b1) && (i_mem_wen == 1'b1 ) && ( i_mem_waddr == o_reg_0_addr )) begin
        o_op_reg_0 = i_mem_wdata;
    end else if( o_reg_0_ren == 1'b1 ) begin
        o_op_reg_0 = i_reg_0_data;
    end else begin
        o_op_reg_0 = imm;
    end
end

// operate data 1 logic
// add 2 case
// 1. if Regfile read port 1 --> read_addr == ex_waddr :  ex_wdata -> o_op_reg_1
// 2. if Regfile read port 1 --> read_addr == mem_waddr:  mem_wdata-> o_op_reg_1
always_comb begin
    if( (o_reg_1_ren == 1'b1) && (i_ex_wen == 1'b1 ) && ( i_ex_waddr == o_reg_1_addr ) ) begin
        o_op_reg_1 = i_ex_wdata;
    end else if( (o_reg_1_ren == 1'b1) && (i_mem_wen == 1'b1 ) && ( i_mem_waddr == o_reg_1_addr )) begin
        o_op_reg_1 = i_mem_wdata;
    end else if( o_reg_1_ren == 1'b1 ) begin
        o_op_reg_1 = i_reg_1_data;
    end else begin
        o_op_reg_1 = imm;
    end
end

// output o_delayslot_vld
assign o_delayslot_vld = i_delayslot_vld;
// load relate 
assign o_streq = (stallreq_for_loadrelate_reg0 | stallreq_for_loadrelate_reg1) ? `STOP : `NO_STOP ;

endmodule