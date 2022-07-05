module FSM (
        input rst_n,    // Active low asynchronous clock
        input clk,      // System clock

        input coin_in,
        input double_wash,

        input state_done, 

        output reg [2:0] state, 
        output wash_done
);

//=========================================================
// reg declarations
//=========================================================
        reg [2:0] next; // next state 


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
                if (!rst_n)     state <= IDLE;
                else            state <= next;



endmodule