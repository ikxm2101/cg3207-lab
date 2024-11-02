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
    // input Interrupt,  // for optional future use
    input [31:0] Instr,

    /* Outputs from Data Memory
     * ReadData_in -> ReadData_M 
    */
    input [31:0] ReadData_in,       // v2: Renamed to support lb/lbu/lh/lhu

    /* Needed for proper functionality of some peripherals
     * MemtoReg_M -> MemRead
    */
    output MemRead,

    /* Inputs for Data Memory
     * MemWrite_M -> MemWrite_out
     * ALUResult_M -> A
     * WriteData_M -> WriteData_out -> WD
    */
    output [3:0] MemWrite_out,		// v2: Changed to column-wise write enable to support sb/sw. Each column is a byte.
    output [31:0] ALUResult_out,
    output [31:0] WriteData_out, // v2: Renamed to support sb/sw

    output [31:0] PC
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
        

    // The signals that are commented out (except CLK) will need to be uncommented and attached a stage suffix for pipelining, except if the connection is within the same stage.
    
    /*************************************************************************
                            START OF REGISTER DECLARATION
    *************************************************************************/

    /*****************************************
     * F stage register (PC) Signals 
     *****************************************/
    // Inputs
    wire PC_WE ;
    wire [31:0] PC_IN ;
    
    // Outputs
    wire [31:0] PC_F; // ProgramCounter module already implements it as a reg

    /* ProgramCounter signals */
    // wire CLK ;
    // wire RESET ;
    wire [31:0] PC_Offset ;

    /*****************************************
     * D Stage Register Signals 
     *****************************************/
    // Inputs
    wire [31:0] Instr_F;

    // Outputs
    reg [31:0] Instr_D = 32'h0;
    reg [31:0] PC_D = 32'h0;

    /* Decoder signals */
    wire [2:0] Funct3_D ;
    wire [6:0] Opcode ;
    wire [6:0] Funct7 ;
    wire [1:0] PCS_D ;
    wire RegWrite_D ;
    wire MemtoReg_D ;
    wire MemWrite_D ;
    wire [3:0] ALUControl_D ;
    wire [1:0] ALUSrcA_D ;
    wire [1:0] ALUSrcB_D ;
    // wire [2:0] ImmSrc ;
    wire MCycleStart_D;
    wire MCycle_ResultSelect_D;
    wire [1:0] MCycleOp_D;

    /* RegFile signals */
    // wire CLK ;
    wire RegFile_WE ;
    wire [4:0] rs1_D ;
    wire [4:0] rs2_D ;
    reg [4:0] rd_W = 5'h0;
    wire [31:0] RegFile_WD ;
    wire [31:0] RD1_D ;
    wire [31:0] RD2_D ;
    
    /* Extend module signals */
    wire [2:0] ImmSrc ;
    wire [24:0] InstrImm ;
    wire [31:0] ExtImm_D ;
    
    /*****************************************
     * E Stage Register Signals 
     *****************************************/
    // Inputs
    // wire [2:0] Funct3_D;
    // wire [1:0] PCS_D;
    // wire RegWrite_D;
    // wire MemtoReg_D;
    // wire MemWrite_D;
    // wire [3:0] ALUControl_D;
    // wire [1:0] ALUSrcA_D;
    // wire [1:0] ALUSrcB_D;
    // wire MCycleStart_D;
    // wire MCycle_ResultSelect_D;
    // wire [1:0] MCycleOp_D;
    // wire [31:0] RD1_D;
    // wire [31:0] RD2_D;
    // wire [31:0] ExtImm_D;
    wire [4:0] rd_D;
    // reg [31:0] PC_D = 32'h0;
    // wire [4:0] rs1_D;
    // wire [4:0] rs2_D;

    // Outputs
    reg [2:0] Funct3_E = 3'h0;
    reg [1:0] PCS_E = 2'h0;
    reg RegWrite_E = 1'h0;
    reg MemtoReg_E = 1'h0;
    reg MemWrite_E = 1'h0;
    reg [3:0] ALUControl_E = 4'h0;
    reg [1:0] ALUSrcA_E = 2'h0;
    reg [1:0] ALUSrcB_E = 2'h0;
    reg MCycleStart_E = 1'h0;
    reg MCycle_ResultSelect_E = 1'h0;
    reg [1:0] MCycleOp_E = 2'h0;
    reg [31:0] RD1_E = 32'h0;
    reg [31:0] RD2_E = 32'h0;
    reg [31:0] ExtImm_E = 32'h0;
    reg [4:0] rd_E = 5'h0;
    reg [31:0] PC_E = 32'h0;
    reg [4:0] rs1_E = 5'h0;
    reg [4:0] rs2_E = 5'h0;

    /* PC_Logic signals */
    // wire [1:0] PCS_E
    // wire [2:0] Funct3_E;
    // wire [2:0] ALUFlags;
    wire [1:0] PCSrc_E;
      
    /* ALU signals */
    wire [31:0] Src_A ;
    wire [31:0] Src_B ;
    // reg [3:0] ALUControl_E = 4'h0 ;
    wire [31:0] ALUResult ;
    wire [2:0] ALUFlags ;
    
    /* MCycle signals */
    // wire CLK ;
    // wire RESET ;
    // wire MCycleStart_E ;
    // reg [1:0] MCycleOp_E = 2'h0 ;
    wire [31:0] MCycle_Operand1 ;
    wire [31:0] MCycle_Operand2 ; 
    wire [31:0] MCycle_Result1 ;
    wire [31:0] MCycle_Result2 ;
    wire MCycle_Busy ;

    /*****************************************
     * M Stage Register Signals 
     *****************************************/
    // Inputs
    // wire RegWrite_E;
    // wire MemtoReg_E;
    // wire MemWrite_E;
    wire [31:0] ALUResult_E;
    wire [31:0] WriteData_E;
    // wire [4:0] rd_E;

    // Outputs
    reg RegWrite_M = 1'h0;
    reg MemtoReg_M = 1'h0;
    reg MemWrite_M = 1'h0;
    reg [31:0] ALUResult_M = 32'h0;
    reg [31:0] WriteData_M = 32'h0;
    reg [4:0] rd_M = 5'h0;
    reg [4:0] rs2_M = 5'h0;

    /* Signals in M Stage */
    // v2: <Added to support lb/lbu/lh/lhu/sb/sh>
    wire [2:0] SizeSel;
    // reg MemWrite_M = 1'h0;
    // reg [31:0] ALUResult_M = 32'h0;
    // reg [31:0] WriteData_M = 32'h0;
    wire [31:0] ReadData_M;


    /*****************************************
     * W Stage Register Signals 
     *****************************************/
    // Inputs
    // reg RegWrite_M = 1'h0;
    // reg MemtoReg_M = 1'h0;
    // wire [31:0] ReadData_M;
    // reg [31:0] ALUResult_M = 32'h0;
    // reg [4:0] rd_M = 5'h0;
    
    // Outputs
    reg RegWrite_W = 1'h0;
    reg MemtoReg_W = 1'h0;
    reg [31:0] ReadData_W = 32'h0;
    reg [31:0] ALUResult_W = 32'h0;
    // reg [4:0] rd_W = 5'h0;

    // Other signals in Writeback stage
    wire [31:0] Result_W;

    /*****************************************
     * Hazard Unit
     *****************************************/ 
    wire [1:0] ForwardAE;
    wire [1:0] ForwardBE;
    wire ForwardM;
    wire StallF;
    wire StallD;
    wire FlushE;
    wire [31:0] RD1_E_Choose;
    wire [31:0] RD2_E_Choose;
    wire [31:0] WriteData_M_Choose;


    /*************************************************************************
                            END OF REGISTER DECLARATION
    *************************************************************************/

    /*************************************************************************
                        START OF STAGE DATAPATH CONNECTION
    *************************************************************************/

    /*****************************************
     * Fetch Pipeline Register (or PC register)
     *****************************************/
    assign Instr_F = Instr; // Get instruction from Wrapper module

    /* Instantiate ProgramCounter */    
    ProgramCounter IProgramCounter_1 (
        .CLK(CLK),
        .RESET(RESET),
        .PC_WE(PC_WE),    
        .PC_IN(PC_IN),
        .PC(PC_F)  
    );

    /*****************************************
     * Fetch Stage Datapath 
     *****************************************/
    /* 
     * Program counter input 
     * PCSrc[0]:
        * controls offset for PC+ : ExtImm(1) or 4(0)
        * controls while pipeline stage info comes from : E(1) or F(0) 
     * PCSrc[1] selects base for PC+ : RD1(1) or PC(0)
    */
    wire [31:0] PC_Base;
    
    assign PC_IN = PC_Offset + PC_Base;
    assign PC_Offset = (PCSrc_E[0] == 1'b0) ? 4 : ExtImm_E;
    assign PC_Base = (PCSrc_E[1] == 1'b0) ? 
                     ((PCSrc_E[0] == 1'b0) ? PC_F : PC_E) // Will choose PC_E if brancgh or jump
                     : RD1_E;
    // PC_WE for Multi-cycle operations (Multiplication, Division) and/or Pipelining with hazard hardware.
    assign PC_WE = (MCycle_Busy || StallF) ? 1'b1 : 1'b0;  // PC is active-low
    assign PC = PC_F;                   // For output to wrapper

    /*****************************************
     * Decode Pipeline Register
     *****************************************/
    always @(posedge CLK) begin
        if (RESET || PCSrc_E[0]) begin
            Instr_D <= 32'h000000013;
            PC_D <= 32'h0;
        end else if (MCycle_Busy || StallD) begin
            Instr_D <= Instr_D;
            PC_D <= PC_D;
        end
        else begin
            Instr_D <= Instr_F;
            PC_D <= PC_F;
        end
    end

    /*****************************************
     * Decode Stage Datapath
     *****************************************/
    /* Instruction from instruction memory */
	assign Funct3_D = Instr_D[14:12];
	assign Opcode = Instr_D[6:0];
	assign Funct7 = Instr_D[31:25];
	assign rs1_D = Instr_D[19:15];
	assign rs2_D = Instr_D[24:20];
	assign rd_D = Instr_D[11:7];
	assign InstrImm = Instr_D[31:7];

    /* Instantiate Decoder */
    Decoder IDecoder_1 (
        .Opcode(Opcode),
        .Funct3(Funct3_D),
        .Funct7(Funct7),
        .PCS(PCS_D),
        .RegWrite(RegWrite_D),
        .MemWrite(MemWrite_D),
        .MemtoReg(MemtoReg_D),
        .ALUSrcA(ALUSrcA_D),
        .ALUSrcB(ALUSrcB_D),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControl_D),
        .MCycleStart(MCycleStart_D),
        .MCycle_ResultSelect(MCycle_ResultSelect_D),
        .MCycleOp(MCycleOp_D)
    );

    /* Instantiate RegFile */
    RegFile IRegFile_1 ( 
        .CLK(CLK),
        .WE(RegFile_WE),
        .rs1(rs1_D),
        .rs2(rs2_D),
        .rd(rd_W),
        .WD(RegFile_WD),
        .RD1(RD1_D),
        .RD2(RD2_D)
    );

    /* Instantiate Extend module */
    Extend IExtend_1 (
        .ImmSrc(ImmSrc),
        .InstrImm(InstrImm),
        .ExtImm(ExtImm_D)
    );

    /*****************************************
     * Execute Pipeline Register
     *****************************************/
    always @(posedge CLK) begin
        if (RESET || FlushE || PCSrc_E[0]) begin
            PCS_E <= 2'b00;
            Funct3_E <= 3'b000;
            RegWrite_E <= 1'b0;
            MemtoReg_E <= 1'b0;
            MemWrite_E <= 1'b0;
            ALUSrcA_E <= 2'b00;
            ALUSrcB_E <= 2'b00;
            ALUControl_E <= 4'b0000;
            MCycleStart_E <= 1'b0;
            MCycle_ResultSelect_E <= 1'b0;
            MCycleOp_E <= 2'b00;
            RD1_E <= 32'h0;
            RD2_E <= 32'h0;
            ExtImm_E <= 32'h0;
            rd_E <= 5'h0;
            PC_E <= 32'h0;
            rs1_E <= 5'h0;
            rs2_E <= 5'h0;
        end else if (MCycle_Busy) begin
            PCS_E <= PCS_E;
            Funct3_E <= Funct3_E;
            RegWrite_E <= RegWrite_E;
            MemtoReg_E <= MemtoReg_E;
            MemWrite_E <= MemWrite_E;
            ALUSrcA_E <= ALUSrcA_E;
            ALUSrcB_E <= ALUSrcB_E;
            ALUControl_E <= ALUControl_E;
            MCycleStart_E <= MCycleStart_E ;
            MCycle_ResultSelect_E <= MCycle_ResultSelect_E;
            MCycleOp_E <= MCycleOp_E;
            RD1_E <= RD1_E;
            RD2_E <= RD2_E;
            ExtImm_E <= ExtImm_E;
            rd_E <= rd_E;
            PC_E <= PC_E;
            rs1_E <= rs1_E;
            rs2_E <= rs2_E;
        end else begin
            PCS_E <= PCS_D;
            Funct3_E <= Funct3_D;
            RegWrite_E <= RegWrite_D;
            MemtoReg_E <= MemtoReg_D;
            MemWrite_E <= MemWrite_D;
            ALUSrcA_E <= ALUSrcA_D;
            ALUSrcB_E <= ALUSrcB_D;
            ALUControl_E <= ALUControl_D;
            MCycleStart_E <= MCycleStart_D;
            MCycle_ResultSelect_E <= MCycle_ResultSelect_D;
            MCycleOp_E <= MCycleOp_D;
            RD1_E <= RD1_D;
            RD2_E <= RD2_D;
            ExtImm_E <= ExtImm_D;
            rd_E <= rd_D;
            PC_E <= PC_D;
            rs1_E <= rs1_D;
            rs2_E <= rs2_D;
        end
    end

    /*****************************************
     * Execute Stage Datapath
     *****************************************/    
    /* ALU and MCycle inputs 
     * Src_A == MCycle Operand1
     * Src_B == MCycle Operand2
    */

     /* Instantiate PC_Logic */
	PC_Logic IPC_Logic_1 (
        .PCS(PCS_E),
        .Funct3(Funct3_E),
        .ALUFlags(ALUFlags),
        .PCSrc(PCSrc_E)
	);
              
    /* Instantiate ALU */    
    ALU IALU_1 (
        .Src_A(Src_A),
        .Src_B(Src_B),
        .ALUControl(ALUControl_E),
        .ALUResult(ALUResult),
        .ALUFlags(ALUFlags)
    );                
    
    /* Instantiate MCycle for multi-cycle operations */
    MCycle IMCycle_1 (
        .CLK(CLK),
        .RESET(RESET),
        .Start(MCycleStart_E),
        .MCycleOp(MCycleOp_E),
        .Operand1(MCycle_Operand1),
        .Operand2(MCycle_Operand2),
        .MCycle_Result1(MCycle_Result1),
        .MCycle_Result2(MCycle_Result2),
        .MCycle_Busy(MCycle_Busy)
    );

    /*
     * Src_A == MCycle_Operand1
     * Src_B == MCycle_Operand2
    */
    assign Src_A =  (ALUSrcA_E[0] == 1'b0) ? RD1_E_Choose : 
                    (ALUSrcA_E[1] == 1'b0) ? 1'b0 : PC_E;
    assign MCycle_Operand1 = Src_A;

    assign Src_B =  (ALUSrcB_E[0] == 1'b0) ? RD2_E_Choose :
                    (ALUSrcB_E[1] == 1'b0) ? 4 : ExtImm_E;
    assign MCycle_Operand2 = Src_B;
    /* 
     * ALUResult: result from ALU block (add, sub, and, or, sll, srl, sra)
     * MCycle_Result1: MCycle block (mul: LSW, div: Quotient)
     * MCycle_Result2: MCycle block (mul: MSW, div: Remainder)
    */
    assign ALUResult_E = MCycleStart_E ? // check if its a multi-cycle instruction
                            (MCycle_ResultSelect_E ? MCycle_Result2 : MCycle_Result1) // select MCycle_Result based on the instruction
                            : ALUResult;

    assign WriteData_E = RD2_E_Choose; 
                        
    /*****************************************
     * Memory Pipeline Register
     *****************************************/
    always @(posedge CLK) begin
        if (RESET) begin
            RegWrite_M <= 1'b0;
            MemtoReg_M <= 1'b0;
            MemWrite_M <= 1'b0;
            ALUResult_M <= 32'h0;
            WriteData_M <= 32'h0;
            rd_M <= 5'h0;
            rs2_M <= 5'h0;
        end else if (MCycle_Busy) begin
            RegWrite_M <= RegWrite_M;
            MemtoReg_M <= MemtoReg_M ;
            MemWrite_M <= MemWrite_M;
            ALUResult_M <= ALUResult_M;
            WriteData_M <= WriteData_M;
            rd_M <= rd_M;
            rs2_M <= rs2_M;
        end else begin
            RegWrite_M <= RegWrite_E;
            MemtoReg_M <= MemtoReg_E;
            MemWrite_M <= MemWrite_E;
            ALUResult_M <= ALUResult_E;
            WriteData_M <= WriteData_E;
            rd_M <= rd_E;
            rs2_M <= rs2_E;
        end
    end

    /*****************************************
     * Memory Stage Datapath
     *****************************************/    
    /* Data memory write data */
    assign MemRead = MemtoReg_M; // This is needed for the proper functionality of some devices such as UART CONSOLE

    assign MemWrite_out = {4{MemWrite_M}}; // Change datapath as appropriate if supporting sb/sh
    
    assign ALUResult_out = ALUResult_M;

    assign WriteData_out = WriteData_M_Choose;

    assign ReadData_M = ReadData_in;     // Change datapath as appropriate if supporting lb/lbu/lh/lhu

    // v2: <Added to support lb/lbu/lh/lhu/sb/sh>
    assign SizeSel = 3'b010;             // Change this to be generated by the Decoder (control) as appropriate if 
                                         // supporting lb/sb/lbu/lh/sh/lhu/lw/sw. Hint: funct3
    // v2: </Added to support lb/lbu/lh/lhu/sb/sh>

    /*****************************************
     * Writeback Pipeline Register
     *****************************************/
    always @(posedge CLK) begin
        if (RESET) begin
            RegWrite_W <= 1'b0;
            MemtoReg_W <= 1'b0;
            ReadData_W <= 32'h0;
            ALUResult_W <= 32'h0;
            rd_W <= 5'h0;
        end else if (MCycle_Busy) begin
            RegWrite_W <= RegWrite_W;
            MemtoReg_W <= MemtoReg_W;
            ReadData_W <= ReadData_W;
            ALUResult_W <= ALUResult_W;
            rd_W <= rd_W;
        end else begin
            RegWrite_W <= RegWrite_M;
            MemtoReg_W <= MemtoReg_M;
            ReadData_W <= ReadData_in;
            ALUResult_W <= ALUResult_M;
            rd_W <= rd_M;
        end
    end

    /*****************************************
     * Writeback Stage Datapath
     *****************************************/        
    /* Datapath result */
    assign Result_W = (MemtoReg_W == 1'b0) ? ALUResult_W : ReadData_W; // check if its a load instruction

    /* Register write enable */
	assign RegFile_WE = RegWrite_W;

    /* Register write data */
	assign RegFile_WD = Result_W;


    /*****************************************
     * Hazard Unit
     *****************************************/ 
    assign RD1_E_Choose = (ForwardAE[1] == 1'b0) ? 
                            ((ForwardAE[0] == 1'b0) ? RD1_E : Result_W)
                            : ALUResult_M ;

    assign RD2_E_Choose = (ForwardBE[1] == 1'b0) ? 
                            ((ForwardBE[0] == 1'b0) ? RD2_E : Result_W)
                            : ALUResult_M ;

    assign WriteData_M_Choose = (ForwardM == 1'b0) ? WriteData_M : Result_W;

    Hazard IHazard_1(
        .rs1_E(rs1_E),
        .rs2_E(rs2_E),
        .rd_M(rd_M),
        .rd_W(rd_W),
        .RegWrite_M(RegWrite_M),
        .RegWrite_W(RegWrite_W),
        .rs2_M(rs2_M),
        .MemWrite_M(MemWrite_M),
        .MemtoReg_W(MemtoReg_W),
        .rs1_D(rs1_D),
        .rs2_D(rs2_D),
        .rd_E(rd_E),
        .MemtoReg_E(MemtoReg_E),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .ForwardM(ForwardM),
        .StallF(StallF),
        .StallD(StallD),
        .FlushE(FlushE)
    );

    /*************************************************************************
                        END OF STAGE DATAPATH CONNECTION
    *************************************************************************/

endmodule
