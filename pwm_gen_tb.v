`timescale 1ms/1us

module pwm_gen_tb;

    reg clk;
    reg rst_n;
    reg [31:0] duty;
    wire out;
    wire error;

    pwm_generator #() dut (
        .clk        (clk),
    	.rst_n      (rst_n),
    	.duty       (duty),
    	.out        (out),
    	.error      (error)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        // Dump waveforms for GTKWave / your viewer of choice
        $dumpfile("pwm_gen_tb.vcd");
        $dumpvars(0, pwm_gen_tb);

        rst_n = 1'b0;
        duty = 32'b0;
        #30
        rst_n = 1'b1;
        duty = 32'd50;
        #10000
        duty = 32'd90;
        #10000
        duty = 32'd10;
        #10000
        $finish;
    end
endmodule
