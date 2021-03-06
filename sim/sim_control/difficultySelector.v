// ECE 5440
// Group: Gone Fishin'
// Module: Difficulty selector
//
// This module takes an initial difficulty selection and a current score and
// uses these to select times for the reel & catch timers, which
// decrease/increase respectively with initial difficulty and score, and win/lose
// bounds for the LED bar, which get tighter as difficulty increases (not affected
// by score). Mostly combinational, except for a latch. Not really a separate function from the game
// controller, but it's broken out because that module is already pretty long

module difficultySelector (currentDiff, currentScore, holdDiff, useWaitTime, // inputs
	reelTime, fishTime, leftLoseBound, rightLoseBound, winZone, // outputs
	CLK, RST);

	// system clock and reset
	// only used for latching difficulty
	input CLK, RST;

	// 8 possible starting difficulties
	input [2:0] currentDiff; // actual current difficulty input
	reg [2:0] startingDiff; // stored value for use during gameplay

	// current score is a 2-digit decimal number
	// represented as 2 4-bit hex digits
	input [7:0] currentScore;
	wire [3:0] scoreTens = currentScore[7:4];
	wire [3:0] scoreOnes = currentScore[3:0];

	// holdDiff bit controls latching of currentDiff->startingDiff
	// (1=opaque)
	input holdDiff;

	// useWaitTime bit indicates that the fishTime should be set to
	// a lower, fixed time (for wait periods) rather than longer varying
	// time for catching fish
	input useWaitTime;
	// WAIT_TIME is the fixed time mentioned above
	parameter WAIT_TIME = {4'h0, 4'h4, 4'h0, 4'h0, 4'h0}; // 4 sec

	// reel time is time it takes one LED to decrement,
	// or a boot to go away
	// up to .999 sec, represented as 3 4-bit hex digits .xxx
	output [11:0] reelTime; // assigned at end of module

	// fish time is time it takes a fish to be hooked/caught
	// up to 99.999 secs (theoretically)
	// represented as 5 4-bit hex digits xx.xxx
	output [19:0] fishTime; // assigned at end of module

	// left and right lose bounds are the bounds you must keep the current
	// LED within to not lose (closer on higher difficulty)
	// defined in terms of the 26-LED LED bar on the board
	output [25:0] leftLoseBound;
	reg [25:0] leftLoseBound;
	output [25:0] rightLoseBound;
	reg [25:0] rightLoseBound;

	// win zone is the zone current LED must be in for the timer to count down
	output [25:0] winZone;
	reg [25:0] winZone;

	// set up difficulty latching
	always @(posedge CLK) begin
		if (!RST) begin // negative-logic reset
			startingDiff <= 0;
		end
		else begin
			// latch is transparent if holdDiff is low
			if (holdDiff) begin
				startingDiff <= startingDiff;
			end
			else begin
				startingDiff <= currentDiff;
			end
		end
	end


	// first, preliminary values are set from starting diff
	reg [11:0] reelTimePrelim;
	reg [19:0] fishTimePrelim;

	always @(startingDiff) begin

		// tens, hundths, and thouths digits of prelim fish time will not be nonzero
		fishTimePrelim[19:16] = 4'h0;
		fishTimePrelim[7:0] = {4'h0, 4'h0};

		// millisecond digit of prelim reel time will not be nonzero
		reelTimePrelim[3:0] = {4'h0};

		case (startingDiff)
			'h0: begin
				// .99 sec
				reelTimePrelim[11:4] = {4'h9, 4'h9};
				// 3.0 sec
				fishTimePrelim[15:8] = {4'h3, 4'h0};
				// LEDG7
				rightLoseBound = 26'b1 << 0;
				// LEDR10
				leftLoseBound = 26'b1 << 16;
				// LEDR14 - LEDG3
				winZone = 26'b00000000000000111111110000;
			end
			'h1: begin
				// .95 sec
				reelTimePrelim[11:4] = {4'h9, 4'h5};
				// 3.5 sec
				fishTimePrelim[15:8] = {4'h3, 4'h5};
				// LEDG6
				rightLoseBound = 26'b1 << 1;
				// LEDR11
				leftLoseBound = 26'b1 << 15;
				// LEDR14 - LEDG3
				winZone = 26'b00000000000000111111110000;
			end
			'h2: begin
				// .89 sec
				reelTimePrelim[11:4] = {4'h8, 4'h9};
				// 4.0 sec
				fishTimePrelim[15:8] = {4'h4, 4'h0};
				// LEDG5
				rightLoseBound = 26'b1 << 2;
				// LEDR12
				leftLoseBound = 26'b1 << 14;
				// LEDR15 - LEDG2
				winZone = 26'b00000000000000011111100000;
			end
			'h3: begin
				// .85 sec
				reelTimePrelim[11:4] = {4'h8, 4'h5};
				// 4.5 sec
				fishTimePrelim[15:8] = {4'h4, 4'h5};
				// LEDG4
				rightLoseBound = 26'b1 << 3;
				// LEDR13
				leftLoseBound = 26'b1 << 13;
				// LEDR15 - LEDG2
				winZone = 26'b00000000000000011111100000;
			end
			'h4: begin
				// .79 sec
				reelTimePrelim[11:4] = {4'h7, 4'h9};
				// 5.0 sec
				fishTimePrelim[15:8] = {4'h5, 4'h0};
				// LEDG3
				rightLoseBound = 26'b1 << 4;
				// LEDR14
				leftLoseBound = 26'b1 << 12;
				// LEDR16 - LEDG1
				winZone = 26'b00000000000000001111000000;
			end
			'h5: begin
				// .75 sec
				reelTimePrelim[11:4] = {4'h7, 4'h5};
				// 5.5 sec
				fishTimePrelim[15:8] = {4'h5, 4'h5};
				// note that the bounds here are the same as the
				// previous state because otherwise we run out
				// of space to decrease
				// LEDG3
				rightLoseBound = 26'b1 << 4;
				// LEDR14
				leftLoseBound = 26'b1 << 12;
				// LEDR16 - LEDG1
				winZone = 26'b00000000000000001111000000;
			end
			'h6: begin
				// .69 sec
				reelTimePrelim[11:4] = {4'h6, 4'h9};
				// 5.9 sec
				// note that this stops increasing with difficulty
				// because 5 is the highest valid ones value
				fishTimePrelim[15:8] = {4'h5, 4'h9};
				// LEDG2
				rightLoseBound = 26'b1 << 5;
				// LEDR15
				leftLoseBound = 26'b1 << 11;
				// LEDR17 - LEDG0
				winZone = 26'b00000000000000000110000000;
			end
			'h7: begin
				// .65 sec
				reelTimePrelim[11:4] = {4'h6, 4'h5};
				// 5.9 sec
				fishTimePrelim[15:8] = {4'h5, 4'h9};
				// LEDG1
				rightLoseBound = 26'b1 << 6;
				// LEDR16
				leftLoseBound = 26'b1 << 10;
				// LEDR17 - LEDG0
				winZone = 26'b00000000000000000110000000;
			end
		endcase
	end


	// next, score selects an amount to add/subtract to/from the prelim values
	reg [3:0] reelHundthsSub, reelTenthsSub;
	reg [3:0] fishOnesAdd;

	always @(scoreOnes, scoreTens) begin
		
		// select values for fish timer ones/reel timer hundths
		// based on highest nonzero bit of score ones
		if (scoreOnes[3]) begin
			reelHundthsSub = 'h4;
			fishOnesAdd = 'h4;
		end
		else if (scoreOnes[2]) begin
			reelHundthsSub = 'h3;
			fishOnesAdd = 'h3;
		end
		else if (scoreOnes[1]) begin
			reelHundthsSub = 'h2;
			fishOnesAdd = 'h2;
		end
		else if (scoreOnes[0]) begin
			reelHundthsSub = 'h1;
			fishOnesAdd = 'h1;
		end
		else begin
			reelHundthsSub = 'h0;
			fishOnesAdd = 'h0;
		end

		// select value for reel timer tenths based on highest
		// nonzero bit of score tens
		if (scoreTens[3]) begin
			reelTenthsSub = 'h4;
		end
		else if (scoreTens[2]) begin
			reelTenthsSub = 'h3;
		end
		else if (scoreTens[1]) begin
			reelTenthsSub = 'h2;
		end
		else if (scoreTens[0]) begin
			reelTenthsSub = 'h1;
		end
		else begin
			reelTenthsSub = 'h0;
		end

		// add value for fish timer tens is simply based on the tens
		// digit of the score
	end


	// finally, implement the actual adding and subtracting and produce output
	wire [7:0] reelTimeDiffPart = reelTimePrelim[11:4] - {reelTenthsSub, reelHundthsSub};
	wire [7:0] fishTimeSumPart = fishTimePrelim[19:12] + {scoreTens, fishOnesAdd};
		
	assign reelTime = {reelTimeDiffPart, reelTimePrelim[3:0]};
	assign fishTime = (useWaitTime) ? WAIT_TIME : {fishTimeSumPart, fishTimePrelim[11:0]};

endmodule
