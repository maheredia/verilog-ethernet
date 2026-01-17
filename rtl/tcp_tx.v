


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

//Header pointer and data mux:
reg  [HDR_PTR_SIZE-1:0]   tcp_hdr_ptr_reg     ;
wire                      tcp_hdr_ptr_done    ;
reg   [AXI_T_BUFSIZE-1:0] tcp_hdr_data        ;

//FSM:
reg   [3:0]  state_reg                    ;
reg   [3:0]  state_next                   ;

//FSM control signals and outputs:
reg                      store_hdr          ;
reg                      tcp_hdr_ena        ;
reg                      tcp_hdr_ptr_rst    ;
reg                      m_ip_hdr_valid_nxt ;
reg                      m_ip_hdr_valid_reg ;
reg                      s_tcp_hdr_ready_nxt;
reg                      s_tcp_hdr_ready_reg;
reg                      s_tcp_payload_axis_tready_next; //used to control input datapath flow
reg                      s_tcp_payload_axis_tready_reg ; //used to control input datapath flow
reg  [HDR_PTR_SIZE-1:0]  tcp_hdr_ptr_nxt    ;
reg  [15:0]              word_count_next    ;
reg  [15:0]              word_count_reg     ;
reg  [63:0]              last_word_data_reg ;
reg  [7:0]               last_word_keep_reg ;
reg                      store_last_word    ;

//Internal datapath (DRIVEN BY FSM):
wire [63:0] m_ip_payload_axis_tdata_int   ;
wire [7:0]  m_ip_payload_axis_tkeep_int   ;
wire        m_ip_payload_axis_tvalid_int  ;
wire        m_ip_payload_axis_tlast_int   ;
wire        m_ip_payload_axis_tuser_int   ;
//Internal tready is a special case:
//  -_int_early is used to control the input datapath flow.
//  -_int_early_reg is used to control the internal datapath flow.
wire        m_ip_payload_axis_tready_int_early;
reg         m_ip_payload_axis_tready_int_reg  ;

//Output datapath registers - these are directly assigned to outputs:
reg [63:0] m_ip_payload_axis_tdata_reg = 64'd0;
reg [7:0]  m_ip_payload_axis_tkeep_reg = 8'd0;
reg        m_ip_payload_axis_tvalid_reg = 1'b0, m_ip_payload_axis_tvalid_next;
reg        m_ip_payload_axis_tlast_reg = 1'b0;
reg        m_ip_payload_axis_tuser_reg = 1'b0;

//TEMP datapath registers: -----> THERE IS NO "TREADY TEMP"
reg [63:0] temp_m_ip_payload_axis_tdata_reg = 64'd0;
reg [7:0]  temp_m_ip_payload_axis_tkeep_reg = 8'd0;
reg        temp_m_ip_payload_axis_tvalid_reg = 1'b0, temp_m_ip_payload_axis_tvalid_next;
reg        temp_m_ip_payload_axis_tlast_reg = 1'b0;
reg        temp_m_ip_payload_axis_tuser_reg = 1'b0;

//Basic datapath flow explanation: TODO: ESTO ES NECESARIO??? SE PODRÍA MEJORAR...
//  --If output side is ready OR both output regs have no valid data THEN:
//    --If output side is ready or there are no output valid data, move internal to output reg.
//    --If output is not ready, store internal to temp.
//  --If

// datapath control
reg store_ip_payload_int_to_output;
reg store_ip_payload_int_to_temp;
reg store_ip_payload_axis_temp_to_output;

//Logic begins--------------------------------------------------------------------------------------------------------------------------

//TCP Slave Outputs:
assign s_tcp_hdr_ready = s_tcp_hdr_ready_reg;

//AXI Stream Slave outputs:
assign s_tcp_payload_axis_tready = s_tcp_payload_axis_tready_reg;

