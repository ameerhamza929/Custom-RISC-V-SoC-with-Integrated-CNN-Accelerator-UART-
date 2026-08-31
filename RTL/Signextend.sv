`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2026 02:39:06 PM
// Design Name: 
// Module Name: Signextend
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




module Signextend(
    input  [11:0] imm,
    input  [12:0] branch_imm,
    input [20:0] jump_imm,
    input  branch,
    input jump,
    output [31:0] signextended
);

    assign signextended = jump ? {{11{jump_imm[20]}}, jump_imm}  : branch ?
                          {{19{branch_imm[12]}}, branch_imm} :
                          {{20{imm[11]}}, imm};

endmodule
