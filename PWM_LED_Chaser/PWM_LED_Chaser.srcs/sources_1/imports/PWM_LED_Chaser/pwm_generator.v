module pwm_generator #(
	//parameter DUTYCYCLE = 70, //MUST BE an Integer between 0 and the period
	parameter PERIOD = 100 //MUST BE AN INTEGER GREATER THAN 1. Is number of base clk cycles in a period
)(
	input clk,
	input rst_n,
	input [31:0] duty,
	output reg out,
	output reg error
);
	// Runs once at time 0 in simulation, before any clock edge.
	// PERIOD is a parameter, so this condition is fully determined
	// at elaboration — the check costs zero hardware.
	initial begin
		if (PERIOD < 2) begin
			// %m expands to the full hierarchical instance path, so you
			// find out *which* instantiation was misparameterised.
			// %0d prints the integer with no padding.
			$display("%m: PERIOD must be >= 2, got %0d", PERIOD);
			$finish;
		end
	end

	reg [31:0] counter;
	reg [31:0] duty_D;

	always @(posedge clk) begin
		if (!rst_n) begin
			out <= 1'b0;
			error <= 1'b0;
			counter <= 32'b0;
			duty_D <= 0;
		end else begin
			if (duty_D>PERIOD) begin
				error <= 1'b1;
			end else begin
				error <= 1'b0;
			end

			if (counter == PERIOD - 1) begin
				duty_D <= duty;
				counter <= 32'b0;
			end else begin
				counter <= counter + 1'b1;
			end
			if (counter>=duty_D) begin	
					out <= 1'b0;
			end else begin
				out <= 1'b1;
			end
		end
	end
endmodule
