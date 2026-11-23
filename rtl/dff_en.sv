`default_nettype none

module dff_en(
    input wire logic clk,
    input wire logic rst,
    input wire logic en,
    input wire logic d,
    output logic q
); 

    always_ff @( posedge clk ) 
        if(rst)
            q <= 0;
        else if(en)
            q <= d;

endmodule