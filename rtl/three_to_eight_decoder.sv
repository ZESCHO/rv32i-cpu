`default_nettype none
module three_to_eight_decoder(

    input wire logic a,
    input wire logic b,
    input wire logic c,
    output logic y7,
    output logic y6,
    output logic y5,
    output logic y4,
    output logic y3,
    output logic y2,
    output logic y1,
    output logic y0
);

    assign y0 = ~a & ~b & ~c;
    assign y1 = ~a & ~b & c;
    assign y2 = ~a & b & ~c;
    assign y3 = ~a & b & c;
    assign y4 = a & ~b & ~c;
    assign y5 = a & ~b & c;
    assign y6 = a & b & ~c;
    assign y7 = a & b & c;

endmodule