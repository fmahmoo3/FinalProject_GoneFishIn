// ECE 5440
// Group: Gone Fishin'
// Module: Difficulty selector testbench
//
// This module tests every possible combination of score and difficulty to
// ensure that the outputs are always a valid decimal number

`timescale 1ns/100ps

module tb_difficultySelector;

	// simulated inputs
	reg [3:0] startingDiff;
	reg [3:0] scoreOnes, scoreTens;
	wire [7:0] currentScore = {scoreOnes, scoreTens};
	reg CLK, RST;

	// test module outputs
	wire [11:0] reelTime;
	wire [19:0] fishTime;
	wire [25:0] leftLoseBound;
	wire [25:0] rightLoseBound;
	wire [25:0] winZone;

	// validity checks
	wire reelTimeInvalid = 
		(reelTime[11:8] > 'h9) ||
		(reelTime[7:4] > 'h9) ||
		(reelTime[3:0] > 'h9);

	wire fishTimeInvalid =
		(fishTime[19:16] > 'h9) ||
		(fishTime[15:12] > 'h9) ||
		(fishTime[11:8] > 'h9) ||
		(fishTime[7:4] > 'h9) ||
		(fishTime[3:0] > 'h9);

	// create reversed versions of rightLoseBound and winZone for validity checks
	// since less than can't tell you if winZone has bits below the right bound
	wire [25:0] rightLoseBoundRev, winZoneRev;
	genvar i;
	generate
		for (i = 0; i < 26R; i = i + 1) begin
			assign rightLoseBoundRev[25-i] = rightLoseBound[i];
			assign winZoneRev[25-i] = winZone[i];
		end
	endgenerate

	wire winZoneinvalid =
		(winZone >= leftLoseBound) ||
		(winZoneRev >= rightLoseBoundRev);

	// instat test device
	difficultySelector DUT (startingDiff[2:0], currentScore, 1'b0, 1'b0,
	       	reelTime, fishTime, leftLoseBound, rightLoseBound, winZone,
	CLK, RST);

	// instat test clock so values can get passed through the latch
	always begin
		CLK = 0;
		#1;
		CLK = 1;
		#1;
	end

	// loop through all possible values
	initial begin
		// assert reset
		RST = 0;
		#10;
		RST = 1;
		// loop
		for (startingDiff = 'h0; startingDiff < 'h8; startingDiff = startingDiff + 1) begin
			for (scoreTens = 'h0; scoreTens < 'hA; scoreTens = scoreTens + 1) begin
				for (scoreOnes = 'h0; scoreOnes < 'hA; scoreOnes = scoreOnes + 1) begin
					#10;
				end
			end
		end
	end
endmodule
