# XDC constraints for the Alinx AX7015 board
# part: xc7z015clg485-2

# General configuration
set_property CFGBVS VCCO                               [current_design]
set_property CONFIG_VOLTAGE 3.3                        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]

# 125 MHz clock
set_property PACKAGE_PIN Y14 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 20.000 -name clk [get_ports clk]

# LEDs
set_property PACKAGE_PIN A5 [get_ports {leds_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds_out[0]}]

set_property PACKAGE_PIN A7 [get_ports {leds_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds_out[1]}]

set_property PACKAGE_PIN A6 [get_ports {leds_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds_out[2]}]

set_property PACKAGE_PIN B8 [get_ports {leds_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds_out[3]}]


# Reset button
set_property PACKAGE_PIN AB12 [get_ports reset_n]
set_property IOSTANDARD LVCMOS33 [get_ports reset_n]

set_false_path -from [get_ports {reset_n}]
set_input_delay 0 [get_ports {reset_n}]

# Push buttons
# TODO

# Toggle switches
# TODO

# UART
set_property -dict {LOC T17 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports uart_txd]
set_property -dict {LOC R17 IOSTANDARD LVCMOS33} [get_ports uart_rxd]

set_false_path -to [get_ports {uart_txd}]
set_output_delay 0 [get_ports {uart_txd}]
set_false_path -from [get_ports {uart_rxd}]
set_input_delay 0 [get_ports {uart_rxd}]

# Gigabit Ethernet RGMII PHY
# set_property -dict {LOC V13 IOSTANDARD LVCMOS33} [get_ports phy2_rxck]
# set_property -dict {LOC AB16 IOSTANDARD LVCMOS33} [get_ports {phy2_rxd[0]}]
# set_property -dict {LOC AA15 IOSTANDARD LVCMOS33} [get_ports {phy2_rxd[1]}]
# set_property -dict {LOC AB15 IOSTANDARD LVCMOS33} [get_ports {phy2_rxd[2]}]
# set_property -dict {LOC AB11 IOSTANDARD LVCMOS33} [get_ports {phy2_rxd[3]}]
# set_property -dict {LOC W10 IOSTANDARD LVCMOS33} [get_ports phy2_rxctl]
# set_property -dict {LOC AA14 IOSTANDARD LVCMOS33 SLEW FAST DRIVE 16} [get_ports phy2_txck]
# set_property -dict {LOC Y12 IOSTANDARD LVCMOS33 SLEW FAST DRIVE 16} [get_ports {phy2_txd[0]}]
# set_property -dict {LOC W12 IOSTANDARD LVCMOS33 SLEW FAST DRIVE 16} [get_ports {phy2_txd[1]}]
# set_property -dict {LOC W11 IOSTANDARD LVCMOS33 SLEW FAST DRIVE 16} [get_ports {phy2_txd[2]}]
# set_property -dict {LOC Y11 IOSTANDARD LVCMOS33 SLEW FAST DRIVE 16} [get_ports {phy2_txd[3]}]
# set_property -dict {LOC V10 IOSTANDARD LVCMOS33 SLEW FAST DRIVE 16} [get_ports phy2_txctl]

