module Mips (Clk, Rst);
    input Rst, Clk;
    wire RegDst, R31, RegWrite, WriteLink, AluSrc,
    MemRead, MemWrite, MemToReg, Branch, jump, jr;
    wire [2:0] ALUOperation;
    wire  [5:0] opcode, func;

   MipsController Ctrl (.opcode(opcode), .func(func), .MemToReg(MemToReg), .MemRead(MemRead), .MemWrite(MemWrite),
   .RegWrite(RegWrite), .ALUOperation(ALUOperation), .Branch(Branch), .jump(jump), .jr(jr),
   .WriteLink(WriteLink), .RegDst(RegDst), .R31(R31), .ALUSrc(AluSrc));
  MipsDatapath DP (.clk(Clk), .rst(Rst), .RegDst(RegDst), .R31(R31), .RegWrite(RegWrite), .WriteLink(WriteLink), .AluSrc(AluSrc),
  .MemRead(MemRead), .MemWrite(MemWrite), .MemToReg(MemToReg), .Branch(Branch), .jump(jump),
  .jr(jr), .AluOperation(ALUOperation), .opcode(opcode), .func(func));
  
endmodule