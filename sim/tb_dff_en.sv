`default_nettype none
module tb_dff_en;
    logic clk = 0;
    logic d, q, rst, en;

    dff_en dut (.clk(clk), .d(d), .q(q), .rst(rst), .en(en));

    always #5 clk = ~clk;

    initial begin
        rst = 1; en = 1; d = 1;
        @(posedge clk);
        #1;
        if(q !== 0) $error("d=%b, q=%b, rst=%b, en=%b, Expected 0", d, q, rst, en);

        rst = 0; en = 1; d = 1;
        @(posedge clk);
        #1;
        if(q !== 1) $error("d=%b, q=%b, rst=%b, en=%b, Expected 1", d, q, rst, en);

        en = 0; d = 0;
        @(posedge clk);
        #1;
        if(q !== 1) $error("d=%b, q=%b, rst=%b, en=%b, Expected 1", d, q, rst, en);

        en = 1; d = 0;
        @(posedge clk);
        #1;         
        if(q !== 0) $error("d=%b, q=%b, rst=%b, en=%b, Expected 0", d, q, rst, en);

        $finish;
    end 
endmodule