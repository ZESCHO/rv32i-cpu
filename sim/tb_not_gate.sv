module tb_not_gate;            
    logic a, y;                   

    not_gate dut (.a(a), .y(y)); 

    initial begin                 
        a = 0; #1;               
        if (y !== 1) $error("a=0: want 1, got %b", y);
        a = 1; #1;
        if (y !== 0) $error("a=1: want 0, got %b", y);
        $finish;                 
    end
endmodule