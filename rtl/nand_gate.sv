`default_nettype none
// y = a NAND b

module nand_gate (
    input wire logic a,
    input wire logic b,
    output logic y
);
    assign y = ~(a & b);
endmodule