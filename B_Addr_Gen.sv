`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2021 09:42:42 AM
// Design Name: 
// Module Name: B_Addr_Gen
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


module B_Addr_Gen(
    input [31:0] J, B, I,
    input [31:0] PC, RS1,
    output [31:0] jal, jalr, branch
    );

    assign jal = J + PC;
    assign jalr = I + RS1;
    assign branch = B + PC;

endmodule
