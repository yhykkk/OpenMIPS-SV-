/**************************************
@ filename    : ex_mem.sv
@ author      : yyrwkk
@ create time : 2024/08/14 20:10:05
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module ex_mem (
    input  logic                    i_clk         ,
    input  logic                    i_rst_n       ,

    input  logic                    i_ex_wen      ,
    input  logic [`N_REG-1:0]       i_ex_wdata    ,
    input  logic [`N_REG_ADDR-1:0]  i_ex_waddr    ,

    input  logic [5:0]              i_stall       ,

    output logic                    o_mem_wen     ,
    output logic [`N_REG-1:0]       o_mem_wdata   ,
    output logic [`N_REG_ADDR-1:0]  o_mem_waddr   ,

    input  logic                    i_ex_hilo_wen ,
    input  logic [`N_REG-1:0]       i_ex_hi       ,
    input  logic [`N_REG-1:0]       i_ex_lo       ,

    output logic                    o_mem_hilo_wen,
    output logic [`N_REG-1:0]       o_mem_hi      ,
    output logic [`N_REG-1:0]       o_mem_lo      ,
    
    input  logic [(2*`N_REG)-1:0]   i_hilo_temp   ,
    input  logic [1:0]              i_cnt         ,

    output logic [(2*`N_REG)-1:0]   o_hilo_temp   , 
    output logic [1:0]              o_cnt         
);
// 1. stall[3] == STOP, stall[4]==NO_STOP, ex->pause, mem->run, use nop instruction
// 2. stall[3] == NO_STOP, ex->run, then come to mem
// 3. others , keep mem_waddr, mem_wen ,mem_wdata,mem_hi,mem_lo,mem_hilo_wen
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if( i_rst_n == `RST_ENABLE ) begin
        o_mem_wen  <= `WRITE_DISABLE; 
        o_mem_wdata<= 'b0;
        o_mem_waddr<= `NOP_REG_ADDR;
        o_mem_hilo_wen <= `WRITE_DISABLE;
        o_mem_hi       <= 'b0;
        o_mem_lo       <= 'b0;
    end else if( (i_stall[3] == `STOP) && (i_stall[4] == `NO_STOP) ) begin
        o_mem_waddr <= `NOP_REG_ADDR;
        o_mem_wen   <= `WRITE_DISABLE;
        o_mem_wdata <= 'b0;
        o_mem_hilo_wen <= `WRITE_DISABLE;
        o_mem_lo       <= 'b0;
        o_mem_hi       <= 'b0;
    end else if( i_stall[3] == `NO_STOP) begin
        o_mem_wen      <= i_ex_wen;
        o_mem_wdata    <= i_ex_wdata;
        o_mem_waddr    <= i_ex_waddr;
        o_mem_hilo_wen <= i_ex_hilo_wen;
        o_mem_hi       <= i_ex_hi;
        o_mem_lo       <= i_ex_lo;
    end else begin
        o_mem_wen      <= o_mem_wen     ;
        o_mem_wdata    <= o_mem_wdata   ;
        o_mem_waddr    <= o_mem_waddr   ;
        o_mem_hilo_wen <= o_mem_hilo_wen;
        o_mem_hi       <= o_mem_hi      ;
        o_mem_lo       <= o_mem_lo      ;
    end
end

// when ex stage is pausing, give back the hilo_temp
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if( !i_rst_n ) begin
        o_hilo_temp <= 'b0;
        o_cnt       <= 2'b00;
    end else if( (i_stall[3] == `STOP) && (i_stall[4]==`NO_STOP) ) begin
        o_hilo_temp <= i_hilo_temp;
        o_cnt       <= i_cnt;
    end else if( i_stall[3] == `NO_STOP ) begin
        o_hilo_temp <= 'b0;
        o_cnt       <= 2'b00;
    end else begin
        o_hilo_temp <= i_hilo_temp;
        o_cnt       <= i_cnt;
    end
end
endmodule