`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2026 01:40:48 AM
// Design Name: 
// Module Name: tb_ya_azeem
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


module tb_ya_azeem;


    // --- 1. Declare Testbench Signals ---
    reg clk;
    reg rst;
    reg start;
    reg CPU_RESETN;
    // --- 2. Instantiate the Unit Under Test (UUT) ---
    SoC uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .CPU_RESETN(CPU_RESETN)
    );

    // --- 3. Clock Generation ---
    // Generates a clock with a 10ns period (100 MHz frequency)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --- 4. Stimulus and Reset Sequence ---
    initial begin
        // Optional: Enable waveform dumping for tools like GTKWave, ModelSim, or Vivado

        // Initialize input
        start = 0;
        rst = 1; // Assert reset (assuming active-high)
        CPU_RESETN = 0;
        // Hold reset for 100 ns to stabilize
        #15;
        CPU_RESETN = 1;
        // De-assert reset to start normal operation
        rst = 0;
        
        #100
        
        start = 1;
        #10
        start = 0;
        // Let the simulation run for an arbitrary amount of time to observe behavior
        #1000;
        
        // Stop the simulation
        $display("Simulation finished.");
        $finish;
    end

endmodule


