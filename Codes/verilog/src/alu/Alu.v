module Alu #(
    parameter SIZE = 32
) (
    input [(SIZE-1):0] A, B,
    input [2:0] op,
    output reg [(SIZE-1):0] res, output zero
);
    
    assign zero = ~|res;

    always @(A, B, op) begin
        res = {SIZE{1'bz}};
        case (op)
            3'b000: res = A; // A
            3'b001: res = B; // B
            3'b010: res = ~B; // not B
            3'b100: res = A + B; // Add
            3'b101: res = A - B; // Sub
            3'b110: res = A & B; // And
            3'b111: res = A | B; // Or
            default: res = {SIZE{1'bz}};
        endcase
    end 

endmodule
