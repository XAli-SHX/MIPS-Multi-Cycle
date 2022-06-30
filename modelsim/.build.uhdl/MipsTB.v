module MipsTB ();
    reg clkk = 0, rstt, strt = 0;

    localparam CLOCK_PERIOD = 10;
    always #(CLOCK_PERIOD/2) clkk = ~clkk;


    Mips UUT1 (.Clk(clkk), .Rst(rstt), .Start(strt));
    
    initial begin
        #1 rstt = 1'b1;
        #10 rstt = 1'b0;
        #2 strt = 1'b1;
        $display(
            "mem[0] = %b", 
            UUT1.DP.Mem.mem[0]
        );
        #600 $stop;
    end
endmodule