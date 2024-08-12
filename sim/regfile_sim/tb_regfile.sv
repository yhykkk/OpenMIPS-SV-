/**************************************
@ filename    : tb_regfile.sv
@ author      : yyrwkk
@ create time : 2024/08/12 23:04:14
@ version     : v1.0.0
**************************************/
module tb_regfile();
`include "defines.svh"

logic                    i_clk    ;
logic                    i_rst_n  ;
logic [`N_REG_ADDR-1:0]  i_waddr  ;
logic [`N_REG-1:0]       i_wdata  ;
logic                    i_wen    ;
logic [`N_REG_ADDR-1:0]  i_raddr_0;
logic                    i_ren_0  ;
logic [`N_REG-1:0]       o_rdata_0;
logic [`N_REG_ADDR-1:0]  i_raddr_1;
logic                    i_ren_1  ;
logic [`N_REG-1:0]       o_rdata_1;

regfile regfile_inst (
    .i_clk     (i_clk     ),
    .i_rst_n   (i_rst_n   ),
    .i_waddr   (i_waddr   ),
    .i_wdata   (i_wdata   ),
    .i_wen     (i_wen     ),
    .i_raddr_0 (i_raddr_0 ),
    .i_ren_0   (i_ren_0   ),
    .o_rdata_0 (o_rdata_0 ),
    .i_raddr_1 (i_raddr_1 ),
    .i_ren_1   (i_ren_1   ),
    .o_rdata_1 (o_rdata_1 ) 
);

initial begin
    i_clk    = 'b0;
    i_rst_n  = `RST_ENABLE;
    i_waddr  = 'b0;
    i_wdata  = 'b0;
    i_wen    = `WRITE_DISABLE;
    i_raddr_0= 'b0;
    i_ren_0  = `READ_DISABLE;
    i_raddr_1= 'b0;
    i_ren_1  = `READ_DISABLE;
end

initial begin
    forever #5 i_clk = ~i_clk;
end

initial begin
    @(posedge i_clk );
    i_rst_n <= `RST_DISABLE;
    @(posedge i_clk );
    for(int i=0;i<32;i++) begin
        i_waddr <= i;
        i_wdata <= i+1;
        i_wen   <= `WRITE_ENABLE;
        @(posedge i_clk);
    end
    i_wen <= `WRITE_DISABLE;

    for( int i=0;i<32;i++ ) begin
        i_raddr_0 <= i;
        i_ren_0   <= `READ_ENABLE;
        i_raddr_1 <= i;
        i_ren_1   <= `READ_ENABLE;
        @(posedge i_clk);
    end 
    i_ren_0   <= `READ_DISABLE;
    i_ren_1   <= `READ_DISABLE;

    @(posedge i_clk);
    i_waddr <= 'd5;
    i_wdata <= 'd666;
    i_wen   <= `WRITE_ENABLE;
    i_raddr_0 <='d5;
    i_ren_0   <= `READ_ENABLE;
    @(posedge i_clk);
    i_wen <= `WRITE_DISABLE;
    i_ren_0   <= `READ_DISABLE;

    repeat(10) @(posedge i_clk);
    $stop;
end


endmodule