`default_nettype none

module reg4(
    input wire logic clk,
    input wire logic rst,
    input wire logic en,
    input wire logic [3:0] d,
    output logic [3:0] q
); 

    always_ff @( posedge clk ) 
        if(rst)
            q <= 0;
        else if(en)
            q <= d;

endmodule