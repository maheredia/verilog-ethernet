# General configurations
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 63.8 [current_design]
set_property BITSTREAM.CONFIG.SPI_OPCODE 8'h6B [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pulldown [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]

# CLK_100
set_property PACKAGE_PIN BH51 [get_ports {CLKREF_P}]
set_property IOSTANDARD DIFF_SSTL12 [get_ports {CLKREF_P}]
set_property PACKAGE_PIN BJ51 [get_ports {CLKREF_N}]
set_property IOSTANDARD DIFF_SSTL12 [get_ports {CLKREF_N}]

create_clock -period 10.000 -name clk_100mhz [get_ports CLKREF_P]
create_generated_clock -name clk_125mhz [get_pins clk_mmcm_inst/CLKOUT0] 

# LEDs
set_property PACKAGE_PIN BH24     [get_ports {led[0]}] ;# Bank  67 VCCO - VCC1V8   - IO_L18N_T2U_N11_AD2N_67
set_property IOSTANDARD  LVCMOS18 [get_ports {led[0]}] ;# Bank  67 VCCO - VCC1V8   - IO_L18N_T2U_N11_AD2N_67
set_property PACKAGE_PIN BG24     [get_ports {led[1]}] ;# Bank  67 VCCO - VCC1V8   - IO_L18P_T2U_N10_AD2P_67
set_property IOSTANDARD  LVCMOS18 [get_ports {led[1]}] ;# Bank  67 VCCO - VCC1V8   - IO_L18P_T2U_N10_AD2P_67
set_property PACKAGE_PIN BG25     [get_ports {led[2]}] ;# Bank  67 VCCO - VCC1V8   - IO_L17N_T2U_N9_AD10N_67
set_property IOSTANDARD  LVCMOS18 [get_ports {led[2]}] ;# Bank  67 VCCO - VCC1V8   - IO_L17N_T2U_N9_AD10N_67
set_property PACKAGE_PIN BF25     [get_ports {led[3]}] ;# Bank  67 VCCO - VCC1V8   - IO_L17P_T2U_N8_AD10P_67
set_property IOSTANDARD  LVCMOS18 [get_ports {led[3]}] ;# Bank  67 VCCO - VCC1V8   - IO_L17P_T2U_N8_AD10P_67
set_property PACKAGE_PIN BF26     [get_ports {led[4]}] ;# Bank  67 VCCO - VCC1V8   - IO_L16N_T2U_N7_QBC_AD3N_67
set_property IOSTANDARD  LVCMOS18 [get_ports {led[4]}] ;# Bank  67 VCCO - VCC1V8   - IO_L16N_T2U_N7_QBC_AD3N_67
set_property PACKAGE_PIN BF27     [get_ports {led[5]}] ;# Bank  67 VCCO - VCC1V8   - IO_L16P_T2U_N6_QBC_AD3P_67
set_property IOSTANDARD  LVCMOS18 [get_ports {led[5]}] ;# Bank  67 VCCO - VCC1V8   - IO_L16P_T2U_N6_QBC_AD3P_67
set_property PACKAGE_PIN BG27     [get_ports {led[6]}] ;# Bank  67 VCCO - VCC1V8   - IO_L15N_T2L_N5_AD11N_67
set_property IOSTANDARD  LVCMOS18 [get_ports {led[6]}] ;# Bank  67 VCCO - VCC1V8   - IO_L15N_T2L_N5_AD11N_67
set_property PACKAGE_PIN BG28     [get_ports {led[7]}] ;# Bank  67 VCCO - VCC1V8   - IO_L15P_T2L_N4_AD11P_67
set_property IOSTANDARD  LVCMOS18 [get_ports {led[7]}] ;# Bank  67 VCCO - VCC1V8   - IO_L15P_T2L_N4_AD11P_67

set_false_path -to [get_ports {led[*]}]
set_output_delay 0 [get_ports {led[*]}]

