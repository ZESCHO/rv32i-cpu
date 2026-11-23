`default_nettype none
module dff(
    input wire logic clk,
    input wire logic d,
    output logic q
); 
    always_ff @( posedge clk ) 
        q <= d;        

endmodule