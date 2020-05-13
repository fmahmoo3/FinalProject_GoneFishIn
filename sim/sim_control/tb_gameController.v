// ECE 5440
// Group: Gone Fishin'
// Module: Game controller testbench

`timescale 1us/100ns

module tb_gameController;

	// simulated control inputs
	reg gameControl, reelButton, castButton;

	// simulated difficulty inputs
	// fixed at constant values for now
	wire [7:0] currentScore = {4'h0, 4'h0};
	reg [2:0] startingDiff;

	// game status outputs
	wire [25:0] lightBar;
	wire [3:0] gameInfo;
	wire scoreUp, scoreDown, scoreRst, blinkBit;

	wire [7:0] fishTimeDisp;
	wire [3:0] fishTimeOnes = fishTimeDisp[3:0];
	wire [7:4] fishTimeTens = fishTimeDisp[7:4];

	// simulated clock and reset
	reg CLK, RST;

	// define 10 KHz clock
	defparam DUT.LFSRTarget = 16'hA59A;
	// instantiate test module
	gameController DUT (
		.gameControl(gameControl),
		.reelButton(reelButton),
		.castButton(castButton),
		.currentScore(currentScore),
		.startingDiff(startingDiff),
		.lightBar(lightBar),
		.gameInfo(gameInfo),
		.scoreUp(scoreUp),
		.scoreDown(scoreDown),
		.fishTimeDisp(fishTimeDisp),
		.blinkBit(blinkBit),
		.scoreRst(scoreRst),
		.CLK(CLK),
		.RST(RST));

	// set 10 KHz clock
	always begin
		CLK = 0;
		#50;
		CLK = 1;
		#50;
	end

	// testing block
	initial begin
		// establish initial values
		gameControl = 1;
		reelButton = 0;
		castButton = 0;
		startingDiff = 3'h3;
		// assert negative-logic reset
		RST = 0;
		repeat (10) @(posedge CLK);
		// release reset
		RST = 1;
		repeat (4) @(posedge CLK);
		// start game
		castButton = 1;
		@(posedge CLK);
		castButton = 0;
		// wait for 6 seconds for game things to happen
		repeat (6) #1000000;
		// check that difficulty latching works
		startingDiff = 3'h0;
		// boop reel button 6 times .60 secs apart (reel timer is set to .65)
		repeat (6) begin
			@(posedge CLK) reelButton = 1;
			@(posedge CLK) reelButton = 0;
			#600000;
		end
		// boop reel button again 5 seconds later to catch a boot
		#4000000;
		@(posedge CLK) reelButton = 1;
		@(posedge CLK) reelButton = 0;
		// more
		#22000000;
		@(posedge CLK) castButton = 1;
		@(posedge CLK) castButton = 0;							
	end
endmodule

