module uart_rx #(
    parameter integer OVERSAMPLE = 16
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sample_tick,
    input  wire        rx,
    output reg  [31:0] data_out,
    output reg          data_valid,
    output reg          framing_error
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
    reg [1:0]  state, next_state;
    reg [3:0]  sample_count;      // 0..15, counts oversample ticks within one bit period
    reg [4:0]  bit_index;         // counts which of the 32 data bits we're on
    reg [31:0] shift_reg;
    reg        mid_sample;        // captured sample at the middle of the bit (count == 8)

    // Synchronizer Registers
    reg rx_meta;
    reg rx_sync;

    //====================================================
    // Part 1
    // Synchronize the asynchronous RX input
    //====================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end
        else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
        end
    end

    //====================================================
    // Part 2
    // UART Receiver State Machine
    //====================================================
    always @(posedge sample_tick or negedge rst_n) begin
        if (!rst_n) begin
            state         <= ST_IDLE;
            sample_count  <= 4'd0;
            bit_index     <= 5'd0;
            shift_reg     <= 32'd0;
            mid_sample    <= 1'b0;
            data_valid    <= 1'b0;
            data_out      <= 32'd0;
            framing_error <= 1'b0;
        end
        else begin
            state         <= next_state;
            data_valid    <= 1'b0;   // default: pulse for one tick only
            framing_error <= 1'b0;   // default: pulse for one tick only

            case (state)

                ST_IDLE: begin
                    sample_count <= 4'd0;
                    bit_index    <= 5'd0;
                end

                ST_START: begin
                    sample_count <= sample_count + 1'b1;

                    // capture the sample at the middle of the start bit
                    if (sample_count == 4'd8)
                        mid_sample <= rx_sync;

                    if (sample_count == 4'd15)
                        sample_count <= 4'd0;
                end

                ST_DATA: begin
                    sample_count <= sample_count + 1'b1;

                    if (sample_count == 4'd8)
                        mid_sample <= rx_sync;

                    if (sample_count == 4'd15) begin
                        shift_reg    <= {mid_sample, shift_reg[31:1]}; // shift in LSB-first
                        sample_count <= 4'd0;
                        bit_index    <= bit_index + 1'b1;
                    end
                end

                ST_STOP: begin
                    sample_count <= sample_count + 1'b1;

                    if (sample_count == 4'd8)
                        mid_sample <= rx_sync;

                    if (sample_count == 4'd15) begin
                        sample_count <= 4'd0;
                        if (mid_sample == 1'b1) begin
                            data_valid <= 1'b1;
                            data_out   <= shift_reg;
                        end
                        else begin
                            framing_error <= 1'b1;
                        end
                    end
                end

                default: begin
                    sample_count <= 4'd0;
                end

            endcase
        end
    end

    //====================================================
    // Next-State Logic
    //====================================================
    always @(*) begin
        next_state = state;
        case (state)
            ST_IDLE: begin
                // start bit is a falling edge (idle line is high)
                next_state = (!rx_sync) ? ST_START : ST_IDLE;
            end

            ST_START: begin
                if (sample_count == 4'd15)
                    // confirm it was really a start bit (low at mid-sample)
                    next_state = (!mid_sample) ? ST_DATA : ST_IDLE;
                else
                    next_state = ST_START;
            end

            ST_DATA: begin
                next_state = (bit_index == 5'd31 && sample_count == 4'd15)
                             ? ST_STOP : ST_DATA;
            end

            ST_STOP: begin
                next_state = (sample_count == 4'd15) ? ST_IDLE : ST_STOP;
            end

            default: next_state = ST_IDLE;
        endcase
    end

endmodule