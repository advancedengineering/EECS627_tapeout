module shifter_reg
(
    input  in,
    input clk,
    input rstn,
    output logic delay_4,
    output logic delay_8
);
logic [7:0] shift;
always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        shift<=0;
    end
    else 
        shift<={shift[6:0],in};
end
assign delay_4=shift[3];
assign delay_8=shift[7];
endmodule