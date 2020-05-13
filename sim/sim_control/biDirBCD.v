// ECE 5440
// Author: George Hodgkins
// Module: Bidirectional BCD counter
//
// This module is a BCD (decimal counter) that can count up or down depending
// on a control bit, and be connected to other of the same module for
// multi-digit operation using carry bits.

module biDirBCD (Count, SetValue, Set, OutValue, CarryOut, CLK, RST);
	
	// parameter controlling count direction (0 = down, 1 = up)
	parameter Direction = 1;

	// increment/decrement bit (depending on direction)
	// for a multi-counter setup, this would be connected to the CarryOut
	// of another biDirBCD, unless it represents the decimal LSB
	input Count;

	// set value loaded in by the set bit
	input [3:0] SetValue;

	// set bit, loads in SetValue to the counter
	input Set;

	// internal counter
	reg [3:0] Counter;

	// value output (wired to internal counter)
	output [3:0] OutValue;
	assign OutValue = Counter;

	// carry out bit (in a multi setup, connected to CountBit of another
	// biDirBCD unless it represents the MSB)
	output CarryOut;
	reg CarryOut;

	// system clock and reset signals
	input CLK, RST;

	// CombLogic to set CarryOut bit
	// combinational is used so that carries can propagate through
	// multiple counters in one clock cycle
	always @(Count, Set, Counter) begin
		// the carry bit should not be high if Set bit is asserted or
		// Count bit is not
		if (!Set && Count) begin
			if (Direction == 1) begin // counting up
				// counter about to roll over, carry out one
				if (Counter == 4'd9) begin
					CarryOut = 1;
				end
				else begin
					CarryOut = 0;
				end
			end
			else begin // Direction == 0, counting down
				// counter about to roll over, carry out one
				if (Counter == 4'd0) begin
					CarryOut = 1;
				end
				else begin
					CarryOut = 0;
				end
			end
		end
		else begin // no carry out if set bit is high or count bit is low
			CarryOut = 0;
		end
	end
	
	// sequential logic to run counter
	always @(posedge CLK) begin
		if (!RST) begin // negative-logic reset active
			// counter reset value is dependent on Direction
			if (Direction == 1) begin // counting up, reset to 0
				Counter <= 4'd0;
			end
			else begin // counting down, reset to 9
				Counter <= 4'd9;
			end
		end
		else begin
			// Set bit has priority over count bit
			if (Set) begin
				// ignore digit inputs greater than 9
				if (SetValue <= 4'd9) begin
					Counter <= SetValue;
				end
			end
			else if (Count) begin
				if (Direction == 1) begin // counting up
					if (Counter == 4'd9) begin
						// time to roll over (CarryOut = 1)
						Counter <= 4'd0;
					end
					else begin
						Counter <= Counter + 4'd1;
					end
				end
				else begin // Direction == 0, counting down
					if (Counter == 4'd0) begin
						// time to roll over (CarryOut = 1)
						Counter <= 4'd9;
					end
					else begin
						Counter <= Counter - 4'd1;
					end
				end
			end
		end
	end
endmodule

