/**************************************
@ filename    : id_ex.sv
@ author      : yyrwkk
@ create time : 2024/08/14 16:04:19
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module id_ex (
    input  logic                   i_clk         ,
    input  logic                   i_rst_n       ,

    input  logic [`N_ALU_OP-1:0 ]  i_id_alu_op   ,
    input  logic [`N_ALU_SEL-1:0]  i_id_alu_sel  ,
    input  logic [`N_REG-1:0]      i_id_reg_0    ,
    input  logic [`N_REG-1:0]      i_id_reg_1    ,
    input  logic                   i_id_reg_wen  ,
    input  logic [`N_REG_ADDR-1:0] i_id_reg_waddr, 
    
    input  logic [5:0]             i_stall       ,

    output logic [`N_ALU_OP-1:0 ]  o_ex_alu_op   ,
    output logic [`N_ALU_SEL-1:0]  o_ex_alu_sel  ,
    output logic [`N_REG-1:0]      o_ex_reg_0    ,
    output logic [`N_REG-1:0]      o_ex_reg_1    ,
    output logic                   o_ex_reg_wen  ,
    output logic [`N_REG_ADDR-1:0] o_ex_reg_waddr 
);
// stall[2]==STOP, stall[3]==NO_STOP , id pause, ex run -> insert nop instruction
// stall[2]==NOSTOP                  , id run
// others, keep ex_aluop,ex_alusel, ex_reg0, ex_reg1,reg_wen, reg_waddr
always_ff @(posedge i_clk or negedge i_rst_n ) begin
    if( i_rst_n == `RST_ENABLE) begin
        o_ex_alu_op    <= `EXE_NOP_OP ;
        o_ex_alu_sel   <= `EXE_RES_NOP;
        o_ex_reg_0     <= 'b0;
        o_ex_reg_1     <= 'b0;
        o_ex_reg_wen   <= `WRITE_DISABLE;
        o_ex_reg_waddr <= `NOP_REG_ADDR;
    end else if( (i_stall[2]==`STOP ) && (i_stall[3] == `NO_STOP )) begin
        o_ex_alu_op    <= `EXE_NOP_OP ;
        o_ex_alu_sel   <= `EXE_RES_NOP;
        o_ex_reg_0     <= 'b0;
        o_ex_reg_1     <= 'b0;
        o_ex_reg_wen   <= `WRITE_DISABLE;
        o_ex_reg_waddr <= `NOP_REG_ADDR;
    end else if( i_stall[2] == `NO_STOP ) begin   
        o_ex_alu_op    <= i_id_alu_op   ;
        o_ex_alu_sel   <= i_id_alu_sel  ;
        o_ex_reg_0     <= i_id_reg_0    ;
        o_ex_reg_1     <= i_id_reg_1    ;
        o_ex_reg_wen   <= i_id_reg_wen  ;
        o_ex_reg_waddr <= i_id_reg_waddr;
    end else begin
        o_ex_alu_op    <= o_ex_alu_op   ;
        o_ex_alu_sel   <= o_ex_alu_sel  ;
        o_ex_reg_0     <= o_ex_reg_0    ;
        o_ex_reg_1     <= o_ex_reg_1    ;
        o_ex_reg_wen   <= o_ex_reg_wen  ;
        o_ex_reg_waddr <= o_ex_reg_waddr;
    end
end
endmodule