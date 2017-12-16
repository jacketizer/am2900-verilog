`timescale 1ns / 1ps

`include "assert.v"
`include "clock.v"

`define testSetup \
    CP = 1'b0; \
    OE = 1'b0; \
    D = 4'b0000; \
    #20

module Am2918Test();
    reg [3:0] D;
    wire [3:0] Q;
    wire [3:0] Y;
    reg CP;
    reg OE;

    Am2918 dut (D, CP, OE, Q, Y);

    `testClock(CP)

    // Output should be zero at first.
    initial begin
        #100
        `testSetup
        `assert(Q, 4'b0000)
        `assert(Y, 4'b0000)
    end

    // Inputs should be clocked in at raising edge of CP.
    initial begin
        #200
        `testSetup
        #20
        D = 4'b1111;
        #20
        `assert(Q, 4'b1111)
        `assert(Y, 4'b1111)
    end

    // Outputs should not be affected of changes occuring before raising edge
    // of CP.
    initial begin
        #300
        `testSetup
        #20
        D = 4'b1111;
        `assert(Q, 4'b0000)
        `assert(Y, 4'b0000)
    end

    // /OE high should set Y output to high-impendance async.
    initial begin
        #400
        `testSetup
        #20
        OE = 1'b1;
        #5
        `assert(Q, 4'b0000)
        `assert(Y, 4'bzzzz)
    end

    // Pulse /OE does not reset state.
    initial begin
        #500
        `testSetup
        #20
        D = 4'b1111;
        #20
        OE = 1'b1;
        #20
        OE = 1'b0;
        #5
        `assert(Q, 4'b1111)
        `assert(Y, 4'b1111)
    end
    
    initial begin
        #1000
        $finish;
    end
endmodule
