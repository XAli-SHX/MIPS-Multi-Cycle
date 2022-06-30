module MipsDatapath(
    input clk, rst, MemWrite, MemRead, PCWrite, PCWriteCond, IOrD, IRWrite, MemToReg, RegWrite, RegDst, AluSrcA, ImSel, //ImSel (wasn't included in datapath schematic)
    input [1:0] AluSrcB, PCSrc,
    input [2:0] AluOperation, //AluOperation is the output of ALU_Control
    output [3:0] opcode,
    output [8:0] func // passed to controller
);

    wire [11:0] InstAddress, PC_In, Mux_InstMemAddress_Out;
    wire [15:0] MemOut, IROut, MDROut, ALURegIn, ALURegOut, WriteData, seIR_Out, R0In, RiIn, R0Out, RiOut, ALU_InA, ALU_InB;
    wire zero, PCWriteAndOr, DstAndFunc;
    wire [2:0] WriteAddress, ALUOp;

    wire [4:0] Mux_Dst_Out, Mux_Jal_Out;
    wire [15:0] ReadData, AluRes, Mux_MemToReg_Out, Mux_Jump_Out, Mux_Jr_Out;
    wire [31:0] br_Adder_Out, Mux_Br_Out;

    assign DstAndFunc = RegDst & IROut[0];
    assign opcode = IROut[15:12];
    assign func = IROut[8:0];
    assign PCWriteAndOr = ((zero & PCWriteCond) | PCWrite);

    Register #(12) PC(.clk(clk), .rst(rst), .ld(PCWriteAndOr), .regIn(PC_In), .regOut(InstAddress));
    Mux2 #(12) Mux_InstMemAddress(.d0(InstAddress), .d1(IROut[11:0]), .sel(IOrD), .w(Mux_InstMemAddress_Out));
    Memory #(16, 12) Mem (
        .clk(clk),
        .Address(Mux_InstMemAddress_Out),
        .WriteData(R0Out),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .ReadData(MemOut)
    );
    Register #(16) IR(.clk(clk), .rst(rst), .ld(IRWrite), .regIn(MemOut), .regOut(IROut));
    Register #(16) MDR(.clk(clk), .rst(rst), .ld(1'b1), .regIn(MemOut), .regOut(MDROut));
    Mux2 #(16) Mux_MemToReg(.d0(ALURegOut), .d1(MDROut), .sel(MemToReg), .w(WriteData));
    Mux2 #(3) Mux_WriteAddress(.d0(3'b000), .d1(IROut[11:9]), .sel(DstAndFunc), .w(WriteAddress)); // 15-12 In schematic was corrected to 11-9
    Register #(16) R0(.clk(clk), .rst(rst), .ld(1'b1), .regIn(R0In), .regOut(R0Out));
    Register #(16) Ri(.clk(clk), .rst(rst), .ld(1'b1), .regIn(RiIn), .regOut(RiOut));
    RegisterFile #(16, 3) RegFile (
        .ReadReg1(3'b000),
        .ReadReg2(IROut[11:9]),
        .WriteReg(WriteAddress), // 15-12 In schematic was corrected to 11-9
        .WriteData(WriteData),
        .clk(clk), .RegWrite(RegWrite),
        .ReadData1(R0In), .ReadData2(RiIn)
    );
    SignExtend #(12, 16) seIR(.in(IROut[11:0]), .out(seIR_Out));
    Mux4 #(16) Mux_ALUSrcB(.d0(RiOut), .d1(seIR_Out), .d2(16'b0000000000000001),
    .d3(16'bZZZZZZZZZZZZZZZZ), .sel(AluSrcB), .w(ALU_InB)
    );
    Mux2 #(16) Mux_ALUSrcA(.d0({InstAddress[11], InstAddress[11], InstAddress[11], InstAddress[11], InstAddress}), // Needed sign extention
    .d1(R0Out), .sel(AluSrcA), .w(ALU_InA)
    );
    Alu #(16) myALU(.A(ALU_InA), .B(ALU_InB), .op(ALUOp), .res(ALURegIn), .zero(zero));
    Register #(16) ALUReg(.clk(clk), .rst(rst), .ld(1'b1), .regIn(ALURegIn), .regOut(ALURegOut));
    Mux2 #(3) Mux_ALUOperation(.d0(AluOperation), .d1(IROut[14:12]), .sel(ImSel), .w(ALUOp));
    Mux4 #(12) Mux_PCSrc(.d0(ALURegIn[11:0]), .d1(IROut[11:0]), .d2({InstAddress[11:9], IROut[8:0]}),
    .d3(12'bZZZZZZZZZZZZ), .sel(PCSrc), .w(PC_In)
    );

endmodule