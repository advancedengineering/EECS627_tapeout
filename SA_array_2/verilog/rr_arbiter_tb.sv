module testbench;

    logic clk, rstn;
    
    bit gnt_en; //decide whether we want to write back
    bit [3-1:0]req; //~empty in FIFO
    logic [3-1:0]gnt;// grant/rd_en in FIFO

    rr_arbiter DUT(.clk(clk), .rstn(rstn), .gnt_en(gnt_en), .req(req), .gnt(gnt));

    always begin
        #5;
        clk=~clk;
    end

    initial begin
        clk = 1'b0;
        rstn = 1'b0;
        gnt_en = 1'b0;
        @(negedge clk);
        rstn = 1'b1;
        $display("gnt should be all 0 here");
        for(int i=0; i<6; ++i)begin
            req = 3'b111;
            #1 $display("req: %b, gnt: %b, gnt_en: %b", req, gnt, gnt_en);
            @(negedge clk);
        end

        gnt_en = 1'b1;
        $display("gnt should be circular here");
        for(int i=0; i<6; ++i)begin
            req = 3'b111;
            #1 $display("req: %b, gnt: %b, gnt_en: %b, mask_ff: %b, m_p_req: %b", req, gnt, gnt_en, DUT.mask_ff, 
            DUT.masked_priority_req);
            @(negedge clk);
        end
        $display("random request");
        for(int i=0; i<20; ++i)begin
            req = $urandom();
            #1 $display("req: %b, gnt: %b, gnt_en: %b", req, gnt, gnt_en);
            @(negedge clk);
        end

        $finish;

    end

endmodule
