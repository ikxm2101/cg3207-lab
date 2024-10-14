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
module test_Wrapper #(
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
	
	/* Tasks */
	/* NOTE:
	 * Automatic tasks:
	 *	1. New instances of local variables are created for each call.
	 *	2. Local variables don't retain values between calls.
	 * Non-automatic (static) tasks:
	 *	1. Local variables retain their values between calls.
	 *	2. There's only one instance of each local variable, shared across all calls.
	 */

	task automatic PB_PressButton(ref logic button, input [6:0] release_PC);
		button = 1'b1; // set button
		PB = {btnL, btnC, btnR}; // update PB register
		wait(LED_PC == release_PC);
		button = 1'b0; // release button
		PB = {btnL, btnC, btnR}; // update PB register
  	endtask
	
	task automatic PB_ResetButton(ref logic button);
		button = 1'b0;
	endtask

	task automatic DIP_SetSwitches(input [15:0] dip_value);
		DIP = dip_value;
  	endtask

	task automatic CONSOLE_TransmitString(input string str);
		/* Sequence of signals for UART input:
			* 1. Write an input to CONSOLE_IN
			* 2. Set CONSOLE_IN_valid to 1
			* 3. Wait for CONSOLE_IN_ack to be 1
			* 4. Wait for CONSOLE_IN_ack to be 0
			* 4. Set CONSOLE_IN_valid to 0
		*/
		for (int i = 0; i < str.len(); i++) begin
			CONSOLE_IN = str[i];
			CONSOLE_IN_valid = 1'b1;
			wait(CONSOLE_IN_ack);
			wait(~CONSOLE_IN_ack);
			CONSOLE_IN_valid = 1'b0;
		end

		// Send carriage return, '\r' to indicate end of string
		CONSOLE_IN = 8'h0D; // '\r'
        CONSOLE_IN_valid = 1'b1;
        wait(CONSOLE_IN_ack);
        wait(~CONSOLE_IN_ack);
        CONSOLE_IN_valid = 1'b0;
	endtask

	string CONSOLE_OutputString = "";
	task automatic CONSOLE_ReceiveString();
		while (LED_PC != LED_PC_MAIN) begin
			@(CONSOLE_OUT) begin
				CONSOLE_OutputString = {CONSOLE_OutputString, string'(CONSOLE_OUT)};
			end
		end
	endtask
	
	/* Clock generation */      
    always #5 CLK = ~CLK ; // invert clk every 5 time units (ns) -> period of 10 ns -> 100 MHz clock

	/* LED_PC for instructions of interest */
	
	// To verify datapath with lab3_check_datapath.asm
	localparam LED_PC_TEST_MUL = 7'b000_0100;
	localparam LED_PC_CHECK_MUL = 7'b000_0101;
	localparam LED_PC_TEST_REM = 7'b000_0110;
	localparam LED_PC_CHECK_REM = 7'b000_0111;
	localparam LED_PC_TEST_DIVU = 7'b000_1000;
	localparam LED_PC_CHECK_DIVU = 7'b000_1001;

	// To verify overall functionality with lab3.asm
	localparam LED_PC_MAIN = 7'b000_0000;
	localparam LED_PC_WAIT_X1 = 7'b010_0110;
	localparam LED_PC_WAIT_Y1 = 7'b011_0000;
	localparam LED_PC_WAIT_X2 = 7'b011_1010;
	localparam LED_PC_WAIT_Y2 = 7'b100_0100;

	/* Testbench stimuli */
    initial begin
		/* Initialise signals */
		CLK = 1; // so posedges happen at intervals of 10ns

		/* 
		 * OK to keep CONSOLE_OUT_ready high continously in the testbench.
		 * In reality, it will be high only if UART is ready to send a data to PC
		*/
		CONSOLE_OUT_ready = 1'h1;
		// $monitor("Time= %t, RegBank: %p", $time, dut.RV1.IRegFile1.RegBank);

		// $monitor("Time= %t, SEVENSEGHEX: %d", $time, SEVENSEGHEX);

		$monitor("Time= %t, CONSOLE_IN: %s", $time, CONSOLE_IN);
		$monitor("Time= %t, CONSOLE_OUT: %s", $time, CONSOLE_OUT);
		$monitor("Time= %t, CONSOLE_OutputString: %s", $time, CONSOLE_OutputString);

		// TODO: Insert rest of the stimuli here
		/*
		 * User inputs:
		 	* CONSOLE_IN:

		 * User outputs: 
		 	* CONSOLE_OUT:
		*/
		
		/* Reset the processor */
		RESET = 1; repeat(2) @(posedge CLK); RESET = 0;
		
		/* Verifies datapath with lab3_check_datapath.asm */
		// forever begin
		// 	wait(LED_PC == LED_PC_CHECK_MUL);
		// 	wait(LED_PC == LED_PC_CHECK_REM);
		// 	wait(LED_PC == LED_PC_CHECK_DIVU);
		// end
		
		/* Verifies overall functionality with lab3.asm */
		wait(LED_PC == LED_PC_WAIT_X1);
		CONSOLE_TransmitString("10");

		wait(LED_PC == LED_PC_WAIT_Y1);
		CONSOLE_TransmitString("20");

		wait(LED_PC == LED_PC_WAIT_X2);
		CONSOLE_TransmitString("30");

		wait(LED_PC == LED_PC_WAIT_Y2);
		CONSOLE_TransmitString("40");

		CONSOLE_ReceiveString();
		
		repeat(100) @(posedge CLK); // wait for 100 clock cycles before finishing the simulation
		$finish;
    end
    
endmodule
