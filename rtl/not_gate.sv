`default_nettype none
// y = NOT a

module not_gate (       
    input wire logic a,      
    output logic y       
);                       
    assign y = ~a;       
endmodule