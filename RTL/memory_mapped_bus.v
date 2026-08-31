`timescale 1ns / 1ps

module memory_mapped_bus(
input clk,
input rst,

////////////////////////////////////////////////////////////
// CPU Interface
////////////////////////////////////////////////////////////
input  [31:0] addr,
input  [31:0] w_data,
input         mem_read,
input         mem_write,
output [31:0] r_data,

////////////////////////////////////////////////////////////
// RAM PORT A
////////////////////////////////////////////////////////////
output [31:0] addra,
output [31:0] dina,
input  [31:0] douta,
output        wea,
output        ena,

////////////////////////////////////////////////////////////
// CNN Interface
////////////////////////////////////////////////////////////
output [31:0] cnn_addr,
output [31:0] cnn_wdata,
output        cnn_write,
output        cnn_read,
input  [31:0] cnn_rdata,

////////////////////////////////////////////////////////////
// UART Interface
////////////////////////////////////////////////////////////
    output [31:0] uart_addr,
    output [31:0] uart_wdata,
    output        uart_write,
    output        uart_read,
    input  [31:0] uart_rdata
);

////////////////////////////////////////////////////////////
// Address Decode
////////////////////////////////////////////////////////////

wire ram_en;
wire cnn_en;
wire uart_en;

Decoder_mem decoder(
    .addr(addr),
    .ram_en(ram_en),
    .cnn_en(cnn_en),
    .uart_en(uart_en)
);

////////////////////////////////////////////////////////////
// CPU -> RAM
////////////////////////////////////////////////////////////

assign addra = addr;
assign dina  = w_data;

assign wea = mem_write & ram_en;
assign ena = (mem_read | mem_write) & ram_en;

////////////////////////////////////////////////////////////
// CPU -> CNN Registers
////////////////////////////////////////////////////////////

assign cnn_addr  = addr;
assign cnn_wdata = w_data;

assign cnn_write  = mem_write  & cnn_en;
assign cnn_read   = mem_read & cnn_en;

assign uart_addr  = addr;
assign uart_wdata = w_data;

assign uart_write = mem_write & uart_en;
assign uart_read  = mem_read  & uart_en;




////////////////////////////////////////////////////////////
// Read Data Mux
////////////////////////////////////////////////////////////
reg [1:0] read_sel;

localparam RAM_SEL  = 2'd0;
localparam CNN_SEL  = 2'd1;
localparam UART_SEL = 2'd2;

always @(posedge clk or posedge rst) begin
    if (rst)
        read_sel <= RAM_SEL;
    else if (mem_read) begin
        if (cnn_en)
            read_sel <= CNN_SEL;
        else if (uart_en)
            read_sel <= UART_SEL;
        else
            read_sel <= RAM_SEL;
    end
end


assign r_data =
    (read_sel == CNN_SEL)  ? cnn_rdata  :
    (read_sel == UART_SEL) ? uart_rdata :
                             douta;

endmodule