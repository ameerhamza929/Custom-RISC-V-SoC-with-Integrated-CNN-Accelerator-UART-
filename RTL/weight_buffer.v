`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2026 03:15:26 AM
// Design Name: 
// Module Name: weight_buffer
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

module weight_buffer(
    input              clk,
    input              rst,
    input              valid,
    input              mem_read,
    input      [31:0]  data_in,     // 4 packed INT8 weights
    output reg [7:0]   weight
);

    reg [7:0] weights [0:8];

    reg [1:0] load_count;   // 0,1,2 (three 32-bit words)
    reg [3:0] read_count;   // 0-8

    integer i;

    always @(posedge clk) begin
        if (rst) begin
            load_count <= 0;
            read_count <= 0;
            weight     <= 8'd0;

            for (i = 0; i < 9; i = i + 1)
                weights[i] <= 8'd0;
        end
        else begin

            //-------------------------
            // Load kernel
            //-------------------------
            if (valid) begin
                case(load_count)

                    // Weights 0-3
                    2'd0: begin
                        weights[0] <= data_in[7:0];
                        weights[1] <= data_in[15:8];
                        weights[2] <= data_in[23:16];
                        weights[3] <= data_in[31:24];
                        load_count <= 2'd1;
                    end

                    // Weights 4-7
                    2'd1: begin
                        weights[4] <= data_in[7:0];
                        weights[5] <= data_in[15:8];
                        weights[6] <= data_in[23:16];
                        weights[7] <= data_in[31:24];
                        load_count <= 2'd2;
                    end

                    // Weight 8 (only lowest byte used)
                    2'd2: begin
                        weights[8] <= data_in[7:0];
                        load_count <= 2'd0;
                    end

                endcase
            end

            //-------------------------
            // Read weights sequentially
            //-------------------------
            if (mem_read) begin

                weight <= weights[read_count];

                if (read_count == 8)
                    read_count <= 0;
                else
                    read_count <= read_count + 1;

            end
        end
    end

endmodule
