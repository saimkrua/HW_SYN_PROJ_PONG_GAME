`timescale 1ns / 1ps

module textToPixel(
  input [2:0] rowNum,
  input [5:0] colNum,
  output reg pixel
);
  reg [63:0] pixels;
  
  always @(*) begin
    case(rowNum)
        3'b000: pixels = 64'b0000000000000000000000000000000000000001100000000000000000000000;
        3'b001: pixels = 64'b0000011000000001111000000000000000000001100000000000000001111000;
        3'b010: pixels = 64'b0000011000000001111000111000011011100001100111111110000001111000;
        3'b011: pixels = 64'b0000011000001110000110011000011001100001100000000110000000011000;
        3'b100: pixels = 64'b0000011000000110000110011000011001100001100000000110000000011000;
        3'b101: pixels = 64'b0000011000000110000110011000011001100001100111100110011000011000;
        3'b110: pixels = 64'b0000011110000110000110100111111001100001100110000110011000011000;
        3'b111: pixels = 64'b0000011110000110000110011000011000011110000001111000000111100000;

        default: pixels = 64'd0;
    endcase
    pixel = pixels[63 - colNum];
  end    
endmodule
