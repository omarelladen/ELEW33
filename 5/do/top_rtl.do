vcom -reportprogress 300 -work work C:/exemplo_vhdl/bram_fifo/bram.vhd
vcom -reportprogress 300 -work work C:/exemplo_vhdl/bram_fifo/top.vhd
vcom -reportprogress 300 -work work C:/exemplo_vhdl/bram_fifo/top_tb.vhd

vsim +altera -do top_run_msim_rtl_vhdl.do \
             -l msim_transcript \
             -gui \
             rtl_work.top_tb

add wave -noupdate                 /top_tb/s_clk
add wave -noupdate                 /top_tb/s_rst
add wave -noupdate                 /top_tb/s_finished
add wave -noupdate                 /top_tb/uut/s_complete_br1
add wave -noupdate                 /top_tb/uut/s_complete_br2
add wave -noupdate                 /top_tb/uut/s_wren_br1
add wave -noupdate -radix unsigned /top_tb/uut/s_addr_br1
add wave -noupdate -radix unsigned /top_tb/uut/s_data_br1
add wave -noupdate -radix unsigned /top_tb/uut/s_q_br1
add wave -noupdate                 /top_tb/uut/s_wren_br2
add wave -noupdate -radix unsigned /top_tb/uut/s_addr_br2
add wave -noupdate -radix unsigned /top_tb/uut/s_q_fifo
add wave -noupdate -radix unsigned /top_tb/s_q_out
add wave -noupdate                 /top_tb/uut/s_state_wr
add wave -noupdate                 /top_tb/uut/s_state_rd
add wave -noupdate                 /top_tb/uut/s_wrreq
add wave -noupdate                 /top_tb/uut/s_rdreq
add wave -noupdate                 /top_tb/uut/s_empty
add wave -noupdate                 /top_tb/uut/s_almost_empty
add wave -noupdate                 /top_tb/uut/s_almost_full
add wave -noupdate -radix unsigned /top_tb/uut/s_usedw

run 350 us
