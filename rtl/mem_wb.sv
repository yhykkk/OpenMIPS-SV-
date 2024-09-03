/**************************************
@ filename    : mem_wb.sv
@ author      : yyrwkk
@ create time : 2024/08/14 20:30:54
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module mem_wb (
    input  logic                    i_clk         ,
    input  logic                    i_rst_n       ,

    input  logic [`N_REG_ADDR-1:0]  i_mem_waddr   ,
    input  logic [`N_REG-1:0]       i_mem_wdata   ,
    input  logic                    i_mem_wen     ,

    output logic [`N_REG_ADDR-1:0]  o_wb_waddr    ,
    output logic [`N_REG-1:0]       o_wb_wdata    ,
    output logic                    o_wb_wen      ,

    input  logic                    i_mem_hilo_wen,
    input  logic [`N_REG-1:0]       i_mem_hi      ,
    input  logic [`N_REG-1:0]       i_mem_lo      ,
    
    output logic                    o_wb_hilo_wen ,
    output logic [`N_REG-1:0]       o_wb_hi       ,
    output logic [`N_REG-1:0]       o_wb_lo       
);

always_ff @( posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == `RST_ENABLE)begin
        o_wb_waddr <= `NOP_REG_ADDR;
        o_wb_wdata <= 'b0;
        o_wb_wen   <= `WRITE_DISABLE;
        o_wb_hilo_wen <= `WRITE_DISABLE;
        o_wb_hi       <= 'b0;
        o_wb_lo       <= 'b0;
    end else begin
        o_wb_waddr <= i_mem_waddr;
        o_wb_wdata <= i_mem_wdata;
        o_wb_wen   <= i_mem_wen  ;
        o_wb_hilo_wen <= i_mem_hilo_wen;
        o_wb_hi       <= i_mem_hi      ;
        o_wb_lo       <= i_mem_lo      ;
    end
end

endmodule