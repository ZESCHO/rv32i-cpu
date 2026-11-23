`default_nettype none
module tb_four_one_mux;
    logic s0, s1, d0, d1, d2, d3, y, expected;

    four_one_mux dut (.s0(s0), .s1(s1), .d0(d0), .d1(d1), .d2(d2), .d3(d3), .y(y));

    initial begin
        for(int i = 0; i < 64; i++) begin
            {s1, s0, d0, d1, d2, d3} = i;
            #1;
            if(s1 == 0 && s0 == 0) expected = d0;
            else if(s1 == 0 && s0 == 1) expected = d1;
            else if(s1 == 1 && s0 == 0) expected = d2;
            else if(s1 == 1 && s0 == 1) expected = d3;
            if(y!==expected)
            $error("s0=%b, s1=%b, d0=%b, d1=%b, d2=%b, d3=%b, y=%b", s0, s1, d0, d1, d2, d3, y);
        end
        $finish;
    end
endmodule