/**************************************
@ filename    : mem_wb.sv
@ author      : yyrwkk
@ create time : 2024/08/14 20:30:54
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module mem_wb (
    input  logic                       i_clk               ,
    input  logic                       i_rst_n             ,
        
    input  logic [`N_REG_ADDR-1:0]     i_mem_waddr         ,
    input  logic [`N_REG-1:0]          i_mem_wdata         ,
    input  logic                       i_mem_wen           ,
         
    output logic [`N_REG_ADDR-1:0]     o_wb_waddr          ,
    output logic [`N_REG-1:0]          o_wb_wdata          ,
    output logic                       o_wb_wen            ,
         
    input  logic [5:0]                 i_stall             ,
         
    input  logic                       i_mem_hilo_wen      ,
    input  logic [`N_REG-1:0]          i_mem_hi            ,
    input  logic [`N_REG-1:0]          i_mem_lo            ,
             
    output logic                       o_wb_hilo_wen       ,
    output logic [`N_REG-1:0]          o_wb_hi             ,
    output logic [`N_REG-1:0]          o_wb_lo             ,
        
    input  logic                       i_mem_llbit_wen     ,
    input  logic                       i_mem_llbit_data    ,
    
    output logic                       o_wb_llbit_wen      ,
    output logic                       o_wb_llbit_data     ,

    input  logic                       i_mem_cp0_reg_wen   ,
    input  logic [`CP0_REG_N_ADDR-1:0] i_mem_cp0_reg_waddr ,
    input  logic [`N_REG-1:0]          i_mem_cp0_reg_wdata ,

    output logic                       o_wb_cp0_reg_wen    ,
    output logic [`CP0_REG_N_ADDR-1:0] o_wb_cp0_reg_waddr  ,
    output logic [`N_REG-1:0]          o_wb_cp0_reg_wdata 
);
// 1. stall[4]==STOP, stall[5]==NO_STOP, mem -> pause, wb -> run, use nop instruction
// 2. stall[4]==NO_STOP, mem->run
// 3. others, keep wb_wen,wb_waddr, wb_wdata,wb_hi,wb_lo,wb_hilo_wen
always_ff @( posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == `RST_ENABLE)begin
        o_wb_waddr <= `NOP_REG_ADDR;
        o_wb_wdata <= 'b0;
        o_wb_wen   <= `WRITE_DISABLE;
        o_wb_hilo_wen <= `WRITE_DISABLE;
        o_wb_hi       <= 'b0;
        o_wb_lo       <= 'b0;
        o_wb_llbit_data <= 'b0;
        o_wb_llbit_wen  <= 'b0;
    end else if( ( i_stall[4] == `STOP ) && (i_stall[5] == `NO_STOP) ) begin
        o_wb_waddr    <= `NOP_REG_ADDR;
        o_wb_wdata    <= 'b0;
        o_wb_wen      <= `WRITE_DISABLE;
        o_wb_hi       <= 'b0;
        o_wb_lo       <= 'b0;
        o_wb_hilo_wen <= `WRITE_DISABLE;
        o_wb_llbit_data <= 'b0;
        o_wb_llbit_wen  <= 'b0;
    end else if( i_stall[4] == `NO_STOP ) begin
        o_wb_waddr    <= i_mem_waddr;
        o_wb_wdata    <= i_mem_wdata;
        o_wb_wen      <= i_mem_wen  ;
        o_wb_hilo_wen <= i_mem_hilo_wen;
        o_wb_hi       <= i_mem_hi      ;
        o_wb_lo       <= i_mem_lo      ;
        o_wb_llbit_data <= i_mem_llbit_data;
        o_wb_llbit_wen  <= i_mem_llbit_wen ;
    end else begin
        o_wb_waddr    <= o_wb_waddr    ;
        o_wb_wdata    <= o_wb_wdata    ;
        o_wb_wen      <= o_wb_wen      ;
        o_wb_hilo_wen <= o_wb_hilo_wen ;
        o_wb_hi       <= o_wb_hi       ;
        o_wb_lo       <= o_wb_lo       ;
        o_wb_llbit_data <= o_wb_llbit_data;
        o_wb_llbit_wen  <= o_wb_llbit_wen ;
    end
end

always_ff @( posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == `RST_ENABLE)begin
        o_wb_cp0_reg_wen   <= `WRITE_DISABLE;
        o_wb_cp0_reg_waddr <= 'b0;
        o_wb_cp0_reg_wdata <= 'b0;
    end else if( ( i_stall[4] == `STOP ) && (i_stall[5] == `NO_STOP) ) begin
        o_wb_cp0_reg_wen   <= `WRITE_DISABLE;
        o_wb_cp0_reg_waddr <= 'b0;
        o_wb_cp0_reg_wdata <= 'b0;
    end else if( i_stall[4] == `NO_STOP ) begin
        o_wb_cp0_reg_wen   <= i_mem_cp0_reg_wen  ; 
        o_wb_cp0_reg_waddr <= i_mem_cp0_reg_waddr;
        o_wb_cp0_reg_wdata <= i_mem_cp0_reg_wdata;
    end else begin
        o_wb_cp0_reg_wen   <= o_wb_cp0_reg_wen  ;
        o_wb_cp0_reg_waddr <= o_wb_cp0_reg_waddr;
        o_wb_cp0_reg_wdata <= o_wb_cp0_reg_wdata;
    end
end

endmodule