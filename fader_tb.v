`timescale 1ms/1us

module fader_tb;

    reg clk;
    reg rst_n;
    reg [31:0] period;
    wire out;
    wire error;

    fader dut (
        .clk(clk),
        .rst_n(rst_n),
        .period(period),
        .out(out),
        .error(error)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        // Dump waveforms for GTKWave / your viewer of choice
        $dumpfile("fader_tb.vcd");
        $dumpvars(0, fader_tb);

        rst_n = 1'b0;
        period = 32'h00000000;
        #50
        rst_n = 1'b1;
        period = 32'h0000000F;
        #50000
        $finish;
    end
endmodule