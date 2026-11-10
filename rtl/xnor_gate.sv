//y = a xnor b

module xnor_gate (
    input logic a,
    input logic b,
    output logic y
);
    assign y = ~(a ^ b);
endmodule