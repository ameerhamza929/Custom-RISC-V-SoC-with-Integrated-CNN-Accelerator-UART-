`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: uart_tx
// Description:
// UART Transmitter (8 Data Bits, No Parity, 1 Stop Bit)
//
// Lab Task:
// Complete the UART transmitter by implementing:
//   1. Idle state
//   2. Start bit transmission
//   3. Data bit transmission (LSB first)
//   4. Stop bit transmission
//   5. Busy and done signal generation
//////////////////////////////////////////////////////////////////////////////////


module uart_tx #(
 parameter packet_size = 34   // kept for interface compatibility, unused now
 )(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       baud_tick,
    (* mark_debug = "true" *)input  wire       start,
    input  wire [31:0] data_in,
    output reg        tx,
    output reg        busy,
    (* mark_debug = "true" *)output reg        done
    //(* mark_debug = "true" *) output reg [31:0] tx_start_count
);

    
    //====================================================
    // State Encoding
    //====================================================
    localparam ST_IDLE  = 2'd0;
    localparam ST_START = 2'd1;
    localparam ST_DATA  = 2'd2;
    localparam ST_STOP  = 2'd3;
    //====================================================
    // Internal Registers
    //====================================================
    (* mark_debug = "true" *)reg [1:0] state,next_state;
    reg [2:0] bit_index;    // CHANGED: 0..7 (8 data bits per byte) instead of 0..31
    reg [31:0] shift_reg;
    reg [1:0] byte_cnt;     // NEW: tracks which of the 4 bytes (0..3) is being sent
    //====================================================
    // UART Transmitter State Machine
    //====================================================

    reg        start_pending;   // latched start request, clk domain
    //====================================================
    // Latch the start pulse so it survives until the FSM
    // is ready to consume it (avoids missing a 1-cycle pulse)
    //====================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            start_pending <= 1'b0;
        else if (start)                    // capture regardless of current state
            start_pending <= 1'b1;
        else if (state == ST_START)        // consumed
            start_pending <= 1'b0;
    end



    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            state <= ST_IDLE;
            shift_reg <= 0;
            bit_index <= 0;
            byte_cnt  <= 0;      // NEW
            busy <= 0;
//            done <= 0;
        end
        else begin
            if(baud_tick)begin
                //done <= 0;
                if(state == ST_IDLE) begin
                    shift_reg <= data_in;
                    bit_index <= 0;
                    byte_cnt  <= 0;   // NEW: start over at byte 0 for a new word
    //                done <= 0;
                end
                if(state == ST_START) begin
                    busy <= 1;
                    bit_index <= 0;   // NEW: reset bit count for each new byte
                    //done <= 0;
                end
                if(state == ST_DATA)begin
                    shift_reg <= {1'b0,shift_reg[31:1]};
                    bit_index <= bit_index + 1;
                end
                if (state == ST_STOP)begin
    //                done <= 1;
                    byte_cnt <= byte_cnt + 1;               // NEW: advance to next byte
                    if (byte_cnt == 2'd3)begin                    // NEW: only drop busy after last byte
                        busy <= 0;
                       // done <= 1;
                    end
                end
                state <= next_state;
            end
        end

    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            done <= 0;
        end
        else begin
            if(state == ST_STOP && byte_cnt == 2'd3)begin  // CHANGED: only after last byte
                done <= 1;
            end
            else if (start)begin
                done <= 0;
            end
        end
    end

    always @(*)
    begin

            case(state)
                ST_IDLE:
                begin
                    tx = 1'b1;
                    // Wait for start signal
                    next_state = (start_pending) ? ST_START:ST_IDLE;

                end

                ST_START:
                begin

                    tx = 1'b0;
                    next_state = ST_DATA;

                end


                ST_DATA:
                begin
                    tx = shift_reg[0];
                    next_state = (bit_index == 3'b111) ?  ST_STOP:ST_DATA;  // CHANGED: 7 instead of 31
                end

                ST_STOP:
                begin

                    tx = 1'b1;
                    next_state = (byte_cnt == 2'd3) ? ST_IDLE : ST_START;   // CHANGED: loop for next byte
                end

            endcase

    end
endmodule