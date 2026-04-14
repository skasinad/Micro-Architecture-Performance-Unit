/*
    this is pmu_core_tb.sv just testing the core pmu path right now before getting into
    the reg block stuff... i want to see all of it kind of come together also....
    wanted to make sure select logic + counting path is doing what its supposed to do first so yeah
*/

module pmu_core_tb;

    parameter int tevents = pmupackage::tevents;
    parameter int ncntrs  = pmupackage::ncntrs;
    parameter int cdepth  = pmupackage::cdepth;
    parameter int eselw   = pmupackage::eselw;
    logic clk;
    logic rst;
    logic clear;
    logic enable;
    logic [tevents-1:0] sigs;
    logic [eselw-1:0] evsel [ncntrs-1:0];
    logic [ncntrs*cdepth-1:0] countout;

    pmu #(
        .tevents(tevents),
        .ncntrs(ncntrs),
        .cdepth(cdepth)
    ) dut (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .sigs(sigs),
        .evsel(evsel),
        .countout(countout)
    );

    always #5 clk = ~clk;
    task automatic check_cnt(input int idx, input int exp);
        begin
            if(countout[idx*cdepth +: cdepth] !== exp[cdepth-1:0]) begin
                $display("fail: counter %0d expected %0d got %0d", idx, exp, countout[idx*cdepth +: cdepth]);
                $fatal;
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 0;
        clear = 0;
        enable = 0;
        sigs = '0;
        evsel[0] = 0;
        evsel[1] = 1;
        evsel[2] = 2;
        evsel[3] = 3;

        $display("test 1 reset should be clear everything...");
        rst = 1;
        @(posedge clk);
        #1;
        rst = 0;
        check_cnt(0, 0);
        check_cnt(1, 0);
        check_cnt(2, 0);
        check_cnt(3, 0);


        $display("test 2 enable low means no counting");
        sigs = 16'hffff;
        enable = 0;
        repeat(3) @(posedge clk);
        #1;
        check_cnt(0, 0);
        check_cnt(1, 0);
        check_cnt(2, 0);
        check_cnt(3, 0);
        sigs = '0;


        $display("Test 3 now so each counter should follow its own selected event instead!!! COME ON");
        enable = 1;
        sigs = '0;
        sigs[0] = 1'b1;
        sigs[2] = 1'b1;
        @(posedge clk);
        #1;
        sigs = '0;
        check_cnt(0, 1);
        check_cnt(1, 0);
        check_cnt(2, 1);
        check_cnt(3, 0);


        $display("test 4: one counter can be pointed somewhere else");
        evsel[1] = 4;
        sigs = '0;
        sigs[4] = 1'b1;
        repeat(2) @(posedge clk);
        #1;
        sigs = '0;
        check_cnt(0, 1);
        check_cnt(1, 2);
        check_cnt(2, 1);
        check_cnt(3, 0);


        $display("fifth test - clear should zero all counters");
        clear = 1;
        @(posedge clk);
        #1;
        clear = 0;
        check_cnt(0, 0);
        check_cnt(1, 0);
        check_cnt(2, 0);
        check_cnt(3, 0);

        $display("6th: counting again after clear");
        sigs = '0;
        evsel[0] = 5;
        evsel[1] = 6;
        evsel[2] = 7;
        evsel[3] = 8;
        sigs[5] = 1'b1;
        sigs[8] = 1'b1;
        repeat(3) @(posedge clk);
        #1;
        sigs = '0;
        check_cnt(0, 3);
        check_cnt(1, 0);
        check_cnt(2, 0);
        check_cnt(3, 3);
        $display("test 7 reset still wins");
        sigs[5] = 1'b1;
        rst = 1;
        @(posedge clk);
        #1;
        rst = 0;
        sigs = '0;
        check_cnt(0, 0);
        check_cnt(1, 0);
        check_cnt(2, 0);
        check_cnt(3, 0);

        $display("all core pmu tests have passed, datapath works :)");
        $finish;
    end

endmodule
