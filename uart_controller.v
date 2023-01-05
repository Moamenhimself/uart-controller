module transmitter (
  input clk,
  input rst,
  input [7:0] tx_data,
  input tx_en,
  output tx_busy,
  output reg txd
);
  reg [7:0] tx_shift_reg;
  reg [3:0] tx_state;
  reg tx_busy_int;

  // state machine to control transmission of data
  always @(posedge clk) begin
    if (rst) begin
      tx_state <= 4'b0000;
    end else begin
      case (tx_state)
        4'b0000: begin  // idle
          if (tx_en) begin
            tx_shift_reg <= tx_data;
            tx_state <= 4'b0001;
          end
        end
        4'b0001: begin  // transmit data
          txd <= tx_shift_reg[7];
          tx_shift_reg <= tx_shift_reg << 1;
          if (tx_shift_reg == 0) begin
            tx_state <= 4'b0000;
          end
        end
      endcase
    end
  end

  // set tx_busy when transmitter is transmitting data
  always @(posedge clk) begin
    if (rst) begin
      tx_busy_int <= 1'b0;
    end else begin
      tx_busy_int <= (tx_state != 4'b0000);
    end
  end

  assign tx_busy = tx_busy_int;
endmodule

module receiver (
  input clk,
  input rst,
  input rxd,
  output [7:0] rx_data,
  output rx_valid
);
  reg [7:0] rx_shift_reg;
  reg [3:0] rx_state;
  reg rx_valid_int;
  reg [7:0] rx_data_reg;
  // state machine to control reception of data
  always @(posedge clk) begin
    if (rst) begin
      rx_state <= 4'b0000;
    end else begin
      case (rx_state)
        4'b0000: begin  // idle
          if (rxd) begin
            rx_shift_reg <= 8'b0;
            rx_state <= 4'b0001;
          end
        end
        4'b0001: begin  // receive data
          rx_shift_reg <= {rx_shift_reg[6:0], rxd};
          if (rx_shift_reg[7]) begin
            rx_state <= 4'b0000;
	    rx_data_reg <= rx_shift_reg; // store received data in rx_data_reg
          end
        end
      endcase
    end
  end

  // set rx_valid when a complete data word has been received
  always @(posedge clk) begin
    if (rst) begin
      rx_valid_int <= 1'b0;
    end else begin
      rx_valid_int <= (rx_state == 4'b0000);
    end
  end

  assign rx_data = rx_data_reg;
  assign rx_valid = rx_valid_int;

endmodule

module baud_rate_generator (
  input clk,
  input rst,
  input [31:0] baud_rate,
  output baud_clk
);
  reg [31:0] baud_counter;
  reg [3:0] baud_state;

  // state machine to generate baud rate clock
  always @(posedge clk) begin
    if (rst) begin
      baud_state <= 4'b0000;
    end else begin
      case (baud_state)
        4'b0000: begin  // idle
          baud_counter <= baud_counter + 1;
          if (baud_counter == baud_rate) begin
            baud_counter <= 0;
            baud_state <= 4'b0001;
          end
        end
        4'b0001: begin  // assert baud_clk
          baud_state <= 4'b0000;
        end
      endcase
    end
  end

  assign baud_clk = (baud_state == 4'b0001);
endmodule


module oversampling_clock_generator (
  input clk,
  input rst,
  input [31:0] baud_rate,
  input [4:0] oversampling_factor,
  output oversampling_clk
);
  reg [31:0] baud_counter;
  reg [3:0] baud_state;
  reg [3:0] oversamp_counter;

  // state machine to generate oversampling clock
  always @(posedge clk) begin
    if (rst) begin
      baud_state <= 4'b0000;
      oversamp_counter <= 4'b0000;
    end else begin
      case (baud_state)
        4'b0000: begin  // idle
          baud_counter <= baud_counter + 1;
          if (baud_counter == baud_rate) begin
            baud_counter <= 0;
            baud_state <= 4'b0001;
          end
        end
        4'b0001: begin  // assert oversampling_clk
          oversamp_counter <= oversamp_counter + 1;
          if (oversamp_counter == oversampling_factor) begin
            baud_state <= 4'b0000;
            oversamp_counter <= 0;
          end
        end
      endcase
    end
  end

  assign oversampling_clk = (baud_state == 4'b0001);
endmodule

//
module slave(
input PCLK,
input PRESETn,
input PSEL,
input PENABLE,
input PWRITE,
input [7:0] PADDR,
input [7:0] PWDATA,
output [7:0] PRDATA,
output reg PREADY
);

// Declare registers to hold the address and data
reg [7:0] reg_addr;
reg [7:0] mem [0:255];

// Assign the value at the specified address to PRDATA1
assign PRDATA = mem[reg_addr];

always @(*)
begin
    // If PRESETn is low, set PREADY to 0
    if (!PRESETn)
        PREADY = 0;
    else
    begin
        // If PSEL is high and PENABLE and PWRITE are low, set PREADY to 0
        if (PSEL && !PENABLE && !PWRITE)
            PREADY = 0;
        // If PSEL is high and PENABLE is high and PWRITE is low, set PREADY to 1 and set the address to the value on PADDR
        else if (PSEL && PENABLE && !PWRITE)
        begin
            PREADY = 1;
            reg_addr = PADDR;
        end
        // If PSEL is high and PENABLE is low and PWRITE is high, set PREADY to 0
        else if (PSEL && !PENABLE && PWRITE)
            PREADY = 0;
        // If PSEL is high and PENABLE and PWRITE are high, set PREADY to 1 and write the value on PWDATA to the address specified by PADDR
        else if (PSEL && PENABLE && PWRITE)
        begin
            PREADY = 1;
            mem[PADDR] = PWDATA;
        end
        // Otherwise, set PREADY to 0
        else
            PREADY = 0;
    end
 end  
    
endmodule



module uart_controller (
  input clk,
  input rst,
  input [1:0] sel,
  input [1:0] wen,
  input [3:0] addr,
  input [7:0] wdata,
  output [7:0] rdata,
  output [1:0] ack,
  input tx_en,
  input [7:0] tx_data,
  output tx_busy,
  output txd,
  input rxd,
  output [7:0] rx_data,
  output rx_valid,
  input [31:0] baud_rate,
  output baud_clk
);
  reg [31:0] baud_rate_int;
  // instantiate transmitter, receiver, baud rate generator, and APB slave modules


  baud_rate_generator baudrate1 (
    .clk(clk),
    .rst(rst),
    .baud_rate(baud_rate),
    .baud_clk(baud_clk)
  );

  // instantiate oversampling clock generator
  oversampling_clock_generator oversamp1 (
    .clk(baudrate1.baud_clk),
    .rst(rst),
    .baud_rate(baud_rate),  // set baud rate as desired
    .oversampling_factor(16),  // set oversampling factor to 16
    .oversampling_clk(oversampling_clk)
  );


  transmitter tx (
    .clk(baudrate1.baud_clk),
    .rst(rst),
    .tx_data(tx_data),
    .tx_en(tx_en),
    .tx_busy(tx_busy),
    .txd(txd)
  );
  receiver rx (
    .clk(oversamp1.oversampling_clk),
    .rst(rst),
    .rxd(rxd),
    .rx_data(rx_data),
    .rx_valid(rx_valid)
  );

  slave apb (
    .PCLK(clk),
    .PRESETn(rst),
    .PSEL(sel),
    .PENABLE(wen),
    .PWRITE(addr[3]),
    .PADDR(addr[2:0]),
    .PWDATA(wdata),
    .PRDATA(rdata),
    .PREADY(ack)
  );

  // connect inputs and outputs of transmitter, receiver, and baud rate generator
  // to APB slave module
  always @(posedge clk) begin
    if (rst) begin
      baud_rate_int <= 0;
    end else if (sel && !wen && !addr[3] && addr[2:0] == 3'b000) begin
      baud_rate_int <= wdata;
    end
  end

  assign baud_rate = baud_rate_int;
  assign tx_data = apb.mem[1];
  assign tx_en = apb.mem[2][0];
  assign rx_valid = apb.mem[4][0];
  assign rx_data = apb.mem[5];

endmodule
