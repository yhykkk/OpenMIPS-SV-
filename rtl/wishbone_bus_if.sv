/**************************************
@ filename    : wishbone_bus_if.sv
@ author      : yyrwkk
@ create time : 2024/10/27 17:48:54
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module wishbone_bus_if(
    input  logic                    i_clk           ,
    input  logic                    i_rst_n         ,

    input  logic [5:0]              i_stall         ,
    input  logic                    i_flush         ,

    input  logic                    i_cpu_ce        ,
    input  logic [`N_REG-1:0]       i_cpu_data      ,
    input  logic [`N_INST_ADDR-1:0] i_cpu_addr      ,
    input  logic                    i_cpu_we        ,
    input  logic [3:0]              i_cpu_sel       ,

    output logic [`N_REG-1:0]       o_cpu_data      ,

    output logic [`N_INST_ADDR-1:0] o_wishbone_addr ,
    output logic [`N_REG-1:0]       o_wishbone_data ,
    output logic                    o_wishbone_we   ,
    output logic [3:0]              o_wishbone_sel  ,
    output logic                    o_wishbone_stb  ,
    output logic                    o_wishbone_cyc  ,
    input  logic [`N_REG-1:0]       i_wishbone_data ,
    input  logic                    i_wishbone_ack  ,

    output logic                    o_stallreq    
);

localparam s_idle =  2'b00;  // wb_idle
localparam s_busy =  2'b01;  // wb_busy
localparam s_wait =  2'b10;  // wb_wait_for_stall 

logic [1:0] curr_state;
logic [1:0] next_state;

always_ff @(posedge i_clk or negedge i_rst_n ) begin 
    if( ! i_rst_n ) begin 
        curr_state <= s_idle;
    end else begin
        curr_state <= next_state;
    end
end

always_comb begin
    case( curr_state )
    s_idle : begin 
        if( i_cpu_ce && (i_flush == 1'b0 ) ) begin 
            next_state = s_busy;
        end else begin 
            next_state = s_idle;
        end
    end
    s_busy : begin 
        if( i_flush == 1'b1 ) begin 
            next_state = s_idle;
        end else if( i_wishbone_ack == 1'b1 ) begin 
            if( i_stall != 'b0 ) begin 
                next_state = s_wait;
            end else begin
                next_state = s_idle;
            end
        end else begin 
            next_state = s_busy;
        end
    end
    s_wait : begin 
        if( i_stall == 'b0 ) begin 
            next_state = s_idle;
        end else begin 
            next_state = s_wait;
        end
    end
    default: begin 
        next_state = s_idle;
    end
    endcase
end

logic [`N_INST_ADDR-1:0] cpu_addr;
logic [`N_REG-1:0]       cpu_data;
logic [`N_INST_ADDR-1:0] cpu_we  ;
logic [`N_REG-1:0]       cpu_sel ;

always_ff @(posedge i_clk or negedge i_rst_n ) begin 
    if( !i_rst_n ) begin 
        cpu_addr <= 'b0;
        cpu_data <= 'b0;
        cpu_we   <= 'b0;
        cpu_sel  <= 'b0;
    end else if( (curr_state == s_idle ) && ( i_cpu_ce ) ) begin 
        cpu_addr <= i_cpu_addr;
        cpu_data <= i_cpu_data;
        cpu_we   <= i_cpu_we;
        cpu_sel  <= i_cpu_sel;
    end else begin 
        cpu_addr <= cpu_addr;
        cpu_data <= cpu_data;
        cpu_we   <= cpu_we  ;
        cpu_sel  <= cpu_sel ;
    end
end

logic first_flag;

always_ff@(posedge i_clk or negedge i_rst_n ) begin 
    if( !i_rst_n ) begin 
        o_wishbone_addr <= 'b0;
        o_wishbone_data <= 'b0;
        o_wishbone_we   <= `WRITE_DISABLE;
        o_wishbone_sel  <= 'b0;
        o_wishbone_stb  <= 'b0;
        o_wishbone_cyc  <= 'b0;
        first_flag      <= 'b0;
    end else begin
        o_wishbone_addr <= 'b0;
        o_wishbone_data <= 'b0;
        o_wishbone_we   <= `WRITE_DISABLE;
        o_wishbone_sel  <= 'b0;
        o_wishbone_stb  <= 'b0;
        o_wishbone_cyc  <= 'b0;
        first_flag      <= 'b0;
        case( next_state )
        s_idle : begin 
        end
        s_busy : begin 
            o_wishbone_addr <= i_cpu_ce ? i_cpu_addr: cpu_addr;
            o_wishbone_data <= i_cpu_ce ? i_cpu_data: cpu_data;
            o_wishbone_we   <= i_cpu_ce ? i_cpu_we  : cpu_we  ;
            o_wishbone_sel  <= i_cpu_ce ? i_cpu_sel : cpu_sel ;
            o_wishbone_stb  <= 1'b1;
            o_wishbone_cyc  <= 1'b1;
        end
        s_wait : begin 
        
        end
        default: begin 
        end
        endcase
    end
end


logic [`N_REG-1:0] wishbone_data;

always_ff @(posedge i_clk or negedge i_rst_n ) begin 
    if( !i_rst_n ) begin 
        wishbone_data <= 'b0;
    end else if((curr_state == s_busy ) && (i_wishbone_ack == 1'b1)) begin
        wishbone_data <= i_wishbone_data;
    end else begin 
        wishbone_data <= wishbone_data;
    end
end

always_comb begin 
    if(( i_cpu_ce == 1'b1 ) && ( i_flush == 1'b1 ) && (curr_state == s_idle) ) begin 
        o_stallreq = `STOP;
        o_cpu_data = 'b0  ;
    end else if ( (curr_state == s_busy ) && (i_wishbone_ack == 1'b1 )) begin
        if( cpu_we == `WRITE_DISABLE ) begin 
            o_cpu_data = i_wishbone_data;
        end else begin 
            o_cpu_data = 'b0;
        end
        o_stallreq = `NO_STOP;
    end else if( curr_state == s_wait ) begin // NOTING !!! ( curr_state , not nexe_state)
        o_stallreq = `NO_STOP;
        o_cpu_data = i_wishbone_ack?i_wishbone_data:wishbone_data;
    end else begin 
        o_stallreq = `NO_STOP;
        o_cpu_data = 'b0  ;
    end
end


endmodule