`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2024 18:19:06
// Design Name: 
// Module Name: clock_enable
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


module clock_enable #(
	parameter BASE_FREQUENCY = 1_0000_0000  // 100 MHz
	)(
	input clk,			    // fundamental clock 100 MHz
	input btnU,			    // button BTNU for 4Hz speed
	input btnC,			    // button BTNC for pause
	output reg clk_enable = 0);	// output signal used to enable the reading of next memory data

	// define reg threshold to allow 4 Hz or 1 Hz frequency
	localparam THRESHOLD_1HZ = BASE_FREQUENCY;
	localparam THRESHOLD_4HZ = BASE_FREQUENCY / 4;
	
	// for simulation purposes
	localparam THRESHOLD_25MHZ = 4;
	localparam THRESHOLD_50MHZ = 2;

	// define reg counter to be able to count to certain threshold value
	localparam BASE_COUNT_WIDTH = 32;
	reg [BASE_COUNT_WIDTH-1:0] base_count = 0;
	
	// complete this always block by determining the enable output by counter, threshold and buttons 
	always @(posedge clk) begin
        if (btnC) begin
            clk_enable <= 0;
		end else begin
			base_count <= base_count + 1;
			if (btnU) begin
				if (base_count >= THRESHOLD_4HZ) begin
					clk_enable <= 1;
					base_count <= 0;
				end else begin
					clk_enable <= 0;
				end
			end else begin
				if (base_count >= THRESHOLD_1HZ) begin
					clk_enable <= 1;
					base_count <= 0;
				end else begin
					clk_enable <= 0;
				end
			end
		end
    end		


endmodule
