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
    output wire Vsync
    );
    
//    reg [7:0] player1Score;
//    reg [7:0] player2Score;

    wire [9:0] x,y;
    wire player1Up, player1Down, player2Up, player2Down, throwBall;
    wire [4:0] wsplspace;
    wire [2:0] rgb_out;
//    wire scorePlayer1Count;
//    wire scorePlayer2Count;
    
    assign {player1Up,player1Down,player2Up,player2Down,throwBall} = wsplspace; // assign wsplspace to player1Up, player1Down, player2Up, player2Down, throwBall
//    assign vgaBlue = {rgb_out[3],rgb_out[2],rgb_out[1],rgb_out[0]}; // assign rgb_out to vgaBlue, vgaGreen, vgaRed
//    assign vgaGreen = {rgb_out[7],rgb_out[6],rgb_out[5],rgb_out[4]};
//    assign vgaRed = {rgb_out[11],rgb_out[10],rgb_out[9],rgb_out[8]};
    assign vgaBlue = {rgb_out[2],rgb_out[2],rgb_out[2]}; // assign rgb_out to vgaBlue, vgaGreen, vgaRed
    assign vgaGreen = {rgb_out[1],rgb_out[1],rgb_out[1]};
    assign vgaRed = {rgb_out[0],rgb_out[0],rgb_out[0]};
    
    uart keyboardInput(clk, RsRx, RsTx, wsplspace); // keyboard input
    animationLogic animeLogic( // main game logic and animation logic
        clk,
        btnU,// reset
        x,// position x
        y,// position y
        1, //videoOn show video where the value is 1
        player1Up,// player1 up control
        player1Down,// player1 down control
        player2Up,// player2 up control
        player2Down,// player2 up control
        throwBall, // throwBall ball game after player get score (afk handle)
        rgb_out // rgb output of the position x y

    );
    vga vga_render(.clk(clk), .reset(reset), .hsync(Hsync), .vsync(Vsync),
                                .video_on(video_on), .p_tick(), .x(x), .y(y)); // vga render
    
endmodule