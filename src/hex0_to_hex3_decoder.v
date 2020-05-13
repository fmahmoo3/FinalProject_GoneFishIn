// ECE 5440
// Group: Gone Fishin'
// Module: hex0_to_hex3_decoder

// This module will control what is outputted to Hex 0 - Hex 3
// of the FPGA Board. When access is not granted, this module
// will take input from access controller to display which order of the
// user ID or password is being inputted along with the actual switch value.
// When access is granted and game has not started, this module will display the User IDs
// in a round robin fashion while a seperate module will display the high score for the specific user ID
// shown by this module. When the game has started and access is granted, this module will 
// display output from the game controller guiding the user of the game

module hex0_to_hex3_decoder(
    // sequential logic variables
    clk, rst, 
    // switch_value for user ID and Password
    switch_val_in,
    // access controller button for roundrobin user id's
    ac_button,
    // FSM variables
    state_ac, state_gc, access_granted, scoreRst,
    // 7-seg outputs
    hex0_out, hex1_out, hex2_out, hex3_out);

    // input variables
    input clk, rst, access_granted, ac_button, scoreRst;
    input [3:0] switch_val_in, state_ac, state_gc;

    // output variables
    output reg [6:0] hex0_out, hex1_out, hex2_out, hex3_out;

    // helper variables
    parameter state_display_nothing = 4'b0000,  state_display_fish = 4'b0001;
    parameter state_display_boot = 4'b0010,  state_display_lose = 4'b0011, state_display_done = 4'b0100;
    parameter state_user_1 = 4'b0101, state_user_2 = 4'b0110, state_user_3 = 4'b0111, state_user_4 = 4'b1000;
    parameter state_pass_1 = 4'b1001, state_pass_2 = 4'b1010, state_pass_3 = 4'b1011, state_pass_4 = 4'b1100, state_pass_5 = 4'b1101;

    // 4 instance of 7-Seg module
    reg [3:0] in_7_seg_1, in_7_seg_2, in_7_seg_3, in_7_seg_4;
    wire [6:0] out_7_seg_1, out_7_seg_2, out_7_seg_3, out_7_seg_4;
    SevenSeg ss1(in_7_seg_1, out_7_seg_1);
    SevenSeg ss2(in_7_seg_2, out_7_seg_2);
    SevenSeg ss3(in_7_seg_3, out_7_seg_3);
    SevenSeg ss4(in_7_seg_4, out_7_seg_4);

    // accessing User ROM
    reg [5:0] addr_user; // 6-bit wide
    wire [15:0] data_user; // 16-bit wide
    reg [15:0] user_ID_raw; // 16-bit wide

    // 1 instances of ROM user retrieval module
    User_ROM romU(addr_user, clk, data_user);
    
    // read 4 digits of user ID input
    reg [2:0] state_disp_user_id, state_callback;
    reg check_rom;
    parameter state_disp_user_id_0 = 3'b000, state_disp_user_id_1 = 3'b001;
    parameter state_disp_user_id_2 = 3'b010, state_disp_user_id_3 = 3'b011;
    parameter state_disp_user_id_4 = 3'b100, state_disp_user_id_5 = 3'b101;
    // wait for ROM to update Data with current addr value
    parameter state_wait_1 = 3'b110, state_wait_2 = 3'b111;

    always @(posedge clk) begin
        if(rst  == 1'b0) begin
            /* if rst pressed, do not display anything and set internal state to 1st user ID */
            hex0_out <= 7'b1111111; // off
            hex1_out <= 7'b1111111; // off
            hex2_out <= 7'b1111111; // off
            hex3_out <= 7'b1111111; // off
            state_disp_user_id <= state_disp_user_id_0;
        end
        else begin
            if(access_granted == 1'b1 && scoreRst == 1'b1) begin
                /* game not started yet and user authenticated so round robin thru user ID's */
                case (state_disp_user_id)
                    /*----Waiting on ROM to update Data---*/
                    state_wait_1: begin
                        state_disp_user_id <= state_wait_2;
                    end
                    state_wait_2: begin
                        state_disp_user_id <= state_callback;
                        check_rom <= 1;
                    end

                    /*----Locating User ID in ROM---*/
                    state_disp_user_id_0: begin
                        if (check_rom == 0) begin
                            // since we stay in state while user is viewing, only run this if check_rom is low
                            state_callback <= state_disp_user_id_0;
                            state_disp_user_id <= state_wait_1;
                            addr_user <= 0;
                        end

                        if(ac_button == 1) begin
                            // display next user ID
                            state_disp_user_id <= state_disp_user_id_1;
                            check_rom <= 0;
                        end

                        if(check_rom == 1) begin
                            // then we set the displays to the values from ROM
                            in_7_seg_1 = data_user[3:0];
                            in_7_seg_2 = data_user[7:4];
                            in_7_seg_3 = data_user[11:8];
                            in_7_seg_4 = data_user[15:12];
                            hex0_out = out_7_seg_1;
                            hex1_out = out_7_seg_2;
                            hex2_out = out_7_seg_3;
                            hex3_out = out_7_seg_4;
                        end
                    end
                    
                    state_disp_user_id_1: begin
                        if (check_rom == 0) begin
                            // since we stay in state while user is viewing, only run this if check_rom is low
                            state_callback <= state_disp_user_id_1;
                            state_disp_user_id <= state_wait_1;
                            addr_user <= 1;
                        end

                        if(ac_button == 1) begin
                            // display next user ID
                            state_disp_user_id <= state_disp_user_id_2;
                            check_rom <= 0;
                        end

                        if(check_rom == 1) begin
                            // then we set the displays to the values from ROM
                            in_7_seg_1 = data_user[3:0];
                            in_7_seg_2 = data_user[7:4];
                            in_7_seg_3 = data_user[11:8];
                            in_7_seg_4 = data_user[15:12];
                            hex0_out = out_7_seg_1;
                            hex1_out = out_7_seg_2;
                            hex2_out = out_7_seg_3;
                            hex3_out = out_7_seg_4;
                        end
                    end
                    
                    state_disp_user_id_2: begin
                        if (check_rom == 0) begin
                            // since we stay in state while user is viewing, only run this if check_rom is low
                            state_callback <= state_disp_user_id_2;
                            state_disp_user_id <= state_wait_1;
                            addr_user <= 2;
                        end

                        if(ac_button == 1) begin
                            // display next user ID
                            state_disp_user_id <= state_disp_user_id_3;
                            check_rom <= 0;
                        end

                        if(check_rom == 1) begin
                            // then we set the displays to the values from ROM
                            in_7_seg_1 = data_user[3:0];
                            in_7_seg_2 = data_user[7:4];
                            in_7_seg_3 = data_user[11:8];
                            in_7_seg_4 = data_user[15:12];
                            hex0_out = out_7_seg_1;
                            hex1_out = out_7_seg_2;
                            hex2_out = out_7_seg_3;
                            hex3_out = out_7_seg_4;
                        end
                    end
                    
                    state_disp_user_id_3: begin
                        if (check_rom == 0) begin
                            // since we stay in state while user is viewing, only run this if check_rom is low
                            state_callback <= state_disp_user_id_3;
                            state_disp_user_id <= state_wait_1;
                            addr_user <= 3;
                        end

                        if(ac_button == 1) begin
                            // display next user ID
                            state_disp_user_id <= state_disp_user_id_4;
                            check_rom <= 0;
                        end

                        if(check_rom == 1) begin
                            // then we set the displays to the values from ROM
                            in_7_seg_1 = data_user[3:0];
                            in_7_seg_2 = data_user[7:4];
                            in_7_seg_3 = data_user[11:8];
                            in_7_seg_4 = data_user[15:12];
                            hex0_out = out_7_seg_1;
                            hex1_out = out_7_seg_2;
                            hex2_out = out_7_seg_3;
                            hex3_out = out_7_seg_4;
                        end
                    end
                    
                    state_disp_user_id_4: begin
                        if (check_rom == 0) begin
                            // since we stay in state while user is viewing, only run this if check_rom is low
                            state_callback <= state_disp_user_id_4;
                            state_disp_user_id <= state_wait_1;
                            addr_user <= 4;
                        end

                        if(ac_button == 1) begin
                            // display next user ID
                            state_disp_user_id <= state_disp_user_id_5;
                            check_rom <= 0;
                        end

                        if(check_rom == 1) begin
                            // then we set the displays to the values from ROM
                            in_7_seg_1 = data_user[3:0];
                            in_7_seg_2 = data_user[7:4];
                            in_7_seg_3 = data_user[11:8];
                            in_7_seg_4 = data_user[15:12];
                            hex0_out = out_7_seg_1;
                            hex1_out = out_7_seg_2;
                            hex2_out = out_7_seg_3;
                            hex3_out = out_7_seg_4;
                        end
                    end
                    
                    state_disp_user_id_5: begin
                        if (check_rom == 0) begin
                            // since we stay in state while user is viewing, only run this if check_rom is low
                            state_callback <= state_disp_user_id_5;
                            state_disp_user_id <= state_wait_1;
                            addr_user <= 5;
                        end

                        if(ac_button == 1) begin
                            // display next user ID
                            state_disp_user_id <= state_disp_user_id_0;
                            check_rom <= 0;
                        end

                        if(check_rom == 1) begin
                            // then we set the displays to the values from ROM
                            in_7_seg_1 = data_user[3:0];
                            in_7_seg_2 = data_user[7:4];
                            in_7_seg_3 = data_user[11:8];
                            in_7_seg_4 = data_user[15:12];
                            hex0_out = out_7_seg_1;
                            hex1_out = out_7_seg_2;
                            hex2_out = out_7_seg_3;
                            hex3_out = out_7_seg_4;
                        end
                    end
                endcase
            end
            else if(access_granted == 1'b1) begin
                state_disp_user_id <= state_disp_user_id_0;
                check_rom <= 0;

                case (state_gc)
                    state_display_nothing: begin
                        hex0_out <= 7'b1111111; // off
                        hex1_out <= 7'b1111111; // off
                        hex2_out <= 7'b1111111; // off
                        hex3_out <= 7'b1111111; // off
                    end
                    state_display_fish: begin
                        hex0_out <= 7'b0001001; // "H"
                        hex1_out <= 7'b0010010; // "S"
                        hex2_out <= 7'b1111001; // "I"
                        hex3_out <= 7'b0001110; // "F"
                    end
                    state_display_boot: begin
                        hex0_out <= 7'b0000111; // "t"
                        hex1_out <= 7'b1000000; // "O"
                        hex2_out <= 7'b1000000; // "O"
                        hex3_out <= 7'b0000011; // "b"
                    end
                    state_display_lose: begin
                        hex0_out <= 7'b0000110; // "E"
                        hex1_out <= 7'b0010010; // "S"
                        hex2_out <= 7'b1000000; // "O"
                        hex3_out <= 7'b1000111; // "L"
                    end
                    state_display_done: begin
                        hex0_out <= 7'b0000110; // "E"
                        hex1_out <= 7'b0101011; // "n"
                        hex2_out <= 7'b1000000; // "O"
                        hex3_out <= 7'b0100001; // "d"
                    end
                endcase
            end
            else begin
                /* Access is not granted */
                
                state_disp_user_id <= state_disp_user_id_0;
                check_rom <= 0;

                // the switch value will always be displayed on hex0 when access is not granted
                in_7_seg_2 = switch_val_in;
                hex0_out = out_7_seg_2;

                // hex1 will be blank when access is not granted
                hex1_out <= 7'b1111111; // off

                if(state_ac < 4'b1001) begin
                    // if access controller is loading user values
                    hex3_out <= 7'b1000001; // "U"

                    in_7_seg_1 = state_ac - 4'b0100;
                    hex2_out = out_7_seg_1;
                end
                else begin
                    // if access controller is loading password values
                    hex3_out <= 7'b0001100; // "P"

                    in_7_seg_1 = state_ac - 4'b1000;
                    hex2_out = out_7_seg_1;
                end
            end
        end
    end
endmodule