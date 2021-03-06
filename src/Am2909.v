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
    reg [3:0] microprogram_counter;
    reg [1:0] stack_pointer;
    reg [3:0] stack [0:3];

    wire [3:0] incremented;
    wire [3:0] before_output;

    initial begin
        stack_pointer <= 2'b11;
    end

    // Clock in new uPC value
    always @ (posedge CP) begin
        microprogram_counter <= incremented;
    end

    // Clock in Address Register values
    always @ (posedge CP) begin
        if (RE == 1'b0) begin
            address_register <= R;
        end
    end

    // Pop or push stack
    always @ (posedge CP) begin
        if (FE == 1'b0) begin
            if (PUP == 1'b1) begin
                // PUSH
                stack_pointer = stack_pointer + 1;
                stack[stack_pointer] = microprogram_counter;
            end
            else begin
                // POP
                stack_pointer = stack_pointer - 1;
            end
        end
    end

    // Multiplexer
    assign before_output = (S == 2'b00) ? microprogram_counter : ((S == 2'b01) ? address_register : ((S == 2'b10) ? stack[stack_pointer] : ((S == 2'b11) ? D : 4'b0000)));

    // Incrementer
    assign incremented = Y + C;

    // Output Control
    assign Y = (OE == 1'b0) ? ((ZERO == 1'b0) ? 4'b0000 : before_output | OR) : 4'bzzzz;

endmodule
