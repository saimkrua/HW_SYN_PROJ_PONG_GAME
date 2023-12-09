`timescale 1ns / 1ps

module textToPixel(
  input [2:0] rowNum,
  input [5:0] colNum,
  output reg pixel
);
  reg [63:0] pixels;
  
  always @(*) begin
    case(rowNum)
        3'b000: pixels = 64'b0000011000000011111000011000011000000001100111111110000001111000;
        3'b001: pixels = 64'b0000011000000110000110011000011000000001100111111110000000011000;
        3'b010: pixels = 64'b0000011000000110000110001000011001000001100000000110000000011000;
        3'b011: pixels = 64'b0000011000000010000110001000011001000001100000000110000000011000;
        3'b100: pixels = 64'b0000011000000010000110001000011001000001100110000110010000011000;
        3'b101: pixels = 64'b0000011000000010000110010111111000111110000111111110011111111000;
        3'b110: pixels = 64'b0000000110000010000110001000011000111110000111111110011111111000;
        3'b111: pixels = 64'd0;

        default: pixels = 64'd0;
    endcase
    pixel = pixels[63 - colNum];
  end    
endmodule
