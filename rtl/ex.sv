/**************************************
@ filename    : ex.sv
@ author      : yyrwkk
@ create time : 2024/08/14 17:16:43
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module ex (
    input  logic                    i_rst_n         ,
    input  logic [`N_ALU_SEL-1:0]   i_alu_sel       ,
    input  logic [`N_ALU_OP-1:0]    i_alu_op        ,
    input  logic [`N_REG-1:0]       i_alu_reg_0     ,
    input  logic [`N_REG-1:0]       i_alu_reg_1     ,

    input  logic                    i_alu_reg_wen   ,
    input  logic [`N_REG_ADDR-1:0]  i_alu_reg_waddr ,
    
    output logic                    o_alu_reg_wen   ,
    output logic [`N_REG_ADDR-1:0]  o_alu_reg_waddr ,
    output logic [`N_REG-1:0]       o_alu_reg_wdata ,

    input  logic [`N_REG-1:0]       i_hi            ,
    input  logic [`N_REG-1:0]       i_lo            ,

    input  logic                    i_mem_hilo_wen  ,
    input  logic [`N_REG-1:0]       i_mem_hi        ,
    input  logic [`N_REG-1:0]       i_mem_lo        ,
    input  logic                    i_wb_hilo_wen   ,
    input  logic [`N_REG-1:0]       i_wb_hi         ,
    input  logic [`N_REG-1:0]       i_wb_lo         ,

    output logic                    o_hilo_wen      ,
    output logic [`N_REG-1:0]       o_hi            ,
    output logic [`N_REG-1:0]       o_lo 
);

logic [`N_REG-1:0] logic_out;  // save logic operator result
logic [`N_REG-1:0] shift_out;  // save shift operator result
logic [`N_REG-1:0] move_out ;  // save move  operator result

logic [`N_REG-1:0] hi       ;  // the lastest value of hi
logic [`N_REG-1:0] lo       ;  // the lastest value of lo

// get the lastest value of hi,lo
always_comb begin
    if(i_mem_hilo_wen == `WRITE_ENABLE) begin
        {hi,lo} = {i_mem_hi,i_mem_lo};
    end else if( i_wb_hilo_wen == `WRITE_ENABLE) begin
        {hi,lo} = {i_wb_hi,i_wb_lo};
    end else begin
        {hi,lo} = {i_hi,i_lo};
    end
end                                                                                      
// alu_op -> calc move
always_comb begin
    move_out = 'b0;
    case ( i_alu_op )
    `EXE_MFHI_OP: begin
        move_out = hi;
    end
    `EXE_MFLO_OP: begin
        move_out = lo;
    end
    `EXE_MOVZ_OP: begin
        move_out = i_alu_reg_0;
    end
    `EXE_MOVN_OP: begin
        move_out = i_alu_reg_0;
    end
    default: begin
    end
    endcase
end

// alu_op -> calc logic 
always_comb begin
    case ( i_alu_op ) 
    `EXE_OR_OP: begin
        logic_out = i_alu_reg_0 | i_alu_reg_1;
    end
    `EXE_AND_OP: begin
        logic_out = i_alu_reg_0 & i_alu_reg_1;
    end
    `EXE_NOR_OP: begin
        logic_out = ~(i_alu_reg_0 | i_alu_reg_1);
    end
    `EXE_XOR_OP: begin
        logic_out = i_alu_reg_0 ^ i_alu_reg_1;
    end
    default: begin
        logic_out = 'b0;
    end
    endcase
end

// alu_op -> calc shift
always_comb begin
    if( i_rst_n == `RST_ENABLE) begin
        shift_out = 'b0;
    end else begin
        case( i_alu_op )
        `EXE_SLL_OP: begin
            shift_out = i_alu_reg_1 << i_alu_reg_0[4:0];
        end
        `EXE_SRL_OP: begin
            shift_out = i_alu_reg_1 >> i_alu_reg_0[4:0];
        end
        `EXE_SRA_OP: begin
            shift_out = ( {32{i_alu_reg_1[31]}} << (6'd32-{1'b0,i_alu_reg_0[4:0]})) | (i_alu_reg_1 >> i_alu_reg_0[4:0]);
        end 
        default: begin
            shift_out = 'b0;
        end
        endcase
    end
end

assign o_alu_reg_waddr = i_alu_reg_waddr;
assign o_alu_reg_wen   =  i_alu_reg_wen ;
// alu_sel -> output
always_comb begin
    case(i_alu_sel) 
    `EXE_RES_LOGIC: begin
        o_alu_reg_wdata = logic_out ;
    end
    `EXE_RES_SHIFT: begin
        o_alu_reg_wdata = shift_out ;
    end
    `EXE_RES_MOVE: begin
        o_alu_reg_wdata = move_out;
    end
    default: begin
        o_alu_reg_wdata = 'b0;
    end
    endcase
end

// o_hilo_wen、o_hi、o_lo
always_comb begin
    if( i_alu_op == `EXE_MTHI_OP ) begin
        o_hilo_wen = `WRITE_ENABLE;
        o_hi       = i_alu_reg_0;
        o_lo       = lo;
    end else if( i_alu_op == `EXE_MTLO_OP ) begin
        o_hilo_wen = `WRITE_ENABLE;
        o_hi       = hi;
        o_lo       = i_alu_reg_0;
    end else begin
        o_hilo_wen = `WRITE_DISABLE;
        o_hi       = hi;
        o_lo       = lo;
    end
end

endmodule