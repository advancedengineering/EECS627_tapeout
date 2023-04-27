// PE unit for first row of SA
module PE1#(
    parameter BIT_WIDTH = 4,
    parameter ROW_INDEX = 0
)(
    input clk,
    input reset,
    input load_weight,
    input out_model, //two case: 4*4, 2*2
    input Sx,
    input Sy,
    input [2*BIT_WIDTH-1:0] input_top,
    input [BIT_WIDTH-1:0] input_left,
    output logic [2*BIT_WIDTH-1:0] out_bot,
    output logic [BIT_WIDTH-1:0] out_right
);

logic [BIT_WIDTH-1:0] weight;// weight stationary SA array, store weight in PE when load weight
logic [2*BIT_WIDTH-1:0] mult_pro;

BitBrick_4bit mult_1 (.clk(clk), .reset(reset), .X(input_left[3:0]), .Y(weight[3:0]), .Sx(Sx), .Sy(Sy), .out_model(out_model), .P(mult_pro[7:0]));
// mult process using bitbrick
always @(posedge clk or negedge reset)
if (~reset) begin
    out_bot <=  0;
    out_right <= 0;
    weight <= 0;
end  else begin
    if (load_weight == 1) begin//load weight
        weight <= input_left;
        out_bot <= 0;
    end else begin// mult
        out_bot <= input_top + mult_pro;
    end
out_right <= input_left;//input pass in horizontal direction
end




endmodule