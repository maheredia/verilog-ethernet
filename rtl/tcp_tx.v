


module tcp_tx
#(

)
(
  input              clk                          ,
  input              rst                          ,
  //Control:
  input              connection_established       ,
  input              syn_send                     ,
  input              ack_send                     ,
  input              fin_send                     ,
  //TCP frame input:
  input  wire        s_tcp_hdr_valid              ,
  output wire        s_tcp_hdr_ready              ,
  input  wire [47:0] s_eth_dest_mac               ,
  input  wire [47:0] s_eth_src_mac                ,
  input  wire [15:0] s_eth_type                   ,
  input  wire [3:0]  s_ip_version                 ,
  input  wire [3:0]  s_ip_ihl                     ,
  input  wire [5:0]  s_ip_dscp                    ,
  input  wire [1:0]  s_ip_ecn                     ,
  input  wire [15:0] s_ip_identification          ,
  input  wire [2:0]  s_ip_flags                   ,
  input  wire [12:0] s_ip_fragment_offset         ,
  input  wire [7:0]  s_ip_ttl                     ,
  input  wire [15:0] s_ip_header_checksum         ,
  input  wire [31:0] s_ip_source_ip               ,
  input  wire [31:0] s_ip_dest_ip                 ,
  input  wire [15:0] s_tcp_source_port            ,
  input  wire [15:0] s_tcp_dest_port              ,
  input  wire [31:0] s_tcp_sequence_number        ,
  input  wire [31:0] s_tcp_ack_number             ,
  input  wire [3:0]  s_tcp_data_offset            ,
  input  wire        s_tcp_urg                    ,
  input  wire        s_tcp_ack                    ,
  input  wire        s_tcp_psh                    ,
  input  wire        s_tcp_rst                    ,
  input  wire        s_tcp_syn                    ,
  input  wire        s_tcp_fin                    ,
  input  wire [15:0] s_tcp_window                 ,
  input  wire [15:0] s_tcp_checksum               ,
  input  wire [15:0] s_tcp_urgent_pointer         ,
  input  wire [63:0] s_tcp_payload_axis_tdata     ,
  input  wire [7:0]  s_tcp_payload_axis_tkeep     ,
  input  wire        s_tcp_payload_axis_tvalid    ,
  output wire        s_tcp_payload_axis_tready    ,
  input  wire        s_tcp_payload_axis_tlast     ,
  input  wire        s_tcp_payload_axis_tuser     ,
  //IP frame output:
  output wire        m_ip_hdr_valid               ,
  input  wire        m_ip_hdr_ready               ,
  output wire [47:0] m_ip_eth_dest_mac            ,
  output wire [47:0] m_ip_eth_src_mac             ,
  output wire [15:0] m_ip_eth_type                ,
  output wire [3:0]  m_ip_version                 ,
  output wire [3:0]  m_ip_ihl                     ,
  output wire [5:0]  m_ip_dscp                    ,
  output wire [1:0]  m_ip_ecn                     ,
  output wire [15:0] m_ip_length                  ,
  output wire [15:0] m_ip_identification          ,
  output wire [2:0]  m_ip_flags                   ,
  output wire [12:0] m_ip_fragment_offset         ,
  output wire [7:0]  m_ip_ttl                     ,
  output wire [7:0]  m_ip_protocol                ,
  output wire [15:0] m_ip_header_checksum         ,
  output wire [31:0] m_ip_source_ip               ,
  output wire [31:0] m_ip_dest_ip                 ,
  output wire [63:0] m_ip_payload_axis_tdata      ,
  output wire [7:0]  m_ip_payload_axis_tkeep      ,
  output wire        m_ip_payload_axis_tvalid     ,
  input  wire        m_ip_payload_axis_tready     ,
  output wire        m_ip_payload_axis_tlast      ,
  output wire        m_ip_payload_axis_tuser       
);

//local parameters:
localparam AXI_T_BUFSIZE       = 64;
localparam TCP_HDR_LENGTH      = 6*32; //This includes options field with 1 8bits option + zero padding
localparam HDR_PTR_SIZE        = 5;

