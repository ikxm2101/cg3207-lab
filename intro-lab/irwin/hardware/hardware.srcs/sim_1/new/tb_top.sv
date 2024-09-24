`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.09.2024 13:12:53
// Design Name: 
// Module Name: tb_top
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


module tb_top(

    );

    /* Simulation inputs */
    reg clk;
    reg btnU;
    reg btnC;

    /* Simulation outputs */
    wire [15:0] led;
    wire dp;
    wire [7:0] anode;
    wire [6:0] cathode;

    /* Instantiate top as the device under test (DUT) */
    top Idut (  
        .*
    );

    /* Testbench logic */

    // 100 MHz clock generation
    initial begin 
        clk = 0;
        forever #5 clk = ~clk; // toggle the clock
    end

    // Stmuli
    initial begin
        btnU = 0; btnC = 0; #10240; // cycle at 25MHz
        btnU = 0; btnC = 1; #100; // pause
        btnU = 1; btnC = 0; #5120; // cycle at 50MHz
        btnU = 1; btnC = 1; #100; // pause
        $finish;
    end

endmodule
