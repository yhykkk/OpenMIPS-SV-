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
// logic                     inst_ren  ;
// logic [`N_INST_ADDR-1:0]  inst_addr ;
// logic [`N_INST_DATA-1:0]  inst      ;

/********** data ram interface *********/
// logic [`N_MEM_ADDR-1:0]   o_ram_addr; 
// logic [`N_MEM_DATA-1:0]   o_ram_data; 
// logic                     o_ram_we  ; 
// logic                     o_ram_ce  ; 
// logic [3:0]               o_ram_sel ; 
// logic [`N_MEM_DATA-1:0]   i_ram_data;

/******** interrupt interface ********/ 
logic [`CP0_REG_N_INT-1:0] interrupt      ;      
logic                      timer_interrupt;

openmips openmips_inst (
    .i_clk                (i_clk          ),
    .i_rst_n              (i_rst_n        ),

    .o_ibus_wishbone_addr (),
    .o_ibus_wishbone_data (),
    .o_ibus_wishbone_we   (),
    .o_ibus_wishbone_sel  (),
    .o_ibus_wishbone_stb  (),
    .o_ibus_wishbone_cyc  (),
    .i_ibus_wishbone_data (),
    .i_ibus_wishbone_ack  (),

    .o_dbus_wishbone_addr (),
    .o_dbus_wishbone_data (),
    .o_dbus_wishbone_we   (),
    .o_dbus_wishbone_sel  (),
    .o_dbus_wishbone_stb  (),
    .o_dbus_wishbone_cyc  (),
    .i_dbus_wishbone_data (),
    .i_dbus_wishbone_ack  (),
 
    .i_interrupt          (interrupt      ),
    .o_timer_interrupt    (timer_interrupt)
);

// logic [`N_INST_ADDR-1:0]  o_ibus_wishbone_addr;
// logic [`N_REG-1:0]        o_ibus_wishbone_data;
// logic                     o_ibus_wishbone_we  ;
// logic [3:0]               o_ibus_wishbone_sel ;
// logic                     o_ibus_wishbone_stb ;
// logic                     o_ibus_wishbone_cyc ;
// logic [`N_REG-1:0]        i_ibus_wishbone_data;
// logic                     i_ibus_wishbone_ack ;
// logic [`N_INST_ADDR-1:0] o_dbus_wishbone_addr ;
// logic [`N_REG-1:0]       o_dbus_wishbone_data ;
// logic                    o_dbus_wishbone_we   ;
// logic [3:0]              o_dbus_wishbone_sel  ;
// logic                    o_dbus_wishbone_stb  ;
// logic                    o_dbus_wishbone_cyc  ;
// logic [`N_REG-1:0]       i_dbus_wishbone_data ;
// logic                    i_dbus_wishbone_ack  ;

assign interrupt = {5'b0,timer_interrupt};  // attach timer_interrupt to interrupt input 


// inst_rom inst_rom_inst (
//     .i_ce    (inst_ren ),
//     .i_addr  (inst_addr),

//     .o_inst  (inst     )
// );

// data_ram data_ram_inst (
//     .i_clk   (i_clk     ),
//     .i_ce    (o_ram_ce  ),
//     .i_data  (o_ram_data),
//     .i_addr  (o_ram_addr),
//     .i_we    (o_ram_we  ),
//     .i_sel   (o_ram_sel ),
//     .o_data  (i_ram_data)
// );

endmodule