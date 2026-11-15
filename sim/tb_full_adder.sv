module tb_full_adder;
    logic a, b, cin, s, cout;

    full_adder dut (.a(a), .b(b), .cin(cin), .s(s), .cout(cout));

    initial begin
        for (int i = 0; i < 8; i++) begin
            {a, b, cin} = i;
            #1;
            if({cout, s} !== a + b + cin)
            $error("a=%b, b=%b, cin=%b, s=%b, cout=%b", a, b, cin, s, cout);
        end
        $finish;
    end
endmodule