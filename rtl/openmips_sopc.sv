/**************************************
@ filename    : openmips_sopc.sv
@ author      : yyrwkk
@ create time : 2024/08/14 22:55:59
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module openmips_sopc (
    input  logic    i_clk   ,
    input  logic    i_rst_n 
);

logic                     inst_ren ;
logic [`N_INST_ADDR-1:0]  inst_addr;
logic [`N_INST_DATA-1:0]  inst     ;

openmips openmips_inst (
    .i_clk       (i_clk    ),
    .i_rst_n     (i_rst_n  ),
    .i_inst_data (inst     ),
    .o_inst_ren  (inst_ren ),
    .o_inst_addr (inst_addr)
);

inst_rom inst_rom_inst (
    .i_ce    (inst_ren ),
    .i_addr  (inst_addr),

    .o_inst  (inst     )
);


endmodule