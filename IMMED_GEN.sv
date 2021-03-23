`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/29/2021 01:18:12 PM
// Design Name: 
// Module Name: IMMED_GEN
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


module IMMED_GEN(
    input [31:0] INSTRUCT,
    output reg [31:0] U_TYPE, I_TYPE, S_TYPE, J_TYPE, B_TYPE
    );
    
    // cut IMM values from INSTRUCT
    always_comb begin
        J_TYPE = {{12{INSTRUCT[31]}}, INSTRUCT[19:12], INSTRUCT[20], INSTRUCT[30:21], 1'b0};
        B_TYPE = {{20{INSTRUCT[31]}}, INSTRUCT[7], INSTRUCT[30:25], INSTRUCT[11:8], 1'b0};
        U_TYPE = {INSTRUCT[31:12], 12'b0};
        S_TYPE = {{21{INSTRUCT[31]}}, INSTRUCT[30:25], INSTRUCT[11:7]};
        I_TYPE = {{21{INSTRUCT[31]}}, INSTRUCT[30:25], INSTRUCT[24:20]};
    end
    
endmodule
