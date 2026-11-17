module tb_dff;
    logic clk = 0;
    logic d, q;
    dff dut (.clk(clk), .d(d), .q(q));

    always #5 clk = ~clk;

    initial begin
        d= 1;
        @(posedge clk);
        #1;
        if(q !== 1) $error("d=%b, q=%b, Expected 1", d, q);
        d = 0;
        @(posedge clk);
        #1;
        if(q !== 0) $error("d=%b, q=%b, Expected 0", d, q);
        $finish;
    end
endmodule