`default_nettype none
// y = a AND b

module and_gate(
    input wire logic a,
    input wire logic b,
    output logic y
);

    assign y = a & b;
endmodule

