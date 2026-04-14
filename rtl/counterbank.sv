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
    input logic[ncntrs-1:0] sigin,
    output logic[ncntrs*cdepth-1:0] countout
);

    logic[cdepth-1:0] cnts[ncntrs-1:0];
    int j;

    genvar i;
    generate
        for(i = 0; i < ncntrs; i++) begin:cblocks
            counter #(
                .cdepth(cdepth)
            ) c0 (
                .clk(clk),
                .rst(rst),
                .clear(clear),
                .enable(enable),
                .sigevent(sigin[i]),
                .crntcount(cnts[i])
            );
        end
    endgenerate



    always_comb begin
        for(j = 0; j < ncntrs; j++) begin
            countout[j*cdepth +: cdepth] = cnts[j];
        end
    end

endmodule