//IP Master outputs
assign m_ip_hdr_valid        = m_ip_hdr_valid_reg       ;
assign m_ip_eth_dest_mac     = m_eth_dest_mac_reg       ;
assign m_ip_eth_src_mac      = m_eth_src_mac_reg        ;
assign m_ip_eth_type         = m_eth_type_reg           ;
assign m_ip_version          = m_ip_version_reg         ;
assign m_ip_ihl              = m_ip_ihl_reg             ;
assign m_ip_dscp             = m_ip_dscp_reg            ;
assign m_ip_ecn              = m_ip_ecn_reg             ;
//assign m_ip_length           = ; TODO
assign m_ip_identification   = m_ip_identification_reg  ;
assign m_ip_flags            = m_ip_flags_reg           ;
assign m_ip_fragment_offset  = m_ip_fragment_offset_reg ;
assign m_ip_ttl              = m_ip_ttl_reg             ;
assign m_ip_protocol         = m_ip_protocol_reg        ;
assign m_ip_header_checksum  = m_ip_header_checksum_reg ;
assign m_ip_source_ip        = m_ip_source_ip_reg       ;
assign m_ip_dest_ip          = m_ip_dest_ip_reg         ;

//AXI Stream Master outputs:
assign m_ip_payload_axis_tdata  = m_ip_payload_axis_tdata_reg  ;
assign m_ip_payload_axis_tkeep  = m_ip_payload_axis_tkeep_reg  ;
assign m_ip_payload_axis_tvalid = m_ip_payload_axis_tvalid_reg ;
assign m_ip_payload_axis_tlast  = m_ip_payload_axis_tlast_reg  ;
assign m_ip_payload_axis_tuser  = m_ip_payload_axis_tuser_reg  ;

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

  if(store_last_word)
  begin
    last_word_data_reg <= m_ip_payload_axis_tdata_int;
    last_word_keep_reg <= m_ip_payload_axis_tkeep_int;
  end
end

