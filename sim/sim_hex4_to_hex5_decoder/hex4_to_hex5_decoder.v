// ECE 5440
// Group: Gone Fishin'
// Module: hex4_to_hex5_decoder

// This module will control what is outputted to Hex 4 - Hex 5
// of the FPGA Board. When access is not granted, this module
// will output "--".
// When access is granted and game has not started, this module 
// will display the high score for each user in a round robin fashion while
// another module will display the associated user ID. When 
// the game has started and access is granted, this module will 
// simply display the current game score.

module hex4_to_hex5_decoder(
    // sequential logic variables
    clk, rst, 
    // access button
    ac_button,
    // FSM variables
    userID, currentGameScore, access_granted, scoreRst,
    // Inputs from RAM Controller
    scoreUserAddr0, scoreUserAddr1, scoreUserAddr2, scoreUserAddr3, scoreUserAddr4, scoreUserAddr5,
    // 7-seg outputs
    hex4_out, hex5_out);

    // input variables
    input clk, rst, access_granted, scoreRst, ac_button;
    input [2:0] userID;
    input [7:0] currentGameScore, scoreUserAddr0, scoreUserAddr1, scoreUserAddr2, scoreUserAddr3, scoreUserAddr4, scoreUserAddr5;

    // output variables
    output reg [6:0] hex4_out, hex5_out;

    // 2 instance of 7-Seg module
    reg [3:0] in_7_seg_1, in_7_seg_2;
    wire [6:0] out_7_seg_1, out_7_seg_2;
    SevenSeg ss1(in_7_seg_1, out_7_seg_1);
    SevenSeg ss2(in_7_seg_2, out_7_seg_2);
    
    // read 4 digits of user ID input
    reg [2:0] state_disp_user_ram_score;
    parameter state_disp_user_ram_score_0 = 3'b000, state_disp_user_ram_score_1 = 3'b001;
    parameter state_disp_user_ram_score_2 = 3'b010, state_disp_user_ram_score_3 = 3'b011;
    parameter state_disp_user_ram_score_4 = 3'b100, state_disp_user_ram_score_5 = 3'b101;

    always @(posedge clk) begin
        if(rst  == 1'b0) begin
            /* if rst pressed, do not display anything and set internal state to 1st user ID */
            hex4_out <= 7'b1111111; // off
            hex5_out <= 7'b1111111; // off
            state_disp_user_ram_score <= state_disp_user_ram_score_0;
        end
        else begin
            if(access_granted == 1'b1 && scoreRst == 1'b1) begin
                /* game not started yet and user authenticated so round robin thru user ram score's */
                case (state_disp_user_ram_score)
                    state_disp_user_ram_score_0: begin
                        if(ac_button == 1) begin
                            state_disp_user_ram_score <= state_disp_user_ram_score_1;
                        end
                        else begin
                            in_7_seg_1 = scoreUserAddr0[3:0];
                            in_7_seg_2 = scoreUserAddr0[7:4];
                            hex4_out = out_7_seg_1;
                            hex5_out = out_7_seg_2;
                        end
                    end
                    
                    state_disp_user_ram_score_1: begin
                        if(ac_button == 1) begin
                            state_disp_user_ram_score <= state_disp_user_ram_score_2;
                        end
                        else begin
                            in_7_seg_1 = scoreUserAddr1[3:0];
                            in_7_seg_2 = scoreUserAddr1[7:4];
                            hex4_out = out_7_seg_1;
                            hex5_out = out_7_seg_2;
                        end
                    end
                    
                    state_disp_user_ram_score_2: begin
                        if(ac_button == 1) begin
                            state_disp_user_ram_score <= state_disp_user_ram_score_3;
                        end
                        else begin
                            in_7_seg_1 = scoreUserAddr2[3:0];
                            in_7_seg_2 = scoreUserAddr2[7:4];
                            hex4_out = out_7_seg_1;
                            hex5_out = out_7_seg_2;
                        end
                    end
                    
                    state_disp_user_ram_score_3: begin
                        if(ac_button == 1) begin
                            state_disp_user_ram_score <= state_disp_user_ram_score_4;
                        end
                        else begin
                            in_7_seg_1 = scoreUserAddr3[3:0];
                            in_7_seg_2 = scoreUserAddr3[7:4];
                            hex4_out = out_7_seg_1;
                            hex5_out = out_7_seg_2;
                        end
                    end
                    
                    state_disp_user_ram_score_4: begin
                        if(ac_button == 1) begin
                            state_disp_user_ram_score <= state_disp_user_ram_score_5;
                        end
                        else begin
                            in_7_seg_1 = scoreUserAddr4[3:0];
                            in_7_seg_2 = scoreUserAddr4[7:4];
                            hex4_out = out_7_seg_1;
                            hex5_out = out_7_seg_2;
                        end
                    end
                    
                    state_disp_user_ram_score_5: begin
                        if(ac_button == 1) begin
                            state_disp_user_ram_score <= state_disp_user_ram_score_0;
                        end
                        else begin
                            in_7_seg_1 = scoreUserAddr5[3:0];
                            in_7_seg_2 = scoreUserAddr5[7:4];
                            hex4_out = out_7_seg_1;
                            hex5_out = out_7_seg_2;
                        end
                    end
                endcase
            end
            else if(access_granted == 1'b1) begin
                /* Game Started */

                // set display state to first user score
                state_disp_user_ram_score <= state_disp_user_ram_score_0;

                in_7_seg_1 = currentGameScore[3:0];
                in_7_seg_2 = currentGameScore[7:4];
                hex4_out = out_7_seg_1;
                hex5_out = out_7_seg_2;
            end
            else begin
                /* Access is not granted */
                hex4_out <= 7'b0111111; // dash
                hex5_out <= 7'b0111111; // dash
                state_disp_user_ram_score <= state_disp_user_ram_score_0;
            end
        end
    end
endmodule