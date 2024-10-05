/**************************************
@ filename    : tb_data_ram.sv
@ author      : yyrwkk
@ create time : 2024/10/05 15:29:55
@ version     : v1.0.0
**************************************/
module tb_data_ram();
`include "defines.svh"

logic                   i_clk   ;
logic                   i_ce    ;
logic [`N_MEM_DATA-1:0] i_data  ;
logic [`N_MEM_ADDR-1:0] i_addr  ;
logic                   i_we    ;
logic [3:0]             i_sel   ;
logic [`N_MEM_DATA-1:0] o_data  ;

data_ram data_ram_inst (
    .i_clk   (i_clk   ),
    .i_ce    (i_ce    ),
    .i_data  (i_data  ),
    .i_addr  (i_addr  ),
    .i_we    (i_we    ),
    .i_sel   (i_sel   ),
    .o_data  (o_data  ) 
);

initial begin
    i_clk  = 'b0;
    i_ce   = 'b0;
    i_data = 'b0;
    i_addr = 'b0;
    i_we   = 'b0;
    i_sel  = 'b0;
end 

initial begin
    forever begin
        #5 i_clk = ~i_clk;
    end
end 

initial begin
    @(posedge i_clk);
    i_ce   <= 'b1;
    i_data <= 32'h11_22_33_44;
    i_addr <= 'hff;
    i_we   <= 'b1;
    i_sel  <= 4'b1000;
    @(posedge i_clk);
    i_ce   <= 'b1;
    i_data <= 32'h11_22_33_44;
    i_addr <= 'hff;
    i_we   <= 'b0;
    i_sel  <= 4'b1000;

    @(posedge i_clk);
    i_ce   <= 'b1;
    i_data <= 32'h11_22_33_44;
    i_addr <= 'hff;
    i_we   <= 'b1;
    i_sel  <= 4'b0100;
    @(posedge i_clk);
    i_ce   <= 'b1;
    i_data <= 32'h11_22_33_44;
    i_addr <= 'hff;
    i_we   <= 'b0;
    i_sel  <= 4'b1000;

    @(posedge i_clk);
    i_ce   <= 'b1;
    i_data <= 32'h11_22_33_44;
    i_addr <= 'hff;
    i_we   <= 'b1;
    i_sel  <= 4'b0010;
    @(posedge i_clk);
    i_ce   <= 'b1;
    i_data <= 32'h11_22_33_44;
    i_addr <= 'hff;
    i_we   <= 'b0;
    i_sel  <= 4'b1000;
    
    @(posedge i_clk);
    i_ce   <= 'b1;
    i_data <= 32'h11_22_33_44;
    i_addr <= 'hff;
    i_we   <= 'b1;
    i_sel  <= 4'b0001;
    @(posedge i_clk);
    i_ce   <= 'b1;
    i_data <= 32'h11_22_33_44;
    i_addr <= 'hff;
    i_we   <= 'b0;
    i_sel  <= 4'b1000;

    repeat(10) @(posedge i_clk);
    $stop;

end






endmodule