//FSM:
localparam IDLE                 = 4'b0000 ;
localparam WRITE_HEADER         = 4'b0001 ;
localparam WRITE_HEADER_LAST    = 4'b0010 ;
localparam WRITE_PAYLOAD        = 4'b0011 ;
localparam WRITE_PAYLOAD_LAST   = 4'b0011 ;
localparam READY                = 4'b0100 ;


//Internal signals:
//Header registers:
reg   [47:0] m_eth_dest_mac_reg        = 48'd0   ;
reg   [47:0] m_eth_src_mac_reg         = 48'd0   ;
reg   [15:0] m_eth_type_reg            = 16'd0   ;
reg   [3:0]  m_ip_version_reg          =  4'd0   ;
reg   [3:0]  m_ip_ihl_reg              =  4'd0   ;
reg   [5:0]  m_ip_dscp_reg             =  6'd0   ;
reg   [1:0]  m_ip_ecn_reg              =  3'd0   ;
reg   [15:0] m_ip_identification_reg   = 16'd0   ;
reg   [2:0]  m_ip_flags_reg            =  3'd0   ;
reg   [12:0] m_ip_fragment_offset_reg  = 13'd0   ;
reg   [7:0]  m_ip_ttl_reg              =  8'd0   ;
reg   [15:0] m_ip_header_checksum_reg  = 16'd0   ;
reg   [31:0] m_ip_source_ip_reg        = 32'd0   ;
reg   [31:0] m_ip_dest_ip_reg          = 32'd0   ;

//Header pointer:
reg   [HDR_PTR_SIZE-1:0]  hdr_ptr_reg     ;

//Header data mux:
reg   [AXI_T_BUFSIZE-1:0] hdr_data        ;

//FSM:
reg   [3:0]  state_reg                    ;
reg   [3:0]  state_next                   ;

//FSM control signals and outputs:
reg                       store_hdr       ;
reg                       hdr_ena         ;
reg                       hdr_ptr_rst     ;


//Logic begins--------------------------------------------------------------------------------------------------------------------------

//Outputs:     
assign m_ip_eth_dest_mac     = m_eth_dest_mac_reg       ;
assign m_ip_eth_src_mac      = m_eth_src_mac_reg        ;
assign m_ip_eth_type         = m_eth_type_reg           ;
assign m_ip_version          = m_ip_version_reg         ;
assign m_ip_ihl              = m_ip_ihl_reg             ;
assign m_ip_dscp             = m_ip_dscp_reg            ;
assign m_ip_ecn              = m_ip_ecn_reg             ;
//assign m_ip_length           = ;
assign m_ip_identification   = m_ip_identification_reg  ;
assign m_ip_flags            = m_ip_flags_reg           ;
assign m_ip_fragment_offset  = m_ip_fragment_offset_reg ;
assign m_ip_ttl              = m_ip_ttl_reg             ;
assign m_ip_protocol         = m_ip_protocol_reg        ;
assign m_ip_header_checksum  = m_ip_header_checksum_reg ;
assign m_ip_source_ip        = m_ip_source_ip_reg       ;
assign m_ip_dest_ip          = m_ip_dest_ip_reg         ;

//Input header registers:
always @ (posedge clk)
begin
  if(store_hdr)
  begin
    m_eth_dest_mac_reg        <=  s_eth_dest_mac        ;
    m_eth_src_mac_reg         <=  s_eth_src_mac         ;
    m_eth_type_reg            <=  s_eth_type            ;
    m_ip_version_reg          <=  s_ip_version          ;
    m_ip_ihl_reg              <=  s_ip_ihl              ;
    m_ip_dscp_reg             <=  s_ip_dscp             ;
    m_ip_ecn_reg              <=  s_ip_ecn              ;
    m_ip_identification_reg   <=  s_ip_identification   ;
    m_ip_flags_reg            <=  s_ip_flags            ;
    m_ip_fragment_offset_reg  <=  s_ip_fragment_offset  ;
    m_ip_ttl_reg              <=  s_ip_ttl              ;
    m_ip_header_checksum_reg  <=  s_ip_header_checksum  ;
    m_ip_source_ip_reg        <=  s_ip_source_ip        ;
    m_ip_dest_ip_reg          <=  s_ip_dest_ip          ;
  end
