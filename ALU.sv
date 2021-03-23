`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/28/2021 01:34:25 PM
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [31:0] A, B,                       // default to signed interpretation
    input [3:0] ALU_FUN,
    output reg [31:0] RESULT
    );
    
    //initial RESULT = 0;     // no latch pls
    
    always_comb begin
        case (ALU_FUN)
            4'b0000: RESULT = $signed(A) + $signed(B);               // ADD
            4'b1000: RESULT = $signed(A) - $signed(B);               // SUB
            4'b0110: RESULT = A | B;                                   // OR
            4'b0111: RESULT = A & B;                               // AND
            4'b0100: RESULT = A ^ B;                               // XOR
            4'b0101: RESULT = $signed(A) >> B[4:0];              // SRL
            4'b0001: RESULT = $signed(A) << B[4:0];               // SLL
            4'b1101: RESULT = $signed(A) >>> B[4:0];             // SRA
            4'b0010: begin                                          // SLT
                if ($signed(A) < $signed(B)) RESULT = 1;
                else RESULT = 0;
                end
            4'b0011: begin                                          // SLTU
                if ($unsigned(A) < $unsigned(B)) RESULT = 1;
                else RESULT = 0;
                end
            4'b1001: RESULT = A;                           // LUI-COPY
            // Else
            default: RESULT = 0;
        endcase
    end
endmodule
