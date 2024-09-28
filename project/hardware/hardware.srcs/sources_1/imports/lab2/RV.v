`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Rajesh Panicker  
-- 
-- Create Date: 09/22/2020 06:49:10 PM
-- Module Name: RV
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 / Basys 3
-- Tool Versions: Vivado 2019.2
-- Description: RISC-V Processor Module
-- 
-- Dependencies: NIL
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: The interface SHOULD NOT be modified unless you modify Wrapper.v/vhd too. The implementation can be modified
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

//-- Save waveform file and add it to the project
//-- Reset and launch simulation if you add interal signals to the waveform window

// Change wire to reg if assigned inside a procedural (always) block. However, where it is easy enough, use assign instead of always.
// A 2-1 multiplexing can be done easily using an assign with a ternary operator
// For multiplexing with number of inputs > 2, a case construct within an always block is a natural fit. DO NOT to use nested ternary assignment operator as it hampers the readability of your code.

module RV(
    input CLK,
    input RESET,
    //input Interrupt,  // for optional future use
    input [31:0] Instr,
    input [31:0] ReadData,
    output MemRead,
    output MemWrite,
    output [31:0] PC,
    output [31:0] ALUResult,
    output [31:0] WriteData
    );
    
    // RegFile signals
    //wire CLK ;
    wire WE ;
    wire [4:0] rs1 ;
    wire [4:0] rs2 ;
    wire [4:0] rd ;
    wire [31:0] WD ;
    wire [31:0] R15 ;
    wire [31:0] RD1 ;
    wire [31:0] RD2 ;
    
    // Extend Module signals
    wire [2:0] ImmSrc ;
    wire [24:0] InstrImm ;
    wire [31:0] ExtImm ;
    
    // Decoder signals
    wire [6:0] Opcode ;
    wire [2:0] Funct3 ;
    wire [6:0] Funct7 ;
    wire [1:0] PCS ;
    wire RegWrite ;
    //wire MemWrite ;
    wire MemtoReg ;
    wire [1:0] ALUSrcA ;
    wire ALUSrcB ;
    //wire [2:0] ImmSrc ;
    wire [3:0] ALUControl ;
    
    // PC_Logic signals
    //wire [1:0] PCS
    //wire [2:0] Funct3;
    //wire [2:0] ALUFlags;
    wire PCSrc;
      
    // ALU signals
    wire [31:0] Src_A ;
    wire [31:0] Src_B ;
    //wire [3:0] ALUControl ;
    //wire [31:0] ALUResult ;
    wire [2:0] ALUFlags ;
    
    // ProgramCounter signals
    //wire CLK ;
    //wire RESET ;
    wire WE_PC ;    
    wire [31:0] PC_IN ;
    //wire [31:0] PC ; 
        
    // Other internal signals here
    wire [31:0] PC_Offset ;
    wire [31:0] Result ;
    
    
    assign MemRead = MemtoReg; // This is needed for the proper functionality of some devices such as UART CONSOLE
    assign WE_PC = 1 ; // Will need to control it for multi-cycle operations (Multiplication, Division) and/or Pipelining with hazard hardware.
    // todo: other datapath connections here

    assign Src_A = (ALUSrcA[0] == 1'b0) ? RD1 : 
                    (ALUSrcA[1] == 1'b0) ? 1'b0 : PC;
    assign Src_B = (ALUSrcB == 1'b1) ? ExtImm : RD2;

    assign Result = (MemtoReg == 1'b0) ? ALUResult : ReadData;
    assign PC_IN = PC + (PCSrc == 1'b0) ? 4 : ExtImm;
	assign WriteData = RD2;
	assign WE = RegWrite;
	assign WD = Result;
	
	assign rs1 = Instr[19:15];
	assign rs2 = Instr[24:20];
	assign rd = Instr[11:7];
	assign InstrImm = Instr[31:7];
	assign Funct3 = Instr[14:12];
	assign Funct7 = Instr[31:25];
	assign Opcode = Instr[6:0];
    /* Instantiate RegFile */
    RegFile IRegFile_1 ( 
        .CLK(CLK),
        .WE(WE),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .WD(WD),
        .RD1(RD1),
        .RD2(RD2)
    );
                
     /* Instantiate Extend module */
    Extend IExtend_1 (
        .ImmSrc(ImmSrc),
        .InstrImm(InstrImm),
        .ExtImm(ExtImm)
    );
                
    /* Instantiate Decoder */
    Decoder IDecoder_1 (
        .Opcode(Opcode),
        .Funct3(Funct3),
        .Funct7(Funct7),
        .PCS(PCS),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControl)
    );
                
    /* Instantiate PC_Logic */
	PC_Logic IPC_Logic_1 (
        .PCS(PCS),
        .Funct3(Funct3),
        .ALUFlags(ALUFlags),
        .PCSrc(PCSrc)
	);
                
    /* Instantiate ALU */        
    ALU IALU_1 (
        .Src_A(Src_A),
        .Src_B(Src_B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .ALUFlags(ALUFlags)
    );                
    
    /* Instantiate ProgramCounter */    
    ProgramCounter IProgramCounter_1 (
        .CLK(CLK),
        .RESET(RESET),
        .WE_PC(WE_PC),    
        .PC_IN(PC_IN),
        .PC(PC)  
    );     

endmodule








