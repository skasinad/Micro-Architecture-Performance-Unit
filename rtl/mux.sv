/*
    mux.sv
    event select block for PMU v2.
    
    each counter gets a select value and this picks which... input event that counter should see
*/

module mux #(
    parameter int tevents = pmupackage::tevents,
    parameter int ncntrs  = pmupackage::ncntrs,
    parameter int eselw = $clog2(tevents)
) (
    input logic[tevents-1:0] sigs,
    output logic[ncntrs-1:0] sigout,

    input logic[eselw-1:0] evsel [ncntrs-1:0]
);

    int i;
    always_comb begin
        for(i = 0; i < ncntrs; i++) begin
            sigout[i] = sigs[evsel[i]];
        end
    end

endmodule
