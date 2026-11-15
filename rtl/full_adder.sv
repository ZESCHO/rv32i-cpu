// sum = a XOR b XOR cin
// cout = (a AND b) OR (b AND cin) OR (cin AND a)

module full_adder(
    input logic a,
    input logic b,
    input logic cin,
    output logic s,
    output logic cout
);
    assign s = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule