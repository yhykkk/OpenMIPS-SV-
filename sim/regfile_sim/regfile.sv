/**************************************
@ filename    : regfile.sv
@ author      : yyrwkk
@ create time : 2024/08/12 22:39:00
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module regfile (
    input  logic                    i_clk     ,
    input  logic                    i_rst_n   ,
    // write port
    input  logic [`N_REG_ADDR-1:0]  i_waddr   ,
    input  logic [`N_REG-1:0]       i_wdata   ,
    input  logic                    i_wen     ,
    // read port
    input  logic [`N_REG_ADDR-1:0]  i_raddr_0 ,
    input  logic                    i_ren_0   ,
    output logic [`N_REG-1:0]       o_rdata_0 ,

    input  logic [`N_REG_ADDR-1:0]  i_raddr_1 ,
    input  logic                    i_ren_1   ,
    output logic [`N_REG-1:0]       o_rdata_1  
);

logic [`N_REG-1:0] regs [`NUM_REG-1:0] ;

// write logic
always_ff@(posedge i_clk or negedge i_rst_n ) begin
    if( i_rst_n == `RST_ENABLE ) begin

    end else begin
        if( ( i_wen == `WRITE_ENABLE ) && (i_waddr != `NOP_REG_ADDR) ) begin
            regs[i_waddr] <= i_wdata;
        end else begin

        end
    end
end

// read port 0 logic 
always_comb begin 
    if( i_rst_n == `RST_ENABLE ) begin
        o_rdata_0 <= 'b0;
    end else begin
        if( i_raddr_0 == `NOP_REG_ADDR ) begin
            o_rdata_0 <= 'b0;
        end else if(( i_raddr_0 == i_waddr ) && (i_wen == `WRITE_ENABLE) && ( i_ren_0 == `READ_ENABLE )) begin
            o_rdata_0 <= i_wdata ;      // write first
        end else if( i_ren_0 == `READ_ENABLE ) begin
            o_rdata_0 <= regs[i_raddr_0];
        end else begin
            o_rdata_0 <= 'b0;
        end
    end
end

// read port 1 logic
always_comb begin 
    if( i_rst_n == `RST_ENABLE ) begin
        o_rdata_1 <= 'b0;
    end else begin
        if( i_raddr_1 == `NOP_REG_ADDR ) begin
            o_rdata_1 <= 'b0;
        end else if(( i_raddr_1 == i_waddr ) && (i_wen == `WRITE_ENABLE) && ( i_ren_1 == `READ_ENABLE )) begin
            o_rdata_1 <= i_wdata ;      // write first
        end else if( i_ren_1 == `READ_ENABLE ) begin
            o_rdata_1 <= regs[i_raddr_1];
        end else begin
            o_rdata_1 <= 'b0;
        end
    end
end

endmodule