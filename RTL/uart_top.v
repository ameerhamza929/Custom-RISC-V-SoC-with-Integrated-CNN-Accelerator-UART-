`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name : uart_top
// Board       : NEXYS A7
//
// Description:
// Top-level UART design.
//
// Lab Tasks:
// 1. Generate baud-rate ticks for transmitter.
// 2. Generate 16× oversampling ticks for receiver.
// 3. Detect push-button press to start transmission.
// 4. Instantiate UART Transmitter.
// 5. Instantiate UART Receiver.
// 6. Display received data on LEDs.
// 7. Display UART status signals.
//
//////////////////////////////////////////////////////////////////////////////////

module uart_top #(
    parameter integer CLOCK_FREQ_HZ = 20_000_000,
    parameter integer BAUD_RATE      = 9600,
    parameter integer start_reg_addr     = 32'h40000000,
    parameter integer data_reg_addr     =  32'h40000004,
    parameter integer status_reg_addr     =  32'h40000008
)(
    input  wire        CLK20MHZ,
    input  wire        CPU_RESETN,
    input rst,
//    input  wire        start,
    input  wire [31:0]  data_in,

    // USB-UART Interface
    input  wire        UART_TXD_IN,
    output wire        UART_RXD_OUT,
    input [31:0] uart_addr,
    input       uart_write,
    input       uart_read,
    output reg [31:0] uart_rdata
   // output [31:0] tx_start_count
);

    (* mark_debug = "true" *) reg [31:0]data_tx;
    (* mark_debug = "true" *) reg start_reg;
    reg [31:0] counter;
    
    always@(posedge CLK20MHZ or posedge rst)begin
        if(rst)begin
            data_tx <= 0;
            start_reg <= 0;
            counter <= 0;
        end
        else begin
            if(uart_write)begin
                if (uart_addr == data_reg_addr)begin
                    data_tx <= counter;
                    counter <= counter + 1;
                end
                if (uart_addr == start_reg_addr)begin
                    start_reg <= data_in[0];
                end
            end
            else begin
                if (uart_addr == status_reg_addr)begin
                    uart_rdata <= {30'd0,tx_done};
                end
            end
        end
    end
    //====================================================
    // Internal Signals
    //====================================================

    // Baud-rate generator outputs
    wire tx_tick;
    wire rx_sample_tick;

    // UART Transmitter signals
    wire tx_busy;
    (* mark_debug = "true" *) wire tx_done;

    // UART Receiver signals
    wire rx_valid;
    wire framing_error;
    wire [7:0] rx_data;

    
    wire start_tx;


 
    baud_rate_generator #(
    .CLOCK_FREQ_HZ(CLOCK_FREQ_HZ), // 100 MHz system clock
    .BAUD_RATE(BAUD_RATE)          // Generate 9600 Hz tick
    ) u_baud_rate_generator (
        .clk   (CLK20MHZ),
        .rst_n (CPU_RESETN),
        .tick  (tx_tick)
    );
    
    
    
  
    
    baud_rate_generator #(
    .CLOCK_FREQ_HZ(CLOCK_FREQ_HZ), // 100 MHz system clock
    .BAUD_RATE(BAUD_RATE * 16)          // Generate 9600 Hz tick
    ) Receiver (
        .clk   (CLK20MHZ),
        .rst_n (CPU_RESETN),
        .tick  (rx_sample_tick)
    );


   
    uart_tx #(
    .packet_size(10)
        ) u_uart_tx (
            .clk       (CLK20MHZ),
            .rst_n     (CPU_RESETN),
            .baud_tick (tx_tick),
            .start     (start_reg),
            .data_in   (data_tx),
        
            .tx        (UART_RXD_OUT),
            .busy      (tx_busy),
            .done      (tx_done)
           // .tx_start_count (tx_start_count)
        );

    
    
    uart_rx #(
    .OVERSAMPLE(16)
     ) u_uart_rx (
         .clk            (CLK20MHZ),
         .rst_n          (CPU_RESETN),
         .sample_tick    (rx_sample_tick),
         .rx             (UART_TXD_IN),
     
         .data_out       (rx_data),
         .data_valid     (rx_valid),
         .framing_error  (framing_error)
     );
    
    
    

endmodule