set_property PACKAGE_PIN B4 [get_ports phy2_rxck]
set_property PACKAGE_PIN B3 [get_ports phy2_rxctl]
set_property PACKAGE_PIN A2 [get_ports {phy2_rxd[0]}]
set_property PACKAGE_PIN A1 [get_ports {phy2_rxd[1]}]
set_property PACKAGE_PIN B2 [get_ports {phy2_rxd[2]}]
set_property PACKAGE_PIN B1 [get_ports {phy2_rxd[3]}]
set_property PACKAGE_PIN D1 [get_ports phy2_txck]
set_property PACKAGE_PIN C1 [get_ports phy2_txctl]
set_property PACKAGE_PIN F2 [get_ports {phy2_txd[0]}]
set_property PACKAGE_PIN F1 [get_ports {phy2_txd[1]}]
set_property PACKAGE_PIN E2 [get_ports {phy2_txd[2]}]
set_property PACKAGE_PIN D2 [get_ports {phy2_txd[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports phy2_rxck]
set_property IOSTANDARD LVCMOS33 [get_ports phy2_rxctl]
set_property IOSTANDARD LVCMOS33 [get_ports {phy2_rxd[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports phy2_txck]
set_property IOSTANDARD LVCMOS33 [get_ports phy2_txctl]
set_property IOSTANDARD LVCMOS33 [get_ports {phy2_txd[*]}]

############################################################
# The following are required to maximise setup/hold        #
############################################################

# Define Tx clock for RGMII port:
# 0° output case
create_generated_clock -name tx_rgmii_clk -source [get_pins clk_mmcm_inst/CLKOUT2] -divide_by 1 [get_ports phy2_txck]
# Phase shifted case
#create_generated_clock -name tx_rgmii_clk -source [get_pins clk_mmcm_inst/CLKOUT1] -divide_by 1 [get_ports phy2_txck]

# set_output_delay 0.75 -max -clock tx_rgmii_clk [get_ports {phy2_txd[*] phy2_txctl}]
# set_output_delay -0.7 -min -clock tx_rgmii_clk [get_ports {phy2_txd[*] phy2_txctl}]
# set_output_delay 0.75 -max -clock tx_rgmii_clk [get_ports {phy2_txd[*] phy2_txctl}] -clock_fall -add_delay 
# set_output_delay -0.7 -min -clock tx_rgmii_clk [get_ports {phy2_txd[*] phy2_txctl}] -clock_fall -add_delay

set_output_delay 3.5 -max -clock tx_rgmii_clk [get_ports {phy2_txd[*] phy2_txctl}]
set_output_delay 0.5 -min -clock tx_rgmii_clk [get_ports {phy2_txd[*] phy2_txctl}]
set_output_delay 3.5 -max -clock tx_rgmii_clk [get_ports {phy2_txd[*] phy2_txctl}] -clock_fall -add_delay 
set_output_delay 0.5 -min -clock tx_rgmii_clk [get_ports {phy2_txd[*] phy2_txctl}] -clock_fall -add_delay 

set_property SLEW FAST [get_ports {phy2_txd[3] phy2_txd[2] phy2_txd[1] phy2_txd[0] phy2_txctl phy2_txck}]

create_clock -period 8.000 -name phy2_rxck [get_ports phy2_rxck]

set_property PACKAGE_PIN B7 [get_ports {phy2_rstn}]
set_property IOSTANDARD LVCMOS33 [get_ports {phy2_rstn}]
set_false_path -to [get_ports {phy2_rstn}]
set_output_delay 0 [get_ports {phy2_rstn}]


set_property PACKAGE_PIN C8 [get_ports phy2_mdc]
set_property PACKAGE_PIN B6 [get_ports phy2_mdio]
set_property IOSTANDARD LVCMOS33 [get_ports phy2_mdc]
set_property IOSTANDARD LVCMOS33 [get_ports phy2_mdio]

#set_false_path -to [get_ports {phy_mdio phy_mdc}]
#set_output_delay 0 [get_ports {phy_mdio phy_mdc}]
#set_false_path -from [get_ports {phy_mdio}]
#set_input_delay 0 [get_ports {phy_mdio}]

# IDELAY on RGMII from PHY chip
set_property IDELAY_VALUE 0 [get_cells {phy_rx_ctl_idelay phy_rxd_idelay_*}]

# Timing
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks clk] -group {phy2_rxck}


# #  Double Data Rate Source Synchronous Outputs 
# #
# #  Source synchronous output interfaces can be constrained either by the max data skew
# #  relative to the generated clock or by the destination device setup/hold requirements.
# #
# #  Max Skew Case:
# #  The skew requirements for FPGA are known from system level analysis.
# #
# # forwarded                __________________________
# # clock       ____________|                          |______________
# #                         |                          |
# #                 bre_skew|are_skew          bfe_skew|afe_skew
# #                 <------>|<------>          <------>|<------>
# #           ______        |        __________        |        ______
# # data      ______XXXXXXXXXXXXXXXXX__________XXXXXXXXXXXXXXXXX______
# #
# # Example of creating generated clock at clock output port
# # create_generated_clock -name <gen_clock_name> -multiply_by 1 -source [get_pins <source_pin>] [get_ports <output_clock_port>]
# # gen_clock_name is the name of forwarded clock here. It should be used below for defining "fwclk".	

# set fwclk       	<clock_name>;	# forwarded clock name (generated using create_generated_clock at output clock port)
# set fwclk_period 	<period_value>;	# forwarded clock period (full-period)
# set bre_skew 		0.000;			# skew requirement before rising edge
# set are_skew 		0.000;			# skew requirement after rising edge
# set bfe_skew 		0.000;			# skew requirement before falling edge
# set afe_skew 		0.000;			# skew requirement after falling edge
# set output_ports 	<output_ports>;	# list of output ports

# # Output Delay Constraints
# set_output_delay -clock $fwclk -max [expr $fwclk_period/2 - $afe_skew] [get_ports $output_ports];
# set_output_delay -clock $fwclk -min $bre_skew                          [get_ports $output_ports];
# set_output_delay -clock $fwclk -max [expr $fwclk_period/2 - $are_skew] [get_ports $output_ports] -clock_fall -add_delay;
# set_output_delay -clock $fwclk -min $bfe_skew                          [get_ports $output_ports] -clock_fall -add_delay;

# # Report Timing Template
# # report_timing -rise_to [get_ports $output_ports] -max_paths 20 -nworst 2 -delay_type min_max -name src_sync_ddr_out_rise -file src_sync_ddr_out_rise.txt;
# # report_timing -fall_to [get_ports $output_ports] -max_paths 20 -nworst 2 -delay_type min_max -name src_sync_ddr_out_fall -file src_sync_ddr_out_fall.txt;
        
      