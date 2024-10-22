/**************************************
@ filename    : mem.sv
@ author      : yyrwkk
@ create time : 2024/08/14 20:21:01
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module mem (
    input  logic                        i_wen             ,
    input  logic [`N_REG_ADDR-1:0]      i_waddr           ,
    input  logic [`N_REG-1:0]           i_wdata           ,
      
    output logic                        o_wen             ,
    output logic [`N_REG_ADDR-1:0]      o_waddr           ,
    output logic [`N_REG-1:0]           o_wdata           ,
      
    input  logic                        i_hilo_wen        ,
    input  logic [`N_REG-1:0]           i_hi              ,
    input  logic [`N_REG-1:0]           i_lo              ,
       
    output logic                        o_hilo_wen        ,
    output logic [`N_REG-1:0]           o_hi              ,
    output logic [`N_REG-1:0]           o_lo              ,
      
    input  logic [`N_ALU_OP-1:0]        i_alu_op          ,
    input  logic [`N_MEM_ADDR-1:0]      i_mem_addr        ,
    input  logic [`N_MEM_DATA-1:0]      i_mem_data        ,
      
    output logic [`N_MEM_ADDR-1:0]      o_mem_addr        ,
    output logic [`N_MEM_DATA-1:0]      o_mem_wdata       ,
    output logic                        o_mem_we          ,
    output logic [3:0]                  o_mem_sel         ,
    output logic                        o_mem_ce          ,
 
    input  logic [`N_MEM_DATA-1:0]      i_mem_rdata       ,
  
    input  logic                        i_llbit           ,
    input  logic                        i_wb_llbit_wen    ,
    input  logic                        i_wb_llbit_data   ,
  
    output logic                        o_llbit_wen       ,
    output logic                        o_llbit_data      ,
   
    input  logic                        i_cp0_reg_wen     ,
    input  logic [`CP0_REG_N_ADDR-1:0]  i_cp0_reg_waddr   ,
    input  logic [`N_REG-1:0]           i_cp0_reg_wdata   ,
  
    output logic                        o_cp0_reg_wen     ,
    output logic [`CP0_REG_N_ADDR-1:0]  o_cp0_reg_waddr   , 
    output logic [`N_REG-1:0]           o_cp0_reg_wdata   ,
  
    input  logic [31:0]                 i_except_type     ,
    input  logic [`N_INST_ADDR-1:0]     i_curr_inst_addr  ,
    input  logic                        i_delayslot_vld   ,
 
    input  logic                        i_wb_cp0_reg_wen  ,
    input  logic [`CP0_REG_N_ADDR-1:0]  i_wb_cp0_reg_waddr,
    input  logic [`N_REG-1:0]           i_wb_cp0_reg_wdata,

    input  logic [`N_REG-1:0]           i_cp0_status      ,
    input  logic [`N_REG-1:0]           i_cp0_cause       ,
    input  logic [`N_REG-1:0]           i_cp0_epc         ,
      
    output logic [31:0]                 o_except_type     ,
    output logic [`N_INST_ADDR-1:0]     o_curr_inst_addr  ,
    output logic                        o_delayslot_vld   ,
    
    output logic [`N_REG-1:0]           o_cp0_epc             


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

// lastest cp0 's reg info
reg [`N_REG-1:0] cp0_status;
reg [`N_REG-1:0] cp0_cause ;
reg [`N_REG-1:0] cp0_epc   ;

assign o_delayslot_vld = i_delayslot_vld;
assign o_curr_inst_addr= i_curr_inst_addr;

// get lastest cp0 's reg 
// status
always_comb begin 
    if( (i_wb_cp0_reg_wen == `WRITE_ENABLE) && ( i_wb_cp0_reg_waddr == `CP0_REG_STATUS ) ) begin 
        cp0_status = i_wb_cp0_reg_wdata ;
    end else begin 
        cp0_status = i_cp0_status;
    end
end
// epc
always_comb begin 
    if( (i_wb_cp0_reg_wen == `WRITE_ENABLE) && ( i_wb_cp0_reg_waddr == `CP0_REG_EPC ) ) begin 
        cp0_epc = i_wb_cp0_reg_wdata ;
    end else begin 
        cp0_epc = i_cp0_epc;
    end
end

assign o_cp0_epc = cp0_epc;

// cause
always_comb begin 
    if( (i_wb_cp0_reg_wen == `WRITE_ENABLE) && ( i_wb_cp0_reg_waddr == `CP0_REG_CAUSE ) ) begin 
        cp0_cause[9:8] = i_wb_cp0_reg_wdata[9:8]; // ip[1:0]
        cp0_cause[22] = i_wb_cp0_reg_wdata[22];   // WP
        cp0_cause[23] = i_wb_cp0_reg_wdata[23];   // IV
    end else begin 
        cp0_cause = i_cp0_cause;
    end
end

// give out exception type
always_comb begin 
    o_except_type = 'b0;
    if( i_curr_inst_addr != 'b0 )  begin 
        if( ((cp0_cause[15:8] &  cp0_status[15:8]) != 8'h00  ) && ( cp0_status[1] == 1'b0 ) && (cp0_status[0] == 1'b1 ) ) begin 
            o_except_type = 32'h00_00_00_01; // interrupt
        end else if( i_except_type[8] == 1'b1 ) begin 
            o_except_type = 32'h00_00_00_08; // syscall
        end else if( i_except_type[9] == 1'b1 ) begin 
            o_except_type = 32'h00_00_00_0a; // inst_valid
        end else if( i_except_type[10] == 1'b1 ) begin 
            o_except_type = 32'h00_00_00_0d; // trap
        end else if( i_except_type[11] == 1'b1 ) begin 
            o_except_type = 32'h00_00_00_0c; // ov
        end else if( i_except_type[12] == 1'b1 ) begin 
            o_except_type = 32'h00_00_00_0e; // eret
        end else begin 

        end
    end else begin 

    end
end

logic mem_we ;

always_comb begin
    o_wen      = i_wen         ;
    o_waddr    = i_waddr       ;
    o_wdata    = i_wdata       ;
    o_hilo_wen = i_hilo_wen    ;
    o_hi       = i_hi          ;
    o_lo       = i_lo          ;
    mem_we     = `WRITE_DISABLE;
    o_mem_addr = 'b0           ;
    o_mem_sel  = 4'b1111       ;
    o_mem_ce   = `CHIP_DISABLE ;
    o_mem_wdata= 'b0           ;
    o_llbit_data= 1'b0         ;
    o_llbit_wen = 1'b0         ;

    case(i_alu_op)
    `EXE_LB_OP :begin 
        o_mem_addr = i_mem_addr;
        mem_we     = `WRITE_DISABLE;
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
        mem_we     = `WRITE_DISABLE;
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
        mem_we     = `WRITE_DISABLE;
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
        mem_we     = `WRITE_DISABLE;
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
        mem_we     = `WRITE_DISABLE;
        o_mem_ce   = `CHIP_ENABLE;
        o_wdata    = i_mem_rdata;
        o_mem_ce   = 4'b1111;
    end
    `EXE_LWL_OP:begin 
        o_mem_addr = {i_mem_addr[31:2],2'b00};
        mem_we     = `WRITE_DISABLE;
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
        mem_we     = `WRITE_DISABLE;
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
        mem_we      = `WRITE_ENABLE;
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
        mem_we      = `WRITE_ENABLE;
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
        mem_we      = `WRITE_ENABLE;
        o_mem_ce    = `CHIP_ENABLE;
        o_mem_wdata = i_mem_data;
        o_mem_sel   = 4'b1111;
    end
    `EXE_SWL_OP:begin 
        o_mem_addr = {i_mem_addr[31:2],2'b0};
        mem_we     = `WRITE_ENABLE;
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
        mem_we     = `WRITE_ENABLE;
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
        mem_we     = `WRITE_DISABLE;
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
            mem_we     = `WRITE_ENABLE;
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

always_comb begin
    o_cp0_reg_wen   = i_cp0_reg_wen  ;
    o_cp0_reg_waddr = i_cp0_reg_waddr;
    o_cp0_reg_wdata = i_cp0_reg_wdata;
end

// if except assert , cancel write to memery
assign o_mem_we = mem_we & ( ~( |o_except_type) );

endmodule