//Header pointer:
always @ (posedge clk, posedge tcp_hdr_ptr_rst)
begin
  if(tcp_hdr_ptr_rst)
    tcp_hdr_ptr_reg <= {HDR_PTR_SIZE{1'b0}};
  else if(tcp_hdr_ena == 1'b1 && m_ip_payload_axis_tready == 1'b1)
    tcp_hdr_ptr_reg <= tcp_hdr_ptr_nxt;
end

assign tcp_hdr_ptr_done = (tcp_hdr_ptr_reg >= 16);

//Header data mux:
always @(*)
begin
  case(tcp_hdr_ptr_reg)
    0:
    begin
      tcp_hdr_data[ 7: 0] = s_tcp_source_port[15:8]      ;
      tcp_hdr_data[15: 8] = s_tcp_source_port[7:0]       ;
      tcp_hdr_data[23:16] = s_tcp_dest_port[15:8]        ;
      tcp_hdr_data[31:24] = s_tcp_dest_port[7:0]         ;
      tcp_hdr_data[39:32] = s_tcp_sequence_number[31:24] ;
      tcp_hdr_data[47:40] = s_tcp_sequence_number[23:16] ;
      tcp_hdr_data[55:48] = s_tcp_sequence_number[15:8]  ;
      tcp_hdr_data[63:56] = s_tcp_sequence_number[7:0]   ;
    end

    8:
    begin
      tcp_hdr_data[ 7: 0] = s_tcp_ack_number[31:24]      ;
      tcp_hdr_data[15: 8] = s_tcp_ack_number[23:16]      ;
      tcp_hdr_data[23:16] = s_tcp_ack_number[15:8]       ;
      tcp_hdr_data[31:24] = s_tcp_ack_number[7:0]        ;
      tcp_hdr_data[39:32] = {s_tcp_data_offset, 4'b0000} ;
      tcp_hdr_data[47:40] = {2'b00, s_tcp_urg, s_tcp_ack, s_tcp_psh, s_tcp_rst, s_tcp_syn, s_tcp_fin};
      tcp_hdr_data[55:48] = s_tcp_window[15:8]           ;
      tcp_hdr_data[63:56] = s_tcp_window[7:0]            ;
    end

    default:
    begin
      tcp_hdr_data[ 7: 0] = s_tcp_checksum[15:0]       ;
      tcp_hdr_data[15: 8] = s_tcp_checksum[7:0]        ;
      tcp_hdr_data[23:16] = s_tcp_urgent_pointer[15:8] ;
      tcp_hdr_data[31:24] = s_tcp_urgent_pointer[7:0]  ;
      tcp_hdr_data[39:32] = 8'd0                       ; //No options supported
      tcp_hdr_data[47:40] = 8'd0                       ; //No options supported
      tcp_hdr_data[55:48] = 8'd0                       ; //No options supported
      tcp_hdr_data[63:56] = 8'd0                       ; //No options supported
    end
  endcase
end

//Early TVALID <-- THIS GOVERNS INTERNAL DATAPATH READYNESS:
//Enable ready input next cycle if output is ready or if both output registers are empty TODO: CHECK IF TEMP NEEDED
assign m_ip_payload_axis_tready_int_early = m_ip_payload_axis_tready || (!temp_m_ip_payload_axis_tvalid_reg && !m_ip_payload_axis_tvalid_reg);

//FSM: sequential logic for state and registers
always @ (posedge clk, posedge rst)
begin
  if(rst)
  begin
    state_reg                     <= IDLE;
    m_ip_hdr_valid_reg            <= 1'b0;
    s_tcp_hdr_ready_reg           <= 1'b0;
    s_tcp_payload_axis_tready_reg <= 1'b0;
    word_count_reg                <=    0;
  end
  else
  begin
    state_reg                     <=         state_next             ;
    m_ip_hdr_valid_reg            <= m_ip_hdr_valid_nxt             ;
    s_tcp_hdr_ready_reg           <= s_tcp_hdr_ready_nxt            ;
    s_tcp_payload_axis_tready_reg <= s_tcp_payload_axis_tready_next ;
    word_count_reg                <=                word_count_next ;
  end
end

//FSM: combo logic
always @(*)
begin
  store_hdr                      =                                 1'b0 ;
  tcp_hdr_ptr_rst                =                                 1'b1 ;
  tcp_hdr_ena                    =                                 1'b0 ;
  s_tcp_hdr_ready_nxt            =                                 1'b1 ;
  // s_tcp_hdr_ready_nxt            =                   !m_ip_hdr_valid_nxt;
  m_ip_hdr_valid_nxt             = m_ip_hdr_valid_reg && !m_ip_hdr_ready; //hdr_ready works as an ack for hdr_valid
  s_tcp_payload_axis_tready_next =                                 1'b0 ;
  tcp_hdr_ptr_nxt                =               {(HDR_PTR_SIZE){1'b0}} ;
  word_count_next                =                        word_count_reg;
  store_last_word                =                                 1'b0 ;
  
  m_ip_payload_axis_tdata_int  = 64'd0; // INTERNAL DATAPATH IS DRIVEN BY THIS FSM
  m_ip_payload_axis_tkeep_int  = 8'd0;  // INTERNAL DATAPATH IS DRIVEN BY THIS FSM
  m_ip_payload_axis_tvalid_int = 1'b0;  // INTERNAL DATAPATH IS DRIVEN BY THIS FSM
  m_ip_payload_axis_tlast_int  = 1'b0;  // INTERNAL DATAPATH IS DRIVEN BY THIS FSM
  m_ip_payload_axis_tuser_int  = 1'b0;  // INTERNAL DATAPATH IS DRIVEN BY THIS FSM

  case(state_reg)
    IDLE:
    begin //TCP connection is not yet stablished: cold start.
      if(s_tcp_hdr_valid == 1'b1 && connection_established == 1'b0)
      begin
        state_next = WRITE_HEADER;
        store_hdr = 1'b1;
        m_ip_hdr_valid_nxt = 1'b1;
        s_tcp_hdr_ready_nxt = 1'b0; //Ready will go down until transfer si completed.
        //word_count_next = //TODO: THIS SHOULD BE CALCULATED? GIVEN BY UPPER HIERARCHY?
        // s_tcp_payload_axis_tready_next = m_ip_payload_axis_tready_int_early;
      end
      else
        state_next = IDLE;
    end

    WRITE_HEADER:
    begin
      tcp_hdr_ptr_rst     = 1'b0         ;
      tcp_hdr_ena         = 1'b1         ;
      s_tcp_hdr_ready_nxt = 1'b0         ;
      state_next          = WRITE_HEADER ;

      if(m_ip_payload_axis_tready_int_reg)
      begin
        m_ip_payload_axis_tvalid_int = 1'b1;
        m_ip_payload_axis_tdata_int  = tcp_hdr_data;
        m_ip_payload_axis_tkeep_int  = 8'hff;
        tcp_hdr_ptr_nxt = tcp_hdr_ptr_reg + 4'd8;
        if(tcp_hdr_ptr_done==1'b1)
        begin
          state_next = WRITE_PAYLOAD;
        end
      end
    end

    WRITE_HEADER_LAST:
    begin
      s_tcp_hdr_ready_nxt = 1'b0;

    end

    WRITE_PAYLOAD:
    begin
      s_tcp_payload_axis_tready_next = m_ip_payload_axis_tready_int_early;
      s_tcp_hdr_ready_nxt = 1'b0;
      //tdata, tkeep, tlast and tuser assigned directly from input, but valid driven by logic in this state.
      m_ip_payload_axis_tdata_int = s_tcp_payload_axis_tdata;
      m_ip_payload_axis_tkeep_int = s_tcp_payload_axis_tkeep;
      m_ip_payload_axis_tlast_int = s_tcp_payload_axis_tlast;
      m_ip_payload_axis_tuser_int = s_tcp_payload_axis_tuser;

      store_last_word = 1'b1;

      if (m_ip_payload_axis_tready_int_reg && s_udp_payload_axis_tvalid)
      begin
        word_count_next = word_count_reg - 16'd8;
        m_ip_payload_axis_tvalid_int = 1'b1;
        if(word_count_reg <= 8)
        begin
          // have entire payload
          m_ip_payload_axis_tkeep_int = count2keep(word_count_reg);
          if(s_tcp_payload_axis_tlast) 
          begin
            if(keep2count(s_tcp_payload_axis_tkeep) < word_count_reg[4:0])
            begin
              // end of frame, but length does not match
              error_payload_early_termination_next = 1'b1;
              m_ip_payload_axis_tuser_int = 1'b1;
            end
            s_tcp_payload_axis_tready_next = 1'b0;
            state_next = IDLE;
          end 
          else
          begin
            m_ip_payload_axis_tvalid_int = 1'b0;
            state_next = WRITE_PAYLOAD_LAST;
          end
        end 
        else
        begin
          if(s_tcp_payload_axis_tlast)
          begin
            // end of frame, but length does not match  --> There is UDP data to transmit according to
            // s_udp_length, but the UDP-side AXI-Stream sends a TLAST indication, so this is an error.
            error_payload_early_termination_next = 1'b1;
            m_ip_payload_axis_tuser_int = 1'b1;
            s_tcp_payload_axis_tready_next = 1'b0;
            state_next = IDLE;
          end
          else 
          begin
            state_next = WRITE_PAYLOAD;
          end
        end
      end
      else
      begin
        state_next = WRITE_PAYLOAD;
      end
    end

    WRITE_PAYLOAD_LAST:
    begin
      s_tcp_hdr_ready_nxt = 1'b0;
      // read and discard until end of frame
      s_tcp_payload_axis_tready_next = m_ip_payload_axis_tready_int_early;

      m_ip_payload_axis_tdata_int = last_word_data_reg;
      m_ip_payload_axis_tkeep_int = last_word_keep_reg;
      m_ip_payload_axis_tlast_int = s_tcp_payload_axis_tlast;
      m_ip_payload_axis_tuser_int = s_tcp_payload_axis_tuser;

      if(s_tcp_payload_axis_tready && s_tcp_payload_axis_tvalid)
      begin
        if(s_tcp_payload_axis_tlast)
        begin
          s_tcp_hdr_ready_next = 1'b0;
          s_tcp_payload_axis_tready_next = 1'b0;
          m_ip_payload_axis_tvalid_int = 1'b1;
          state_next = IDLE;
        end 
        else
        begin
          state_next = WRITE_PAYLOAD_LAST;
        end
      end
      else
      begin
        state_next = WRITE_PAYLOAD_LAST;
      end
    end

    READY:
    begin
      s_tcp_hdr_ready_nxt = 1'b1;
      state_next = IDLE;
    end

    default:
    begin
      s_tcp_hdr_ready_nxt = 1'b0;
      state_next = IDLE;
    end
  endcase
end

endmodule