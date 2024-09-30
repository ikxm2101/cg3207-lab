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
	task automatic press_button(ref logic button, input [6:0] release_PC);
		button = 1'b1; // set button
		PB = {btnL, btnC, btnR}; // update PB register
		wait(LED_PC == release_PC);
		button = 1'b0; // release button
		PB = {btnL, btnC, btnR}; // update PB register
  	endtask
	
	task automatic reset_button(ref logic button);
		button = 1'b0;
	endtask

	task set_dip_switches(input [15:0] dip_value);
		DIP = dip_value;
  	endtask

	/* Clock generation */      
    always #5 CLK = ~CLK ; // invert clk every 5 time units (ns) -> period of 10 ns -> 100 MHz clock

	/* LED_PC for instructions of interest 
	 * DISPLAY1 -> cycling display
	 * DISPLAY2 -> display to showcase sll and sra 
	*/

	/* Used with previous revision of lab2.asm that implements button presses in polling mode 
	// localparam DISPLAY1_BUTTON_READ = 7'b001_0100;
	// localparam DISPLAY1_SHOW_LED_1 = 7'b001_1001;
	// localparam DISPLAY1_SHOW_SEVENSEG_1 = 7'b001_1010;
	// localparam DISPLAY1_SHOW_LED_2 = 7'b001_1101;
	// localparam DISPLAY1_SHOW_SEVENSEG_2 = 7'b001_1010;
	
	// localparam DISPLAY2_BUTTON_READ = 7'b010_0100;
	// localparam CHANGE_TO_DISPLAY2_ENTRY = 7'b010_0011;
	// localparam DISPLAY2_BTNL_SLL_ENTRY = 7'b010_1111;
	// localparam DISPLAY2_BTNR_SRA_ENTRY = 7'b010_1101;
	*/

	/* Used with newest revision of lab2.asm that implements button presses in polling mode with flags */
	localparam DETECT_BUTTON = 7'b000_1111;
    
    // sub, or
	localparam NORMAL_DISPLAY_F0_SHOW_LED = 7'b011_0010;
	localparam NORMAL_DISPLAY_F0_SHOW_SEVENSEG = 7'b011_0011;
	
	// add, and
	localparam NORMAL_DISPLAY_F1_SHOW_LED = 7'b010_1110;
	localparam NORMAL_DISPLAY_F1_SHOW_SEVENSEG = 7'b010_1111;

	localparam MODE_SELECT_ENTRY = 7'b001_1000;

	// STIMULI
    initial begin
		/* Initialise signals */
		CLK = 1; // so posedges happen at intervals of 10ns
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

		/* Test Cases */
		// set_dip_switches(16'h1234);
		// set_dip_switches(16'hA050); // to test sra (DIPS[7:0] - DIPS[15:8] = -80, implemented in previous lab2.asm revision)
		set_dip_switches(16'h50A0); // to test sra (DIPS[15:8] - DIPS[7:0] = -80, implemented in newest lab2.asm revision)

		/* Reset the processor */
		RESET = 1; repeat(2) @(posedge CLK); RESET = 0; 

		/*
		 * btnC = 0 -> Cycles between:
		 *			-> and instruction on LED_OUT / add instruction on SEVENSEGHEX
		 * 			-> OR instruction on LED_OUT / sub instruction on SEVENSEGHEX
		*/
		wait (LED_PC == DETECT_BUTTON);
		reset_button(.button(btnC));

		wait (LED_PC == NORMAL_DISPLAY_F1_SHOW_LED);
		$display("and instruction: LED_OUT = %b", LED_OUT);
		// assert(LED_OUT == 8'b0001_0000) else $error("and instruction failed");

		wait (LED_PC == NORMAL_DISPLAY_F1_SHOW_SEVENSEG);
		$display("ADD instruction: SEVENSEGHEX = %b", SEVENSEGHEX);
		// assert(SEVENSEGHEX == 8'b0100_0110) else $error("add instruction failed");
		
		wait (LED_PC == NORMAL_DISPLAY_F0_SHOW_LED);
		$display("or instruction: LED_OUT = %b", LED_OUT);
		// assert(LED_OUT == 8'b0011_0110) else $error("or instruction failed");

		wait (LED_PC == NORMAL_DISPLAY_F0_SHOW_SEVENSEG);
		$display("sub instruction: SEVENSEGHEX = %b", SEVENSEGHEX);
		// assert(SEVENSEGHEX == 8'b0010_0010) else $error("sub instruction failed");

		/*
		 * btnC = 1 -> Changes SEVENSEGHEX display to showcase sub instruction:
		 *			-> sll done on sub instruction output
		 * 			-> sra done on sub instruction output
		*/

		wait (LED_PC == DETECT_BUTTON);
		press_button(.button(btnC), .release_PC(MODE_SELECT_ENTRY)); // change to different display mode to showcase sll and sra
		$display("sub instruction: SEVENSEGHEX = %b", SEVENSEGHEX);
		// assert(SEVENSEGHEX == 8'b1101_1110) else $error("sub instruction failed");

		wait (LED_PC == DETECT_BUTTON);
		press_button(.button(btnL), .release_PC(MODE_SELECT_ENTRY));
		$display("sll instruction: SEVENSEGHEX = %b", SEVENSEGHEX);
		// assert(SEVENSEGHEX == 8'b0101_0100) else $error("sll instruction failed");

		wait (LED_PC == DETECT_BUTTON);
		press_button(.button(btnR), .release_PC(MODE_SELECT_ENTRY));
		$display("sra instruction: SEVENSEGHEX = %b", SEVENSEGHEX);
		// assert(SEVENSEGHEX == 8'b0010_1010) else $error("sra instruction failed");

		repeat(100) @(posedge CLK); // wait for 100 clock cycles before finishing the simulation
		$finish;
    end
    
endmodule
