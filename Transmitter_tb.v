module transmitter_tb();
  // Declare input and output signals for the MUT
  reg clk, rst, tx_en;
  reg [7:0] tx_data;
  wire tx_busy;
  wire txd;

  // Instantiate the MUT
  transmitter MUT (
    .clk(clk),
    .rst(rst),
    .tx_data(tx_data),
    .tx_en(tx_en),
    .tx_busy(tx_busy),
    .txd(txd)
  );

  // Initialize input signals and registers
  initial begin
    clk = 0;
    rst = 1;
    tx_en = 0;
    tx_data = 0;
    #10 rst = 0;
  end

  // Apply stimuli to the MUT and observe the output responses
  always begin
    #5 clk = ~clk;
  end

  // Print out input and output signals
  initial begin
    $monitor("tx_data=%d tx_en=%d txd=%d tx_busy=%d", tx_data, tx_en, txd, tx_busy);
  end

  // Test case 1: transmit a single data word
  initial begin
    tx_en = 1;
    tx_data = 8'h12;
    #100;
    tx_en = 0;
  end

  // Test case 2: transmit multiple data words
  initial begin
    #100;
    tx_en = 1;
    tx_data = 8'h34;
    #100;
    tx_data = 8'h87;
    #50;
    tx_en = 0;
  end
endmodule