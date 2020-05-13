// ECE 5440
// Group: GoneFishin'
// Module: button_shaper

// This module will convert a push button that is active-low to active-high and only replicate a one cycle pulse when the 
// the button is pressed.

// Example:
// input: 
//                __                                  _____________
//      button_in:  |________________________________|
//                      ______        ______
//            clk:_____|      |______|      |______
// output: 
//                      ______________
//     button_out:_____|              |__________


module button_shaper (button_in, clk, rst, button_out);
    input button_in;
    output reg button_out;
    input clk, rst;

    parameter S_Init = 0, S_Pulse = 1, S_Wait = 2;

    reg [1:0] State, StateNext; // 2-bit
    
    // Sequential Logic (Procedure 1)
    always @(State, button_in) begin
        case (State)
            S_Init: begin
                // stay in this state until button intially pressed
                button_out <= 0;
                if(button_in == 0) begin
                    StateNext <= S_Pulse;
                end
                else begin
                    StateNext <= S_Init;
                end
            end
            S_Pulse: begin
                // stay in this state for 1 clk cycle
                button_out <= 1;
                StateNext <= S_Wait;
            end
            S_Wait: begin
                // stay in this state until button is released
                button_out <= 0;
                if(button_in == 0) begin
                    StateNext <= S_Wait;
                end
                else begin
                    StateNext <= S_Init;
                end
            end
        endcase                 
    end
    
    // StateReg (Procedure 2)
    always @(posedge clk) begin
        if (rst == 0) begin
            // if rst is click, go to intial state
            State <= S_Init;
        end
        else begin
            State <= StateNext;
        end
    end

endmodule
