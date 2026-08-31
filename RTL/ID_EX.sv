`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2026 03:43:25 PM
// Design Name: 
// Module Name: ID_EX
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


module ID_EX(
    input clk,
    input rst,
    input en,
    input RegWriteD,
    input [1:0]ResultSrcD,
    input MemWriteD,
    input JumpD,
    input BranchD,
    input [2:0]ALUControlD,
    input ALUSrcD,
    input [31:0]rdata1,
    input [31:0]rdata2,
    input [31:0]PCD,
    input [4:0]rs1D,
    input [4:0]rs2D,
    input [4:0]rdD,
    input [31:0] ImmExtD,
    input [31:0] PCplus4D,
    input [6:0] opcode,
    output logic RegWriteE,
    output logic [1:0] ResultSrcE,
    output logic MemWriteE,
    output logic JumpE,
    output logic BranchE,
    output logic [2:0]ALUControlE,
    output logic ALUSrcE,
    output logic [31:0]rdata1E,
    output logic [31:0]rdata2E,
    output logic [31:0]PCE,
    output logic [4:0]rs1E,
    output logic [4:0]rs2E,
    output logic [4:0]rdE,
    output logic [31:0] ImmExtE,
    output logic [31:0] PCplus4E,
    output logic [6:0] opcodeE
  );
  
  always@(posedge clk or posedge rst)begin
        if(rst)begin
            RegWriteE       <= 0;
            ResultSrcE      <= 0;
            MemWriteE       <= 0;
            JumpE           <= 0;
            BranchE         <= 0;
            ALUControlE     <= 0;
            ALUSrcE         <= 0;
            rdata1E         <= 0;
            rdata2E         <= 0;
            PCE             <= 0;
            rs1E            <= 0;
            rs2E            <= 0;
            rdE             <= 0;
            ImmExtE         <= 0;
            PCplus4E        <= 0;   
            opcodeE         <= 0;                
        end
        else begin
            if(en)begin
                RegWriteE       <= RegWriteD;   
                ResultSrcE      <= ResultSrcD;  
                MemWriteE       <= MemWriteD; 
                JumpE           <= JumpD;  
                BranchE         <= BranchD;     
                ALUControlE     <= ALUControlD; 
                ALUSrcE         <= ALUSrcD;
                rdata1E         <= rdata1;    
                rdata2E         <= rdata2;    
                PCE             <= PCD;    
                rs1E            <= rs1D;        
                rs2E            <= rs2D;       
                rdE             <= rdD;       
                ImmExtE         <= ImmExtD;     
                PCplus4E        <= PCplus4D;    
                opcodeE         <= opcode;
            end
            else begin
                RegWriteE       <= 0;
                ResultSrcE      <= 0;
                MemWriteE       <= 0;
                JumpE           <= 0;
                BranchE         <= 0;
                ALUControlE     <= 0;
                ALUSrcE         <= 0;
                rdata1E         <= 0;
                rdata2E         <= 0;
                PCE             <= 0;
                rs1E            <= 0;
                rs2E            <= 0;
                rdE             <= 0;
                ImmExtE         <= 0;
                PCplus4E        <= 0;
            end
        end
  
  end
  
  
  
endmodule
