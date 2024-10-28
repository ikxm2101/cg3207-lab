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
	wire [7:0] UART_TX;
	reg  UART_TX_ready = 0;
	wire UART_TX_valid;
	reg  [7:0] UART_RX = 0;
	reg  UART_RX_valid = 0;
	wire UART_RX_ack;
	reg  RESET = 0;					
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

	task automatic UART_TransmitString(input string str);
		/* Sequence of signals for UART input:
			* 1. Write an input to UART_RX
			* 2. Set UART_RX_valid to 1
			* 3. Wait for UART_RX_ack to be 1
			* 4. Wait for UART_RX_ack to be 0
			* 4. Set UART_RX_valid to 0
		*/
		for (int i = 0; i < str.len(); i++) begin
			UART_RX = str[i];
			UART_RX_valid = 1'b1;
			wait(UART_RX_ack);
			wait(~UART_RX_ack);
			UART_RX_valid = 1'b0;
		end

		// Send carriage return, '\r' to indicate end of string
		UART_RX = 8'h0D; // '\r'
        UART_RX_valid = 1'b1;
        wait(UART_RX_ack);
        wait(~UART_RX_ack);
        UART_RX_valid = 1'b0;
	endtask

	string UART_TXString = "";
	task automatic UART_ReceiveString();
		while (LED_PC != LED_PC_MAIN) begin
			@(UART_TX) begin
				UART_TXString = {UART_TXString, string'(UART_TX)};
			end
		end
	endtask
	
	/* Clock generation */      
    always #5 CLK = ~CLK ; // invert clk every 5 time units (ns) -> period of 10 ns -> 100 MHz clock

	/* LED_PC for instructions of interest */
	
	// To verify datapath with lab3_check_datapath.asm
	// localparam LED_PC_TEST_MUL = 7'b000_0100;
	// localparam LED_PC_CHECK_MUL = 7'b000_0101;
	// localparam LED_PC_TEST_REM = 7'b000_0110;
	// localparam LED_PC_CHECK_REM = 7'b000_0111;
	// localparam LED_PC_TEST_DIVU = 7'b000_1000;
	// localparam LED_PC_CHECK_DIVU = 7'b000_1001;

	// To verify overall functionality with lab3.asm
	// localparam LED_PC_MAIN = 7'b000_0000;
	// localparam LED_PC_WAIT_X1 = 7'b010_0110;
	// localparam LED_PC_WAIT_Y1 = 7'b011_0000;
	// localparam LED_PC_WAIT_X2 = 7'b011_1010;
	// localparam LED_PC_WAIT_Y2 = 7'b100_0100;
	
	// To verify overall functionality with lab3_backup.asm
	localparam LED_PC_MAIN = 7'b000_0000;
	localparam LED_PC_WAIT_X = 7'b010_0010;
	localparam LED_PC_WAIT_Y = 7'b010_1010;
	localparam LED_PC_DISPLAY_LOOP = 7'b011_0100;
	
	/* Testbench stimuli */
    initial begin
		/* Initialise signals */
		CLK = 1; // so posedges happen at intervals of 10ns
		DIP = 16'h0000;

		/* 
		 * OK to keep UART_TX_ready high continously in the testbench.
		 * In reality, it will be high only if UART is ready to send a data to PC
		*/
		UART_TX_ready = 1'h1;
		// $monitor("Time= %t, RegBank: %p", $time, dut.RV1.IRegFile1.RegBank);

		$monitor("Time= %t, SEVENSEGHEX: %d", $time, SEVENSEGHEX);

		$monitor("Time= %t, UART_RX: %d", $time, UART_RX);
		// $monitor("Time= %t, UART_TX: %s", $time, UART_TX);
		// $monitor("Time= %t, UART_TXputString: %s", $time, UART_TXputString);

		// TODO: Insert rest of the stimuli here
		/*
		 * User inputs:
		 	* UART_RX:

		 * User outputs: 
		 	* UART_TX:
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
		// wait(LED_PC == LED_PC_WAIT_X1);
		// UART_TransmitString("1");

		// wait(LED_PC == LED_PC_WAIT_Y1);
		// UART_TransmitString("1");

		// wait(LED_PC == LED_PC_WAIT_X2);
		// UART_TransmitString("2");

		// wait(LED_PC == LED_PC_WAIT_Y2);
		// UART_TransmitString("2");

		// UART_ReceiveString();
		
		/* Verifies overall functionality with lab3_backup.asm */
		wait(LED_PC == LED_PC_WAIT_X);
		UART_TransmitString("444");

		wait(LED_PC == LED_PC_WAIT_Y);
		UART_TransmitString("222");

		wait(LED_PC == LED_PC_DISPLAY_LOOP);
		DIP_SetSwitches(16'h0000); // division
        repeat(100) @(posedge CLK);
        
		wait(LED_PC == LED_PC_DISPLAY_LOOP);
		DIP_SetSwitches(16'h0001); // multiplication
       	repeat(100) @(posedge CLK);
        
        /* Reset the processor */
		RESET = 1; repeat(2) @(posedge CLK); RESET = 0;
		
		wait(LED_PC == LED_PC_WAIT_X);
		UART_TransmitString("222");

		wait(LED_PC == LED_PC_WAIT_Y);
		UART_TransmitString("444");

		wait(LED_PC == LED_PC_DISPLAY_LOOP);
		DIP_SetSwitches(16'h0000); // division
        repeat(100) @(posedge CLK);
        
		wait(LED_PC == LED_PC_DISPLAY_LOOP);
		DIP_SetSwitches(16'h0001); // multiplication
		
		repeat(100) @(posedge CLK); // wait for 100 clock cycles before finishing the simulation
		$finish;
    end
    
endmodule
