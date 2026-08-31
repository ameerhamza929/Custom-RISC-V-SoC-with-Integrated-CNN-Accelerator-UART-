`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2026 05:16:29 PM
// Design Name: 
// Module Name: mux3x1
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


module mux3x1(
    input [31:0] a,
    input [31:0] b,
    input [31:0] c,
    input [1:0] sel,
    output logic [31:0] out
    );
    
    always_comb begin
        case(sel)
            2'b00: out = a;
            2'b01: out = b;
            2'b10: out = c;
            default: out = 32'd0;
        endcase
    end
    
endmodule
