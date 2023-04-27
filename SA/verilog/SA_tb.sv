module SA_tb;

logic clk, reset, out_model, load_weight;
logic Sx, Sy;

logic [7:0] input_top [3:0];
logic [3:0] input_left [3:0];

//out
logic [13:0] out_bot [3:0];
logic [3:0] out_right [3:0];

//logic [BIT_WIDTH-1:0] hori_wires [DIMENSION-1:0][DIMENSION-2:0];// horizaton wire: dimension * (dimension - 1)
// vertical wire: (dimension - 1) * dimension
//logic [7:0] ver_wires_row1 [3:0];//first row
//logic [9:0] ver_wires_row2 [3:0];//second row
//logic [11:0] ver_wires_row3 [3:0];//third row

SA DUT(
    .clk(clk), .reset(reset),
    .load_weight(),
    .out_model(out_model),
    .Sx(Sx), .Sy(Sy),
    .input_left(input_left), .input_top(input_top),
    .out_bot(out_bot), .out_right(out_right)
);

//--- Clock Generation Block ---//
always
begin
    #5 clk=~clk;
end

//--- Value Setting Block ---//
initial
begin
    clk  =    0;
    reset = 0;
    Sx      =    1'b1;
    Sy     =    1'b1;
    // load_weight_1 = 1'b0;
    // load_weight_2 = 1'b0;
    // load_weight_3 = 1'b0;
    // load_weight_4 = 1'b0;
    out_model = 1'b1;

    input_top[0] = 8'b11111111;
    input_top[1] = 8'b11111111;
    input_top[2] = 8'b11111111;
    input_top[3] = 8'b11111111;

    input_left[0] = 8'b11111111;
    input_left[1] = 8'b11111111;
    input_left[2] = 8'b11111111;
    input_left[3] = 8'b11111111;

        // Remember that monitor statements change whenever *any argument* changes
    $monitor("Time:%4.0f clock:%b Sx:%d Sy:%d Input_top:%b Input_left:%b out_bot:%b out_right:%b  ", $time, clk, Sx, Sy, 
    input_top, input_left, out_bot, out_right);

    @(negedge clk);
    input_top[0] = 8'b11111111;
    input_top[1] = 8'b11111111;
    input_top[2] = 8'b11111111;
    input_top[3] = 8'b11111111;

    input_left[0] = 8'b11111110;
    input_left[1] = 8'b11111101;
    input_left[2] = 8'b11111011;
    input_left[3] = 8'b11110111;
    #5

    load_weight_1 = 1'b1;
    load_weight_2 = 1'b1;
    load_weight_3 = 1'b1;
    load_weight_4 = 1'b1;

    @(negedge clk);
    input_top[0] = 8'b11111110;
    input_top[1] = 8'b11111101;
    input_top[2] = 8'b11111011;
    input_top[3] = 8'b11110111;

    input_left[0] = 8'b11111111;
    input_left[1] = 8'b11111111;
    input_left[2] = 8'b11111111;
    input_left[3] = 8'b11111111;
    #5

    @(negedge clk);
    input_top[0] = 8'b11111111;
    input_top[1] = 8'b11111111;
    input_top[2] = 8'b11111111;
    input_top[3] = 8'b11111111;

    input_left[0] = 8'b11111111;
    input_left[1] = 8'b11111111;
    input_left[2] = 8'b11111111;
    input_left[3] = 8'b11111111;
    #5

    @(negedge clk);
    input_top[0] = 8'b11111111;
    input_top[1] = 8'b11111111;
    input_top[2] = 8'b11111111;
    input_top[3] = 8'b11111111;

    input_left[0] = 8'b11111111;
    input_left[1] = 8'b11111111;
    input_left[2] = 8'b11111111;
    input_left[3] = 8'b11111111;
    #5
    $finish;
end

endmodule

