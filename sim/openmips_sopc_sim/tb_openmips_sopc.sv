/**************************************
@ filename    : tb_openmips_sopc.sv
@ author      : yyrwkk
@ create time : 2024/08/14 23:09:36
@ version     : v1.0.0
**************************************/
module tb_openmips_sopc();

logic    i_clk   ;
logic    i_rst_n ;
openmips_sopc openmips_sopc_inst (
    .i_clk   (i_clk   ),
    .i_rst_n (i_rst_n )
);

initial begin
    i_clk   = 'b0;
    i_rst_n = 'b0;
end

initial begin
    forever #5 i_clk = ~i_clk;
end

initial begin
    @(posedge i_clk );
    i_rst_n <= 1'b1;

    repeat(200) @(posedge i_clk);
    $stop;
end

endmodule