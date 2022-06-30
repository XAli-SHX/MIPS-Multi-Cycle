module Memory #(parameter WORD_SIZE = 32, ADDRESS_SIZE = 32) (
    input [(ADDRESS_SIZE-1):0] Address,
    input [(WORD_SIZE-1):0] WriteData,
    input MemRead, MemWrite, clk,
    output reg [(WORD_SIZE-1):0] ReadData
);
    
    reg [15:0] mem [0:5000];

    initial begin
        $readmemb("../Codes/mem/memory.mem", mem);
    end

    assign ReadData = MemRead ? mem[Address] : {WORD_SIZE{1'bZ}};

    always @(posedge clk) begin
        if(MemRead)
            ReadData <= mem[Address];
        else if(MemWrite)
            mem[Address] <= WriteData;        
    end

endmodule