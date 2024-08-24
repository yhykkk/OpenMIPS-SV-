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

    input  logic                    i_alu_reg_wen  ,
    input  logic [`N_REG_ADDR-1:0]  i_alu_reg_waddr ,
    
    output logic                    o_alu_reg_wen  ,
    output logic [`N_REG_ADDR-1:0]  o_alu_reg_waddr ,
    output logic [`N_REG-1:0]       o_alu_reg_wdata
);

logic [`N_REG-1:0] logic_out;  // save logic operator result
logic [`N_REG-1:0] shift_out;  // save shift operator result
// alu_op -> calc logic 
always_comb begin
    if( i_rst_n == `RST_ENABLE) begin
        logic_out = 'b0;
    end else begin
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
    default: begin
        o_alu_reg_wdata = 'b0;
    end
    endcase
end

endmodule