`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/15/2026 01:42:46 PM
// Design Name: 
// Module Name: Adder
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


module Adder(
 input clk,
 input rst,
 input signed [31:0] a,
 input signed [31:0] b,
 input add_en,
 output signed [31:0] result
    );
    
    
    reg [31:0] result_reg;
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            result_reg <= 0;
        else if (add_en)
            result_reg <= a+b;
    end
    
    assign result = (add_en) ? a+b:result_reg;
endmodule
