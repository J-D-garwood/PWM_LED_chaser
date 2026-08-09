`timescale 1ms/1us

module chaser_tb;

    reg clk;
    reg rst_n;
    wire [3:0] out;
    wire bit1;
    wire bit2;
    wire bit3;
    wire bit4;    

    chaser dut (
        .clk(clk),
        .rst_n(rst_n),
        .out(out)
    );

    assign {bit1, bit2, bit3, bit4} = out;

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("chaser_tb.vcd");
        $dumpvars(0, chaser_tb);

        rst_n = 1'b0;
        #50
        rst_n = 1'b1;
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