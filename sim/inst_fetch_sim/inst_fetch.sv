/**************************************
@ filename    : inst_fetch.sv
@ author      : yyrwkk
@ create time : 2024/08/09 22:34:52
@ version     : v1.0.0
**************************************/
module inst_fetch #(
    parameter NPC  =  6   ,
    parameter NINST=  32  
)(
    input  logic             i_clk   ,
    input  logic             i_rst_n ,

    output logic [NINST-1:0] o_inst   
);

logic [NPC-1:0] pc  ;
logic           ce  ;

pc_reg # (
    .NPC  (NPC)  
)pc_reg_inst(
    .i_clk   (i_clk  ),
    .i_rst_n (i_rst_n),
    .o_pc    (pc     ),
    .o_ce    (ce     ) 
);

rom # (
    .NPC   (NPC  ),
    .NINST (NINST)
)rom_inst(
    .i_ce    (ce    ),
    .i_addr  (pc  ),
    .o_inst  (o_inst)
);

endmodule