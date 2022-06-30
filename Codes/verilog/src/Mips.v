module Mips (Clk, Rst, Start);

  input Rst, Clk, Start;

  wire [3:0] opcode;
  wire [8:0] func;
  wire MemWrite, MemRead, PCWrite,
  PCWriteCond, IOrD, IRWrite, MemToReg,
  RegWrite, RegDst, AluSrcA, ImSel;
  wire [1:0] AluSrcB, PCSrc;
  wire [2:0] ALUOperation;

   MipsController Ctrl (
    .opcode(opcode),
    .func(func),
    .clk(Clk),
    .rst(Rst),
    .MemWrite(MemWrite),
    .MemRead(MemRead),
    .PCWrite(PCWrite),
    .PCWriteCond(PCWriteCond),
    .IOrD(IOrD),
    .IRWrite(IRWrite),
    .MemToReg(MemToReg),
    .RegWrite(RegWrite),
    .RegDst(RegDst),
    .AluSrcA(AluSrcA),
    .ImSel(ImSel),
    .start(Start),
    .AluSrcB(AluSrcB),
    .PCSrc(PCSrc),
    .ALUOperation(ALUOperation)
  );
  MipsDatapath DP (
    .clk(Clk),
    .rst(Rst),
    .MemWrite(MemWrite),
    .MemRead(MemRead),
    .PCWrite(PCWrite),
    .PCWriteCond(PCWriteCond),
    .IOrD(IOrD),
    .IRWrite(IRWrite),
    .MemToReg(MemToReg),
    .RegWrite(RegWrite),
    .RegDst(RegDst),
    .AluSrcA(AluSrcA),
    .ImSel(ImSel),
    .AluSrcB(AluSrcB),
    .PCSrc(PCSrc),
    .AluOperation(ALUOperation),
    .opcode(opcode),
    .func(func)
  );

endmodule