`default_nettype none

module tb_counter;
    logic clk = 0;
    logic rst, en;
    logic [3:0] q, expected;

    counter dut (.clk(clk), .rst(rst), .en(en), .q(q));

    always #5 clk = ~clk;

    initial begin

        rst = 1; en = 1; 
        @(posedge clk);
        #1;
        if(q !== 4'b0000) $error("q=%b, rst=%b, en=%b, Expected 0000", q, rst, en);

        rst = 0; expected = 0;
        for(int i = 0; i < 16; i++) begin
            @(posedge clk);
            #1;
            expected = expected + 1;
            if(q !== expected) $error("q=%b, expected=%b", q, expected);
        end

        en = 0;
        @(posedge clk) #1;
        if(q !== 4'b0000) $error("q=%b, expected 0000", q);

        $finish;
    end
endmodule