/*
Project        : Controller Unit For a Washing Machine 
Module name    : washing_machine_controller
Dependancy     :
Owner          : Shehab Bahaa
*/
module washing_machine_controller (
	input 		rst_n,    			// Active low asynchronous clock
	input 		clk,      			// System clock

	input [1:0] clk_freq,   		// Input Clock Frequency Configuration Code

	input 		coin_in,			// Input flag which is asserted when a coin is deposited
	input 		double_wash,		// Input flag which is asserted if the user requires double wash option
	input 		timer_pause,		// Input flag when it is set to ‘1’ spinning phase is paused until this flag is de-asserted

	output reg 	wash_done			// Active high output asserted when spinning phase is done and deasserted when coin_in is set to ‘1’
);

//=========================================================
// parameter definitions 
//=========================================================
	// state encoding for FSM
	localparam  S_IDLE            = 3'b000,
				S_FILLING_WATER   = 3'b001,
				S_WASHING         = 3'b010,
				S_RINSING         = 3'b011,
				S_SPINNING        = 3'b100;

//=========================================================
// reg declarations
//=========================================================
	reg [2:0]   state; 					// next state 
	reg [31:0]  clock_count;
	reg 		second_wash_flag;
	reg			paused_spinning_flag;
	reg [31:0]  filling_water_duration,
				washing_duration,
				rinsing_duration,
				spinning_duration;      // number of clock cycles for each state

//=========================================================
// task definitions 
//=========================================================
	task states_duration ();
	//==============================================================================================================================================================================
	// states_duration task is used to define the required time duration for each state. The time duration is defined using a counter for the number of clock cycles of each state.
	// The number a clock cycles per state depends on the clock frequency used and the state itself. It is calculated as follows: 
	// # of clock cycles per state = (frequency, i.e., cycles per sec)*(state duration in minutes)*(60 s/min)
	//==============================================================================================================================================================================
		case (clk_freq)
		// decoding the clk_freq[1:0] input port
			2'b00   :   // 1 MHz
						begin 
						filling_water_duration  <= 32'h7270e00; 	// # of clock cycles per state = (1*10**6)*(2)*(60) = 120*10**6
						washing_duration        <= 32'h11e1a300; 	// # of clock cycles per state = (1*10**6)*(5)*(60) = 300*10**6
						rinsing_duration        <= 32'h7270e00; 	// # of clock cycles per state = (1*10**6)*(2)*(60) = 120*10**6
						spinning_duration       <= 32'h3938700; 	// # of clock cycles per state = (1*10**6)*(1)*(60) = 60*10**6
						end
			2'b01   :   // 2 MHz
						begin 
						filling_water_duration  <= 32'he4e1c00; 	// # of clock cycles per state = (2*10**6)*(2)*(60) = 240*10**6
						washing_duration        <= 32'h23c34600; 	// # of clock cycles per state = (2*10**6)*(5)*(60) = 600*10**6
						rinsing_duration        <= 32'he4e1c00; 	// # of clock cycles per state = (2*10**6)*(2)*(60) = 240*10**6
						spinning_duration       <= 32'h7270e00; 	// # of clock cycles per state = (2*10**6)*(1)*(60) = 120*10**6
						end
			2'b10   :   // 4 MHz
						begin 
						filling_water_duration  <= 32'h1c9c3800; 	// # of clock cycles per state = (4*10**6)*(2)*(60) = 480*10**6
						washing_duration        <= 32'h47868c00; 	// # of clock cycles per state = (4*10**6)*(5)*(60) = 1.2*10**9
						rinsing_duration        <= 32'h1c9c3800; 	// # of clock cycles per state = (4*10**6)*(2)*(60) = 480*10**6
						spinning_duration       <= 32'he4e1c00; 	// # of clock cycles per state = (4*10**6)*(1)*(60) = 240*10**6
						end
			2'b11   :   // 8 MHz
						begin 
						filling_water_duration  <= 32'h39387000; 	// # of clock cycles per state = (8*10**6)*(2)*(60) = 960*10**6
						washing_duration        <= 32'h8f0d1800; 	// # of clock cycles per state = (8*10**6)*(5)*(60) = 2.4*10**9
						rinsing_duration        <= 32'h39387000; 	// # of clock cycles per state = (8*10**6)*(2)*(60) = 960*10**6
						spinning_duration       <= 32'h1c9c3800; 	// # of clock cycles per state = (8*10**6)*(1)*(60) = 480*10**6
						end
		endcase
	endtask 
