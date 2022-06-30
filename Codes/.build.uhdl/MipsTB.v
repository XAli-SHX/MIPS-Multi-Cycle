module MipsTB ();
    reg clkk = 0, rstt;

    Mips UUT1 (.Clk(clkk), .Rst(rstt));
    always #17 clkk = ~clkk;
    initial begin
        #5 rstt = 1'b1;
        #23 rstt = 1'b0;
        #6000 $stop;
    end
endmodule