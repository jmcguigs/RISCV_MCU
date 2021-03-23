`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/22/2021 09:14:15 AM
// Design Name: 
// Module Name: Reg_File
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


module Reg_File(
    input logic [31:0] RF_WD,
    input logic [4:0] RF_WA, RF_ADR1, RF_ADR2,
    input logic RF_EN, CLK,
    output logic [31:0] RF_RS1, RF_RS2
    );
    
    logic [31:0] ram [31:0];                 // 32x32
    
    // initialize all registers to 0
//    initial begin
//    int i;
//        for (i=0; i<32; i++) begin
//            ram[i] = 0;
//        end
//    end

    initial ram[0] = 0;
    
    // synchronous write
    always_ff @ (posedge CLK) begin
        if (RF_EN == 1 && RF_WA == 0) ram[0] <= 0;       // x0 is always 0
        else if (RF_EN == 1) ram[RF_WA] <= RF_WD;       // update if EN high
    end
    
    // asynchronous read
    always_comb begin
        RF_RS1 = ram[RF_ADR1];
        RF_RS2 = ram[RF_ADR2];
    end
endmodule
