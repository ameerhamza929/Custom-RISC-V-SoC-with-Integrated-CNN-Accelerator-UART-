`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 03:10:32 PM
// Design Name: 
// Module Name: ALU
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


module ALU(
input [31:0] srcA,
input [31:0] srcB,
input [2:0] ALU_Ctrl,
output logic [31:0] ALU_result,
output logic zero
    );
    
    always_comb begin
        case(ALU_Ctrl)
            3'b000: ALU_result = srcA + srcB;
            3'b001: ALU_result = srcA - srcB;
            3'b010: ALU_result = srcA & srcB;
            3'b011: ALU_result = srcA | srcB;
            3'b100: ALU_result = srcA << srcB;
//            3'b1100: ALU_result = ~(srcA | srcB);
            3'b101: begin
                if(srcA<srcB)
                    ALU_result = 32'd1;
                else 
                    ALU_result = 32'd0;
            end
        endcase
       
    end
    
    assign zero = (srcA == srcB); 
    
endmodule
