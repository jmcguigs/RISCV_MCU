`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/11/2021 01:26:11 PM
// Design Name: 
// Module Name: CU_Decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CU_Decoder(
    input [6:0] OPCODE,
    input [2:0] FUNC3,
    input INTR_TAKEN, FUNC_ID, BR_EQ, BR_LT, BR_LTU,
    output reg [3:0] ALU_FUN,
    output reg [2:0] PC_SRC,
    output reg [1:0] ALU_SRCB, RF_WR_SEL,
    output reg ALU_SRCA
    );
    
    always_comb begin
        case (OPCODE)
        7'b0110011: begin                   // R-TYPE
            ALU_FUN = {FUNC_ID, FUNC3};
            ALU_SRCA = 0;
            ALU_SRCB = 0;
            PC_SRC = 0;
            RF_WR_SEL = 3;
        end
        7'b0010011: begin                   // I-TYPE - ALU FUNCS
            if (FUNC3 == 3'b101 | FUNC3 == 3'b001) ALU_FUN = {FUNC_ID, FUNC3};
            else ALU_FUN = {1'b0, FUNC3};
            ALU_SRCA = 0;
            ALU_SRCB = 1;
            PC_SRC = 0;
            RF_WR_SEL = 3;
        end
        7'b0000011: begin                   // I-TYPE - LOAD
            ALU_FUN = 4'b0000;
            ALU_SRCA = 0;
            ALU_SRCB = 1;
            PC_SRC = 0;
            RF_WR_SEL = 2;
        end
        7'b1100111: begin                   // I-TYPE - JALR
            ALU_FUN = {1'b0, FUNC3};
            ALU_SRCA = 0;
            ALU_SRCB = 1;
            PC_SRC = 1;
            RF_WR_SEL = 0;
        end
        7'b0100011: begin                   // S-TYPE
            ALU_FUN = 4'b0000;
            ALU_SRCA = 0;
            ALU_SRCB = 2;
            PC_SRC = 0;
            RF_WR_SEL = 3;
        end
        7'b1100011: begin                   // B-TYPE
            ALU_FUN = 4'b0000;
            ALU_SRCA = 0;
            ALU_SRCB = 3;
            RF_WR_SEL = 3;
            case (FUNC3)        // branch conditions, set PC to B addr if true
                3'b000: begin
                    if (BR_EQ == 1) PC_SRC = 2;
                    else PC_SRC = 0;
                    end
                3'b101: begin
                    if (BR_LT == 0) PC_SRC = 2;
                    else PC_SRC = 0;
                    end
                3'b111: begin
                    if (BR_LTU == 0) PC_SRC = 2;
                    else PC_SRC = 0;
                    end
                3'b100: begin
                    if (BR_LT == 1) PC_SRC = 2;
                    else PC_SRC = 0;
                    end
                3'b110: begin
                    if (BR_LTU == 1) PC_SRC = 2;
                    else PC_SRC = 0;
                end
                3'b001: begin
                    if (BR_EQ == 0) PC_SRC = 2;
                    else PC_SRC = 0;
                    end
                default: PC_SRC = 0;
            endcase
        end
        7'b0110111: begin                   // LUI
            ALU_SRCA = 1;
            ALU_SRCB = 0;
            PC_SRC = 0;
            RF_WR_SEL = 3;
            ALU_FUN = 4'b1001;
            end
        7'b0010111: begin                   // AUIPC
            ALU_SRCA = 1;
            ALU_SRCB = 3;
            PC_SRC = 0;
            RF_WR_SEL = 3;
            ALU_FUN = 4'b0000;
            end
        7'b1101111: begin                   // JAL
            ALU_FUN = 4'b0000;         // not used for jal
            ALU_SRCA = 0;
            ALU_SRCB = 0;
            RF_WR_SEL = 0;             // link
            PC_SRC = 3;
        end
        7'b1110011: begin               // CSR/mret
            if (FUNC3 == 3'b000) begin  // mret
                ALU_FUN = 4'b0000;
                ALU_SRCA = 0;
                ALU_SRCB = 0;
                RF_WR_SEL = 0;
                PC_SRC = 5;
                end
            else begin                  // CSR read/write
                ALU_FUN = 4'b0000;
                ALU_SRCA = 0;
                ALU_SRCB = 0;
                RF_WR_SEL = 1;
                PC_SRC = 0;
            end
        end
        default: begin                      // no latches
            ALU_FUN = 4'b0000;
            ALU_SRCA = 0;
            ALU_SRCB = 0;
            PC_SRC = 0;
            RF_WR_SEL = 3;
            end
        endcase
        if (INTR_TAKEN) PC_SRC = 4;
    end
endmodule
