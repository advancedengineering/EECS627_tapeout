module shifter_reg_4bits
(
    input [3:0] in,
    input clk,
    input rstn,
    output logic [(`SA_NUM-1)*4-1:0] [3:0] shift 
);
always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        for(int i=0; i<=(`SA_NUM-1)*4-1; i++) begin
            shift[i]<=0;
        end
    end
    else begin
        for(int i=0; i<=(`SA_NUM-1)*4-1 ; i++) begin
            if(i==0)
                shift[0]<=in;
            else
                shift[i]<=shift[i-1];
        end
    end
end
endmodule