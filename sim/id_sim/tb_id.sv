/**************************************
@ filename    : tb_id.sv
@ author      : yyrwkk
@ create time : 2024/08/13 15:23:49
@ version     : v1.0.0
**************************************/
`timescale 1ns/1ns
module tb_id();
`include "defines.svh"
logic                       i_rst_n      ;
logic [`N_INST_ADDR-1:0]    i_pc         ;
logic [`N_INST_DATA-1:0]    i_inst       ;
logic [`N_REG-1:0]          i_reg_0_data ;
logic [`N_REG-1:0]          i_reg_1_data ;
logic [`N_REG_ADDR-1:0]     o_reg_0_addr ;
logic                       o_reg_0_ren  ;
logic [`N_REG_ADDR-1:0]     o_reg_1_addr ;
logic                       o_reg_1_ren  ;
logic [`N_ALU_OP-1:0]       o_alu_op     ;
logic [`N_ALU_SEL-1:0]      o_alu_sel    ;
logic [`N_REG-1:0]          o_op_reg_0   ;
logic [`N_REG-1:0]          o_op_reg_1   ;
logic                       o_reg_wen    ;
logic [`N_REG_ADDR-1:0]     o_reg_waddr  ;

id id_inst (
    .i_rst_n      (i_rst_n      ),
    .i_pc         (i_pc         ),
    .i_inst       (i_inst       ),
    .i_reg_0_data (i_reg_0_data ),
    .i_reg_1_data (i_reg_1_data ),
    .o_reg_0_addr (o_reg_0_addr ),
    .o_reg_0_ren  (o_reg_0_ren  ),
    .o_reg_1_addr (o_reg_1_addr ),
    .o_reg_1_ren  (o_reg_1_ren  ),
    .o_alu_op     (o_alu_op     ), 
    .o_alu_sel    (o_alu_sel    ), 
    .o_op_reg_0   (o_op_reg_0   ), 
    .o_op_reg_1   (o_op_reg_1   ), 
    .o_reg_wen    (o_reg_wen    ), 
    .o_reg_waddr  (o_reg_waddr  )   
);

initial begin
    i_rst_n     = 0; 
    i_pc        = 0; 
    i_inst      = 0; 
end

initial begin
    #10 i_rst_n = 1'b1;
    #10 i_inst = {`EXE_ORI,5'd5,5'd1,16'd666};
    #10 i_inst = 'b0;
    #20 $stop;
end

assign i_reg_0_data = o_reg_0_ren? (o_reg_0_addr + 1'b1): 'b0;
assign i_reg_1_data = o_reg_1_ren? (o_reg_1_addr + 1'b1): 'b0;


endmodule