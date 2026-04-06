/*
    package.sv

    package file for PMU v2.
    just putting the common stuff here for now like widths,
    some typedefs, and the first register addresses.
*/

package pmu_pkg;

    parameter int tevents = 8;
    parameter int ncntrs  = 4;
    parameter int cdepth  = 16;
    parameter int apb_dw  = 32;
    parameter int apb_aw  = 12;

    parameter int eselw = $clog2(tevents);

    typedef logic [cdepth-1:0] cnt_t;
    typedef logic [tevents-1:0] sigs_t;
    typedef logic [eselw-1:0] sel_t;
    typedef logic [ncntrs*cdepth-1:0] cntbus_t;

    localparam logic [apb_aw-1:0] ctrlreg = 12'h000;
    localparam logic [apb_aw-1:0] evsel0 = 12'h010;
    localparam logic [apb_aw-1:0] evsel1 = 12'h014;
    localparam logic [apb_aw-1:0] evsel2 = 12'h018;
    localparam logic [apb_aw-1:0] evsel3 = 12'h01C;
    localparam logic [apb_aw-1:0] count0 = 12'h020;
    localparam logic [apb_aw-1:0] count1 = 12'h024;
    localparam logic [apb_aw-1:0] count2 = 12'h028;
    localparam logic [apb_aw-1:0] count3 = 12'h02C;

    localparam int enbit = 0;
    localparam int clearbit = 1;

endpackage
