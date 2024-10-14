/**************************************
@ filename    : cp0.sv
@ author      : yyrwkk
@ create time : 2024/10/12 01:00:58
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module cp0 (
    input  logic                       i_clk            ,
    input  logic                       i_rst_n          ,

    input  logic [`CP0_REG_N_ADDR-1:0] i_r_addr         ,
    input  logic [`CP0_REG_N_INT -1:0] i_interrupt      ,
    input  logic                       i_w_en           ,
    input  logic [`CP0_REG_N_ADDR-1:0] i_w_addr         ,   
    input  logic [`N_REG-1:0]          i_w_data         ,

    output logic [`N_REG-1:0]          o_data           ,
    output logic [`N_REG-1:0]          o_count          ,
    output logic [`N_REG-1:0]          o_compare        ,
    output logic [`N_REG-1:0]          o_status         ,
    output logic [`N_REG-1:0]          o_cause          ,
    output logic [`N_REG-1:0]          o_epc            ,
    output logic [`N_REG-1:0]          o_config         ,
    output logic [`N_REG-1:0]          o_prid           ,
    output logic                       o_timer_interrupt
);

// reg operate
always_ff @ (posedge i_clk or negedge i_rst_n) begin
    if( i_rst_n == `RST_ENABLE ) begin
        o_count   <= 'b0;
        o_compare <= 'b0;
        // field cu -> 4'b0001, cp0 is exist
        o_status  <= 32'b0001_0000_0000_0000_0000_0000_0000_0000;
        o_cause   <= 'b0;
        o_epc     <= 'b0;
        // field be -> 1'b1 , MSB
        o_config  <= 32'b0000_0000_0000_0000_1000_0000_0000_0000;
        // prid, L, type 0x1, version 1.0
        o_prid    <= 32'b0000_0000_0100_1100_0000_0001_0000_0010;
        o_timer_interrupt <= ~(`INTERRUPT_ASSERT);
    end else begin
        o_count <= o_count + 1'b1;     // every clk inc
        o_cause[15:10] <= i_interrupt; // cause 's [15:10] -> extern interrupt
        // when compare is not zero, and count == compare -> time_interrupt is occur
        if( (o_compare != 'b0) && (o_count == o_compare ) ) begin
            o_timer_interrupt <= `INTERRUPT_ASSERT;
        end else begin
            o_timer_interrupt <= o_timer_interrupt;
        end

        if( i_w_en == `WRITE_ENABLE ) begin
            case( i_w_addr ) 
            `CP0_REG_COUNT: begin
                o_count <= i_w_data;
            end
            `CP0_REG_COMPARE: begin
                o_compare <= i_w_data;
                o_timer_interrupt <= ~(`INTERRUPT_ASSERT);
            end
            `CP0_REG_STATUS: begin
                o_status <= i_w_data;
            end
            `CP0_REG_EPC: begin
                o_epc    <= i_w_data;
            end
            `CP0_REG_CAUSE: begin
                // just ip[1:0], iv, wp filed can write
                o_cause[9:8] <= i_w_data[9:8];
                o_cause[23] <= i_w_data[23];
                o_cause[22] <= i_w_data[22];
            end
            default: begin
            end
            endcase
        end
    end
end

// reg read
always_comb begin
    case(i_r_addr)
    `CP0_REG_COUNT: begin
        o_data = o_count;
    end
    `CP0_REG_COMPARE: begin
        o_data = o_compare;
    end
    `CP0_REG_STATUS: begin  
        o_data = o_status;
    end
    `CP0_REG_CAUSE: begin
        o_data = o_cause;
    end
    `CP0_REG_EPC: begin
        o_data = o_epc;
    end
    `CP0_REG_PRID: begin
        o_data = o_prid;
    end
    `CP0_REG_CONFIG: begin
        o_data = o_config;
    end
    default: begin
        o_data = 'b0;
    end
    endcase
end

endmodule