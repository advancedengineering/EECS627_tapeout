module SA #(
    parameter BIT_WIDTH = 4,
    parameter DIMENSION = 4
)(
    input clk,
    input reset,
    input load_weight_1,// load weight enable for first row
    input load_weight_2,// load weight enable for second row
    input load_weight_3,// load weight enable for thrid row
    input load_weight_4,// load weight enable for fourth row
    input out_model, //two case: high for 4*4, low for 2*2
    input Sx,
    input Sy,
    input [2*BIT_WIDTH-1:0] input_top [DIMENSION-1:0],
    input [BIT_WIDTH-1:0] input_left [DIMENSION-1:0],
    output logic [2*(BIT_WIDTH + DIMENSION -1)-1:0] out_bot [DIMENSION-1:0],
    output logic [BIT_WIDTH-1:0] out_right [DIMENSION-1:0]
);

logic [BIT_WIDTH-1:0] hori_wires [DIMENSION-1:0][DIMENSION-2:0];// horizaton wire: dimension * (dimension - 1)
// vertical wire: (dimension - 1) * dimension
logic [2*BIT_WIDTH-1:0] ver_wires_row1 [DIMENSION-1:0];//first row
logic [2*BIT_WIDTH+1:0] ver_wires_row2 [DIMENSION-1:0];//second row
logic [2*BIT_WIDTH+3:0] ver_wires_row3 [DIMENSION-1:0];//third row


