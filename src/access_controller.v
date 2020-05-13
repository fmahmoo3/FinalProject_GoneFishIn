// ECE 5440
// Group: Gone Fishin'
// Module: access_controller

// This module will block inputs from all buttons except RST to ensure the game can not be triggered untill access is granted.
// To login, the player must enter a user id and password combination from the list below. This module will output the address
// in ROM so the score keeper can update the high score for the user that is logged in. This module will also interact with 
// decoder modules to enhance the user experience. If user ID is not valid, the player has unlimited attempts, as well if the
// password does not match the user ID, the player as unlimited attempts at the password without having to enter the user ID
// again.

// u/p setup:
// Fazal:   u=1-1-2-7, p=7-2-1-1-A, addr=0
// Jon:     u=2-8-4-9, p=9-4-8-2-B, addr=1
// George:  u=4-7-5-5, p=5-5-7-4-C, addr=2
// Nick:    u=2-3-8-9, p=9-8-3-2-D, addr=3
// Nathan:  u=5-1-9-8, p=8-9-1-5-E, addr=4
// Guest:   u=3-4-7-6, p=6-7-4-3-F, addr=5

module access_controller(
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

    // input variables
    input clk, rst, access_button_in, reel_button_in, game_start_button_in;
    input [3:0] access_switch;

    // output variables
    output reg validOut, access_button_out, reel_button_out, game_start_button_out;
    output reg [3:0] output_to_decoder, state_for_decoder;
    output reg [2:0] user_ID;

    // accessing User ROM
    reg [5:0] addr_user; // 6-bit wide
    wire [15:0] data_user; // 16-bit wide
    reg [15:0] user_ID_raw; // 16-bit wide

    // access Pass ROM
    reg	[5:0]  addr_pass; // 6-bit wide
	wire [19:0]  data_pass; // 20-bit wide
    reg [19:0] pass_raw; // 20-bit wide

    // 1 instances of ROM user retrieval module
    User_ROM romU(addr_user, clk, data_user);
    
    // 1 instances of ROM password retrieval module
    Password_ROM romP(addr_pass, clk, data_pass);

    // helper variables
    reg [4:0] state, state_callback;
    reg check_rom;
    integer clk_counter;
    // read 4 digits of user ID input
    parameter state_user_0 = 5'b00000, state_user_1 = 5'b00001;
    parameter state_user_2 = 5'b00010, state_user_3 = 5'b00011;
    // round robin 6 ROM address to find match for User ID
    parameter state_user_rom_0 = 5'b00100, state_user_rom_1 = 5'b00101;
    parameter state_user_rom_2 = 5'b00110, state_user_rom_3 = 5'b00111;
    parameter state_user_rom_4 = 5'b01000, state_user_rom_5 = 5'b01001;
    // read 5 digits of password input
    parameter state_pass_0 = 5'b01010, state_pass_1 = 5'b01011;
    parameter state_pass_2 = 5'b01100, state_pass_3 = 5'b01101;
    parameter state_pass_4 = 5'b01110;
    // no need to round robin, simiply check same addres that user_data was a match
    parameter state_pass_rom = 5'b01111;
    // wait for ROM to update Data with current addr value
    parameter state_wait_1 = 5'b10000, state_wait_2 = 5'b10001;
    // access granted
    parameter state_access_granted = 5'b10010;

    always @(posedge clk) begin
        if(rst == 0) begin
            validOut <= 0;
            user_ID <= 0;
            user_ID_raw <= 0;
            pass_raw <= 0;
            check_rom <= 0;
            access_button_out <= 0;
            reel_button_out <= 0;
            game_start_button_out <= 0;
            state_for_decoder <= 0;

            state <= state_user_0;
        end
        else begin
            case (state)
                /*----Waiting on ROM to update Data---*/
                state_wait_1: begin
                    state <= state_wait_2;
                end
                state_wait_2: begin
                    state <= state_callback;
                    check_rom <= 1;
                end


                /*----Reading in User ID Input---*/
                state_user_0: begin
                    validOut <= 0;
                    user_ID <= 0;
                    user_ID_raw = 0; // need to make this blocking
                    pass_raw <= 0;
                    check_rom <= 0;
                    access_button_out <= 0;
                    reel_button_out <= 0;
                    game_start_button_out <= 0;
                    
                    state_for_decoder <= 4'b0101;
                    output_to_decoder <= access_switch;
                    
                    if(access_button_in == 1) begin
                        user_ID_raw = user_ID_raw + access_switch;
                        user_ID_raw = user_ID_raw << 4; 
                        state = state_user_1;
                    end
                end
                state_user_1: begin
                    state_for_decoder <= 4'b0110;
                    output_to_decoder <= access_switch;

                    if(access_button_in == 1) begin
                        user_ID_raw = user_ID_raw + access_switch;
                        user_ID_raw = user_ID_raw << 4; 
                        state = state_user_2;
                    end
                end
                state_user_2: begin
                    state_for_decoder <= 4'b0111;
                    output_to_decoder <= access_switch;

                    if(access_button_in == 1) begin
                        user_ID_raw = user_ID_raw + access_switch;
                        user_ID_raw = user_ID_raw << 4; 
                        state = state_user_3;
                    end
                end
                state_user_3: begin
                    state_for_decoder <= 4'b1000;
                    output_to_decoder <= access_switch;

                    if(access_button_in == 1) begin
                        user_ID_raw = user_ID_raw + access_switch;
                        // no need to shift left since thats the final 4-bits in user ID
                        state = state_user_rom_0;
                    end
                end


                /*----Locating User ID in ROM---*/
                state_user_rom_0: begin
                    state_callback <= state_user_rom_0;
                    state <= state_wait_1;
                    addr_user <= 0;

                    if(check_rom == 1) begin
                        check_rom <= 0;
                        if(user_ID_raw == data_user) begin
                            // then we can go straight to reading password
                            user_ID <= addr_user;
                            state <= state_pass_0;
                        end
                        else begin
                            state <= state_user_rom_1;
                        end
                    end
                end
                state_user_rom_1: begin
                    state_callback <= state_user_rom_1;
                    state <= state_wait_1;
                    addr_user <= 1;

                    if(check_rom == 1) begin
                        check_rom <= 0;
                        if(user_ID_raw == data_user) begin
                            // then we can go straight to reading password
                            user_ID <= addr_user;
                            state <= state_pass_0;
                        end
                        else begin
                            state <= state_user_rom_2;
                        end
                    end
                end
                state_user_rom_2: begin
                    state_callback <= state_user_rom_2;
                    state <= state_wait_1;
                    addr_user <= 2;

                    if(check_rom == 1) begin
                        check_rom <= 0;
                        if(user_ID_raw == data_user) begin
                            // then we can go straight to reading password
                            user_ID <= addr_user;
                            state <= state_pass_0;
                        end
                        else begin
                            state <= state_user_rom_3;
                        end
                    end
                end
                state_user_rom_3: begin
                    state_callback <= state_user_rom_3;
                    state <= state_wait_1;
                    addr_user <= 3;

                    if(check_rom == 1) begin
                        check_rom <= 0;
                        if(user_ID_raw == data_user) begin
                            // then we can go straight to reading password
                            user_ID <= addr_user;
                            state <= state_pass_0;
                        end
                        else begin
                            state <= state_user_rom_4;
                        end
                    end
                end
                state_user_rom_4: begin
                    state_callback <= state_user_rom_4;
                    state <= state_wait_1;
                    addr_user <= 4;

                    if(check_rom == 1) begin
                        check_rom <= 0;
                        if(user_ID_raw == data_user) begin
                            // then we can go straight to reading password
                            user_ID <= addr_user;
                            state <= state_pass_0;
                        end
                        else begin
                            state <= state_user_rom_5;
                        end
                    end
                end
                state_user_rom_5: begin
                    state_callback <= state_user_rom_5;
                    state <= state_wait_1;
                    addr_user <= 5;

                    if(check_rom == 1) begin
                        check_rom <= 0;
                        if(user_ID_raw == data_user) begin
                            // then we can go straight to reading password
                            user_ID <= addr_user;
                            state <= state_pass_0;
                        end
                        else begin
                            // user ID does not match any ROM registers, go back to first user state
                            state <= state_user_0;
                        end
                    end
                end


                /*----Reading in Password Input---*/
                state_pass_0: begin
                    pass_raw = 0; // reset in case multiple password entries
                    state_for_decoder <= 4'b1001;
                    output_to_decoder <= access_switch;

                    if(access_button_in == 1) begin
                        pass_raw = pass_raw + access_switch;
                        pass_raw = pass_raw << 4; 
                        state = state_pass_1;
                    end
                end
                state_pass_1: begin
                    state_for_decoder <= 4'b1010;
                    output_to_decoder <= access_switch;

                    if(access_button_in == 1) begin
                        pass_raw = pass_raw + access_switch;
                        pass_raw = pass_raw << 4; 
                        state = state_pass_2;
                    end
                end
                state_pass_2: begin
                    state_for_decoder <= 4'b1011;
                    output_to_decoder <= access_switch;

                    if(access_button_in == 1) begin
                        pass_raw = pass_raw + access_switch;
                        pass_raw = pass_raw << 4; 
                        state = state_pass_3;
                    end
                end
                state_pass_3: begin
                    state_for_decoder <= 4'b1100;
                    output_to_decoder <= access_switch;

                    if(access_button_in == 1) begin
                        pass_raw = pass_raw + access_switch;
                        pass_raw = pass_raw << 4; 
                        state = state_pass_4;
                    end
                end
                state_pass_4: begin
                    state_for_decoder <= 4'b1101;
                    output_to_decoder <= access_switch;

                    if(access_button_in == 1) begin
                        pass_raw = pass_raw + access_switch;
                        // no need to shift left since thats the final 4-bits in pass
                        state = state_pass_rom;
                    end
                end


                /*----Determining if Password inputted matched in same ROM address as User ID---*/
                state_pass_rom: begin
                    state_callback <= state_pass_rom;
                    state <= state_wait_1;
                    addr_pass <= user_ID;

                    if(check_rom == 1) begin
                        check_rom <= 0;
                        if(pass_raw == data_pass) begin
                            // pass matched, grant access
                            state <= state_access_granted;
                        end
                        else begin
                            // pass did not match ROM, allow re-entering password
                            state <= state_pass_0;
                        end
                    end
                end


                /*----Granting access to remainder of system---*/
                state_access_granted: begin
                    validOut <= 1;
                    access_button_out <= access_button_in;
                    reel_button_out <= reel_button_in;
                    game_start_button_out <= game_start_button_in;
                    state_for_decoder <= 0;

                    /*----Looking for logout---*/
                    if(access_button_in == 1 && clk_counter > 0) begin
                        // logout!
                        clk_counter <= 0;
                        state <= state_user_0;
                    end
                    else if(access_button_in == 1 && clk_counter == 0) begin
                        // first button click
                        clk_counter <= clk_counter + 1;
                    end
                    else if(clk_counter == 12500000) begin //12.5M = 1/4 second
                        // if its been longer than .25 seconds, dont try to log out user
                        clk_counter <= 0;
                    end
                    else if(clk_counter > 0) begin
                        // if counter is increased (by first button click), keep increasing
                        clk_counter <= clk_counter + 1;
                    end
                end
            endcase
        end
    end
endmodule