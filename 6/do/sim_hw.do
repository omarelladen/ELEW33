set NumericStdNoWarnings 1
set StdArithNoWarnings   1

add wave -position insertpoint  \
    sim:/hostsystem_tb/hostsystem_inst/uart/clk \
    sim:/hostsystem_tb/hostsystem_inst/uart/readdata \
    sim:/hostsystem_tb/hostsystem_inst/uart/readyfordata \
    sim:/hostsystem_tb/hostsystem_inst/user_0/writedata \
    sim:/hostsystem_tb/hostsystem_inst/user_0/readdata \
    sim:/hostsystem_tb/hostsystem_inst/user_0/resetn \
    sim:/hostsystem_tb/hostsystem_inst/user_0/s_checksum_sw \
    sim:/hostsystem_tb/hostsystem_inst/user_0/s_checksum_hw

run 10 ms
