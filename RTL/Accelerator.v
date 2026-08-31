`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2026 01:26:51 AM
// Design Name: 
// Module Name: Accelerator
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


module Accelerator#(
    parameter SIZE = 8,        // 8x8 array of processing elements
    parameter WIDTH = 32,      // Data size
    parameter INPUT_BASE_ADDR = 32'h80000000,
    parameter WEIGHT_BASE_ADDR = 32'h80000004,
    parameter OUTPUT_BASE_ADDR = 32'h80000008,
    parameter START = 32'h8000000C,
    parameter DONE_ADDR = 32'h80000010
)(
 input clk,
 input rst ,
 output [31:0] mem_data_out,
 input [31:0] doutb,
 output enb,
 output web,
 output [11:0] addrb,
 input [31:0] cnn_addr,
 input [31:0] cnn_wdata,
 input        cnn_write,
 input cnn_read,
 output reg [31:0] cnn_rdata 
    );
    
 
// wire [7:0] addra,addrb;   
// wire ena,enb;
// wire [31:0] dina,doutb;
 wire [1:0] ctrl1;
 wire ctrl0;
 wire add_enable;
 wire acc_enable;
 wire conv_comp   ;
 wire flush       ;           
 wire hold        ;
 wire add_eng     ;
 wire ctrl_bf_conv;
 wire valid_in    ;
 wire valid_in_datain_b  ;              
 wire weight_read        ;              
 wire data_ready         ;
 wire done               ;
 wire infmap_valid;
 wire weight_valid;
 wire [(8*SIZE*SIZE)-1:0] mem_data_inn;
 wire [7:0] weight_in;
 
 reg start_reg;
(* mark_debug = "true" *)  reg [11:0] start_infmap_addr, start_weight_addr, start_outfmap_addr;
 
  
 
 always@(posedge clk or posedge rst)begin
    if(rst)begin
        start_reg <= 0;
        start_infmap_addr <= 0;
        start_weight_addr <= 0;
        start_outfmap_addr <= 0;
        cnn_rdata <= 0;
    end
    else begin
        if(cnn_write)begin
            if(cnn_addr == INPUT_BASE_ADDR)begin
                start_infmap_addr <= cnn_wdata[11:0];
            end
            if(cnn_addr == WEIGHT_BASE_ADDR)begin
                start_weight_addr <= cnn_wdata[11:0];
            end
            if(cnn_addr == OUTPUT_BASE_ADDR)begin
                start_outfmap_addr <= cnn_wdata[11:0];
            end
            if(cnn_addr == START)begin
                start_reg <= cnn_wdata[0];
            end
            
         end
         else begin
            if(cnn_addr == DONE_ADDR)begin
                cnn_rdata <= {30'd0,done};
            end
         end
    end
 end
 
// blk_mem_gen_0 BRAM_inst(
//    .addra(addra),
//    .clka(clk),
//    .dina(dina),
//    .ena(ena),
//    .addrb(addrb),
//    .clkb(clk),
//    .doutb(doutb),
//    .enb(enb)
//  );
  
  
  infmap_buffer u_infmap_buffer (
    .clk       (clk),       // input wire
    .rst       (rst),       // input wire
    .valid     (infmap_valid),     // input wire
    .data_in   (doutb),   // input wire [31:0]
    .shift_reg (mem_data_inn)  // output wire [511:0]
  );
  
   weight_buffer u_weight_buffer (
      .clk      (clk),      // input wire
      .rst      (rst),      // input wire
      .valid    (weight_valid),    // input wire
      .mem_read (weight_read), // input wire
      .data_in  (doutb),  // input wire [31:0]
      .weight   (weight_in)    // output wire [7:0]
  );
  
   controller #(
    .SIZE (8) // Default: 8
) u_controller (
    .clk               (clk),               // input wire
    .rst               (rst),               // input wire
    .start             (start_reg),             // input wire
    .start_infmap_addr (start_infmap_addr),
    .start_weight_addr (start_weight_addr),
    .start_outfmap_addr(start_outfmap_addr),
    .ctrl0             (ctrl0),             // output reg
    .ctrl1             (ctrl1),             // output reg [1:0]
    .add_enable        (add_enable),        // output reg
    .acc_enable        (acc_enable),        // output reg
    .conv_comp         (conv_comp),         // output reg
    .flush             (flush),             // output reg
    
    .hold              (hold),              // output reg [2:0]
    .add_eng           (add_eng),           // output reg [2:0]
    .ctrl_bf_conv      (ctrl_bf_conv),      // output reg
    
    .valid_in          (valid_in),          // output reg
    
    .addrb             (addrb),             // output reg [7:0]
    .enb               (enb),               // output reg
    .infmap_valid (infmap_valid), // output re
    .weight_valid(weight_valid),
    .weight_read       (weight_read),       // output reg
    
    .data_ready        (data_ready),        // output reg
    .done              (done),               // output reg
    .web                (web)
);

  wire [1151:0] dataout_a_valid;
  
   top_module #(
    .SIZE  (8),  // Default: 8
    .WIDTH (32)  // Default: 32
) u_top_module (
    .clk             (clk),             // input wire
    .rst             (rst),             // input wire
    .conv_comp       (conv_comp),       // input wire
    .hold            (hold),            // input wire
    .mem_data_inn    (mem_data_inn),    // input wire [(8*SIZE*SIZE)-1:0]
    .eng_shift       (0),       // input wire [(WIDTH*SIZE*SIZE)-1:0]
    .dataout_a_valid (dataout_a_valid), // output wire [1151:0]
    .ctrl0           (ctrl0),           // input wire
    .ctrl1           (ctrl1),           // input wire [1:0]
    .add_enable      (add_enable),      // input wire
    .acc_enable      (acc_enable),      // input wire
    .add_eng         (add_eng),         // input wire
    .flush           (flush),           // input wire
    .weight_in       (weight_in)        // input wire [7:0]
);


  
 wire busy;
 
PISO #(
    .WIDTH (32), // Default: 32
    .WORDS (36)  // Default: 36
) u_PISO (
    .clk          (clk),          // input 
    .rst          (rst),          // input 
    .datain       (dataout_a_valid),       // input  [(WIDTH*WORDS)-1:0]
    .data_ready   (data_ready),   // input 
    .mem_data_out (mem_data_out), // output [WIDTH-1:0]
    .busy         (busy)         // output 
    //.done         (done)          // output 
);
   
   
    
endmodule
