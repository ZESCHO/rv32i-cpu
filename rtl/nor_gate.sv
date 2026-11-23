`default_nettype none
//y = a NOR b

module nor_gate(
	input wire logic a,
	input wire logic b,
	output logic y
);
	assign y = ~(a | b);
endmodule
