`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2026 03:20:00 PM
// Design Name: 
// Module Name: IF_ID
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


module IF_ID(
    input clk,
    input rst,
    input en,
    input flashD,
    input [31:0] InstrF,   
    input [31:0] PCF,     
    input [31:0] PCplus4F, 
    output logic [31:0] InstrD,
    output logic [31:0] PCD,
    output logic [31:0] PCplus4D 
 );
    
    
    always@(posedge clk or posedge rst)begin
        if(rst||flashD)begin
            InstrD <= 32'd0; 
            PCD    <= 32'd0;    
            PCplus4D <= 32'd0;
        end
        else begin
            if(en)begin
                InstrD <=     InstrF; 
                PCD    <=     PCF;     
                PCplus4D <=   PCplus4F; 
            end
        end
    
    end
    
endmodule
