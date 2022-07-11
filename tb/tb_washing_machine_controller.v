`timescale 1us/1ns

module tb_washing_machine_controller;
	
	reg 		rst_n;
	reg 		clk = 0;
	reg [1:0] 	clk_freq;  
	reg 		coin_in;
	reg 		double_wash;
	reg 		timer_pause;
	wire  		wash_done;
	real		state_start_time;
	real		state_end_time;
	real		state_duration;

//=========================================================
// task definitions 
//=========================================================
	task checkers (input integer expected_previous_state_minutes, input [13*8:1] previous_state, input [13*8:1] expected_current_state, input expected_wash_done);
		integer state_number;
		begin
			case (expected_current_state)
			"IDLE"			: 	state_number = 0;
			"FILLING WATER"	: 	state_number = 1;
			"WASHING"		: 	state_number = 2;
			"RINSING"		: 	state_number = 3;
			"SPINNING"		: 	state_number = 4;
			endcase
		//=========================================================
		// Checking the duration of the previous state
		//=========================================================
			if (previous_state !== "IDLE") begin
				state_end_time 		= $realtime;
				state_duration		= (state_end_time - state_start_time)/(60*10**6);
				if (state_duration == expected_previous_state_minutes)
					$display("\"SUCCESSFUL %s state\" with %0d minutes duration", previous_state, state_duration);
				else begin 
					$display("\"FAILED %s state\" \nEXPECTED: %0d minutes, OBSERVED: %0d minutes", previous_state,expected_previous_state_minutes,state_duration);	
					$finish; 
				end
			end
		//=========================================================
		// Checking that the current state is as expected
		//=========================================================
			if (DUT.state === state_number) state_start_time 	= $realtime;
			else begin
				$display("\"FAILED\" \nEXPECTED: %s state, OBSERVED: %0d", expected_current_state, state_number); $finish;
			end
		//=========================================================
		// Checking the output
		//=========================================================
			if (wash_done !== expected_wash_done) begin 
				$display("\"FAILED wash done\" \nEXPECTED: %0d, OBSERVED: %0d", expected_wash_done, wash_done); 
				$finish; 
			end
		end
	endtask

	task test1();
	//=========================================================
	// Test Scenario (1): No double_wash and no timer_pause 
	//=========================================================
		begin
			//$display("\"SUCCESSFUL %s state\" with %0d minutes duration", previous_state, state_duration);
			$display("//=============================================================\n// Test Scenario 1 started (No double_wash and no timer_pause)\n//=============================================================");
			fork
				// Driving
				begin
									clk_freq 	= 2'b00;
									coin_in		= 1;
									double_wash = 0;
									timer_pause = 0;
					@(negedge clk)	coin_in 	= 0;
				end
				// Monitoring
				begin
											if (DUT.state === 0) 	$display("\"SUCCESSFUL IDLE state\""); 
											else begin 				$display("\"FAILED IDLE state\""); $finish; end
					@(DUT.state)			checkers(0, "IDLE", "FILLING WATER", 0);
					@(DUT.state)			checkers(2, "FILLING WATER", "WASHING", 0);
					@(DUT.state)			checkers(5, "WASHING", "RINSING", 0);
					@(DUT.state)			checkers(2, "RINSING", "SPINNING", 0);
					@(DUT.state)			checkers(1, "SPINNING", "IDLE", 1);
											if (wash_done == 1) 
												$display("\"SUCCESSFUL wash done\""); 
											else begin 
												$display("\"FAILED wash done\" \nEXPECTED: 1, OBSERVED: 0"); 
												$finish; 
											end
				end
			join
			$display("//=============================================================\n// Test Scenario 1 finished successfully\n//=============================================================");
		end
	endtask
//=========================================================
// DUT Instantiation
//=========================================================

	washing_machine_controller DUT(
		.rst_n(rst_n),
		.clk(clk),
		.clk_freq(clk_freq),   
		.coin_in(coin_in),
		.double_wash(double_wash),
		.timer_pause(timer_pause),
		.wash_done(wash_done)
	);
	// Clock period 
	localparam PERIOD = 1;
	// Clock 
	always #(0.5*PERIOD) clk = ~clk;

	initial begin
		$monitor("[$monitor] time= %0tns, state = %0d", $realtime, DUT.state);
	//=========================================================
	// RESET
	//=========================================================
		rst_n = 0;
		@(negedge clk)	rst_n 		= 1;
		@(negedge clk)

		`ifdef test1	test1();
		`elsif test2
		`elsif test3
		`elsif test4
		`endif

		#100;
		$finish;
	end

endmodule
 

