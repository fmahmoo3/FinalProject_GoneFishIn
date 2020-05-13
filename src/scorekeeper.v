// ECE 5440
// Group: Gone Fishin'
// Module: scorekeeper
/*
This module keeps score for the game. It does this by using a 1-byte number. The first 4 bits
represent the tens digit, and the second 4 bits represent the ones digit. The module can recieve
1-bit signals which indicate if the score should be increased or decreased.
*/

module scorekeeper(clk, rst, resetScore, incrementScore, decrementScore, currentScore);
	input clk, rst, resetScore; //initializes score
	input incrementScore, decrementScore; //signals that change the score

	output reg [7:0] currentScore; //score output which goes to other modules

	always @(posedge clk) begin
        if(rst == 1'b0 || resetScore == 1'b1) begin
			currentScore = 8'b00000000; //initalize outputs
		end
		else if(incrementScore == 1'b1 && decrementScore == 1'b0 && currentScore != 8'b10011001) begin 
        //increment score
			if(currentScore[3:0] == 4'b1001) begin //if ones place is 9
				currentScore = currentScore - 8'b00001001; //set ones place to 0
				currentScore = currentScore + 8'b00010000; //add one to tens place
			end
			else
				currentScore = currentScore + 8'b00000001; //otherwise, add 1 to ones place
		end
		else if(decrementScore == 1'b1 && incrementScore == 1'b0 && currentScore != 8'b00000000) begin	
        //decrement score
			if(currentScore[3:0] == 4'b0000) begin //if ones place is 0
				currentScore = currentScore + 8'b00001001; //set ones place to 9
				currentScore = currentScore - 8'b00010000; //subtract one from tens place
			end
			else
				currentScore = currentScore - 8'b00000001; //otherwise, subtract 1 from ones place
		end
    end
endmodule
