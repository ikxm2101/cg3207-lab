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
    input [6:0] Opcode,
    input [2:0] Funct3,
    input [6:0] Funct7,
    output logic [1:0] PCS,		        // 00 for non-control, 01 for conditional branch, 10 for jal, 11 for jalr
    output logic RegWrite,		        // Asserted only by instructions which write to register file (load, auipc, lui, DPImm, DPReg);
    output logic MemWrite,		        // Asserted only by store (sw)
    output logic MemtoReg,		        // Asserted only by load (lw)
    output logic [1:0] ALUSrcA,         // Needed for lui, auipic. Refer to the microarchitecture for its use. Uncomment wire and port map in RV.v as well
    output logic ALUSrcB,		        // Asserted by all instructions which use an immediate (load, store, lui, auipc, DPImm). Needs to be expanded to a 2-bit signal to support link functionality for jal, jalr. Change wire width in RV.v as well
    output logic [2:0] ImmSrc, 	        // 000 for U, 010 for UJ, 011 for I, 110 for S, 111 for SB.
    output logic [3:0] ALUControl,	    // 0000 for add, 0001 for sub, 1110 for and, 1100 for or, 0010 for sll, 1010 for srl, 1011 for sra, 0001 for branch, 0000 for all others.
                                        // Note that the most significant 3 bits are Funct3 for all DP instrns. LSB is the same as Funct[5] for DPReg type and DPImm_shifts.
                                        // For other DPImms, Funct[5] is 0.
                                        // It is the same as sub for branches, and add for all others not mentioned in the line above.
    output logic MCycleStart,           // Asserted only by instructions which start a multi-cycle operation (eg. mul, divu)
    output logic MCycle_ResultSelect,   // Selection signal to choose between MCycle_Result1 and MCycle_Result2 depending on the operation
    output logic [1:0] MCycleOp         // Multi-cycle Operation. "00" for signed multiplication, "01" for unsigned multiplication, "10" for signed division, "11" for unsigned division.
    );
    // Change wire to reg if assigned inside a procedural (always) block. However, where it is easy enough, use assign instead of always.
    // A 2-1 multiplexing can be done easily using an assign with a ternary operator
    // For multiplexing with number of inputs > 2, a case construct within an always block is a natural fit. DO NOT to use nested ternary assignment operator as it hampers the readability of your code.
    
    // TODO: Implement Decoder here

    /*
	 * Chapter 3B RISC-V Microarchitecture (Page 19)
    */

	/* Opcode details
        * DP Reg	33 (0110011)
        * DP Imm	13 (0010011)
        * load	    03 (0000011)
        * store	    23 (0100011)
        * branch	63 (1100011)
        * jal	    6F (1101111)
        * auipc	    17 (0010111)
        * lui	    37 (0110111)
    */
    
    localparam OPCODE_DP_REG = 7'h33;
    localparam OPCODE_DP_IMM = 7'h13;
    localparam OPCODE_LOAD = 7'h03;
    localparam OPCODE_STORE = 7'h23;
    localparam OPCODE_BRANCH = 7'h63;
    localparam OPCODE_JAL = 7'h6F;
    localparam OPCODE_AUIPC = 7'h17;
    localparam OPCODE_LUI = 7'h37;
    
    /* Funct3 for mul and divu
        * mul       0x00 (000)
        * mulh      0x01 (001)
        * mulsu     0x02 (010)
        * mulu      0x03 (011)
        * div       0x04 (100)
        * divu      0x05 (101)
        * rem       0x06 (110)
        * remu      0x07 (111)
    */
    localparam FUNCT3_MUL = 3'h0;
    localparam FUNCT3_MULH = 3'h1;
    localparam FUNCT3_MULSU = 3'h2;
    localparam FUNCT3_MULU = 3'h3;
    localparam FUNCT3_DIV = 3'h4;
    localparam FUNCT3_DIVU = 3'h5;
    localparam FUNCT3_REM = 3'h6;
    localparam FUNCT3_REMU = 3'h7;

    /* Funct7 for DP Reg
        * Most base instructions    0x00 (0000000)
        * sub, sra                  0x20 (0100000)
        * M extension               0x01 (0000001)
    */

    localparam FUNCT7_M = 7'h01;

    assign MemtoReg = (Opcode == OPCODE_LOAD) ? 1'b1 : 1'b0; // Only set for load
    assign MemWrite = (Opcode == OPCODE_STORE) ? 1'b1 : 1'b0; // Only set for store

    assign RegWrite = (Opcode == OPCODE_STORE || Opcode == OPCODE_BRANCH || Opcode == OPCODE_JAL) ? 1'b0 : 1'b1; // Only set for DP Reg, DP Imm, load, auipc, lui

    always_comb begin : PCSBlock
        case (Opcode) 
            OPCODE_BRANCH: PCS = 2'b01; // branch instruction
            OPCODE_JAL: PCS = 2'b10; // jal instruction
            default: PCS = 2'b00; // non control instruction
        endcase
    end

    always_comb begin : ALUSrcABlock
        case (Opcode)
            OPCODE_AUIPC: ALUSrcA = 2'b11;
            OPCODE_LUI: ALUSrcA = 2'b01;
            default: ALUSrcA = 2'bx0;
        endcase
    end

    assign ALUSrcB = (Opcode == OPCODE_DP_REG || Opcode == OPCODE_BRANCH) ? 1'b0 : 1'b1;  // Only set for DP Imm, load, store, auipc, lui

    always_comb begin : ImmSrcBlock
        case (Opcode)
            OPCODE_DP_IMM, OPCODE_LOAD: ImmSrc = 3'b011;
            OPCODE_AUIPC, OPCODE_LUI: ImmSrc = 3'b000;
            OPCODE_STORE: ImmSrc = 3'b110;
            OPCODE_BRANCH: ImmSrc = 3'b111;
            OPCODE_JAL: ImmSrc = 3'b010;
            default: ImmSrc = 3'bxxx;
        endcase
    end

    always_comb begin : ALUControlBlock
        case (Opcode)
            OPCODE_BRANCH: ALUControl = 4'b0001;
            OPCODE_DP_REG: ALUControl = { Funct3, Funct7[5] };
            OPCODE_DP_IMM: ALUControl = { Funct3, (Funct3 == 3'h5) ? Funct7[5] : 1'b0 };
            default: ALUControl = 4'b0000;
        endcase
    end
    
    always_comb begin : MCycleStartBlock
        case (Funct7)
            FUNCT7_M: MCycleStart = 1'b1;
            default: MCycleStart = 1'b0;
        endcase
    end

    always_comb begin : MCycle_ResultSelectBlock
       /*
        * 0 for MCycle_Result1
        * 1 for MCycle_Result2
        */
        case ({ Funct3, Funct7 })
            { FUNCT3_MUL, FUNCT7_M }: MCycle_ResultSelect = 1'b0;
            { FUNCT3_MULH, FUNCT7_M }: MCycle_ResultSelect = 1'b1;
            { FUNCT3_MULSU, FUNCT7_M }: MCycle_ResultSelect = 1'bx; // not implemented
            { FUNCT3_MULU, FUNCT7_M }: MCycle_ResultSelect = 1'b1;
            { FUNCT3_DIV, FUNCT7_M }: MCycle_ResultSelect = 1'b0;
            { FUNCT3_DIVU, FUNCT7_M }: MCycle_ResultSelect = 1'b0;
            { FUNCT3_REM, FUNCT7_M }: MCycle_ResultSelect = 1'b1;
            { FUNCT3_REMU, FUNCT7_M }: MCycle_ResultSelect = 1'b1;
            default: MCycle_ResultSelect = 1'bx;
        endcase
    end

    always_comb begin : MCycleOpBlock
        case ({ Funct3, Funct7 })
        /*
         * Instruction  | MCycleOp[1:0]
         * multiply (S) | 00  
         * multiply (U) | 01
         * division (S) | 10
         * division (U) | 11
        */
        /*
          ! for mul:
          ! use the unsigned multiplication operation because it takes 
          ! less cycles to achieve the same result as signed multiplication
          ! in the current multiplier implementation in MCycle.v 
         */ 
            { FUNCT3_MUL, FUNCT7_M }: MCycleOp = 2'b01;
            { FUNCT3_MULH, FUNCT7_M }: MCycleOp = 2'b00;
            { FUNCT3_MULSU, FUNCT7_M }: MCycleOp = 2'bxx; // not implemented
            { FUNCT3_MULU, FUNCT7_M }: MCycleOp = 2'b01;
            { FUNCT3_DIV, FUNCT7_M }: MCycleOp = 2'b10;
            { FUNCT3_DIVU, FUNCT7_M }: MCycleOp = 2'b11;
            { FUNCT3_REM, FUNCT7_M }: MCycleOp = 2'b10;
            { FUNCT3_REMU, FUNCT7_M }: MCycleOp = 2'b11;
            default: MCycleOp = 2'bxx;
        endcase
    end
    
endmodule


