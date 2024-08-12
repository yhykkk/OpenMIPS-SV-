onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_regfile/i_clk
add wave -noupdate /tb_regfile/i_raddr_0
add wave -noupdate /tb_regfile/i_raddr_1
add wave -noupdate -color Magenta /tb_regfile/i_ren_0
add wave -noupdate /tb_regfile/i_ren_1
add wave -noupdate /tb_regfile/i_rst_n
add wave -noupdate -radix unsigned /tb_regfile/i_waddr
add wave -noupdate -radix unsigned /tb_regfile/i_wdata
add wave -noupdate /tb_regfile/i_wen
add wave -noupdate -color Magenta -radix unsigned /tb_regfile/o_rdata_0
add wave -noupdate -color Magenta -radix unsigned /tb_regfile/o_rdata_1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {672 ns} 0}
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
WaveRestoreZoom {591 ns} {699 ns}
