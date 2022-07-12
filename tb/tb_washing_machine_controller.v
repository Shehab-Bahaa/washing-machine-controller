`timescale 1us/100ps

module tb_washing_machine_controller;
	
	// DUT inputs
	reg 		rst_n;
	reg 		clk = 0;
	reg [1:0] 	clk_freq;  
	reg 		coin_in;
	reg 		double_wash;
	reg 		timer_pause;
	// DUT outputs
	wire  		wash_done;
	// clock generation variables
	real 		clock_period = 1; // 1us
	// monitoring variables
	real		state_start_time;
	real		state_end_time;
	real		state_duration;

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

//=========================================================
// task definitions 
//=========================================================
	task checkers (input real expected_previous_state_minutes, input [13*8:1] previous_state, input [13*8:1] expected_current_state, input expected_wash_done);
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
			if ((previous_state !== "IDLE") || (expected_previous_state_minutes != 0)) begin
				state_end_time 		= $realtime;
				state_duration		= (state_end_time - state_start_time)/(60*10**6);
				if (state_duration == expected_previous_state_minutes)
					$display("\"SUCCESSFUL %s state\" with %0f minutes duration", previous_state, state_duration);
				else begin 
					$display("\"FAILED %s state\" \nEXPECTED: %0f minutes, OBSERVED: %0f minutes", previous_state,expected_previous_state_minutes,state_duration);	
					$finish; 
				end
			end
		//=========================================================
		// Checking that the current state is as expected
		//=========================================================
			if (DUT.state === state_number) state_start_time 	= $realtime;
			else begin
				$display("\"FAILED\" \nEXPECTED: %0d state, OBSERVED: %0d", state_number, DUT.state); $finish;
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
	//==============================================================
	// Test Scenario (1): No double_wash and no timer_pause (1MHZ clock) 
	//==============================================================
		begin
			$display("//=============================================================================\n// Test Scenario 1 started (No double_wash and no timer_pause with 1 MHZ clock)\n//=============================================================================");
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
					@(DUT.state)	checkers(0, "IDLE", "FILLING WATER", 0);
					@(DUT.state)	checkers(2, "FILLING WATER", "WASHING", 0);
					@(DUT.state)	checkers(5, "WASHING", "RINSING", 0);
					@(DUT.state)	checkers(2, "RINSING", "SPINNING", 0);
					@(DUT.state)	checkers(1, "SPINNING", "IDLE", 1);
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

	task test2();
	//==================================================================
	// Test Scenario (2): double_wash but no timer_pause (2MHZ clock) 
	//==================================================================
		begin
			$display("//=============================================================================\n// Test Scenario 2 started (double_wash but no timer_pause with 2 MHZ clock)\n//=============================================================================");
			fork
				// Driving
				begin
									clk_freq 	= 2'b01;
									coin_in		= 1;
									double_wash = 1;
									timer_pause = 0;
					@(negedge clk)	coin_in 	= 0;
				end
				// Monitoring
				begin
									if (DUT.state === 0) 	$display("\"SUCCESSFUL IDLE state\""); 
									else begin 				$display("\"FAILED IDLE state\""); $finish; end
					@(DUT.state)	checkers(0, "IDLE", "FILLING WATER", 0);
					@(DUT.state)	checkers(2, "FILLING WATER", "WASHING", 0);
					@(DUT.state)	checkers(5, "WASHING", "RINSING", 0);
					@(DUT.state)	checkers(2, "RINSING", "WASHING", 0);
					@(DUT.state)	checkers(5, "WASHING", "RINSING", 0);
					@(DUT.state)	checkers(2, "RINSING", "SPINNING", 0);
					@(DUT.state)	checkers(1, "SPINNING", "IDLE", 1);
									if (wash_done == 1) 
										$display("\"SUCCESSFUL wash done\""); 
									else begin 
										$display("\"FAILED wash done\" \nEXPECTED: 1, OBSERVED: 0"); 
										$finish; 
									end
				end
			join
			$display("//=============================================================\n// Test Scenario 2 finished successfully\n//=============================================================");
		end
	endtask

	task test3();
	//==============================================================
	// Test Scenario (3): No double_wash and no timer_pause (4MHZ clock) 
	//==============================================================
		begin
			$display("//=============================================================================\n// Test Scenario 3 started (No double_wash but with timer_pause with 3 MHZ clock)\n//=============================================================================");
			fork
				// Driving
				begin
										clk_freq 	= 2'b00;
										coin_in		= 1;
										double_wash = 0;
										timer_pause = 0;
					@(negedge clk)		coin_in 	= 0;
					@(DUT.state == 4)	
					#(0.5*10**6*60)		timer_pause = 1;	// start the pause in the middle of the spinning phase
					#(1*10**6*60)		timer_pause = 0;	// the pause duration is one minute

				end
				// Monitoring
				begin
									if (DUT.state === 0) 	$display("\"SUCCESSFUL IDLE state\""); 
									else begin 				$display("\"FAILED IDLE state\""); $finish; end
					@(DUT.state)	checkers(0, "IDLE", "FILLING WATER", 0);
					@(DUT.state)	checkers(2, "FILLING WATER", "WASHING", 0);
					@(DUT.state)	checkers(5, "WASHING", "RINSING", 0);
					@(DUT.state)	checkers(2, "RINSING", "SPINNING", 0);
					@(DUT.state)	checkers(0.5, "SPINNING", "IDLE", 0);
					@(DUT.state)	checkers(1, "IDLE", "SPINNING", 0);
					@(DUT.state)	checkers(0.5, "SPINNING", "IDLE", 1);
									if (wash_done == 1) 
										$display("\"SUCCESSFUL wash done\""); 
									else begin 
										$display("\"FAILED wash done\" \nEXPECTED: 1, OBSERVED: 0"); 
										$finish; 
									end
				end
			join
			$display("//=============================================================\n// Test Scenario 3 finished successfully\n//=============================================================");
		end
	endtask
//=========================================================
// Clock Generation
//=========================================================
	always #(0.5*clock_period) clk = ~clk;

	always @(clk_freq) 
		case(clk_freq)
			2'b00 : clock_period = 1;
			2'b01 : clock_period = 0.5;
			2'b10 : clock_period = 0.25;
			2'b11 : clock_period = 0.125;
		endcase

//=========================================================
// Main Code
//=========================================================
	initial begin
		$monitor("[$monitor] time= %0tns, state = %0d", $realtime, DUT.state);
		// RESET
		rst_n = 0;
		@(negedge clk)	rst_n 		= 1;
		@(negedge clk)
		// Selecting the test scenario
		`ifdef test1	test1();
		`elsif test2	test2();
		`elsif test3	test3();
		`elsif test4
		`endif

		#100;
		$finish;
	end

endmodule
 


