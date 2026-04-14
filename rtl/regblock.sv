/*
    first pass of the pmu register block keeping it simple right now
    ctrl reg, event select regs, and counter reads back out


    clear is being done like a pulse here essentially bc that just felt easier for now than making it a sticky bit and then
    figuring out when to clear the clear bit again
*/

module regblock #(
    parameter int ncntrs = pmupackage::ncntrs,
    parameter int cdepth = pmupackage::cdepth,
    parameter int apb_dw = pmupackage::apb_dw,
    parameter int apb_aw = pmupackage::apb_aw,
    parameter int eselw  = pmupackage::eselw
) (
    input logic clk,
    input logic rst,

    input logic psel,
    input logic penable,
    input logic pwrite,
    input logic[apb_aw-1:0] paddr,
    input logic[apb_dw-1:0] pwdata,


    output logic[apb_dw-1:0] prdata,
    output logic pready,
    output logic pslverr,

    output logic pmuen,
    output logic clear,
    output logic[eselw-1:0] evsel[ncntrs-1:0],
    input logic[ncntrs*cdepth-1:0] countout
);

    int i;
    always_ff @(posedge clk) begin
        if(rst) begin
            pmuen <= 1'b0;
            clear <= 1'b0;
            for(i = 0; i < ncntrs; i++) begin
                evsel[i] <= i[eselw-1:0];
            end
        end else begin
            clear <= 1'b0;

            if(psel && penable && pwrite) begin
                case(paddr)
                    pmupackage::ctrlreg: begin
                        pmuen <= pwdata[pmupackage::enbit];
                        if(pwdata[pmupackage::clearbit])
                            clear <= 1'b1;
                    end


                    pmupackage::evsel0: evsel[0] <= pwdata[eselw-1:0];
                    pmupackage::evsel1: evsel[1] <= pwdata[eselw-1:0];
                    pmupackage::evsel2: evsel[2] <= pwdata[eselw-1:0];
                    pmupackage::evsel3: evsel[3] <= pwdata[eselw-1:0];
                    default: begin //if add does not match writable PMU do nothing!!!
                    end
                endcase
            end
        end
    end



    always_comb begin
        prdata = '0;
        case(paddr)
            pmupackage::ctrlreg: begin
                prdata[pmupackage::enbit] = pmuen;
                prdata[pmupackage::clearbit] = 1'b0;
            end

            pmupackage::evsel0: prdata[eselw-1:0] = evsel[0];
            pmupackage::evsel1: prdata[eselw-1:0] = evsel[1];
            pmupackage::evsel2: prdata[eselw-1:0] = evsel[2];
            pmupackage::evsel3: prdata[eselw-1:0] = evsel[3];
            pmupackage::count0: prdata[cdepth-1:0] = countout[0*cdepth +: cdepth];
            pmupackage::count1: prdata[cdepth-1:0] = countout[1*cdepth +: cdepth];
            pmupackage::count2: prdata[cdepth-1:0] = countout[2*cdepth +: cdepth];
            pmupackage::count3: prdata[cdepth-1:0] = countout[3*cdepth +: cdepth];

            default: prdata = '0;
        endcase
    end

    always_comb begin
        pready = 1'b1;
        pslverr = 1'b0;
        if(psel && penable) begin
            case(paddr)
                pmupackage::ctrlreg,
                pmupackage::evsel0,
                pmupackage::evsel1,
                pmupackage::evsel2,
                pmupackage::evsel3,
                pmupackage::count0,
                pmupackage::count1,
                pmupackage::count2,
                pmupackage::count3: pslverr = 1'b0;
                default: pslverr = 1'b1;
            endcase
        end
    end

endmodule
