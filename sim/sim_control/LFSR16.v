// ECE 5440
// Author: George Hodgkins
// Module: 16-bit LFSR
//
// This module implements a maximum-period (2^16 -1) 16-bit LFSR for use as the core
// of a timer module.


module LFSR16 (Restart, Run, Value, CLK, RST);
	
	// this bit resets the LFSR (same as system RST)
	// has priority over Run input
	input Restart;

	// the LFSR only counts if this input is high
	input Run;

	// current value of the LFSR state
	output [15:0] Value;
	reg [15:0] state;
	assign Value = state;

	// these wires implement the actual shifting,
	// the sequential logic simply latches shift3->state every clock
	// when Run is high
	wire [15:0] shift1 = state ^ (state << 7);
	wire [15:0] shift2 = shift1 ^ (shift1 >> 9);
	wire [15:0] shift3 = shift2 ^ (shift2 << 8);

	// system clock and reset signals
	input CLK, RST;

	always @(posedge CLK) begin
		if (!RST || Restart) begin // negative-logic reset
			state <= 16'hFFFF; // any nonzero seed works, this one is memorable
		end
		else begin
			if (Run) begin
				// see wire assignments above
				state <= shift3;
			end
			else begin
				state <= state;
			end
		end
	end
endmodule
