onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_id/id_inst/i_inst
add wave -noupdate /tb_id/id_inst/i_pc
add wave -noupdate /tb_id/id_inst/i_reg_0_data
add wave -noupdate /tb_id/id_inst/i_reg_1_data
add wave -noupdate /tb_id/id_inst/i_rst_n
add wave -noupdate -radix unsigned /tb_id/id_inst/imm
add wave -noupdate /tb_id/id_inst/o_alu_op
add wave -noupdate /tb_id/id_inst/o_alu_sel
add wave -noupdate /tb_id/id_inst/o_op_reg_0
add wave -noupdate -radix unsigned /tb_id/id_inst/o_op_reg_1
add wave -noupdate /tb_id/id_inst/o_reg_0_addr
add wave -noupdate /tb_id/id_inst/o_reg_0_ren
add wave -noupdate /tb_id/id_inst/o_reg_1_addr
add wave -noupdate /tb_id/id_inst/o_reg_1_ren
add wave -noupdate /tb_id/id_inst/o_reg_waddr
add wave -noupdate -color Magenta /tb_id/id_inst/o_reg_wen
add wave -noupdate /tb_id/id_inst/op
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {31 ns} 0}
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
WaveRestoreZoom {5 ns} {63 ns}
