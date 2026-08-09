`timescale 1ns / 1ps

module top (
    input  sys_clk_p,
    input  sys_clk_n,
    input  rst_n,
    output led1,
    output led2,
    output led3,
    output led4,
    output led5
);

    wire clk;
    wire [3:0] chaser_out;

    localparam CLK_HZ = 200_000_000;
    localparam CHASE_PERIOD = CLK_HZ;              // 1 s per full chase
    localparam FADE_STEP    = CLK_HZ / 200;        // 2 s per breathe

    wire chase_con_1;
    wire chase_con_2;
    wire chase_con_3;
    wire chase_con_4;

    wire pwm_out_1;
    wire pwm_out_2;
    wire pwm_out_3;
    wire pwm_out_4;

    assign led1 = ~pwm_out_1;
    assign led2 = ~pwm_out_2;
    assign led3 = ~pwm_out_3;
    assign led4 = ~pwm_out_4;

    wire err1;
    wire err2;
    wire err3;
    wire err4;
    wire err5;

    wire [31:0] duty_led_1;
    wire [31:0] duty_led_2; 
    wire [31:0] duty_led_3;
    wire [31:0] duty_led_4;

    IBUFDS #(.IOSTANDARD("DIFF_SSTL15")) u_clk_buf (
        .I (sys_clk_p), .IB (sys_clk_n), .O (clk)
    );

    chaser chase (
        .clk(clk),
        .rst_n(rst_n),
        .period(CHASE_PERIOD),
        .out(chaser_out)
    );

    assign {chase_con_1, chase_con_2, chase_con_3, chase_con_4} = chaser_out;

    chaser_to_pwm gen1(
        .clk(clk),
        .rst_n(rst_n),
        .on(chase_con_1),
        .duty(duty_led_1)
    );

    chaser_to_pwm gen2(
        .clk(clk),
        .rst_n(rst_n),
        .on(chase_con_2),
        .duty(duty_led_2)
    );

    chaser_to_pwm gen3(
        .clk(clk),
        .rst_n(rst_n),
        .on(chase_con_3),
        .duty(duty_led_3)
    );

    chaser_to_pwm gen4(
        .clk(clk),
        .rst_n(rst_n),
        .on(chase_con_4),
        .duty(duty_led_4)
    );

    pwm_generator #() pwm1(
        .clk(clk),
        .rst_n(rst_n),
        .duty(duty_led_1),
        .out(pwm_out_1),
        .error(err1)
    );

    pwm_generator #() pwm2(
        .clk(clk),
        .rst_n(rst_n),
        .duty(duty_led_2),
        .out(pwm_out_2),
        .error(err2)
    );

    pwm_generator #() pwm3(
        .clk(clk),
        .rst_n(rst_n),
        .duty(duty_led_3),
        .out(pwm_out_3),
        .error(err3)
    );

    pwm_generator #() pwm4(
        .clk(clk),
        .rst_n(rst_n),
        .duty(duty_led_4),
        .out(pwm_out_4),
        .error(err4)
    );

    //localparam [31:0] period = 32'h0000FFFF;
    localparam [31:0] init = 32'b0;

    fader fade (
        .clk(clk),
        .rst_n(rst_n),
        .period(FADE_STEP),
        .init(init),
        .out(led5),
        .error(err5)
    );


endmodule
