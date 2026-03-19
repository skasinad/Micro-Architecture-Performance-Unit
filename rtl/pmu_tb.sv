`timescale 1ns/1ps 

module pmu_tb;
parameter int TEVENTS = 4; 
parameter int CDEPTH = 16; 
logic clk; 
logic rst; 
logic enable; 
logic[TEVENTS-1:0] sigs; 
logic[TEVENTS*CDEPTH-1:0] out; 

pmu # (
    .TOTAL_EVENTS(TEVENTS), 
    .COUNTER_DEPTH(CDEPTH)
) dut (
    .clk(clk), 
    .rst(rst), 
    .enable(enable), 
    .signals(sigs), 
    .finalcntr(out)
);
always #5 clk = ~clk; 



//per edge case essentially just 1 test case
initial begin 
    clk = 0; 
    rst = 0; 
    enable = 0; 
    sigs = '0;

    $display("first test: making sure reset is actually able to clear everything");
    @(posedge clk); #1; 
    rst = 1; 
    @(posedge clk); #1; 
    rst = 0; 
    if(out !== '0) begin
        $display("failed! reset is not clearning the output correctly");
    end else begin
        $display("passed! reset is working well"); 
    end

    $display("second test: testing counters as they shouldnt increment when enable is low");
    enable = 0; 
    sigs = 4'b1111; 
    repeat(5) @(posedge clk);
    sigs = 0;
    if(out != '0) begin
        $display("failed! counters are incrementing at enable low"); 
    end else begin
        $display("passed! enable gate is working as usual"); 
    end

    $display("third test: for a single event there should be a single increment in the counter");
    enable = 1; 
    sigs = 4'b0001; 
    @(posedge clk); #1; 
    sigs = '0;
    @(posedge clk); #1; 
    if(out[CDEPTH-1:0] !== 16'd1) begin
        $display("test failed because counter 0 should be 1 but instead it is %0d", out[CDEPTH-1:0]); 
    end else begin
        $display("test passed singnle event incremeing is working!"); 
    end
    rst = 1; @(posedge clk); #1; rst = 0;
    
    $display("fourth test: for multiple events the counter needs to go to 1");
    enable = 1; 
    sigs = 4'b1111; 
    @(posedge clk); #1; 
    sigs = '0;
    @(posedge clk); #1;
    if(out[CDEPTH-1:0] !== 16'd1 || out[2*CDEPTH-1:CDEPTH] !== 16'd1 || out[3*CDEPTH-1:CDEPTH*2] !== 16'd1 || out[4*CDEPTH-1:CDEPTH*3] !== 16'd1) begin
        $display("test has failed because not all counters are hitting 1"); 
    end else begin
        $display("test passed all counters have increased togehter!"); 
    end
    rst = 1; @(posedge clk); #1; rst = 0;

    $display("fifth test:counters need to be independent when counting");
    enable = 1; 
    sigs = 4'b0100; 
    repeat(3) @(posedge clk);
    sigs = '0;
    @(posedge clk); #1; 
    if(out[3*CDEPTH-1:CDEPTH*2] !== 16'd3) begin
        $display("failed! counter 2 should be 3 but got %0d", out[3*CDEPTH-1:CDEPTH*2]); 
    end else begin
        $display("test passed, counter 2 counted it right!"); 
    end
    if(out[CDEPTH-1:0] !== 16'd0 || out[2*CDEPTH-1:CDEPTH] !== 16'd0 || out[4*CDEPTH-1:CDEPTH*3] !== 16'd0) begin
        $display("failed because the counters are moving when they aren't supposed to");
        $display("counter 0 = %0d | counter 1 = %0d | counter 3 = %0d ", out[CDEPTH-1:0], out[2*CDEPTH-1:CDEPTH], out[4*CDEPTH-1:CDEPTH*3]); 
    end else begin
        $display("passed all the other counters stayed at 0"); 
    end

    $display("sixth test: reset needs to work even during the counting");
    enable = 1; 
    sigs = 4'b0011;
    repeat(4) @(posedge clk);
    sigs = '0;
    rst = 1; @(posedge clk); #1; rst = 0;
    @(posedge clk); #1;
    if(out !== '0) begin
        $display("test failed! in the middle of count reset did not clear, result is %h", out);
    end else begin
        $display("passed test!"); 
    end

    $display("test seven: reset and sigevent need to have no issue when in the same cycle");
    enable = 1; 
    rst = 1; 
    sigs = 4'b1111; 
    @(posedge clk);
    rst = 0; 
    sigs = '0;
    @(posedge clk); #1; 
    if(out !== '0) begin
        $display("test failed! rst didnt win over sigevent, got %h", out); 
    end else begin
        $display("test passed because rst priority over sigevent is right"); 
    end

    $display("eight test: counter is supposed to freez when the enable goes low");
    rst = 1; @(posedge clk); #1; rst = 0;
    enable = 1; 
    sigs = 4'b0001;
    repeat(3) @(posedge clk);
    sigs = '0;
    @(posedge clk); #1; //c0 =3
    enable = 0; 
    sigs = 4'b0001; 
    repeat(5) @(posedge clk); //enable low for 5 cycls
    sigs = '0;
    @(posedge clk); #1;
    if(out[CDEPTH-1:0] !== 16'd3) begin
        $display("failed the test! counter moved with enable low and got %0d", out[CDEPTH-1:0]); 
    end else begin
        $display("test passed, counter freezes when enable drops"); 
    end 
    $finish;      
end

endmodule