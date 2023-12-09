`timescale 1ns / 1ps

module main(
    input clk,
    input RsRx,
    input btnU,
    input btnD,
    output RsTx,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output wire Hsync,
    output wire Vsync,
    output [6:0] seg,
    output [3:0] an
    );

    wire [9:0] x,y;
    wire [3:0] movement;
    wire [11:0] rgb_out;
    wire [19:0] clk_div;
    wire [8:0] scorePlayer1;
    wire [8:0] scorePlayer2;
    
    assign clk_div[0] = clk;
    assign vgaBlue = {rgb_out[3],rgb_out[2],rgb_out[1],rgb_out[0]}; // assign rgb_out to vgaBlue, vgaGreen, vgaRed
    assign vgaGreen = {rgb_out[7],rgb_out[6],rgb_out[5],rgb_out[4]};
    assign vgaRed = {rgb_out[11],rgb_out[10],rgb_out[9],rgb_out[8]};
    
    generate for(genvar i = 0;i<19;i = i+1) begin // divine clock by 2^19 for 7 segment display
        clock_divider div1(clk_div[i],clk_div[i+1]);
    end endgenerate
    
    uart keyboardUART(clk, RsRx, RsTx, movement, throwBall); // keyboard input
    gameLogic gameInstance( // main game logic and animation logic
        clk,
        btnU,// reset
        x,// position x
        y,// position y
        video_on, // videoOn show video where the value is 1
        movement, // player1Up, player1Down, player2Up, player2Down
        throwBall, // throwBall
        rgb_out, // rgb output of the position x y
        scorePlayer1,
        scorePlayer2
    );
    vga vga_render(.clk(clk), .reset(reset), .hsync(Hsync), .vsync(Vsync), .video_on(video_on), .p_tick(), .x(x), .y(y)); // vga render
    seven_segment_tdm segmentDisplay(clk_div[19],scorePlayer1[7:4],scorePlayer1[3:0],scorePlayer2[7:4],scorePlayer2[3:0],seg,an,1); // score 7 segment
endmodule