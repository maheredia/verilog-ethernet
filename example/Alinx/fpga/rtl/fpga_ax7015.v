/*

Copyright (c) 2014-2021 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * FPGA top-level module
 */
module fpga (
    /*
     * Clock: 125 MHz
     * Reset: Push button, active low
     */
    input  wire       clk,
    input  wire       reset_n,
    /*
     * GPIO & LEDs
     */
    output wire [3:0] leds_out,
    /*
     * Ethernet: 1000BASE-T RGMII
     */
    output wire [3:0]           phy2_txd,
    output wire                 phy2_txctl,
    output wire                 phy2_txck,
    input  wire [3:0]           phy2_rxd,
    input  wire                 phy2_rxctl,
    input  wire                 phy2_rxck,
    output wire                 phy2_rstn,
    inout  wire                 phy2_mdio,
    output wire                 phy2_mdc,

    /*
     * UART
     */
    input  wire       uart_rxd,
    output wire       uart_txd
);

// Clock and reset

wire clk_ibufg;

// Internal 125 MHz clock
wire clk_mmcm_out;
wire clk_int;
wire rst_int;

wire mmcm_rst = ~reset_n;
wire mmcm_locked;
wire mmcm_clkfb;

IBUFG
clk_ibufg_inst(
    .I(clk),
    .O(clk_ibufg)
);

wire clk90_mmcm_out;
wire clk90_int;

wire clk_200_mmcm_out;
wire clk_200_int;

// MMCM instance
// 50 MHz in, 125 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 800 MHz to 1600 MHz
// M = 10, D = 1 sets Fvco = 1250 MHz (in range)
// Divide by 10 to get output frequency of 125 MHz
// Need two 125 MHz outputs with 90 degree offset
// Also need 200 MHz out for IODELAY
// 1000 / 5 = 200 MHz
MMCME2_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(6.25),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0),
    .CLKOUT1_DIVIDE(10),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT1_PHASE(90.0),
    .CLKOUT2_DIVIDE(10),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT2_PHASE(0),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT3_PHASE(0),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT4_PHASE(0),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT5_PHASE(0),
    .CLKOUT6_DIVIDE(1),
    .CLKOUT6_DUTY_CYCLE(0.5),
    .CLKOUT6_PHASE(0),
    .CLKFBOUT_MULT_F(25),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(20.000),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_ibufg),
    .CLKFBIN(mmcm_clkfb),
    .RST(mmcm_rst),
    .PWRDWN(1'b0),
    .CLKOUT0(clk_200_mmcm_out),
    .CLKOUT0B(),
    .CLKOUT1(clk90_mmcm_out),
    .CLKOUT1B(),
    .CLKOUT2(clk_mmcm_out),
    .CLKOUT2B(),
    .CLKOUT3(),
    .CLKOUT3B(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKOUT6(),
    .CLKFBOUT(mmcm_clkfb),
    .CLKFBOUTB(),
    .LOCKED(mmcm_locked)
);

BUFG
clk_bufg_inst (
    .I(clk_mmcm_out),
    .O(clk_int)
);

BUFG
clk90_bufg_inst (
    .I(clk90_mmcm_out),
    .O(clk90_int)
);

BUFG
clk_200_bufg_inst (
    .I(clk_200_mmcm_out),
    .O(clk_200_int)
);

sync_reset #(
    .N(4)
)
sync_reset_inst (
    .clk(clk_int),
    .rst(~mmcm_locked),
    .out(rst_int)
);

// GPIO
// TODO
wire uart_rxd_int;

sync_signal #(
    .WIDTH(1),
    .N(2)
)
sync_signal_inst (
    .clk(clk_int),
    .in({uart_rxd}),
    .out({uart_rxd_int})
);

// IODELAY elements for RGMII interface to PHY
// TODO: WHAT FOR?
wire [3:0] phy_rxd_delay;
wire       phy_rx_ctl_delay;

