module shifter_reg
(
    input  in,
    input clk,
    input rstn,
    output logic [(`SA_NUM-1)*4-1:0] delayed_out
);
always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        delayed_out<=0;
    end
    else 
        delayed_out<={delayed_out[(`SA_NUM-1)*4-2:0],in};
end
endmodule