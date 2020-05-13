// ECE 5440
// Group: GoneFishin'
// Module: SevenSeg

// Provided a 4-bit binary value, between 0000 - 1111, this module will return the 7-bit output signal
// to properly display the number in Hexadecimal. 

// Example:
// input: 
//		num_bi: 1010
// output: 
//	 	num_disp: 'A'

module SevenSeg (num_bi, num_disp);
	input [3:0] num_bi;
	output [6:0] num_disp;
	reg [6:0] num_disp;

	always @ (num_bi) begin
		case(num_bi)
		4'b0000: num_disp = 7'b1000000;//0
		4'b0001: num_disp = 7'b1111001;//1
		4'b0010: num_disp = 7'b0100100;//2
		4'b0011: num_disp = 7'b0110000;//3
		4'b0100: num_disp = 7'b0011001;//4
		4'b0101: num_disp = 7'b0010010;//5
		4'b0110: num_disp = 7'b0000010;//6
		4'b0111: num_disp = 7'b1111000;//7
		4'b1000: num_disp = 7'b0000000;//8
		4'b1001: num_disp = 7'b0011000;//9
		4'b1010: num_disp = 7'b0001000;//10 'A'
		4'b1011: num_disp = 7'b0000011;//11 'b'
		4'b1100: num_disp = 7'b1000110;//12 'C'
		4'b1101: num_disp = 7'b0100001;//13 'd'
		4'b1110: num_disp = 7'b0000110;//14 'E'
		4'b1111: num_disp = 7'b0001110;//15 'F'
		endcase
	end

endmodule
