/*
    counter.sv

    same counter from v1 basically keeping clear here too so later the pmu can zero out
    counters without needing a full reset
*/

module counter #(
    parameter int cdepth = pmupackage::cdepth
) (
    input logic clk,
    input logic rst,
    input logic clear,
    input logic enable,
    input logic sigevent,
    output logic[cdepth-1:0] crntcount
);

    always_ff @(posedge clk) begin
        if(rst || clear) begin
            crntcount <= '0;
        end else if(enable && sigevent) begin
            if(crntcount != '1)
                crntcount <= crntcount + 1'b1;
        end
    end

endmodule
