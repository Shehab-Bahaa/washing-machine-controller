module state_duration_manager (
        input rst_n,    // Active low asynchronous clock
        input clk,      // System clock

        input   [1:0]     clk_freq,     //
        input   [2:0]        state,     //
        
        output  []        state_duration        //
);

//***************************************************************************
// Parameter definitions
//***************************************************************************
        localparam      IDLE            = 3'b000,
                        FILLING_WATER   = 3'b001,
                        WASHING         = 3'b010,
                        RINSING         = 3'b011,
                        SPINNING        = 3'b010,
                        XXX_state       = 'x;


endmodule