/**************************************
@ filename    : pause_ctrl.sv
@ author      : yyrwkk
@ create time : 2024/09/05 09:47:21
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module pause_ctrl(
    input  logic       i_id_stallreq   ,
    input  logic       i_ex_stallreq   ,
    output logic [5:0] o_stall        
);

always_comb begin
    if( i_ex_stallreq == `STOP ) begin
        o_stall = 6'b001111;
    end else if( i_id_stallreq == `STOP ) begin
        o_stall = 6'b000111;
    end else begin
        o_stall = 'b0;
    end
end

endmodule