generate
      for (genvar i = 0; i < DIMENSION; ++i)begin : gen_sa_row
         for (genvar j = 0; j < DIMENSION; ++j)begin : gen_sa_col
            if (i == 0)begin
               if (j == 0)begin //SA[0][0]
                  PE1 #(.BIT_WIDTH(4)) PE_ij (
                    .clk(clk), .reset(reset),
                    .load_weight(load_weight_1), .out_model(out_model),
                    .Sx(Sx), .Sy(Sy),
                    .input_left(input_left[i]), .input_top(input_top[j]),
                    .out_bot(ver_wires_row1[j]), .out_right(hori_wires[i][j])
                  );
               end else if (j == DIMENSION-1) begin //SA[0][N-1]
                  PE1 #(.BIT_WIDTH(4)) PE_ij (
                    .clk(clk), .reset(reset),
                    .load_weight(load_weight_1), .out_model(out_model),
                    .Sx(Sx), .Sy(Sy),
                    .input_left(hori_wires[i][j-1]), .input_top(input_top[j]),
                    .out_bot(ver_wires_row1[j]), .out_right(out_right[i])
                  );
               end else begin //SA[0][1:N-2]
                  PE1 #(.BIT_WIDTH(4)) PE_ij (
                    .clk(clk), .reset(reset),
                    .load_weight(load_weight_1), .out_model(out_model),
                    .Sx(Sx), .Sy(Sy),
                    .input_left(hori_wires[i][j-1]), .input_top(input_top[j]),
                    .out_bot(ver_wires_row1[j]), .out_right(hori_wires[i][j])
                  );
               end      
            end else if (i == DIMENSION-1) begin
                if (j == 0)begin //SA[N-1][0]
                  PE2 #(.BIT_WIDTH(4), .ROW_INDEX(i)) PE_ij (
                    .clk(clk), .reset(reset),
                    .load_weight(load_weight_4), .out_model(out_model),
                    .Sx(Sx), .Sy(Sy),
                    .input_left(input_left[i]), .input_top(ver_wires_row3[j]),
                    .out_bot(out_bot[j]), .out_right(hori_wires[i][j])
                  );
               end else if (j == DIMENSION-1) begin //SA[N-1][N-1]
                  PE2 #(.BIT_WIDTH(4), .ROW_INDEX(i)) PE_ij (
                    .clk(clk), .reset(reset),
                    .load_weight(load_weight_4), .out_model(out_model),
                    .Sx(Sx), .Sy(Sy),
                    .input_left(hori_wires[i][j-1]), .input_top(ver_wires_row3[j]),
                    .out_bot(out_bot[j]), .out_right(out_right[i])
                  );
               end else begin //SA[N-1][1:N-2]
                  PE2 #(.BIT_WIDTH(4), .ROW_INDEX(i)) PE_ij (
                    .clk(clk), .reset(reset),
                    .load_weight(load_weight_4), .out_model(out_model),
                    .Sx(Sx), .Sy(Sy),
                    .input_left(hori_wires[i][j-1]), .input_top(ver_wires_row3[j]),
                    .out_bot(out_bot[j]), .out_right(hori_wires[i][j])
                  );
               end                  
            end else if (i == 1) begin
               if (j == 0) begin //SA[1][0]
                  PE2 #(.BIT_WIDTH(4), .ROW_INDEX(i)) PE_ij (
                  .clk(clk), .reset(reset),
                  .load_weight(load_weight_2), .out_model(out_model),
                  .Sx(Sx), .Sy(Sy),
                  .input_left(input_left[i]), .input_top(ver_wires_row1[j]),
                  .out_bot(ver_wires_row2[j]), .out_right(hori_wires[i][j])
                  );
               end else if (j == DIMENSION-1) begin //SA[1][N-1]
                  PE2 #(.BIT_WIDTH(4), .ROW_INDEX(i)) PE_ij (
                  .clk(clk), .reset(reset),
                  .load_weight(load_weight_2), .out_model(out_model),
                  .Sx(Sx), .Sy(Sy),
                  .input_left(hori_wires[i][j-1]), .input_top(ver_wires_row1[j]),
                  .out_bot(ver_wires_row2[j]), .out_right(out_right[i])
                  );
               end else begin //SA[1][1:N-2]
                  PE2 #(.BIT_WIDTH(4), .ROW_INDEX(i)) PE_ij (
                  .clk(clk), .reset(reset),
                  .load_weight(load_weight_2), .out_model(out_model),
                  .Sx(Sx), .Sy(Sy),
                  .input_left(hori_wires[i][j-1]), .input_top(ver_wires_row1[j]),
                  .out_bot(ver_wires_row2[j]), .out_right(hori_wires[i][j])
                  );
               end      
            end else if (i == 2) begin
               if (j == 0) begin //SA[2][0]
                  PE2 #(.BIT_WIDTH(4), .ROW_INDEX(i)) PE_ij (
                  .clk(clk), .reset(reset),
                  .load_weight(load_weight_3), .out_model(out_model),
                  .Sx(Sx), .Sy(Sy),
                  .input_left(input_left[i]), .input_top(ver_wires_row2[j]),
                  .out_bot(ver_wires_row3[j]), .out_right(hori_wires[i][j])
                  );
               end else if (j == DIMENSION-1) begin //SA[2][N-1]
                  PE2 #(.BIT_WIDTH(4), .ROW_INDEX(i)) PE_ij (
                  .clk(clk), .reset(reset),
                  .load_weight(load_weight_3), .out_model(out_model),
                  .Sx(Sx), .Sy(Sy),
                  .input_left(hori_wires[i][j-1]), .input_top(ver_wires_row2[j]),
                  .out_bot(ver_wires_row3[j]), .out_right(out_right[i])
                  );
               end else begin //SA[2][1:N-2]
                  PE2 #(.BIT_WIDTH(4), .ROW_INDEX(i)) PE_ij (
                  .clk(clk), .reset(reset),
                  .load_weight(load_weight_3), .out_model(out_model),
                  .Sx(Sx), .Sy(Sy),
                  .input_left(hori_wires[i][j-1]), .input_top(ver_wires_row2[j]),
                  .out_bot(ver_wires_row3[j]), .out_right(hori_wires[i][j])
                  );
               end      
            end
         end
      end

   endgenerate
endmodule