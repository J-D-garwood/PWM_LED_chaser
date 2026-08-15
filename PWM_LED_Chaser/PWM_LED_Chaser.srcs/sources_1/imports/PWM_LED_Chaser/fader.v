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

    localparam integer BRIGHT_STEPS = 63;
    localparam integer BRIGHT_WIDTH = 20;
    
    reg [BRIGHT_WIDTH-1:0] bright_lut [0:BRIGHT_STEPS-1];
    
initial begin
        bright_lut[ 0] = 20'd0      ;  // 00000
        bright_lut[ 1] = 20'd1      ;  // 00001
        bright_lut[ 2] = 20'd2      ;  // 00002
        bright_lut[ 3] = 20'd3      ;  // 00003
        bright_lut[ 4] = 20'd4      ;  // 00004
        bright_lut[ 5] = 20'd5      ;  // 00005
        bright_lut[ 6] = 20'd6      ;  // 00006
        bright_lut[ 7] = 20'd7      ;  // 00007
        bright_lut[ 8] = 20'd8      ;  // 00008
        bright_lut[ 9] = 20'd9      ;  // 00009
        bright_lut[10] = 20'd10     ;  // 0000a
        bright_lut[11] = 20'd11     ;  // 0000b
        bright_lut[12] = 20'd13     ;  // 0000d
        bright_lut[13] = 20'd16     ;  // 00010
        bright_lut[14] = 20'd19     ;  // 00013
        bright_lut[15] = 20'd23     ;  // 00017
        bright_lut[16] = 20'd27     ;  // 0001b
        bright_lut[17] = 20'd32     ;  // 00020
        bright_lut[18] = 20'd37     ;  // 00025
        bright_lut[19] = 20'd42     ;  // 0002a
        bright_lut[20] = 20'd49     ;  // 00031
        bright_lut[21] = 20'd55     ;  // 00037
        bright_lut[22] = 20'd62     ;  // 0003e
        bright_lut[23] = 20'd70     ;  // 00046
        bright_lut[24] = 20'd78     ;  // 0004e
        bright_lut[25] = 20'd87     ;  // 00057
        bright_lut[26] = 20'd96     ;  // 00060
        bright_lut[27] = 20'd106    ;  // 0006a
        bright_lut[28] = 20'd116    ;  // 00074
        bright_lut[29] = 20'd127    ;  // 0007f
        bright_lut[30] = 20'd139    ;  // 0008b
        bright_lut[31] = 20'd151    ;  // 00097
        bright_lut[32] = 20'd164    ;  // 000a4
        bright_lut[33] = 20'd177    ;  // 000b1
        bright_lut[34] = 20'd191    ;  // 000bf
        bright_lut[35] = 20'd206    ;  // 000ce
        bright_lut[36] = 20'd222    ;  // 000de
        bright_lut[37] = 20'd238    ;  // 000ee
        bright_lut[38] = 20'd255    ;  // 000ff
        bright_lut[39] = 20'd272    ;  // 00110
        bright_lut[40] = 20'd290    ;  // 00122
        bright_lut[41] = 20'd309    ;  // 00135
        bright_lut[42] = 20'd329    ;  // 00149
        bright_lut[43] = 20'd349    ;  // 0015d
        bright_lut[44] = 20'd371    ;  // 00173
        bright_lut[45] = 20'd392    ;  // 00188
        bright_lut[46] = 20'd415    ;  // 0019f
        bright_lut[47] = 20'd438    ;  // 001b6
        bright_lut[48] = 20'd463    ;  // 001cf
        bright_lut[49] = 20'd488    ;  // 001e8
        bright_lut[50] = 20'd513    ;  // 00201
        bright_lut[51] = 20'd540    ;  // 0021c
        bright_lut[52] = 20'd567    ;  // 00237
        bright_lut[53] = 20'd596    ;  // 00254
        bright_lut[54] = 20'd625    ;  // 00271
        bright_lut[55] = 20'd654    ;  // 0028e
        bright_lut[56] = 20'd685    ;  // 002ad
        bright_lut[57] = 20'd717    ;  // 002cd
        bright_lut[58] = 20'd749    ;  // 002ed
        bright_lut[59] = 20'd782    ;  // 0030e
        bright_lut[60] = 20'd816    ;  // 00330
        bright_lut[61] = 20'd851    ;  // 00353
        bright_lut[62] = 20'd887    ;  // 00377
        bright_lut[63] = 20'd924    ;  // 0039c
    end

    reg [31:0] duty;
    reg [31:0] counter;
    reg [5:0] idx;
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
            duty <= 1'b0;
            counter <= 32'b0;
            up <= 1'b1;
            idx <= 1'b0;
        end else begin 
            if (counter >= period) begin
                if (up) begin
                    if (idx == BRIGHT_STEPS-1) up <= 1'b0;
                    else                       idx <= idx + 1'b1;
                end else begin
                    if (idx == 0) up <= 1'b1;
                    else          idx <= idx - 1'b1;
                end
                duty <= bright_lut[idx];
                counter <= 32'b0;
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end
endmodule