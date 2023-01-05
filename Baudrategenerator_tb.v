//In the testbench, the baud_rate input signal is initially set to 5000000, which corresponds to a baud rate of 5 MHz.
//Then, after a delay of 10 time units, the rst signal is set to 0, which resets the state machine in the baud_rate_generator module.
//The clk signal is then toggled every 5 time units.
//After a delay of 150 time units, the value of the baud_rate signal is changed to 1000000, which corresponds to a baud rate of 1 MHz.
//This change in the baud_rate signal will affect the frequency of the baud_clk signal.
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


