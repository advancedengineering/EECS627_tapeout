module counter1
#(
    parameter BIT_WIDTH=2
)
(
    input clk,
    input rstn,
    input inc,
    input logic [BIT_WIDTH-1:0] max_count,
    //input new_inst,
    output overflow,
    output logic [BIT_WIDTH-1:0] out
);

always_ff @(posedge clk or negedge rstn) begin
    if(!rstn)
        out <= 0;
    else begin
	    //if ((inc&&overflow) || new_inst) out<=0;
        if ((inc&&overflow) ) out<=0;
	    else if (inc) out<=out+1;
	    else out <= out;
    end
end

assign overflow=(max_count==out);
endmodule
