vcom -reportprogress 300 -work work C:/exemplo_vhdl/bram_fifo/bram.vhd
vcom -reportprogress 300 -work work C:/exemplo_vhdl/bram_fifo/simulation/modelsim/top.vho
vcom -reportprogress 300 -work work C:/exemplo_vhdl/bram_fifo/top_tb.vhd

vsim +altera -do top_run_msim_gate_vhdl.do \
             -l msim_transcript \
             -gui -sdftyp \
             /top_tb/uut=C:/exemplo_vhdl/bram_fifo/simulation/modelsim/top_vhd.sdo \
             gate_work.top_tb

add wave -position insertpoint \
    sim:/top_tb/s_clk \
    sim:/top_tb/s_rst \
    sim:/top_tb/s_finished
add wave -noupdate -radix unsigned /top_tb/s_q_out

run 350 us
