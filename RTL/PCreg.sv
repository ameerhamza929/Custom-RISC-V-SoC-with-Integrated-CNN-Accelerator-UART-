`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module PCreg(
    input clk,
    input rst,
    input en,
    input [31:0]PCin,
    input start,
    output logic [31:0]PCout
    );
    
    always@(posedge clk or posedge rst)begin
        if(rst)
            PCout<= 0;
        else begin
            if(en)begin
                PCout <= PCin;
            end
        end
    
    end
    
endmodule
