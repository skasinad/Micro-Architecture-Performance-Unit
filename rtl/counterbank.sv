/*
    counterbank so the counter group for the pmu
    after the mux picks the event for each counter this block is just the actual counters sitting here and counting...
*/

module counterbank #(
    parameter int ncntrs = pmupackage::ncntrs,
    parameter int cdepth = pmupackage::cdepth
) (
    input logic clk,
    input logic rst,
    input logic clear,
    input logic enable,
    input logic sigin[ncntrs-1:0],
    output logic[cdepth-1:0] countout[ncntrs-1:0]
);

    genvar i;
    generate
        for(i = 0; i < ncntrs; i++) begin : cblocks
            counter #(
                .cdepth(cdepth)
            ) c0 (
                .clk(clk),
                .rst(rst),
                .clear(clear),
                .enable(enable),
                .sigevent(sigin[i]),
                .crntcount(countout[i])
            );
        end
    endgenerate

endmodule
