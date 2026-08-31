`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2026 04:14:39 AM
// Design Name: 
// Module Name: top_module
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


module top_module#(
    parameter SIZE = 8,        // 8x8 array of processing elements
    parameter WIDTH = 32      //Data size
)(
    input wire clk,
    input wire rst,
    input conv_comp,
    input hold,
    input wire [(8*SIZE*SIZE)-1:0] mem_data_inn,         
    input wire [(WIDTH*SIZE*SIZE)-1:0] eng_shift,         // 1D array for eng_shift input for each PE
    (* keep = "true" *)output wire [1151:0] dataout_a_valid, //ENgine shift from outfmap,
    input wire ctrl0,          // Control signal for each PE
    input wire [1:0] ctrl1,    // Control signal for each P
    input wire add_enable,     // Add enable signal for each PE
    input wire acc_enable,
    input wire add_eng,
    input wire flush,
    input [7:0] weight_in
);


  wire [(WIDTH*SIZE*SIZE)-1:0] ENG_shift_out;
  
   wire [8*8*WIDTH-1:0] dataout_a;

  convolution_engine #(
    .SIZE  (8),  // Default: 8
    .WIDTH (32)  // Default: 32
  ) u_convolution_engine (
      .clk           (clk),           
      .rst           (rst),           
      .conv_comp     (conv_comp),     
      .hold          (hold),          
      .mem_data_inn  (mem_data_inn),  
      .eng_shift     (0),     
      .ENG_shift_out (ENG_shift_out), 
      .ctrl0         (ctrl0),         
      .ctrl1         (ctrl1),         
      .add_enable    (add_enable),    
      .acc_enable    (acc_enable),    
      .add_eng       (add_eng),       
      .flush         (flush),         
      .weight_in     (weight_in)      
  );
  
  
  valid_out #(
      .R      (8),  // Default: 8
      .C      (8),  // Default: 8
      .WIDTH  (32), // Default: 16
      .stride (1)   // Default: 1
  ) u_valid_out (
      .clk             (clk),             // input wire
      .rst             (rst),             // input wire
      .Kh              (3),              // input wire [2:0]
      .Kw              (3),              // input wire [2:0]
      .dataout_a       (ENG_shift_out),       // input wire [(R*C*WIDTH)-1:0]
      .mask_row        (8'b00111111),        // input wire [R-1:0]
      .mask_col        (8'b00111111),        // input wire [C-1:0]
      .dataout_a_valid (dataout_a)  // output wire [(R*C*WIDTH)-1:0]
  );
  
  
  assign dataout_a_valid = dataout_a[1151:0]; 

endmodule
