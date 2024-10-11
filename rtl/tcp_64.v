// Language: Verilog 2001

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * TCP block, IP interface (64 bit datapath)
 */
module tcp_64 #
(
    parameter DEFAULT_2MSL_TIMER = 16'h1000,
    parameter CHECKSUM_GEN_ENABLE = 1,
    parameter CHECKSUM_PAYLOAD_FIFO_DEPTH = 2048,
    parameter CHECKSUM_HEADER_FIFO_DEPTH = 8
)
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * IP frame input
     */
    input  wire        s_ip_hdr_valid,
    output wire        s_ip_hdr_ready,
    input  wire [47:0] s_ip_eth_dest_mac,
    input  wire [47:0] s_ip_eth_src_mac,
    input  wire [15:0] s_ip_eth_type,
    input  wire [3:0]  s_ip_version,
    input  wire [3:0]  s_ip_ihl,
    input  wire [5:0]  s_ip_dscp,
    input  wire [1:0]  s_ip_ecn,
    input  wire [15:0] s_ip_length,
    input  wire [15:0] s_ip_identification,
    input  wire [2:0]  s_ip_flags,
    input  wire [12:0] s_ip_fragment_offset,
    input  wire [7:0]  s_ip_ttl,
    input  wire [7:0]  s_ip_protocol,
    input  wire [15:0] s_ip_header_checksum,
    input  wire [31:0] s_ip_source_ip,
    input  wire [31:0] s_ip_dest_ip,
    input  wire [63:0] s_ip_payload_axis_tdata,
    input  wire [7:0]  s_ip_payload_axis_tkeep,
    input  wire        s_ip_payload_axis_tvalid,
    output wire        s_ip_payload_axis_tready,
    input  wire        s_ip_payload_axis_tlast,
    input  wire        s_ip_payload_axis_tuser,
    
    /*
     * IP frame output
     */
    output wire        m_ip_hdr_valid,
    input  wire        m_ip_hdr_ready,
    output wire [47:0] m_ip_eth_dest_mac,
    output wire [47:0] m_ip_eth_src_mac,
    output wire [15:0] m_ip_eth_type,
    output wire [3:0]  m_ip_version,
    output wire [3:0]  m_ip_ihl,
    output wire [5:0]  m_ip_dscp,
    output wire [1:0]  m_ip_ecn,
    output wire [15:0] m_ip_length,
    output wire [15:0] m_ip_identification,
    output wire [2:0]  m_ip_flags,
    output wire [12:0] m_ip_fragment_offset,
    output wire [7:0]  m_ip_ttl,
    output wire [7:0]  m_ip_protocol,
    output wire [15:0] m_ip_header_checksum,
    output wire [31:0] m_ip_source_ip,
    output wire [31:0] m_ip_dest_ip,
    output wire [63:0] m_ip_payload_axis_tdata,
    output wire [7:0]  m_ip_payload_axis_tkeep,
    output wire        m_ip_payload_axis_tvalid,
    input  wire        m_ip_payload_axis_tready,
    output wire        m_ip_payload_axis_tlast,
    output wire        m_ip_payload_axis_tuser,
    
    /*
     * TCP frame input
     */
    input  wire        s_tcp_hdr_valid,
    output wire        s_tcp_hdr_ready,
    input  wire [47:0] s_tcp_eth_dest_mac,
    input  wire [47:0] s_tcp_eth_src_mac,
    input  wire [15:0] s_tcp_eth_type,
    input  wire [3:0]  s_tcp_ip_version,
    input  wire [3:0]  s_tcp_ip_ihl,
    input  wire [5:0]  s_tcp_ip_dscp,
    input  wire [1:0]  s_tcp_ip_ecn,
    input  wire [15:0] s_tcp_ip_identification,
    input  wire [2:0]  s_tcp_ip_flags,
    input  wire [12:0] s_tcp_ip_fragment_offset,
    input  wire [7:0]  s_tcp_ip_ttl,
    input  wire [15:0] s_tcp_ip_header_checksum,
    input  wire [31:0] s_tcp_ip_source_ip,
    input  wire [31:0] s_tcp_ip_dest_ip,
    input  wire [15:0] s_tcp_source_port,
    input  wire [15:0] s_tcp_dest_port,
    input  wire [31:0] s_tcp_sequence_number,
    input  wire [31:0] s_tcp_ack_number,
    input  wire [3:0]  s_tcp_data_offset,
    input  wire        s_tcp_urg,
    input  wire        s_tcp_ack,
    input  wire        s_tcp_psh,
    input  wire        s_tcp_rst,
    input  wire        s_tcp_syn,
    input  wire        s_tcp_fin,
    input  wire [15:0] s_tcp_window,
    input  wire [15:0] s_tcp_checksum,
    input  wire [15:0] s_tcp_urgent_pointer,
    input  wire [63:0] s_tcp_payload_axis_tdata,
    input  wire [7:0]  s_tcp_payload_axis_tkeep,
    input  wire        s_tcp_payload_axis_tvalid,
    output wire        s_tcp_payload_axis_tready,
    input  wire        s_tcp_payload_axis_tlast,
    input  wire        s_tcp_payload_axis_tuser,
    
    /*
     * TCP frame output
     */
    output wire        m_tcp_hdr_valid,
    input  wire        m_tcp_hdr_ready,
    output wire [47:0] m_tcp_eth_dest_mac,
    output wire [47:0] m_tcp_eth_src_mac,
    output wire [15:0] m_tcp_eth_type,
    output wire [3:0]  m_tcp_ip_version,
    output wire [3:0]  m_tcp_ip_ihl,
    output wire [5:0]  m_tcp_ip_dscp,
    output wire [1:0]  m_tcp_ip_ecn,
    output wire [15:0] m_tcp_ip_length,
    output wire [15:0] m_tcp_ip_identification,
    output wire [2:0]  m_tcp_ip_flags,
    output wire [12:0] m_tcp_ip_fragment_offset,
    output wire [7:0]  m_tcp_ip_ttl,
    output wire [7:0]  m_tcp_ip_protocol,
    output wire [15:0] m_tcp_ip_header_checksum,
    output wire [31:0] m_tcp_ip_source_ip,
    output wire [31:0] m_tcp_ip_dest_ip,
    output wire [15:0] m_tcp_source_port,
    output wire [15:0] m_tcp_dest_port,
    output wire [31:0] m_tcp_sequence_number,
    output wire [31:0] m_tcp_ack_number,
    output wire [3:0]  m_tcp_data_offset,
    output wire        m_tcp_urg,
    output wire        m_tcp_ack,
    output wire        m_tcp_psh,
    output wire        m_tcp_rst,
    output wire        m_tcp_syn,
    output wire        m_tcp_fin,
    output wire [15:0] m_tcp_window,
    output wire [15:0] m_tcp_checksum,
    output wire [15:0] m_tcp_urgent_pointer,
    output wire [63:0] m_tcp_payload_axis_tdata,
    output wire [7:0]  m_tcp_payload_axis_tkeep,
    output wire        m_tcp_payload_axis_tvalid,
    input  wire        m_tcp_payload_axis_tready,
    output wire        m_tcp_payload_axis_tlast,
    output wire        m_tcp_payload_axis_tuser,
    
    /*
     * Status signals
     */
    output wire        rx_busy,
    output wire        tx_busy,
    output wire        rx_error_header_early_termination,
    output wire        rx_error_payload_early_termination,
    output wire        tx_error_payload_early_termination
);

//Local parameters:

//Internal signals:

//Tx:
tcp_tx
#(

)
tcp_tx_inst
(

);

//Rx:

//Control:
tcp_control
#(
  .DEFAULT_2MSL_TIMER (DEFAULT_2MSL_TIMER)
)
tcp_control_inst
(
  .clk              ()  , // input
  .rst_n            ()  , // input
  //Register bank:
  .timeout_2msl_in  (), // input  [15:0]
  .state_out        (), // output [4:0] 
  .active_open      (), // input        
  .active_close     (), // input        
  //Packet builder:
  .syn_send         (), // output
  .syn_rcvd         (), // input 
  .fin_send         (), // output
  .fin_rcvd         (), // input 
  .ack_send         (), // output
  .ack_rcvd         (), // input 
  .syn_ack_rcvd     (), // input 
  .fin_ack_rcvd     ()  // input 
  //other inputs and outputs from reg bank...
);

endmodule

`resetall
