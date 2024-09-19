/**************************************
@ filename    : id.sv
@ author      : yyrwkk
@ create time : 2024/08/13 14:32:24
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module id (
    input  logic                       i_rst_n              ,

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
    input  logic                       i_delayslot_vld      
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

    case( op0 )
    `EXE_SPECIAL : begin
        if( op1 == 'b0 ) begin
            case ( op2 ) 
            `EXE_OR: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_OR_OP;
                o_alu_sel   = `EXE_RES_LOGIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
            end
            `EXE_AND: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_AND_OP;
                o_alu_sel   = `EXE_RES_LOGIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
            end
            `EXE_XOR: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_XOR_OP;
                o_alu_sel   = `EXE_RES_LOGIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
            end
            `EXE_NOR: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_NOR_OP;
                o_alu_sel   = `EXE_RES_LOGIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
            end
            `EXE_SLLV: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_SLL_OP;
                o_alu_sel   = `EXE_RES_SHIFT;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
            end
            `EXE_SRLV: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_SRL_OP;
                o_alu_sel   = `EXE_RES_SHIFT;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
            end
            `EXE_SRAV: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_SRA_OP;
                o_alu_sel   = `EXE_RES_SHIFT;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
            end
            `EXE_SYNC: begin
                o_reg_wen   = `WRITE_DISABLE;
                o_alu_op    = `EXE_NOP_OP;
                o_alu_sel   = `EXE_RES_NOP;
                o_reg_0_ren = `READ_DISABLE;
                o_reg_1_ren = `READ_ENABLE;
            end
            `EXE_MFHI: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_MFHI_OP ;
                o_alu_sel   = `EXE_RES_MOVE;
                o_reg_0_ren = `WRITE_DISABLE;
                o_reg_1_ren = `WRITE_DISABLE;
            end
            `EXE_MFLO: begin
                o_reg_wen   = `WRITE_ENABLE;
                o_alu_op    = `EXE_MFLO_OP ;
                o_alu_sel   = `EXE_RES_MOVE;
                o_reg_0_ren = `WRITE_DISABLE;
                o_reg_1_ren = `WRITE_DISABLE;
            end
            `EXE_MTHI: begin
                o_reg_wen   = `WRITE_DISABLE;
                o_alu_op    = `EXE_MTHI_OP ;
                o_alu_sel   = `EXE_RES_MOVE;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `WRITE_DISABLE;
            end
            `EXE_MTLO: begin
                o_reg_wen   = `WRITE_DISABLE;
                o_alu_op    = `EXE_MTLO_OP ;
                o_alu_sel   = `EXE_RES_MOVE;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `WRITE_DISABLE;
            end
            `EXE_MOVN: begin
                o_alu_op    = `EXE_MOVN_OP;
                o_alu_sel   = `EXE_RES_MOVE;
                o_reg_0_ren = `READ_ENABLE ;
                o_reg_1_ren = `READ_ENABLE ;
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
            end
            `EXE_SLTU: begin
                o_reg_wen = `WRITE_ENABLE;
                o_alu_op  = `EXE_SLTU_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
            end
            `EXE_ADD: begin
                o_reg_wen = `WRITE_ENABLE;
                o_alu_op  = `EXE_ADD_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
            end
            `EXE_ADDU: begin 
                o_reg_wen = `WRITE_ENABLE;
                o_alu_op  = `EXE_ADDU_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
            end
            `EXE_SUB: begin
                o_reg_wen = `WRITE_ENABLE;
                o_alu_op  = `EXE_SUB_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
            end
            `EXE_SUBU: begin
                o_reg_wen = `WRITE_ENABLE;
                o_alu_op  = `EXE_SUBU_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
            end
            `EXE_MULT: begin
                o_reg_wen = `WRITE_DISABLE;
                o_alu_op  = `EXE_MULT_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;  // not used in fact
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
            end
            `EXE_MULTU: begin
                o_reg_wen = `WRITE_DISABLE;
                o_alu_op  = `EXE_MULTU_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;  // not used in fact
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
            end
            `EXE_DIV: begin  
                o_reg_wen = `WRITE_DISABLE;
                o_alu_op  = `EXE_DIV_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;  // not used in fact
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
            end
            `EXE_DIVU: begin 
                o_reg_wen = `WRITE_DISABLE;
                o_alu_op  = `EXE_DIVU_OP;
                o_alu_sel = `EXE_RES_ARITHMETIC;  // not used in fact
                o_reg_0_ren = `READ_ENABLE;
                o_reg_1_ren = `READ_ENABLE;
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
        end
        `EXE_CLO: begin
            o_reg_wen = `WRITE_ENABLE;
            o_alu_op  = `EXE_CLO_OP;
            o_alu_sel = `EXE_RES_ARITHMETIC;
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_DISABLE;
        end
        `EXE_MUL: begin
            o_reg_wen = `WRITE_ENABLE;
            o_alu_op  = `EXE_MUL_OP;
            o_alu_sel = `EXE_RES_MUL;
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_ENABLE;
        end
        `EXE_MADD: begin
            o_reg_wen = `WRITE_DISABLE;
            o_alu_op  = `EXE_MADD_OP;
            o_alu_sel = `EXE_RES_MUL; 
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_ENABLE;
        end
        `EXE_MADDU: begin
            o_reg_wen = `WRITE_DISABLE;
            o_alu_op  = `EXE_MADDU_OP;
            o_alu_sel = `EXE_RES_MUL; 
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_ENABLE;
        end
        `EXE_MSUB: begin
            o_reg_wen = `WRITE_DISABLE;
            o_alu_op  = `EXE_MSUB_OP;
            o_alu_sel = `EXE_RES_MUL; 
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_ENABLE;
        end
        `EXE_MSUBU: begin
            o_reg_wen = `WRITE_DISABLE;
            o_alu_op  = `EXE_MSUBU_OP;
            o_alu_sel = `EXE_RES_MUL; 
            o_reg_0_ren = `READ_ENABLE;
            o_reg_1_ren = `READ_ENABLE;
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

        imm         = {16'b0, i_inst[15:0]};
        o_reg_waddr = i_inst[20:16];  
    end 
    `EXE_ANDI: begin
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
    end
    `EXE_SLTI: begin
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_SLT_OP;
        o_alu_sel = `EXE_RES_ARITHMETIC;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_DISABLE;
        imm         = {{16{i_inst[15]}},i_inst[15:0]};
        o_reg_waddr = i_inst[20:16];
    end
    `EXE_SLTIU: begin
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_SLTU_OP;
        o_alu_sel = `EXE_RES_ARITHMETIC;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_DISABLE;
        imm         = {{16{i_inst[15]}},i_inst[15:0]};
        o_reg_waddr = i_inst[20:16];
    end
    `EXE_ADDI : begin
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_ADDI_OP;
        o_alu_sel = `EXE_RES_ARITHMETIC;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_DISABLE;
        imm         = {{16{i_inst[15]}},i_inst[15:0]};
        o_reg_waddr = i_inst[20:16];
    end
    `EXE_ADDIU: begin
        o_reg_wen = `WRITE_ENABLE;
        o_alu_op  = `EXE_ADDIU_OP;
        o_alu_sel = `EXE_RES_ARITHMETIC;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_DISABLE;
        imm         = {{16{i_inst[15]}},i_inst[15:0]};
        o_reg_waddr = i_inst[20:16];
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
    end
    `EXE_BEQ: begin // beq
        o_reg_wen = `WRITE_DISABLE;
        o_alu_op  = `EXE_NOP_OP   ;
        o_alu_sel = `EXE_RES_NOP;
        o_reg_0_ren = `READ_ENABLE;
        o_reg_1_ren = `READ_ENABLE;
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
    end
    `EXE_BLEZ: begin // blez  --> <= 0
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
        end
        endcase
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
        end
        `EXE_SRL: begin
            o_reg_wen   = `WRITE_ENABLE ;
            o_reg_waddr = i_inst[15:11];
            o_alu_sel   = `EXE_RES_SHIFT;
            o_alu_op    = `EXE_SRL_OP ;
            o_reg_0_ren = `READ_DISABLE;
            o_reg_1_ren = `READ_ENABLE;
            imm[4:0]    = i_inst[10:6];
        end
        `EXE_SRA: begin
            o_reg_wen   = `WRITE_ENABLE ;
            o_reg_waddr = i_inst[15:11];
            o_alu_sel   = `EXE_RES_SHIFT;
            o_alu_op    = `EXE_SRA_OP ;
            o_reg_0_ren = `READ_DISABLE;
            o_reg_1_ren = `READ_ENABLE;
            imm[4:0]    = i_inst[10:6];
        end
        endcase 
    end else begin
    end
end

// operate data 0 logic
// add 2 case
// 1. if Regfile read port 0 --> read_addr == ex_waddr :  ex_wdata -> o_op_reg_0 
// 2. if Regfile read port 0 --> read_addr == mem_waddr:  mem_wdata-> o_op_reg_0
always_comb begin
    if( i_rst_n == `RST_ENABLE ) begin
        o_op_reg_0 = 'b0;
    end else begin
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
end

// operate data 1 logic
// add 2 case
// 1. if Regfile read port 1 --> read_addr == ex_waddr :  ex_wdata -> o_op_reg_1
// 2. if Regfile read port 1 --> read_addr == mem_waddr:  mem_wdata-> o_op_reg_1
always_comb begin
    if( i_rst_n == `RST_ENABLE ) begin
        o_op_reg_1 = 'b0;
    end else begin
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
end

// output o_delayslot_vld
assign o_delayslot_vld = i_delayslot_vld;

assign o_streq = `NO_STOP;

endmodule