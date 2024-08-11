/**************************************
@ filename    : pc_reg.sv
@ author      : yyrwkk
@ create time : 2024/08/09 12:56:39
@ version     : v1.0.0
**************************************/
module pc_reg # (
    parameter NPC  =  6  
)(
    input  logic           i_clk   ,
    input  logic           i_rst_n ,

    output logic [NPC-1:0] o_pc    ,
    output logic           o_ce  
);

always_ff @(posedge i_clk or negedge i_rst_n ) begin
   if(!i_rst_n ) begin
        o_ce <= 1'b0;
   end else begin
        o_ce <= 1'b1;
   end
end

always_ff @(posedge i_clk or negedge i_rst_n ) begin
    if( (!i_rst_n ) || (o_ce ==1'b0) ) begin // when first ce == 1'b1 , the value of pc is 0x00 ( not from zero )
        o_pc <= 'b0;
    end else begin
        o_pc <= o_pc + 1'b1; 
    end
end

endmodule