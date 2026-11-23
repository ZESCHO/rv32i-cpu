`default_nettype none
module tb_three_to_eight_decoder;
    logic a, b, c, y0, y1, y2, y3, y4, y5, y6, y7;

    three_to_eight_decoder dut (.a(a), .b(b), .c(c), .y0(y0), .y1(y1), .y2(y2), .y3(y3), .y4(y4), .y5(y5), .y6(y6), .y7(y7));

    initial begin
        for (int i = 0; i < 8; i++) begin
            {a, b, c} = i;
            #1;
            if({y7, y6, y5, y4, y3, y2, y1, y0} !== 1 << i)
            $error("a=%b, b=%b, c=%b, y0=%b, y1=%b, y2=%b, y3=%b, y4=%b, y5=%b, y6=%b, y7=%b", a, b, c, y0, y1, y2, y3, y4, y5, y6, y7);
        end
        $finish;
    end
endmodule