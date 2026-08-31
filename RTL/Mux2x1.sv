`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 05:53:26 PM
// Design Name: 
// Module Name: Mux2x1
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


module Mux2x1 #(
  parameter WIDTH = 32
)(
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    input sel,
    output [WIDTH-1:0] out
    );
    
    assign out = (sel) ? B:A;
    
endmodule
