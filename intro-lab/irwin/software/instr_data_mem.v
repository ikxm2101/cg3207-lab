module memory_initialization;
integer i;

// Instruction Memory Initialization
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

// Data Constant Memory Initialization
	DATA_CONST_MEM[0] = 32'h00000004;
	DATA_CONST_MEM[1] = 32'h65570a0d;
	DATA_CONST_MEM[2] = 32'h6d6f636c;
	DATA_CONST_MEM[3] = 32'h6f742065;
	DATA_CONST_MEM[4] = 32'h33474320;
	DATA_CONST_MEM[5] = 32'h2e373032;
	DATA_CONST_MEM[6] = 32'h000a0d2e;
	for (i = 7; i < 128; i = i + 1) begin
		DATA_CONST_MEM[i] = 32'h0;
	end
endmodule