`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2026 04:33:21 PM
// Design Name: 
// Module Name: EX_MEM
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


module EX_MEM(
    input clk,
    input rst,
    input en,
    input RegWriteE,
    input [1:0]ResultSrcE,
    input MemWriteE,
    input [31:0] ALU_result,
    input [31:0] WriteDataE,
    input [4:0] RdE,
    input [31:0] PCplus4E,
    input [31:0] rdata2E,
    input [6:0]  opcodeE,
    output logic RegWriteM,
    output logic [1:0] ResultSrcM,
    output logic MemWriteM,
    output logic [31:0] ALU_resultM,
    output logic [31:0] WriteDataM,
    output logic [4:0] RdM,
    output logic [31:0] PCplus4M,
    output logic [31:0] rdata2M,
    output logic [6:0] opcodeM
    );
    
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            RegWriteM       <= 0;
            ResultSrcM      <= 0; 
            MemWriteM       <= 0; 
            ALU_resultM     <= 0;
            WriteDataM      <= 0;
            RdM             <= 0;
            PCplus4M        <= 0;
            rdata2M         <= 0;
            opcodeM <= 0;
        end
        else begin
            if(en) begin
                RegWriteM       <= RegWriteE   ;
                ResultSrcM      <= ResultSrcE  ;
                MemWriteM       <= MemWriteE   ;
                ALU_resultM     <= ALU_result ;
                WriteDataM      <= WriteDataE  ;
                RdM             <= RdE         ;
                PCplus4M        <= PCplus4E    ;
                rdata2M         <= rdata2E;
                opcodeM <= opcodeE;
            end
        end
    
    end
    
endmodule
