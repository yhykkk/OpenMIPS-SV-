/**************************************
@ filename    : divider.sv
@ author      : yyrwkk
@ create time : 2024/09/09 19:21:58
@ version     : v1.0.0
**************************************/
module divider # (
    parameter N_DIVIDEND = 32,
    parameter N_DIVISOR  = 32
)(
    input  logic                  i_clk      ,
    input  logic                  i_rst_n    ,

    input  logic                  i_divsigned,
    input  logic [N_DIVIDEND-1:0] i_dividend ,
    input  logic [N_DIVISOR-1:0]  i_divisor  ,

    input  logic                  i_divstart ,

    output logic [N_DIVIDEND-1:0] o_quotient ,
    output logic [N_DIVISOR-1:0]  o_remainder,
    output logic                  o_res_vld      
);

logic [N_DIVIDEND-1:0] dividend_temp  [N_DIVIDEND-1:0];
logic [N_DIVISOR-1:0]  divisor_temp   [N_DIVIDEND-1:0];
logic [N_DIVISOR-1:0]  remainder_temp [N_DIVIDEND-1:0];
logic [N_DIVIDEND-1:0] rdy_temp                       ;
logic [N_DIVIDEND-1:0] quotient_temp  [N_DIVIDEND-1:0];

logic [N_DIVIDEND-1:0] div_signed_temp                ;
logic [N_DIVIDEND-1:0] dividend_signed_temp           ;
logic [N_DIVIDEND-1:0] divisor_signed_temp            ;

logic [N_DIVIDEND-1:0] dividend ;
logic [N_DIVISOR-1:0]  divisor  ;

always_comb begin
    if( (i_divsigned==1'b1) && (i_dividend[N_DIVIDEND-1] == 1'b1 )) begin
        dividend = ~i_dividend + 1'b1;
    end else begin
        dividend = i_dividend;
    end
end

always_comb begin
    if( (i_divsigned==1'b1) && (i_divisor[N_DIVISOR-1] == 1'b1 )) begin
        divisor = ~i_divisor + 1'b1;
    end else begin
        divisor = i_divisor;
    end
end

genvar i;
generate 
    for( i=0;i<N_DIVIDEND;i=i+1) begin: div_block
        if( i==0 ) begin
            divider_cell #(
                .N_DIVIDEND(N_DIVIDEND),
                .N_DIVISOR (N_DIVISOR )
            )divider_cell_inst(
                .i_clk             ( i_clk                   ),
                .i_rst_n           ( i_rst_n                 ),         
                .i_en              ( i_divstart              ),
                .i_div_signed      ( i_divsigned             ),
                .i_dividend_signed ( i_dividend[N_DIVIDEND-1]),
                .i_divisor_signed  ( i_divisor[N_DIVISOR-1]  ),
                .i_dividend        ( {{N_DIVISOR{1'b0}},dividend[N_DIVIDEND-1]} ),  // last remainder + 1 bit origin dividend data -> N_DIVISOR + 1'b1
                .i_divisor         ( divisor                 ),
                .i_quotient_last   ( {N_DIVIDEND{1'b0}}      ),  // init quotient is zero
                .i_dividend_origin ( dividend                ),
                .o_dividend        ( dividend_temp        [i]),
                .o_divisor         ( divisor_temp         [i]),
                .o_quotient        ( quotient_temp        [i]),
                .o_remainder       ( remainder_temp       [i]),
                .o_ready           ( rdy_temp             [i]),
                .o_div_signed      ( div_signed_temp      [i]),
                .o_dividend_signed ( dividend_signed_temp [i]),
                .o_divisor_signed  ( divisor_signed_temp  [i])
            );
        end else begin
            divider_cell #(
                .N_DIVIDEND(N_DIVIDEND),
                .N_DIVISOR (N_DIVISOR )
            )divider_cell_inst(
                .i_clk             ( i_clk                   ),
                .i_rst_n           ( i_rst_n                 ),         
                .i_en              ( rdy_temp           [i-1]),
                .i_div_signed      (div_signed_temp     [i-1]),
                .i_dividend_signed (dividend_signed_temp[i-1]),
                .i_divisor_signed  (divisor_signed_temp [i-1]),
                .i_dividend        ({remainder_temp[i-1],dividend_temp[i-1][N_DIVIDEND-i-1]}),  // last remainder + 1 bit origin dividend data -> N_DIVISOR + 1'b1
                .i_divisor         (divisor_temp        [i-1]),
                .i_quotient_last   (quotient_temp       [i-1]),
                .i_dividend_origin (dividend_temp       [i-1]),
                .o_dividend        (dividend_temp         [i]),
                .o_divisor         (divisor_temp          [i]),
                .o_quotient        (quotient_temp         [i]),
                .o_remainder       (remainder_temp        [i]),
                .o_div_signed      (div_signed_temp       [i]),
                .o_dividend_signed (dividend_signed_temp  [i]),
                .o_divisor_signed  (divisor_signed_temp   [i]),
                .o_ready           (rdy_temp              [i]) 
            );
        end
    end
endgenerate

always_comb begin
    if( (div_signed_temp[N_DIVIDEND-1] == 1'b1 ) && ( dividend_signed_temp[N_DIVIDEND-1] ^ divisor_signed_temp[N_DIVIDEND-1] ) ) begin
        o_quotient = ~quotient_temp[N_DIVIDEND-1] + 1'b1;
    end else begin
        o_quotient = quotient_temp[N_DIVIDEND-1];
    end
end 

always_comb begin
    if( (div_signed_temp[N_DIVIDEND-1] == 1'b1 ) && ( dividend_signed_temp[N_DIVIDEND-1] ^ remainder_temp[N_DIVIDEND-1][N_DIVISOR-1] )) begin
        o_remainder = ~remainder_temp[N_DIVIDEND-1] + 1'b1;
    end else begin
        o_remainder = remainder_temp[N_DIVIDEND-1];
    end
end 

assign o_res_vld   = rdy_temp [N_DIVIDEND-1];

endmodule