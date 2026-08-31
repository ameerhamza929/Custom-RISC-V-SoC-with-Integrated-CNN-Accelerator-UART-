`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 02:30:16 PM
// Design Name: 
// Module Name: PC
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


module PC(
    input clk,
    input rst,
    input start,
    input [31:0]PCin,
    output logic [31:0] count
    );
    
    always@(*)begin
        count = PCin + 4;
        if(PCin == 0)begin
            if(start)begin
                count = PCin + 4;
            end
            else
                count = 0;
        end
            
    end
    
    
    
endmodule
