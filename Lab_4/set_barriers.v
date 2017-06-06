`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:27:40 05/30/2017 
// Design Name: 
// Module Name:    space_invaders_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module set_barriers(
    // Inputs
    input wire clk,
    input wire rst,
    input wire restart,
    input wire [1:0] mode,
    //Current X and Y of the screen
    input wire [10:0] xCoord,
    input wire [10:0] yCoord,
    // Damage input
    input wire [10:0] spaceshipLaserXcoord,
    input wire [10:0] spaceshipLaserYcoord,
/*
    input wire [65:0] alienLaserXcoord,
    input wire [65:0] alienLaserYcoord,
*/
    input wire [32:0] alienLaserXcoord,
    input wire [32:0] alienLaserYcoord,
    //Output that states whether the current position is a barrier
    output wire [7:0] rgb,
    output wire is_barrier,
    output reg spaceshipLaserHit,
    output reg [11:0] alienLaserHit
    );
     
`include "barrier_params.vh"
parameter LASER_HEIGHT = 11'd10;
    //format (from top left) [which_barrier] [xVal] [yVal] [health]
    reg [2:0] barrierInfo [3:0] [3:0] [3:0];
    reg [2:0] i;
    reg [2:0] k;
    reg [2:0] m;
    initial begin
        for(i = 3'b000; i <= 3'b011; i = i+1) begin
            for(k = 3'b000; k <= 3'b011; k = k+1) begin
                for(m = 3'b000; m <= 3'b011; m = m+1) begin
                    if(((k == 3'b000 || k == 3'b011) && m == 3'b011) || ((k == 3'b001 || k == 3'b010) && m > 3'b001)) begin
                        barrierInfo [i] [k] [m] <= 2'b00;
                    end
                    else begin
                        barrierInfo [i] [k] [m] <= 2'b11;
                    end
                end
            end
        end
    end
     
    //shifted x and y values for calculation of which barrier block we're "in" - values for display
    wire [1:0] currBarrier;
    wire [1:0] currXblk;
    wire [1:0] currYblk;
    wire inBarrier;
     
    //Get location of barrier for display
    extract_barrier_blk getDisplayVals(
        //Inputs
        .xCoord(xCoord), .yCoord(yCoord), 
        //Outputs
        .currBarrier(currBarrier), .xVal(currXblk), .yVal(currYblk), .inBarrier(displayInBarrier)
        );
    //variables to keep track of damage from spaceship
    wire [1:0] spaceshipDamageBarrier;
    wire [1:0] spaceshipDamageXblk;
    wire [1:0] spaceshipDamageYblk;
    wire isSpaceshipDamage;   
    //Check if the spaceship laser is in the barrier, and extract which barrier it's in
    extract_barrier_blk getSpaceshipDamageVals(
        //Inputs
        .xCoord(spaceshipLaserXcoord), .yCoord(spaceshipLaserYcoord),
        //Outputs
        .currBarrier(spaceshipDamageBarrier), .xVal(spaceshipDamageXblk), .yVal(spaceshipDamageYblk), .inBarrier(isSpaceshipDamage)
        );
    //Damage from bullet 0
    wire [1:0] alienDamageBarrier0;
    wire [1:0] alienDamageXblk0;
    wire [1:0] alienDamageYblk0;
    wire isAlienDamage0;
    //Damage from bullet 1
    wire [1:0] alienDamageBarrier1;
    wire [1:0] alienDamageXblk1;
    wire [1:0] alienDamageYblk1;
    wire isAlienDamage1;
    //Damage from bullet 2
    wire [1:0] alienDamageBarrier2;
    wire [1:0] alienDamageXblk2;
    wire [1:0] alienDamageYblk2;
    wire isAlienDamage2;
    /*
    //Damage from bullet 3
    wire [1:0] alienDamageBarrier3;
    wire [1:0] alienDamageXblk3;
    wire [1:0] alienDamageYblk3;
    wire isAlienDamage3;
    //Damage from bullet 4
    wire [1:0] alienDamageBarrier4;
    wire [1:0] alienDamageXblk4;
    wire [1:0] alienDamageYblk4;
    wire isAlienDamage4;
    //Damage from bullet 5
    wire [1:0] alienDamageBarrier5;
    wire [1:0] alienDamageXblk5;
    wire [1:0] alienDamageYblk5;
    wire isAlienDamage5;
    */
    extract_barrier_blk getAlienDamageVals0(
        .xCoord(alienLaserXcoord[10:0]), .yCoord(alienLaserYcoord[10:0]+LASER_HEIGHT),
        //Outputs
        .currBarrier(alienDamageBarrier0), .xVal(alienDamageXblk0), .yVal(alienDamageYblk0), .inBarrier(isAlienDamage0)
        );
    extract_barrier_blk getAlienDamageVals1(
        .xCoord(alienLaserXcoord[21:11]), .yCoord(alienLaserYcoord[21:11]+LASER_HEIGHT),
        //Outputs
        .currBarrier(alienDamageBarrier1), .xVal(alienDamageXblk1), .yVal(alienDamageYblk1), .inBarrier(isAlienDamage1)
        );
    extract_barrier_blk getAlienDamageVals2(
        .xCoord(alienLaserXcoord[32:22]), .yCoord(alienLaserYcoord[32:22]+LASER_HEIGHT),
        //Outputs
        .currBarrier(alienDamageBarrier2), .xVal(alienDamageXblk2), .yVal(alienDamageYblk2), .inBarrier(isAlienDamage2)
        );
    /*
    extract_barrier_blk getAlienDamageVals3(
        .xCoord(alienLaserXcoord[43:33]), .yCoord(alienLaserYcoord[43:33]+LASER_HEIGHT),
        //Outputs
        .currBarrier(alienDamageBarrier3), .xVal(alienDamageXblk3), .yVal(alienDamageYblk3), .inBarrier(isAlienDamage3)
        );
    extract_barrier_blk getAlienDamageVals4(
        .xCoord(alienLaserXcoord[54:44]), .yCoord(alienLaserYcoord[54:44]+LASER_HEIGHT),
        //Outputs
        .currBarrier(alienDamageBarrier4), .xVal(alienDamageXblk4), .yVal(alienDamageYblk4), .inBarrier(isAlienDamage4)
        );
    extract_barrier_blk getAlienDamageVals5(
        .xCoord(alienLaserXcoord[65:55]), .yCoord(alienLaserYcoord[65:55]+LASER_HEIGHT),
        //Outputs
        .currBarrier(alienDamageBarrier5), .xVal(alienDamageXblk5), .yVal(alienDamageYblk5), .inBarrier(isAlienDamage5)
        );
        */
