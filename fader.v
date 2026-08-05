//32'd100 is still hardcoded while pwm_generator #() takes PERIOD as a parameter. 
//They agree only because you left the default at 100. Change PERIOD and the fader 
//silently ramps to the wrong ceiling. Make it one shared parameter passed to both —
// this is the constraint about parameterizing timing constants.

//counter == period should be >=. period is an input port, not a parameter. If it 
// drops while counter is already past the new value, you miss the match and stall 
//for 2³² cycles.

//init is unvalidated. The comment says 0–100, nothing enforces it. Feed it 150 and
// the up-ramp never hits == 100, so duty climbs to 4 billion and wraps. The PWM's 
//error will fire, so you'd notice — but the fader itself has no opinion, and error is
// still a bare passthrough.

//Minor: both endpoints are held for two step-periods, since the turnaround cycle flips up without moving duty. Fine if deliberate, worth a comment either way.
//R2 risk: 100 linear steps. The 0→1 step is a doubling of brightness, the 99→100 step is a 1% change. That's the stair-stepping the requirement calls out.
//Fix 1 and 2 before you put it on hardware.







module fader (
    input clk,
    input rst_n,
    input [31:0] period,
    input [31:0] init, // number between 32'd0 and 32'd100
    output out,
    output error
);

    reg [31:0] duty;
    reg [31:0] counter;
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
            duty <= init;
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