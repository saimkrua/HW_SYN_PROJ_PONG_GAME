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

    wire [9:0] x,y;
    wire [3:0] movement;
    wire [11:0] rgb_out;
    
    assign vgaBlue = {rgb_out[3],rgb_out[2],rgb_out[1],rgb_out[0]}; // assign rgb_out to vgaBlue, vgaGreen, vgaRed
    assign vgaGreen = {rgb_out[7],rgb_out[6],rgb_out[5],rgb_out[4]};
    assign vgaRed = {rgb_out[11],rgb_out[10],rgb_out[9],rgb_out[8]};
//    assign vgaBlue = {rgb_out[2],rgb_out[2],rgb_out[2]}; // assign rgb_out to vgaBlue, vgaGreen, vgaRed
//    assign vgaGreen = {rgb_out[1],rgb_out[1],rgb_out[1]};
//    assign vgaRed = {rgb_out[0],rgb_out[0],rgb_out[0]};
    
    uart keyboardUART(clk, RsRx, RsTx, movement, throwBall); // keyboard input
    gameLogic gameInstance( // main game logic and animation logic
        clk,
        btnU,// reset
        x,// position x
        y,// position y
        video_on, // videoOn show video where the value is 1
        movement, // player1Up, player1Down, player2Up, player2Down
        throwBall, // throwBall
        rgb_out // rgb output of the position x y
    );
    vga vga_render(.clk(clk), .reset(reset), .hsync(Hsync), .vsync(Vsync),
                                .video_on(video_on), .p_tick(), .x(x), .y(y)); // vga render
    
endmodule