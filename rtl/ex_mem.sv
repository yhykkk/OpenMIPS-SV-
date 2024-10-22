/**************************************
@ filename    : ex_mem.sv
@ author      : yyrwkk
@ create time : 2024/08/14 20:10:05
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module ex_mem (
    input  logic                       i_clk               ,
    input  logic                       i_rst_n             ,
        
    input  logic                       i_ex_wen            ,
    input  logic [`N_REG-1:0]          i_ex_wdata          ,
    input  logic [`N_REG_ADDR-1:0]     i_ex_waddr          ,
        
    input  logic [5:0]                 i_stall             ,
        
    output logic                       o_mem_wen           ,
    output logic [`N_REG-1:0]          o_mem_wdata         ,
    output logic [`N_REG_ADDR-1:0]     o_mem_waddr         ,
        
    input  logic                       i_ex_hilo_wen       ,
    input  logic [`N_REG-1:0]          i_ex_hi             ,
    input  logic [`N_REG-1:0]          i_ex_lo             ,
        
    output logic                       o_mem_hilo_wen      ,
    output logic [`N_REG-1:0]          o_mem_hi            ,
    output logic [`N_REG-1:0]          o_mem_lo            ,
            
    input  logic [(2*`N_REG)-1:0]      i_hilo_temp         ,
    input  logic [1:0]                 i_cnt               ,
        
    output logic [(2*`N_REG)-1:0]      o_hilo_temp         , 
    output logic [1:0]                 o_cnt               ,
        
    input  logic [`N_ALU_OP-1:0]       i_ex_aluop          ,
    input  logic [`N_MEM_ADDR-1:0]     i_ex_mem_addr       ,
    input  logic [`N_MEM_DATA-1:0]     i_ex_mem_data       ,
        
    output logic [`N_ALU_OP-1:0]       o_mem_aluop         ,
    output logic [`N_MEM_ADDR-1:0]     o_mem_addr          ,
    output logic [`N_MEM_DATA-1:0]     o_mem_data          ,

    input  logic                       i_ex_cp0_reg_wen    ,
    input  logic [`CP0_REG_N_ADDR-1:0] i_ex_cp0_reg_waddr  ,
    input  logic [`N_REG-1:0]          i_ex_cp0_reg_wdata  ,

    output logic                       o_mem_cp0_reg_wen   ,
    output logic [`CP0_REG_N_ADDR-1:0] o_mem_cp0_reg_waddr ,
    output logic [`N_REG-1:0]          o_mem_cp0_reg_wdata ,

    input  logic                       i_flush             ,
    input  logic [31:0]                i_ex_except_type    ,
    input  logic [`N_INST_ADDR-1:0]    i_ex_curr_inst_addr ,
    input  logic                       i_ex_delayslot_vld  ,

    output logic [31:0]                o_mem_except_type   ,
    output logic [`N_INST_ADDR-1:0]    o_mem_curr_inst_addr,
    output logic                       o_mem_delayslot_vld 

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
        o_mem_aluop    <= `EXE_NOP_OP;
        o_mem_addr     <= 'b0;  
        o_mem_data     <= 'b0; 
        o_mem_except_type   <= 'b0;
        o_mem_delayslot_vld <= `NOT_DELAY_SLOT;
        o_mem_curr_inst_addr<= 'b0;
    end else if( i_flush == 1'b1 ) begin 
        o_mem_wen  <= `WRITE_DISABLE; 
        o_mem_wdata<= 'b0;
        o_mem_waddr<= `NOP_REG_ADDR;
        o_mem_hilo_wen <= `WRITE_DISABLE;
        o_mem_hi       <= 'b0;
        o_mem_lo       <= 'b0;
        o_mem_aluop    <= `EXE_NOP_OP;
        o_mem_addr     <= 'b0;  
        o_mem_data     <= 'b0; 
        o_mem_except_type   <= 'b0;
        o_mem_delayslot_vld <= `NOT_DELAY_SLOT;
        o_mem_curr_inst_addr<= 'b0;
    end else if( (i_stall[3] == `STOP) && (i_stall[4] == `NO_STOP) ) begin
        o_mem_waddr <= `NOP_REG_ADDR;
        o_mem_wen   <= `WRITE_DISABLE;
        o_mem_wdata <= 'b0;
        o_mem_hilo_wen <= `WRITE_DISABLE;
        o_mem_lo       <= 'b0;
        o_mem_hi       <= 'b0;
        o_mem_aluop    <= `EXE_NOP_OP;
        o_mem_addr     <= 'b0;  
        o_mem_data     <= 'b0; 
        o_mem_except_type   <= 'b0;
        o_mem_delayslot_vld <= `NOT_DELAY_SLOT;
        o_mem_curr_inst_addr<= 'b0;
    end else if( i_stall[3] == `NO_STOP) begin
        o_mem_wen      <= i_ex_wen;
        o_mem_wdata    <= i_ex_wdata;
        o_mem_waddr    <= i_ex_waddr;
        o_mem_hilo_wen <= i_ex_hilo_wen;
        o_mem_hi       <= i_ex_hi;
        o_mem_lo       <= i_ex_lo;
        o_mem_aluop    <= i_ex_aluop;
        o_mem_addr     <= i_ex_mem_addr;  
        o_mem_data     <= i_ex_mem_data; 
        o_mem_except_type   <= i_ex_except_type;
        o_mem_delayslot_vld <= i_ex_delayslot_vld;
        o_mem_curr_inst_addr<= i_ex_curr_inst_addr;
    end else begin
        o_mem_wen      <= o_mem_wen     ;
        o_mem_wdata    <= o_mem_wdata   ;
        o_mem_waddr    <= o_mem_waddr   ;
        o_mem_hilo_wen <= o_mem_hilo_wen;
        o_mem_hi       <= o_mem_hi      ;
        o_mem_lo       <= o_mem_lo      ;
        o_mem_aluop    <= o_mem_aluop   ;
        o_mem_addr     <= o_mem_addr    ;
        o_mem_data     <= o_mem_data    ;
        o_mem_except_type   <= o_mem_except_type   ;
        o_mem_delayslot_vld <= o_mem_delayslot_vld ;
        o_mem_curr_inst_addr<= o_mem_curr_inst_addr;
    end
end

// when ex stage is pausing, give back the hilo_temp
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if( !i_rst_n ) begin
        o_hilo_temp <= 'b0;
        o_cnt       <= 2'b00;
    end else if( i_flush == 1'b1 ) begin 
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

// when ex stage is not pausing, pass the cp0 write info to next stage
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if( !i_rst_n ) begin
        o_mem_cp0_reg_wen   <= `WRITE_DISABLE;
        o_mem_cp0_reg_waddr <= 'b0;
        o_mem_cp0_reg_wdata <= 'b0;
    end else if( i_flush ) begin 
        o_mem_cp0_reg_wen   <= `WRITE_DISABLE;
        o_mem_cp0_reg_waddr <= 'b0;
        o_mem_cp0_reg_wdata <= 'b0;
    end else if( (i_stall[3] == `STOP) && (i_stall[4]==`NO_STOP) ) begin
        o_mem_cp0_reg_wen   <= `WRITE_DISABLE;
        o_mem_cp0_reg_waddr <= 'b0;
        o_mem_cp0_reg_wdata <= 'b0;
    end else if( i_stall[3] == `NO_STOP ) begin
        o_mem_cp0_reg_wen   <= i_ex_cp0_reg_wen  ;
        o_mem_cp0_reg_waddr <= i_ex_cp0_reg_waddr;
        o_mem_cp0_reg_wdata <= i_ex_cp0_reg_wdata;
    end else begin
        o_mem_cp0_reg_wen   <= o_mem_cp0_reg_wen  ;
        o_mem_cp0_reg_waddr <= o_mem_cp0_reg_waddr;
        o_mem_cp0_reg_wdata <= o_mem_cp0_reg_wdata;
    end
end
endmodule