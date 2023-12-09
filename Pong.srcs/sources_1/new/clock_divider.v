`timescale 1ns / 1ps

module clock_divider (
    input clk,
    output clk_out
);

reg clk_out;

initial
begin
    clk_out = 0;
end

always @(posedge clk) begin
    clk_out = ~clk_out;
end
endmodule
