`timescale 1ms/1us

module chaser_tb;

    reg clk;
    reg rst_n;
    reg [31:0] period;
    wire out1;
    wire out2;
    wire out3;
    wire error;

    chaser dut (
        .clk(clk),
        .rst_n(rst_n),
        .period(period),
        .out1(out1),
        .out2(out2),
        .out3(out3),
        .error(error)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("chaser_tb.vcd");
        $dumpvars(0, chaser_tb);

        rst_n = 1'b0;
        period = 32'h00000000;
        #50
        rst_n = 1'b1;
        period = 32'h0000000F;
        #50000
        $finish;
    end
endmodule

//module led_chaser (
//    input clk,
//    input rst_n,
//    input [31:0] period,
//    output out1,
//    output out2,
//    output out3,
//    output error
//);