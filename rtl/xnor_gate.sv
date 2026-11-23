`default_nettype none
//y = a xnor b

module xnor_gate (
    input wire logic a,
    input wire logic b,
    output logic y
);
    assign y = ~(a ^ b);
endmodule