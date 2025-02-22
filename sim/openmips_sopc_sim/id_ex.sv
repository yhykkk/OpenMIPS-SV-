/**************************************
@ filename    : id_ex.sv
@ author      : yyrwkk
@ create time : 2024/08/14 16:04:19
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module id_ex (
    input  logic                    i_clk                  ,
    input  logic                    i_rst_n                ,

    input  logic [`N_ALU_OP-1:0 ]   i_id_alu_op            ,
    input  logic [`N_ALU_SEL-1:0]   i_id_alu_sel           ,
    input  logic [`N_REG-1:0]       i_id_reg_0             ,
    input  logic [`N_REG-1:0]       i_id_reg_1             ,
    input  logic                    i_id_reg_wen           ,
    input  logic [`N_REG_ADDR-1:0]  i_id_reg_waddr         , 
    
    input  logic [5:0]              i_stall                ,

    output logic [`N_ALU_OP-1:0 ]   o_ex_alu_op            ,
    output logic [`N_ALU_SEL-1:0]   o_ex_alu_sel           ,
    output logic [`N_REG-1:0]       o_ex_reg_0             ,
    output logic [`N_REG-1:0]       o_ex_reg_1             ,
    output logic                    o_ex_reg_wen           ,
    output logic [`N_REG_ADDR-1:0]  o_ex_reg_waddr         ,

    input  logic                    i_id_delayslot_vld     ,
    input  logic [`N_INST_ADDR-1:0] i_id_link_addr         ,
    input  logic                    i_next_delayslot_vld   ,
    output logic                    o_ex_delayslot_vld     ,
    output logic [`N_INST_ADDR-1:0] o_ex_link_addr         ,
    output logic                    o_delayslot_vld        ,

    input  logic [`N_INST_DATA-1:0] i_id_inst              ,
    output logic [`N_INST_DATA-1:0] o_ex_inst              ,

    input  logic                    i_flush                ,
    input  logic [31:0]             i_id_except_type       ,
    input  logic [`N_INST_ADDR-1:0] i_id_curr_inst_addr    ,

    output logic [31:0]             o_ex_except_type       ,
    output logic [`N_INST_ADDR-1:0] o_ex_curr_inst_addr   
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
        o_ex_link_addr <= 'b0;
        o_ex_delayslot_vld <= `NOT_DELAY_SLOT;
        o_delayslot_vld    <= `NOT_DELAY_SLOT;
        o_ex_inst          <= 'b0;
        o_ex_except_type   <= 'b0;
        o_ex_curr_inst_addr<= 'b0;
    end else if( i_flush ) begin
        o_ex_alu_op    <= `EXE_NOP_OP ;
        o_ex_alu_sel   <= `EXE_RES_NOP;
        o_ex_reg_0     <= 'b0;
        o_ex_reg_1     <= 'b0;
        o_ex_reg_wen   <= `WRITE_DISABLE;
        o_ex_reg_waddr <= `NOP_REG_ADDR;
        o_ex_link_addr <= 'b0;
        o_ex_delayslot_vld <= `NOT_DELAY_SLOT;
        o_delayslot_vld    <= `NOT_DELAY_SLOT;
        o_ex_inst          <= 'b0;
        o_ex_except_type   <= 'b0;
        o_ex_curr_inst_addr<= 'b0;
    end else if( (i_stall[2]==`STOP ) && (i_stall[3] == `NO_STOP )) begin
        o_ex_alu_op    <= `EXE_NOP_OP ;
        o_ex_alu_sel   <= `EXE_RES_NOP;
        o_ex_inst      <= 'b0;
        o_ex_reg_0     <= 'b0;
        o_ex_reg_1     <= 'b0;
        o_ex_reg_wen   <= `WRITE_DISABLE;
        o_ex_reg_waddr <= `NOP_REG_ADDR;
        o_ex_link_addr <= 'b0;
        o_ex_delayslot_vld <= `NOT_DELAY_SLOT;
        o_delayslot_vld    <= `NOT_DELAY_SLOT;
        o_ex_except_type   <= 'b0;
        o_ex_curr_inst_addr<= 'b0;
    end else if( i_stall[2] == `NO_STOP ) begin   
        o_ex_alu_op    <= i_id_alu_op   ;
        o_ex_alu_sel   <= i_id_alu_sel  ;
        o_ex_reg_0     <= i_id_reg_0    ;
        o_ex_reg_1     <= i_id_reg_1    ;
        o_ex_reg_wen   <= i_id_reg_wen  ;
        o_ex_reg_waddr <= i_id_reg_waddr;
        o_ex_link_addr <= i_id_link_addr;
        o_ex_delayslot_vld <= i_id_delayslot_vld;
        o_delayslot_vld    <= i_next_delayslot_vld;
        o_ex_inst          <= i_id_inst ;
        o_ex_except_type   <= i_id_except_type;
        o_ex_curr_inst_addr<= i_id_curr_inst_addr;
    end else begin
        o_ex_alu_op    <= o_ex_alu_op   ;
        o_ex_alu_sel   <= o_ex_alu_sel  ;
        o_ex_reg_0     <= o_ex_reg_0    ;
        o_ex_reg_1     <= o_ex_reg_1    ;
        o_ex_reg_wen   <= o_ex_reg_wen  ;
        o_ex_reg_waddr <= o_ex_reg_waddr;
        o_ex_link_addr <= o_ex_link_addr;
        o_ex_delayslot_vld <= o_ex_delayslot_vld;
        o_delayslot_vld    <= o_delayslot_vld;
        o_ex_inst          <= o_ex_inst ;
        o_ex_except_type   <= o_ex_except_type;
        o_ex_curr_inst_addr<= o_ex_curr_inst_addr;
    end
end
endmodule