end

//Header pointer:
always @ (posedge clk, posedge hdr_ptr_rst)
begin
  if(hdr_ptr_rst)
    hdr_ptr_reg <= {HDR_PTR_SIZE{1'b0}};
  else if(hdr_ena == 1'b1 && m_ip_payload_axis_tready == 1'b1)
    hdr_ptr_reg <= hdr_ptr_reg + 8;
end

//Header data mux:
always @(*)
begin
  case(hdr_ptr_reg)
    0:
    begin
      hdr_data[ 7: 0] = s_tcp_source_port[15:8]      ;
      hdr_data[15: 8] = s_tcp_source_port[7:0]       ;
      hdr_data[23:16] = s_tcp_dest_port[15:8]        ;
      hdr_data[31:24] = s_tcp_dest_port[7:0]         ;
      hdr_data[39:32] = s_tcp_sequence_number[31:24] ;
      hdr_data[47:40] = s_tcp_sequence_number[23:16] ;
      hdr_data[55:48] = s_tcp_sequence_number[15:8]  ;
      hdr_data[63:56] = s_tcp_sequence_number[7:0]   ;
    end

    8:
    begin
      hdr_data[ 7: 0] = s_tcp_ack_number[31:24]      ;
      hdr_data[15: 8] = s_tcp_ack_number[23:16]      ;
      hdr_data[23:16] = s_tcp_ack_number[15:8]       ;
      hdr_data[31:24] = s_tcp_ack_number[7:0]        ;
      hdr_data[39:32] = {s_tcp_data_offset, 4'b0000} ;
      hdr_data[47:40] = {2'b00, s_tcp_urg, s_tcp_ack, s_tcp_psh, s_tcp_rst, s_tcp_syn, s_tcp_fin};
      hdr_data[55:48] = s_tcp_window[15:8]           ;
      hdr_data[63:56] = s_tcp_window[7:0]            ;
    end

    default:
    begin
      hdr_data[ 7: 0] = s_tcp_checksum[15:0]       ;
      hdr_data[15: 8] = s_tcp_checksum[7:0]        ;
      hdr_data[23:16] = s_tcp_urgent_pointer[15:8] ;
      hdr_data[31:24] = s_tcp_urgent_pointer[7:0]  ;
      hdr_data[39:32] = 8'd0                       ; //No options supported
      hdr_data[47:40] = 8'd0                       ; //No options supported
      hdr_data[55:48] = 8'd0                       ; //No options supported
      hdr_data[63:56] = 8'd0                       ; //No options supported
    end
  endcase
end

//FSM: sequential logic
always @ (posedge clk, posedge rst)
begin
  if(rst)
    state_reg <= IDLE;
  else
    state_reg <= state_next;
end

//FSM: combo logic
always @(*)
begin
  store_hdr    =        1'b0 ;
  hdr_ptr_rst  =        1'b1 ;
  hdr_ena      =        1'b0 ;

  case(state_reg)
    IDLE:
    begin
      if(s_tcp_hdr_valid == 1'b1 && connection_established == 1'b0)
      begin
        state_next = WRITE_HEADER;
        store_hdr = 1'b1;
      end
      else
        state_next = IDLE;
    end

    WRITE_HEADER:
    begin
      hdr_ptr_rst = 1'b0;
      hdr_ena     = 1'b1;
      //TODO: TVALID AND NEXT STATE LOGIC...
    end

    WRITE_HEADER_LAST:
    begin

    end

    WRITE_PAYLOAD:
    begin

    end

    WRITE_PAYLOAD_LAST:
    begin

    end

    READY:
    begin

    end

    default:
    begin

    end
  endcase
end

endmodule