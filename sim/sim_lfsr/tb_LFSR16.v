// ECE 5440
// Author: George Hodgkins
// Module: 16-bit LFSR testbench
//
// This module acts as a testbench for the 16-bit LFSR. In addition to testing
// basic functionality, it also tests a long counting sequence to ensure the
// value is correct.

`timescale 1ns/100ps

module tb_LFSR16;
	
	// simulated control bits
	reg Restart, Run;

	// value output
	wire [15:0] Value;

	// simulated clock and reset
	reg CLK, RST;

	// instantiate test module
	LFSR16 DUT (Restart, Run, Value, CLK, RST);

	// establish 50 MHz clock (20 ns period)
	always begin
		CLK = 0;
		#10;
		CLK = 1;
		#10;
	end

	// testing block
	initial begin
		// initial input values
		Restart = 0;
		Run = 0;
		#3;
		RST = 0; // assert negative-logic reset
		#40;
		RST = 1; // release reset
		#40;
		Run = 1;
		// run timer for 5 clocks
		repeat (5) begin
			@(posedge CLK);
		end
		// output value should now be 'h225F
		#3;
		Run = 0;
		// reset timer with non-system reset
		Restart = 1;
		@(posedge CLK);
		@(posedge CLK);
		Restart = 0;
		// start timer and wait for 1 ms (50k clocks)
		Run = 1;
		@(posedge CLK); #1000000;
		// output value should now be 'h9967
		Run = 0;
	end
endmodule

