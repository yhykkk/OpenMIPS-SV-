/**************************************
@ filename    : hilo_reg.sv
@ author      : yyrwkk
@ create time : 2024/08/25 16:13:15
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module hilo_reg (
    input  logic               i_clk    ,
    input  logic               i_rst_n  ,

    input  logic               i_wen    ,
    input  logic [`N_REG-1:0]  i_hi     ,
    input  logic [`N_REG-1:0]  i_lo     ,

    output logic [`N_REG-1:0]  o_hi     ,
    output logic [`N_REG-1:0]  o_lo 
);

always_ff @(posedge i_clk or negedge i_rst_n ) begin
    if( i_rst_n == `RST_ENABLE ) begin
        o_hi <= 'b0;
        o_lo <= 'b0;
    end else begin
        if( i_wen == `WRITE_ENABLE ) begin
            o_hi <= i_hi ;
            o_lo <= i_lo ;
        end else begin
            o_hi <= o_hi ;
            o_lo <= o_lo ;
        end
    end
end

endmodule