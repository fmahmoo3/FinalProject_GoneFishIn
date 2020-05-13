// ECE 5440
// Group: Gone Fishin'
// Module: hex0_to_hex3_decoder_tb

// This module will test the operations of the hex0_to_hex3_decoder module
// by testing when access is not granted, access is granted but game has not started,
// and when access is granted and game has started

`timescale 10ns/100ps

module hex0_to_hex3_decoder_tb();
    reg clk, rst, scoreRst, access_button_out, access_granted;
    reg [3:0] state_ac, state_gc, switch_value;

    wire [6:0] hex0_out, hex1_out, hex2_out, hex3_out;

    hex0_to_hex3_decoder decoder_DUT(
    // sequential logic variables
    clk, rst, 
    // switch_value for user ID and Password
    switch_value,
    // access controller button for roundrobin user id's
    access_button_out,
    // FSM variables
    state_ac, state_gc, access_granted, scoreRst,
    // 7-seg outputs
    hex0_out, hex1_out, hex2_out, hex3_out);

    
    parameter state_display_nothing = 4'b0000,  state_display_fish = 4'b0001;
    parameter state_display_boot = 4'b0010,  state_display_lose = 4'b0011, state_display_done = 4'b0100;
    parameter state_user_1 = 4'b0101, state_user_2 = 4'b0110, state_user_3 = 4'b0111, state_user_4 = 4'b1000;
    parameter state_pass_1 = 4'b1001, state_pass_2 = 4'b1010, state_pass_3 = 4'b1011, state_pass_4 = 4'b1100, state_pass_5 = 4'b1101;

    always begin
        #10 clk = 1;
        #10 clk = 0;
    end

    initial begin
        /* Start by reseting module */
        @(posedge clk);
        rst <= 0;
        @(posedge clk);
        rst <= 1;
        @(posedge clk);

        /* Start by displaying access controller states */
        @(posedge clk);
        #5;
        switch_value <= 4'b0101;
        access_granted <= 1'b0;
        scoreRst <= 1'b1;

        @(posedge clk);
        state_ac <= state_user_1;
        @(posedge clk);
        state_ac <= state_user_2;
        @(posedge clk);
        state_ac <= state_user_3;
        @(posedge clk);
        state_ac <= state_user_4;
        @(posedge clk);
        state_ac <= state_pass_1;
        @(posedge clk);
        state_ac <= state_pass_2;
        @(posedge clk);
        state_ac <= state_pass_3;
        @(posedge clk);
        state_ac <= state_pass_4;
        @(posedge clk);
        state_ac <= state_pass_5;

        @(posedge clk);
        #5 access_granted <= 1'b1;

        #100;

        /* round robin through all user IDs 2x */
        #5 access_button_out <= 1;
        @(posedge clk);
        #5 access_button_out <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 access_button_out <= 1;
        @(posedge clk);
        #5 access_button_out <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 access_button_out <= 1;
        @(posedge clk);
        #5 access_button_out <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 access_button_out <= 1;
        @(posedge clk);
        #5 access_button_out <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 access_button_out <= 1;
        @(posedge clk);
        #5 access_button_out <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 access_button_out <= 1;
        @(posedge clk);
        #5 access_button_out <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        
        #5 access_button_out <= 1;
        @(posedge clk);
        #5 access_button_out <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 access_button_out <= 1;
        @(posedge clk);
        #5 access_button_out <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 access_button_out <= 1;
        @(posedge clk);
        #5 access_button_out <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 access_button_out <= 1;
        @(posedge clk);
        #5 access_button_out <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 access_button_out <= 1;
        @(posedge clk);
        #5 access_button_out <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 access_button_out <= 1;
        @(posedge clk);
        #5 access_button_out <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        @(posedge clk);
        #5 scoreRst <= 1'b0;

        #100;

        @(posedge clk);
        state_gc <= state_display_nothing;
        @(posedge clk);
        state_gc <= state_gc + 1;
        @(posedge clk);
        state_gc <= state_gc + 1;
        @(posedge clk);
        state_gc <= state_gc + 1;

    end
endmodule