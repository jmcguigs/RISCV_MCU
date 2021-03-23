`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/10/2021 11:40:35 PM
// Design Name: 
// Module Name: OTTER_MCU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: the real deal, the mcu
// 
// Dependencies: everything
// 
// Revision: 2.11.21
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module OTTER_MCU(
    input RST, INTR, CLK,
    input [31:0] IOBUS_IN,
    output IOBUS_WR,
    output [31:0] IOBUS_OUT, IOBUS_ADDR
    );
    
    // interconnects
    logic [31:0] PC_IN, jalr, branch, jal, mtvec, mepc, COUNT, ADDR_NEXT, ir, IMM_U, IMM_I, IMM_S, IMM_J, IMM_B;
    logic [31:0] srcA, srcB, result, RS1, RS2, reg_dat, csr_RD;
    logic [3:0] alu_fun;
    logic [2:0] pcSource;
    logic [1:0] alu_srcB, rf_wr_sel;
    logic PCWrite, regWrite, memWE2, memRDEN1, memRDEN2, reset, csr_WE, int_taken, alu_srcA, csr_MIE;
        
    // outputs
    assign IOBUS_OUT = RS2;
    assign IOBUS_ADDR = result; 
    
    // PROGRAM COUNTER
    Mux_6_1 PC_INPUT(.out(PC_IN), .in0(ADDR_NEXT), .in1(jalr), .in2(branch), .in3(jal), .in4(mtvec), .in5(mepc), .sel(pcSource));
    Prog_Count PC(.CLK(CLK), .PC_WRITE(PCWrite), .PC_RST(reset), .PC_DIN(PC_IN), .PC_COUNT(COUNT), .PC_NEXT(ADDR_NEXT));
    
    // MEMORY
    logic [31:0] DOUT2;
    Memory MEM(.MEM_CLK(CLK), .MEM_ADDR1(COUNT[15:2]), .MEM_ADDR2(result), .MEM_DIN2(RS2), .MEM_RDEN1(memRDEN1), .MEM_RDEN2(memRDEN2), 
    .MEM_WE2(memWE2), .MEM_SIZE(ir[13:12]), .MEM_SIGN(ir[14]), .MEM_DOUT2(DOUT2), .MEM_DOUT1(ir), .IO_IN(IOBUS_IN), .IO_WR(IOBUS_WR));
    
    // RAM
    //input mux
    always_comb begin
        case (rf_wr_sel)
        0: reg_dat = ADDR_NEXT;
        1: reg_dat = csr_RD;            // CSR RD placeholder
        2: reg_dat = DOUT2;
        3: reg_dat = result;
        endcase
    end
    Reg_File RAM(.CLK(CLK), .RF_EN(regWrite), .RF_ADR1(ir[19:15]), .RF_ADR2(ir[24:20]), .RF_WA(ir[11:7]), .RF_RS1(RS1), .RF_RS2(RS2),
    .RF_WD(reg_dat));
    
    // IMMEDIATE & ADDR GEN
    IMMED_GEN IMMED_GEN(.INSTRUCT(ir), .U_TYPE(IMM_U), .I_TYPE(IMM_I), .S_TYPE(IMM_S), .J_TYPE(IMM_J), .B_TYPE(IMM_B));
    B_Addr_Gen BRANCH_ADDR_GEN(.J(IMM_J), .B(IMM_B), .I(IMM_I), .PC(COUNT), .RS1(RS1), .jalr(jalr), .branch(branch), .jal(jal));
    
    // ALU
    //ALU srcA mux
    always_comb begin
        case (alu_srcA)
        0: srcA = RS1;
        1: srcA = IMM_U;
        endcase
    end
    // ALU srcB mux
    always_comb begin
        case (alu_srcB)
        0: srcB = RS2;
        1: srcB = IMM_I;
        2: srcB = IMM_S;
        3: srcB = COUNT;
        endcase
    end
    ALU ALU(.A(srcA), .B(srcB), .ALU_FUN(alu_fun), .RESULT(result));
    
    // BRANCH GEN & CONTROL
    logic br_eq, br_lt, br_ltu;
    B_Cond_Gen BRANCH_COND_GEN(.A(RS1), .B(RS2), .LTU(br_ltu), .LTS(br_lt), .EQ(br_eq));
    
    CU_Decoder Decoder(.OPCODE(ir[6:0]), .FUNC3(ir[14:12]), .FUNC_ID(ir[30]), .BR_EQ(br_eq), .BR_LT(br_lt), .BR_LTU(br_ltu),
    .ALU_FUN(alu_fun), .ALU_SRCA(alu_srcA), .ALU_SRCB(alu_srcB), .PC_SRC(pcSource), .RF_WR_SEL(rf_wr_sel), .INTR_TAKEN(int_taken));
    
    CU_FSM FSM(.CLK(CLK), .RST(RST), .INTR(INTR), .RF_WR(regWrite), .MEM_WE2(memWE2), .MEM_RE1(memRDEN1), .MEM_RE2(memRDEN2),
    .RESET(reset), .CSR_WE(csr_WE), .INT_TAKEN(int_taken), .OPCODE(ir[6:0]), .FUNC3(ir[14:12]), .PC_WR(PCWrite), .CSR_MIE(csr_MIE));
    
    // Control status register
    CSR CSR(.RST(reset), .INT_TAKEN(int_taken), .ADDR(ir[31:20]), .WE(csr_WE), .PC(COUNT), .CLK(CLK), .MIE(csr_MIE), 
    .MTVEC(mtvec), .MEPC(mepc), .WD(RS1), .RD(csr_RD));
endmodule
