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
	parameter N_PBs		= 3 
	)(
	);
	
	// Signals for the Device Under Test (DUT)
	reg  [N_DIPs-1:0] DIP = 0;		
	reg  [N_PBs-1:0] PB = 0;			
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
	
	// Instantiate DUT
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
	
	// GENERATE CLOCK       
    always #5 CLK = ~CLK ; // invert clk every 5 time units

	logic btnR = PB[0];
	logic btnC = PB[1];
	logic btnL = PB[2];

	// STIMULI
    initial begin
		RESET = 1; #10; RESET = 0; // hold reset state for 10 ns.

		// CONSOLE_OUT_ready = 1'h1; // ok to keep it high continously in the testbench. In reality, it will be high only if UART is ready to send a data to PC

		// /* Sequence of signals for UART input
		//  * 1. Write an input to CONSOLE_IN
		//  * 2. Set CONSOLE_IN_valid to 1
		//  * 3. Wait for CONSOLE_IN_ack to be 1
		//  * 4. Set CONSOLE_IN_valid to 0
		// */
        // CONSOLE_IN = 8'h50; // 'P'. Will be read and ignored by the processor
        // CONSOLE_IN_valid = 1'h1;
        // wait(CONSOLE_IN_ack);
        // wait(~CONSOLE_IN_ack);
        // CONSOLE_IN_valid = 1'h0;
        // #105;

        // CONSOLE_IN = 8'h41;// 'A'
        // CONSOLE_IN_valid = 1'h1;
        // wait(CONSOLE_IN_ack);
        // wait(~CONSOLE_IN_ack);
		// CONSOLE_IN_valid = 1'h0;
        // #105;

        // CONSOLE_IN = 8'h0D; // '\r'
        // CONSOLE_IN_valid = 1'h1;
        // wait(CONSOLE_IN_ack); // should print "Welcome to CG3207" following this.
        // wait(~CONSOLE_IN_ack);
        // CONSOLE_IN_valid = 1'h0;
		
		// TODO: Insert rest of the stimuli here
		/*
		 * User inputs:
		 	* DIP:	DIPs[7:0] -> rs1, DIPs[15:8] -> rs2
		 	* PB:	btnC -> used to change the display result to showcase 'sub' instruction
			* 		btnL -> used to showcase 'sll' instruction
			* 		btnR -> used to showcase 'sra' instruction
		 * User outputs: 
		 	* LED_OUT: 		8-bit output to display the results:
								* 1. 'and'
								* 2. 'or' 
			* SEVENSEGHEX: 	display the results:
								* 1. 'add'
								* 2. 'sub'
		*/
		/* Test Case 1 */
		DIP = 16'b1100_1100_1010_1010; #10;
		btnC = 0; #10;
		$display("AND Operation: LED_OUT = %b", LED_OUT);
		assert(LED_OUT == 8'b1000_1000) else $error("AND Operation failed");

		$display("ADD Operation: SEVENSEGHEX = %b", SEVENSEGHEX);
		assert(SEVENSEGHEX == 8'b1000_0000) else $error("ADD Operation failed");

		$display("OR Operation: LED_OUT = %b", LED_OUT);
		assert(LED_OUT == 8'b1110_1110) else $error("OR Operation failed");

		$display("SUB Operation: SEVENSEGHEX = %b", SEVENSEGHEX);
		assert(SEVENSEGHEX == 8'b1101_1110) else $error("SUB Operation failed");

		#50;

		btnC = 1; #10; btnC = 0;
		$display("SUB Operation: SEVENSEGHEX = %b", SEVENSEGHEX);
		assert(SEVENSEGHEX == 8'b1101_1110) else $error("SUB Operation failed");
		
		btnL = 1; #10; btnL = 0;
		$display("SLL Operation: SEVENSEGHEX = %b", SEVENSEGHEX);
		assert(SEVENSEGHEX == 8'b0101_0100) else $error("SLL Operation failed");

		btnR = 1; #10; btnR = 0;
		$display("SRA Operation: SEVENSEGHEX = %b", SEVENSEGHEX);
		assert(SEVENSEGHEX == 8'b1101_0101) else $error("SRA Operation failed");

		$finish;
    end
    
endmodule
