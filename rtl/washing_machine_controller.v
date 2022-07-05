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
        reg [2:0] state, next; // next state 


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
// State register
//=========================================================
        always @(posedge clk, negedge rst_n)
                if (!rst_n)     state <= S_IDLE;
                else            state <= next;

        always @()




case ()




//=========================================================
// State register
//=========================================================


endmodule
//=========================================================
// EOF 
//=========================================================