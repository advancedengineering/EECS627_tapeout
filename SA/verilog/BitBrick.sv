module BitBrick(
    input [1:0] X2b,
    input [1:0] Y2b,
    input sx,
    input sy,
    output [5:0] P6b
);

    logic [2:0] X3b;
    logic [2:0] Y3b;
    assign X3b[1:0] = X2b;
    assign Y3b[1:0] = Y2b;
    assign X3b[2] = sx & X2b[1];
    assign Y3b[2] = sy & Y2b[1];

    // Start multiply
    assign P6b[0] = X3b[0] & Y3b[0];
    logic [1:0] ha_1;
    assign ha_1[0] = X3b[0] & Y3b[1];
    assign ha_1[1] = X3b[1] & Y3b[0];
    logic c1;
    half_adder ha1 (.A(ha_1[1]), .B(ha_1[0]), .sum(P6b[1]), .Cout(c1));

    logic [1:0] fa_1;
    assign fa_1[0] = X3b[1] & Y3b[1];
    assign fa_1[1] = ~(X3b[0] & Y3b[2]);
    logic c2, s1;
    full_adder fa1 (.A(fa_1[1]), .B(fa_1[0]), .Cin(c1), .sum(s1), .Cout(c2));
    logic ha_2;
    assign ha_2 = ~(X3b[2] & Y3b[0]);
    logic c3;
    half_adder ha2 (.A(ha_2), .B(s1), .sum(P6b[2]), .Cout(c3));

    logic [1:0] fa_2;
    assign fa_2[0] = ~(X3b[2] & Y3b[1]);
    assign fa_2[1] = ~(X3b[1] & Y3b[2]);
    logic c4, s2;
    full_adder fa2 (.A(fa_2[1]), .B(fa_2[0]), .Cin(c2), .sum(s2), .Cout(c4));
    logic c5;
    //half_adder ha3 (.A(s2), .B(c3), .sum(P6b[3]), .Cout(c5));
    full_adder fa4 (.A(s2), .B(1'b1), .Cin(c3), .sum(P6b[3]), .Cout(c5));
    logic fa_3;
    assign fa_3 = X3b[2] & Y3b[2];
    logic sh, shi;
    full_adder fa3 (.A(fa_3), .B(c4), .Cin(c5), .sum(P6b[4]), .Cout(sh));
    half_adder ha3 (.A(sh), .B(1'b1), .sum(P6b[5]), .Cout(shi));
    
   
endmodule // mult

module full_adder (
    input A, 
    input B, 
    input Cin,
    output sum, 
    output Cout
);

    assign sum = A ^ B ^ Cin;
    assign Cout = (A & B) | (A & Cin) | (B & Cin);
endmodule

module half_adder (
    input A, 
    input B, 
    output sum, 
    output Cout
);

    assign sum = A ^ B;
    assign Cout = A & B;
endmodule