/*
    //variables to keep track of damage from aliens
    wire [5:0] alienInBarrier;
    //Damage from bullet 1
    reg [10:0] alienDamageXcoord1;
    reg [10:0] alienDamageYcoord1;
    wire [1:0] alienDamageBarrier1;
    wire [1:0] alienDamageXblk1;
    wire [1:0] alienDamageYblk1;
    wire isAlienDamage1;
    //Damage from bullet 2
    reg [10:0] alienDamageXcoord2;
    reg [10:0] alienDamageYcoord2;
    wire [1:0] alienDamageBarrier2;
    wire [1:0] alienDamageXblk2;
    wire [1:0] alienDamageYblk2;
    wire isAlienDamage2;
    //Damage from bullet 3
    reg [10:0] alienDamageXcoord3;
    reg [10:0] alienDamageYcoord3;
    wire [1:0] alienDamageBarrier3;
    wire [1:0] alienDamageXblk3;
    wire [1:0] alienDamageYblk3;
    wire isAlienDamage3;
    //If we receive damage from an alien, see which barrier we damage
    extract_barrier_blk getAlienDamageVals1(
        //Inputs
        .xCoord(alienDamageXCoord1), .yCoord(alienDamageYcoord1+LASER_HEIGHT), 
        //Outputs
        .currBarrier(alienDamageBarrier1), .xVal(alienDamageXblk1), .yVal(alienDamageYblk1), .inBarrier(isAlienDamage1)
        );
    extract_barrier_blk getAlienDamageVals2(
        //Inputs
        .xCoord(alienDamageXCoord2), .yCoord(alienDamageYcoord2+LASER_HEIGHT), 
        //Outputs
        .currBarrier(alienDamageBarrier2), .xVal(alienDamageXblk2), .yVal(alienDamageYblk2), .inBarrier(isAlienDamage2)
        );
    extract_barrier_blk getAlienDamageVals3(
        //Inputs
        .xCoord(alienDamageXCoord3), .yCoord(alienDamageYcoord3+LASER_HEIGHT), 
        //Outputs
        .currBarrier(alienDamageBarrier3), .xVal(alienDamageXblk3), .yVal(alienDamageYblk3), .inBarrier(isAlienDamage3)
        );

 
    //Modules used to check if lasers from aliens are hitting barriers
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 0
    wire [1:0] alien0_ignoreBarr;
    wire [10:0] alien0_ignoreX;
    isInBarrier alien0_laser(
        //Inputs
        .xCoord(alienLaserXcoord[10:0]), .yCoord(alienLaserYcoord[10:0]),
       //Outputs
       .currBarrier(alien0_ignoreBarr), .inBarrier(alienInBarrier[0]), .shiftedXCoord(alien0_ignoreX)
        );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 1
    wire [1:0] alien1_ignoreBarr;
    wire [10:0] alien1_ignoreX;
    isInBarrier alien1_laser(
        //Inputs
        .xCoord(alienLaserXcoord[21:11]), .yCoord(alienLaserYcoord[21:11]),
       //Outputs
       .currBarrier(alien1_ignoreBarr), .inBarrier(alienInBarrier[1]), .shiftedXCoord(alien1_ignoreX)
        );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 2
    wire [1:0] alien2_ignoreBarr;
    wire [10:0] alien2_ignoreX;
    isInBarrier alien2_laser(
        //Inputs
        .xCoord(alienLaserXcoord[32:22]), .yCoord(alienLaserYcoord[32:22]),
       //Outputs
       .currBarrier(alien2_ignoreBarr), .inBarrier(alienInBarrier[2]), .shiftedXCoord(alien2_ignoreX)
        );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 3
    wire [1:0] alien3_ignoreBarr;
    wire [10:0] alien3_ignoreX;
    isInBarrier alien3_laser(
        //Inputs
        .xCoord(alienLaserXcoord[43:33]), .yCoord(alienLaserYcoord[43:33]),
       //Outputs
       .currBarrier(alien3_ignoreBarr), .inBarrier(alienInBarrier[3]), .shiftedXCoord(alien3_ignoreX)
        );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 4
    wire [1:0] alien4_ignoreBarr;
    wire [10:0] alien4_ignoreX;
    isInBarrier alien4_laser(
        //Inputs
        .xCoord(alienLaserXcoord[54:44]), .yCoord(alienLaserYcoord[54:44]),
       //Outputs
       .currBarrier(alien4_ignoreBarr), .inBarrier(alienInBarrier[4]), .shiftedXCoord(alien4_ignoreX)
        );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 5
    wire [1:0] alien5_ignoreBarr;
    wire [10:0] alien5_ignoreX;
    isInBarrier alien5_laser(
        //Inputs
        .xCoord(alienLaserXcoord[65:55]), .yCoord(alienLaserYcoord[65:55]),
       //Outputs
       .currBarrier(alien5_ignoreBarr), .inBarrier(alienInBarrier[5]), .shiftedXCoord(alien5_ignoreX)
        );

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 6
    wire [1:0] alien6_ignoreBarr;
    wire alien6_inBarrier;
    wire [9:0] alien6_ignoreX;
    isInBarrier alien6_laser(
        //Inputs
        .xCoord(alienLaserXcoord[69:60]), .yCoord(alienLaserYcoord[69:60]),
       //Outputs
       .currBarrier(alien6_ignoreBarr), .inBarrier(alien6_inBarrier), .shiftedXCoord(alien6_ignoreX)
        );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 7
    wire [1:0] alien7_ignoreBarr;
    wire alien7_inBarrier;
    wire [9:0] alien7_ignoreX;
    isInBarrier alien7_laser(
        //Inputs
        .xCoord(alienLaserXcoord[79:70]), .yCoord(alienLaserYcoord[79:70]),
       //Outputs
       .currBarrier(alien7_ignoreBarr), .inBarrier(alien7_inBarrier), .shiftedXCoord(alien7_ignoreX)
        );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 8
    wire [1:0] alien8_ignoreBarr;
    wire alien8_inBarrier;
    wire [9:0] alien8_ignoreX;
    isInBarrier alien8_laser(
        //Inputs
        .xCoord(alienLaserXcoord[89:80]), .yCoord(alienLaserYcoord[89:80]),
       //Outputs
       .currBarrier(alien8_ignoreBarr), .inBarrier(alien8_inBarrier), .shiftedXCoord(alien8_ignoreX)
        );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 9
    wire [1:0] alien9_ignoreBarr;
    wire alien9_inBarrier;
    wire [9:0] alien9_ignoreX;
    isInBarrier alien9_laser(
        //Inputs
        .xCoord(alienLaserXcoord[99:90]), .yCoord(alienLaserYcoord[99:90]),
       //Outputs
       .currBarrier(alien9_ignoreBarr), .inBarrier(alien9_inBarrier), .shiftedXCoord(alien9_ignoreX)
        );
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 10
    wire [1:0] alien10_ignoreBarr;
    wire alien10_inBarrier;
    wire [9:0] alien10_ignoreX;
    isInBarrier alien10_laser(
        //Inputs
        .xCoord(alienLaserXcoord[109:100]), .yCoord(alienLaserYcoord[109:100]),
       //Outputs
       .currBarrier(alien10_ignoreBarr), .inBarrier(alien10_inBarrier), .shiftedXCoord(alien10_ignoreX)
        );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 11
    wire [1:0] alien11_ignoreBarr;
    wire alien11_inBarrier;
    wire [9:0] alien11_ignoreX;
    isInBarrier alien11_laser(
        //Inputs
        .xCoord(alienLaserXcoord[119:110]), .yCoord(alienLaserYcoord[119:110]),
       //Outputs
       .currBarrier(alien11_ignoreBarr), .inBarrier(alien11_inBarrier), .shiftedXCoord(alien11_ignoreX)
        );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 12
    wire [1:0] alien12_ignoreBarr;
    wire alien12_inBarrier;
    wire [9:0] alien12_ignoreX;
    isInBarrier alien12_laser(
        //Inputs
        .xCoord(alienLaserXcoord[129:120]), .yCoord(alienLaserYcoord[129:120]),
       //Outputs
       .currBarrier(alien12_ignoreBarr), .inBarrier(alien12_inBarrier), .shiftedXCoord(alien12_ignoreX)
        );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 13
    wire [1:0] alien13_ignoreBarr;
    wire alien13_inBarrier;
    wire [9:0] alien13_ignoreX;
    isInBarrier alien13_laser(
        //Inputs
        .xCoord(alienLaserXcoord[139:130]), .yCoord(alienLaserYcoord[139:130]),
       //Outputs
       .currBarrier(alien13_ignoreBarr), .inBarrier(alien13_inBarrier), .shiftedXCoord(alien13_ignoreX)
        );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 14
    wire [1:0] alien14_ignoreBarr;
    wire alien14_inBarrier;
    wire [9:0] alien14_ignoreX;
    isInBarrier alien14_laser(
        //Inputs
        .xCoord(alienLaserXcoord[149:140]), .yCoord(alienLaserYcoord[149:140]),
       //Outputs
       .currBarrier(alien14_ignoreBarr), .inBarrier(alien14_inBarrier), .shiftedXCoord(alien14_ignoreX)
        );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 15
    wire [1:0] alien15_ignoreBarr;
    wire alien15_inBarrier;
    wire [9:0] alien15_ignoreX;
    isInBarrier alien15_laser(
        //Inputs
        .xCoord(alienLaserXcoord[159:150]), .yCoord(alienLaserYcoord[159:150]),
       //Outputs
       .currBarrier(alien15_ignoreBarr), .inBarrier(alien15_inBarrier), .shiftedXCoord(alien15_ignoreX)
        );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 16
    wire [1:0] alien16_ignoreBarr;
    wire alien16_inBarrier;
    wire [9:0] alien16_ignoreX;
    isInBarrier alien16_laser(
        //Inputs
        .xCoord(alienLaserXcoord[169:160]), .yCoord(alienLaserYcoord[169:160]),
       //Outputs
       .currBarrier(alien16_ignoreBarr), .inBarrier(alien16_inBarrier), .shiftedXCoord(alien16_ignoreX)
        );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 17
    wire [1:0] alien17_ignoreBarr;
    wire alien17_inBarrier;
    wire [9:0] alien17_ignoreX;
    isInBarrier alien17_laser(
        //Inputs
        .xCoord(alienLaserXcoord[179:170]), .yCoord(alienLaserYcoord[179:170]),
       //Outputs
       .currBarrier(alien17_ignoreBarr), .inBarrier(alien17_inBarrier), .shiftedXCoord(alien17_ignoreX)
        );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 18
    wire [1:0] alien18_ignoreBarr;
    wire alien18_inBarrier;
    wire [9:0] alien18_ignoreX;
    isInBarrier alien18_laser(
        //Inputs
        .xCoord(alienLaserXcoord[189:180]), .yCoord(alienLaserYcoord[189:180]),
       //Outputs
       .currBarrier(alien18_ignoreBarr), .inBarrier(alien18_inBarrier), .shiftedXCoord(alien18_ignoreX)
        );
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //Alien 19
    wire [1:0] alien19_ignoreBarr;
    wire alien19_inBarrier;
    wire [9:0] alien19_ignoreX;
    isInBarrier alien19_laser(
        //Inputs
        .xCoord(alienLaserXcoord[199:190]), .yCoord(alienLaserYcoord[199:190]),
       //Outputs
       .currBarrier(alien19_ignoreBarr), .inBarrier(alien19_inBarrier), .shiftedXCoord(alien19_ignoreX)
        );
*/
/*
    wire [1:0] alienIgnoreBarr;
    wire [10:0] alienIgnoreX;
    wire [5:0] alienInBarrier; 
    generate
        genvar n;
        for(n = 0; n < 6; n = n+1) 
            begin: check_aliens
                isInBarrier alien_laser(
                //Inputs
                .xCoord(alienLaserXcoord[10*n +: 11]), .yCoord(alienLaserYcoord[(10*n) +: 11]),
               //Outputs
               .currBarrier(alienIgnoreBarr), .inBarrier(alienInBarrier[n]), .shiftedXCoord(alien_ignoreX)
                );
            end
    endgenerate
*/
    reg is_barrier_temp;
    reg [7:0] rgb_temp;
    reg [4:0] index;
    reg [1:0] index1;
    reg [1:0] numAlienBullets; 
    always @ (posedge clk) begin
        if(rst || mode == 0 || mode == 1) begin
            for(i = 3'b000; i <= 3'b011; i = i+1) begin
                for(k = 3'b000; k <= 3'b011; k = k+1) begin
                    for(m = 3'b000; m <= 3'b011; m = m+1) begin
                        if(((k == 3'b000 || k == 3'b011) && m == 3'b011) || ((k == 3'b001 || k == 3'b010) && m > 3'b001)) begin
                            barrierInfo [i] [k] [m] <= 2'b00;
                        end
                        else begin
                            barrierInfo [i] [k] [m] <= 2'b11;
                        end
                    end
                end
        end
        end
        if(displayInBarrier && barrierInfo[currBarrier][currXblk][currYblk] != 3'b000) begin
            is_barrier_temp <= 1;
            rgb_temp <= {2'b00, barrierInfo[currBarrier][currXblk][currYblk], 4'b1000};
        end
        else begin
            is_barrier_temp <= 0;
            rgb_temp <= 7'd0;
        end

/*        numAlienBullets = 0;
        for(index = 0; index < 6; index = index+1) begin
            if(alienInBarrier[index]) begin
                if(numAlienBullets == 0) begin
                    numAlienBullets = 1;
                    alienDamageXcoord1 = alienLaserXcoord[(index*11) +: 11];
                    alienDamageYcoord1 = alienLaserYcoord[(index*11) +: 11];
                end
                else if(numAlienBullets == 1) begin
                    numAlienBullets = 2;
                    alienDamageXcoord2 = alienLaserXcoord[(index*11) +: 11];
                    alienDamageYcoord2 = alienLaserYcoord[(index*11) +: 11];
                end
                else if (numAlienBullets == 2) begin
                    numAlienBullets = 3;
                    alienDamageXcoord3 = alienLaserXcoord[(index*11) +: 11];
                    alienDamageYcoord3 = alienLaserYcoord[(index*11) +: 11];
                end
            end
        end
*/
        if(isSpaceshipDamage && barrierInfo [spaceshipDamageBarrier][spaceshipDamageXblk][spaceshipDamageYblk] != 3'b000) begin
            barrierInfo [spaceshipDamageBarrier][spaceshipDamageXblk][spaceshipDamageYblk] <= barrierInfo [spaceshipDamageBarrier][spaceshipDamageXblk][spaceshipDamageYblk] - 1;
            spaceshipLaserHit <= 1;
        end
        else begin
            spaceshipLaserHit <= 0;
        end
        if(isAlienDamage0 && barrierInfo [alienDamageBarrier0][alienDamageXblk0][alienDamageYblk0] != 3'b000) begin
            barrierInfo [alienDamageBarrier0][alienDamageXblk0][alienDamageYblk0] <= barrierInfo [alienDamageBarrier0][alienDamageXblk0][alienDamageYblk0] - 1;
            alienLaserHit[6] <= 1;
        end
        else begin
            alienLaserHit[6] <= 0;
        end
        if(isAlienDamage1 && barrierInfo [alienDamageBarrier1][alienDamageXblk1][alienDamageYblk1] != 3'b000) begin
            barrierInfo [alienDamageBarrier1][alienDamageXblk1][alienDamageYblk1] <= barrierInfo [alienDamageBarrier1][alienDamageXblk1][alienDamageYblk1] - 1;
            alienLaserHit[7] <= 1;
        end
        else begin
            alienLaserHit[7] <= 0;
        end
        if(isAlienDamage2 && barrierInfo [alienDamageBarrier2][alienDamageXblk2][alienDamageYblk2] != 3'b000) begin
            barrierInfo [alienDamageBarrier2][alienDamageXblk2][alienDamageYblk2] <= barrierInfo [alienDamageBarrier2][alienDamageXblk2][alienDamageYblk2] - 1;
            alienLaserHit[8] <= 1;
        end
        else begin
            alienLaserHit[8] <= 0;
        end
        /*
        if(isAlienDamage3 && barrierInfo [alienDamageBarrier3][alienDamageXblk3][alienDamageYblk3] != 3'b000) begin
            barrierInfo [alienDamageBarrier3][alienDamageXblk3][alienDamageYblk3] <= barrierInfo [alienDamageBarrier3][alienDamageXblk3][alienDamageYblk3] - 1;
            alienLaserHit[9] <= 1;
        end
        else begin
            alienLaserHit[9] <= 0;
        end
        if(isAlienDamage4 && barrierInfo [alienDamageBarrier4][alienDamageXblk4][alienDamageYblk4] != 3'b000) begin
            barrierInfo [alienDamageBarrier4][alienDamageXblk4][alienDamageYblk4] <= barrierInfo [alienDamageBarrier4][alienDamageXblk4][alienDamageYblk4] - 1;
            alienLaserHit[10] <= 1;
        end
        else begin
            alienLaserHit[10] <= 0;
        end
        if(isAlienDamage5 && barrierInfo [alienDamageBarrier5][alienDamageXblk5][alienDamageYblk5] != 3'b000) begin
            barrierInfo [alienDamageBarrier5][alienDamageXblk5][alienDamageYblk5] <= barrierInfo [alienDamageBarrier5][alienDamageXblk5][alienDamageYblk5] - 1;
            alienLaserHit[11] <= 1;
        end
        else begin
            alienLaserHit[11] <= 0;
        end
        */
    end
  
    assign rgb = rgb_temp;
    assign is_barrier = is_barrier_temp;

endmodule 
