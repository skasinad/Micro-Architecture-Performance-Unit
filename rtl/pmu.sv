module pmu#(
    parameter int TOTAL_EVENTS = 4,
    parameter int COUNTER_DEPTH = 16
) (
    input logic clk, 
    input logic rst, 
    input logic enable, 
    input logic[TOTAL_EVENTS-1:0] signals, 
    output logic[TOTAL_EVENTS*COUNTER_DEPTH-1:0] finalcntr
);

    logic[COUNTER_DEPTH-1:0] buffer[TOTAL_EVENTS-1:0];
   
   //I need to hook up all the counters now
   genvar i; 
   generate
    for(i = 0; i < TOTAL_EVENTS; i++) begin : genblk
        counter #(
            .DEPTH(COUNTER_DEPTH)
        ) c0 (
            .clk(clk), 
            .rst(rst), 
            .enable(enable), 
            .sigevent(signals[i]),
            .crntcount(buffer[i])
        );
    end 
   endgenerate

   int j; 
   always_comb begin
    for(j = 0; j < TOTAL_EVENTS; j++) begin 
        finalcntr[j*COUNTER_DEPTH +: COUNTER_DEPTH] = buffer[j];
    end 
   end 
    

endmodule 