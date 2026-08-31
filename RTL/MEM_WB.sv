`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2026 04:56:01 PM
// Design Name: 
// Module Name: MEM_WB
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


module MEM_WB(
    input clk,
    input rst,
    input en,
    input RegWriteM,
    input [1:0] ResultSrcM,
    input [31:0] read_data_mem,
    input [4:0]RdM,
    input [31:0] PCplus4M,
    input [31:0] ALU_resultM,
    input [6:0] opcodeM,
    output logic RegWriteW,
    output logic [1:0]ResultSrcW,
    output logic [31:0] read_data_mem_W,
    output logic [4:0]RdW,
    output logic [31:0] PCplus4W,
    output logic [31:0] ALU_resultW,
    output logic [6:0] opcodeW
    );
    
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            RegWriteW              <= 0; 
            ResultSrcW             <= 0;
            read_data_mem_W        <= 0;
            RdW                    <= 0; 
            PCplus4W               <= 0;  
            ALU_resultW            <= 0;
            opcodeW                <= 0;   
        end
        else begin
             if(en) begin
                RegWriteW             <=  RegWriteM       ;
                ResultSrcW            <=  ResultSrcM      ;
                read_data_mem_W       <=  read_data_mem   ;
                RdW                   <=  RdM             ;
                PCplus4W              <=  PCplus4M        ;
                ALU_resultW           <= ALU_resultM      ;
                opcodeW               <= opcodeM;
             end
        end
    
    end
    
    
endmodule
