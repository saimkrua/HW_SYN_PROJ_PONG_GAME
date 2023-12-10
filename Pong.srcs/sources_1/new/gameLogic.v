`timescale 1ns / 1ps

module gameLogic(
    input clk,
    input reset,
    input [9:0] x,
    input [9:0] y,
    input videoOn,
    input [3:0] movement,
    input throwBall,
    output wire [11:0] rgb,
    output wire [7:0] leftScore,
    output wire [7:0] rightScore
);

    wire leftUp, leftDown, rightUp, rightDown; 
    assign {leftUp,leftDown,rightUp,rightDown} = movement;
    
    reg [7:0] totalLeftScore;
    reg [7:0] totalRightScore;
    reg scoreCheckerLeft;
    reg scoreCheckerRight;
    reg scorer; 
    reg scorerNext;

    /*======================= Paddle =============================*/
    parameter paddleWidth  = 8; // paddle width
    parameter paddleHeight = 200; // paddle height
    parameter paddleSpeed  = 4; // paddle speed
    /*================================================================*/
    
    /*======================= Ball =============================*/
    parameter ballDefaultX = 300; // default x ball
    parameter ballDefaultY = 300; // default y ball
    parameter ballRadius   = 8;  // ball radius
    parameter ballSpeedX   = 2;  // x ball speed
    parameter ballSpeedY   = 2;  // y ball speed
    /*================================================================*/

    /*======================= Color =============================*/
    parameter white     = 12'b111111111111;
    parameter bgColor   = 12'b101011001011;
    parameter ballColor = 12'b110001110000;
    parameter textColor = 12'b000001010101;
    parameter blue      = 12'b011010011111;
    parameter red       = 12'b100101011000;
    /*================================================================*/

    /*======================= Left Player =============================*/
    // paddle
    parameter leftPaddleX = 72;
    integer   leftPaddleY;
    integer   leftPaddleYNext;
    wire displayLeftPaddle;
    wire [11:0] rgbLeftPaddle;
    // score
    wire displayLeftScore;
    wire leftScoreFirstDigit; 
    wire leftScoreSecondDigit;
    wire [11:0] rgbLeftScore;
    /*================================================================*/
    
    /*======================= Right Player =============================*/
    // paddle
    parameter rightPaddleX = 560; 
    integer   rightPaddleY; 
    integer   rightPaddleYNext; 
    wire displayRightPaddle;
    wire [11:0] rgbRightPaddle;

    // score
    wire displayRightScore; 
    wire rightScoreFirstDigit; 
    wire rightScoreSecondDigit; 
    wire [11:0] rgbRightScore;
    /*================================================================*/

    
    /*======================= Game name =============================*/
    wire displayGameName;
    wire gameName;
    wire [11:0] rgbGameName; 
    
    /*======================= Ball =============================*/
    // the distance between the ball and left side of the screen
    integer ballX;
    integer ballXNext;
    // the distance between the ball and top side of the screen
    integer ballY;
    integer ballYNext;
    // the horizontal speed of the ball
    integer speedX; 
    integer speedXNext;
    // the vertical speed of the 
    integer speedY;
    integer speedYNext;
    // display
    wire displayBall; 
    wire [11:0] rgbBall;

    /*======================= Monitor =============================*/
    reg  [19:0] refreshReg;
    wire [19:0] refreshNext;
    parameter   refreshConstant = 830000;
    wire refreshRate;

    wire [6:0] outputMux; // Display mux

    reg  [11:0] rgbReg; 
    wire [11:0] rgbNext; 

    /*======================= Initial =============================*/
    initial begin
        speedY     = 0;
        speedYNext = 0;
        speedX     = 0;
        speedXNext = 0;
        
        ballX      = 320;
        ballXNext  = 320;
        ballY      = 240;
        ballYNext  = 240;

        leftPaddleY      = 340;
        leftPaddleYNext  = 340;
        rightPaddleY     = 340;
        rightPaddleYNext = 340;
    end

   
    /*======================= Left animation =============================*/
    always @(leftPaddleY or refreshRate or leftUp or leftDown) begin
        leftPaddleYNext <= leftPaddleY; // assign leftPaddleY to it's next value   
        if (refreshRate === 1'b1) 
        begin
            if (leftUp === 1'b1 & leftPaddleY - paddleHeight > paddleSpeed) 
            begin 
                // up button is pressed and paddle can move to up, which mean paddle is not on the top side of the screen.
                leftPaddleYNext <= leftPaddleY - paddleSpeed; // move paddle to the up   
            end

            else if (leftDown === 1'b1 & leftPaddleY < 500) 
            begin
                // down button is pressed and paddle can move down, which mean paddle is not on the bottom side of the screen
                leftPaddleYNext <= leftPaddleY + paddleSpeed;   // move paddle to the down.
            end

            else 
            begin
                leftPaddleYNext <= leftPaddleY;   
            end
        end
    end

    /*======================= Right animation =============================*/
    always @(rightPaddleY or refreshRate or rightUp or rightDown) 
    begin
        rightPaddleYNext <= rightPaddleY; // assign rightPaddleY to it's next value   
        if (refreshRate === 1'b1) 
        begin
            if (rightUp === 1'b1 & rightPaddleY - paddleHeight > paddleSpeed) 
            begin 
                // up button is pressed and paddle can move to up, which mean paddle is not on the top side of the screen.
                rightPaddleYNext <= rightPaddleY - paddleSpeed; // move paddle to the up   
            end

            else if (rightDown === 1'b1 & rightPaddleY < 500) 
            begin
                // down button is pressed and paddle can move down, which mean paddle is not on the bottom side of the screen
                rightPaddleYNext <= rightPaddleY + paddleSpeed;   // move paddle to the down.
            end

            else 
            begin
                rightPaddleYNext <= rightPaddleY;   
            end
        end
    end

    /*======================= Ball animation =============================*/
    always @(refreshRate or ballX or ballY or speedX or speedY) 
    begin
        ballXNext <= ballX;
        ballYNext <= ballY;

        speedXNext <= speedX;
        speedYNext <= speedY;

        scorerNext <= scorer;
        scoreCheckerLeft <= 1'b0; // player 1 did not scored, default value
        scoreCheckerRight <= 1'b0; // player 2 did not scored, default value

        if (refreshRate === 1'b1) begin
            if (ballY <= leftPaddleY & 
                ballY >= leftPaddleY - paddleHeight & 
                ballX <= leftPaddleX + paddleWidth + ballRadius & 
                ballX > leftPaddleX + ballRadius) 
            begin
                // if ball hits the left paddle
                speedXNext <= ballSpeedX; // set the direction of horizontal speed positive
            end

            if (ballY <= rightPaddleY & 
                ballY >= rightPaddleY - paddleHeight & 
                ballX >= rightPaddleX - ballRadius & 
                ballX < rightPaddleX + paddleWidth - ballRadius) 
            begin
                // if ball hits the right paddle
                speedXNext <= -1 * ballSpeedX; // set the direction of horizontal speed negative
            end

            if (ballY < 9) 
            begin
                // if ball hits the top side of the screen
                speedYNext <= ballSpeedY; // set the direction of vertical speed positive
            end

            if (ballY > 471) 
            begin
                // if ball hits the top side of the screen
                speedYNext <= -1 * ballSpeedY; // set the direction of vertical speed negative
            end
            
            ballXNext <= ballX + speedX; // move the ball's horizontal location   
            ballYNext <= ballY + speedY; // move the ball's vertical location
           
            if (ballX >= 630) 
            begin
                // if player 1 scores, ball passes through the horizontal location of right paddle.
                
                //reset the ball's location to its default
                ballXNext <= ballDefaultX;
                ballYNext <= ballDefaultY;

                // stop the ball
                speedXNext <= 0;
                speedYNext <= 0;

                // player 1 scored
                scorerNext <= 1'b0;
                scoreCheckerLeft <= 1'b1;
            end
            else
            begin
                scoreCheckerLeft <= 1'b0;   
            end

            if (ballX <= 8) 
            begin
                // if player 2 scores, ball passes through the horizontal location of left paddle.
                
                //reset the ball's location to its default
                ballXNext <= ballDefaultX;
                ballYNext <= ballDefaultY;

                // stop the ball
                speedXNext <= 0;
                speedYNext <= 0;

                // player 1 scored
                scorerNext <= 1'b1;
                scoreCheckerRight <= 1'b1;
            end
            else 
            begin
                scoreCheckerRight <= 1'b0;   
            end
        end
    end

    /*======================= Display =============================*/
    assign displayLeftPaddle = y < leftPaddleY & 
                               y > leftPaddleY - paddleHeight & 
                               x > leftPaddleX & 
                               x < leftPaddleX + paddleWidth ? 1'b1 : 1'b0; 

    assign displayRightPaddle = y < rightPaddleY & 
                                y > rightPaddleY - paddleHeight & 
                                x > rightPaddleX & 
                                x < rightPaddleX + paddleWidth ? 1'b1 : 1'b0; 
                                
    assign displayBall = (x-ballX)*(x-ballX) + (y-ballY)*(y-ballY) <= ballRadius*ballRadius ? 1'b1 : 1'b0;
   
    assign displayLeftScore = x >= 80 & x < 112 & y >= 236 & y < 244; 
    numberToPixel leftScoreFirstDigitConvertor(totalLeftScore[7:4], y - 236, x - 80, leftScoreFirstDigit);
    numberToPixel leftScoreSecondDigitCfonvertor(totalLeftScore[3:0], y - 236, x - 96, leftScoreSecondDigit);
    
    assign displayRightScore = x >= 528 & x < 560 & y >= 236 & y < 244; 
    numberToPixel rightFirstDigitConvertor(totalRightScore[7:4], y - 236, x - 528, rightFirstDigit);
    numberToPixel rightSecondDigitConvertor(totalRightScore[3:0], y - 236, x - 544, rightSecondDigit);
    
    assign displayGameName = x >= 290 & x < 350 & y >= 80 & y < 88;
    textToPixel gameNameConvertor(y - 80, x - 290, gameName);
    
    /*======================= Color =============================*/
    assign rgbLeftPaddle = blue;
    assign rgbRightPaddle = red;
    assign rgbBall = ballColor;
    assign rgbLeftScore = x >= 96 ? leftScoreSecondDigit ? textColor : bgColor
                                     : leftScoreFirstDigit ? textColor : bgColor;
    assign rgbRightScore = x >= 544 ? rightSecondDigit ? textColor : bgColor
                                      : rightFirstDigit ? textColor : bgColor;
    assign rgbGameName = gameName ? textColor : bgColor;
    
    /*======================= Next State =============================*/
    always @(posedge clk) begin
        refreshReg <= refreshNext;   
    end

    assign refreshNext = refreshReg === refreshConstant ? 0 : refreshReg + 1; 
    assign refreshRate = refreshReg === 0 ? 1'b1 : 1'b0; 

    always @(posedge clk or posedge reset) begin
        if (reset === 1'b1) begin
            // to reset the game
            ballX        <= ballDefaultX;
            ballY        <= ballDefaultY;
            leftPaddleY  <= 380;
            rightPaddleY <= 380;
            speedX       <= 0;
            speedY       <= 0;
        end
        else 
        begin
            speedX <= speedXNext; // assigns horizontal speed
            speedY <= speedYNext; // assigns vertical speed
            if (throwBall === 1'b1) 
            begin
                if (scorer === 1'b0) 
                begin
                    // if scorer is player 2 throw the ball to player 1.
                    speedX <= -1 * ballSpeedX;
                    speedY <= 1;
                end
                else
                begin
                    // if scorer is player 1 throw the ball to player 2.
                    speedX <= ballSpeedX;
                    speedY <= 1;
                end
            end

            ballX        <= ballXNext; // assigns the next value of the ball's location from the left side of the screen to it's location.
            ballY        <= ballYNext; // assigns the next value of the ball's location from the top side of the screen to it's location.  
            leftPaddleY  <= leftPaddleYNext; // assigns the next value of the left paddle's location from the top side of the screen to it's location.
            rightPaddleY <= rightPaddleYNext; // assigns the next value of the right paddle's location from the top side of the screen to it's location.
            scorer       <= scorerNext;
        end
    end


    always @(posedge clk) 
    begin 
        rgbReg <= rgbNext;   
    end

    assign outputMux = {videoOn, displayLeftPaddle, displayRightPaddle, displayBall, displayLeftScore, displayRightScore, displayGameName}; 
    assign rgbNext = outputMux === 7'b1000000 ? bgColor:
                     outputMux === 7'b1100000 ? rgbLeftPaddle: 
                     outputMux === 7'b1101000 ? rgbLeftPaddle: 
                     outputMux === 7'b1010000 ? rgbRightPaddle: 
                     outputMux === 7'b1011000 ? rgbRightPaddle: 
                     outputMux === 7'b1001000 ? rgbBall:
                     outputMux === 7'b1001010 ? rgbBall:
                     outputMux === 7'b1001100 ? rgbBall:
                     outputMux === 7'b1001001 ? rgbBall:
                     outputMux === 7'b1000100 ? rgbLeftScore:
                     outputMux === 7'b1000010 ? rgbRightScore:
                     outputMux === 7'b1000001 ? rgbGameName:
                     12'b000000000000;
                    
    /*======================= Output =============================*/
    assign rgb = rgbReg; 
    assign leftScore = totalLeftScore;
    assign rightScore = totalRightScore;

    /*======================= Score =============================*/
    always @(posedge clk)
    begin
        if (reset) 
        begin
            // Reset scores for both players
            totalLeftScore <= 8'd0;
            totalRightScore <= 8'd0;
        end
        else if (scoreCheckerLeft && !throwBall) 
        begin
            // Increment Player 1 score
            if (totalLeftScore[3:0] < 4'd9)
                totalLeftScore[3:0] <= totalLeftScore[3:0] + 1;
            else if (totalLeftScore[7:4] < 4'd9) 
            begin
                // If units digit is 9, increment tens and reset units
                totalLeftScore[3:0] <= 4'd0;
                totalLeftScore[7:4] <= totalLeftScore[7:4] + 1;
            end
        end
        else if (scoreCheckerRight & !throwBall) 
        begin
            // Increment Player 2 score
            if (totalRightScore[3:0] < 4'd9)
                totalRightScore[3:0] <= totalRightScore[3:0] + 1;
            else if (totalRightScore[7:4] < 4'd9) 
            begin
                // If units digit is 9, increment tens and reset units
                totalRightScore[3:0] <= 4'd0;
                totalRightScore[7:4] <= totalRightScore[7:4] + 1;
            end
        end
    end
    
endmodule