module tb_adder;

    logic [3:0] a, b, sum;
    logic cin, cout;
    adder dut(.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    initial begin
        for (int i = 0; i < 512 ; i++) begin
            {a, b, cin} = i;
            #1;
            if({cout, sum} !== a + b + cin) 
            $error("a=%b, b=%b, cin=%b, sum=%b, cout=%b", a, b, cin, sum, cout);     
        end
        $finish;
    end
endmodule