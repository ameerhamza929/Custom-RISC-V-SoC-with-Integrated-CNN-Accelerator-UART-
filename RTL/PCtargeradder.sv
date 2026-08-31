`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2026 05:13:43 PM
// Design Name: 
// Module Name: PCtargeradder
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


module PCtargeradder(
input [31:0] A,
input [31:0] B,
output [31:0]result
    );
    
    assign result = A + B;
    
endmodule