# UART1
set_property PACKAGE_PIN BK28     [get_ports {uart_rxd}] ;# Bank  67 VCCO - VCC1V8   - IO_L9N_T1L_N5_AD12N_67
set_property IOSTANDARD  LVCMOS18 [get_ports {uart_rxd}] ;# Bank  67 VCCO - VCC1V8   - IO_L9N_T1L_N5_AD12N_67
set_property PACKAGE_PIN BJ28     [get_ports {uart_txd}] ;# Bank  67 VCCO - VCC1V8   - IO_L9P_T1L_N4_AD12P_67
set_property IOSTANDARD  LVCMOS18 [get_ports {uart_txd}] ;# Bank  67 VCCO - VCC1V8   - IO_L9P_T1L_N4_AD12P_67
set_property PACKAGE_PIN BL26     [get_ports {uart_rts}] ;# Bank  67 VCCO - VCC1V8   - IO_L8N_T1L_N3_AD5N_67
set_property IOSTANDARD  LVCMOS18 [get_ports {uart_rts}] ;# Bank  67 VCCO - VCC1V8   - IO_L8N_T1L_N3_AD5N_67
set_property PACKAGE_PIN BL27     [get_ports {uart_cts}] ;# Bank  67 VCCO - VCC1V8   - IO_L8P_T1L_N2_AD5P_67
set_property IOSTANDARD  LVCMOS18 [get_ports {uart_cts}] ;# Bank  67 VCCO - VCC1V8   - IO_L8P_T1L_N2_AD5P_67

set_false_path -to [get_ports {uart_txd uart_rts}]
set_output_delay 0 [get_ports {uart_txd uart_rts}]
set_false_path -from [get_ports {uart_rxd uart_cts}]
set_input_delay 0 [get_ports {uart_rxd uart_cts}]

# Gigabit Ethernet SGMII PHY
set_property PACKAGE_PIN BH22     [get_ports {phy_sgmii_tx_n}] ;# ENET_SGMII_IN_N Bank  67 VCCO - VCC1V8   - IO_L23N_T3U_N9_67
set_property IOSTANDARD  LVDS     [get_ports {phy_sgmii_tx_n}] ;# ENET_SGMII_IN_N Bank  67 VCCO - VCC1V8   - IO_L23N_T3U_N9_67
set_property PACKAGE_PIN BG22     [get_ports {phy_sgmii_tx_p}] ;# ENET_SGMII_IN_P Bank  67 VCCO - VCC1V8   - IO_L23P_T3U_N8_67
set_property IOSTANDARD  LVDS     [get_ports {phy_sgmii_tx_p}] ;# ENET_SGMII_IN_P Bank  67 VCCO - VCC1V8   - IO_L23P_T3U_N8_67
set_property PACKAGE_PIN BK21     [get_ports {phy_sgmii_rx_n}] ;# ENET_SGMII_OUT_N Bank  67 VCCO - VCC1V8   - IO_L21N_T3L_N5_AD8N_67
set_property IOSTANDARD  LVDS     [get_ports {phy_sgmii_rx_n}] ;# ENET_SGMII_OUT_N Bank  67 VCCO - VCC1V8   - IO_L21N_T3L_N5_AD8N_67
set_property PACKAGE_PIN BJ22     [get_ports {phy_sgmii_rx_p}] ;# ENET_SGMII_OUT_P Bank  67 VCCO - VCC1V8   - IO_L21P_T3L_N4_AD8P_67
set_property IOSTANDARD  LVDS     [get_ports {phy_sgmii_rx_p}] ;# ENET_SGMII_OUT_P Bank  67 VCCO - VCC1V8   - IO_L21P_T3L_N4_AD8P_67
set_property PACKAGE_PIN BJ27     [get_ports {phy_sgmii_clk_n}] ;# ENET_SGMII_CLK_N Bank  67 VCCO - VCC1V8   - IO_L12N_T1U_N11_GC_67
set_property IOSTANDARD  LVDS     [get_ports {phy_sgmii_clk_n}] ;# ENET_SGMII_CLK_N Bank  67 VCCO - VCC1V8   - IO_L12N_T1U_N11_GC_67
set_property PACKAGE_PIN BH27     [get_ports {phy_sgmii_clk_p}] ;# ENET_SGMII_CLK_P Bank  67 VCCO - VCC1V8   - IO_L12P_T1U_N10_GC_67
set_property IOSTANDARD  LVDS     [get_ports {phy_sgmii_clk_p}] ;# ENET_SGMII_CLK_P Bank  67 VCCO - VCC1V8   - IO_L12P_T1U_N10_GC_67
set_property PACKAGE_PIN BF22     [get_ports {phy_int_n}] ;# ENET_PDWN_B_I_INT_B_O Bank  67 VCCO - VCC1V8   - IO_L24P_T3U_N10_67
set_property IOSTANDARD  LVCMOS18 [get_ports {phy_int_n}] ;# ENET_PDWN_B_I_INT_B_O Bank  67 VCCO - VCC1V8   - IO_L24P_T3U_N10_67
set_property PACKAGE_PIN BG23     [get_ports {phy_mdio}] ;# ENET_MDIO Bank  67 VCCO - VCC1V8   - IO_T3U_N12_67
set_property IOSTANDARD  LVCMOS18 [get_ports {phy_mdio}] ;# ENET_MDIO Bank  67 VCCO - VCC1V8   - IO_T3U_N12_67
set_property PACKAGE_PIN BN27     [get_ports {phy_mdc}] ;# ENET_MDC Bank  67 VCCO - VCC1V8   - IO_T1U_N12_67
set_property IOSTANDARD  LVCMOS18 [get_ports {phy_mdc}] ;# ENET_MDC Bank  67 VCCO - VCC1V8   - IO_T1U_N12_67
set_property PACKAGE_PIN BL23     [get_ports dummy_port_in] ;# Bank  67 VCCO - VCC1V8   - IO_L19P_T3L_N0_DBC_AD9P_67
set_property IOSTANDARD  LVCMOS18 [get_ports dummy_port_in] ;# Bank  67 VCCO - VCC1V8   - IO_L19P_T3L_N0_DBC_AD9P_67
#set_property PACKAGE_PIN BJ23     [get_ports "ENET_CLKOUT"] ;# Bank  67 VCCO - VCC1V8   - IO_L14N_T2L_N3_GC_67
#set_property IOSTANDARD  LVCMOS18 [get_ports "ENET_CLKOUT"] ;# Bank  67 VCCO - VCC1V8   - IO_L14N_T2L_N3_GC_67
#set_property PACKAGE_PIN BP27     [get_ports "ENET_COL_GPIO"] ;# Bank  67 VCCO - VCC1V8   - IO_T0U_N12_VRP_67
#set_property IOSTANDARD  LVCMOS18 [get_ports "ENET_COL_GPIO"] ;# Bank  67 VCCO - VCC1V8   - IO_T0U_N12_VRP_67

