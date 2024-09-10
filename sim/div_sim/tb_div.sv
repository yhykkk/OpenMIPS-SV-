/**************************************
@ filename    : tb_div.sv
@ author      : yyrwkk
@ create time : 2024/09/08 22:45:47
@ version     : v1.0.0
**************************************/
module tb_div();
parameter N_WIDTH  =  32            ;

logic                  i_clk        ; 
logic                  i_rst_n      ; 
logic                  i_divsigned  ; 
logic                  i_divstart   ; 
logic [N_WIDTH-1:0]    i_dividend   ; 
logic [N_WIDTH-1:0]    i_divisor    ; 
logic [N_WIDTH-1:0]    o_quotient   ; 
logic [N_WIDTH-1:0]    o_remainder  ; 
logic                  o_done_vld   ; 
logic                  o_ready      ; 

div div_inst (
    .i_clk          (i_clk         ),
    .i_rst_n        (i_rst_n       ),
    .i_divsigned    (i_divsigned   ),
    .i_divstart     (i_divstart    ),
    .i_dividend     (i_dividend    ),
    .i_divisor      (i_divisor     ),
    .o_quotient     (o_quotient    ),
    .o_remainder    (o_remainder   ),
    .o_done_vld     (o_done_vld    ),
    .o_ready        (o_ready       )     
);

initial begin
    i_clk       = 'b0;
    i_rst_n     = 'b0;
    i_divsigned = 'b0;
    i_divstart  = 'b0;
    i_dividend  = 'b0;
    i_divisor   = 'b0;
end 


initial begin
    forever #5 i_clk = ~i_clk;
end 

initial begin
    @(posedge i_clk );
    i_rst_n <= 1'b1;
    @(posedge i_clk );
    i_divsigned = 'b1;
    i_divstart  = 'b1;
    i_dividend  = {{29{1'b1}},3'b010};
    i_divisor   = 'd5;
    @(posedge i_clk );
    i_divsigned = 'b0;
    i_divstart  = 'b0;
    i_dividend  = 'd0;
    i_divisor   = 'd0;

    repeat(100) @(posedge i_clk);
    $stop;
end

endmodule