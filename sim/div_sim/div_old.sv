/**************************************
@ filename    : div.sv
@ author      : yyrwkk
@ create time : 2024/09/08 21:03:53
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module div_old (
    input  logic                  i_clk        ,
    input  logic                  i_rst_n      ,
 
    input  logic                  i_signed     ,
    input  logic                  i_start      ,

    input  logic [`N_REG-1:0]     i_op_data_0  ,
    input  logic [`N_REG-1:0]     i_op_data_1  ,

    input  logic                  i_cancel     ,

    output logic [(2*`N_REG)-1:0] o_result     ,
    output logic                  o_done       ,

    output logic                  o_ready       
);

localparam s_idle      = 2'b00;
localparam s_divbyzero = 2'b01;
localparam s_divon     = 2'b10;
localparam s_divend    = 2'b11;

logic [31:0] op_data0_temp  ;
logic [31:0] op_data1_temp  ;
logic [4:0]  cnt            ;
logic [32:0] div_temp       ;
logic [64:0] dividend       ;
logic [31:0] divisor        ;
logic        sigend_flag    ;
logic        op_data0_signed;
logic        op_data1_signed;



logic [1:0]  curr_state   ;
logic [1:0]  next_state   ;

logic        first_flag   ;

always_ff @(posedge i_clk or negedge i_rst_n ) begin
    if( !i_rst_n ) begin
        curr_state <= s_idle;
    end else begin
        curr_state <= next_state;
    end
end

always_comb begin
    case ( curr_state ) 
    s_idle     : begin
        if( (o_ready == 1'b1) && (i_start == 1'b1 ) && ( i_cancel == 1'b0)) begin
            if( i_op_data_1 == 'b0 ) begin
                next_state = s_divbyzero;
            end else begin
                next_state = s_divon;
            end
        end else begin
            next_state = s_idle;
        end
    end
    s_divbyzero: begin
        next_state = s_idle;
    end
    s_divon    : begin
        if( i_cancel == 1'b0 ) begin
            if( cnt == 'd30 ) begin
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

always_comb begin
    if((o_ready == 1'b1) && (i_start == 1'b1 ) ) begin
        if( (i_signed == 1'b1 ) && (i_op_data_0[31] == 1'b1 )) begin
            op_data0_temp = ~i_op_data_0 + 1'b1;
        end else begin
            op_data0_temp = i_op_data_0;
        end
    end else begin
        op_data0_temp = 'b0;
    end
end

always_comb begin
    if((o_ready == 1'b1) && (i_start == 1'b1 ) ) begin
        if( (i_signed == 1'b1 ) && (i_op_data_1[31] == 1'b1 )) begin
            op_data1_temp = ~i_op_data_1 + 1'b1;
        end else begin
            op_data1_temp = i_op_data_1;
        end
    end else begin
        op_data1_temp = 'b0;
    end
end

always_comb begin
    if((o_ready == 1'b1) && (i_start == 1'b1 ) ) begin
        div_temp = {1'b0,31'b0,op_data0_temp[0]} - op_data1_temp;
    end else begin
        div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};
    end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if( !i_rst_n ) begin
        sigend_flag <= 1'b0;
    end else begin
        if( (o_ready == 1'b1) && (i_start == 1'b1 ) ) begin
            sigend_flag <= i_signed ;
        end else begin
            sigend_flag <= sigend_flag;
        end
    end
end

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if( !i_rst_n ) begin
        op_data0_signed <= 1'b0;
    end else begin
        if( (o_ready == 1'b1) && (i_start == 1'b1 ) ) begin
            op_data0_signed <= i_op_data_0[31];
        end else begin
            op_data0_signed <= op_data0_signed;
        end
    end
end

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if( !i_rst_n ) begin
        op_data1_signed <= 1'b0;
    end else begin
        if( (o_ready == 1'b1) && (i_start == 1'b1 ) ) begin
            op_data1_signed <= i_op_data_1[31];
        end else begin
            op_data1_signed <= op_data1_signed;
        end
    end
end

always_ff @(posedge i_clk or negedge i_rst_n ) begin
    if( !i_rst_n ) begin
        o_done      <= 'b0;
        o_ready     <= 1'b1;
        first_flag  <= 'b0;
        dividend    <= 'b0;
        divisor     <= 'b0;
        cnt         <= 'b0;
        o_done      <= 1'b0;
    end else begin
        o_done      <= 'b0;
        o_ready     <= o_ready;
        first_flag  <= 'b0;
        dividend    <= 'b0;
        divisor     <= 'b0;
        cnt         <= cnt;
        o_done      <= 1'b0;
        case ( next_state ) 
        s_idle     : begin
            o_ready <= 1'b1;
            cnt     <= 'b0 ;
        end
        s_divbyzero: begin
            dividend <= 'b0;
        end
        s_divon    : begin
            first_flag <= 1'b1;
            divisor <= divisor;
            if( ! first_flag ) begin
                divisor  <= op_data1_temp;
                if( div_temp[32] == 1'b1 ) begin
                    dividend <= {29'b0,op_data0_temp,2'b0,1'b0};
                end else begin
                    dividend <= {div_temp[31:0],op_data0_temp[30:0],1'b0,1'b1};  
                end
                cnt <= 'b0;
            end else begin
                if( div_temp[32] == 1'b1 ) begin
                    dividend <= {dividend[63:0],1'b0};
                end else begin
                    dividend <= {div_temp[31:0],dividend[31:0],1'b1};  
                end
                cnt <= cnt + 1'b1;
            end
        end
        s_divend   : begin
            if( cnt == 'd31 ) begin
                if( (sigend_flag == 1'b1) && ( op_data0_signed ^ op_data1_signed) ) begin
                    dividend[31:0] <= (~dividend[31:0]) + 1'b1;
                end else begin
                    dividend[31:0] <= dividend[31:0];
                end

                if( (sigend_flag == 1'b1) && ( op_data0_signed ^ dividend[64]) ) begin
                    dividend[64:33] <= (~dividend[64:33]) + 1'b1;
                end else begin
                    dividend[64:33] <= dividend[64:33];
                end
            end else begin  
                dividend <= dividend;
            end
            o_done <= 1'b1;
        end
        default    : begin
        end
        endcase
    end
end

always_comb begin
    if(o_done == 1'b1 ) begin
        o_result = {dividend[64:33],dividend[31:0]};
    end else begin
        o_result  = 'b0;
    end
end
endmodule