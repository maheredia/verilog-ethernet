


module mdio_fsm
#(
  parameter PRESCALE = 8'd3,
  parameter PHY_ADDR = 5'h00,
  parameter WAIT_CNT = 125000000
)
(
  input  wire        clk,
  input  wire        rst,
  /*
   * data interface
   */
  output wire [15:0] data_out,
  output wire        data_out_valid,
  /*
   * MDIO to PHY
   */
  output wire        mdc_o,
  input  wire        mdio_i,
  output wire        mdio_o,
  output wire        mdio_t,
  /*
   * Status
   */
  output wire        busy,
  output wire [4:0]  state_out
);

localparam ST_RD_BMCR = 5'd0;
localparam ST_RD_PHY_ID_1 = 5'd1;
localparam ST_RD_PHY_ID_2 = 5'd2;
localparam ST_RD_BMSR = 5'd3;
localparam ST_RD_GBSR = 5'd4;
localparam ST_RD_GBESR = 5'd5;
localparam ST_WR_BMCR = 5'd6;
localparam ST_WAIT = 5'd31;

reg [31:0] wait_cntr;
reg        wait_cntr_ena;

always @ (posedge clk, posedge rst)
begin
  if(rst==1'b1 || wait_cntr_ena==1'b0)
  begin
    wait_cntr <= 32'd0;
  end
  else if(wait_cntr_ena==1'b1)
  begin
    if(wait_cntr < WAIT_CNT-1)
      wait_cntr <= wait_cntr+1'b1;
  end
end

reg [19:0] delay_reg = 20'hfffff;
reg [4:0] mdio_cmd_reg_addr = 5'h00;
reg [15:0] mdio_cmd_data = 16'd0;
reg [1:0] mdio_cmd_opcode = 2'b01;
reg mdio_cmd_valid = 1'b0;
wire mdio_cmd_ready;
wire [15:0] mdio_read_data;
wire mdio_data_out_valid;

reg [4:0] state_reg = 0;

always @(posedge clk) begin
    if (rst) begin
        state_reg <= ST_WAIT;
        delay_reg <= 20'hfffff;
        mdio_cmd_reg_addr <= 5'h00;
        mdio_cmd_data <= 16'd0;
        mdio_cmd_valid <= 1'b0;
        wait_cntr_ena <= 1'b0;
        mdio_cmd_opcode <= 2'b10;
    end 
    else
    begin
        mdio_cmd_valid <= mdio_cmd_valid & !mdio_cmd_ready;
        if(delay_reg > 0)
        begin
            delay_reg <= delay_reg - 1;
        end
        else if(!mdio_cmd_ready)
        begin
            // wait for ready
            state_reg <= state_reg;
        end
        else
        begin
            mdio_cmd_valid <= 1'b0;
            wait_cntr_ena <= 1'b0;
            case (state_reg)
                ST_WAIT:
                begin
                  mdio_cmd_reg_addr <= 5'h00;
                  mdio_cmd_data <= 16'd0;
                  mdio_cmd_valid <= 1'b0;
                  mdio_cmd_opcode <= 2'b10;
                  wait_cntr_ena <= 1'b1;
                  if(wait_cntr==WAIT_CNT-1)
                    state_reg <= ST_RD_BMCR;
                end

                ST_RD_BMCR:
                begin
                    mdio_cmd_reg_addr <= 5'h00;
                    mdio_cmd_data <= 16'd0;
                    mdio_cmd_valid <= 1'b1;
                    mdio_cmd_opcode <= 2'b10;
                    state_reg <= ST_RD_PHY_ID_1;
                end

                ST_RD_PHY_ID_1:
                begin
                    mdio_cmd_reg_addr <= 5'h02;
                    mdio_cmd_data <= 16'd0;
                    mdio_cmd_valid <= 1'b1;
                    mdio_cmd_opcode <= 2'b10;
                    state_reg <= ST_RD_PHY_ID_2;
                end

                ST_RD_PHY_ID_2:
                begin
                    mdio_cmd_reg_addr <= 5'h03;
                    mdio_cmd_data <= 16'd0;
                    mdio_cmd_valid <= 1'b1;
                    mdio_cmd_opcode <= 2'b10;
                    state_reg <= ST_RD_BMSR;
                end

                ST_RD_BMSR:
                begin
                    mdio_cmd_reg_addr <= 5'h01;
                    mdio_cmd_data <= 16'd0;
                    mdio_cmd_valid <= 1'b1;
                    mdio_cmd_opcode <= 2'b10;
                    state_reg <= ST_RD_GBSR;
                end

                ST_RD_GBSR:
                begin
                    mdio_cmd_reg_addr <= 5'h0A;
                    mdio_cmd_data <= 16'd0;
                    mdio_cmd_valid <= 1'b1;
                    mdio_cmd_opcode <= 2'b10;
                    state_reg <= ST_RD_GBESR;
                end

                ST_RD_GBESR:
                begin
                    mdio_cmd_reg_addr <= 5'h0F;
                    mdio_cmd_data <= 16'd0;
                    mdio_cmd_valid <= 1'b1;
                    mdio_cmd_opcode <= 2'b10;
                    state_reg <= ST_WR_BMCR;
                end

                ST_WR_BMCR:
                begin
                    mdio_cmd_reg_addr <= 5'h00;
                    mdio_cmd_data <= 16'h5140;
                    mdio_cmd_valid <= 1'b1;
                    mdio_cmd_opcode <= 2'b01;
                    state_reg <= ST_WAIT;
                end

                default: begin
                    // done
                    state_reg <= ST_WAIT;
                end
            endcase
        end
    end
end

mdio_master
mdio_master_inst (
    .clk(clk),
    .rst(rst),

    .cmd_phy_addr(PHY_ADDR),
    .cmd_reg_addr(mdio_cmd_reg_addr),
    .cmd_data(mdio_cmd_data),
    .cmd_opcode(mdio_cmd_opcode),
    .cmd_valid(mdio_cmd_valid),
    .cmd_ready(mdio_cmd_ready),

    .data_out(mdio_read_data),
    .data_out_valid(mdio_data_out_valid),
    .data_out_ready(1'b1),

    .mdc_o(mdc_o),
    .mdio_i(mdio_i),
    .mdio_o(mdio_o),
    .mdio_t(mdio_t),

    .busy(busy),
    .prescale(PRESCALE)
);

assign data_out = mdio_read_data;
assign data_out_valid = mdio_data_out_valid;
assign state_out = state_reg;

endmodule