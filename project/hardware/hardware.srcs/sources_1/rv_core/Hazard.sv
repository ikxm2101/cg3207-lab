`timescale 1ns / 1ps
module Hazard(
    input [4:0] rs1_E,              // Data Forward
    input [4:0] rs2_E,              // Data Forward
    input [4:0] rd_M,               // Data Forward
    input [4:0] rd_W,               // Data Forward
    input RegWrite_M,               // Data Forward
    input RegWrite_W,               // Data Forward
    input [4:0] rs2_M,              // M2M Copy
    input MemWrite_M,               // M2M Copy
    input MemtoReg_W,               // M2M Copy
    input [4:0] rs1_D,              // Load and Use
    input [4:0] rs2_D,              // Load and Use
    input [4:0] rd_E,               // Load and Use
    input MemtoReg_E,               // Load and Use
    output logic [1:0] ForwardAE,   // Data Forward
    output logic [1:0] ForwardBE,   // Data Forward
    output logic ForwardM,          // M2M Copy
    output StallF,                  // Load and Use
    output StallD,                  // Load and Use
    output FlushE                   // Load and Use
    );

    // Data Forward
    always_comb begin : ForwardAEBlock
        if ((rs1_E == rd_M) && (RegWrite_M == 1'h1) && (rd_M != 5'h0)) begin
            ForwardAE = 2'b10;
        end else if ((rs1_E == rd_W) && (RegWrite_W == 1'h1) && (rd_W != 5'h0)) begin
            ForwardAE = 2'b01;
        end else begin
            ForwardAE = 2'b00;
        end
    end

    // Data Forward
    always_comb begin : ForwardBEBlock
        if ((rs2_E == rd_M) && (RegWrite_M == 1'h1) && (rd_M != 5'h0)) begin
            ForwardBE = 2'b10;
        end else if ((rs2_E == rd_W) && (RegWrite_W == 1'h1) && (rd_W != 5'h0)) begin
            ForwardBE = 2'b01;
        end else begin
            ForwardBE = 2'b00;
        end
    end

    // M2M Copy
    assign ForwardM = ((rs2_M == rd_W) && MemWrite_M && MemtoReg_W && (rd_W != 5'h0)) ? 1'b1 : 1'b0;

    // Load and Use
    wire lwStall;
    assign lwStall = ((rs1_D == rd_E) || (rs2_D == rd_E)) && MemtoReg_E;
    assign StallF = lwStall;
    assign StallD = lwStall;
    assign FlushE = lwStall;
endmodule

