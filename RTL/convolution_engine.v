`timescale 1ns / 1ps


module convolution_engine #(
    parameter SIZE = 8,        // 8x8 array of processing elements
    parameter WIDTH = 32      //Data size
)(
    input wire clk,
    input wire rst,
    input conv_comp,
    input hold,
    input wire [(8*SIZE*SIZE)-1:0] mem_data_inn,         
    input wire [(WIDTH*SIZE*SIZE)-1:0] eng_shift,         // 1D array for eng_shift input for each PE
    (* keep = "true" *)output wire [(WIDTH*SIZE*SIZE)-1:0] ENG_shift_out, //ENgine shift from outfmap,
    input wire ctrl0,          // Control signal for each PE
    input wire [1:0] ctrl1,    // Control signal for each P
    input wire add_enable,     // Add enable signal for each PE
    input wire acc_enable,
    input wire add_eng,
    input wire flush,
    input [7:0] weight_in
);

    // Wires to connect HOR_shift and VERT_shift between processing elements
    (* keep = "true" *) wire [WIDTH-1:0] HOR_shift_wires [0:SIZE-1][0:SIZE-1];
    (* keep = "true" *)wire [WIDTH-1:0] VERT_shift_wires [0:SIZE-1][0:SIZE-1];
    (* keep = "true" *)wire [WIDTH-1:0] ENG_shift_wires [0:SIZE-1][0:SIZE-1];
    wire [WIDTH-1:0] ENG_shift_w [(SIZE*SIZE)-1:0];
    // Local Memories
    wire [7:0] Infmap [SIZE*SIZE-1:0];    // 2D Array for storing Infmap
    reg [7:0] weight;    // register for storing weight
    reg [WIDTH-1:0] Outfmap [SIZE*SIZE-1:0];  // 2D Array for storing Outfmap
   
    (* mark_debug = "true", KEEP = "TRUE" *) wire [WIDTH-1:0] Outfmap1 [SIZE*SIZE-1:0];
    
    
    
    genvar a;
    generate
        for (a = 0; a < SIZE*SIZE; a = a + 1) begin : loop1
            always @(posedge clk or posedge rst) begin
                if (rst)
                    Outfmap[a] <= 16'd0;
                else if (!hold && conv_comp)
                    Outfmap[a] <= Outfmap1[a];
                // implicit else: hold value - this is the ONLY hold path now
            end
         end
    endgenerate
  
  
   integer i, j;
   
   genvar l;
   generate
        for(l=0; l<64; l = l+1) begin
            assign ENG_shift_w[l] = eng_shift[(((l+1)*WIDTH) - 1): (l*WIDTH)];
       end
   endgenerate
   
   
   genvar w;
   generate
        for(w=0; w<64; w = w+1) begin
            assign ENG_shift_out[(((w+1)*WIDTH) - 1): (w*WIDTH)] = Outfmap[w];
       end
   endgenerate
   
   
   genvar f;
    generate
        for (f = 0; f < SIZE*SIZE; f = f + 1) begin : UNPACK
            assign Infmap[f] = mem_data_inn[(f*8) +: 8];
        end
    endgenerate
   
     
   
   
    // Memory read/write logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset memory arrays
            weight <= 0;
        end else begin
           
              weight<= weight_in;
        end
    end   
    
    // Generate block to instantiate 8x8 array of processing elements
    genvar x, y;
    
            
    generate
        for (x = 0; x < SIZE; x = x + 1) begin : row_loop
            for (y = 0; y < SIZE; y = y + 1) begin : col_loop
                // Instantiating the PE module for each element in the 8x8 array
                (* dont_touch = "true" *) processingelement processing_element_inst (
                    .rst(rst),
                    .clk(clk),
                    .hold(hold),
                    .Infmap(Infmap[(y*SIZE)+x]),
                    .weight(weight),
                    .hor_shift((x == 0 ) ? 16'd0 : HOR_shift_wires[x-1][y]), // For the first PE in each row, connect to hor_shift_init, otherwise connect to the previous PE's HOR_shift
                    .vert_shift((y == 0) ? 16'd0 : VERT_shift_wires[x][y-1]), // For the first PE in each column, connect to vert_shift_init, otherwise connect to the previous PE's VERT_shift
                    .eng_shift(ENG_shift_w[(x*SIZE)+y]),
                    .Outfmap(Outfmap1[((x*8)+y)]),
                    .HOR_shift_out(HOR_shift_wires[x][y]),   // Output HOR_shift is connected to the next PE in the row
                    .VERT_shift_out(VERT_shift_wires[x][y]), // Output VERT_shift is connected to the next PE in the column
                    .ENG_shift_out(ENG_shift_wires[x][y]),
                    .ctrl0(ctrl0),
                    .ctrl1(ctrl1),
                    .add_enable(add_enable),
                    .acc_enable(acc_enable),
                    .add_eng(add_eng),
                    .flush(flush)
                );
            end
        end
    endgenerate

endmodule