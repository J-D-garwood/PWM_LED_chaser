// ---------------------------------------------------------------------------
// KNOWN ISSUE (R2): linear duty ramp, non-linear perception.
//
// This fader steps duty by a constant +/-1 out of 100. The LED's light output
// really does change by 1% of full scale each step, but the eye doesn't
// measure light — it measures ratio. Roughly, perceived brightness follows a
// power law (Stevens' law, exponent ~0.3-0.5 for point sources), so what
// registers as "one step brighter" is a constant *multiplication*, not a
// constant addition.
//
// Consequence at the two ends of the ramp:
//   duty  0 ->  1 : light output doubles (x2.0)  -> large, obvious jump
//   duty 50 -> 51 : +2%                          -> barely noticeable
//   duty 99 ->100 : +1%                          -> invisible
//
// So the ramp appears to lurch out of black in a few visible stairs, then
// crawl through an almost static bright region. Same increment, wildly
// different apparent effect. This is the stair-stepping R2 prohibits.
//
// Fix (deferred — leaving linear for now to observe the artifact):
// make each step a constant ratio instead of a constant increment. Options:
//   (a) ramp an index i and drive duty = f(i) where f is convex, e.g. i*i
//       scaled to PERIOD — cheap, one multiplier or a shift-add.
//   (b) a small ROM LUT of ~64 pre-computed gamma-corrected duty values
//       (duty = PERIOD * (i/N)^2.2) — exact, costs one block RAM or LUTs.
// Either way PERIOD must grow: fine ratios near zero need more resolution
// than 100 counts can express, since the smallest nonzero step is 1/100.
// ---------------------------------------------------------------------------


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