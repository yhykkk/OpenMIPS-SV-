/**************************************
@ filename    : tb_divider.sv
@ author      : yyrwkk
@ create time : 2024/09/09 20:15:01
@ version     : v1.0.0
**************************************/
`timescale 1ns/1ns

module tb_divider() ;
parameter N_DIVIDEND = 32;
parameter N_DIVISOR  = 32;

logic                  i_clk      ;
logic                  i_rst_n    ;
logic                  i_divsigned;
logic [N_DIVIDEND-1:0] i_dividend ;
logic [N_DIVISOR-1:0]  i_divisor  ;
logic                  i_divstart ;
logic [N_DIVIDEND-1:0] o_quotient ;
logic [N_DIVISOR-1:0]  o_remainder;
logic                  o_res_vld  ;   

divider # (
    .N_DIVIDEND (N_DIVIDEND),
    .N_DIVISOR  (N_DIVISOR )
)divider_inst(
    .i_clk      (i_clk      ),
    .i_rst_n    (i_rst_n    ),
    .i_divsigned(i_divsigned),
    .i_dividend (i_dividend ),
    .i_divisor  (i_divisor  ),
    .i_divstart (i_divstart ),
    .o_quotient (o_quotient ),
    .o_remainder(o_remainder),
    .o_res_vld  (o_res_vld  )    
);

initial begin
    i_clk      = 'b0;
    i_rst_n    = 'b0;
    i_divsigned= 1'b0;
    i_dividend = 'b0;
    i_divisor  = 'b0;
    i_divstart = 'b0;
end

initial begin
    forever #5 i_clk = ~i_clk;
end 

initial begin
    @(posedge i_clk);
    i_rst_n <= 1'b1;
    @(posedge i_clk);

    for(int i=0;i<64;i++) begin
        i_dividend <= ~i + 1'b1;
        i_divsigned<= 1'b1;
        i_divisor  <= i+1;
        i_divstart <= 1'b1;
        @(posedge i_clk);
    end

    repeat(100) @(posedge i_clk);
    $stop;
end


endmodule 