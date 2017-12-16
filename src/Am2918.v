`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:  Am2918 - Quad D Register with Standard and Three-State Outputs
// Project Name: Am2900 Family
// Description:  From The Am2900 Family Data Book:
//   "The Am2918 consists of four D-type flip-flops with a buffered common clock.
//   Information meeting the setup and hold requirements on the D inputs is
//   transferred to the Q outputs on the LOW-to-HIGH transition of the clock.
//
//   The same data as on the Q outputs is enabled at the three-state Y outputs
//   when the 'output-control' (/OE) input is LOW. When the /OE input is HIGH, the
//   Y outputs are in the high-impendance state."
// Dependencies: N/A
//////////////////////////////////////////////////////////////////////////////////


module Am2918(
    input [3:0] D,  // Data Inputs
    input CP,       // Common Clock
    input OE,       // Output Control
    input [3:0] Q,  // Standard Outputs
    input [3:0] Y   // Three-State Outputs
    );

    reg [3:0] storage;
 
    always @ (posedge CP) storage <= D;

    assign Q = storage;
    assign Y = ~OE ? storage : 4'bzzzz;

endmodule
