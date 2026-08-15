

module chaser_to_pwm (
    input clk,
    input rst_n,
    input on,
    output reg [31:0] duty
);

    always @(posedge clk) begin
        if (!rst_n) begin
            duty <= 32'b0;
        end else begin
            if (on) duty <= 32'd10000;
            else duty <= 32'b0;
        end
    end
endmodule
