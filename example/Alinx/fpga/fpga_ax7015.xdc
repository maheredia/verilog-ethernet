# XDC constraints for the Alinx AX7015 board
# part: xc7z015clg485-2

# General configuration
set_property CFGBVS VCCO                               [current_design]
set_property CONFIG_VOLTAGE 3.3                        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]

# 125 MHz clock
set_property PACKAGE_PIN Y14 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 8.000 -name clk [get_ports clk]

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

create_clock -period 8.000 -name phy2_rxck [get_ports phy2_rxck]

set_property PACKAGE_PIN B7 [get_ports {phy2_rstn}]
set_property IOSTANDARD LVCMOS33 [get_ports {phy2_rstn}]
set_false_path -to [get_ports {phy2_rstn}]
set_output_delay 0 [get_ports {phy2_rstn}]


#set_property -dict {LOC Y16  IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports phy_mdio]
#set_property -dict {LOC AA16 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports phy_mdc]
# set_property PACKAGE_PIN C8 [get_ports mdio_mdc]
# set_property PACKAGE_PIN B6 [get_ports mdio_mdio_io]
# set_property IOSTANDARD LVCMOS33 [get_ports mdio_mdc]
# set_property IOSTANDARD LVCMOS33 [get_ports mdio_mdio_io]
#set_false_path -to [get_ports {phy_mdio phy_mdc}]
#set_output_delay 0 [get_ports {phy_mdio phy_mdc}]
#set_false_path -from [get_ports {phy_mdio}]
#set_input_delay 0 [get_ports {phy_mdio}]

# IDELAY on RGMII from PHY chip
set_property IDELAY_VALUE 0 [get_cells {phy_rx_ctl_idelay phy_rxd_idelay_*}]