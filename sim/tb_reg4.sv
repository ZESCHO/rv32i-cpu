`default_nettype none
module tb_reg4;
    logic clk = 0;
    logic rst, en;
    logic [3:0] d, q;

    reg4 dut (.clk(clk), .rst(rst), .en(en), .d(d), .q(q));

    always #5 clk = ~clk;

    initial begin
        rst = 1; en = 1; d = 4'b1010;
        @(posedge clk);
        #1;
        if(q !== 4'b0000) $error("d=%b, q=%b, rst=%b, en=%b, Expected 0000", d, q, rst, en);

        rst = 0; en = 1; d = 4'b1010;
        @(posedge clk);
        #1;
        if(q !== 4'b1010) $error("d=%b, q=%b, rst=%b, en=%b, Expected 1010", d, q, rst, en);

        en = 0; d = 4'b0101;
        @(posedge clk);
        #1;
        if(q !== 4'b1010) $error("d=%b, q=%b, rst=%b, en=%b, Expected 1010", d, q, rst, en);

        en = 1; d = 4'b0101;
        @(posedge clk);
        #1;         
        if(q !== 4'b0101) $error("d=%b, q=%b, rst=%b, en=%b, Expected 0101", d, q, rst, en);

        $finish;
    end
endmodule