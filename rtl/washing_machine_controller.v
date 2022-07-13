/*
Project        : Controller Unit For a Washing Machine 
Module name    : washing_machine_controller
Dependancy     :
Design doc.    : Digital Design Assignment
Description    : 
Owner          : Shehab Bahaa
*/
module washing_machine_controller (
	input rst_n,    // Active low asynchronous clock
	input clk,      // System clock

	input [1:0] clk_freq,   // Input Clock Frequency Configuration Code
	// control inputs
	input coin_in,			// Input flag which is asserted when a coin is deposited
	input double_wash,		// Input flag which is asserted if the user requires double wash option
	input timer_pause,		// Input flag when it is set to ‘1’ spinning phase is paused until this flag is de-asserted
	// outputs
	output reg wash_done	// Active high output asserted when spinning phase is done and deasserted when coin_in is set to ‘1’
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
	reg [2:0]   state; // next state 
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
	// decoding the 
	task states_duration ();
		// decoding the clk_freq[1:0] input port
		case (clk_freq)
			// 1 MHz
			2'b00   :   begin 
						filling_water_duration  <= 32'h7270e00;
						washing_duration        <= 32'h11e1a300;
						rinsing_duration        <= 32'h7270e00;
						spinning_duration       <= 32'h3938700;
						end
			// 2 MHz
			2'b01   :   begin 
						filling_water_duration  <= 32'he4e1c00;
						washing_duration        <= 32'h23c34600;
						rinsing_duration        <= 32'he4e1c00;
						spinning_duration       <= 32'h7270e00;
						end
			// 4 MHz
			2'b10   :   begin 
						filling_water_duration  <= 32'h1c9c3800;
						washing_duration        <= 32'h47868c00;
						rinsing_duration        <= 32'h1c9c3800;
						spinning_duration       <= 32'he4e1c00;
						end
			// 8 MHz
			2'b11   :   begin 
						filling_water_duration  <= 32'h39387000;
						washing_duration        <= 32'h8f0d1800;
						rinsing_duration        <= 32'h39387000;
						spinning_duration       <= 32'h1c9c3800;
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
				S_IDLE          : // 
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
				S_FILLING_WATER : // 
								  if (clock_count < filling_water_duration - 1) begin
									clock_count <= clock_count + 1;
																						state <= S_FILLING_WATER;	//@ loopback 
								  end else begin
									clock_count <= 0;
																						state <= S_WASHING;
								  end // if clock_count < filling_water_duration - 1
				S_WASHING       : // 
								  if (clock_count < washing_duration - 1) begin
									clock_count <= clock_count + 1;
																						state <= S_WASHING;		//@ loopback 
								  end else begin
									clock_count <= 0;
									if (double_wash) 
										second_wash_flag <= ~second_wash_flag;
																						state <= S_RINSING;
								  end // if clock_count < washing_duration - 1
				S_RINSING       : // 
								  if (clock_count < rinsing_duration - 1) begin
									clock_count <= clock_count + 1;
																						state <= S_RINSING;		//@ loopback 
								  end else begin
									clock_count <= 0;
									if (second_wash_flag)								state <= S_WASHING;
									else 												state <= S_SPINNING;
								  end // if clock_count < rinsing_duration - 1
				S_SPINNING      : // 
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