`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2026 03:03:43 PM
// Design Name: 
// Module Name: Hazard_Unit
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


module Hazard_Unit(
 input [4:0] rs1E,
 input [4:0] rdM,
 input RegWriteM,
 input [4:0] rdW,
 input RegWriteW,
 input [4:0] rs2E,
 input ResultSrcE0,
 input [4:0] rs1,
 input [4:0] rs2,
 input [4:0] rdE,
 input PCSrc,
 output stallF,
 output stallD,
 input FlushD,
 output FlushE,
 output [1:0] ForwardAE,
 output [1:0] ForwardBE
    );
    
    wire lwstall;
//    assign ForwardAE = ((rs1E == rdM) && RegWriteM) && (rs1E != 0)) ? 2'b10 : ((rs1E == rdW) && RegWriteW) && ( rs1E != 0)) ? 2'b01:2'b00;
    assign ForwardAE = ((rs1E == rdM) && RegWriteM && (rs1E != 0)) ? 2'b10 :
                   ((rs1E == rdW) && RegWriteW && (rs1E != 0)) ? 2'b01 :
                   2'b00;
    assign ForwardBE = ((rs2E == rdM) && RegWriteM && (rs2E != 0)) ? 2'b10 :
                   ((rs2E == rdW) && RegWriteW && (rs2E != 0)) ? 2'b01 :
                   2'b00;
    assign lwstall = (ResultSrcE0 && ((rs1 == rdE) || (rs2 == rdE)))? 1'b1:1'b0;
    assign stallF = lwstall;
    assign stallD = lwstall;
    assign FlushE = lwstall|PCSrc;
    assign FlushD = PCSrc;
    
endmodule
