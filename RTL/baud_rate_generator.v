`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name : baud_rate_generator
//
// Description:
// Parameterized Baud Rate Generator
//
// Lab Tasks:
// 1. Calculate the divider value.
// 2. Implement a counter.
// 3. Generate a one-clock-cycle tick.
// 4. Reset the counter.
//
// Applications:
// • UART Transmitter  : TICK_RATE_HZ = BAUD_RATE
// • UART Receiver     : TICK_RATE_HZ = BAUD_RATE × OVERSAMPLE
//
//////////////////////////////////////////////////////////////////////////////////

module baud_rate_generator #(
    parameter integer CLOCK_FREQ_HZ = 20_000_000,   // System clock
    parameter integer BAUD_RATE     = 9600
)
(
    input  wire clk,
    input  wire rst_n,

    output reg  tick
);

    localparam integer DIVIDER = CLOCK_FREQ_HZ / BAUD_RATE;

    reg [31:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 32'd0;
            tick  <= 1'b0;
        end
        else begin
            if (count == DIVIDER-1) begin
                count <= 32'd0;
                tick  <= 1'b1;      // One clock pulse
            end
            else begin
                count <= count + 1'b1;
                tick  <= 1'b0;
            end
        end
    end

endmodule