//=========================================================
// FSM code using 1-always block coding style 
//=========================================================
	always @(posedge clk, negedge rst_n)
		if (!rst_n)     begin   
			state           		<= S_IDLE;
			wash_done       		<= 0;
			clock_count     		<= 0;
			second_wash_flag 		<= 0;
			paused_spinning_flag 	<= 0;
		end
		else begin
			case (state)
				S_IDLE          : //============================================================================================================================================================================
								  // the machine checks if a spinning state is pause or not using the paused_spinning_flag:
								  // 	- If a spinning state is paused, the last clock count from the spinning state is saved until the timer_pause input is deasserted, then it continues the spinning state.
								  //		 -- Note: a flag is introduced along with the timer_pause signal so that the timer_pause is considered only when the spinning state is paused. 
								  // 	- If there is no spinning state paused, then the counter is initialized to 0 and the value of wash_done signal is saved until the coin_in signal is asserted.
								  // 		-- When coin_in is asserted, wash_done and second_wash flag is reseted and the state_duration task is called.
								  // 		-- states_duration task is used to define the required time duration for each state.
								  //============================================================================================================================================================================
								  if (paused_spinning_flag) begin 
										clock_count 			<= clock_count;
										if (timer_pause) 								state <= S_IDLE;	//@ loopback
										else 											state <= S_SPINNING;
									end else begin
										clock_count 			<= 0;
										if (coin_in) begin 
											wash_done       	<= 0;
											second_wash_flag	<= 0;
											states_duration ();
																						state <= S_FILLING_WATER;
										end 
										else begin
											wash_done 			<= wash_done;
																						state <= S_IDLE;		//@ loopback 
										end // if coin_in
								  end // if paused_spinning_flag
				S_FILLING_WATER : //===================================================================================================
								  // the machine checks if the state duration has passed using the clock count:
								  // 	- If the state duration did not pass, then it increments the counter and stays in this state.
								  // 	- If the state duration passed, then it resets the counter and moves into the S_WASHING state.
								  //===================================================================================================
								  if (clock_count < filling_water_duration - 1) begin
									clock_count <= clock_count + 1;
																						state <= S_FILLING_WATER;	//@ loopback 
								  end else begin
									clock_count <= 0;
																						state <= S_WASHING;
								  end // if clock_count < filling_water_duration - 1
				S_WASHING       : //===============================================================================================================================================
								  // the machine checks if the state duration passed using the clock count:
								  // 	- If the state duration did not pass, then it increments the counter and stays in this state.
								  // 	- If the state duration passed, then:
								  // 		-- resets the counter 
								  // 		-- If the double_wash input is asserted, it toggles second_wash_flag.
								  // 			--- Note: this flag allows only one more round of washing and rinsing even if double_wash is still asserted after the second round.
								  // 		-- and moves into the S_RINSING state.
								  //================================================================================================================================================
								  if (clock_count < washing_duration - 1) begin
									clock_count <= clock_count + 1;
																						state <= S_WASHING;		//@ loopback 
								  end else begin
									clock_count <= 0;
									if (double_wash) 
										second_wash_flag <= ~second_wash_flag;
																						state <= S_RINSING;
								  end // if clock_count < washing_duration - 1
				S_RINSING       : //==================================================================================================
								  // the machine checks if the state duration passed using the clock count:
								  // 	- If the state duration did not pass, then it increments the counter and stays in this state.
								  // 	- If the state duration passed, then it resets the counter and
								  // 		-- If the second_wash_flag is 0, it moves into the S_SPINNING state.
								  // 		-- If the second_wash_flag is 1, it moves into the S_WASHING state.
								  //==================================================================================================
								  if (clock_count < rinsing_duration - 1) begin
									clock_count <= clock_count + 1;
																						state <= S_RINSING;		//@ loopback 
								  end else begin
									clock_count <= 0;
									if (second_wash_flag)								state <= S_WASHING;
									else 												state <= S_SPINNING;
								  end // if clock_count < rinsing_duration - 1
				S_SPINNING      : //==================================================================================================================
								  // the machine checks if the state duration passed using the clock count:
								  // 	- If the state duration did not pass, then it increments the counter and checks:
								  // 		-- If timer_pause input is deasserted, it stays in this state.
								  // 		-- If timer_pause input is asserted, then it sets the paused_spinning_flag and moves into S_IDLE state.
								  // 	- If the state duration passed, then it resets the counter, asserts wash_done and moves into the S_IDLE state.
								  //===================================================================================================================
								  if (clock_count < spinning_duration - 1) begin
									clock_count 			<= clock_count + 1;
									if (timer_pause) begin
										paused_spinning_flag 	<= 1;
																						state <= S_IDLE;
									end else begin
																						state <= S_SPINNING; 	//@ loopback
									end // if timer_pause
								  end else begin
									paused_spinning_flag 		<= 0;
									wash_done 					<= 1;			// Mealy output
																						state <= S_IDLE;
								 end // if clock_count < spinning_duration - 1
			endcase
			end // if !rst_n
endmodule
//=========================================================
// EOF 
//=========================================================