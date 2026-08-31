`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 03:46:53 PM
// Design Name: 
// Module Name: Decoder
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


module Decoder(
 input [31:0] inst,
 output [6:0] opcode,
 output logic [4:0] rd,
 output logic [4:0] rs1,
 output logic [4:0] rs2,
 output logic [6:0] func7,
 output logic [2:0] func3,
 output logic [11:0] imm,
 output logic [12:0] branch_imm,
 output logic [20:0] jump_imm
    );
    
    
    parameter r_type = 7'b0110011;
    parameter s_type = 7'b0100011;
    parameter L_type = 7'b0000011;
    parameter b_type = 7'b1100011;
    parameter I_type = 7'b0010011;
    parameter J_type = 7'b1101111;
     
    assign opcode =  inst[6:0];
    
    always_comb begin
        rd = 0;
        func3 = 0;
        rs1 = 0;
        rs2 = 0;
        func7 = 0;
        imm  = 0;
        branch_imm = 0;
        jump_imm = 0;
        case(opcode)
            r_type:begin
                rd = inst[11:7];
                func3 = inst[14:12];
                rs1 = inst[19:15];
                rs2 = inst[24:20];
                func7 = inst[31:25];
            end
            
            s_type:begin
                imm = {inst[31:25],inst[11:7]};
                func3 = inst[14:12];
                rs1 = inst[19:15];
                rs2 = inst[24:20];
            end
            L_type: begin
                rd = inst[11:7];
                func3 = inst[14:12];
                rs1 = inst[19:15];
                imm = inst[31:20];
            end
            b_type: begin
                branch_imm = {inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
                func3 = inst[14:12];
                rs1 = inst[19:15];
                rs2 = inst[24:20];
            end
            
            I_type: begin
                rd = inst[11:7];
                func3 = inst[14:12];
                rs1 = inst[19:15];
                imm = inst[31:20];
            end
            
            J_type: begin
                rd = inst[11:7];
                jump_imm = {inst[31],inst[19:12],inst[20],inst[30:21],1'b0};    
            
            end
        
        endcase
    
    end
    
endmodule
