module tb_nor_gate;
    logic a, b, y;
    
    nor_gate dut (.a(a), .b(b), .y(y));

    initial begin
        a = 0; b = 0; #1;
        if(y !== 1) $error("a=0, b=0: want 1, got %b", y);
        a = 0; b = 1; #1;
        if(y !== 0) $error("a=0, b=1: want 0, got %b", y);
        a = 1; b = 0; #1;
        if(y !== 0) $error("a=1, b=0: want 0, got %b", y);
        a = 1; b = 1; #1;
        if(y !== 0) $error("a=1, b=1: want 0, got %b", y);
        $finish;
    end
    
endmodule