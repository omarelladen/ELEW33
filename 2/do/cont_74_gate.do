vcom -reportprogress 300 -work work C:/exemplo_vhdl/cont_74/cont4.vhd
vcom -reportprogress 300 -work work C:/exemplo_vhdl/cont_74/simulation/modelsim/cont_74.vho
vcom -reportprogress 300 -work work C:/exemplo_vhdl/cont_74/cont_74_tb.vhd

vsim +altera -do cont_74_run_msim_gate_vhdl.do \
             -l msim_transcript \
             -gui -sdftyp \
             /cont_74_tb/uut=C:/exemplo_vhdl/cont_74/simulation/modelsim/cont_74_7_1200mv_85c_vhd_slow.sdo \
             gate_work.cont_74_tb

add wave -position insertpoint \
    sim:/cont_74_tb/s_rst \
    sim:/cont_74_tb/s_clk \
    sim:/cont_74_tb/s_en \
    sim:/cont_74_tb/s_clr \
    sim:/cont_74_tb/s_q \
    sim:/cont_74_tb/s_finished \
    sim:/cont_74_tb/c_period

run 1 ms
