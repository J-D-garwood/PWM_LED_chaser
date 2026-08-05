`timescale 1ms/1us

module fader_tb;

    reg clk;
    reg rst_n;
    reg [31:0] period1;
    reg [31:0] period2;
    reg [31:0] init1;
    reg [31:0] init2;
    wire out1;
    wire error1;
    wire out2;
    wire error2;

    fader dut_1 (
        .clk(clk),
        .rst_n(rst_n),
        .period(period1),
        .init(init1),
        .out(out1),
        .error(error1)
    );

    fader dut_2 (
        .clk(clk),
        .rst_n(rst_n),
        .period(period2),
        .init(init2),
        .out(out2),
        .error(error2)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;
    initial init1 = 32'd0;
    initial init2 = 32'd100;

    initial begin
        // Dump waveforms for GTKWave / your viewer of choice
        $dumpfile("fader_tb.vcd");
        $dumpvars(0, fader_tb);

        rst_n = 1'b0;
        period1 = 32'h00000000;
        period2 = 32'h00000000;
        #50
        rst_n = 1'b1;
        period2 = 32'h000000F;
        period1 = 32'h0000000F;
        #50000
        $finish;
    end
endmodule