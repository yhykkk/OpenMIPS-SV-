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

/********** instruction rom interface *********/
logic                     inst_ren  ;
logic [`N_INST_ADDR-1:0]  inst_addr ;
logic [`N_INST_DATA-1:0]  inst      ;

/********** data ram interface *********/
logic [`N_MEM_ADDR-1:0]   o_ram_addr; 
logic [`N_MEM_DATA-1:0]   o_ram_data; 
logic                     o_ram_we  ; 
logic                     o_ram_ce  ; 
logic [3:0]               o_ram_sel ; 
logic [`N_MEM_DATA-1:0]   i_ram_data;

/******** interrupt interface ********/ 
logic [`CP0_REG_N_INT-1:0] interrupt      ;      
logic                      timer_interrupt;

openmips openmips_inst (
    .i_clk            (i_clk          ),
    .i_rst_n          (i_rst_n        ),
    .i_inst_data      (inst           ),
    .o_inst_ren       (inst_ren       ),
    .o_inst_addr      (inst_addr      ),
         
    .i_ram_data       (i_ram_data     ),
    .o_ram_addr       (o_ram_addr     ),
    .o_ram_data       (o_ram_data     ),
    .o_ram_we         (o_ram_we       ),
    .o_ram_ce         (o_ram_ce       ),
    .o_ram_sel        (o_ram_sel      ),
 
    .i_interrupt      (interrupt      ),
    .o_timer_interrupt(timer_interrupt)
);

assign interrupt = {5'b0,timer_interrupt};  // attach timer_interrupt to interrupt input 


inst_rom inst_rom_inst (
    .i_ce    (inst_ren ),
    .i_addr  (inst_addr),

    .o_inst  (inst     )
);

data_ram data_ram_inst (
    .i_clk   (i_clk     ),
    .i_ce    (o_ram_ce  ),
    .i_data  (o_ram_data),
    .i_addr  (o_ram_addr),
    .i_we    (o_ram_we  ),
    .i_sel   (o_ram_sel ),
    .o_data  (i_ram_data)
);

endmodule