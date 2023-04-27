parameter SA_OUTPUT_WIDTH = 14;

module pooling_tb;
    logic clk;
    logic a_reset;
    logic out_model, pool_enable;
    logic [4:0] counter;
    logic Sx,Sy;
    logic [SA_OUTPUT_WIDTH - 1: 0] input_from_RELU;
    logic [SA_OUTPUT_WIDTH - 1: 0] max_out [1:0];

    logic [7:0] cyc_cnt;

    //DUT instantiation
    pooling DUT(.clk(clk), .a_reset(a_reset), .out_model(out_model), .pool_enable(pool_enable), .counter(counter),
                .Sx(Sx), .Sy(Sy), .input_from_RELU(input_from_RELU), .max_out(max_out) );

    // Clock Generation //
    always begin
        #5 clk = ~clk;
    end

    always @ (posedge clk) begin
        if (~a_reset) begin
            cyc_cnt <= 0;
        end
        else begin
            cyc_cnt <= cyc_cnt + 1;
        end
    end

    //Value Setting Block//
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end


    initial begin
        clk = 0;
        a_reset = 0;
        out_model = 1;
        pool_enable = 0;

        counter = 0;
        Sy = 0;
        Sx = 0;
        input_from_RELU = 0;

        $monitor("Time:%4.0f clock:%b reset:%b out_model:%b pool_enable:%b counter:%b Sx:%b Sy:%b input_from_RELU:%b max_out[0]: %b max_out[1]: %b", 
                $time, clk, a_reset, out_model, pool_enable, counter, Sx, Sy, input_from_RELU, max_out[0], max_out[1]);

        @(negedge clk);
        a_reset = 1;

        pool_enable = 1;
        counter = 0;
        input_from_RELU = 0;

        @(negedge clk);
        a_reset = 1;

        pool_enable = 1;
        counter = 1;
        input_from_RELU = 12;

        @(negedge clk);
        a_reset = 1;

        pool_enable = 1;
        counter = 2;
        input_from_RELU = 7;

        @(negedge clk);
        a_reset = 1;

        pool_enable = 1;
        counter = 3;
        input_from_RELU = 23;

        @(negedge clk);
        a_reset = 1;

        pool_enable = 1;
        counter = 4;
        input_from_RELU = 100;

        #20
        
        @(negedge clk);
        pool_enable = 0;

        // 2bit Mult Case
        @(negedge clk);
        counter = 0;

        input_from_RELU = 14'b00000010000001;

        @(negedge clk);
        counter = 0;
        out_model = 0;
        input_from_RELU = 14'b00000010000001;

        @(negedge clk);
        pool_enable = 1;

        @(negedge clk);
        counter = 1;
        input_from_RELU = 14'b00000110000101;

        @(negedge clk);
        counter = 2;
        input_from_RELU = 14'b00010000001100;

        @(negedge clk);
        counter = 3;
        input_from_RELU = 14'b11000010000111;

        @(negedge clk);
        counter = 4;
        input_from_RELU = 14'b00000010000001;

        @(negedge clk);
        counter = 5;
        input_from_RELU = 14'b00101010001101;

        @(negedge clk);
        counter = 6;
        input_from_RELU = 14'b00101010001001;

        @(negedge clk);
        counter = 7;
        input_from_RELU = 14'b00001100000011;

        @(negedge clk);
        counter = 8;
        input_from_RELU = 14'b00000010000001;

        @(negedge clk);
        counter = 9;
        input_from_RELU = 14'b11111111111111;

        @(negedge clk);
        counter = 10;
        input_from_RELU = 14'b00000010000001;


        #20
        $finish;
    end

endmodule