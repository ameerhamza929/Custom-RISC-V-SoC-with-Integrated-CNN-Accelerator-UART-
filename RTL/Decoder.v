`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2026 03:48:12 PM
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


module Decoder_mem(
input [31:0] addr,
output ram_en,
output cnn_en,
output uart_en
    );
    
    assign ram_en = (addr[31:16] == 16'h0000) ? 1'b1:1'b0;
    assign cnn_en = (addr[31:16] == 16'h8000) ? 1'b1:1'b0;
    assign uart_en = (addr[31:16] == 16'h4000) ? 1'b1:1'b0;
endmodule
