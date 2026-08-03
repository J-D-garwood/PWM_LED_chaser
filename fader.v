module fader (
    input clk,
    input rst_n,
    input [31:0] period,
    output out,
    output error
);

    reg [31:0] duty = 32'b0;
    reg [31:0] counter = 32'b0;
    reg up;

    pwm_generator #() PWM(
        .clk(clk),
	    .rst_n(rst_n),
	    .duty(duty),
	    .out(out),
	    .error(error)
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            duty <= 32'b0;
            counter <= 32'b0;
            up <= 1'b1;
        end else begin 
            if (counter == period) begin
                if (up) begin
                    if (duty == 32'd100) begin
                        up <= 1'b0;
                    end else begin 
                        duty <= duty + 32'd1;
                    end
                end else begin
                    if (duty == 32'd0) begin
                        up <= 1'b1;
                    end else begin 
                        duty <= duty - 32'd1;
                    end
                end
                counter <= 32'b0;
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end
endmodule