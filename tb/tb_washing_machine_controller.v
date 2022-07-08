`timescale 1s/1ns

module tb_washing_machine_controller;
	
	reg 		rst_n;
	reg 		clk = 0;
	reg [1:0] 	clk_freq;  
	reg 		coin_in;
	reg 		double_wash;
	reg 		timer_pause;
	wire  		wash_done;

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
	localparam PERIOD = 0.000001;
	// Clock 
	always #(0.0000005) clk = ~clk;

	initial begin
		rst_n = 0;
		#(PERIOD)	rst_n 		= 1;
					clk_freq 	= 2'b00;
					coin_in		= 1;
					double_wash = 0;
					timer_pause = 0;
		#(PERIOD)	coin_in 	= 0;
		#660
		$finish;
	end

endmodule