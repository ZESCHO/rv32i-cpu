`default_nettype none
// y = a OR b

module or_gate(
    input wire logic a,
    input wire logic b,
    output logic y
);

    assign y = a | b;
endmodule
