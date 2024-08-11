/**************************************
@ filename    : rom.sv
@ author      : yyrwkk
@ create time : 2024/08/09 22:26:28
@ version     : v1.0.0
**************************************/
module rom # (
    parameter NPC  =  6   ,
    parameter NINST=  32  
)(
    input  logic             i_ce    ,
    input  logic [NPC-1:0]   i_addr  ,

    output logic [NINST-1:0] o_inst 
);

logic [NINST-1:0] rom [( 32'b1<<NPC )-1:0] ; 

initial begin
    for( int i=0;i<( 32'b1<<NPC );i++) begin
        rom[i] = i+1;
    end
end

always_comb begin 
    if( i_ce == 1'b0 ) begin
        o_inst = 'b0;
    end else begin
        o_inst = rom[i_addr];
    end
end

endmodule