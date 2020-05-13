// ECE 5440
// Group: Gone Fishin'
// Module: access_controller_tb

// This module will test access_controller by inputting an incorrect user ID, then correct user ID, then
// the incorrect password for the previously inputted user ID, and end by inputting the correct password for
// the user ID. For further testing options, the code to test all user IDs and their corresponding passwords 
// can be found commented below this module. Please make sure to activate rst, before trying new user ID and 
// password combinations as well as logout

// u/p setup:
// Fazal:   u=1-1-2-7, p=7-2-1-1-A, addr=0
// Jon:     u=2-8-4-9, p=9-4-8-2-B, addr=1
// George:  u=4-7-5-5, p=5-5-7-4-C, addr=2
// Nick:    u=2-3-8-9, p=9-8-3-2-D, addr=3
// Nathan:  u=5-1-9-8, p=8-9-1-5-E, addr=4
// Guest:   u=3-4-7-6, p=6-7-4-3-F, addr=5
`timescale 10ns/100ps

module access_controller_tb();
    reg clk, rst, access_button_in, reel_button_in, game_start_button_in;
    reg [3:0] access_switch;
    reg flag;

    wire validOut, access_button_out, reel_button_out, game_start_button_out;
    wire [3:0] output_to_decoder, state_for_decoder;
    wire [2:0] user_ID;

    access_controller ac_DUT(
    // sequential logic variables
    clk, rst, 
    // password digit switch input
    access_switch, 
    // user input buttons
    access_button_in, reel_button_in, game_start_button_in,
    // output LED/ game controller trigger variable
    validOut,
    // output to 7-seg decoder
    state_for_decoder, output_to_decoder,
    // output button's based on access state
    access_button_out, reel_button_out, game_start_button_out,
    // output user ID to score keeper
    user_ID);

    always begin
        #10 clk = 1;
        #10 clk = 0;
    end

    initial begin
        access_button_in <= 0;
        access_switch <= 4'b0000;
        reel_button_in <= 1;
        game_start_button_in <= 1;
        flag <= 0;

        @(posedge clk);
        rst <= 0;
        @(posedge clk);
        rst <= 1;
        @(posedge clk);


        /* inputing INCORRECT user ID 1*/
        #5 access_button_in <= 1;
        access_switch <= 1;
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #5 access_button_in <= 1;
        access_switch <= 1;
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #5 access_button_in <= 1;
        access_switch <= 2;
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #5 access_button_in <= 1;
        access_switch <= 8;
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #800;


        /* inputing CORRECT user ID 1*/
        #5 access_button_in <= 1;
        access_switch <= 1;
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #5 access_button_in <= 1;
        access_switch <= 1;
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #5 access_button_in <= 1;
        access_switch <= 2;
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #5 access_button_in <= 1;
        access_switch <= 7;
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #800;


        /* inputing INCORRECT password for user ID 1*/
        #5 access_button_in <= 1;
        access_switch <= 7;
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #5 access_button_in <= 1;
        access_switch <= 2;
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #5 access_button_in <= 1;
        access_switch <= 1;
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #5 access_button_in <= 1;
        access_switch <= 1;
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #5 access_button_in <= 1;
        access_switch <= 11; // "B"
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #800;


        /* inputing CORRECT password for user ID 1*/
        #5 access_button_in <= 1;
        access_switch <= 7;
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #5 access_button_in <= 1;
        access_switch <= 2;
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #5 access_button_in <= 1;
        access_switch <= 1;
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #5 access_button_in <= 1;
        access_switch <= 1;
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #5 access_button_in <= 1;
        access_switch <= 10; // "A"
        @(posedge clk);
        #5 access_button_in <= 0;
        @(posedge clk);

        #800;

        /* simulating a logout but its NOT quick enough */
        // first button
        @(posedge clk);
        #5 access_button_in <= 1;
        @(posedge clk);
        #5 access_button_in <= 0;

        // wait longer than .25 seconds
        flag <= 1;
        #2000;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        flag <= 0;

        // second button press
        @(posedge clk);
        #5 access_button_in <= 1;
        @(posedge clk);
        #5 access_button_in <= 0;

        #3000;

        /* simulating a logout */
        // first button
        @(posedge clk);
        #5 access_button_in <= 1;
        @(posedge clk);
        #5 access_button_in <= 0;

        // NOT waiting longer than .25 seconds
        flag <= 1;
        #1960;
        flag <= 0;

        // second button press
        @(posedge clk);
        #5 access_button_in <= 1;
        @(posedge clk);
        #5 access_button_in <= 0;

    end
endmodule

//      
        // /* inputing INCORRECT user ID 1*/
        // #5 access_button_in <= 1;
        // access_switch <= 1;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 1;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 2;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 8;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #800;
        /* inputing user ID 2*/
        // @(posedge clk);
        // rst <= 0;
        // @(posedge clk);
        // rst <= 1;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 2;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 8;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 4;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 9;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #800;

        // /* inputing user ID 3*/
        // @(posedge clk);
        // rst <= 0;
        // @(posedge clk);
        // rst <= 1;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 4;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 7;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 5;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 5;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #800;

        // /* inputing user ID 4*/
        // @(posedge clk);
        // rst <= 0;
        // @(posedge clk);
        // rst <= 1;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 2;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 3;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 8;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 9;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #800;

        // /* inputing user ID 5*/
        // @(posedge clk);
        // rst <= 0;
        // @(posedge clk);
        // rst <= 1;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 5;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 1;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 9;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 8;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #800;

        // /* inputing user ID 6*/
        // @(posedge clk);
        // rst <= 0;
        // @(posedge clk);
        // rst <= 1;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 3;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 4;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 7;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #5 access_button_in <= 1;
        // access_switch <= 6;
        // @(posedge clk);
        // #5 access_button_in <= 0;
        // @(posedge clk);

        // #800;