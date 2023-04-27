module BitBrick_4bit(
    input [3:0] X,//input
    input [3:0] Y,//weight
    input Sx,Sy,
    input out_model,//1 for 4bit, 0 for 2bit
    output logic [7:0] P
);

logic [5:0] sum_low, sum_mid1, sum_mid2, sum_high;
logic [7:0] D;
logic sign_x, sign_y;

assign sign_x = (out_model) ? 1'b0 : Sx;
assign sign_y = (out_model) ? 1'b0 : Sy ;


BitBrick low (.X2b(X[1:0]), .Y2b(Y[1:0]), .sx(sign_x), .sy(sign_y), .P6b(sum_low));
BitBrick mid1 (.X2b(X[3:2]), .Y2b(Y[1:0]), .sx(Sx), .sy(1'b0), .P6b(sum_mid1));
BitBrick mid2 (.X2b(X[1:0]), .Y2b(Y[3:2]), .sx(1'b0), .sy(Sy), .P6b(sum_mid2));
BitBrick high (.X2b(X[3:2]), .Y2b(Y[3:2]), .sx(Sx), .sy(Sy), .P6b(sum_high));

assign P = (out_model) ? (sum_high << 4) + (sum_mid1 << 2) + (sum_mid2 << 2) + sum_low : {sum_high[3:0],sum_low[3:0]};



 


endmodule
