


module tcp_control
#(
  parameter         DEFAULT_2MSL_TIMER = 16'h1000
)
(
  input             clk              ,
  input             rst_n            ,
  //Register bank:
  input [15:0]      timeout_2msl_in  ,
  output  [4:0]     state_out        ,
  input             active_open      ,
  input             active_close     ,
  //Packet builder:
  output            syn_send         ,
  input             syn_rcvd         ,
  output            fin_send         ,
  input             fin_rcvd         ,
  output            ack_send         ,
  input             ack_rcvd         ,
  input             syn_ack_rcvd     ,
  input             fin_ack_rcvd      

  //other inputs and outputs from reg bank...
);

//FSM states:
localparam CLOSED       = 5'b00000;
localparam LISTEN       = 5'b00001;
localparam SYN_SEND     = 5'b00010;
localparam SYN_RCVD     = 5'b00011;
localparam ESTAB        = 5'b00100;
localparam FIN_WAIT_1   = 5'b00101;
localparam FIN_WAIT_2   = 5'b00110;
localparam CLOSING      = 5'b00111;
localparam CLOSE_WAIT   = 5'b01000;
localparam LAST_ACK     = 5'b01001;
localparam TIME_WAIT    = 5'b01010;
localparam SEND_DATA    = 5'b01011;
localparam RECEIVE_ACK  = 5'b01100;
localparam RECEIVE_DATA = 5'b01101;
localparam SEND_ACK     = 5'b01110;
localparam ERROR        = 5'b01111;
localparam SEND_ARP_REQ = 5'b10000;
localparam WAIT_ARP_REP = 5'b10001;

//Internal signals:
reg  [4:0]    current_state;
wire [4:0]    next_state   ;

reg           fsm_syn_send ;
reg           fsm_ack_send ;
reg           fsm_fin_send ;
reg           close        ; //TODO define its driver

//2MSL timer:
reg  [15:0]   timer_2msl       ;
wire          timeout_2msl_hit ;
wire [15:0]   timeout_2msl     ;
reg           reset_2msl       ;

//Outputs:
assign state_out = current_state;
assign syn_send  = fsm_syn_send;
assign ack_send  = fsm_ack_send;
assign fin_send  = fsm_fin_send;

//2MSL timer:
always @ (posedge clk, negedge rst_n)
begin
  if(!rst_n)
    timer_2msl <= 16'h0000;
  else if(reset_2msl == 1'b1)
    timeout_2msl <= 16'h0000;
  else if(timer_2msl < timeout_2msl)
    timer_2msl <= timer_2msl + 1'b1;
end

assign timeout_2msl = (timeout_2msl_in == 16'0000) ? (DEFAULT_2MSL_TIMER) : (timeout_2msl_in);
assign timeout_2msl_hit = (timer_2msl >= timeout_2msl);

//Sequential part of FSM:
always @ (posedge clk, negedge rst_n)
begin
  if(!rst_n)
    current_state <= CLOSED;
  else
    current_state <= next_state;
end

//TODO: add timers!
//Combinational part of FSM:
always @ (*)
begin

  fsm_syn_send = 1'b0;
  fsm_ack_send = 1'b0;
  fsm_fin_send = 1'b0;
  reset_2msl   = 1'b1;

  case(current_state)
    CLOSED:
    begin
      if(active_open == 1'b1)
      begin
        next_state = SYN_SEND;
        fsm_syn_send = 1'b1;
      end
      else
        next_state = CLOSED;
    end

    LISTEN:
    begin
      //Implement for passive open...
    end

    SYN_SEND:
    begin
      if(syn_rcvd == 1'b1)
      begin
        fsm_ack_send = 1'b1;
        if(syn_ack_rcvd == 1'b1)
          next_state = ESTAB;
        else
          next_state = SYN_RCVD;
      end
      else
        next_state = SYN_SEND;
    end

    SYN_RCVD:
    begin
      if(syn_ack_rcvd == 1'b1)
      begin
        next_state = ESTAB;
        fsm_ack_send = 1'b1;
      end
      else if(close == 1'b1)
      begin
        next_state = FIN_WAIT_1;
        fsm_fin_send = 1'b1;
      end
      else
        next_state = SYN_RCVD;
    end

    ESTAB:
    begin
      if(close == 1'b1)
      begin
        next_state = FIN_WAIT_1;
        fsm_fin_send = 1'b1;
      end
      else if(fin_rcvd == 1'b1)
      begin
        next_state = CLOSE_WAIT;
        fsm_ack_send = 1'b1;
      end
      else
        next_state = ESTAB;
    end

    FIN_WAIT_1:
    begin
      if(fin_rcvd == 1'b1)
      begin
        next_state = CLOSING;
        fsm_ack_send = 1'b1;
      end
      else if(fin_ack_rcvd == 1'b1)
        next_state = FIN_WAIT_2;
      else
        next_state = FIN_WAIT_1;
    end
    
    FIN_WAIT_2:
    begin
      if(fin_rcvd == 1'b1)
      begin
        next_state = TIME_WAIT;
        fsm_ack_send = 1'b1;
      end
      else
        next_state = FIN_WAIT_2;
    end
    
    CLOSING:
    begin
      if(fin_ack_rcvd == 1'b1)
      begin
        next_state = TIME_WAIT;
        fsm_ack_send = 1'b1;
      end
    end
    
    CLOSE_WAIT:
    begin
      if(close == 1'b1)
      begin
        next_state = LAST_ACK;
        fsm_fin_send = 1'b1;
      end
      else
        next_state = CLOSE_WAIT;
    end
    
    LAST_ACK: //TODO: timeout
    begin
      if(fin_ack_rcvd == 1'b1)
        next_state = CLOSED;
      else
        next_state = LAST_ACK;
    end
    
    TIME_WAIT:
    begin
      reset_2msl = 1'b0;
      if(timeout_2msl_hit == 1'b1)
        next_state = CLOSED;
      else
        next_state = TIME_WAIT;
    end
    
    // SEND_DATA:
    // begin

    // end
    
    // RECEIVE_ACK:
    // begin

    // end
    
    // RECEIVE_DATA:
    // begin

    // end
    
    // SEND_ACK:
    // begin

    // end
    
    // ERROR:
    // begin

    // end
    
    // SEND_ARP_REQ:
    // begin

    // end
    
    // WAIT_ARP_REP:
    // begin

    // end
    
    default:
    begin

    end
  endcase
end

endmodule