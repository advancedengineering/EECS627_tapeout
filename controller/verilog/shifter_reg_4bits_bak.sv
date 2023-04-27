module shifter_reg_4bits
(
    input [3:0] in,
    input clk,
    input rstn,
    output logic [3:0] delay_4,
    output logic [3:0] delay_8
);
logic [3:0] shift [7:0];
always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        for(int i=0; i<=7; i++) begin
            shift[i]<=0;
        end
    end
    else begin
        shift[7]<=shift[6];
        shift[6]<=shift[5];
        shift[5]<=shift[4];
        shift[4]<=shift[3];
        shift[3]<=shift[2];
        shift[2]<=shift[1];
        shift[1]<=shift[0];
        shift[0]<=in;
    end
end
assign delay_4=shift[3];
assign delay_8=shift[7];
endmodule