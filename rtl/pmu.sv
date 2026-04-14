/*
    welcome to pmu.sv, the CORE pmu block for where the project is right now
    event signals come in, mux chooses what each counter sees... then the counter bank does the actual counting
*/

module pmu #(
    parameter int tevents = pmupackage::tevents,
    parameter int ncntrs = pmupackage::ncntrs,
    parameter int cdepth = pmupackage::cdepth
) (
    input logic clk,
    input logic rst,
    input logic clear,
    input logic enable,
    input logic[tevents-1:0] sigs,
    input logic[$clog2(tevents)-1:0] evsel[ncntrs-1:0],
    output logic[ncntrs*cdepth-1:0] countout
);

    logic[ncntrs-1:0] sigpicked;

    mux #(
        .tevents(tevents),
        .ncntrs(ncntrs)
    ) eventmux (
        .sigs(sigs),
        .evsel(evsel),
        .sigout(sigpicked)
    );


    counterbank #(
        .ncntrs(ncntrs),
        .cdepth(cdepth)
    ) cntbank (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .sigin(sigpicked),
        .countout(countout)
    );

endmodule
