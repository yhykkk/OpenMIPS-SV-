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

    output logic [`N_INST_ADDR-1:0]   o_id_pc   ,
    output logic [`N_INST_DATA-1:0]   o_id_inst 
);

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if( i_rst_n == `RST_ENABLE ) begin
        o_id_pc   <= 'b0;
        o_id_inst <= 'b0;
    end else begin
        o_id_pc   <= i_if_pc;
        o_id_inst <= i_if_inst;
    end
end

endmodule