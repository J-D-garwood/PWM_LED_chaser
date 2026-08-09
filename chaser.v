// This is interesting but not quite the assignment 
// Its as simple as having four LEDs and lighting only 1 at a time.
// make the advance slow enough so its clear to the human eye

module chaser (
    input clk,
    input rst_n,
    output reg [3:0] out
);
    reg [31:0] counter;
    reg [31:0] period;

    always @(posedge clk) begin
        if (!rst_n) begin
            out <= 4'b0;
            counter <= 32'b0;
            period <= 32'h000000FF;
        end else begin
            if (counter == period) begin 
                counter <= 32'b0;
                out <= 4'b0;
            end else begin
                if (counter < (period >> 2)) begin out <= 4'b0001; end
                else if (counter < (period >> 1)) begin out <= 4'b0010; end
                else if (counter < ((period >> 1)+(period >> 2))) begin out <= 4'b0100; end
                else begin out <= 4'b1000; end
                counter <= counter + 1'b1;
            end
        end
    end
endmodule