module PE_tb;


//logic [3:0] X, Y;
logic [11:0] input_top;
logic [3:0] input_left;
logic [11:0] out_bot;
logic [3:0] out_right;
logic [7:0] mult_pro;
logic clk, reset, load_weight, out_model, PE_enable;
logic is_signed;


PE DUT(
    .input_top(input_top),
    .input_left(input_left),
    .out_bot(out_bot),
    .out_right(out_right),
    .load_weight(load_weight),
    .out_model(out_model),
    .clk(clk),
    .reset(reset),
    .PE_enable(PE_enable),
    .is_signed(is_signed)
);

//--- Clock Generation Block ---//
always
begin
    #5 clk=~clk;
end

//--- Value Setting Block ---//
initial
begin
    clk  = 0;
    reset = 1;
    is_signed = 0;
    load_weight  = 1'b1;
    PE_enable =1;
    input_top = 12'b0000_0000_0000;
    input_left = 4'b1111;
    out_model = 1;


    // Remember that monitor statements change whenever *any argument* changes
    $monitor("Time:%4.0f clock:%b reset:%b  load_weight:%b weight:%b mult_pro:%b out_model:%b in_left:%b in_top:%b out_bot:%b out_right:%b", $time, clk, reset, 
    load_weight, DUT.weight, DUT.mult_pro, out_model, input_left, input_top, out_bot, out_right);

    @(negedge clk);
    load_weight  = 1'b0;
    #5
    @(negedge clk);
    input_top = 12'b0000_0000_0000;
    input_left = 4'b1111;
    load_weight  = 1'b0;
    #5;
    @(negedge clk);
    load_weight  = 1'b0;
    #5
    @(negedge clk);
    #10
    $finish;
end


endmodule


