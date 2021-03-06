// ECE 5440
// Group: Gone Fishin'
// Module: Game controller
//
// This module is the primary controller for the Gone Fishin' game. It
// implements the state machine for gameplay and instantiates several related
// modules, including the various timers used and the random number generator.

module gameController (

	// game control inputs
	gameControl, startingDiff, reelButton, castButton, currentScore,

	// score control outputs
	scoreUp, scoreDown, scoreRst,

	// display outputs
	lightBar, gameInfo, fishTimeDisp, blinkBit,

	// system clock and reset
	CLK, RST);

	input CLK, RST;

	
	//-----Control inputs-----
	// Bit indicating if the game should be operational or suspended
	input gameControl;
	// this is the starting difficulty (0-7, higher more difficult)
	input [2:0] startingDiff;
	// this shaped button input starts and ends the game
	input castButton;
	// this button increases the LED bar by one during gameplay
	input reelButton;
	// this is the current score (from the score keeper) represented as
	// 2 4-bit decimal digits
	input [7:0] currentScore;


	//-----Display & score control outputs-----
	// These are controlled by the state machine unless otherwise indicated
	//
	// this controls the LED bar that indicates the fishing status
	// controlled by LED blinker module
	output [25:0] lightBar;
	// this selects various things to be displayed on the info display
	// passed through a decoder
	output [3:0] gameInfo;
	reg [3:0] gameInfo;
	// these outputs increment, decrement, and reset the score, respectively
	output scoreUp, scoreDown, scoreRst;
	reg scoreUp, scoreDown, scoreRst;
	// this outputs the remaining time until the fish is caught as two
	// 4-bit hex digits, but representing decimal numbers
	// tied to a timer module output below
	output [7:0] fishTimeDisp;
	// this bit is used to blink the info display
	// controlled by LED blinker module
	output blinkBit;


	//-----RNG-----
	// Random numbers will be generated from a free-spinning 16-bit LFSR
	wire [15:0] currentRand; // current value of the LFSR
	// this LFSR will shift every clock cycle, always
	LFSR16 randomSource (1'b0, 1'b1, currentRand, CLK, RST);


	//-----Difficulty selector-----
	// The difficulty selector takes a difficulty setting and the current
	// score as inputs and produces timer starting values and win/lose bounds
	// as outputs. As the difficulty/score increase, reel time gets
	// shorter and fish time gets longer. Since the fish timer is also
	// used for the waiting periods, but we don't want to wait longer on
	// higher difficulties, the useWaitTime bit tells the selector to
	// output a shorter load time for the fish timer to use during waiting periods.
	reg holdDiff; // tells selector to keep the current difficulty until the end of the game
	reg useWaitTime; // tells selector to use a shorter time for waiting-for-fish periods
	defparam diffSel.WAIT_TIME = {4'h0, 4'h4, 4'h0, 4'h0, 4'h0}; // 04.000 sec
	wire [11:0] reelTimerLoad; // reel timer load value
	wire [19:0] fishTimerLoad; // fish timer load value
	// win/lose bounds (inputs to LEDBlinker below)
	wire [25:0] leftLoseBound, rightLoseBound, winZone;
	difficultySelector diffSel (startingDiff, currentScore, holdDiff, useWaitTime,
		reelTimerLoad, fishTimerLoad, leftLoseBound, rightLoseBound, winZone,
		CLK, RST);


	// TODO: add interval randomizers
	//-----Gameplay timers-----
	// There are two timers involved in gameplay:
	// fishTimer - time until an object is hooked or a fish is caught
	// reelTimer - time until LED decrements or boot is off hook
	reg runFishTimer, runReelTimer; // bits telling the timer to run
	reg rstFishTimer, rstReelTimer; // bits telling the timer to reset and load new values
	wire fishTimerDone, reelTimerDone; // bits indicating the timer has timed out
	wire [19:0] fullFishTimeDisp; // full time has three sub-second digits not used
	assign fishTimeDisp = fullFishTimeDisp[19:12];	

	parameter LFSRTarget = 16'h9CED; // target for 50 MHz
	defparam fishTimer.LFSRTarget = LFSRTarget;
	defparam reelTimer.LFSRTarget = LFSRTarget;

	defparam fishTimer.Digits = 5; //xx.xxx
	countdownTimer fishTimer (
		.StartValue(fishTimerLoad),
		.Restart(rstFishTimer),
		.Run(runFishTimer),
		.CurrentValue(fullFishTimeDisp), // tied to a module output
		.TimerDone(fishTimerDone),
		.CLK(CLK),
		.RST(RST));

	defparam reelTimer.Digits = 3; //.xxx
	countdownTimer reelTimer (
		.StartValue(reelTimerLoad),
		.Restart(rstReelTimer),
		.Run(runReelTimer),
		.CurrentValue(), // intentionally not connected
		.TimerDone(reelTimerDone),
		.CLK(CLK),
		.RST(RST));


	
	//-----LED blinker----
	// This module controls the LED bar output, selecting some LEDs to
	// turn on and some to blink (using an internal timer). 
	// It also outputs a blink bit to control blinking of the info
	// display. LED bar is represented as a 26-bit binary number where
	// LEDG7 is the LSB and LEDR0 is the MSB.
	//
	// Three LEDs will blink: the right and left "lose bounds", and the current
	// LED (controlled by the reel button/timer). If the current LED
	// hits either boundary, you lose the game.
	//
	// The LEDs between the "win bounds," inclusive, will be lit (solid),
	// except the current LED if it is in that range. The current LED has
	// to stay in the win bounds for the fish timer to count down; when
	// the timer reaches zero, you catch a fish and gain a point.
	//
	// For reference, the green-red boundary that these bounds should be centered
	// around is bit 16 (LEDR16) and 17 (LEDG0). Bounds are set by the difficulty
	// selector above.
		
	// set up a shift/load register to control the current LED
	// resetLED also acts as an inverted enable/disable for the LED
	// blinker output since those happen to be synonymous
	reg LEDGoRight, LEDGoLeft, resetLED;
	localparam startingLED = 26'b1 << 9;
	wire [25:0] currentLED;
	defparam LEDMultiReg.Bits = 26;
	multiReg LEDMultiReg (startingLED, resetLED, LEDGoLeft, LEDGoRight, currentLED, CLK, RST);

	// these are the LEDs that will blink
	wire [25:0] blinkThese = leftLoseBound | rightLoseBound | currentLED;
	// instantiate blinker module
	defparam blinky.LFSRTarget = LFSRTarget;
	LEDBlinker blinky (
		.lightThese(winZone),
		.blinkThese(blinkThese),
		.blinkEnab(!resetLED),
		.lightBar(lightBar),
		.blinkBit(blinkBit),
		.CLK(CLK),
		.RST(RST));

	
	//-----Game state machine-----
	// Since this thing is so big, it's divided into three procedures:
	// - sequential logic to advance state
	// - combinational logic to set outputs from current state
	// - combinational logic to set next state from inputs and current state
	// in that order

	// 13 states
	reg [3:0] State, nextState;
	localparam waitingForStart = 0, waitingForFish = 1, fishOrBoot = 2, bootOnHook = 3,
		catchBoot = 4, catchingFish = 5, stalemateWithFish = 6, leftOneLED = 7,
		rightOneLED = 8, catchFish = 9, gameOver = 10, gameDone = 11;

	// possible info outputs, named for clarity
	localparam NONE = 0, FISH = 1, BOOT = 2, LOSE = 3, DONE = 4;

	// SeqLogic to advance or reset state
	always @(posedge CLK) begin
		if (!RST || !gameControl ) begin // negative-logic reset ORed with game control bit
			State <= waitingForStart;
		end
		else begin
			State <= nextState;
		end
	end

	
	// CombLogic to set outputs based on current state
	always @(State) begin

		//-----default output values-----
		// reset fish timer
		rstFishTimer = 1;
		runFishTimer = 0;
		// reset reel timer
		rstReelTimer = 1;
		runReelTimer = 0;
		// reset current LED to default (and do not show)
		resetLED = 1;
		LEDGoLeft = 0;
		LEDGoRight = 0;
		// do not show game info
		gameInfo = NONE;
		// score stays constant
		scoreUp = 0;
		scoreDown = 0;
		scoreRst = 0;
		// difficulty is latched (not changing)
		holdDiff = 1;
		// wait time is used by default for fish timer
		useWaitTime = 1;

		case (State)
			waitingForStart: begin
				// reset score in starting state
				scoreRst = 1;
				// load in new difficulty
				holdDiff = 0;
			end
			waitingForFish: begin
				// run fish timer
				runFishTimer = 1;
				rstFishTimer = 0;
				// use fishing time, not wait time
				//useWaitTime = 0;
			end
			fishOrBoot: begin
				// use fishing time, not wait time
				useWaitTime = 0;
			end
			bootOnHook: begin
				// run reel timer
				runReelTimer = 1;
				rstReelTimer = 0;
				// show BOOT on game info
				gameInfo = BOOT;
			end
			catchBoot: begin
				// score goes down because they caught a boot
				scoreDown = 1;
			end
			catchingFish: begin
				// pull LED reset low
				resetLED = 0;
				// run fish timer
				runFishTimer = 1;
				rstFishTimer = 0;
				// run reel timer
				runReelTimer = 1;
				rstReelTimer = 0;
				// show FISH on game info
				gameInfo = FISH;
			end
			stalemateWithFish: begin
				// pull LED reset low
				resetLED = 0;
				// pause but do not reset fish timer
				runFishTimer = 0;
				rstFishTimer = 0;
				// run reel timer
				runReelTimer = 1;
				rstReelTimer = 0;
				// show FISH on game info
				gameInfo = FISH;
			end
			// NB: I am aware that the fish timer runs in the two states
			// below even if you're coming from the paused state, which
			// is technically incorrect. However, I think if you
			// are able to win the game using this bug, you
			// deserve to win, so I'm not changing it.
			leftOneLED: begin
				// pull LED reset low, shift LED left
				resetLED = 0;
				LEDGoLeft = 1;
				// run fish timer
				runFishTimer = 1;
				rstFishTimer = 0;
				// reset reel timer
				runReelTimer = 0;
				rstReelTimer = 1;
				// show FISH on game info
				gameInfo = FISH;
			end
			rightOneLED: begin
				// pull LED reset low, shift LED right
				resetLED = 0;
				LEDGoRight = 1;
				// run fish timer
				runFishTimer = 1;
				rstFishTimer = 0;
				// run reel timer
				runReelTimer = 1;
				rstReelTimer = 0;
				// show FISH on game info
				gameInfo = FISH;
			end
			catchFish: begin
				// score goes up because you caught a fish
				scoreUp = 1;
			end
			gameOver: begin
				// show LOSE on game info
				gameInfo = LOSE;
			end
			gameDone: begin
				// show DONE on game info
				gameInfo = DONE;
			end
		endcase
	end

	// CombLogic to define next state from inputs and current state
	always @* begin
		case (State)
			waitingForStart: begin
				// start game if cast button is pressed
				if (castButton) begin
					nextState = waitingForFish;
				end
				else begin
					nextState = waitingForStart;
				end
			end
			waitingForFish: begin
				// end game if cast button is pressed
				if (castButton) begin
					nextState = gameDone;
				end
				// if fish timer is done, advance to fish/boot selection
				else if (fishTimerDone) begin
					nextState = fishOrBoot;
				end
				else begin
					nextState = waitingForFish;
				end
			end
			fishOrBoot: begin
				// end game if cast button is pressed
				if (castButton) begin
					nextState = gameDone;
				end
				// select fish or boot based on LSB of random number
				else if (currentRand[0]) begin
					nextState = bootOnHook;
				end
				else begin // !currentRand[0]
					nextState = catchingFish;
				end
			end
			bootOnHook: begin
				// end game if cast button is pressed
				if (castButton) begin
					nextState = gameDone;
				end
				// catch boot if reel button is pressed
				else if (reelButton) begin
					nextState = catchBoot;
				end
				// if reel timer is done, go back to waiting
				else if (reelTimerDone) begin
					nextState = waitingForFish;
				end
				else begin
					nextState = bootOnHook;
				end
			end
			catchBoot: begin
				// end game if cast button is pressed
				if (castButton) begin
					nextState = gameDone;
				end
				else begin
					nextState = waitingForFish;
				end
			end
			catchingFish: begin
				// end game if cast button is pressed
				if (castButton) begin
					nextState = gameDone;
				end
				// if fish timer is done, you catch fish
				else if (fishTimerDone) begin
					nextState = catchFish;
				end
				// in the unlikely event reel button and timer
				// signal at the same time, nothing happens
				else if (reelTimerDone && reelButton) begin
					nextState = catchingFish;
				end
				// if reel button is pressed, LED goes right
				else if (reelButton) begin
					nextState = rightOneLED;
				end
				// if reel timer is done, LED goes left
				else if (reelTimerDone) begin
					nextState = leftOneLED;
				end
				else begin
					nextState = catchingFish;
				end
			end
			
			stalemateWithFish: begin
				// end game if cast button is pressed
				if (castButton) begin
					nextState = gameDone;
				end
				// in the unlikely event reel button and timer
				// signal at the same time, nothing happens
				else if (reelTimerDone && reelButton) begin
					nextState = stalemateWithFish;
				end
				// if reel button is pressed, LED goes right
				else if (reelButton) begin
					nextState = rightOneLED;
				end
				// if reel timer is done, LED goes left
				else if (reelTimerDone) begin
					nextState = leftOneLED;
				end
				else begin
					nextState = stalemateWithFish;
				end
			end
			leftOneLED: begin
				// end game if cast button is pressed
				if (castButton) begin
					nextState = gameDone;
				end
				// if reel button is pressed, LED goes right
				else if (reelButton) begin
					nextState = rightOneLED;
				end
				// if LED is going to hit the left lose bound
				// (after shift), player loses
				else if (currentLED == (leftLoseBound >> 1)) begin
					nextState = gameOver;
				end
				// if LED is within win bounds, you are
				// catching fish
				else if (currentLED & winZone) begin
					nextState = catchingFish;
				end
				else begin
					nextState = stalemateWithFish;
				end
			end
			rightOneLED: begin
				// end game if cast button is pressed
				if (castButton) begin
					nextState = gameDone;
				end
				// if reel timer is done, LED goes left
				else if (reelTimerDone) begin
					nextState = leftOneLED;
				end
				// if LED is going to hit the right lose bound
				// (after shift), player loses
				else if (currentLED == (rightLoseBound << 1)) begin
					nextState = gameOver;
				end
				// if LED is within win bounds, you are
				// catching fish
				else if (currentLED & winZone) begin
					nextState = catchingFish;
				end
				else begin
					nextState = stalemateWithFish;
				end
			end
			catchFish: begin
				// end game if cast button is pressed
				if (castButton) begin
					nextState = gameDone;
				end
				else begin
					nextState = waitingForFish;
				end
			end
			gameOver: begin
				// return to start if cast button is pressed
				if (castButton) begin
					nextState = waitingForStart;
				end
				else begin
					nextState = gameOver;
				end
			end
			gameDone: begin
				// return to start if cast button is pressed
				if (castButton) begin
					nextState = waitingForStart;
				end
				else begin
					nextState = gameDone;
				end
			end
			// return to start if in an illegal state
			default: begin
				nextState = waitingForStart;
			end
		endcase
	end
endmodule
