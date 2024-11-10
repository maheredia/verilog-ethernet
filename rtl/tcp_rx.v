


module tcp_rx
#(

)
(
  input             clk                         ,
  input             rst_n                       ,
  //Control:
  input             connection_established      ,
  output            syn_rcvd                    ,
  output            fin_rcvd                    ,
  output            ack_rcvd                    ,
  output            syn_ack_rcvd                ,
  output            fin_ack_rcvd                ,
  //Datapath: TODO
  output [15:0]     rx_tcp_source_port          ,
  output [15:0]     rx_tcp_dest_port            ,
  output [31:0]     rx_tcp_sequence_number      ,
  output [31:0]     rx_tcp_ack_number           ,
  output [3:0]      rx_tcp_data_offset          ,
  output            rx_tcp_urg                  ,
  output            rx_tcp_ack                  ,
  output            rx_tcp_psh                  ,
  output            rx_tcp_rst                  ,
  output            rx_tcp_syn                  ,
  output            rx_tcp_fin                  ,
  output [15:0]     rx_tcp_window               ,
  output [15:0]     rx_tcp_checksum             ,
  output [15:0]     rx_tcp_urgent_pointer       ,
);

endmodule