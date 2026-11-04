set NumericStdNoWarnings 1
set StdArithNoWarnings   1

add wave -position insertpoint  \
    sim:/hostsystem_tb/hostsystem_inst/uart/clk \
    sim:/hostsystem_tb/hostsystem_inst/uart/readdata \
    sim:/hostsystem_tb/hostsystem_inst/uart/readyfordata \
    sim:/hostsystem_tb/hostsystem_inst/user_0/resetn \
    sim:/hostsystem_tb/hostsystem_inst/user_0/chipselect \
    sim:/hostsystem_tb/hostsystem_inst/user_0/read_en \
    sim:/hostsystem_tb/hostsystem_inst/user_0/add \
    sim:/hostsystem_tb/hostsystem_inst/user_0/writedata \
    sim:/hostsystem_tb/hostsystem_inst/user_0/readdata \
    sim:/hostsystem_tb/hostsystem_inst/user_0/s_bram_wren \
    sim:/hostsystem_tb/hostsystem_inst/user_0/s_bram_q \
    sim:/hostsystem_tb/hostsystem_inst/user_0/s_checksum_sw \
    sim:/hostsystem_tb/hostsystem_inst/user_0/s_checksum_hw \
    sim:/hostsystem_tb/hostsystem_inst/user_0/s_match_checksum \
    sim:/hostsystem_tb/hostsystem_inst/user_0/s_sequence_sw

run 10 ms