set_false_path -to [get_ports {phy_reset_n phy_mdio phy_mdc}]
set_output_delay 0 [get_ports {phy_reset_n phy_mdio phy_mdc}]
set_false_path -from [get_ports {phy_int_n phy_mdio}]
set_input_delay 0 [get_ports {phy_int_n phy_mdio}]

# Reset button
set_property PACKAGE_PIN BM29      [get_ports {reset}] ;# Bank  64 VCCO - DDR4_VDDQ_1V2 - IO_L1N_T0L_N1_DBC_64
set_property IOSTANDARD  LVCMOS12  [get_ports {reset}] ;# Bank  64 VCCO - DDR4_VDDQ_1V2 - IO_L1N_T0L_N1_DBC_64

# UART0
# set_property PACKAGE_PIN BP26     [get_ports "UART0_RXD"] ;# Bank  67 VCCO - VCC1V8   - IO_L2N_T0L_N3_67
# set_property IOSTANDARD  LVCMOS18 [get_ports "UART0_RXD"] ;# Bank  67 VCCO - VCC1V8   - IO_L2N_T0L_N3_67
# set_property PACKAGE_PIN BN26     [get_ports "UART0_TXD"] ;# Bank  67 VCCO - VCC1V8   - IO_L2P_T0L_N2_67
# set_property IOSTANDARD  LVCMOS18 [get_ports "UART0_TXD"] ;# Bank  67 VCCO - VCC1V8   - IO_L2P_T0L_N2_67
# set_property PACKAGE_PIN BP22     [get_ports "UART0_RTS_B"] ;# Bank  67 VCCO - VCC1V8   - IO_L1N_T0L_N1_DBC_67
# set_property IOSTANDARD  LVCMOS18 [get_ports "UART0_RTS_B"] ;# Bank  67 VCCO - VCC1V8   - IO_L1N_T0L_N1_DBC_67
# set_property PACKAGE_PIN BP23     [get_ports "UART0_CTS_B"] ;# Bank  67 VCCO - VCC1V8   - IO_L1P_T0L_N0_DBC_67
# set_property IOSTANDARD  LVCMOS18 [get_ports "UART0_CTS_B"] ;# Bank  67 VCCO - VCC1V8   - IO_L1P_T0L_N0_DBC_67