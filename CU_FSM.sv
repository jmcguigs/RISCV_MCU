`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/11/2021 07:26:30 PM
// Design Name: 
// Module Name: CU_FSM
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


module CU_FSM(
    input RST, INTR, CSR_MIE, CLK,
    input [6:0] OPCODE,
    input [2:0] FUNC3,
    output reg PC_WR, RF_WR, MEM_WE2, MEM_RE1, MEM_RE2, RESET, CSR_WE, INT_TAKEN
    );
    
    reg [2:0] state = 0, next;
    //initial state = 2'b01;
    
    always_ff @ (posedge CLK) begin
        if (RST == 0) state <= next;              // advance state on each clock edge
        else state <= 0;
    end
    
    always_comb begin
        case (state)
        3'b000: begin                // INIT/RESET - DO NOTHING
            next = 3'b001;
            RESET = 1;
            MEM_RE1 = 0;
            MEM_RE2 = 0;
            MEM_WE2 = 0;
            RF_WR = 0;
            PC_WR = 0;
            INT_TAKEN = 0;
            CSR_WE = 0;
        end
        3'b001: begin                // FETCH - READ
            next = 3'b010;
            RESET = 0;
            MEM_RE1 = 1;
            MEM_RE2 = 0;
            MEM_WE2 = 0;
            RF_WR = 0;
            PC_WR = 0;
            INT_TAKEN = 0;
            CSR_WE = 0;
        end
        3'b010: begin                // EXEC - CALC/WRITE
            case (OPCODE)
                default begin       // !LOAD - 1 CYCLE
                    next = 3'b001;
                    RESET = 0;
                    MEM_RE1 = 0;
                    MEM_RE2 = 1;
                    MEM_WE2 = 0;
                    RF_WR = 1;
                    PC_WR = 1;
                    INT_TAKEN = 0;
                    CSR_WE = 0;
                end
                7'b0100011: begin   // S-TYPE
                    next = 3'b001;
                    RESET = 0;
                    MEM_RE1 = 0;
                    MEM_RE2 = 0;
                    MEM_WE2 = 1;
                    RF_WR = 0;
                    PC_WR = 1;
                    INT_TAKEN = 0;
                    CSR_WE = 0;
                end
                7'b1100011: begin   // B-TYPE
                    next = 3'b001;
                    RESET = 0;
                    MEM_RE1 = 0;
                    MEM_RE2 = 1;
                    MEM_WE2 = 0;
                    RF_WR = 0;
                    PC_WR = 1;
                    INT_TAKEN = 0;
                    CSR_WE = 0;
                end
                7'b0000011: begin   // LOAD - 2 CYCLE
                    next = 3'b011;
                    RESET = 0;
                    MEM_RE1 = 0;
                    MEM_RE2 = 1;
                    MEM_WE2 = 0;
                    RF_WR = 0;
                    PC_WR = 0;
                    INT_TAKEN = 0;
                    CSR_WE = 0;
                end
                7'b1110011: begin               // CSR/mret
                if (FUNC3 == 3'b000) begin  // mret
                    next = 3'b001;
                    RESET = 0;
                    MEM_RE1 = 0;
                    MEM_RE2 = 0;
                    MEM_WE2 = 0;
                    RF_WR = 0;
                    PC_WR = 1;
                    INT_TAKEN = 0;
                    CSR_WE = 0;
                end
                else begin                  // CSR read/write
                    next = 3'b001;
                    RESET = 0;
                    MEM_RE1 = 0;
                    MEM_RE2 = 0;
                    MEM_WE2 = 0;
                    RF_WR = 1;
                    PC_WR = 1;
                    INT_TAKEN = 0;
                    CSR_WE = 1;
                end
                end
            endcase
            if (INTR & CSR_MIE & (next != 3'b011)) next = 3'b100;  // interrupt
        end
        3'b011: begin                // WRITEBACK - 2nd LOAD CYCLE
            if (INTR & CSR_MIE) next = 3'b100;
            else next = 3'b001;
            RESET = 0;
            MEM_RE1 = 0;
            MEM_RE2 = 0;
            MEM_WE2 = 0;
            RF_WR = 1;
            PC_WR = 1;
            INT_TAKEN = 0;
            CSR_WE = 0;
        end
        3'b100: begin               // INTERRUPT
            next = 3'b001;
            RESET = 0;
            MEM_RE1 = 0;
            MEM_RE2 = 0;
            MEM_WE2 = 0;
            RF_WR = 0;
            PC_WR = 1;
            INT_TAKEN = 1;
            CSR_WE = 1;
        end
        default: begin
            next = 3'b001;
            RESET = 1;
            MEM_RE1 = 0;
            MEM_RE2 = 0;
            MEM_WE2 = 0;
            RF_WR = 0;
            PC_WR = 0;
            INT_TAKEN = 0;
            CSR_WE = 0;
            end
        endcase
    end
endmodule
