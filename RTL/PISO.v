`timescale 1ns / 1ps

module PISO #(
    parameter WIDTH = 32,
    parameter WORDS = 36
)(
    input                           clk,
    input                           rst,
    input      [WIDTH*WORDS-1:0]    datain,
    input                           data_ready,
    output reg [WIDTH-1:0]          mem_data_out,
    output reg                      busy,
    output reg                      done
);

    localparam COUNT_WIDTH = $clog2(WORDS);

    reg [WIDTH*WORDS-1:0] shift_reg;
    reg [COUNT_WIDTH:0]   count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg    <= {(WIDTH*WORDS){1'b0}};
            mem_data_out <= {WIDTH{1'b0}};
            count        <= 0;
            busy         <= 1'b0;
            done         <= 1'b0;
        end
        else begin
            done <= 1'b0;

            // Load new data
            if (data_ready && !busy) begin
                shift_reg <= datain;
                count     <= 0;
                busy      <= 1'b1;
            end

            // Serialize
            else if (busy) begin
                mem_data_out <= shift_reg[WIDTH-1:0];
                shift_reg    <= shift_reg >> WIDTH;

                if (count == WORDS-1) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                end

                count <= count + 1'b1;
            end
        end
    end

endmodule