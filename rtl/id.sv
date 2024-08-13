/**************************************
@ filename    : id.sv
@ author      : yyrwkk
@ create time : 2024/08/13 14:32:24
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module id (
    input  logic                       i_rst_n      ,

    input  logic [`N_INST_ADDR-1:0]    i_pc         ,
    input  logic [`N_INST_DATA-1:0]    i_inst       ,

    // input regfile value
    input  logic [`N_REG-1:0]          i_reg_0_data ,
    input  logic [`N_REG-1:0]          i_reg_1_data ,

    // output regfile read ctrl signal
    output logic [`N_REG_ADDR-1:0]     o_reg_0_addr ,
    output logic                       o_reg_0_ren  ,
    output logic [`N_REG_ADDR-1:0]     o_reg_1_addr ,
    output logic                       o_reg_1_ren  ,

    // output signal to execute state 
    output logic [`N_ALU_OP-1:0]       o_alu_op     ,  // operator sub type  --> or , and , xor ...
    output logic [`N_ALU_SEL-1:0]      o_alu_sel    ,  // operator type      --> logic , arithmetic operation

    output logic [`N_REG-1:0]          o_op_reg_0   ,  // operate data 0
    output logic [`N_REG-1:0]          o_op_reg_1   ,  // operate data 1

    output logic                       o_reg_wen    ,  // dst reg w enable signal
    output logic [`N_REG_ADDR-1:0]     o_reg_waddr     // dst reg addr
);

logic [`N_INST_OP-1:0] op;
assign op = i_inst[31:26];

logic [`N_REG-1:0] imm  ;  // immediate data

// decode instruct
always_comb begin
    if( i_rst_n == `RST_ENABLE ) begin
        o_alu_op    = `EXE_NOP_OP ;
        o_alu_sel   = `EXE_RES_NOP;
        o_reg_waddr = `NOP_REG_ADDR;
        o_reg_wen   = `WRITE_DISABLE;

        o_reg_0_ren = `READ_DISABLE;
        o_reg_1_ren = `READ_DISABLE;

        o_reg_0_addr= `NOP_REG_ADDR;
        o_reg_1_addr= `NOP_REG_ADDR;
        imm         = 'b0;
    end else begin
        o_alu_op    = `EXE_NOP_OP ;
        o_alu_sel   = `EXE_RES_NOP;

        o_reg_waddr = i_inst[15:11];
        o_reg_wen   = `WRITE_DISABLE;

        o_reg_0_ren = `READ_DISABLE;
        o_reg_1_ren = `READ_DISABLE;

        o_reg_0_addr= i_inst[25:21];
        o_reg_1_addr= i_inst[20:16];

        imm         = 'b0;

        case( op )
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
        default: begin

        end
        endcase

    end
end

// operate data 0 logic
always_comb begin
    if( i_rst_n == `RST_ENABLE ) begin
        o_op_reg_0 = 'b0;
    end else begin
        if( o_reg_0_ren == 1'b1 ) begin
            o_op_reg_0 = i_reg_0_data;
        end else begin
            o_op_reg_0 = imm;
        end
    end
end
// operate data 1 logic
always_comb begin
    if( i_rst_n == `RST_ENABLE ) begin
        o_op_reg_1 = 'b0;
    end else begin
        if( o_reg_1_ren == 1'b1 ) begin
            o_op_reg_1 = i_reg_1_data;
        end else begin
            o_op_reg_1 = imm;
        end
    end
end

endmodule