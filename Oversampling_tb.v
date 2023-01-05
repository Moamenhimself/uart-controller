//The testbench instantiates an instance of oversampling_clock_generator called MUT and applies stimuli to it by setting the input signals clk, rst, baud_rate, and oversampling_factor and observing the output signal oversampling_clk.
//It also includes some initial and always blocks that set the input signals to specific values and toggle the clk signal.
// It also includes a $monitor statement that prints the values of the input and output signals.
//Finally, there is an initial block at the end that changes the value of oversampling_factor after a delay of 150 time units.

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
    baud_rate = 9600;  
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
  // Test case 2: change baud rate
  initial begin
    #300 baud_rate = 10000;
  end
endmodule

