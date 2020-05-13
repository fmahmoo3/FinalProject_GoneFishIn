// ECE 5440
// Group: Gone Fishin'
// Module: Load/bidirectional shift register
//
// This module is a load/bidirectional shift register, meaning it can act as
// both a normal load register and a shift register. Arbitrary number of bits.

module multiReg (loadValue, loadBit, shiftLeft, shiftRight, currentValue, CLK, RST);

	// number of bits in register
	parameter Bits = 4;	

	// value to be loaded when load bit or reset is asserted
	input [Bits-1:0] loadValue;

	// bit controlling load (has priority over shifts)
	input loadBit;

	// bits controlling shifting (left has priority over right)
	input shiftLeft, shiftRight;

	// current value of the register
	output [Bits-1:0] currentValue;
	// we need to be able to see it inside the module
	reg [Bits-1:0] storedValue;
	assign currentValue = storedValue;

	// system clock and reset
	input CLK, RST;

	always @(posedge CLK) begin
		if (!RST || loadBit) begin // negative-logic reset
			storedValue <= loadValue;
		end
		else if (shiftLeft) begin
			storedValue <= storedValue << 1;
		end
		else if (shiftRight) begin
			storedValue <= storedValue >> 1;
		end
		else begin
			storedValue <= storedValue;
		end
	end
endmodule
