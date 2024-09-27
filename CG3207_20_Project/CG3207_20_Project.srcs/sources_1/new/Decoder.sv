`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Rajesh Panicker  
-- 
-- Create Date: 09/22/2020 06:49:10 PM
-- Module Name: Decoder
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 / Basys 3
-- Tool Versions: Vivado 2019.2
-- Description: RISC-V Processor Decoder Module
-- 
-- Dependencies: NIL
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Interface and implementation can be modified.
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

module Decoder(
    input [6:0] Opcode ,
    input [2:0] Funct3 ,
    input [6:0] Funct7 ,
    output logic [1:0] PCS,		// 00 for non-control, 01 for conditional branch, 10 for jal, 11 for jalr
    output logic RegWrite,		// Asserted only by instructions which write to register file (load, auipc, lui, DPImm, DPReg);
    output logic MemWrite,		// Asserted only by store (sw)
    output logic MemtoReg,		// Asserted only by load (lw)
    output logic [1:0] ALUSrcA, 	// Needed for lui, auipic. Refer to the microarchitecture for its use. Uncomment wire and port map in RV.v as well
    output logic [1:0] ALUSrcB,		// Asserted by all instructions which use an immediate (load, store, lui, auipc, DPImm). Needs to be expanded to a 2-bit signal to support link functionality for jal, jalr. Change wire width in RV.v as well
    output logic [2:0] ImmSrc, 	// 000 for U, 010 for UJ, 011 for I, 110 for S, 111 for SB.
    output logic [3:0] ALUControl	// 0000 for add, 0001 for sub, 1110 for and, 1100 for or, 0010 for sll, 1010 for srl, 1011 for sra, 0001 for branch, 0000 for all others.
    					// Note that the most significant 3 bits are Funct3 for all DP instrns. LSB is the same as Funct[5] for DPReg type and DPImm_shifts. For other DPImms, Funct[5] is 0.
    					// It is the same as sub for branches, and add for all others not mentioned in the line above.
    ); 
// Change wire to reg if assigned inside a procedural (always) block. However, where it is easy enough, use assign instead of always.
// A 2-1 multiplexing can be done easily using an assign with a ternary operator
// For multiplexing with number of inputs > 2, a case construct within an always block is a natural fit. DO NOT to use nested ternary assignment operator as it hampers the readability of your code.
    
    	// todo: Implement Decoder here
	
	/* Opcode details
        DP Reg	33 (0110011).
        DP Imm	13 (0010011).
        Load	03 (0000011).
        Store	23 (0100011)
        Branch	63 (1100011)
        jal	    6F (1101111)
        auipc	17 (0010111).
        lui	    37 (0110111).
    */

    assign MemtoReg = (Opcode == 7'h03) ? 1'b1 : 1'b0; // Only for Load
    assign RegWrite = (Opcode == 7'h23 || Opcode == 7'h63 || Opcode == 7'h6F) ? 1'b0 : 1'b1;
    assign MemWrite = (Opcode == 7'h23) ? 1'b1 : 1'b0; // Only for Store
    assign ALUSrcB[0] = (Opcode == 7'h33 || Opcode == 7'h63) ? 1'b0 : 1'b1;
    assign ALUSrcB[1] = (Opcode == 7'h6F || Opcode == 7'h67) ? 1'b0 : 1'b1;

    always_comb begin : PCSBlock
        case (Opcode) 
            7'h63: PCS = 2'b01; // Branch Instruction
            7'h6F: PCS = 2'b10; // jal Instruction
            default: PCS = 2'b00; // Non control instruction
        endcase
    end

    always_comb begin : ALUSrcABlock
        case (Opcode)
            7'h17: ALUSrcA = 2'b11;
            7'h37: ALUSrcA = 2'b01;
            default: ALUSrcA = 2'bx0;
        endcase
    end
    
    always_comb begin : ImmSrcBlock
        case (Opcode)
            7'h13 || 7'h03: ImmSrc = 3'b011;
            7'h17 || 7'h37: ImmSrc = 3'b000;
            7'h23: ImmSrc = 3'b110;
            7'h63: ImmSrc = 3'b111;
            7'h6F: ImmSrc = 3'b010;
            default: ImmSrc = 3'bxxx;
        endcase
    end

    always_comb begin : ALUControlBlock
        case (Opcode)
            7'h63: ALUControl = 4'b0001;
            7'h33: ALUControl = {Funct3, Funct7[5]};
            7'h13: ALUControl = {Funct3, (Funct3 == 3'h5) ? Funct7[5] : 1'b0 };
            default: ALUControl = 3'b0000;
        endcase
    end

endmodule



