`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/15/2026 02:42:28 PM
// Design Name: 
// Module Name: Multiplier
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Multiplier(
    input        [7:0] a,
    input signed [7:0] b,
    output signed [31:0] result
);

// Pad 'a' with a 0 to make it a positive 9-bit signed number, 
// then multiply with signed 'b'.
assign result = $signed({1'b0, a}) * b;

endmodule