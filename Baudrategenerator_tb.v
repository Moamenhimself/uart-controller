module baud_rate_generator_tb();
  // Declare input and output signals for the MUT
  reg clk, rst;
  reg [31:0] baud_rate;
  wire baud_clk;

  // Instantiate the MUT
  baud_rate_generator MUT (
    .clk(clk),
    .rst(rst),
    .baud_rate(baud_rate),
    .baud_clk(baud_clk)
  );

  // Initialize input signals and registers
  initial begin
    clk = 0;
    rst = 1;
    baud_rate = 5000000;  // 5 MHz baud rate
    #10 rst = 0;
  end

  // Apply stimuli to the MUT and observe the output responses
  always begin
    #5 clk = ~clk;
  end

  // Print out input and output signals
  initial begin
    $monitor("baud_rate=%d baud_clk=%d", baud_rate, baud_clk);
  end

  // Test case 1: change baud rate
  initial begin
    #150 baud_rate = 1000000;  // 1 MHz baud rate
  end
endmodule

