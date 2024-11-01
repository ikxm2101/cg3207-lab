`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Rajesh Panicker  
-- 
-- Create Date: 09/22/2020 06:49:10 PM
-- Module Name: CondLogic
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 / Basys 3
-- Tool Versions: Vivado 2019.2
-- Description: RISC-V Processor Conditional Logic Module
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

module PC_Logic(                    // This is a combinational module, unlike ARM. See the note below.
	input [1:0] PCS,	            // 00 for non-control, 01 for conditional branch, 10 for jal, 11 for jalr
	input [2:0] Funct3,	            // condition specified in the instruction (eq / ne / lt / ge / ltu / geu)
	input [2:0] ALUFlags, 	        // {eq, lt, ltu}
	output logic [1:0] PCSrc	    // will need to be expanded to 2 bits to support jalr
    );
    
    /* 
    	Important Note : ALUFlags are not *stored* in flag registers in RISC-V, unlike ARM and most other processors.
    	In RISC-V, the flags are produced and consumed in the same branch instruction. 
    	The effect of CMP R1, R2 and BEQ LABEL in ARM is beq x1, x2, LABEL in RISC-V.
    */
    
    
	// TODO: conditional logic goes here

    /*
     * Chapter 3B RISC-V Microarchitecture (Page 17)
    */

    /* PCS */
    localparam PCS_NON_CONTROL = 2'b00;
    localparam PCS_CONDITIONAL_BRANCH = 2'b01;
    localparam PCS_JAL = 2'b10;
    localparam PCS_JALR = 2'b11;

    /* CONDITIONAL_BRANCH Funct3 */
    localparam FUNCT3_BEQ = 3'b000;
    localparam FUNCT3_BNE = 3'b001;
    localparam FUNCT3_BLT = 3'b100;
    localparam FUNCT3_BGE = 3'b101;
    localparam FUNCT3_BLTU = 3'b110;
    localparam FUNCT3_BGEU = 3'b111;

	always_comb begin : PCSrcBlock
        case(PCS)
            PCS_NON_CONTROL: PCSrc = 2'b00;
            PCS_CONDITIONAL_BRANCH: begin
                case (Funct3)
                    FUNCT3_BEQ: PCSrc = {1'b0, ALUFlags[2]};
                    FUNCT3_BNE: PCSrc = {1'b0, ~ALUFlags[2]};
                    FUNCT3_BLT: PCSrc = {1'b0, ALUFlags[1]};
                    FUNCT3_BGE: PCSrc = {1'b0, ~ALUFlags[1]};
                    FUNCT3_BLTU: PCSrc ={1'b0,  ALUFlags[0]};
                    FUNCT3_BGEU: PCSrc ={1'b0,  ~ALUFlags[0]};
                    default: PCSrc = 2'bxx;
                endcase
            end
            PCS_JAL: PCSrc = 2'b01;
            PCS_JALR: PCSrc = 2'b11;
            default: PCSrc = 2'bxx;
        endcase
    end
	
endmodule
