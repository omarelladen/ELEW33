set NumericStdNoWarnings 1
set StdArithNoWarnings   1

add wave -position insertpoint  \
    sim:/hostsystem_tb/hostsystem_inst/uart/clk \
    sim:/hostsystem_tb/hostsystem_inst/uart/readdata \
    sim:/hostsystem_tb/hostsystem_inst/uart/readyfordata

run 1 ms
