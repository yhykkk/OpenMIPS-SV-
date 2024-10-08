/**************************************
@ filename    : llbit_reg.sv
@ author      : yyrwkk
@ create time : 2024/10/07 14:19:13
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module llbit_reg(
    input  logic    i_clk     ,
    input  logic    i_rst_n   ,

    input  logic    i_flush   , // whether exception is occurred, 1 -> occurred
    input  logic    i_wen     , 
    input  logic    i_llbit   ,
    output logic    o_llbit  
);

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if( i_rst_n == `RST_ENABLE)    begin
        o_llbit <= 1'b0;
    end else begin
        if( i_flush == 1'b1 ) begin // when exception occurred, set llbit to 0
            o_llbit <= 1'b0;
        end else if( i_wen == `WRITE_ENABLE ) begin
            o_llbit <= i_llbit;
        end else begin
            o_llbit <= o_llbit;
        end
    end
end

endmodule