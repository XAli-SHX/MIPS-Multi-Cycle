module AluController(
    input [1:0] AluOp, input [8:0] func, 
    output reg [2:0] AluOperation
);

    always @(AluOp, func) begin
        case (AluOp)
            2'b10: begin
                case (func)
                    9'b000000001: AluOperation = 3'b000; // A
                    9'b000000010: AluOperation = 3'b001; // B
                    9'b000000100: AluOperation = 3'b100; // add
                    9'b000001000: AluOperation = 3'b101; // sub
                    9'b000010000: AluOperation = 3'b110; // and
                    9'b000100000: AluOperation = 3'b111; // or
                    9'b001000000: AluOperation = 3'b010; // not B
                    9'b010000000: AluOperation = 3'b000; // A
                endcase
            end
            2'b00: AluOperation = 3'b100; // add
            2'b01: AluOperation = 3'b101; // sub
        endcase    
    end

endmodule