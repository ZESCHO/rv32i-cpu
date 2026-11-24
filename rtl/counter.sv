`default_nettype none

module counter(
    input wire logic clk,
    input wire logic en,
    input wire logic rst,
    output logic [3:0] q
);

    always_ff @( posedge clk ) 
        if(rst)
            q <= 0;
        else if(en)
            q <= q + 1;
endmodule