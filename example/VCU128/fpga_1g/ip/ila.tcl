create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_0
set_property -dict [list CONFIG.C_PROBE2_WIDTH {16} CONFIG.C_PROBE4_WIDTH {16} CONFIG.C_PROBE5_WIDTH {16} CONFIG.C_PROBE6_WIDTH {5} CONFIG.C_NUM_OF_PROBES {7}] [get_ips ila_0]