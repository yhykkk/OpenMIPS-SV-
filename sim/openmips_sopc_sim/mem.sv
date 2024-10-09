/**************************************
@ filename    : mem.sv
@ author      : yyrwkk
@ create time : 2024/08/14 20:21:01
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module mem (
    input  logic                        i_rst_n        ,
    input  logic                        i_wen          ,
    input  logic [`N_REG_ADDR-1:0]      i_waddr        ,
    input  logic [`N_REG-1:0]           i_wdata        ,
    
    output logic                        o_wen          ,
    output logic [`N_REG_ADDR-1:0]      o_waddr        ,
    output logic [`N_REG-1:0]           o_wdata        ,
    
    input  logic                        i_hilo_wen     ,
    input  logic [`N_REG-1:0]           i_hi           ,
    input  logic [`N_REG-1:0]           i_lo           ,
     
    output logic                        o_hilo_wen     ,
    output logic [`N_REG-1:0]           o_hi           ,
    output logic [`N_REG-1:0]           o_lo           ,
    
    input  logic [`N_ALU_OP-1:0]        i_alu_op       ,
    input  logic [`N_MEM_ADDR-1:0]      i_mem_addr     ,
    input  logic [`N_MEM_DATA-1:0]      i_mem_data     ,
    
    output logic [`N_MEM_ADDR-1:0]      o_mem_addr     ,
    output logic [`N_MEM_DATA-1:0]      o_mem_wdata    ,
    output logic                        o_mem_we       ,
    output logic [3:0]                  o_mem_sel      ,
    output logic                        o_mem_ce       ,

    input  logic [`N_MEM_DATA-1:0]      i_mem_rdata    ,

    input  logic                        i_llbit        ,
    input  logic                        i_wb_llbit_wen ,
    input  logic                        i_wb_llbit_data,

    output logic                        o_llbit_wen    ,
    output logic                        o_llbit_data   
);

logic llbit ;   // lastest llbit value
// if wb state to write llbit, wb stage 's value is lastest
// otherwise, llbit 's output is lastest
always_comb begin
    if( i_wb_llbit_wen == `WRITE_ENABLE ) begin
        llbit = i_wb_llbit_data;
    end else begin
        llbit = i_llbit;
    end
end

always_comb begin
    o_wen      = i_wen         ;
    o_waddr    = i_waddr       ;
    o_wdata    = i_wdata       ;
    o_hilo_wen = i_hilo_wen    ;
    o_hi       = i_hi          ;
    o_lo       = i_lo          ;
    o_mem_we   = `WRITE_DISABLE;
    o_mem_addr = 'b0           ;
    o_mem_sel  = 4'b1111       ;
    o_mem_ce   = `CHIP_DISABLE ;
    o_mem_wdata= 'b0           ;
    o_llbit_data= 1'b0         ;
    o_llbit_wen = 1'b0         ;

    case(i_alu_op)
    `EXE_LB_OP :begin 
        o_mem_addr = i_mem_addr;
        o_mem_we   = `WRITE_DISABLE;
        o_mem_ce   = `CHIP_ENABLE;
        case(i_mem_addr[1:0])
        2'b00: begin 
            o_wdata     = {{24{i_mem_rdata[31]}},i_mem_rdata[31:24]};
            o_mem_sel   = 4'b1000;
        end
        2'b01: begin 
            o_wdata     = {{24{i_mem_rdata[23]}},i_mem_rdata[23:16]};
            o_mem_sel   = 4'b0100;
        end
        2'b10: begin 
            o_wdata     = {{24{i_mem_rdata[15]}},i_mem_rdata[15:8]};
            o_mem_sel   = 4'b0010;
        end
        2'b11: begin 
            o_wdata     = {{24{i_mem_rdata[7]}},i_mem_rdata[7:0]};
            o_mem_sel   = 4'b0001;
        end
        endcase
    end  
    `EXE_LBU_OP:begin 
        o_mem_addr = i_mem_addr;
        o_mem_we   = `WRITE_DISABLE;
        o_mem_ce   = `CHIP_ENABLE;
        case(i_mem_addr[1:0])
        2'b00: begin 
            o_wdata     = {{24{1'b0}},i_mem_rdata[31:24]};
            o_mem_sel   = 4'b1000;
        end
        2'b01: begin 
            o_wdata     = {{24{1'b0}},i_mem_rdata[23:16]};
            o_mem_sel   = 4'b0100;
        end
        2'b10: begin 
            o_wdata     = {{24{1'b0}},i_mem_rdata[15:8]};
            o_mem_sel   = 4'b0010;
        end
        2'b11: begin 
            o_wdata     = {{24{1'b0}},i_mem_rdata[7:0]};
            o_mem_sel   = 4'b0001;
        end
        endcase
    end
    `EXE_LH_OP :begin 
        o_mem_addr = i_mem_addr;
        o_mem_we   = `WRITE_DISABLE;
        o_mem_ce   = `CHIP_ENABLE;
        case(i_mem_addr[1:0])
        2'b00: begin 
            o_wdata     = {{16{i_mem_rdata[31]}},i_mem_rdata[31:16]};
            o_mem_sel   = 4'b1100;
        end
        2'b10: begin
            o_wdata     = {{16{i_mem_rdata[15]}},i_mem_rdata[15:0]};
            o_mem_sel   = 4'b0011;
        end
        default: begin
            o_wdata     = 2'b0;
        end
        endcase
    end
    `EXE_LHU_OP:begin 
        o_mem_addr = i_mem_addr;
        o_mem_we   = `WRITE_DISABLE;
        o_mem_ce   = `CHIP_ENABLE;
        case(i_mem_addr[1:0])
        2'b00: begin 
            o_wdata     = {{16{1'b0}},i_mem_rdata[31:16]};
            o_mem_sel   = 4'b1100;
        end
        2'b10: begin
            o_wdata     = {{16{1'b0}},i_mem_rdata[15:0]};
            o_mem_sel   = 4'b0011;
        end
        default: begin
            o_wdata     = 2'b0;
        end
        endcase
    end
    `EXE_LW_OP :begin 
        o_mem_addr = i_mem_addr;
        o_mem_we   = `WRITE_DISABLE;
        o_mem_ce   = `CHIP_ENABLE;
        o_wdata    = i_mem_rdata;
        o_mem_ce   = 4'b1111;
    end
    `EXE_LWL_OP:begin 
        o_mem_addr = {i_mem_addr[31:2],2'b00};
        o_mem_we   = `WRITE_DISABLE;
        o_mem_sel  = 4'b1111;
        o_mem_ce   = `CHIP_ENABLE;
        case( i_mem_addr[1:0] )
        2'b00: begin  
            o_wdata = i_mem_rdata[31:0];
        end
        2'b01: begin  
            o_wdata = {i_mem_rdata[23:0],i_mem_data[7:0]};
        end
        2'b10: begin  
            o_wdata = {i_mem_rdata[15:0],i_mem_data[15:0]};
        end
        2'b11: begin  
            o_wdata = {i_mem_rdata[7:0],i_mem_data[23:0]};
        end
        endcase
    end
    `EXE_LWR_OP:begin 
        o_mem_addr = {i_mem_addr[31:2],2'b00};
        o_mem_we   = `WRITE_DISABLE;
        o_mem_sel  = 4'b1111;
        o_mem_ce   = `CHIP_ENABLE;
        case( i_mem_addr[1:0] )
        2'b00: begin  
            o_wdata = {i_mem_data[31:8],i_mem_rdata[31:24]};
        end
        2'b01: begin  
            o_wdata =  {i_mem_data[31:16],i_mem_rdata[31:16]};
        end
        2'b10: begin  
            o_wdata =  {i_mem_data[31:24],i_mem_rdata[31:8]};
        end
        2'b11: begin  
            o_wdata =  i_mem_rdata;
        end
        endcase
    end
    `EXE_SB_OP :begin 
        o_mem_addr  = i_mem_addr;
        o_mem_we    = `WRITE_ENABLE;
        o_mem_ce    = `CHIP_ENABLE;
        o_mem_wdata = {i_mem_data[7:0],i_mem_data[7:0],i_mem_data[7:0],i_mem_data[7:0]};
        case( i_mem_addr[1:0] )
        2'b00: begin
            o_mem_sel = 4'b1000;
        end
        2'b01: begin
            o_mem_sel = 4'b0100;
        end
        2'b10: begin
            o_mem_sel = 4'b0010;
        end 
        2'b11: begin
            o_mem_sel = 4'b0001;
        end
        endcase
    end
    `EXE_SH_OP :begin 
        o_mem_addr  = i_mem_addr;
        o_mem_we    = `WRITE_ENABLE;
        o_mem_ce    = `CHIP_ENABLE;
        o_mem_wdata = {i_mem_data[15:0],i_mem_data[15:0]};
        case( i_mem_addr[1:0] )
        2'b00: begin
            o_mem_sel = 4'b1100;
        end
        2'b10: begin
            o_mem_sel = 4'b0011;
        end 
        default: begin 
            o_mem_sel = 4'b0;
        end
        endcase
    end
    `EXE_SW_OP :begin 
        o_mem_addr  = i_mem_addr;
        o_mem_we    = `WRITE_ENABLE;
        o_mem_ce    = `CHIP_ENABLE;
        o_mem_wdata = i_mem_data;
        o_mem_sel   = 4'b1111;
    end
    `EXE_SWL_OP:begin 
        o_mem_addr = {i_mem_addr[31:2],2'b0};
        o_mem_we   = `WRITE_ENABLE;
        o_mem_ce   = `CHIP_ENABLE;
        case( i_mem_addr[1:0] )
        2'b00:begin 
            o_mem_sel   = 4'b1111; 
            o_mem_wdata = i_mem_data;
        end
        2'b01:begin 
            o_mem_sel   = 4'b0111; 
            o_mem_wdata = {8'b0,i_mem_data[31:8]};
        end
        2'b10:begin 
            o_mem_sel   = 4'b0011; 
            o_mem_wdata = {16'b0,i_mem_data[31:16]};
        end
        2'b11:begin 
            o_mem_sel   = 4'b0001; 
            o_mem_wdata = {24'b0,i_mem_data[31:24]};
        end
        endcase
    end
    `EXE_SWR_OP:begin 
        o_mem_addr = {i_mem_addr[31:2],2'b0};
        o_mem_we   = `WRITE_ENABLE;
        o_mem_ce   = `CHIP_ENABLE;
        case( i_mem_addr[1:0] )
        2'b00:begin 
            o_mem_sel   = 4'b1000; 
            o_mem_wdata = {i_mem_data[7:0],24'b0};
        end
        2'b01:begin 
            o_mem_sel   = 4'b1100; 
            o_mem_wdata = {i_mem_data[15:0],16'b0};
        end
        2'b10:begin 
            o_mem_sel   = 4'b1110; 
            o_mem_wdata = {i_mem_data[23:0],8'b0};
        end
        2'b11:begin 
            o_mem_sel   = 4'b1111; 
            o_mem_wdata = i_mem_data;
        end
        endcase
    end  
    `EXE_LL_OP: begin
        o_mem_addr = i_mem_addr;
        o_mem_we   = `WRITE_DISABLE;
        o_wdata    = i_mem_rdata;
        o_llbit_wen= `WRITE_ENABLE;
        o_llbit_data=1'b1;
        o_mem_sel  = 4'b1111;
        o_mem_ce   = `CHIP_ENABLE;
    end
    `EXE_SC_OP: begin
        if( llbit == 1'b1 ) begin
            o_llbit_wen = `WRITE_ENABLE;
            o_llbit_data= 1'b0;
            o_mem_addr = i_mem_addr;
            o_mem_we   = `WRITE_ENABLE;
            o_mem_wdata= i_mem_data;
            o_mem_sel  = 4'b1111;
            o_mem_ce   = `CHIP_ENABLE;
            o_wdata    = 'b1;
        end else begin
            o_wdata = 'b0;
        end
    end
    default    :begin 
    end

    endcase
end

endmodule