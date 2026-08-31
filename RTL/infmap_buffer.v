`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2026 03:22:25 AM
// Design Name: 
// Module Name: infmap_buffer
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


module infmap_buffer(
    input              clk,
    input              rst,
    input              valid,
    input      [31:0]  data_in,
    output reg [511:0] shift_reg
);

    always @(posedge clk) begin
        if (rst) begin
            shift_reg <= 512'd0;
        end
        else if (valid) begin
            // Insert new data at MSB and shift existing data right by 32 bits
            shift_reg <= {data_in, shift_reg[511:32]};
        end
    end

endmodule
