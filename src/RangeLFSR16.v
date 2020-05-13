// ECE 5440
// Group: Gone Fishin'
// Module: RangLFSR16.v

//This module generates a random number within the range specified by the user.

module RangeLFSR16(Restart,Run,offset,limit,out,CLK,RST);
	input Restart,Run,CLK,RST;
	input [15:0] offset,limit;
	output [15:0] out;
	reg [15:0] out;
	wire [15:0] Value;
	LFSR16 LFSR16_1(Restart,Run,Value,CLK,RST);
	always @ (CLK)
		begin
		out=offset+(Value%(limit+1-offset));
		end
endmodule
