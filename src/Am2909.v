`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:  Am2909 - Microprogram Sequencer
// Project Name: Am2900 Family
// Description:  From The Am2900 Family Data Book:
//   "The Am2909 is a four-bit wide address controller intended
//   for sequencing through a series of microintructions contained
//   in a ROM or PROM."
// Dependencies: N/A
//////////////////////////////////////////////////////////////////////////////////


module Am2909(
    input FE,       // Enable Line for Register File
    input PUP,      // Control Lines for Push/Pop Stack
    input RE,       // Enable Line for Internal Address Register
    input [3:0] D,  // Direct Inputs
    input [3:0] R,  // Inputs to the Internal Address Register
    input [1:0] S,  // Control Lines for Address Source Selection
    input OE,       // Output Enable
    input CP,       // Common Clock
    input [3:0] OR, // Logic OR Inputs on Each Address Output Line
    input ZERO,     // Logic AND Input on the Output Lines
    input C,        // Carry-in to the Incrementer
    output [3:0] Y  // Address Outputs
    );

    reg [3:0] address_register;

    always @ (posedge CP) begin
        // Address Register
        if (RE == 1'b0) begin
            address_register <= R;
        end
    end

    // Multiplexer
    assign Y = (S == 2'b01) ? address_register : 4'b000;

endmodule