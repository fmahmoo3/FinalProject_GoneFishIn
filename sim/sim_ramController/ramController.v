// ECE 5440
// Group: Gone Fishin'
// Module: ramController
/*
This module controlls the RAM. When reset is pressed, it initializes the RAM to all 0s.
Then, if the game is over and the score isn't being reset, it writes the current score
to the current user's address in RAM. Otherwise, it constantly outputs the score of the
current user.
*/

module ramController(currScore, gc_State, scoreRst, userID, clk, rst,
scoreUserAddr0, scoreUserAddr1, scoreUserAddr2, scoreUserAddr3, scoreUserAddr4, scoreUserAddr5);
    input scoreRst,clk,rst;
    input [7:0] currScore;
    input [2:0] userID;
    input [3:0] gc_State;

    output reg [7:0] scoreUserAddr0, scoreUserAddr1, scoreUserAddr2, scoreUserAddr3, scoreUserAddr4, scoreUserAddr5;

    reg flag_ram_init,wr;
    reg [4:0] addr;
    reg [7:0] ram_data_in;
    wire [7:0] ram_data_out;

    ram scores(addr, clk, ram_data_in, wr, ram_data_out);

    always@(posedge clk) begin
        if(rst == 1'b0) begin
            scoreUserAddr0 = 0;
            scoreUserAddr1 = 0;
            scoreUserAddr2 = 0;
            scoreUserAddr3 = 0;
            scoreUserAddr4 = 0;
            scoreUserAddr5 = 0;

            flag_ram_init = 1'b0;
            addr = 5'b00000;
            wr = 1'b1;    //write = 1 and read = 0
            ram_data_in = 8'b00000000;
        end
        else begin
            if(flag_ram_init == 1'b0) begin    //reset RAM
                wr = 1'b1;
                addr = addr + 5'b00001;
                ram_data_in = 8'b00000000;
                if(addr == 5'b00110)    //initialize the first 6 addresses (which are the only ones that'll be used)
                    flag_ram_init = 1'b1;    //done resetting
            end
            else begin
                addr[0] = userID[0];
                addr[1] = userID[1];
                addr[2] = userID[2];
                addr[3] = 0;
                addr[4] = 0;
                if( ((gc_State == 4'b0100) || (gc_State == 4'b0011)) && !scoreRst && currScore > ram_data_out) begin    
                    //write score when game is over and the score wasn't reset
                    wr = 1'b1;
                    ram_data_in = currScore;

                    case (userID)
                        3'b000: scoreUserAddr0 = currScore;
                        3'b001: scoreUserAddr1 = currScore;
                        3'b010: scoreUserAddr2 = currScore;
                        3'b011: scoreUserAddr3 = currScore;
                        3'b100: scoreUserAddr4 = currScore;
                        3'b101: scoreUserAddr5 = currScore;
                    endcase
                end
                else begin
                    wr = 1'b0;    //otherwise, output the score that corresponds with the current userID
                end
            end
        end
    end
endmodule

