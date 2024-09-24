`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2024 18:19:06
// Design Name: 
// Module Name: get_mem
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


module get_mem(
    input clk,					// fundamental clock 100MHz
	input clk_enable,			// enable signal to read the next content
	output [31:0] data,			// 32 bits memory contents for 7-segments display
    output lower);      	    // 1-bit signal required for LEDs, indicating which half of the memory data is displaying on LEDs
								// lower = 1 to display upper half of the Memory data on LEDs
    
	// declare INSTR_MEM and DATA_CONST_MEM
	reg [31:0] INSTR_MEM [0:127];
	reg [31:0] DATA_CONST_MEM [0:127];

	// declare indics of INSTR_MEM and DATA_CONST_MEM
	reg [8:0] addr;
	reg [8:0] i, j;

    initial begin
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
    end

    // Instantiate 9-bit counter
    counter #(
        .COUNT_WIDTH(9)
    ) Icounter_9bit_0 (
        .*,
        .count(addr)
    );

    // determine lower by corresponding input
    assign lower = addr[0];

    // determine corresponding memory data that should be displayed on 7-segments
    wire [6:0] mem_index;
    assign mem_index = addr[7:1];
    wire mem_sel;
    assign mem_sel = addr[8];

    // determine memory index "addr" accordingly
    assign data = ~mem_sel ? INSTR_MEM[mem_index] : DATA_CONST_MEM[mem_index];
endmodule
