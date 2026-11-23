`default_nettype none
module tb_dff_rst;
    logic clk = 0;
    logic d, q, rst;
    
    dff_rst dut (.clk(clk), .d(d), .q(q), .rst(rst));

    always #5 clk = ~clk;

    initial begin
        rst = 1; d = 1;
        @(posedge clk);
        #1;
        if(q !== 0) $error("d=%b, q=%b, rst=%b, Expected 0", d, q, rst);

        rst = 0; d = 1;
        @(posedge clk);
        #1;
        if(q !== 1) $error("d=%b, q=%b, rst=%b, Expected 1", d, q, rst);

        rst = 1;
        #2;
        if(q !== 1) $error("d=%b, q=%b, rst=%b, Expected 1", d, q, rst);
        @(posedge clk);
        #1;
        if(q !== 0) $error("d=%b, q=%b, rst=%b, Expected 0", d, q, rst);
        $finish;
    end

endmodule