/**************************************
@ filename    : if_id.sv
@ author      : yyrwkk
@ create time : 2024/08/12 22:22:02
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module if_id (
    input  logic                      i_clk     ,
    input  logic                      i_rst_n   ,
  
    input  logic [`N_INST_ADDR-1:0]   i_if_pc   ,
    input  logic [`N_INST_DATA-1:0]   i_if_inst ,

    input  logic [5:0]                i_stall   ,

    output logic [`N_INST_ADDR-1:0]   o_id_pc   ,
    output logic [`N_INST_DATA-1:0]   o_id_inst ,

    input  logic                      i_flush  
);
// stall[1]==STOP, stall[2]==NOSTOP , fetch stop, id run -> generate nop instruct
// stall[1]==NOSTOP                 , fetch run
// others: id_pc,id_inst no change
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if( i_rst_n == `RST_ENABLE ) begin
        o_id_pc   <= 'b0;
        o_id_inst <= 'b0;
    end else if( i_flush == 1'b1 ) begin // clear id_pc, id_inst
        o_id_pc   <= 'b0;
        o_id_inst <= 'b0;
    end else if( (i_stall[1] == `STOP) &&(i_stall[2] == `NO_STOP )) begin
        o_id_pc   <= 'b0;
        o_id_inst <= 'b0;  // nop instruction
    end else if( i_stall[1] == `NO_STOP ) begin
        o_id_pc   <= i_if_pc;
        o_id_inst <= i_if_inst;
    end else begin
        o_id_pc   <= o_id_pc;
        o_id_inst <= o_id_inst;
    end
end

endmodule