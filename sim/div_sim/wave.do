onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_divider/i_clk
add wave -noupdate -radix decimal /tb_divider/i_dividend
add wave -noupdate -radix decimal /tb_divider/i_divisor
add wave -noupdate -color Magenta /tb_divider/i_divstart
add wave -noupdate /tb_divider/i_rst_n
add wave -noupdate /tb_divider/N_DIVIDEND
add wave -noupdate /tb_divider/N_DIVISOR
add wave -noupdate /tb_divider/o_quotient
add wave -noupdate -radix decimal /tb_divider/o_remainder
add wave -noupdate -color Magenta -itemcolor Magenta /tb_divider/o_res_vld
add wave -noupdate -expand -group div_cell_0 /tb_divider/divider_inst/dividend_temp
add wave -noupdate -expand -group div_cell_0 /tb_divider/divider_inst/divisor_temp
add wave -noupdate -expand -group div_cell_0 /tb_divider/divider_inst/i_clk
add wave -noupdate -expand -group div_cell_0 /tb_divider/divider_inst/i_dividend
add wave -noupdate -expand -group div_cell_0 /tb_divider/divider_inst/i_divisor
add wave -noupdate -expand -group div_cell_0 -color Magenta /tb_divider/divider_inst/i_divstart
add wave -noupdate -expand -group div_cell_0 /tb_divider/divider_inst/i_rst_n
add wave -noupdate -expand -group div_cell_0 /tb_divider/divider_inst/N_DIVIDEND
add wave -noupdate -expand -group div_cell_0 /tb_divider/divider_inst/N_DIVISOR
add wave -noupdate -expand -group div_cell_0 /tb_divider/divider_inst/o_quotient
add wave -noupdate -expand -group div_cell_0 -radix decimal /tb_divider/divider_inst/o_remainder
add wave -noupdate -expand -group div_cell_0 /tb_divider/divider_inst/o_res_vld
add wave -noupdate -expand -group div_cell_0 /tb_divider/divider_inst/quotient_temp
add wave -noupdate -expand -group div_cell_0 /tb_divider/divider_inst/rdy_temp
add wave -noupdate -expand -group div_cell_0 -expand /tb_divider/divider_inst/remainder_temp
add wave -noupdate -expand -group div_cell_0 {/tb_divider/divider_inst/div_block[0]/i}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {474 ns} 0}
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
WaveRestoreZoom {447 ns} {517 ns}
