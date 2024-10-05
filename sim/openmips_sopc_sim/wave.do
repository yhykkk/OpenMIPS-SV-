onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group regfile /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/regfile_inst/i_clk
add wave -noupdate -expand -group regfile /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/regfile_inst/i_rst_n
add wave -noupdate -expand -group regfile -radix hexadecimal {/tb_openmips_sopc/openmips_sopc_inst/openmips_inst/regfile_inst/regs[1]}
add wave -noupdate -expand -group regfile -radix binary {/tb_openmips_sopc/openmips_sopc_inst/openmips_inst/regfile_inst/regs[2]}
add wave -noupdate -expand -group regfile {/tb_openmips_sopc/openmips_sopc_inst/openmips_inst/regfile_inst/regs[3]}
add wave -noupdate -expand -group regfile {/tb_openmips_sopc/openmips_sopc_inst/openmips_inst/regfile_inst/regs[4]}
add wave -noupdate -expand -group hilo /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/hilo_reg_reg/o_hi
add wave -noupdate -expand -group hilo /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/hilo_reg_reg/o_lo
add wave -noupdate -expand -group id /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/i_rst_n
add wave -noupdate -expand -group id /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/i_pc
add wave -noupdate -expand -group id -color Magenta -radix binary /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/i_inst
add wave -noupdate -expand -group id /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/i_reg_0_data
add wave -noupdate -expand -group id -radix hexadecimal /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/i_reg_1_data
add wave -noupdate -expand -group id -color Magenta /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/o_reg_0_ren
add wave -noupdate -expand -group id -color Magenta /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/o_reg_0_addr
add wave -noupdate -expand -group id /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/o_reg_1_ren
add wave -noupdate -expand -group id /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/o_reg_1_addr
add wave -noupdate -expand -group id -radix binary /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/o_alu_op
add wave -noupdate -expand -group id /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/o_alu_sel
add wave -noupdate -expand -group id -color Magenta -radix decimal /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/o_op_reg_0
add wave -noupdate -expand -group id /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/o_op_reg_1
add wave -noupdate -expand -group id /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/o_reg_wen
add wave -noupdate -expand -group id /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/o_reg_waddr
add wave -noupdate -expand -group id /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/i_ex_wen
add wave -noupdate -expand -group id /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/i_ex_waddr
add wave -noupdate -expand -group id /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/i_ex_wdata
add wave -noupdate -expand -group id /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/i_mem_wen
add wave -noupdate -expand -group id /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/i_mem_waddr
add wave -noupdate -expand -group id /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/i_mem_wdata
add wave -noupdate -expand -group id /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/id_inst/imm
add wave -noupdate -expand -group ex -radix binary /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/ex_inst/i_alu_op
add wave -noupdate -expand -group ex -radix binary /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/ex_inst/i_alu_sel
add wave -noupdate -expand -group ex -radix decimal /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/ex_inst/i_alu_reg_0
add wave -noupdate -expand -group ex /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/ex_inst/i_alu_reg_1
add wave -noupdate -expand -group ex /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/ex_inst/i_alu_reg_waddr
add wave -noupdate -expand -group ex /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/ex_inst/i_alu_reg_wen
add wave -noupdate -expand -group ex /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/ex_inst/i_rst_n
add wave -noupdate -expand -group ex /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/ex_inst/logic_out
add wave -noupdate -expand -group ex /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/ex_inst/o_alu_reg_waddr
add wave -noupdate -expand -group ex /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/ex_inst/o_alu_reg_wdata
add wave -noupdate -expand -group ex /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/ex_inst/o_alu_reg_wen
add wave -noupdate -expand -group ex /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/ex_inst/o_hi
add wave -noupdate -expand -group ex /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/ex_inst/i_cnt
add wave -noupdate -expand -group ex /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/ex_inst/o_lo
add wave -noupdate -expand -group data_ram /tb_openmips_sopc/openmips_sopc_inst/data_ram_inst/i_clk
add wave -noupdate -expand -group data_ram -color Magenta /tb_openmips_sopc/openmips_sopc_inst/data_ram_inst/i_addr
add wave -noupdate -expand -group data_ram /tb_openmips_sopc/openmips_sopc_inst/data_ram_inst/i_ce
add wave -noupdate -expand -group data_ram -color Magenta /tb_openmips_sopc/openmips_sopc_inst/data_ram_inst/i_data
add wave -noupdate -expand -group data_ram /tb_openmips_sopc/openmips_sopc_inst/data_ram_inst/i_sel
add wave -noupdate -expand -group data_ram /tb_openmips_sopc/openmips_sopc_inst/data_ram_inst/i_we
add wave -noupdate -expand -group data_ram /tb_openmips_sopc/openmips_sopc_inst/data_ram_inst/o_data
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/i_alu_op
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/i_hi
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/i_hilo_wen
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/i_lo
add wave -noupdate -expand -group mem -color Magenta /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/i_mem_addr
add wave -noupdate -expand -group mem -color Magenta /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/i_mem_data
add wave -noupdate -expand -group mem -color Magenta /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/i_mem_rdata
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/i_rst_n
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/i_waddr
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/i_wdata
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/i_wen
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/o_hi
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/o_hilo_wen
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/o_lo
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/o_mem_addr
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/o_mem_ce
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/o_mem_sel
add wave -noupdate -expand -group mem -color Magenta /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/o_mem_wdata
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/o_mem_we
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/o_waddr
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/o_wdata
add wave -noupdate -expand -group mem /tb_openmips_sopc/openmips_sopc_inst/openmips_inst/mem_inst/o_wen
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {343 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {250 ns} {368 ns}
