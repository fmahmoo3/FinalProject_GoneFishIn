// ECE 5440
// Group: Gone Fishin'
// Module: Top Module

module FinalProject_GoneFishIn (
    // hardware inputs
    clk, rst, access_switch, access_button_unshapped, reel_button_unshapped, cast_button_unshapped,
    startingDiff,
    // hardware outpts
    access_green_led, hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7, lightBar);

    input clk, rst, access_button_unshapped, reel_button_unshapped, cast_button_unshapped;
    input [3:0] access_switch;
    input [2:0] startingDiff;

    output access_green_led;
    output [6:0] hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7;
    output [25:0] lightBar;

    wire access_button_shapped, reel_button_shapped, cast_button_shapped;
    wire [3:0] state_for_decoder, output_to_decoder;

    wire access_button_out, reel_button_out, cast_button_out;
    wire [3:0] user_ID;

    wire [7:0] currentScore, fishTimeDisp;
    wire [3:0] gameInfo;
    wire scoreDown, scoreUp, blinkBit, scoreRst;

    wire [7:0] scoreUserAddr0, scoreUserAddr1, scoreUserAddr2, scoreUserAddr3, scoreUserAddr4, scoreUserAddr5;

    button_shaper bs1(access_button_unshapped, clk, rst, access_button_shapped);
    button_shaper bs2(reel_button_unshapped, clk, rst, reel_button_shapped);
    button_shaper bs3(cast_button_unshapped, clk, rst, cast_button_shapped);

    access_controller ac(clk, rst, access_switch, access_button_shapped, reel_button_shapped, cast_button_shapped,
    access_green_led, state_for_decoder, output_to_decoder, access_button_out, reel_button_out, cast_button_out, user_ID);

    scorekeeper sk(clk, rst, scoreRst, scoreUp, scoreDown, currentScore);
    ramController rC(currentScore,gameInfo,scoreRst,user_ID,clk,rst,scoreUserAddr0, scoreUserAddr1,
    scoreUserAddr2, scoreUserAddr3, scoreUserAddr4, scoreUserAddr5);

    gameController gc(access_green_led, startingDiff, reel_button_out, cast_button_out, currentScore,
    scoreUp, scoreDown, scoreRst, lightBar, gameInfo, fishTimeDisp, blinkBit, clk, rst);
    
    hex0_to_hex3_decoder decoder(clk, rst, output_to_decoder, access_button_out, state_for_decoder, gameInfo, access_green_led, scoreRst, hex0, hex1, hex2, hex3);
    hex4_to_hex5_decoder decoder2(clk, rst, access_button_out, user_ID, currentScore, access_green_led, scoreRst, 
    scoreUserAddr0, scoreUserAddr1, scoreUserAddr2, scoreUserAddr3, scoreUserAddr4, scoreUserAddr5, hex4, hex5);
    
    SevenSeg ss3(fishTimeDisp[3:0], hex6);
    SevenSeg ss4(fishTimeDisp[7:4], hex7);

endmodule
