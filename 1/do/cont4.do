vcom -reportprogress 300 -work work C:/exemplo_vhdl/cont4/cont4.vhd
vcom -reportprogress 300 -work work C:/exemplo_vhdl/cont4/cont4_tb.vhd

vsim +altera -do cont4_run_msim_rtl_vhdl.do -l msim_transcript -gui rtl_work.cont4_tb

add wave -position insertpoint \
  sim:/cont4_tb/s_clk \
  sim:/cont4_tb/s_finished \
  sim:/cont4_tb/s_q \
  sim:/cont4_tb/s_en \
  sim:/cont4_tb/s_clr \
  sim:/cont4_tb/s_rst

run 500 ns
