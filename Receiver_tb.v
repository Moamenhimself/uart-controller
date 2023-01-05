module receiver_tb();
  // Declare input and output signals for the MUT
  reg clk, rst;
  reg rxd;
  wire [7:0] rx_data;
  wire rx_valid;

  // Instantiate the MUT
  receiver MUT (
    .clk(clk),
    .rst(rst),
    .rxd(rxd),
    .rx_data(rx_data),
    .rx_valid(rx_valid)
  );

  // Initialize input signals and registers
  initial begin
    clk = 0;
    rst = 1;
    rxd = 0;
    #10 rst = 0;
  end

  // Apply stimuli to the MUT and observe the output responses
  always begin
    #5 clk = ~clk;
  end

  // Print out input and output signals
  initial begin
    $monitor("rxd=%d rx_data=%d rx_valid=%d", rxd, rx_data, rx_valid);
  end

   // Test case: receive multiple data words
  initial begin
    rxd = 1;
    #100; rxd = 0;
    #40; rxd = 1;
    #40; rxd = 0;
    #40; rxd = 1;
    #40; rxd = 0;
  end

endmodule


