/**************************************
@ filename    : div.sv
@ author      : yyrwkk
@ create time : 2024/09/09 11:18:46
@ version     : v1.0.0
**************************************/
module div # (
    parameter N_WIDTH  =  32  
)(
    input  logic                  i_clk          ,
    input  logic                  i_rst_n        ,
 
    input  logic                  i_divsigned    ,

    input  logic                  i_divstart     ,
    input  logic [N_WIDTH-1:0]    i_dividend     ,
    input  logic [N_WIDTH-1:0]    i_divisor      ,

    input  logic                  i_cancel       ,

    output logic [N_WIDTH-1:0]    o_quotient     ,
    output logic [N_WIDTH-1:0]    o_remainder    ,
    output logic                  o_done_vld     ,

    output logic                  o_ready             
);

localparam s_idle      = 3'd0;
localparam s_divinit   = 3'd1;
localparam s_divbyzero = 3'd2;
localparam s_divon     = 3'd3;
localparam s_divend    = 3'd4;

logic [2:0]  curr_state       ;
logic [2:0]  next_state       ;

logic [4:0]  cnt              ;

logic [31:0] dividend_temp    ;
logic [31:0] divisor_temp     ;

logic [31:0] dividend         ;
logic [31:0] divisor          ;
logic        div_signed       ;
logic        dividend_signed  ;
logic        divisor_signed   ;

logic [31:0] div_temp         ;
logic [32:0] div_sub          ;

logic [31:0] quotient         ;
logic [31:0] remainder        ;


assign dividend_temp = (i_divsigned & i_dividend[31]) ? (~i_dividend + 1'b1) : i_dividend;
assign divisor_temp  = (i_divsigned & i_divisor[31]) ? (~i_divisor + 1'b1) : i_divisor;


always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(!i_rst_n ) begin
        dividend   <= 'b0;
        divisor    <= 'b0;
        div_signed <= 'b0;
    end else begin
        if( (o_ready == 1'b1 ) && (i_divstart == 1'b1 ) ) begin
            dividend   <= dividend_temp;
            divisor    <= divisor_temp;
            div_signed <= i_divsigned;
            dividend_signed <= i_dividend[31];
            divisor_signed  <= i_divisor[31];
        end else begin
            dividend   <= dividend   ;
            divisor    <= divisor    ;
            div_signed <= div_signed ;
            dividend_signed <= dividend_signed;
            divisor_signed  <= divisor_signed ;
        end
    end
end

always_ff@(posedge i_clk or negedge i_rst_n ) begin
    if( !i_rst_n ) begin
        curr_state <= s_idle;
    end else begin
        curr_state <= next_state;
    end
end

always_comb begin
    case(curr_state )
    s_idle     : begin
        if( (o_ready == 1'b1 ) && (i_divstart == 1'b1 ) && (i_cancel == 1'b0 )) begin
            if( i_divisor == 'b0 ) begin
                next_state = s_divbyzero;
            end else begin
                next_state = s_divinit;
            end
        end else begin
            next_state = s_idle;
        end
    end
    s_divinit  : begin
        if( i_cancel == 1'b0 ) begin 
            next_state = s_divon;
        end else begin
            next_state = s_idle;
        end
    end
    s_divbyzero: begin
        if( i_cancel == 1'b0 ) begin 
            next_state = s_divend;
        end else begin 
            next_state = s_idle;
        end
    end
    s_divon    : begin
        if( i_cancel == 1'b0 ) begin 
            if( cnt == 'd0 ) begin
                next_state = s_divend;
            end else begin
                next_state = s_divon;
            end
        end else begin 
            next_state = s_idle;
        end
    end
    s_divend   : begin
        next_state = s_idle;
    end
    default    : begin
        next_state = s_idle;
    end
    endcase
end

assign div_sub = {1'b0,div_temp}-{1'b0,divisor};

always_ff@(posedge i_clk or negedge i_rst_n ) begin
    if( !i_rst_n ) begin
        o_ready    <= 1'b1;
        div_temp   <= 'b0;
        cnt        <= 'd31;
        quotient   <= 'b0;
        remainder  <= 'b0;
        o_done_vld <= 1'b0;
    end else begin
        o_ready    <= 1'b0;
        div_temp   <= div_temp;
        cnt        <= cnt;
        quotient   <= quotient;
        remainder  <= remainder;
        o_done_vld <= 1'b0;
        case( next_state )
        s_idle     : begin
            o_ready <= 1'b1;
            div_temp<= 'b0;
            cnt     <= 'd31;
        end
        s_divinit  : begin
            div_temp <= dividend_temp[31];
            cnt      <= 'd31;
        end
        s_divbyzero: begin
            quotient <= 'b0;
        end
        s_divon    : begin
            if(div_sub[32]=='b0) begin
                quotient <= (quotient << 1'b1) | 1'b1;
                div_temp   <= {div_sub[30:0],dividend[cnt-1'b1]};
            end else begin
                quotient <= (quotient << 1'b1);
                div_temp   <= {div_temp[30:0],dividend[cnt-1'b1]};
            end
            cnt <= cnt - 1'b1;
        end
        s_divend   : begin
            if( cnt == 'd31 ) begin
                remainder <= 'b0;
            end else begin
                remainder <= (div_sub[32]==1'b0)?div_sub[31:0]:div_temp;

                if(div_sub[32]=='b0) begin
                    quotient <= (quotient << 1'b1) | 1'b1;
                end else begin
                    quotient <= (quotient << 1'b1);
                end
            end
            o_done_vld <= 1'b1;
        end
        default    : begin
            
        end
        endcase
    end 
end

always_comb begin
    if( o_done_vld == 1'b1 ) begin
        if( (div_signed == 1'b1 ) && ( dividend_signed ^ divisor_signed ) ) begin
            o_quotient = ~quotient + 1'b1;
        end else begin
            o_quotient = quotient;
        end
    end else begin
        o_quotient = 'b0;
    end
end 

always_comb begin
    if( o_done_vld == 1'b1 ) begin
        if( (div_signed == 1'b1 ) && ( dividend_signed ^ remainder[31] )) begin
            o_remainder = ~remainder + 1'b1;
        end else begin
            o_remainder = remainder;
        end
    end else begin
        o_remainder = 'b0;
    end
end 


endmodule