`default_nettype none
//y = a XOR b

module xor_gate (
    input wire logic a,
    input wire logic b,
    output logic y
);
    assign y = a ^ b;
endmodule