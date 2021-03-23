`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2021 02:40:40 PM
// Design Name: 
// Module Name: CSR
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


module CSR(
    input RST, INT_TAKEN, WE, CLK,
    input [11:0] ADDR,
    input [31:0] PC, WD,
    output reg MIE,
    output reg [31:0] MEPC, MTVEC, RD
    );
    
    always_ff @(posedge CLK) begin
        if (WE & INT_TAKEN) begin   // interrupt
            MEPC <= PC;
            MIE <= 0;
        end
        if (WE & ~INT_TAKEN) begin  // read/write
            case (ADDR)
                'h341: begin        // mepc
                    RD <= MEPC;
                    MEPC <= WD;
                end
                'h305: begin        // mtvec
                    RD <= MTVEC;
                    MTVEC <= WD;
                end
                'h304: begin        // mie
                    RD <= MIE;
                    MIE <= WD;
                end
                default: begin      // failsafe
                    RD <= MTVEC;
                    MTVEC <= WD;
                end
            endcase
        end
        if (RST) begin              // reset
            MEPC <= 0;
            MIE <= 0;
            MTVEC <= 0;
        end
    end
endmodule
