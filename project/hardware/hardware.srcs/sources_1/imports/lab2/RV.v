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
    input [31:0] ReadData_in,       // v2: Renamed to support lb/lbu/lh/lhu
    output MemRead,
    output [3:0] MemWrite_out,		// v2: Changed to column-wise write enable to support sb/sw. Each column is a byte.
    output [31:0] PC,
    output [31:0] ALUResult,
    output [31:0] WriteData_out		// v2: Renamed to support sb/sw
    );
    
    // v2: Important info regarding alignment
    // CAUTION: Unaligned data reads and writes are NOT supported. 
    // If the instruction is lh/lhu/sh (load/store halfword), the data memory address should be divisble by 2 (the last bit should be 0)
    // If the instruction is lw/sw, the data memory address should be divisible by 4 (the last two bits should be 0s)
    
    // Lab 4 potential enhancement: Unaligned requests can be detected and used to generate interrupts by editing the wrapper.
    // This interrupt could be used to do a software emulation of unaligned access via aligned access.
    
    // ReadData_in is the whole word that contains the word/half-word/byte you want. 
    //  You need to extract out what you want, with sign/zero(u) extension as required by the instruction.
    //  For example, when running lbu (load byte unsigned) instruction, if the last 2 bits of the address is 2'b01, and the address location has 8'hAB, 
    //      ReadData_in is 32'hxxxxABxx.ReadData, the word to be written into the destination register is 32'h000000AB (0s as MSBs as it is lbu. 
    //      Else,ReadData_in[15] should be replicated to the 24 MSBs. You have to do this conversion.
    // >> give an example here
    // WriteData_out is a word, with word/byte/half-word aligned to where you wish to write it to within the word.
    //  The MemWrite_out bits of every byte to be modified should be 1.
    //  For example,when running sb (store byte) instruction, if the last 2 bits of the address is 2'b10 and the byte to be written is 8'hAB (or 32'b000000AB),
    //      WriteData_out should be 32'hxxABxxxx and MemWrite_out should be 4'h0100.You have to do this conversion.
    //  Another example: when running sh (store halfword), if the last 2 bits of the address is 2'b10 and the half-word to be written is 16'hABCD (or 32'h0000ABCD),
    //      WriteData_out should be 32'hABCDxxxx and MemWrite_out should be 4'h1100.You have to do this conversion.
        
    /* RV Signals */
    // v2: <Added to support lb/lbu/lh/lhu/sb/sh>
    wire [2:0] SizeSel;
    wire [31:0] ReadData;
    wire [31:0] WriteData;
    wire MemWrite;
    // v2: </Added to support lb/lbu/lh/lhu/sb/sh>

    // The signals that are commented out (except CLK) will need to be uncommented and attached a stage suffix for pipelining,
    //  except if the connection is within the same stage.

    /* RegFile signals */
    //wire CLK ;
    wire WE ;
    wire [4:0] rs1 ;
    wire [4:0] rs2 ;
    wire [4:0] rd ;
    wire [31:0] WD ;
    wire [31:0] R15 ;
    wire [31:0] RD1 ;
    wire [31:0] RD2 ;
    
    /* Extend module signals */
    wire [2:0] ImmSrc ;
    wire [24:0] InstrImm ;
    wire [31:0] ExtImm ;
    
    /* Decoder signals */
    wire [6:0] Opcode ;
    wire [2:0] Funct3 ;
    wire [6:0] Funct7 ;
    wire [1:0] PCS ;
    wire RegWrite ;
    // wire MemWrite ;
    wire MemtoReg ;
    wire [1:0] ALUSrcA ;
    wire ALUSrcB ;
    // wire [2:0] ImmSrc ;
    wire [3:0] ALUControl ;
    
    /* PC_Logic signals */
    // wire [1:0] PCS
    // wire [2:0] Funct3;
    // wire [2:0] ALUFlags;
    wire PCSrc;
      
    /* ALU signals */
    wire [31:0] Src_A ;
    wire [31:0] Src_B ;
    // wire [3:0] ALUControl ;
    // wire [31:0] ALUResult ;
    wire [2:0] ALUFlags ;
    
    /* MCycle signals */
    // wire CLK ;
    // wire RESET ;
    wire MCycleStart ;
    wire [1:0] MCycleOp ;
    // wire [31:0] Operand1 ;
    // wire [31:0] Operand2 ; 
    wire [31:0] MCycle_Result1 ;
    wire [31:0] MCycle_Result2 ;
    wire Busy ;

    /* ProgramCounter signals */
    // wire CLK ;
    // wire RESET ;
    wire PC_WE ;    
    wire [31:0] PC_IN ;
    // wire [31:0] PC ; 
    
    /* Other internal signals */
    wire [31:0] PC_Offset ;
    wire [31:0] Result ;

    assign MemRead = MemtoReg; // This is needed for the proper functionality of some devices such as UART CONSOLE
    assign PC_WE = Busy ? 1'b0 : 1'b1; // Will need to control it for multi-cycle operations (Multiplication, Division) and/or Pipelining with hazard hardware.
    
    // v2: <Added to support lb/lbu/lh/lhu/sb/sh>
    assign ReadData = ReadData_in;       // Change datapath as appropriate if supporting lb/lbu/lh/lhu
    assign WriteData_out = WriteData;    // Change datapath as appropriate if supporting sb/sh
    assign MemWrite_out = {4{MemWrite}}; // Change datapath as appropriate if supporting sb/sh
    assign SizeSel = 3'b010;             // Change this to be generated by the Decoder (control) as appropriate if 
                                         // supporting lb/sb/lbu/lh/sh/lhu/lw/sw. Hint: funct3
    // v2: </Added to support lb/lbu/lh/lhu/sb/sh>

    // TODO: other datapath connections here
    /* Program counter input */
    assign PC_IN = (PCSrc == 1'b0) ? (PC + 4) : (PC + ExtImm);

    /* ALU and MCycle inputs */
    assign Src_A = (ALUSrcA[0] == 1'b0) ? RD1 : 
                    (ALUSrcA[1] == 1'b0) ? 1'b0 : PC; // MCycle Operand1
    assign Src_B = (ALUSrcB == 1'b1) ? ExtImm : RD2; // MCycle Operand2

    /* Data memory write data */
	assign WriteData = RD2;

    /* Register write enable and write data */
	assign WE = RegWrite;
	assign WD = Result;

    /* Datapath result 
     * ALUResult: result from ALU block (add, sub, and, or, sll, srl, sra)
     * MCycle_Result1: MCycle block (mul: LSW, div: Quotient)
     * MCycle_Result2: MCycle block (mul: MSW, div: Remainder)
    */ 
    assign Result = (MemtoReg == 1'b0) ? // check if its a load instruction     
                    (MCycleStart ? // check if its a multi-cycle instruction
                    (MCycle_ResultSelect ? MCycle_Result2 : MCycle_Result1) // select MCycle_Result based on the instruction
                    : ALUResult)
                    : ReadData; 

    /* Instruction from instruction memory */
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
        .ALUControl(ALUControl),
        .MCycleStart(MCycleStart),
        .MCycle_ResultSelect(MCycle_ResultSelect),
        .MCycleOp(MCycleOp)
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
    
    /* Instantiate MCycle for multi-cycle operations */
    MCycle IMCycle_1 (
        .CLK(CLK),
        .RESET(RESET),
        .Start(MCycleStart),
        .MCycleOp(MCycleOp),
        .Operand1(Src_A),
        .Operand2(Src_B),
        .MCycle_Result1(MCycle_Result1),
        .MCycle_Result2(MCycle_Result2),
        .Busy(Busy)
    );

    /* Instantiate ProgramCounter */    
    ProgramCounter IProgramCounter_1 (
        .CLK(CLK),
        .RESET(RESET),
        .PC_WE(PC_WE),    
        .PC_IN(PC_IN),
        .PC(PC)  
    );     

endmodule








