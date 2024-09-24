`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2024 18:19:06
// Design Name: 
// Module Name: top
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


module top(
    input clk,  			// fundamental clock 1MHz
    input btnU, 			// button BTNU for 4Hz speed
    input btnC, 			// button BTNC for pause
    output [15:0] led,  	// 16 LEDs to display upper or lower 16 bits of memory data
    output dp,  			// dot point of 7-segments, can be deleted if 7-segments are not implemented
    output [7:0] anode, 	// anodes of 7-segments, can be deleted if 7-segments are not implemented
    output [6:0] cathode);  // cathodes of 7-segments, can be deleted if 7-segments are not implemented
		
    wire clk_enable;        // enable signal to read the next memory content
    wire lower;   	        // 1-bit signal used between modules to indicate either upper or lower 16-bit contents is displaying on LEDs, lower = 1 to display upper half of the memory data
    wire [31:0] data;       // entire 32-bit contents displaying on LEDs and 7-segments, can be deleted if 7-segments are not implemented

    // Choose 1 Hz or 4 Hz display frequency based on BTNU and BTNC readings, using given module clock_enable.v
    clock_enable Iclock_enable_0 (
        .*
    );

    // Fetch memory content, using given module get_mem.v
    get_mem Iget_mem_0 (
        .*
    );

    // Displays the 32-bit memory data on 7-segments, using given module seven_seg.v
    seven_seg Iseven_seg_0 (
        .*
    );

    // Split the 32-bit Memory data using a multiplexer to display on led 
    assign led = lower ? data[15:0] : data[31:16];

endmodule
