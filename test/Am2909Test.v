`timescale 1ns / 1ps

`include "assert.v"
`include "clock.v"

`define testSetup \
    FE = 1'b1; \
    PUP = 1'b1; \
    RE = 1'b0; \
    D = 4'b0000; \
    R = 4'b0000; \
    S = 2'b11; \
    OE = 1'b0; \
    CP = 1'b0; \
    OR = 4'b0000; \
    ZERO = 1'b1; \
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

    // Direct Inputs (D) should be redirected to Y if S is 11 (async).
    initial begin
        #500
        `testSetup
        S = 2'b11;
        D = 4'b0101;
        #1
        `assert(Y, 4'b0101)
        #19
        `assert(Y, 4'b0101)
    end

    // Microprogram register should increment at posedge of CP.
    initial begin
        #600
        `testSetup
        S = 2'b00;
        #1
        `assert(Y, 4'b0001)
        #20
        `assert(Y, 4'b0010)
        #20
        `assert(Y, 4'b0011)
    end

    // If ZERO is low, Y should be zero (async).
    initial begin
        #700
        `testSetup
        R = 4'b1111;
        S = 2'b01;
        RE = 1'b0;
        #20
        RE = 1'b1;
        `assert(Y, 4'b1111)
        #1
        ZERO = 1'b0;
        #1
        `assert(Y, 4'b0000)
        #20
        `assert(Y, 4'b0000)
    end

    // If OR[i] is high, Y[i] should be high (async).
    initial begin
        #800
        `testSetup
        R = 4'b1010;
        S = 2'b01;
        RE = 1'b0;
        #20
        RE = 1'b1;
        `assert(Y, 4'b1010)
        #1
        OR = 4'b1111;
        #1
        `assert(Y, 4'b1111)
        #20
        `assert(Y, 4'b1111)
    end

    // ZERO should have higher priority than OR.
    initial begin
        #900
        `testSetup
        R = 4'b0101;
        S = 2'b01;
        RE = 1'b0;
        #20
        RE = 1'b1;
        `assert(Y, 4'b0101)
        #1
        OR = 4'b1111;
        #1
        `assert(Y, 4'b1111)
        #1
        ZERO = 1'b0;
        #1
        `assert(Y, 4'b0000)
    end

    // If OE is high, the Y outputs should be in high-impedance state.
    initial begin
        #1000
        `testSetup
        OE = 1'b1;
        #1
        `assert(Y, 4'bzzzz)
    end

    // Test to push and pop stack.
    initial begin
        #1100
        `testSetup
        R = 4'b0001;
        S = 2'b01;
        RE = 1'b0;
        #20
        `assert(Y, 4'b0001)
        #20
        `assert(Y, 4'b0001)
        S = 2'b00;
        #1
        `assert(Y, 4'b0010)

        // Push uPC
        FE = 1'b0;
        PUP = 1'b1;
        #20
        `assert(Y, 4'b0011)

        // Push uPC again
        #20
        `assert(Y, 4'b0100)

        // Push uPC again
        #20
        `assert(Y, 4'b0101)

        // Push uPC again
        #20
        `assert(Y, 4'b0110)

        // Stop pushing
        FE = 1'b1;

        // Let Y be STK0
        S = 2'b10;
        #1
        `assert(Y, 4'b0101)

        // Pop stack and assert outputs
        FE = 1'b0;
        PUP = 1'b0;
        #20
        `assert(Y, 4'b0100)

        // Pop stack and assert outputs
        #20
        `assert(Y, 4'b0011)

        // Pop stack and assert outputs
        #20
        `assert(Y, 4'b0010)
    end

    initial begin
        #2000
        $finish;
    end
endmodule
