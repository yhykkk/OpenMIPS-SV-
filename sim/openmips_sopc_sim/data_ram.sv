/**************************************
@ filename    : data_ram.sv
@ author      : yyrwkk
@ create time : 2024/10/05 15:12:16
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module data_ram (
    input  logic                   i_clk   ,
    input  logic                   i_ce    ,
    input  logic [`N_MEM_DATA-1:0] i_data  ,
    input  logic [`N_MEM_ADDR-1:0] i_addr  ,
    input  logic                   i_we    ,
    input  logic [3:0]             i_sel   ,
    output logic [`N_MEM_DATA-1:0] o_data  
);

logic [`N_MEM_DATA-1:0] data_mem [`NUM_DATA_MEM-1:0];

// write opcode, must sequential circuit to save data
always_ff @ (  posedge i_clk ) begin
    if( i_ce == `CHIP_DISABLE ) begin
        //do nothing
    end else if( i_we == `WRITE_ENABLE ) begin
        if( i_sel[3] == 1'b1 ) begin 
            data_mem[{2'b0,i_addr[`N_MEM_ADDR-1:2]}][31-:8] <= i_data[31-:8];
        end 
        if( i_sel[2] == 1'b1 ) begin
            data_mem[{2'b0,i_addr[`N_MEM_ADDR-1:2]}][23-:8] <= i_data[23-:8];
        end
        if( i_sel[1] == 1'b1 ) begin
            data_mem[{2'b0,i_addr[`N_MEM_ADDR-1:2]}][15-:8] <= i_data[15-:8];
        end 
        if( i_sel[0] == 1'b1 ) begin
            data_mem[{2'b0,i_addr[`N_MEM_ADDR-1:2]}][7-:8] <= i_data[7-:8];
        end 
    end else begin
        // do nothing
    end
end

// read opcode, completeness of conditions
always_comb begin
    if( i_ce == `CHIP_DISABLE ) begin
        o_data = 'b0;
    end else if( i_we == `WRITE_DISABLE ) begin
        o_data = data_mem[{2'b0,i_addr[`N_MEM_ADDR-1:2]}];
    end else begin
        o_data = 'b0;
    end
end


endmodule