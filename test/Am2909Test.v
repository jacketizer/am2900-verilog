`timescale 1ns / 1ps

`include "assert.v"
`include "clock.v"

`define testSetup \
    FE = 1'b1; \
    PUP = 1'b1; \
    RE = 1'b0; \
    D = 4'b0000; \
    R = 4'b0000; \
    S = 2'b00; \
    OE = 1'b0; \
    CP = 1'b0; \
    OR = 4'b0000; \
    ZERO = 1'b0; \
    C = 1'b0; \
    #20 RE = 1'b1; \
    #1

module Am2909Test();
    reg FE;
    reg PUP;
    reg RE;
    reg [3:0] D;
    reg [3:0] R;
    reg [1:0] S;
    reg OE;
    reg CP;
    reg [3:0] OR;
    reg ZERO;
    reg C;
    wire [3:0] Y;

    Am2909 dut (FE, PUP, RE, D, R, S, OE, CP, OR, ZERO, C, Y);

    `testClock(CP)

    // Output should be zero at first.
    initial begin
        #100
        `testSetup
        `assert(Y, 4'b0000)
    end

    // Address Register should latch data on posedge of CP if RE is 0.
    initial begin
        #200
        `testSetup
        R = 4'b1111;
        S = 2'b01;
        RE = 1'b0;
        #20
        `assert(Y, 4'b1111)
    end

    // Address Register should not latch data unless posedge CP.
    initial begin
        #300
        `testSetup
        S = 2'b01;
        R = 4'b1111;
        RE = 1'b0;
        #1
        `assert(Y, 4'b0000)
    end

    // Address Register should not latch data if RE is 1.
    initial begin
        #400
        `testSetup
        R = 4'b1111;
        S = 2'b01;
        RE = 1'b1;
        #20
        `assert(Y, 4'b0000)
    end

    initial begin
        #1000
        $finish;
    end
endmodule
