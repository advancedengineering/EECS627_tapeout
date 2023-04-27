import DEFINE_PKG::*;
module SA (
    input clk,
    input reset,// low activate
    input [`DIMENSION-1:0] load_weight,// load weight enable: first row(0), last row(N-1)
    input out_model, //two case: high for 4*4, low for 2*2
    input PE_enable, //if 1, work; if 0, stop load weight and compute
    input is_signed,
    input [`DIMENSION-1:0] [`SA_OUTPUT_WIDTH-1:0] input_top,// [11:0]
    input [`DIMENSION-1:0] [`BIT_WIDTH-1:0] input_left, //input from shifter
    output logic [`DIMENSION-1:0] [`SA_OUTPUT_WIDTH-1:0] out_bot,
    output logic [`DIMENSION-1:0] [`BIT_WIDTH-1:0] out_right 
);

logic [`BIT_WIDTH-1:0] hori_wires [`DIMENSION-1:0][`DIMENSION-2:0];// horizaton wire: dimension * (dimension - 1)
logic [`SA_OUTPUT_WIDTH-1:0] ver_wires [`DIMENSION-2:0][`DIMENSION-1:0];// vertical wire: (dimension - 1) * dimension




generate
   for (genvar i = 0; i < `DIMENSION; ++i)begin : gen_sa_row
      for (genvar j = 0; j < `DIMENSION; ++j)begin : gen_sa_col
         if (i == 0)begin
            if (j == 0)begin //SA[0][0]
               PE  PE_ij (
                  .clk(clk), .reset(reset),
                  .load_weight(load_weight[i]), .out_model(out_model),
                  .PE_enable(PE_enable),
                  .is_signed(is_signed),
                  .input_left(input_left[i]), .input_top(input_top[j]),
                  .out_bot(ver_wires[i][j]), .out_right(hori_wires[i][j])
               );
            end else if (j == `DIMENSION-1) begin //SA[0][N-1]
               PE  PE_ij (
                  .clk(clk), .reset(reset),
                  .load_weight(load_weight[i]), .out_model(out_model),
                  .PE_enable(PE_enable),
                  .is_signed(is_signed),
                  .input_left(hori_wires[i][j-1]), .input_top(input_top[j]),
                  .out_bot(ver_wires[i][j]), .out_right(out_right[i])
               );
            end else begin //SA[0][1:N-2]
               PE  PE_ij (
                  .clk(clk), .reset(reset),
                  .load_weight(load_weight[i]), .out_model(out_model),
                  .PE_enable(PE_enable),
                  .is_signed(is_signed),
                  .input_left(hori_wires[i][j-1]), .input_top(input_top[j]),
                  .out_bot(ver_wires[i][j]), .out_right(hori_wires[i][j])
               );
            end      
         end else if (i == `DIMENSION-1) begin
               if (j == 0)begin //SA[N-1][0]
               PE  PE_ij (
                  .clk(clk), .reset(reset),
                  .load_weight(load_weight[i]), .out_model(out_model),
                  .PE_enable(PE_enable),
                  .is_signed(is_signed),
                  .input_left(input_left[i]), .input_top(ver_wires[i-1][j]),
                  .out_bot(out_bot[j]), .out_right(hori_wires[i][j])
               );
            end else if (j == `DIMENSION-1) begin //SA[N-1][N-1]
               PE  PE_ij (
                  .clk(clk), .reset(reset),
                  .load_weight(load_weight[i]), .out_model(out_model),
                  .PE_enable(PE_enable),
                  .is_signed(is_signed),
                  .input_left(hori_wires[i][j-1]), .input_top(ver_wires[i-1][j]),
                  .out_bot(out_bot[j]), .out_right(out_right[i])
               );
            end else begin //SA[N-1][1:N-2]
               PE  PE_ij (
                  .clk(clk), .reset(reset),
                  .load_weight(load_weight[i]), .out_model(out_model),
                  .PE_enable(PE_enable),
                  .is_signed(is_signed),
                  .input_left(hori_wires[i][j-1]), .input_top(ver_wires[i-1][j]),
                  .out_bot(out_bot[j]), .out_right(hori_wires[i][j])
               );
            end                  
         end else if (j == 0) begin //SA[1:N-2][0]
               PE  PE_ij (
               .clk(clk), .reset(reset),
               .load_weight(load_weight[i]), .out_model(out_model),
               .PE_enable(PE_enable),
               .is_signed(is_signed),
               .input_left(input_left[i]), .input_top(ver_wires[i-1][j]),
               .out_bot(ver_wires[i][j]), .out_right(hori_wires[i][j])
               );
         end else if (j == `DIMENSION-1) begin //SA[1:N-2][N-1]
               PE  PE_ij (
               .clk(clk), .reset(reset),
               .load_weight(load_weight[i]), .out_model(out_model),
               .PE_enable(PE_enable),
               .is_signed(is_signed),
               .input_left(hori_wires[i][j-1]), .input_top(ver_wires[i-1][j]),
               .out_bot(ver_wires[i][j]), .out_right(out_right[i])
               );
         end else begin //SA[1][1:N-2:N-2]
               PE  PE_ij (
               .clk(clk), .reset(reset),
               .load_weight(load_weight[i]), .out_model(out_model),
               .PE_enable(PE_enable),
               .is_signed(is_signed),
               .input_left(hori_wires[i][j-1]), .input_top(ver_wires[i-1][j]),
               .out_bot(ver_wires[i][j]), .out_right(hori_wires[i][j])
               );
         end      
         
      end
   end
endgenerate
endmodule