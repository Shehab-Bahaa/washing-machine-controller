/*
Project        : Controller Unit For a Washing Machine 
Standard doc.  : 
Module name    : 
Dependancy     :
Design doc.    : 
References     : 
Description    : 
Owner          : Shehab Bahaa
*/
module washing_machine_controller (
        input rst_n,    // Active low asynchronous clock
        input clk,      // System clock

        input [1:0] clk_freq,   //
        // control inputs
        input coin_in,
        input double_wash,
        input timer_pause,
        // outputs
        output wash_done
);

//=========================================================
// reg declarations
//=========================================================
        reg [2:0]       state, next; // next state 
        reg [31:0]      filling_water_duration,
                        washing_duration,
                        rinsing_duration,
                        spinning_duration;      // number of clock cycles for each state
        reg [32:0]      clock_count;
        reg             spinning_done;

//=========================================================
// parameter definitions 
//=========================================================
        // state encoding for FSM
        localparam      S_IDLE            = 3'b000,
                        S_FILLING_WATER   = 3'b001,
                        S_WASHING         = 3'b010,
                        S_RINSING         = 3'b011,
                        S_SPINNING        = 3'b010,
                        S_XXX             = 'x;

//=========================================================
// function definitions 
//=========================================================
        function states_duration ();
                case (clk_freq)
                        2'b00   :       filling_water_duration  = 32'h7270e00;
                                        washing_duration        = 32'h11e1a300;
                                        rinsing_duration        = 32'h7270e00;
                                        spinning_duration       = 32'h3938700;
                        2'b01   :       filling_water_duration  = 32'he4e1c00;
                                        washing_duration        = 32'h23c34600;
                                        rinsing_duration        = 32'he4e1c00;
                                        spinning_duration       = 32'h7270e00;
                        2'b10   :       filling_water_duration  = 32'h1c9c3800;
                                        washing_duration        = 32'h47868c00;
                                        rinsing_duration        = 32'h1c9c3800;
                                        spinning_duration       = 32'he4e1c00;
                        2'b11   :       filling_water_duration  = 32'h39387000;
                                        washing_duration        = 32'h8f0d1800;
                                        rinsing_duration        = 32'h39387000;
                                        spinning_duration       = 32'h1c9c3800;
                        default :       filling_water_duration  = 'x;
                                        washing_duration        = 'x;
                                        rinsing_duration        = 'x;   // for debugging
                                        spinning_duration       = 'x;
                endcase
        endfunction 

//=========================================================
// State register
//=========================================================
        always @(posedge clk, negedge rst_n)
                if (!rst_n)     begin   state <= S_IDLE; spinning_done = 0; end
                else                    state <= next;
 
        always @()
                states_duration ();







//=========================================================
// Mealy Output
//=========================================================
        assign 

endmodule
//=========================================================
// EOF 
//=========================================================