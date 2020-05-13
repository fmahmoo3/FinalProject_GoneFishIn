// ECE 5440
// Group: Gone Fishin'
// Module: ramController_tb
/*
This module is a test bench for the ramController module. It initizes the RAM
and then write scores to various addresses and then reads various addresses.
*/

`timescale 1ns/100ps

module ramController_tb();

	//inputs
	reg clk_tb,rst_tb,scoreReset;
	reg [3:0] gameState;
	reg [7:0] score;
	reg [2:0] user_ID;

	//output
	wire [7:0] score0, score1, score2, score3, score4, score5;

	ramController DUT_ramController(score,gameState,scoreReset,user_ID,clk_tb,rst_tb,score0, score1, score2, score3, score4, score5);

	always begin	//clock procedure
		clk_tb = 1'b0;
		#20;
		clk_tb = 1'b1;
		#20;
	end

	initial begin
		scoreReset = 1'b0;
		gameState = 4'b0000;
		score = 8'b01010101;
		user_ID = 3'b000;
		
		rst_tb = 1'b0;		//reset is pressed
		@(posedge clk_tb);
		@(posedge clk_tb);
		#5 rst_tb = 1'b1;	//reset is unpressed
		@(posedge clk_tb);
		@(posedge clk_tb);
		#410;

		
		user_ID = 3'b011;	//write score 00011011 to address 011
		@(posedge clk_tb);
		@(posedge clk_tb);
		@(posedge clk_tb);
		@(posedge clk_tb);
		score = 8'b00011011;
		gameState = 4'b0100;
		@(posedge clk_tb);
		gameState = 4'b0000;
		@(posedge clk_tb);
		#285

		user_ID = 3'b001;	//write score 11001000 to address 001
		@(posedge clk_tb);
		@(posedge clk_tb);
		@(posedge clk_tb);
		@(posedge clk_tb);
		score = 8'b11001000;
		gameState = 4'b0100;
		@(posedge clk_tb);
		gameState = 4'b0000;
		@(posedge clk_tb);
		#285

		user_ID = 3'b101;	//write score 11100101 to address 101
		@(posedge clk_tb);
		@(posedge clk_tb);
		@(posedge clk_tb);
		@(posedge clk_tb);
		score = 8'b11100101;
		gameState = 4'b0100;
		@(posedge clk_tb);
		gameState = 4'b0000;
		@(posedge clk_tb);
		#285

		user_ID = 3'b001;	//write score 00001000 to address 001
		@(posedge clk_tb);
		@(posedge clk_tb);
		@(posedge clk_tb);
		@(posedge clk_tb);
		score = 8'b00001000;	//score isn't written becuase it's smaller than the score already there
		gameState = 4'b0100;
		@(posedge clk_tb);
		gameState = 4'b0000;
		@(posedge clk_tb);
		#285

		#160 user_ID = 3'b000;	//read score from each address
		#160 user_ID = 3'b001;
		#160 user_ID = 3'b010;
		#160 user_ID = 3'b011;
		#160 user_ID = 3'b100;
		#160 user_ID = 3'b101;
	end

endmodule



