/**************************************
@ filename    : inst_rom.sv
@ author      : yyrwkk
@ create time : 2024/08/14 22:42:49
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module inst_rom (
    input  logic                      i_ce    ,
    input  logic [`N_INST_ADDR-1:0]   i_addr  ,

    output logic [`N_INST_DATA-1:0]   o_inst 
);

logic [`N_INST_DATA-1:0] inst_mem [`NUM_INST_MEM-1:0] ; 

initial begin
    $readmemh("inst_rom.dat",inst_mem);
end

always_comb begin 
    if( i_ce == `CHIP_DISABLE ) begin
        o_inst = 'b0;
    end else begin
        o_inst = inst_mem[i_addr[`N_INST_ADDR_USE+2-1:2]];
    end
end

endmodule