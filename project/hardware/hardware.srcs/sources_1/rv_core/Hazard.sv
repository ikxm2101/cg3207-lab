`timescale 1ns / 1ps
module Hazard(
    input [4:0] rs1_E,
    input [4:0] rs2_E,
    input [4:0] rd_M,
    input [4:0] rd_W,
    input RegWrite_M,
    input RegWrite_W,
    output logic [1:0] ForwardAE,
    output logic [1:0] ForwardBE
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

endmodule

