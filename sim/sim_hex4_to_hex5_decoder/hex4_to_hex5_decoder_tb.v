// ECE 5440
// Group: Gone Fishin'
// Module: hex4_to_hex5_decoder_tb

// This module will test the operations of the hex4_to_hex5_decoder module
// by testing when access is not granted, access is granted but game has not started,
// and when access is granted and game has started

`timescale 10ns/100ps

module hex4_to_hex5_decoder_tb();
    reg clk, rst, access_granted, scoreRst, ac_button;
    reg [2:0] userID;
    reg [7:0] currentGameScore, currentUserScoreFromRam;

    wire [6:0] hex4_out, hex5_out;

    hex4_to_hex5_decoder decoder(
    // sequential logic variables
    clk, rst, 
    // access button
    ac_button,
    // FSM variables
    userID, currentGameScore, currentUserScoreFromRam, access_granted, scoreRst,
    // 7-seg outputs
    hex4_out, hex5_out);

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

        /* Start by displaying "--" */
        @(posedge clk);
        #5;
        access_granted <= 1'b0;
        scoreRst <= 1'b1;

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        @(posedge clk);
        #5 access_granted <= 1'b1;

        #100;

        /* round robin through all user scores 2x */
        userID <= 3'b010;
        currentUserScoreFromRam <= 8'b00100100;
        #5 ac_button <= 1;
        @(posedge clk);
        #5 ac_button <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 ac_button <= 1;
        @(posedge clk);
        #5 ac_button <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 ac_button <= 1;
        @(posedge clk);
        #5 ac_button <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 ac_button <= 1;
        @(posedge clk);
        #5 ac_button <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 ac_button <= 1;
        @(posedge clk);
        #5 ac_button <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 ac_button <= 1;
        @(posedge clk);
        #5 ac_button <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        
        #5 ac_button <= 1;
        @(posedge clk);
        #5 ac_button <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 ac_button <= 1;
        @(posedge clk);
        #5 ac_button <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 ac_button <= 1;
        @(posedge clk);
        #5 ac_button <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 ac_button <= 1;
        @(posedge clk);
        #5 ac_button <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 ac_button <= 1;
        @(posedge clk);
        #5 ac_button <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        #5 ac_button <= 1;
        @(posedge clk);
        #5 ac_button <= 0;
        @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        @(posedge clk);
        #5 scoreRst <= 1'b0;

        #100;

        @(posedge clk);
        currentGameScore <= 8'b00100100;
        @(posedge clk);
        currentGameScore <= currentGameScore + 1;
        @(posedge clk);
        currentGameScore <= currentGameScore + 1;
        @(posedge clk);
        currentGameScore <= currentGameScore + 1;

    end
endmodule