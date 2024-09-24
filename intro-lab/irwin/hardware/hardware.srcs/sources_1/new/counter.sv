`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2024 18:19:06
// Design Name: 
// Module Name: counter
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


module counter #(
    parameter COUNT_WIDTH = 8
    )(
    input clk,
    input clk_enable,
    output reg [COUNT_WIDTH-1:0] count = 0);

    always @(posedge clk) begin
        if (clk_enable) begin
            count <= count + 1;
        end
    end
endmodule
