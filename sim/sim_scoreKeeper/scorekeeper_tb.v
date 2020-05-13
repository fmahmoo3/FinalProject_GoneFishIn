// ECE 5440
// Group: Gone Fishin'
// Module: scorekeeper_tb
/*
This module is a test bench for the scorekeeper module. It counts up to 11, then
back down to 0.
*/

`timescale 1ns/100ps

module scorekeeper_tb();

	//inputs
	reg [0:0] rst_tb,rstScore,inc,dec,clk_tb;

	//output
	wire [7:0] currScore;

	scorekeeper DUT_scorekeeper(clk_tb,rst_tb,rstScore,inc,dec,currScore);

	always begin	//clock procedure
		clk_tb = 1'b0;
		#20;
		clk_tb = 1'b1;
		#20;
	end

	initial begin
		inc = 1'b0;
		dec = 1'b0;
		rstScore = 1'b0;
		
		rst_tb = 1'b0;		//reset is pressed
		@(posedge clk_tb);
		@(posedge clk_tb);
		#5 rst_tb = 1'b1;	//reset is unpressed
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 inc = 1'b1;
		@(posedge clk_tb);
		#5 inc = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 inc = 1'b1;
		@(posedge clk_tb);
		#5 inc = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 inc = 1'b1;
		@(posedge clk_tb);
		#5 inc = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 inc = 1'b1;
		@(posedge clk_tb);
		#5 inc = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 inc = 1'b1;
		@(posedge clk_tb);
		#5 inc = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 inc = 1'b1;
		@(posedge clk_tb);
		#5 inc = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 inc = 1'b1;
		@(posedge clk_tb);
		#5 inc = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 inc = 1'b1;
		@(posedge clk_tb);
		#5 inc = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 inc = 1'b1;
		@(posedge clk_tb);
		#5 inc = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 inc = 1'b1;
		@(posedge clk_tb);
		#5 inc = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 inc = 1'b1;
		@(posedge clk_tb);
		#5 inc = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 dec = 1'b1;
		@(posedge clk_tb);
		#5 dec = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 dec = 1'b1;
		@(posedge clk_tb);
		#5 dec = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 dec = 1'b1;
		@(posedge clk_tb);
		#5 dec = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 dec = 1'b1;
		@(posedge clk_tb);
		#5 dec = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 dec = 1'b1;
		@(posedge clk_tb);
		#5 dec = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 dec = 1'b1;
		@(posedge clk_tb);
		#5 dec = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 dec = 1'b1;
		@(posedge clk_tb);
		#5 dec = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 dec = 1'b1;
		@(posedge clk_tb);
		#5 dec = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 dec = 1'b1;
		@(posedge clk_tb);
		#5 dec = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 dec = 1'b1;
		@(posedge clk_tb);
		#5 dec = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 dec = 1'b1;
		@(posedge clk_tb);
		#5 dec = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);

		#5 dec = 1'b1;
		@(posedge clk_tb);
		#5 dec = 1'b0;
		@(posedge clk_tb);
		@(posedge clk_tb);
	end

endmodule



