`timescale 1ns / 1ps

module uart(
    input clk,
    input RsRx,
    output RsTx,
    output wire [3:0] movementIO,
    output wire throwIO
    );
    
    reg en, last_rec;
    reg [7:0] data_in;
    reg [3:0] movement = 4'b0000; // player1Up, player1Down, player2Up, player2Down
    reg throw = 1'b0; // throw
    wire [7:0] data_out;
    wire sent, received, baud;
    
    assign movementIO = movement;
    assign throwIO = throw;
    
    baudrate_gen baudrate_gen(clk, baud); // generate baud rate
    uart_rx receiver(baud, RsRx, received, data_out); // encode data to 8 bits
    uart_tx transmitter(baud, data_in, en, sent, RsTx); // check if input is valid
    
    always @(posedge baud) begin
        if (en) en = 0;
        if (~last_rec & received) begin
            data_in = data_out;
            if (data_in == 8'h77 || data_in == 8'h73 || data_in == 8'h70 || data_in == 8'h6C || data_in == 8'h20) en = 1; // recieve w,s,p,l,space keys
        end
        last_rec = received;
    end
    
    /*movement*/
    always @(posedge sent) begin
        if (sent) begin
            case (data_in)
                8'h77: movement[3:2] = 2'b10; // w : player 1 up
                8'h73: movement[3:2] = 2'b01; // s : player 1 down
                8'h70: movement[1:0] = 2'b10; // p : player 2 up
                8'h6C: movement[1:0] = 2'b01; // l : player 2 down
            endcase
        end
    end
    
    /*throw ball*/
    always @(posedge sent) begin
        if(sent) begin 
            if(data_in == 8'h20) throw = 1'b1; // space pressed
            else throw = 1'b0; // space released
        end
    end
    
endmodule
