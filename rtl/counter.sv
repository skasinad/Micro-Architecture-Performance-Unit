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

endmodule 