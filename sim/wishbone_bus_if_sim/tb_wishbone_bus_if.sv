/**************************************
@ filename    : tb_wishbone_bus_if.sv
@ author      : yyrwkk
@ create time : 2024/10/27 22:33:48
@ version     : v1.0.0
**************************************/
module tb_wishbone_bus_if ();

logic                    i_clk           ;
logic                    i_rst_n         ;
logic [5:0]              i_stall         ;
logic                    i_flush         ;
logic                    i_cpu_ce        ;
logic [32-1:0]           i_cpu_data      ;
logic [32-1:0]           i_cpu_addr      ;
logic                    i_cpu_we        ;
logic [3:0]              i_cpu_sel       ;
logic [32-1:0]           o_cpu_data      ;
logic [32-1:0]           o_wishbone_addr ;
logic [32-1:0]           o_wishbone_data ;
logic                    o_wishbone_we   ;
logic [3:0]              o_wishbone_sel  ;
logic                    o_wishbone_stb  ;
logic                    o_wishbone_cyc  ;
logic [32-1:0]           i_wishbone_data ;
logic                    i_wishbone_ack  ;
logic                    o_stallreq      ; 

wishbone_bus_if wishbone_bus_if_inst(
    .i_clk           (i_clk           ),
    .i_rst_n         (i_rst_n         ),
    .i_stall         (i_stall         ),
    .i_flush         (i_flush         ),
    .i_cpu_ce        (i_cpu_ce        ),
    .i_cpu_data      (i_cpu_data      ),
    .i_cpu_addr      (i_cpu_addr      ),
    .i_cpu_we        (i_cpu_we        ),
    .i_cpu_sel       (i_cpu_sel       ),
    .o_cpu_data      (o_cpu_data      ),
    .o_wishbone_addr (o_wishbone_addr ),
    .o_wishbone_data (o_wishbone_data ),
    .o_wishbone_we   (o_wishbone_we   ),
    .o_wishbone_sel  (o_wishbone_sel  ),
    .o_wishbone_stb  (o_wishbone_stb  ),
    .o_wishbone_cyc  (o_wishbone_cyc  ),
    .i_wishbone_data (i_wishbone_data ),
    .i_wishbone_ack  (i_wishbone_ack  ),
    .o_stallreq      (o_stallreq      )
);

initial begin 
    i_clk           = 'b0;     
    i_rst_n         = 'b0;           
    i_stall         = 'b1;        
    i_flush         = 'b0;      
    i_cpu_ce        = 'b0;     
    i_cpu_data      = 'b0;
    i_cpu_addr      = 'b0;
    i_cpu_we        = 'b0;      
    i_cpu_sel       = 'b0;  
    i_wishbone_data = 'b0;
    i_wishbone_ack  = 'b0;
end

initial begin 
    forever #5 i_clk = ~i_clk;
end 

initial begin 
    @(posedge i_clk);
    i_rst_n <= 1'b1;
    @(posedge i_clk);
    i_cpu_ce   <= 1'b1;  
    i_cpu_data <= 32'hff;
    i_cpu_addr <= 32'hee;
    i_cpu_we   <= 1'b0;  
    i_cpu_sel  <= 4'hf;
    @(posedge i_clk);
    i_cpu_ce   <= 'b0;
    i_cpu_data <= 'b0;
    i_cpu_addr <= 'b0;
    i_cpu_we   <= 'b0;
    i_cpu_sel  <= 'b0;


    repeat(10) @(posedge i_clk);
    i_stall <= 'b0;

    repeat(100) @(posedge i_clk);
    $stop;
end


initial begin 
    forever begin 
        @(posedge i_clk);
        if( o_wishbone_cyc && o_wishbone_stb ) begin 
            if( i_wishbone_ack == 1'b0 && o_wishbone_we==1'b0 ) begin 
                i_wishbone_data <= o_wishbone_addr;
                i_wishbone_ack  <= 1'b1;
            end else if( i_wishbone_ack == 1'b1 ) begin 
                i_wishbone_data <= 'b0 ;
                i_wishbone_ack  <= 1'b0;
            end
        end else begin 
            i_wishbone_data <= 'b0 ;
            i_wishbone_ack  <= 1'b0;
        end
    end
end
  
endmodule