`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
--	(c) Thao Nguyen and Rajesh Panicker
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vi) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
*/
module test_lab4Wrapper #(
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
	wire OLED_Write = 0;
	wire [6:0] OLED_Col;
	wire [3:0] OLED_Row;
	wire [7:0] OLED_Data;
	reg  RESET = 1;					
	reg  CLK = 1;				
	
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
		.OLED_Write(OLED_Write),
		.OLED_Col(OLED_Col),
		.OLED_Row(OLED_Row),
		.OLED_Data(OLED_Data),
		.ACCEL_Data(ACCEL_Data),
		.ACCEL_DReady(ACCEL_DReady),
		.RESET(RESET), 
		.CLK(CLK)
	);
	
	/* Clock generation */      
    always #5 CLK = ~CLK ; // invert clk every 5 time units (ns) -> period of 10 ns -> 100 MHz clock

	/* Testbench stimuli */
    initial begin
		repeat(2) @(posedge CLK); RESET = 0;

		$monitor("Time= %t, OLED_Write: %d", $time, OLED_Write);
		$monitor("Time= %t, OLED_Col: %d", $time, OLED_Col);
		$monitor("Time= %t, OLED_Row: %d", $time, OLED_Row);
		$monitor("Time= %t, OLED_Data: %d", $time, OLED_Data);
	
		repeat(50000) @(posedge CLK); // wait for 100 clock cycles before finishing the simulation
		$finish;
    end
    
endmodule
