// ECE 5440
// Group: Gone Fishin'
// Module: Countdown timer
//
// This module implements a decimal-valued timer with a resolution of 1 ms and
// parameterized number of digits. Each digit is represented at both the input
// and the output as a 4-bit hex number. The core 1 ms counter is implemented
// using a 16-bit LFSR.
//
// Note: LSD = least sig. digit, MSD = most sig. digit 

module countdownTimer (StartValue, Restart, Run, CurrentValue, TimerDone, CLK, RST);
	
	// number of decimal digits (starting from .001) to instantiate
	// minimum 2 for proper functioning
	parameter Digits = 5; // 5 digits is decimal xx.xxx

	// target value for LFSR, i.e. the LFSR value corresponding to the
	// number of clock cycles in 1 ms for your system, minus two
	// the LFSR is a 16-bit Xorshift with triplet [7, 9, 8] and seed 'hFFFF
	parameter LFSRTarget = 16'h9CED; // counter value 49999998 (50 MHz clock)

	// value to count down from
	// each 4-bit chunk represents one decimal value 0-9
	// MSD on the left, LSD (1 ms) on the right
	input [Digits*4-1:0] StartValue;

	// this bit holds the timer in the waiting state while it is high
	// takes priority over the run bit
	input Restart;

	// the timer will run when this bit is high
	// if it is pulled low without a restart, the timer will pause
	input Run;

	// current value of the timer
	// format is same as StartValue
	output [Digits*4-1:0] CurrentValue;
	// we need to see the current value within the module
	wire [Digits*4-1:0] currentTime;
	assign CurrentValue = currentTime;

	// bit indicating timer is done
	// tied to the highest overflow bit
	output TimerDone;
	reg TimerDone;

	// internal nets controlling biDirBCD modules
	reg countBit, setBit;

	// internal nets controlling LFSR module
	reg runLFSR, restartLFSR;

	// current value of the LFSR
	wire [15:0] shiftRegValue;

	// system clock and reset signals
	input CLK, RST;
	
	// internal nets to link BCDs
	// bottom carry in is tied to countBit
	wire [Digits-1:0] counterCarry;

	// generate block for BCD chain
	genvar d;
	generate
		for (d = 0; d < Digits; d = d + 1) begin: counters
			wire count;
			if (d == 0) begin
				// external control bit for LSD
				assign count = countBit;
			end
			else begin
				// internal linking net for all others
				assign count = counterCarry[d-1];
			end
			
			// all counters counting down
			defparam Digit.Direction = 0;
			biDirBCD Digit (
				.Count(count),
				.SetValue(StartValue[(d+1)*4-1:d*4]),
				.Set(setBit),
				.OutValue(currentTime[(d+1)*4-1:d*4]),
				.CarryOut(counterCarry[d]),
				.CLK(CLK),
				.RST(RST));
		end
	endgenerate

	// instantiate LFSR module to do 1ms count
	LFSR16 shiftReg (restartLFSR, runLFSR, shiftRegValue, CLK, RST);
	
	// states for state machine
	localparam waiting = 0, running = 1, counting = 2, paused = 3, timeout = 4;
	reg [2:0] State;
	reg [2:0] nextState;

	// CombLogic to set outputs and next state from current one
	always @(State, Run, Restart, shiftRegValue, currentTime) begin
	       case (State)
		       waiting: begin
			       TimerDone = 0;
			       // BCDs accept starting value inputs
			       countBit = 0;
			       setBit = 1;
			       // LFSR stopped
			       runLFSR = 0;
			       restartLFSR = 1;
			       // start timer if Run is asserted
			       if (Run) begin
				       nextState = running;
			       end
			       else begin
				       nextState = waiting;
			       end
		       end
		       running: begin
			       TimerDone = 0;
			       // BCDs do not change
			       countBit = 0;
			       setBit = 0;
			       // LFSR is counting
			       runLFSR = 1;
			       restartLFSR = 0;
			       if (Restart) begin 
				       nextState = waiting;
			       end
			       // Check for 1 ms timeout
			       else if (shiftRegValue == LFSRTarget) begin
				       nextState = counting;
			       end
			       else if (!Run) begin
				       nextState = paused;
			       end
			       else begin
				       nextState = running;
			       end
		       end
		       counting: begin
			       TimerDone = 0;
			       // decrement BCD chain
			       countBit = 1;
			       setBit = 0;
			       // restart LFSR
			       runLFSR = 0;
			       restartLFSR = 1;
			       // check for overall timeout
			       if (currentTime[Digits*4-1:4] == {Digits*4-5 {1'h0}} &&
				       currentTime[3:0] == 4'h1) begin
				       // time out if LSD is one and all
				       // others are zero
				       nextState = timeout;
			       end
			       else if (Restart) begin
				       nextState = waiting;
			       end
			       else if (!Run) begin
				       nextState = paused;
			       end
			       else begin
				       nextState = running;
			       end
		       end
		       paused: begin
			       TimerDone = 0;
			       // BCDs do not change
			       countBit = 0;
			       setBit = 0;
			       // LFSR is paused but not restarted
			       runLFSR = 0;
			       restartLFSR = 0;
			       if (Restart) begin
				       nextState = waiting;
			       end
			       // continue if Run bit is asserted again
			       else if (Run) begin
				       nextState = running;
			       end
			       else begin
				       nextState = paused;
			       end
		       end
		       timeout: begin
			       TimerDone = 1;
			       // BCDs do not change
			       countBit = 0;
			       setBit = 0;
			       // LFSR stopped
			       runLFSR = 0;
			       restartLFSR = 1;
			       // return to wait state if Restart is asserted
			    	nextState = waiting;
		       end
		       default: begin
			       // replicate default state outputs
			       TimerDone = 0;
			       countBit = 0;
			       setBit = 1;
			       runLFSR = 0;
			       restartLFSR = 1;

			       nextState = waiting;
		       end
	       endcase
	end

	// SeqLogic to set state
	always @(posedge CLK) begin
		if (!RST) begin // negative-logic reset asserted
			State <= waiting;
		end
		else begin
			State <= nextState;
		end
	end

endmodule

