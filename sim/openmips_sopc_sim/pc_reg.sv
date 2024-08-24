/**************************************
@ filename    : pc_reg.sv
@ author      : yyrwkk
@ create time : 2024/08/09 12:56:39
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module pc_reg (
    input  logic                    i_clk   ,
    input  logic                    i_rst_n ,

    output logic [`N_INST_ADDR-1:0] o_pc    ,
    output logic                    o_ce  
);

always_ff @(posedge i_clk or negedge i_rst_n ) begin
   if( i_rst_n == `RST_ENABLE ) begin
        o_ce <= `CHIP_DISABLE;
   end else begin
        o_ce <= `CHIP_ENABLE;
   end
end

always_ff @(posedge i_clk or negedge i_rst_n ) begin
    if( (i_rst_n == `RST_ENABLE) || (o_ce ==`CHIP_DISABLE) ) begin // when first ce == 1'b1 , the value of pc is 0x00 ( not from zero )
        o_pc <= 'b0;
    end else begin
        o_pc <= o_pc + 4'h4;   // when ce enalbe, the value of pc add 4 every clk
    end
end

endmodule