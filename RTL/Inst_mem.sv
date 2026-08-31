`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 02:34:54 PM
// Design Name: 
// Module Name: Inst_mem
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


module Inst_mem(
    input [31:0] PC,
    input start,
    output logic [31:0] inst    
    );
    
    logic [7:0]inst_reg[0:1023];       //Byte addressable
    
    initial begin
        $readmemh("D:/IC Design and Verification/Module 2 DSD/Convolution_engine/Convolution_engine.srcs/inst.txt", inst_reg); 
    end
    
    always@(*)begin
        if(PC==0)begin
            if(start)
                 inst = {inst_reg[PC+3],inst_reg[PC+2],inst_reg[PC+1],inst_reg[PC]};
        end
        else  inst = {inst_reg[PC+3],inst_reg[PC+2],inst_reg[PC+1],inst_reg[PC]};
    end
    
    //assign inst = {inst_reg[PC+3],inst_reg[PC+2],inst_reg[PC+1],inst_reg[PC]};
    
endmodule
