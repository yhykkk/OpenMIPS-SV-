/**************************************
@ filename    : pause_ctrl.sv
@ author      : yyrwkk
@ create time : 2024/09/05 09:47:21
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module pause_ctrl(
    input  logic                    i_id_stallreq   ,
    input  logic                    i_ex_stallreq   ,
    output logic [5:0]              o_stall         ,
    
    input  logic [`N_REG-1:0]       i_cp0_epc       , 
    input  logic [31:0]             i_except_type   ,
    output logic [`N_INST_ADDR-1:0] o_new_pc        ,
    output logic                    o_flush            
);

always_comb begin
    if( i_except_type != 'b0 ) begin // except assert
        o_flush = 1'b1; 
        o_stall = 'b0;
        case( i_except_type )
        32'h00_00_00_01: begin 
            o_new_pc = 32'h00_00_00_20 ; // interrupt 
        end
        32'h00_00_00_08: begin  
            o_new_pc = 32'h00_00_00_40 ; // syscall 
        end
        32'h00_00_00_0a: begin 
            o_new_pc = 32'h00_00_00_40 ; // invalid instruction 
        end
        32'h00_00_00_0d: begin 
            o_new_pc = 32'h00_00_00_40 ; // trap
        end
        32'h00_00_00_0c: begin 
            o_new_pc = 32'h00_00_00_40 ; // overflow
        end
        32'h00_00_00_0e: begin 
            o_new_pc = i_cp0_epc;        // eret
        end
        default: begin 
            o_new_pc = 'b0;
        end
        endcase
    end else if( i_ex_stallreq == `STOP ) begin
        o_stall = 6'b001111;
        o_flush = 1'b0;
        o_new_pc = 'b0;
    end else if( i_id_stallreq == `STOP ) begin
        o_stall = 6'b000111;
        o_flush = 1'b0;
        o_new_pc = 'b0;
    end else begin
        o_stall = 'b0;
        o_flush = 1'b0;
        o_new_pc = 'b0;
    end
end

endmodule