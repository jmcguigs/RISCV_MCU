`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2021 12:16:29 AM
// Design Name: 
// Module Name: B_Cond_Gen
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


module B_Cond_Gen(
    input signed [31:0] A, B,
    output LTU, EQ, LTS
    );
    assign LTU = $unsigned(A) < $unsigned(B);   // unsigned interpretation
    assign EQ = A == B;
    assign LTS = (A) < (B);       // signed interpretation
endmodule
