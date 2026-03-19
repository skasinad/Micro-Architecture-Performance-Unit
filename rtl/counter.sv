module counter#(
    parameter int DEPTH = 16 //16 bits long 
)(
    input logic clk, 
    input logic rst, 
    input logic enable, 
    input logic sigevent, 
    output logic[DEPTH-1:0] crntcount
);
    always_ff @(posedge clk) begin 
        if(rst) begin
            crntcount <= '0; 
        end else if (enable && sigevent) begin
            if(crntcount != '1) begin 
                crntcount <= crntcount + 1;
            end 
        end 
    end
    //making sure counter never goes past max value ever
    `ifndef SYNTHESIS 
    always @(posedge clk) begin
        if(!rst) begin
            assert(crntcount <= '1)
            else $display("broo assertion failed!! counter went over max value look %0d", crntcount); 
        end  
    end
    //if rst was high in the last cycle crntcount needs to be 0 rn
    always @(posedge clk) begin 
        if($past(rst) == 1) begin
            assert(crntcount == '0)
            else $display("assertion failed again..... rst was high but counter didnt clear and got %0d", crntcount); 
        end 
    end

    //cntr shouldnt move at all when enable is low 
    always @(posedge clk) begin
        if(!enable && !rst) begin
            assert(crntcount == $past(crntcount))
            else $display("assertion failed bc counter changed when enable was low, was %0d and now %0d", $past(crntcount), crntcount); 
        end  
    end

    //when already at max and sigevent fires it needs to stay at max not wrap
    always @(posedge clk) begin
        if($past(crntcount) == '1 && $past(sigevent) && $past(enable) && !rst) begin
            assert(crntcount == '1)
            else $display("again the assertion failed!!!!!!!!! counter wrapped around instead of staying at max");
        end 
    end
    `endif      

endmodule 