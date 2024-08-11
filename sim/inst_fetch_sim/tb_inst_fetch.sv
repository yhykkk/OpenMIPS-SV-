/**************************************
@ filename    : tb_inst_fetch.sv
@ author      : yyrwkk
@ create time : 2024/08/09 23:02:07
@ version     : v1.0.0
**************************************/
module tb_inst_fetch();
parameter NPC  =  6   ;
parameter NINST=  32  ;

logic             i_clk   ;
logic             i_rst_n ;
logic [NINST-1:0] o_inst  ;

inst_fetch #(
    .NPC   (NPC   ),
    .NINST (NINST )
)inst_fetch_inst(
    .i_clk   (i_clk   ),
    .i_rst_n (i_rst_n ),
    .o_inst  (o_inst  )  
);

initial begin
    i_clk   = 'b0;
    i_rst_n = 'b0;
end

initial begin
    forever begin
        #5 i_clk = ~i_clk;
    end
end

initial begin
    @(posedge i_clk);
    i_rst_n <= 1'b1;
    @(posedge i_clk);

    repeat(200) @(posedge i_clk);
    $stop(2);
end


endmodule