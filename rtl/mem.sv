/**************************************
@ filename    : mem.sv
@ author      : yyrwkk
@ create time : 2024/08/14 20:21:01
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module mem (
    input  logic                   i_rst_n    ,
    input  logic                   i_wen      ,
    input  logic [`N_REG_ADDR-1:0] i_waddr    ,
    input  logic [`N_REG-1:0]      i_wdata    ,

    output logic                   o_wen      ,
    output logic [`N_REG_ADDR-1:0] o_waddr    ,
    output logic [`N_REG-1:0]      o_wdata    ,

    input  logic                   i_hilo_wen ,
    input  logic [`N_REG-1:0]      i_hi       ,
    input  logic [`N_REG-1:0]      i_lo       ,

    output logic                   o_hilo_wen ,
    output logic [`N_REG-1:0]      o_hi       ,
    output logic [`N_REG-1:0]      o_lo
);

always_comb begin
    // if( i_rst_n == `RST_ENABLE )  begin
    //     o_wen   = `WRITE_DISABLE;
    //     o_waddr = `NOP_REG_ADDR ;
    //     o_wdata = 'b0;
    //     o_hilo_wen = `WRITE_DISABLE;
    //     o_hi       = 'b0;
    //     o_lo       = 'b0;
    // end else begin
    //     o_wen   = i_wen ;
    //     o_waddr = i_waddr;
    //     o_wdata = i_wdata;
    //     o_hilo_wen = i_hilo_wen;
    //     o_hi       = i_hi      ;
    //     o_lo       = i_lo      ;
    // end
    o_wen      = i_wen     ;
    o_waddr    = i_waddr   ;
    o_wdata    = i_wdata   ;
    o_hilo_wen = i_hilo_wen;
    o_hi       = i_hi      ;
    o_lo       = i_lo      ;
end

endmodule