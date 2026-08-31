`timescale 1ns / 1ps

module controller #(
    parameter SIZE = 8
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  [11:0] start_weight_addr,
    input  [11:0] start_infmap_addr,
    input  [11:0] start_outfmap_addr,
    output reg         ctrl0,
    output reg  [1:0]  ctrl1,
    output reg         add_enable,
    output reg         acc_enable,
    output reg         conv_comp,
    output reg         flush,

    // new outputs for engine shift
    output reg    hold,
    output reg [2:0]   add_eng,
    output reg         ctrl_bf_conv,

    // output for memory store back
    output reg         valid_in,

    // output for BRAM infmap
    output reg [11:0]   addrb,
    output reg         enb,
    output reg         infmap_valid,
    output reg         weight_valid,

    // weights_memory
    output reg         weight_read,

    output reg         data_ready,
    (* mark_debug = "true", keep = "true"*) output reg done,
    output reg web
);

    (* mark_debug = "true", keep = "true", dont_touch = "true", fsm_encoding = "user" *)
     reg [4:0]   state;
    // --------------------------------------------------------
    // State Encoding
    // --------------------------------------------------------
    localparam S_IDLE                   = 5'd0;
    localparam S_INIT                   = 5'd1;
    localparam S_LOADDATA               = 5'd2;
    localparam S_next_patch_addr        = 5'd3;
    localparam S_nextpatch              = 5'd4;
    localparam S_memclear               = 5'd5;
    localparam S_weights                = 5'd6;
    localparam S_FLUSH                  = 5'd7;
    localparam S_LOAD_W0                = 5'd8;
    localparam S_CONV_LOOP              = 5'd9;
    localparam S_ACCUM                  = 5'd10;
    localparam S_INTER                  = 5'd11;
    localparam S_ADD                    = 5'd12;
    localparam S_DONE                   = 5'd13;
    localparam S_ENGSHIFT0              = 5'd14;
    localparam S_ENGSHIFT1              = 5'd15;
    localparam S_ENGSHIFT2              = 5'd16;
    localparam S_ENGSHIFT3              = 5'd17;
    localparam S_ENGSHIFT4              = 5'd18;
    localparam S_ENGSHIFT5              = 5'd19;
    localparam S_ENGSHIFT6              = 5'd20;
    localparam S_PISO_1                 = 5'd21;
    localparam S_PISO_2                 = 5'd22;
    localparam S_PISO_3                 = 5'd23;
    localparam S_memclear_1             = 5'd24;
    localparam S_next_patch_addr_buffer = 5'd25;
    localparam S_weightsload            = 5'd26;
    localparam S_Buffer                 = 5'd27;
    localparam S_SecBuffer              = 5'd28;
    localparam S_writeback              = 5'd29;

    (* keep = "true", dont_touch = "true", fsm_encoding = "user" *)
    reg [4:0] next_state;

    // --------------------------------------------------------
    // Internal Registers
    // --------------------------------------------------------
    wire [2:0]   Kh = 3;
    wire [2:0]   Kw = 3;
    reg         valid_in_datain_b;
    reg  [7:0]   start_addr; 
    reg [3:0]  repeat_count, repeat_count_conv, repeat_count_enb;
    reg [7:0]  repeat_count_loaddata;
    reg [3:0]  max_repeats, max_repeat_conv, max_repeat_enb;
    reg [7:0]  max_repeat_loaddata;
    reg [3:0]  max_repeat_writeback;
    (* mark_debug = "true" ,KEEP = "TRUE" *)reg load_patch = 1'b0; 
    reg        load_comp;
    reg [3:0]  current_layer;
    reg        input_req;

    (* keep = "true" *) reg [4:0] repeat_channel;
    reg [4:0] max_repeat_channel;

    // --------------------------------------------------------
    // State Register + Sequential Counters
    // --------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state             <= S_IDLE;
            repeat_count      <= 0;
            repeat_count_conv <= 0;
            repeat_channel    <= 0;
        end else begin
            state <= next_state;

            // repeat_count
            if (state == S_CONV_LOOP)
                repeat_count <= repeat_count + 1'b1;
            else
                repeat_count <= 0;

            // repeat_count_conv
            if (state == S_ACCUM)
                repeat_count_conv <= repeat_count_conv + 1'b1;
            else if (state == S_ADD)
                repeat_count_conv <= 0;

            // repeat_channel & config_mem_addr
            if (state == S_ENGSHIFT6)
                repeat_channel <= repeat_channel + 1;
            else if (state == S_next_patch_addr) begin
                repeat_channel  <= 0;
            end
        end
    end

    // --------------------------------------------------------
    // Load Data Sequential Block
    // --------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            repeat_count_loaddata <= 0;
            repeat_count_enb      <= 0;
            addrb                 <= 0;
            load_comp             <= 0;
            valid_in_datain_b     <= 0;
            enb                   <= 0;
            start_addr            <= 0;
            input_req             <= 0;
            web                   <= 0;
        end else begin
            // Default each cycle - prevents latches
            valid_in_datain_b <= 1'b0;
            enb               <= 1'b0;
            input_req         <= 1'b0;
            web               <= 1'b0;
            if (load_patch) begin
                repeat_count_loaddata <= repeat_count_loaddata + 1'b1;
                enb <= 1'b1;
                if(state == S_PISO_1) web <= 1'b1;
                if(addrb !=0)begin
                    addrb <= addrb + 1;
                end

               if (repeat_count_loaddata == 8'd0)begin 
                    if(state == S_weightsload)begin
                        addrb <= start_weight_addr;
                    end
                    else if(state == S_PISO_1)  addrb <= start_outfmap_addr;
                    else addrb <= start_infmap_addr;
                end
                if (repeat_count_loaddata == 8'd1)begin
                    input_req <= 1'b1;
                end

                if (repeat_count_loaddata >= 1)
                    valid_in_datain_b <= 1'b1;

                if (repeat_count_loaddata >= 1 && repeat_count_loaddata < 16)
                    addrb <= addrb + 1;

                if (repeat_count_loaddata >= max_repeat_loaddata)
                    load_comp <= 1'b1;
            end else begin
                repeat_count_loaddata <= 0;
                load_comp             <= 1'b0;
            end
        end
    end

    // --------------------------------------------------------
    // Next State + Output Logic (Combinational)
    // --------------------------------------------------------
    
   always @(posedge clk or posedge rst) begin
        if (rst) begin
            load_patch <= 1'b0;
            done <= 0;
        end else begin
            case (state)
                S_INIT: begin  
                     done <= 0;  
                     load_patch <= 1'b1;
                    if (load_comp) 
                        load_patch <= 1'b0;
                end
                S_nextpatch: load_patch <= 1'b1;
                S_weightsload: begin
                    load_patch <= 1'b1;
                    if (load_comp) 
                        load_patch <= 1'b0;
                end
                S_weights: begin  
                            if (load_comp) load_patch <= 1'b0;
                            else load_patch <= load_patch; // hold
                end
                S_PISO_1:begin
                    load_patch <= 1'b1;
                    if (load_comp) 
                        load_patch <= 1'b0;
                end
                S_SecBuffer:begin
                    done <= 1;
                end
            endcase
        end
    end
    
    always @(*) begin
        // ---- Default all outputs unconditionally ----
        next_state           = S_IDLE;
        ctrl0                = 1'b0;
        ctrl1                = 2'b00;
        add_enable           = 1'b0;
        acc_enable           = 1'b0;
        conv_comp            = 1'b0;
        flush                = 1'b0;
        hold                 =  0;
        add_eng              = 3'd0;
        ctrl_bf_conv         = 1'b0;
        valid_in             = 1'b0;
        weight_read          = 1'b0;
        data_ready           = 1'b0;
        infmap_valid = 0;
        weight_valid = 0;
        //done = 0;

        // Loop constants (must also be assigned unconditionally)
        max_repeat_loaddata  = 8'd15;
        max_repeats          = Kh - 3;
        max_repeat_conv      = Kh;
        max_repeat_writeback = 4'd3;
        max_repeat_channel   = 5'd0;
        max_repeat_enb       = 4'd2;
//        web = 0;
        // ---- FSM ----
        case (state)

            S_IDLE: begin
                next_state = start ? S_INIT : S_IDLE;
            end

            S_INIT: begin
                infmap_valid =  valid_in_datain_b;
                if (load_comp) begin
                    next_state = S_Buffer;
                end else begin
                    next_state = S_INIT;
                end
            end

            S_Buffer:begin
                infmap_valid =  valid_in_datain_b;
                next_state = S_weightsload;
            end
            S_weightsload: begin
                max_repeat_loaddata = 8'd3;
                weight_valid =  valid_in_datain_b;
                if (load_comp) begin
                    next_state = S_weights;
                end else begin
                    next_state = S_weightsload;
                end
            end

            S_weights: begin
                weight_read = 1'b1;
                next_state = S_FLUSH;
            end

            S_FLUSH: begin
                flush       = 1'b1;
                weight_read = 1'b1;
                next_state  = S_LOAD_W0;
            end

            S_LOAD_W0: begin
                ctrl0       = 1'b1;
                ctrl1       = 2'b01;
                weight_read = 1'b1;
                next_state  = S_CONV_LOOP;
            end

            S_CONV_LOOP: begin
                ctrl0       = 1'b1;
                ctrl1       = 2'b01;
                weight_read = (repeat_count < max_repeats) ? 1'b1 : 1'b0;
                next_state  = (repeat_count < max_repeats) ? S_CONV_LOOP : S_ACCUM;
            end

            S_ACCUM: begin
                ctrl0       = 1'b1;
                ctrl1       = 2'b10;
                acc_enable  = 1'b1;
                weight_read = (repeat_count_conv < max_repeat_conv - 1) ? 1'b1 : 1'b0;
                next_state  = S_INTER;
            end

            S_INTER: begin
                add_enable  = 1'b1;
                weight_read = (repeat_count_conv < max_repeat_conv) ? 1'b1 : 1'b0;
                next_state  = (repeat_count_conv < max_repeat_conv) ? S_LOAD_W0 : S_ADD;
            end

            S_ADD: begin
                conv_comp  = 1'b1;
                next_state = S_DONE;
            end

            S_DONE: begin
                hold       = 1;
                next_state = S_PISO_1;
            end
            
            S_PISO_1: begin
                data_ready = 1'b1;
                max_repeat_loaddata = 8'd34;
                if (load_comp) begin
                    next_state = S_SecBuffer;
                end else begin
                    next_state = S_PISO_1;
                end
            end
            S_SecBuffer:begin
//                done = 1;
                next_state = S_IDLE;
            end
//            S_writeback:begin
//                web = 1;
//                max_repeat_loaddata = 8'd36;
//                if (load_comp) begin
//                    next_state = S_IDLE;
//                end else begin
//                    next_state = S_writeback;
//                end
//            end

            default: next_state = S_IDLE;

        endcase
    end

endmodule