IDELAYCTRL
idelayctrl_inst
(
    .REFCLK(clk_200_int),
    .RST(rst_int),
    .RDY()
);

IDELAYE2 #(
    .IDELAY_TYPE("FIXED")
)
phy_rxd_idelay_0
(
    .IDATAIN(phy2_rxd[0]),
    .DATAOUT(phy_rxd_delay[0]),
    .DATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .CINVCTRL(1'b0),
    .CNTVALUEIN(5'd0),
    .CNTVALUEOUT(),
    .LD(1'b0),
    .LDPIPEEN(1'b0),
    .REGRST(1'b0)
);

IDELAYE2 #(
    .IDELAY_TYPE("FIXED")
)
phy_rxd_idelay_1
(
    .IDATAIN(phy2_rxd[1]),
    .DATAOUT(phy_rxd_delay[1]),
    .DATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .CINVCTRL(1'b0),
    .CNTVALUEIN(5'd0),
    .CNTVALUEOUT(),
    .LD(1'b0),
    .LDPIPEEN(1'b0),
    .REGRST(1'b0)
);

IDELAYE2 #(
    .IDELAY_TYPE("FIXED")
)
phy_rxd_idelay_2
(
    .IDATAIN(phy2_rxd[2]),
    .DATAOUT(phy_rxd_delay[2]),
    .DATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .CINVCTRL(1'b0),
    .CNTVALUEIN(5'd0),
    .CNTVALUEOUT(),
    .LD(1'b0),
    .LDPIPEEN(1'b0),
    .REGRST(1'b0)
);

IDELAYE2 #(
    .IDELAY_TYPE("FIXED")
)
phy_rxd_idelay_3
(
    .IDATAIN(phy2_rxd[3]),
    .DATAOUT(phy_rxd_delay[3]),
    .DATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .CINVCTRL(1'b0),
    .CNTVALUEIN(5'd0),
    .CNTVALUEOUT(),
    .LD(1'b0),
    .LDPIPEEN(1'b0),
    .REGRST(1'b0)
);

IDELAYE2 #(
    .IDELAY_TYPE("FIXED")
)
phy_rx_ctl_idelay
(
    .IDATAIN(phy2_rxctl),
    .DATAOUT(phy_rx_ctl_delay),
    .DATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .CINVCTRL(1'b0),
    .CNTVALUEIN(5'd0),
    .CNTVALUEOUT(),
    .LD(1'b0),
    .LDPIPEEN(1'b0),
    .REGRST(1'b0)
);

// Core
wire [7:0] leds_int;

fpga_core #(
    .TARGET("XILINX"),
    .USE_CLK90("FALSE")
)
core_inst (
    /*
     * Clock: 125MHz
     * Synchronous reset
     */
    .clk(clk_int),
    .clk90(clk90_int),
    .rst(rst_int),
    /*
     * GPIO & LEDs
     */
    .leds_out(leds_int),
    /*
     * Ethernet: 1000BASE-T RGMII
     */
    .phy_rx_clk(phy2_rxck),
    .phy_rxd(phy_rxd_delay),
    .phy_rx_ctl(phy_rx_ctl_delay),
    .phy_tx_clk(phy2_txck),
    .phy_txd(phy2_txd),
    .phy_tx_ctl(phy2_txctl),
    .phy_reset_n(), //phy reset connected to MMCM lock
    .phy_int_n(1'b1), //phy2 interrupt not routed in Alinx AX7015 board.
    .phy_pme_n(1'b1), //Not used
    /*
     * UART: 115200 bps, 8N1
     */
    .uart_rxd(uart_rxd_int),
    .uart_txd(uart_txd)
);

// Other outputs
assign phy2_rstn = mmcm_locked;
assign leds_out = leds_int[3:0];

// MDIO master

wire mdio_t;
wire mdio_o;
wire [15:0] mdio_data;
wire mdio_data_valid;
wire [4:0] mdio_state;
wire mdio_busy;
mdio_fsm
#(
  .WAIT_CNT(40000000),
  .PHY_ADDR(5'h01)
)
mdio_fsm
(
  .clk (clk_int) ,
  .rst (rst_int) ,
  /*
   * data interface
   */
  .data_out        (mdio_data),
  .data_out_valid  (mdio_data_valid),
  /*
   * MDIO to PHY
   */
  .mdc_o  (phy2_mdc),
  .mdio_i (phy2_mdio),
  .mdio_o (mdio_o),
  .mdio_t (mdio_t),
  /*
   * Status
   */
  .busy      (mdio_busy),
  .state_out (mdio_state)
);

assign phy2_mdio = mdio_t ? 1'bz : mdio_o;

//ILAs

// ila_rx ila_rx_inst
// (
//   .clk(phy2_rxck) ,
//   .probe0(core_inst.eth_mac_inst.rx_error_bad_frame),
//   .probe1(core_inst.eth_mac_inst.rx_error_bad_fcs),
//   .probe2(core_inst.eth_mac_inst.rx_fifo_overflow),
//   .probe3(core_inst.eth_mac_inst.rx_fifo_bad_frame),
//   .probe4(core_inst.eth_mac_inst.rx_fifo_good_frame)
// );

// ila_sys ila_sys_inst
// (
//   .clk(clk_int) ,
//   .probe0(core_inst.eth_mac_inst.rx_axis_tdata),
//   .probe1(core_inst.eth_mac_inst.rx_axis_tvalid),
//   .probe2(core_inst.eth_mac_inst.rx_axis_tready),
//   .probe3(core_inst.eth_mac_inst.rx_axis_tlast),
//   .probe4(core_inst.eth_mac_inst.rx_axis_tuser),
//   .probe5(core_inst.rx_eth_hdr_valid),
//   .probe6(core_inst.rx_eth_hdr_ready),
//   .probe7(core_inst.rx_eth_dest_mac),
//   .probe8(core_inst.rx_eth_src_mac),
//   .probe9(core_inst.rx_eth_type),
//   .probe10(core_inst.eth_mac_inst.tx_axis_tdata),
//   .probe11(core_inst.eth_mac_inst.tx_axis_tvalid),
//   .probe12(core_inst.eth_mac_inst.tx_axis_tready),
//   .probe13(core_inst.eth_mac_inst.tx_axis_tlast),
//   .probe14(core_inst.eth_mac_inst.tx_axis_tuser),
//   .probe15(mdio_state),
//   .probe16(mdio_busy),
//   .probe17(mdio_data),
//   .probe18(mdio_data_valid)
// );

// ila_rgmii_tx ila_rgmii_tx_inst
// (
//   .clk (core_inst.eth_mac_inst.eth_mac_1g_rgmii_inst.rgmii_phy_if_inst.mac_gmii_tx_clk),
//   .probe0(core_inst.eth_mac_inst.eth_mac_1g_rgmii_inst.rgmii_phy_if_inst.mac_gmii_txd),
//   .probe1(core_inst.eth_mac_inst.eth_mac_1g_rgmii_inst.rgmii_phy_if_inst.mac_gmii_tx_en),
//   .probe2(core_inst.eth_mac_inst.eth_mac_1g_rgmii_inst.rgmii_phy_if_inst.mac_gmii_tx_er)
// );

ila_rgmii_rx ila_rgmii_rx_inst
(
  .clk (core_inst.eth_mac_inst.eth_mac_1g_rgmii_inst.rgmii_phy_if_inst.mac_gmii_rx_clk),
  .probe0(core_inst.eth_mac_inst.eth_mac_1g_rgmii_inst.rgmii_phy_if_inst.mac_gmii_rxd),
  .probe1(core_inst.eth_mac_inst.eth_mac_1g_rgmii_inst.rgmii_phy_if_inst.mac_gmii_rx_dv),
  .probe2(core_inst.eth_mac_inst.eth_mac_1g_rgmii_inst.rgmii_phy_if_inst.mac_gmii_rx_er)
);

endmodule

`resetall
