module oversampling_clock_generator_tb();
  // Declare input and output signals for the MUT
  reg clk, rst;
  reg [31:0] baud_rate;
  reg [4:0] oversampling_factor;
  wire oversampling_clk;

  // Instantiate the MUT
  oversampling_clock_generator MUT (
    .clk(clk),
    .rst(rst),
    .baud_rate(baud_rate),
    .oversampling_factor(oversampling_factor),
    .oversampling_clk(oversampling_clk)
  );

  // Initialize input signals and registers
  initial begin
    clk = 0;
    rst = 1;
    baud_rate = 5000000;  // 5 MHz baud rate
    #10
    oversampling_factor = 16;  // 16x oversampling
    #10
    rst = 0;
  end

  // Apply stimuli to the MUT and observe the output responses
  always begin
    #5 clk = ~clk;
  end

  // Print out input and output signals
  initial begin
    $monitor("baud_rate=%d oversampling_factor=%d oversampling_clk=%d", baud_rate, oversampling_factor, oversampling_clk);
  end

  // Test case 1: change oversampling factor
  initial begin
    #150 oversampling_factor = 8;  // 8x oversampling
  end
endmodule

