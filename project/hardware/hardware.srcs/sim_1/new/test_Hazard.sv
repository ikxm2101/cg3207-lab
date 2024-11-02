`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.11.2024 03:55:25
// Design Name: 
// Module Name: test_Hazard
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


module test_Hazard #(
    parameter N_LEDs_OUT	= 8,					
	parameter N_DIPs		= 16,
	parameter N_PBs			= 3 
    )(
    );
    
	/* Instantiation of Wrapper as the DUT */
	// Signals for the Device Under Test (DUT) 
	reg  [N_DIPs-1:0] DIP = 0;
	/* User pushbuttons -> PB[2:0] btnL, btnC, btnR */ 
	logic btnL = 0, btnC = 0, btnR = 0;
	reg  [N_PBs-1:0] PB = {btnL, btnC, btnR};			
	wire [N_LEDs_OUT-1:0] LED_OUT;
	wire [6:0] LED_PC;			
	wire [31:0] SEVENSEGHEX;	
	wire [7:0] UART_TX;
	reg  UART_TX_ready = 0;
	wire UART_TX_valid;
	reg  [7:0] UART_RX = 0;
	reg  UART_RX_valid = 0;
	wire UART_RX_ack;
	reg  RESET = 1;					
	reg  CLK = 0;				
	
	// Module instantiation of wrapper
	Wrapper dut (
		.DIP(DIP), 
		.PB(PB), 
		.LED_OUT(LED_OUT), 
		.LED_PC(LED_PC), 
		.SEVENSEGHEX(SEVENSEGHEX), 
		.UART_TX(UART_TX), 
		.UART_TX_ready(UART_TX_ready), 
		.UART_TX_valid(UART_TX_valid), 
		.UART_RX(UART_RX), 
		.UART_RX_valid(UART_RX_valid), 
		.UART_RX_ack(UART_RX_ack), 
		.RESET(RESET), 
		.CLK(CLK)
	);

    // Expected pattern array
    reg [31:0] expected_pattern [0:10]; // Adjust the size as needed for your test
    integer i;

    /* Clock generation */      
    always #5 CLK = ~CLK ; // invert clk every 5 time units (ns) -> period of 10 ns -> 100 MHz clock

    initial begin
        #10; RESET = 0;

        // Initialize expected pattern
        expected_pattern[0] = 32'd0;
        expected_pattern[1] = 32'd57;
        expected_pattern[2] = 32'd47;
        expected_pattern[3] = 32'd63;
        expected_pattern[4] = 32'd8;
        expected_pattern[5] = 32'd69;
        expected_pattern[6] = 32'd5;
        expected_pattern[7] = 32'd103;
        expected_pattern[8] = 32'd22;
        expected_pattern[9] = 32'd15;
        expected_pattern[10] = 32'd0;



        // ... (fill in the pattern)

        // Monitor the output and check against expected values when it changes
        i = 0; // Start with the first pattern
        $monitor("Time= %t, SEVENSEGHEX: %h", $time, SEVENSEGHEX);

        while (i < 11) begin
            @(SEVENSEGHEX); // Wait for SEVENSEGHEX to change
            if (SEVENSEGHEX !== expected_pattern[i]) begin
                $display("Error at time %t: Expected %d, got %d", $time, expected_pattern[i], SEVENSEGHEX);
            end
            i = i + 1; // Move to the next expected value
        end

        $finish;

    end
endmodule
