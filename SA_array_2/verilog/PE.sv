//PE unit for non-first row of SA
module PE#(
    parameter BIT_WIDTH = 4
)(
    input clk,
    input reset,
    input load_weight,
    input out_model, //two case: high for 4*4, low for 2*2
    input PE_enable, //if 1, work; if 0, stop load weight and compute
    input is_signed,//signed:1, unsigned:0
    input [3*BIT_WIDTH-1:0] input_top,// input_top:[11:0]
    input [BIT_WIDTH-1:0] input_left, //2bit model: [1:0] x11, [3:2] x12
    output logic [3*BIT_WIDTH-1:0] out_bot,
    output logic [BIT_WIDTH-1:0] out_right
);

logic [BIT_WIDTH-1:0] weight;// 1. weight stationary SA array, store weight in PE when load weight; 2. 2bit model:[1:0] w11, [3:2] w21
logic [2*BIT_WIDTH-1:0] mult_pro;

BitBrick_4bit mult_1 (.X(input_left[3:0]), .Y(weight[3:0]), .Sx(is_signed), .Sy(is_signed), .out_model(out_model), .P(mult_pro[2*BIT_WIDTH-1:0]));

// mult process using bitbrick
always @(posedge clk or negedge reset)
if (~reset) begin
    out_bot <=  0;
    out_right <= 0;
    weight <= 0;
end  else if (PE_enable) begin
    if (load_weight == 1) begin//load weight
        weight <= input_left;
        out_bot <= 0;
    end else begin// mult
        if (out_model) begin //4bit * 4bit
            //4bit accumulator
            if (is_signed) begin
                out_bot <= input_top + {{BIT_WIDTH{mult_pro[2*BIT_WIDTH-1]}},mult_pro};//sign extension
            end
            else begin
                out_bot <= input_top + mult_pro;
            end
        end else begin//2bit
            //2bit accumulator
            if (is_signed) begin
                out_bot <= input_top + {{2*BIT_WIDTH{mult_pro[2*BIT_WIDTH-1]}},mult_pro[2*BIT_WIDTH-1:BIT_WIDTH]} + {{2*BIT_WIDTH{mult_pro[BIT_WIDTH-1]}},mult_pro[BIT_WIDTH-1:0]};//sign extension
            end
            else begin
                out_bot <= input_top + mult_pro[2*BIT_WIDTH-1:BIT_WIDTH] + mult_pro[BIT_WIDTH-1:0];
            end
        end
    end
    out_right <= input_left;//input pass in horizontal direction
end else begin
    weight <= weight;
    out_bot <= out_bot;
    out_right <= out_right;
end



endmodule

