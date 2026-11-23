`default_nettype none
// mux: (NOT s1 AND NOT s0 AND d0) OR (NOT s1 AND s0 AND d1) OR (s1 AND NOT s0 AND d2) OR (s1 AND s0 AND d3)

// ports: 
// d0, d1, d2, d3: 4 data inputs 
// s0, s1: 2 selector inputs deciding which data input of the four should pass on.
// y: output 

// Behaviour:
// y: d reaches y for each select value, with s1 as the high bit.

// Edge cases:
// if any of the selector is x then output will be unreliable
// eg: s1 = x, s0 = 0
// 0,0 = d0
// 1,0 = d2

module four_one_mux(
    input wire logic s0,
    input wire logic s1, 
    input wire logic d0, 
    input wire logic d1, 
    input wire logic d2, 
    input wire logic d3, 
    output logic y 
);
    assign y = (~s1 & ~s0 & d0) | (~s1 & s0 & d1) | (s1 & ~s0 & d2) | (s1 & s0 & d3);
endmodule
