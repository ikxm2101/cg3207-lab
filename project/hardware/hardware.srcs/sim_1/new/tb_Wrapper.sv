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
module tb_Wrapper #(
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
	wire [7:0] CONSOLE_OUT;
	reg  CONSOLE_OUT_ready = 0;
	wire CONSOLE_OUT_valid;
	reg  [7:0] CONSOLE_IN = 0;
	reg  CONSOLE_IN_valid = 0;
	wire CONSOLE_IN_ack;
	reg  RESET = 0;					
	reg  CLK = 0;				
	
	// Module instantiation of wrapper
	Wrapper dut (
		.DIP(DIP), 
		.PB(PB), 
		.LED_OUT(LED_OUT), 
		.LED_PC(LED_PC), 
		.SEVENSEGHEX(SEVENSEGHEX), 
		.CONSOLE_OUT(CONSOLE_OUT), 
		.CONSOLE_OUT_ready(CONSOLE_OUT_ready), 
		.CONSOLE_OUT_valid(CONSOLE_OUT_valid), 
		.CONSOLE_IN(CONSOLE_IN), 
		.CONSOLE_IN_valid(CONSOLE_IN_valid), 
		.CONSOLE_IN_ack(CONSOLE_IN_ack), 
		.RESET(RESET), 
		.CLK(CLK)
	);
	
	/* 
	 * Automatic tasks:
	 *	1. New instances of local variables are created for each call.
	 *	2. Local variables don't retain values between calls.
	 * Non-automatic (static) tasks:
	 *	1. Local variables retain their values between calls.
	 *	2. There's only one instance of each local variable, shared across all calls.
	 */

	/* Tasks for button and DIP switches */
	task automatic press_button(ref logic button, input int hold_cycles = 5);
		@(posedge CLK);
		button = 1'b1;
		repeat(hold_cycles) @(posedge CLK); // hold the button for number_cycles
		button = 1'b0;
  	endtask
	
	task automatic reset_button(ref logic button);
		@(posedge CLK);
		button = 1'b0;
	endtask

	task set_dip_switches(input [15:0] dip_value);
		@(posedge CLK);
		DIP = dip_value;
  	endtask

	/* Clock generation */      
    always #5 CLK = ~CLK ; // invert clk every 5 time units (ns)

	// STIMULI
    initial begin
		/* Initialise signals */
		CLK = 0;
		PB = 3'b000;
		DIP = 16'h0000;

		// TODO: Insert rest of the stimuli here
		/*
		 * User inputs:
		 	* DIP:	DIPs[7:0] -> rs1, DIPs[15:8] -> rs2
		 	* PB:	btnC -> used to change the display result to showcase 'sub' instruction
			* 		btnL -> used to showcase 'sll' instruction
			* 		btnR -> used to showcase 'sra' instruction
		 * User outputs: 
		 	* LED_OUT: LED[15:8] -> 8-bit output to display the results:
										* 1. 'and'
										* 2. 'or' 
			* SEVENSEGHEX: 	display the results:
								* 1. 'add'
								* 2. 'sub'
		*/

		/* Test Case 1: DIP = 16'h1234 */
		set_dip_switches(16'h1234);
		/* Reset the processor */
		RESET = 1; repeat(2) @(posedge CLK); RESET = 0; 

		/*
		 * btnC = 0 -> Cycles between:
		 *			-> and instruction on LED_OUT / add instruction on SEVENSEGHEX
		 * 			-> OR instruction on LED_OUT / sub instruction on SEVENSEGHEX
		*/
		reset_button(.button(btnC));
		$display("and instruction: LED_OUT = %b", LED_OUT);
		assert(LED_OUT == 8'b0001_0000) else $error("and instruction failed");

		$display("ADD instruction: SEVENSEGHEX = %b", SEVENSEGHEX);
		assert(SEVENSEGHEX == 8'b1000_0000) else $error("add instruction failed");
		
		repeat(20) @(posedge CLK);
		
		reset_button(.button(btnC));
		$display("or instruction: LED_OUT = %b", LED_OUT);
		assert(LED_OUT == 8'b0011_0110) else $error("or instruction failed");

		$display("sub instruction: SEVENSEGHEX = %b", SEVENSEGHEX);
		assert(SEVENSEGHEX == 8'b1101_1110) else $error("sub instruction failed");

		repeat(10) @(posedge CLK);

		/*
		 * btnC = 1 -> Changes SEVENSEGHEX display to showcase sub instruction:
		 *			-> sll done on sub instruction output
		 * 			-> sra done on sub instruction output
		*/
		press_button(.button(btnC), .hold_cycles(10));
		$display("sub instruction: SEVENSEGHEX = %b", SEVENSEGHEX);
		assert(SEVENSEGHEX == 8'b1101_1110) else $error("sub instruction failed");
		
		repeat(5) @(posedge CLK);

		press_button(.button(btnL), .hold_cycles(2));
		$display("sll instruction: SEVENSEGHEX = %b", SEVENSEGHEX);
		assert(SEVENSEGHEX == 8'b0101_0100) else $error("sll instruction failed");

		press_button(.button(btnR), .hold_cycles(2));
		$display("sra instruction: SEVENSEGHEX = %b", SEVENSEGHEX);
		assert(SEVENSEGHEX == 8'b0010_1010) else $error("sra instruction failed");

		$finish;
    end
    
endmodule
