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
    output logic [1:0] ForwardAE,   // Data Forward
    output logic [1:0] ForwardBE,   // Data Forward
    output logic ForwardM           // M2M Copy
    );

    always_comb begin : ForwardAEBlock
        if ((rs1_E == rd_M) && (RegWrite_M == 1'h1) && (rd_M != 5'h0)) begin
            ForwardAE = 2'b10;
        end else if ((rs1_E == rd_W) && (RegWrite_W == 1'h1) && (rd_W != 5'h0)) begin
            ForwardAE = 2'b01;
        end else begin
            ForwardAE = 2'b00;
        end
    end

    always_comb begin : ForwardBEBlock
        if ((rs2_E == rd_M) && (RegWrite_M == 1'h1) && (rd_M != 5'h0)) begin
            ForwardBE = 2'b10;
        end else if ((rs2_E == rd_W) && (RegWrite_W == 1'h1) && (rd_W != 5'h0)) begin
            ForwardBE = 2'b01;
        end else begin
            ForwardBE = 2'b00;
        end
    end

    assign ForwardM = ((rs2_M == rd_W) && MemWrite_M && MemtoReg_W && (rd_W != 5'h0)) ? 1'b1 : 1'b0;

endmodule

