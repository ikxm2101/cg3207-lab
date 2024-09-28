`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// This module should contain the corresponding Memory data generated from Hex2ROM
// and choose the memory data to be displayed based on enable signal  
// Fill in the blank to complete this module 
// (c) Gu Jing, ECE, NUS
//////////////////////////////////////////////////////////////////////////////////


module Get_MEM(
    input clk,					// fundamental clock 100MHz
	input enable,				// enable signal to read the next content
	output [31:0] data,			// 32 bits memory contents for 7-segments display
    output upper_lower);      	// 1-bit signal rerequied for LEDs, indicating which half of the Memory data is displaying on LEDs
								// upper_lower = 1 to display upper half of the Memory data on LEDs
    
// declare INSTR_MEM and DATA_CONST_MEM
reg [31:0] INSTR_MEM [0:127];
reg [31:0] DATA_CONST_MEM [0:127];

// declare indics of INSTR_MEM and DATA_CONST_MEM
reg [7:0] addr;
reg [8:0] i, j;

initial
begin
	////////////////////////////////////////////////////////////////
    // Instruction Memory
    ////////////////////////////////////////////////////////////////
	INSTR_MEM[0] = 32'h00002497;
	INSTR_MEM[1] = 32'h40048493;
	INSTR_MEM[2] = 32'h00002937;
	INSTR_MEM[3] = 32'h40490913;
	INSTR_MEM[4] = 32'h00002997;
	INSTR_MEM[5] = 32'hff09a983;
	INSTR_MEM[6] = 32'h00092a03;
	INSTR_MEM[7] = 32'h0144a023;
	INSTR_MEM[8] = 32'hfff98993;
	INSTR_MEM[9] = 32'hfe0986e3;
	INSTR_MEM[10] = 32'hff9ff06f;
	INSTR_MEM[11] = 32'h000000ef;
	for (i = 12; i < 128; i = i + 1) begin
		INSTR_MEM[i] = 32'h0;
	end
	
	////////////////////////////////////////////////////////////////
    // Data (Constant) Memory
    ////////////////////////////////////////////////////////////////	

	DATA_CONST_MEM[0] = 32'h00000004;
	DATA_CONST_MEM[1] = 32'h65570a0d;
	DATA_CONST_MEM[2] = 32'h6d6f636c;
	DATA_CONST_MEM[3] = 32'h6f742065;
	DATA_CONST_MEM[4] = 32'h33474320;
	DATA_CONST_MEM[5] = 32'h2e373032;
	DATA_CONST_MEM[6] = 32'h000a0d2e;
	for (j = 7; j < 128; j = j + 1) begin
		DATA_CONST_MEM[j] = 32'h0;
	end
	
	// Initial address
	addr <= 8'b0; // set 8 bit counter to 0 (how to deicde blocking or non blocking?)
	              // = is blocking, <= non blocking

end

// determine upper_lower by corresponding input 
    // not needed as not using LED
    // assign upper_lower = addr[0]; //assign will update LHS when RHS changes
    
// determine corresponding memory data that should be displayed on 7-segments (using Bit 7)
// if Bit 7 is on, show DATA as we show INST before showing data
// Bit 6 to 0 is address to the ROM
    assign data = (addr[7]) ? DATA_CONST_MEM[addr[6:0]] : INSTR_MEM[addr[6:0]];

// determine memory index "addr" accordingly
always @(posedge clk) // Note : Do NOT replace clk with enable. If you do so, enable is no longer an enable but a clock, and then you are using a clock divider (entire circuit doesnt run on the same clock).
			// Please see towards the end of Lab 1 manual for more info/hints on how to use enable
begin
    if (enable)
    begin
        addr <= (addr == 8'hff) ? 8'b0 : (addr + 1);
    end
end
	
endmodule
