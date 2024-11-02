`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2024 19:09:09
// Design Name: 
// Module Name: test_fixsub
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


module test_fixsub #(
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
    
    /* Clock generation */      
    always #5 CLK = ~CLK ; // invert clk every 5 time units (ns) -> period of 10 ns -> 100 MHz clock
    
    initial begin
        #10; RESET = 0;
        $monitor("Time= %t, SEVENSEGHEX: %d", $time, SEVENSEGHEX);
 
        repeat(100000) @(posedge CLK); // wait for 100 clock cycles before finishing the simulation
    $finish;
    end
endmodule
