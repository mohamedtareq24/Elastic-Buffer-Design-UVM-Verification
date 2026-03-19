# Timing constraints for eb_top on Avnet Ultra96 V2
# Part: xczu3eg-sbva484-1-e (Zynq UltraScale+ MPSoC)
#
# sys_clk_i : System/PCLK  (USB 3.0 PCLK = 250 MHz -> 4.0 ns period)
# cdr_clk_i : CDR recovered clock (250 MHz -> 4.0 ns period)
# The two domains are fully asynchronous to each other.

create_clock -name sys_clk -period 4.000 [get_ports sys_clk_i]
create_clock -name cdr_clk -period 4.000 [get_ports cdr_clk_i]

# Asynchronous CDC: no timing relationship between the two clocks
set_clock_groups -asynchronous \
    -group [get_clocks sys_clk] \
    -group [get_clocks cdr_clk]

# Active-low async reset: exclude from regular data timing analysis
set_false_path -from [get_ports sys_arst_n_i]
