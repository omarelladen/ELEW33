vcom -reportprogress 300 -work work C:/exemplo_vhdl/cont4/cont4.vhd
vcom -reportprogress 300 -work work C:/exemplo_vhdl/cont4/cont4_tb.vhd

vsim +altera -do cont4_run_msim_rtl_vhdl.do -l msim_transcript -gui rtl_work.cont4_tb

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cont4_tb/s_clk
add wave -noupdate /cont4_tb/s_finished
add wave -noupdate -radix hexadecimal /cont4_tb/s_q
add wave -noupdate /cont4_tb/s_en
add wave -noupdate /cont4_tb/s_clr
add wave -noupdate /cont4_tb/s_rst
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {425250 ps}


run 500 ns
