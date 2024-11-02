`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Rajesh Panicker  
-- 
-- Create Date: 09/22/2020 06:49:10 PM
-- Module Name: ALU
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 / Basys 3
-- Tool Versions: Vivado 2019.2
-- Description: RISC-V Processor ALU Module
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

module ALU (
    input [31:0] Src_A,
    input [31:0] Src_B,
    input [3:0] ALUControl, // 0000 for add, 0001 for sub, 1110 for and, 1100 for or, 0010 for sll, 1010 for srl, 1011 for sra.
    output reg [31:0] ALUResult,
    output [2:0] ALUFlags // {eq, lt, ltu}
    );
    
    /* Shifter signals */
	wire [1:0] Sh;
	wire [4:0] Shamt5;
	wire [31:0] ShIn;
	wire [31:0] ShOut;
	
    /* Other signals */
    reg [32:0] Src_A_comp;
    reg [32:0] Src_B_comp;
    reg [32:0] C_0;
    wire [32:0] S_wider;
    wire N, Z, C, V; 	// optional intermediate values to derive eq, lt, ltu
			            // Hint: We need to care about V only for subtraction
	
    assign S_wider = Src_A_comp + Src_B_comp + C_0;
    
    /* ALU Control signals */
    localparam ADD = 4'b0000;
    localparam SUB = 4'b0001;
    localparam XOR = 4'b1000;
    localparam OR  = 4'b1100;
    localparam AND = 4'b1110;
    localparam SLL = 4'b0010;
    localparam SRL = 4'b1010;
    localparam SRA = 4'b1011;
    localparam SLT = 4'b0100;
    localparam SLTU = 4'b0110;

    always @(Src_A, Src_B, ALUControl, S_wider, ShOut) begin
        // default values: help avoid latches
        C_0 = 0 ; 
        Src_A_comp = {1'b0, Src_A};
        Src_B_comp = {1'b0, Src_B};
        ALUResult = Src_B ;
    
        case (ALUControl)
            ADD: ALUResult = S_wider[31:0];
            SUB: begin
                C_0[0] = 1 ;  
                Src_B_comp = {1'b0, ~ Src_B};
                ALUResult = S_wider[31:0];
            end
            AND: ALUResult = Src_A & Src_B;
            OR: ALUResult = Src_A | Src_B; 
            XOR: ALUResult = Src_A ^ Src_B;
            SLT: begin
                if (Src_A[31] != Src_B[31]) begin
                    ALUResult = (Src_A[31] == 1) ? 32'd1 : 32'd0;
                end else begin
                    if (Src_A[31] == 1) begin
                        ALUResult = (Src_A > Src_B) ? 32'd1 : 32'd0;
                    end else begin
                        ALUResult = (Src_A < Src_B) ? 32'd1 : 32'd0;
                    end
                end
            end
            SLTU: ALUResult = (Src_A < Src_B) ? 32'd1 : 32'd0;
            SLL: ALUResult = ShOut;
            SRL: ALUResult = ShOut;
            SRA: ALUResult = ShOut;	
            default: ALUResult = 32'bx;
        endcase
    end
      
    assign Z = (ALUResult == 0) ? 1 : 0 ;
    assign N = ALUResult[31];

    
    assign ALUFlags = {Z, 1'b0, 1'b0} ; // {eq, lt, ltu} - all except eq are placeholders. 
    					                // TODO : Will need to be modified in lab 3 to support blt, bltu, bge, bgeu.
    
    
    /* Sh signals used by Shifter module can be derived directly from the appropriate ALUControl bits
     * Shift operation | ALUControl[3:0] | Sh[1:0]
     * SLL | 0010 | 00 
     * SRL | 1010 | 10
     * SRA | 1011 | 11

     * Description:
        * rd = rs1 (<< / >>) rs2
        * rd = rs1 (<< / >>) rs2
    */
    assign Sh = {ALUControl[3], ALUControl[0]};
    assign ShIn = Src_A; // rs1 -> RD1 -> Src_A
    assign Shamt5 = Src_B[4:0];  // rs2 -> RD2 -> Src_B[4:0] (RV32I) 

	/* Instantiate Shifter */        
    Shifter IShifter_1 (
        .Sh(Sh),
        .Shamt5(Shamt5),
        .ShIn(ShIn),
        .ShOut(ShOut)
    );
     
endmodule
