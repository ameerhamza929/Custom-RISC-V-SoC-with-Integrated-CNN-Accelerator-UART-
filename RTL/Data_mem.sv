`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 04:18:57 PM
// Design Name: 
// Module Name: Data_mem
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


module Data_mem(
    input clk,
    input rst,
    input mem_read,
    input mem_write,
    input [31:0]addr,
    input [31:0] write_data,
    output logic [31:0]read_data    
    );
    
    logic [7:0] memory [0:1023];

    integer i;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
//            read_data <= 32'd0;
            for (i=0; i<1023; i=i+1)
                memory[i] <= 8'd0;
        end
        else begin
            if (mem_write) begin
                memory[addr]   <= write_data[7:0];
                memory[addr+1] <= write_data[15:8];
                memory[addr+2] <= write_data[23:16];
                memory[addr+3] <= write_data[31:24];
            end
//            else if (mem_read)
//                read_data <= {memory[addr+3], memory[addr+2],
//                             memory[addr+1], memory[addr]}; 
        end
     end
     
     assign read_data = (mem_read) ? {memory[addr+3], memory[addr+2],memory[addr+1],memory[addr]}:32'd0; 
    
    
endmodule




//  0x00100093	addi x1 x0 1	addi x1, x0, 1
//  0x01F00293	addi x5 x0 31	addi x5, x0, 31
//  0x005090B3	sll x1 x1 x5	sll x1, x1, x5 # x1 = 0x80000000 (Infmap base)
//  0x00408113	addi x2 x1 4	addi x2, x1, 4 # Weight register
//	0x00808193	addi x3 x1 8	addi x3, x1, 8 # Output register
//	0x00C08213	addi x4 x1 12	addi x4, x1, 12 # Start register
//	0x01008513	addi x10 x1 16	addi x10, x1, 16 # Done register
//	0x00100713	addi x14 x0 1	addi x14, x0, 1
//	0x01E00293	addi x5 x0 30	addi x5, x0, 30
//	0x00571733	sll x14 x14 x5	sll x14, x14, x5 # x14 = 0x40000000 (UART base)
//	0x00000313	addi x6 x0 0	addi x6, x0, 0 # Infmap initial value
//	0x10E00413	addi x8 x0 270	addi x8, x0, 270 # Output initial value
//	0x10600393	addi x7 x0 262	addi x7, x0, 262 # Weight address (constant)
//	0x00100493	addi x9 x0 1	addi x9, x0, 1 # Start pulse high (constant)
//	0x01000613	addi x12 x0 16	addi x12, x0, 16 # Max outer iterations
//	0x00000693	addi x13 x0 0	addi x13, x0, 0 # Current outer iteration counter
//	0x02400813	addi x16 x0 36	addi x16, x0, 36 # 36 words per iteration (e.g., 270 to 305)
//	0x00712023	sw x7 0(x2)	sw x7, 0(x2) # Write weight address once
//	0x0060A023	sw x6 0(x1)	sw x6, 0(x1) # Write Infmap
//	0x0081A023	sw x8 0(x3)	sw x8, 0(x3) # Write Output
//	0x00922023	sw x9 0(x4)	sw x9, 0(x4) # Start pulse HIGH
//	0x00022023	sw x0 0(x4)	sw x0, 0(x4) # Start pulse LOW
//	0x00052583	lw x11 0(x10)	lw x11, 0(x10) # Hardware stall handles lw -> beq dependency
//	0x00958463	beq x11 x9 8	beq x11, x9, start_uart_tx
//	0xFE000CE3	beq x0 x0 -8	beq x0, x0, poll
//	0x00040793	addi x15 x8 0	addi x15, x8, 0 # x15 = pointer to current output address (starts at x8)
//	0x00000893	addi x17 x0 0	addi x17, x0, 0 # x17 = inner loop counter (reset to 0)
//	0x0007A903	lw x18 0(x15)	lw x18, 0(x15) # Load data word from memory
//	0x00178793	addi x15 x15 1	addi x15, x15, 1 # 1. Increment memory pointer to next word
//	0x00188893	addi x17 x17 1	addi x17, x17, 1 # 2. Increment inner UART loop counter
//	0x01272223	sw x18 4(x14)	sw x18, 4(x14) # Write data word to UART Data (0x40000004)
//	0x00972023	sw x9 0(x14)	sw x9, 0(x14) # UART Start HIGH (0x40000000)
//	0x00072023	sw x0 0(x14)	sw x0, 0(x14) # UART Start LOW
//	0x00872983	lw x19 8(x14)	lw x19, 8(x14) # Load UART Status (0x40000008)
//	0x00998463	beq x19 x9 8	beq x19, x9, uart_check_done # If Status == 1, word is sent
//	0xFE000CE3	beq x0 x0 -8	beq x0, x0, uart_poll
//	0x01088463	beq x17 x16 8	beq x17, x16, next_it # If 36 words sent, exit inner loop
//	0xFC000CE3	beq x0 x0 -40	beq x0, x0, uart_loop # Else, loop back and send the next word
//	0x01030313	addi x6 x6 16	addi x6, x6, 16 # Increment Infmap
//	0x02440413	addi x8 x8 36	addi x8, x8, 36 # Increment Output base address
//	0x00168693	addi x13 x13 1	addi x13, x13, 1 # Increment outer loop counter
//	0x00C68463	beq x13 x12 8	beq x13, x12, finished # EXIT LOOP: If outer counter == 16, finish
//	0xFA0000E3	beq x0 x0 -96	beq x0, x0, loop # CONTINUE: Unconditional jump back to main loop
//	0x00000063	beq x0 x0 0	beq x0, x0, finished
