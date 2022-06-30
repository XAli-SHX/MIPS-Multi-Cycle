module MipsController (
    clk, rst, MemWrite, MemRead, PCWrite, start, //you have to start first!
    PCWriteCond, IOrD, IRWrite, MemToReg,
    RegWrite, RegDst, AluSrcA, ImSel, //ImSel (wasn't included in datapath schematic)
    AluSrcB, PCSrc, ALUOperation, //AluOperation is the output of ALU_Control
    opcode, func
);
    input [3:0] opcode;
    input [8:0] func;
    input clk, rst, start;

    output reg MemWrite, MemRead, PCWrite,
    PCWriteCond, IOrD, IRWrite, MemToReg,
    RegWrite, RegDst, AluSrcA, ImSel;
    output reg [1:0] AluSrcB, PCSrc;
    output [2:0] ALUOperation;
    
    reg [1:0] ALUOp;
    reg [3:0] ns, ps;
    // initial ns = 4'b0000;

    parameter [3:0]  Idle = 0, IF = 1, ID = 2, Jump = 3,
    BranchZ = 4, Load_Read = 5, Load_WriteReg = 6,
    Store = 7, C_Ex = 8, C_Reg = 9, 
	D_Ex = 10, D_Reg = 11;

    AluController AluCtrl(.func(func), .AluOp(ALUOp), .AluOperation(ALUOperation)); // ALU Ctrl Instance

    always @(ps, start) begin
        ns = Idle;
        case(ps)
            Idle: ns = start ? IF : Idle;
            IF: ns = ID;
            ID: begin
                case(opcode)
                    4'b1000: ns = C_Ex;
                    4'b1100: ns = D_Ex;
                    4'b1101: ns = D_Ex;
                    4'b1110: ns = D_Ex;
                    4'b1111: ns = D_Ex;
                    4'b0000: ns = Load_Read;
                    4'b0001: ns = Store;
                    4'b0010: ns = Jump;
                    4'b0100: ns = BranchZ;
                endcase
            end
            C_Ex: ns = C_Reg;
            C_Reg: ns = IF;
            D_Ex: ns = D_Reg;
            D_Reg: ns = IF;
            Load_Read: ns = Load_WriteReg;
            Load_WriteReg: ns = IF;
            Store: ns = IF;
            Jump: ns = IF;
            BranchZ: ns = IF;
        endcase
    end

    always @(ps, opcode) begin // Is sensitivity correct?
        MemWrite = 1'b0; MemRead = 1'b0; PCWrite = 1'b0; ALUOp = 2'b00; AluSrcB = 2'b00; PCSrc = 2'b00;
    PCWriteCond = 1'b0; IOrD = 1'b0; IRWrite = 1'b0; MemToReg = 1'b0;
    RegWrite = 1'b0; RegDst = 1'b0; AluSrcA = 1'b0; ImSel = 1'b0;
        case(ps)
            IF: begin
                MemRead = 1'b1;
                IRWrite = 1'b1;
                AluSrcB = 2'b10;
                PCWrite = 1'b1;
            end
            C_Ex: begin
                AluSrcA = 1'b1;
                ALUOp = 2'b10;
            end
            C_Reg: begin
                RegWrite = 1'b1;
                RegDst = 1'b1;
            end
            D_Ex: begin
                AluSrcA = 1'b1;
                AluSrcB = 2'b01;
                ImSel = 1'b1;
            end
            D_Reg: RegWrite = 1'b1;
            Load_Read: begin
                IOrD = 1'b1;
                MemRead = 1'b1;
            end
            Load_WriteReg: begin
                MemToReg = 1'b1;
                RegWrite = 1'b1;
            end
            Store: begin
                IOrD = 1'b1;
                MemWrite = 1'b1;
            end
            Jump: begin
                PCWrite = 1'b1;
                PCSrc = 2'b01;
            end
            BranchZ: begin
                AluSrcA = 1'b1;
                ALUOp = 2'b01;
                PCWriteCond = 1'b1;
                PCSrc = 2'b10;
            end
        endcase    
    end

    always @(posedge clk, posedge rst) begin
        if (rst)
            ps <= Idle;
        else
            ps <= ns;
    end
    
endmodule