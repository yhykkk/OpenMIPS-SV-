/**************************************
@ filename    : divider_cell.sv
@ author      : yyrwkk
@ create time : 2024/09/09 15:28:19
@ version     : v1.0.0
**************************************/
module divider_cell # (
    parameter N_DIVIDEND = 32,
    parameter N_DIVISOR  = 32
)(
    input  logic                    i_clk             ,
    input  logic                    i_rst_n           ,
             
    input  logic                    i_en              ,

    input  logic                    i_div_signed      ,
    input  logic                    i_dividend_signed ,
    input  logic                    i_divisor_signed  ,

    input  logic [N_DIVISOR+1-1:0]  i_dividend        ,  // last remainder + 1 bit origin dividend data -> N_DIVISOR + 1'b1
    input  logic [N_DIVISOR-1:0]    i_divisor         ,

    input  logic [N_DIVIDEND-1:0]   i_quotient_last   ,
    input  logic [N_DIVIDEND-1:0]   i_dividend_origin ,
 
    output logic [N_DIVIDEND-1:0]   o_dividend        ,
    output logic [N_DIVISOR-1:0]    o_divisor         ,

    output logic [N_DIVIDEND-1:0]   o_quotient        ,
    output logic [N_DIVISOR-1:0]    o_remainder       ,

    output logic                    o_div_signed      ,
    output logic                    o_dividend_signed ,
    output logic                    o_divisor_signed  ,

    output logic                    o_ready            
);

always_ff @(posedge i_clk or negedge i_rst_n ) begin
    if( !i_rst_n ) begin
        o_ready    <= 1'b0;
        o_dividend <= 'b0;
        o_divisor  <= 'b0;
        o_quotient <= 'b0;
        o_remainder<= 'b0;
        o_div_signed     <= 'b0;
        o_dividend_signed<= 'b0;
        o_divisor_signed <= 'b0;
    end else if( i_en ) begin
        o_ready    <= 1'b1;
        o_dividend <= i_dividend_origin;
        o_divisor  <= i_divisor;
        o_div_signed     <= i_div_signed     ;
        o_dividend_signed<= i_dividend_signed;
        o_divisor_signed <= i_divisor_signed ;
        if( i_dividend >= {1'b0,i_divisor}) begin
            o_quotient <= (o_quotient << 1'b1) | 1'b1;
            o_remainder<= i_dividend - {1'b0,i_divisor};
        end else begin
            o_quotient <= (o_quotient << 1'b1);
            o_remainder<= i_dividend;
        end
    end else begin
        o_ready    <= 1'b0;
        o_dividend <= 'b0;
        o_divisor  <= 'b0;
        o_quotient <= 'b0;
        o_remainder<= 'b0;
        o_div_signed     <= 'b0;
        o_dividend_signed<= 'b0;
        o_divisor_signed <= 'b0;
    end
end



endmodule