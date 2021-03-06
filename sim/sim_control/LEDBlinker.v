// ECE 5440
// Group: Gone Fishin'
// Module: LED bar blinker
//
// This module controls the LED bar on the DE2-112 board (i.e. every LED except
// the one between the 7-segs) and selects LEDs to a) turn on and b) blink;
// the blinking is controlled by an internal timer. A blink bit is
// also made available as an output to control other blinking displays.

module LEDBlinker (lightThese, blinkThese, blinkEnab, lightBar, blinkBit, CLK, RST);

	// these LEDs will be lit
	input [25:0] lightThese;

	// these LEDs will blink
	// they will blink even if not selected above
	input [25:0] blinkThese;

	// LEDs will only be driven if this is high
	input blinkEnab;

	// light bar control output
	// gated with enable bit
	output [25:0] lightBar;
	reg [25:0] lightBarUngated;
	assign lightBar = blinkEnab ? lightBarUngated : 26'b0;

	// system clock and reset
	input CLK, RST;

	// blink output bit
	// tied to the (gated) state machine bit
	output blinkBit;
	reg blinkOn;
	assign blinkBit = blinkOn || !blinkEnab;

	// this timer controls the blinking rate
	// runs continuously
	wire timerDone; // timeout signal from timer
	parameter blinkTime = {4'h2, 4'h0, 4'h0}; // .200 sec
	parameter LFSRTarget = 16'h9CED; // target for 50 MHz clock
	defparam blinkTimer.Digits = 3; // up to .999 sec
	defparam blinkTimer.LFSRTarget = LFSRTarget;

	countdownTimer blinkTimer (
		.StartValue(blinkTime),
		.Restart(1'b0), // never restart (except for a RST)
		.Run(1'b1), // always run
		.CurrentValue(), // intentionally not connected
		.TimerDone(timerDone),
		.CLK(CLK),
		.RST(RST));

	// this is basically just a two state state machine
	// one state the blinking LEDs are off, the other they are on
	// the non blinking are on all the time
	
	always @(posedge CLK) begin

		if (!RST) begin // negative-logic reset
			blinkOn <= 0;
		end
		else begin
			case (blinkOn)
				// blinking LEDs off
				1'b0: begin
					lightBarUngated <= lightThese & ~blinkThese;
					if (timerDone) begin
						blinkOn <= 1'b1;
					end
					else begin
						blinkOn <= 1'b0;
					end
				end
				// blinking LEDs on
				1'b1: begin
					lightBarUngated <= lightThese | blinkThese;
					if (timerDone) begin
						blinkOn <= 1'b0;
					end
					else begin
						blinkOn <= 1'b1;
					end
				end
			endcase
		end
	end
endmodule

				
