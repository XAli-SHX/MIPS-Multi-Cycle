module MipsDatapath(
    input clk, rst, RegDst, R31, RegWrite, WriteLink, AluSrc,
    MemRead, MemWrite, MemToReg, Branch, jump, jr,
    input [2:0] AluOperation,
    output [5:0] opcode, func // passed to controller
);

    wire [31:0] InstAddress, PC_Adder_Out, Instruction;
    wire [4:0] Mux_Dst_Out, Mux_Jal_Out;
    wire [31:0] ReadData1, ReadData2, WriteData, Mux_AluSrc_Out, se_Out;
    wire [31:0] ReadData, AluRes, Mux_MemToReg_Out, Mux_Jump_Out, Mux_Jr_Out;
    wire [31:0] br_Adder_Out, Mux_Br_Out;
    wire zero;

    Register #(32) PC(.clk(clk), .rst(rst), .ld(1'b1), .regIn(Mux_Jr_Out), .regOut(InstAddress));
    InstructionMemory #(32, 32) InstMem(.clk(clk), .Address(InstAddress), .Instruction(Instruction)); // (5, 32) Or (32, 32) ?
    Adder #(32) PC_Adder (.A(32'b00000000000000000000000000000100), .B(InstAddress), .sub(0), .res(PC_Adder_Out));
    Mux2 #(5) Mux_Dst(.d0(Instruction[20:16]), .d1(Instruction[15:11]), .sel(RegDst), .w(Mux_Dst_Out));
    Mux2 #(5) Mux_Jal(.d0(Mux_Dst_Out), .d1(5'b11111), .sel(R31), .w(Mux_Jal_Out));
    Mux2 #(32) Mux_WriteLink(.d0(Mux_MemToReg_Out), .d1(PC_Adder_Out), .sel(WriteLink), .w(WriteData));
    SignExtend #(16, 32) se(.in(Instruction[15:0]), .out(se_Out));
    Mux2 #(32) Mux_AluSrc(.d0(ReadData2), .d1(se_Out), .sel(AluSrc), .w(Mux_AluSrc_Out));
    Alu #(32) myALU(.A(ReadData1), .B(Mux_AluSrc_Out), .op(AluOperation), .res(AluRes), .zero(zero));
    Memory #(32, 32) DataMem(
        .Address(AluRes),
        .WriteData(ReadData2),
        .MemRead(MemRead), .MemWrite(MemWrite), .clk(clk),
        .ReadData(ReadData)
    );
    Mux2 #(32) Mux_MemToReg(.d0(AluRes), .d1(ReadData), .sel(MemToReg), .w(Mux_MemToReg_Out));
    RegisterFile #(32, 5) RegFile (
        .ReadReg1(Instruction[25:21]), .ReadReg2(Instruction[20:16]), .WriteReg(Mux_Jal_Out),
        .WriteData(WriteData),
        .clk(clk), .RegWrite(RegWrite),
        .ReadData1(ReadData1), .ReadData2(ReadData2)
    );
    Adder #(32) br_Adder (.A(PC_Adder_Out), .B((se_Out<<2)), .sub(0), .res(br_Adder_Out));
    Mux2 #(32) Mux_Br(.d0(PC_Adder_Out), .d1(br_Adder_Out), .sel((Branch & zero)), .w(Mux_Br_Out)); // Sussy
    Mux2 #(32) Mux_Jump(
        .d0(Mux_Br_Out), .d1({PC_Adder_Out[31:28], Instruction[25:0], 2'b00}), // pc_adder_out[31:28]
        .sel(jump), .w(Mux_Jump_Out)
    );
    Mux2 #(32) Mux_Jr(.d0(Mux_Jump_Out), .d1(ReadData1), .sel(jr), .w(Mux_Jr_Out));
    assign opcode = Instruction[31:26];
    assign func = Instruction[5:0];

endmodule