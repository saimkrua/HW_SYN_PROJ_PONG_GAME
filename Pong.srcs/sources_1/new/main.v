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
    wire [8:0] scorePlayer1;
    wire [8:0] scorePlayer2;
    wire [19:0] clk_div;

    /*======================= IO =============================*/    
    uart keyboardUART(clk, RsRx, RsTx, movement, throwBall); // keyboard input
    /*================================================================*/
    
    /*======================= GAMEINSTANCE =============================*/
    gameLogic gameInstance(
        clk, // in : clock
        btnU,// in : reset
        x,// in : position x from vga
        y,// in : position y from vga
        video_on, // in : show video from vga
        movement, // in : from IO {player1Up, player1Down, player2Up, player2Down}
        throwBall, // in : from IO
        rgb_out, // out : for output 
        scorePlayer1, // out : for 7 seg
        scorePlayer2 // out : for 7 seg
    );
    /*================================================================*/
    
    
    /*======================= VGA =============================*/
    assign vgaBlue = rgb_out[3:0];
    assign vgaGreen = rgb_out[7:4];
    assign vgaRed = rgb_out[11:8];
    
    vga vga_render(.clk(clk), .reset(reset), .hsync(Hsync), .vsync(Vsync), .video_on(video_on), .p_tick(), .x(x), .y(y));
    /*================================================================*/
    
    
    /*======================= SEVEN SEGMENT =============================*/
    assign clk_div[0] = clk;
    generate for(genvar i = 0;i<19;i = i+1) begin // divine clock by 2^19
        clock_divider div1(clk_div[i],clk_div[i+1]);
    end endgenerate
    
    seven_segment_tdm segmentDisplay(clk_div[19],scorePlayer1[7:4],scorePlayer1[3:0],scorePlayer2[7:4],scorePlayer2[3:0],seg,an,1);
    /*================================================================*/
    
endmodule