// ECE 5440
// Group: Gone Fishin'
// Module: Value randomizer
//
// This module takes an arbitrary-width base number input and a 16-bit random number input
// and randomizes the base number (output same width as base input).

module valueRandomizer (baseValue, randomNumber, randomizedValue, CLK, RST);

	// bit width of the baseValue input and randomizedValue output
	parameter baseWidth = 16;

	// max changed bit
	

	// value to be randomized
	input [baseWidth - 1:0] baseValue;
	
