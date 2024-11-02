`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: Rajesh Panicker  
-- 
-- Create Date: 09/22/2020 06:49:10 PM
-- Module Name: Wrapper
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 / Basys 3
-- Tool Versions: Vivado 2019.2
-- Description: Wrapper for RISC-V processor. Not meant to be synthesized directly.
-- 
-- Dependencies: NIL
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: The interface SHOULD NOT be modified unless you modify TOP.vhd too. The implementation can be modified.
-- 
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate anyone's intellectual property.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v) send an email to rajesh<dot>panicker<at>ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vi) retain this notice in this file as well as any files derived from this.
----------------------------------------------------------------------------------
*/

//>>>>>>>>>>>> ******* FOR SIMULATION. DO NOT SYNTHESIZE THIS DIRECTLY (This is used as a component in TOP.vhd for Synthesis) ******* <<<<<<<<<<<<


/*
******* New features in V2 *******
- Ability to use the hexadecimal text dump from RARS directly without any conversion software or copy-pasting needed.
- Instruction and data memory sizes can be bigger than 128 words. Be mindful of the potentially increased synthesis time though.
- Addresses except IROM_BASE and DATA_MEM_BASE are hierarchically derived instead of hard-coding.
- Byte and half-word write to data memory and 7-segment display (sb and sh support) - aligned memory addresses and pre-shifted/aligned data required. Please read the relevant comments carefully.
--Note: byte and half-word read don't require any Wrapper support - you can simply read the whole byte, extract the byte/half-word, and extend as necessary.
- Possible to use a different Memory Configuration from RARS, *except* supporting 32'hFFFF0000 as the MMIO base in the RARS default. MMIO_BASE = DRAM_BASE + 2**DRAM_DEPTH_BITS in all configs.
- Possible to use block RAMs (sync read) for instruction and data memories in the pipelined version. Allows faster synthesis times and possibly clock rates for larger memory sizes.
- Renamed for simplicity and concistency with assembly program labels: INSTR_MEM->IROM; DATA_CONST_MEM->DROM; DATA_VAR_MEM->DRAM
- Updated files: Wrapperv2.v, RVv2.v, and ProgramCounterv2.v (necessary only if the Memory Configuration is changed in RARS).
*/

/*
V2:
To use FPGA block RAMs for instruction and data memories in pipelined version (Allows faster synthesis times and possibly clock rates for larger memory sizes):
(Disclaimer: Not tested fully), Uncomment line 225. Comment 231 to 233. Change 238, 248, 255, 273 to always@(posedge clk)
If enabled, Instr, ReadData_in are delayed by 1 cycle. Therefore, what you get can be used as InstrD, ReadDataW directly. MMIO reads are also delayed. 
The required byte/half-word will still have to be extracted from ReadDataW and zero/sign extended in W stage if using lb/lbu/lh/lhu.
*/

module Wrapper
#(
	parameter N_LEDs_OUT = 8,        // Number of LEDs displaying Result. LED(15 downto 15-N_LEDs_OUT+1). 8 by default
	parameter N_DIPs = 16,           // Number of DIPs. 16 by default
	parameter N_PBs  = 3             // Number of PushButtons. 3 by default
		                             // [2:0] -> BTNL, BTNC, BTNR. Note that BTNU is used as PAUSE and BTND is used as RESET
)
(
	input  [N_DIPs-1:0] DIP, 		 		// DIP switch inputs. Not debounced. Mapped to 0x00000C04. 
	                                        // Only the least significant 16 bits read from this location are valid. 
	input  [N_PBs-1:0] PB,  				// PB switch inputs. Not debounced.	Mapped to 0x00000C08. 
	                                        // Only the least significant 4 bits read from this location are valid. Order (3 downto 0) -> BTNU, BTNL, BTNR, BTND.
	output reg [N_LEDs_OUT-1:0] LED_OUT, 	// LED(15 downto 8) mapped to 0x00000C00. Only the least significant 8 bits written to this location are used.
	output [6:0] LED_PC, 					// LED(6 downto 0) showing PC(8 downto 2).
	output reg [31:0] SEVENSEGHEX, 			// 7 Seg LED Display. Mapped to 0x00000C18. The 32-bit value will appear as 8 Hex digits on the display.
	output reg [7:0] UART_TX,           	// CONSOLE (UART) Output. Mapped to 0x00000C0C. The least significant 8 bits written to this location are sent to PC via UART.
											// Check if CONSOLE_OUT_ready (0x00000C14) is set before writing to this location (especially if your CLK_DIV_BITS is small).
											// Consecutive STRs to this location not permitted (there should be at least 1 instruction gap between STRs to this location).
	input	UART_TX_ready,					// An indication to the wrapper/processor that it is ok to write to the CONSOLE_OUT (UART hardware).
	                                        // This bit should be set in the testbench to indicate that it is ok to write a new character to CONSOLE_OUT from your program.
	                                        // It can be read from the address 0x00000C14.
	output reg UART_TX_valid,           	// An indication to the UART hardware that the processor has written a new data byte to be transmitted.
	input  [7:0] UART_RX,                	// CONSOLE (UART) Input. Mapped to 0x00000C0C. The least significant 8 bits read from this location is the character received from PC via UART.
	                                        // Check if CONSOLE_IN_valid flag (0x00000C10) is set before reading from this location.
											// Consecutive LDRs from this location not permitted (needs at least 1 instruction spacing between LDRs).
											// Also, note that there is no Tx FIFO implemented. DO NOT send characters from PC at a rate faster than 
											// your processor (program) can read them. This means sending only 1 char every few seconds if your CLK_DIV_BITS is 26.
											// This is not a problem if your processor runs at a high speed.
	input  	UART_RX_valid,               	// An indication to the wrapper/processor that there is a new data byte waiting to be read from the UART hardware.
	                                        // This bit should be set in the testbench to indicate a new character (Else, the processor will only read in 0x00).
											// It can be read from the address 0x00000C10.
	output reg UART_RX_ack,              	// An indication to the UART hardware that the processor has read the newly received data byte.
	                                        // The testbench should clear CONSOLE_IN_valid when this is set.
	output reg OLED_Write,					// Indicates that the pixel is to be updated. This could happen when you change row or col or data depending on OLED_CTRL[3:0]
	output reg [6:0] OLED_Col,
	output reg [5:0] OLED_Row,
	output reg [23:0] OLED_Data,			// 24-bit pixel so as to see easily on the display. <5R, 6G, 8B>, each extended to 8 bits left aligned.
	input [31:0] ACCEL_Data,				// Packed <Temp, X, Y, Z> from MSB to LSB. X, Y, Z are in +/-2g range, 8-bit signed.
	input ACCEL_DReady,						// Accelerometer data ready signal. Mostly not necessary unless you are reading at a very high rate.
	input RESET,							// Active high. Implemented in TOP as not(CPU_RESET) or Internal_reset (CPU_RESET is red push button and is active low).
	input CLK								// Divided Clock from TOP.
);

// Set the base address according to your memory configuration in RARS. Set the size (Depth bits) appropriately as well.
//----------------------------------------------------------------
// V2: Sizes of various segments, base addresses, and peripheral address offsets.
//----------------------------------------------------------------
// Set the number of bits for the byte address. 
// Depth (size) = 2**DEPTH_BITS. e.g.,if DEPTH_BITS = 9, depth = 512 bytes = 128 words. 
// Make sure that the align directive in the assembly programme is set according to the sizes of the various segments.
// The size of a data segment affects the *next* segment alignment and address.
// Keep in mind that large memory sizes can cause synthesis times to be longer, esp if not using synch read (block RAM)

localparam IROM_DEPTH_BITS = 10; 
localparam DMEM_DEPTH_BITS = 10;	// combined DROM and DRAM into one in v3
localparam MMIO_DEPTH_BITS = 8;

// Base addresses of various segments
// The RARS default memory configuration is IROM_BASE = 32'h00400000 and DATA_MEM_BASE = 32'h10010000 in RARS.
// The RARS default MMIO base is 32'hFFFF0000, but this is hard to support. So we use MMIO_BASE = DRAM_BASE + 2**DRAM_DEPTH_BITS in all memory configurations
// We use compact memory configuration with .txt at 0 where IROM_BASE = 32'h00000000 and DATA_MEM_BASE = 32'h00002000, but you can change this to either of the other two if you wish.
// Do not use absolute addresses (e.g., using li pseudoinstruction for addresses) for memory/MMIO unless you know what you are doing. If you are building on the sample HelloWorld, use la for SEVENSEG.
//  Relative addresses (e.g., la pseudoinstruction) work fine for all starting addresses and segment sizes

localparam IROM_BASE = 32'h00000000;	/*  
                                         ! make sure this is the same as the .txt address based on the Memory Configuration set in the assembler/linker
										 ! and the PC default value as well as reset value in **ProgramCounter.v** 
										 */
localparam DMEM_BASE = 32'h00002000;	// ! make sure this is the same as the .data address based on the Memory Configuration set in the assembler/linker
localparam MMIO_BASE = DMEM_BASE + 2**DMEM_DEPTH_BITS;	// assuming MMIO is also in the .data segment

// Memory-mapped peripheral register offsets
localparam LED_OFF 		= 8'h00; //WO
localparam DIP_OFF 		= 8'h04; //RO
localparam PB_OFF  		= 8'h08; //RO
localparam UART_OFF 		= 8'h0C; //RW
localparam UART_RX_VALID_OFF 	= 8'h10; //RO, status bit
localparam UART_RX_READY_OFF 	= 8'h14; //RO, status bit
localparam SEVENSEG_OFF 	= 8'h18; //WO
localparam CYCLECOUNT_OFF 	= 8'h1C; //RO
localparam OLED_COL_OFF 	= 8'h20; //WO
localparam OLED_ROW_OFF 	= 8'h24; //WO
localparam OLED_DATA_OFF 	= 8'h28; //WO
localparam OLED_CTRL_OFF 	= 8'h2C; //WO 
localparam ACCEL_DATA_OFF 	= 8'h30; //RO
localparam ACCEL_DREADY_OFF 	= 8'h34; //RO, status bit
                                      
//----------------------------------------------------------------
// RV signals
//----------------------------------------------------------------
wire[31:0] PC ;
reg [31:0] Instr ;
reg[31:0] ReadData_in ;
wire MemRead ;
wire [3:0] MemWrite_out ;
wire[31:0] ALUResult ;
wire[31:0] WriteData_out ;

//----------------------------------------------------------------
// Address Decode signals
//---------------------------------------------------------------
// 'enable' signals from data memory address decoding
reg dec_DMEM, dec_LED, dec_DIP, dec_PB, dec_UART, dec_UART_RX_valid, dec_UART_TX_ready, dec_SEVENSEG, dec_CYCLECOUNT,
			dec_OLED_COL, dec_OLED_ROW, dec_OLED_DATA, dec_OLED_CTRL, dec_ACCEL_Data, dec_ACCEL_DReady;
wire dec_MMIO_read;	// any MMIO register is being read?
reg dec_DMEM_W = 1'b0, dec_MMIO_read_W = 1'b0;  // delayed versions of the decoded signals for output multiplexing
reg bad_MEM_addr;	// bad data memory address. Can be used as interrupt
wire MemWrite;		// overall MemWrite

//----------------------------------------------------------------
// Memory declaration
//-----------------------------------------------------------------
reg [31:0] IROM	[0:2**(IROM_DEPTH_BITS-2)-1];	// instruction memory aka IROM
reg [31:0] DMEM	[0:2**(DMEM_DEPTH_BITS-2)-1];	// data (constant) memory + data (variable) memory.

//----------------------------------------------------------------
// Memory initialisation
//----------------------------------------------------------------
initial begin
// Make sure that the .mem files (hexadecimal text memory dump from RARS - name it with .mem extension) are added to the project as 'Design Sources'. Alternatively, specify the full path.
// v3: Renamed the file to start with AA so that it is easier t find in the file open/save dialog box 
// If you checked "Copy sources into project", make sure that subsequent dumps from RARS are to projectName/projectName.srcs/sources_1/imports/orignalSourceFolderName 
	// IMP: "Relaunch Simulation" (top menu broken clock-wise button) may not be enough if you change your .mem file. Do SIMULATION > Run Simulation > Run Behavioural Simulation. 
	// In simulation, check the memory contents under test_Wrapper>dut (Wrapper)> IROM (and other memories) if unsure the correct contents are used.
// If you click Generate Bitstream after updating the .mem file, Vivado does not rerun synthesis using the new file, as it does not know that the file was modified externally. 
	// Rerun the synthesis and then bitstream generation though Vivado says it is up to date. 
	
$readmemh("IROM.mem", IROM);
$readmemh("DMEM.mem", DMEM);	// v3: Renamed DROM into DMEM
// AA_DMEM.mem will generate a warning of having more than necessary data as the assembler dumps the entire data segment including DMEM and MMIO,
	// This is ok as only the first part of it will be used to initialize DMEM.

end

//----------------------------------------------------------------
// Memory and Peripheral outputs to be multiplexed
//----------------------------------------------------------------
reg [31:0] ReadData_DMEM ;
reg [31:0] ReadData_MMIO ;

//----------------------------------------------------------------
// Data memory address decoding
//----------------------------------------------------------------
always@(*) begin
	dec_DMEM <= 1'b0;
	dec_LED <= 1'b0;
	dec_DIP <= 1'b0; 
	dec_PB <= 1'b0; 
	dec_UART <= 1'b0;
	dec_UART_RX_valid <= 1'b0; 
	dec_UART_TX_ready <= 1'b0; 
	dec_SEVENSEG <= 1'b0;
	dec_CYCLECOUNT <= 1'b0;
	dec_OLED_COL <= 1'b0;
	dec_OLED_ROW <= 1'b0;
	dec_OLED_DATA <= 1'b0;
	dec_OLED_CTRL <= 1'b0;
	dec_ACCEL_Data <= 1'b0;
	dec_ACCEL_DReady <= 1'b0;
	bad_MEM_addr <= 1'b0;
	
	if(ALUResult[31:DMEM_DEPTH_BITS] == DMEM_BASE[31:DMEM_DEPTH_BITS])
		dec_DMEM <= 1'b1;
	else if (ALUResult[31:MMIO_DEPTH_BITS] == MMIO_BASE[31:MMIO_DEPTH_BITS]) begin
		case (ALUResult[MMIO_DEPTH_BITS-1:2])
			LED_OFF[MMIO_DEPTH_BITS-1:2]: dec_LED <= 1'b1;
			DIP_OFF[MMIO_DEPTH_BITS-1:2]: dec_DIP <= 1'b1;
			PB_OFF[MMIO_DEPTH_BITS-1:2]: dec_PB <= 1'b1;
			UART_OFF[MMIO_DEPTH_BITS-1:2]: dec_UART <= 1'b1;
			UART_RX_VALID_OFF[MMIO_DEPTH_BITS-1:2]: dec_UART_RX_valid <= 1'b1;
			UART_RX_READY_OFF[MMIO_DEPTH_BITS-1:2]: dec_UART_TX_ready <= 1'b1;
			SEVENSEG_OFF[MMIO_DEPTH_BITS-1:2]: dec_SEVENSEG <= 1'b1;
			CYCLECOUNT_OFF[MMIO_DEPTH_BITS-1:2]: dec_CYCLECOUNT <= 1'b1;
			OLED_COL_OFF[MMIO_DEPTH_BITS-1:2]: dec_OLED_COL <= 1'b1;
			OLED_ROW_OFF[MMIO_DEPTH_BITS-1:2]: dec_OLED_ROW <= 1'b1;
			OLED_DATA_OFF[MMIO_DEPTH_BITS-1:2]: dec_OLED_DATA <= 1'b1;
			OLED_CTRL_OFF[MMIO_DEPTH_BITS-1:2]: dec_OLED_CTRL <= 1'b1;
			ACCEL_DATA_OFF[MMIO_DEPTH_BITS-1:2]: dec_ACCEL_Data <= 1'b1;
			ACCEL_DREADY_OFF[MMIO_DEPTH_BITS-1:2]: dec_ACCEL_DReady <= 1'b1;
			default: bad_MEM_addr <= 1'b1;
		endcase
	end
	else 
		bad_MEM_addr <= 1'b1;
end

assign dec_MMIO_read = MemRead || dec_DIP || dec_PB || dec_UART || dec_UART_RX_valid || dec_UART_TX_ready || dec_CYCLECOUNT || dec_ACCEL_Data || dec_ACCEL_DReady ;
assign MemWrite = MemWrite_out[3] || MemWrite_out[2] || MemWrite_out[1] || MemWrite_out[0];

//----------------------------------------------------------------
// Input (into RV) multiplexing
//----------------------------------------------------------------
always@(*) begin
if (dec_DMEM_W)
	ReadData_in <= ReadData_DMEM ; 
else 		// dec_MMIO_read_W
	ReadData_in <= ReadData_MMIO ;
end

//----------------------------------------------------------------
// DMEM write
//----------------------------------------------------------------
localparam NUM_COL = 4;
localparam COL_WIDTH = 8;
integer i;
always@(posedge CLK) begin
	if( MemWrite ) begin
		for(i=0;i<NUM_COL;i=i+1) begin
			if(MemWrite_out[i]) begin
				if( dec_DMEM ) begin
					DMEM[ALUResult[DMEM_DEPTH_BITS-1:2]][i*COL_WIDTH +: COL_WIDTH] <= WriteData_out[i*COL_WIDTH +: COL_WIDTH];
				end		      
			end
		end
	end
    // ReadData_DMEM <= DMEM[ALUResult[DMEM_DEPTH_BITS-1:2]] ; // Uncomment only if only using synch read for memory
end

//----------------------------------------------------------------
// Asych DMEM read - // Uncomment the following block (3 lines) if NOT using synch read for memory
//----------------------------------------------------------------
always@(*) begin 
    ReadData_DMEM <= DMEM[ALUResult[DMEM_DEPTH_BITS-1:2]] ; // async read
end

//----------------------------------------------------------------
// IROM read
//----------------------------------------------------------------
always@(*) begin // @posedge CLK only if using synch read for memory
    Instr = ( ( PC[31:IROM_DEPTH_BITS] == IROM_BASE[31:IROM_DEPTH_BITS]) && // To check if address is in the valid range
	     				(PC[1:0] == 2'b00) )? // and is word-aligned - we do not support instruction sizes other than 32.
                 IROM[PC[IROM_DEPTH_BITS-1:2]] : 32'h00000013 ; // If the address is invalid, the instruction fetched is NOP. 
                 						// This can be changed to trigger an exception instead if need be.
end

//----------------------------------------------------------------
// Cycle count read
//----------------------------------------------------------------
reg [31:0] cycle_count = 32'd0; // Max 42 seconds at 100 MHz clock
// extending this to generate interrupts at fixed intervals that are powers of two is very easy.
// extending this to generate interrupts at programmable intervals or intervals that are not powers of two is not difficult either. This will require another 
//  counter that reloads/resets itself with each interrupt. This reload/reset value can be made programmable by having an MMIO register for the purpose. 
always@(posedge CLK) begin
    if(RESET)
        cycle_count <= 0 ;
    else
        cycle_count <= cycle_count+1 ;
end

//----------------------------------------------------------------
// MMIO read
//----------------------------------------------------------------
always@(*) begin // @posedge CLK only if using synch read for memory
if (dec_DIP)
	ReadData_MMIO <= { {31-N_DIPs+1{1'b0}}, DIP } ; 
else if (dec_PB)
	ReadData_MMIO <= { {31-N_PBs+1{1'b0}}, PB } ; 
else if (dec_UART && UART_RX_valid)
	ReadData_MMIO <= {24'd0, UART_RX};
else if (dec_UART_RX_valid)
	ReadData_MMIO <= {31'd0, UART_RX_valid};	
else if (dec_UART_TX_ready)
	ReadData_MMIO <= {31'd0, UART_TX_ready};
else if (dec_CYCLECOUNT)
	ReadData_MMIO <= cycle_count;
else if (dec_ACCEL_Data)
	ReadData_MMIO <= ACCEL_Data;	
else	// dec_ACCEL_DReady // the default else to avoid the statement from being incomplete
	ReadData_MMIO <= {31'd0, ACCEL_DReady};
end

//----------------------------------------------------------------
// Delaying the decoded signals for multiplexing (delay only if using synch read for memory)
//----------------------------------------------------------------
always@(*) begin // @posedge CLK only if using synch read for memory
    dec_DMEM_W <= dec_DMEM;
    dec_MMIO_read_W <= dec_MMIO_read;
end

//----------------------------------------------------------------
// SevenSeg write
//----------------------------------------------------------------
integer j;
always@(posedge CLK) begin
	if( MemWrite ) begin
		for(j=0;j<NUM_COL;j=j+1) begin
			if(MemWrite_out[j]) begin
				if (RESET)
					SEVENSEGHEX <= 32'd0;
				else if (dec_SEVENSEG)
					SEVENSEGHEX[j*COL_WIDTH +: COL_WIDTH] <= WriteData_out[j*COL_WIDTH +: COL_WIDTH];		      
			end
		end
	end
end

//----------------------------------------------------------------
// Memory-mapped LED write
//----------------------------------------------------------------
always@(posedge CLK) begin
    if(RESET)
        LED_OUT <= 0 ;
    else if( MemWrite_out[0] && dec_LED ) 
        LED_OUT <= WriteData_out[N_LEDs_OUT-1 : 0] ;
end

//----------------------------------------------------------------
// Memory-mapped OLED write
//----------------------------------------------------------------
reg [7:0] OLED_ctrl_reg = 8'd0;// control register. 
// Lower nibble controlling whether the row or column or mode is varied. Upper nibble controlling the colour mode. 
// [3:0] - 0000: vary_pix_data_mode; 0001: vary_COL_mode (x); 0010: vary_ROW_mode (y)
// [7:4] - 0000: 8-bit colour mode; 0001: 16-bit colour mode; 0010: 24-bit colour mode
always@(posedge CLK) begin
	case (OLED_ctrl_reg[3:0]) // mapping OLED_Write direclty to TOP will write at the fast clock rate. Not an issue, but unnecessary writes
		4'b0001: OLED_Write <= MemWrite_out[0] && dec_OLED_COL;	//vary_COL_mode (x)
		4'b0010: OLED_Write <= MemWrite_out[0] && dec_OLED_ROW;  //vary_ROW_mode (y)
		default: OLED_Write <= MemWrite && dec_OLED_DATA; //vary_pix_data_mode
	endcase

	if( MemWrite_out[0] && dec_OLED_CTRL )
        OLED_ctrl_reg <= WriteData_out[7:0] ;
	if( MemWrite_out[0] && dec_OLED_ROW ) 
        OLED_Row <= WriteData_out[5:0] ;
	if( MemWrite_out[0] && dec_OLED_COL ) 
        OLED_Col <= WriteData_out[6:0] ; 
	case (OLED_ctrl_reg[7:4])
		4'b0001: 		// 16-bit colour mode 5R-6G-5B - can only be written as whole world or lower half-word.
			if( MemWrite_out[1] && MemWrite_out[0] && dec_OLED_DATA )
				OLED_Data <= { WriteData_out[15:11], 3'd0, WriteData_out[10:5], 2'd0, WriteData_out[4:0], 3'd0};
		4'b0010: 
			begin		// 24-bit colour mode -  byte, half-word, and whole word accessible
				if( MemWrite_out[2] && dec_OLED_DATA )
					OLED_Data[23:16] <= WriteData_out[23:16];  
				if( MemWrite_out[1] && dec_OLED_DATA )
					OLED_Data[15:8] <= WriteData_out[15:8];
				if( MemWrite_out[0] && dec_OLED_DATA )
					OLED_Data[7:0] <= WriteData_out[7:0];
			end
		default: 		// 8-bit colour mode 3R-3G-2B (1 byte) - LSB byte, lower half-word, and whole word accessible
			if( MemWrite_out[0] && dec_OLED_DATA )
				OLED_Data <= { WriteData_out[7:5], 5'd0, WriteData_out[4:2], 5'd0, WriteData_out[1:0], 6'd0}; 
	endcase        
end


//----------------------------------------------------------------
// UART read / write
//----------------------------------------------------------------
always @(posedge CLK) begin
	UART_TX_valid <= 1'b0;
	UART_RX_ack <= 1'b0;
	if (MemWrite_out[0] && dec_UART && UART_TX_ready)
	begin
		UART_TX <= WriteData_out[7:0];
		UART_TX_valid <= 1'b1;
	end
	if (MemRead && dec_UART && UART_RX_valid)
		UART_RX_ack <= 1'b1;
end

//----------------------------------------------------------------
// Debug LEDs
//----------------------------------------------------------------
assign LED_PC = PC[15-N_LEDs_OUT+1 : 2]; // debug showing PC

//----------------------------------------------------------------
// RV port map
//----------------------------------------------------------------
RV RV1(
	.CLK(CLK),
	.RESET(RESET),
	.Instr(Instr),
	.ReadData_in(ReadData_in),
	.MemRead(MemRead),
	.MemWrite_out(MemWrite_out),
	.ALUResult_out(ALUResult),
	.WriteData_out(WriteData_out),
	.PC(PC)
);

endmodule
