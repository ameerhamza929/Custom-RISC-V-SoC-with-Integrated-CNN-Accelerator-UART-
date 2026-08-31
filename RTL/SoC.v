`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2026 11:04:26 PM
// Design Name: 
// Module Name: SoC
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


module SoC(
input clk,
input rst,
input CPU_RESETN,
(* mark_debug = "true" *) input start,
output [31:0]  mem_data_out,
input  wire        UART_TXD_IN,
output wire        UART_RXD_OUT
//output [31:0] tx_start_count   
);
    
    
    
    wire          ena;
    wire  [0:0]   wea;
    wire  [11:0]   addra;
    wire  [31:0]  dina;
    wire [31:0]  douta;
    
  
    wire          enb;
    wire  [0:0]   web;
    wire  [11:0]   addrb;
   // wire  [31:0]  mem_data_out;
    wire [31:0]  doutb;
    
    
wire [31:0] cnn_addr;
wire [31:0] cnn_wdata;
wire        cnn_write;

wire [31:0] addr;
wire [31:0] w_data;
wire        mem_read;
wire        mem_write;
wire [31:0] r_data;
wire cnn_read;
wire [31:0] cnn_rdata;
wire [31:0] uart_addr;
wire [31:0] uart_wdata;
wire        uart_write;
wire        uart_read;
wire [31:0] uart_rdata;

// --- Module Instantiation ---
memory_mapped_bus u_memory_mapped_bus (
    .clk(clk),
    .rst(rst),
    // CPU Interface
    .addr(addr),
    .w_data(w_data),
    .mem_read(1'b1),
    .mem_write(mem_write),
    .r_data(r_data),

    // RAM PORT A (Dedicated to CPU)
    .addra(addra),
    .dina(dina),
    .douta(douta),
    .wea(wea),
    .ena(ena),

    // CNN Register Interface
    .cnn_addr(cnn_addr),
    .cnn_wdata(cnn_wdata),
    .cnn_write(cnn_write),
    .cnn_read(cnn_read),
    .cnn_rdata(cnn_rdata),
    //UART INTERFACE
    .uart_addr(uart_addr),
    .uart_wdata(uart_wdata),
    .uart_write(uart_write),
    .uart_read(uart_read),
    .uart_rdata(uart_rdata)
);
    
    pipelineprocessor u_pipelineprocessor (
        .clk(clk),
        .rst(rst),
        .start(start),
        .MemWriteM(mem_write),
        .ALU_resultM(addr),
        .rdata2M(w_data),
        .read_data_mem(r_data)
    );
    
 
  Accelerator #(
    .SIZE(8),
    .WIDTH(32),
    .INPUT_BASE_ADDR(32'h80000000),
    .WEIGHT_BASE_ADDR(32'h80000004),
    .OUTPUT_BASE_ADDR(32'h80000008),
    .START(32'h8000000C)
) u_Accelerator (
    .clk(clk),
    .rst(rst),
    //.start(start),
    .mem_data_out(mem_data_out),
    .doutb(doutb),
    .enb(enb),
    .web(web),
    .addrb(addrb),
    .cnn_addr  (cnn_addr)         ,
    .cnn_wdata (cnn_wdata)       ,
    .cnn_write (cnn_write),
    .cnn_read (cnn_read),
    .cnn_rdata(cnn_rdata)        
);


blk_mem_gen_0 u_blk_mem_gen (
    .clka(clk),      // input wire clka
    .ena(ena),        // input wire ena
    .wea(wea),        // input wire [0 : 0] wea
    .addra(addra),    // input wire [7 : 0] addra
    .dina(dina),      // input wire [31 : 0] dina
    .douta(douta),    // output wire [31 : 0] douta
    .clkb(clk),      // input wire clkb
    .enb(enb),        // input wire enb
    .web(web),        // input wire [0 : 0] web
    .addrb(addrb),    // input wire [7 : 0] addrb
    .dinb(mem_data_out),      // input wire [31 : 0] dinb
    .doutb(doutb)     // output wire [31 : 0] doutb
    
);



uart_top #(
    // Parameters (You can override defaults here if needed)
    .CLOCK_FREQ_HZ   (20_000_000),
    .BAUD_RATE       (9600),
    .start_reg_addr  (32'h40000000),
    .data_reg_addr   (32'h40000004),
    .status_reg_addr (32'h40000008)
    ) u_uart_top (
        // Clock and Reset
        .CLK20MHZ     (clk),
        .CPU_RESETN   (CPU_RESETN),
        .rst          (rst),
        
        // Data input
        .data_in      (uart_wdata),
        
        // USB-UART Interface
        .UART_TXD_IN  (UART_TXD_IN),
        .UART_RXD_OUT (UART_RXD_OUT),
        
        // Memory-Mapped Interface
        .uart_addr    (uart_addr),
        .uart_write   (uart_write),
        .uart_read    (uart_read),
        .uart_rdata   (uart_rdata)
      //  .tx_start_count(tx_start_count)
    );
    
    
endmodule
