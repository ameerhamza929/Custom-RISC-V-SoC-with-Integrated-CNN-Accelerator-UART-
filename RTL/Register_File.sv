`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 02:43:48 PM
// Design Name: 
// Module Name: Register_File
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


module Register_File(
    input clk,
    input rst,
    input opcode,
    input reg_write,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0]wr,
    output logic [31:0] rdata1,
    output logic [31:0] rdata2
    );
    
    reg reg_write_reg;
    reg [4:0] rd_reg;
    logic [31:0] registers [0:31];
    integer i;
    always@(negedge clk or posedge rst)begin
        if(rst)begin
            for (i = 0;i<32; i++)begin
                registers[i] <= i;
            end      
        end
        else begin
            if(reg_write)begin
                registers[rd] <= wr;
            end

        end
    
    end
    
    
    
    assign rdata1 = registers[rs1];
    assign rdata2 = registers[rs2];
    
endmodule
