


module tcp_control
(
  input             clk          ,
  input             rst_n        ,

  input             active_open  ,
  input             active_close ,
  output            syn_send     ,
  input             syn_rcvd     ,
  output            ack_send     ,
  input             ack_rcvd     ,
  output            fin_send     ,
  input             fin_rcvd     ,

  output            state_out    ;
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

//Sequential part of FSM:
always @ (posedge clk, negedge rst_n)
begin
  if(!rst_n)
    current_state <= CLOSED;
  else
    current_state <= next_state;
end

//Combinational part of FSM:
always @ (*)
begin
  case(current_state)
    CLOSED:
    begin

    end

    LISTEN:
    begin

    end

    SYN_SEND:
    begin

    end

    SYN_RCVD:
    begin

    end

    ESTAB:
    begin

    end

    FIN_WAIT_1:
    begin

    end
    
    FIN_WAIT_2:
    begin

    end
    
    CLOSING:
    begin

    end
    
    CLOSE_WAIT:
    begin

    end
    
    LAST_ACK:
    begin

    end
    
    TIME_WAIT:
    begin

    end
    
    SEND_DATA:
    begin

    end
    
    RECEIVE_ACK:
    begin

    end
    
    RECEIVE_DATA:
    begin

    end
    
    SEND_ACK:
    begin

    end
    
    ERROR:
    begin

    end
    
    SEND_ARP_REQ:
    begin

    end
    
    WAIT_ARP_REP:
    begin

    end
    
    default:
    begin

    end
  endcase
end

endmodule