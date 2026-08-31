`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 03:25:02 PM
// Design Name: 
// Module Name: ALU_Control
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


module ALU_Control(
  input [1:0] ALU_op,
  input op5,
  input [2:0] func3,
  input [6:0] func7,
  output logic [2:0] ALU_Ctrl
    );
    
    always_comb begin
        case(ALU_op)
            2'b00: ALU_Ctrl = 3'b000;
            2'b01: ALU_Ctrl = 3'b001;
            2'b10: begin
                case(func3)
                    3'b000: begin
                        if(op5)begin
                            case(func7)
                                7'b0000000: ALU_Ctrl = 3'b000;
                                7'b0100000: ALU_Ctrl = 3'b001;
                            endcase
                        end
                        else begin
                            ALU_Ctrl = 3'b000;
                        end
                            
                    end
                    3'b001: ALU_Ctrl = 3'b100;
                    3'b010: ALU_Ctrl = 3'b101;
                    3'b110: ALU_Ctrl = 3'b011;
                    3'b111: ALU_Ctrl = 3'b010;
                    
              endcase
            end
        endcase
    end
    
endmodule
