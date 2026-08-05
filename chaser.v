// This is interesting but not quite the assignment 
// Its as simple as having four LEDs and lighting only 1 at a time.
// make the advance slow enough so its clear to the human eye

module chaser (
    input clk,
    input rst_n,
    input [31:0] period,
    output out1,
    output out2,
    output out3,
    output error
);

    wire err1;
    wire err2;
    wire err3;

    reg [31:0] init1 = 32'd0;
    reg [31:0] init2 = 32'd50;
    reg [31:0] init3 = 32'd100;
    
    assign error = (err1 | err2 | err3);

    fader led_1 (
        .clk(clk),
        .rst_n(rst_n),
        .period(period),
        .init(init1), // number between 32'd0 and 32'd100
        .out(out1),
        .error(err1)
    );
    fader led_2 (
        .clk(clk),
        .rst_n(rst_n),
        .period(period),
        .init(init2), // number between 32'd0 and 32'd100
        .out(out2),
        .error(err2)
    );

    fader led_3 (
        .clk(clk),
        .rst_n(rst_n),
        .period(period),
        .init(init3), // number between 32'd0 and 32'd100
        .out(out3),
        .error(err3)
    );

endmodule