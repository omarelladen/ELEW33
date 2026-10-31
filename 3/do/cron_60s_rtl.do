vcom -reportprogress 300 -work work C:/exemplo_vhdl/cron_60s/div_10ms.vhd
vcom -reportprogress 300 -work work C:/exemplo_vhdl/cron_60s/bcd_7seg.vhd
vcom -reportprogress 300 -work work C:/exemplo_vhdl/cron_60s/cont4.vhd
vcom -reportprogress 300 -work work C:/exemplo_vhdl/cron_60s/cron_60s.vhd
vcom -reportprogress 300 -work work C:/exemplo_vhdl/cron_60s/top.vhd
vcom -reportprogress 300 -work work C:/exemplo_vhdl/cron_60s/top_tb.vhd

vsim +altera -do top_run_msim_rtl_vhdl.do \
             -l msim_transcript \
             -gui \
             rtl_work.top_tb

add wave -position insertpoint \
    sim:/top_tb/s_clk \
    sim:/top_tb/uut/s_en_10ms \
    sim:/top_tb/s_finished \
    sim:/top_tb/s_rst \
    sim:/top_tb/uut/s_clr \
    sim:/top_tb/uut/s_ss \
    sim:/top_tb/uut/s_q \
    sim:/top_tb/s_disp_s1 \
    sim:/top_tb/s_disp_s0 \
    sim:/top_tb/s_disp_c1 \
    sim:/top_tb/s_disp_c0 \
    sim:/top_tb/uut/s_en_div

run 1 ms
