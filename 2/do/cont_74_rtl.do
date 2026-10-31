vcom -reportprogress 300 -work work C:/exemplo_vhdl/cont_74/cont4.vhd
vcom -reportprogress 300 -work work C:/exemplo_vhdl/cont_74/cont_74.vhd
vcom -reportprogress 300 -work work C:/exemplo_vhdl/cont_74/cont_74_tb.vhd

vsim +altera -do cont_74_run_msim_rtl_vhdl.do -l msim_transcript -gui rtl_work.cont_74_tb

add wave -position insertpoint \
    sim:/cont_74_tb/s_rst \
    sim:/cont_74_tb/s_clk \
    sim:/cont_74_tb/s_en \
    sim:/cont_74_tb/s_clr \
    sim:/cont_74_tb/s_q \
    sim:/cont_74_tb/s_finished \
    sim:/cont_74_tb/c_period

run 1 ms
