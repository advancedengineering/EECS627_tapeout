module testbench;

    logic clk, rstn;
    
    logic rd_en;
    FIFO_ENTRY_t data_in;

    logic wr_en;
    FIFO_ENTRY_t data_out;

    logic empty;
    logic full;

    FIFO DUT(.clk(clk), .rstn(rstn), .rd_en(rd_en), .data_in(data_in), .wr_en(wr_en), .data_out(data_out),
            .empty(empty), .full(full));

    always begin
        #5;
        clk=~clk;
    end

    initial begin
        clk = 1'b0;
        rstn = 1'b0;
        rd_en = 1'b0;
        wr_en = 1'b0;
        data_in = '{default:'0};
        @(negedge clk);
        rstn = 1'b1;
        @(negedge clk);
        for(int i=0; i<=30; ++i)begin
            data_in.addr = i;
            data_in.data = i;
            if(i <= 10)begin
                wr_en = 1'b1;
                rd_en = 1'b0;
            end else if (i > 10 && i <=20)begin
                wr_en = 1'b1;
                rd_en = 1'b1;
            end else begin
                wr_en = 1'b0;
                rd_en = 1'b1;
            end
            
            $display("wr_en: %0b; rd_en: %0b; rd_ptr: %0d;  wr_ptr: %0d;  empty: %0b;  full: %0b; data_in.addr: %0d; data_out.addr: %0d", 
                        wr_en, rd_en, DUT.rd_ptr[2:0], DUT.wr_ptr[2:0], empty, full, data_in.addr, data_out.addr);
            @(negedge clk);
        end

        $finish;

    end

endmodule
