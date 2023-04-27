// ######### Write Back Arbiter and FIFO
import DEFINE_PKG::*;
module write_back_part
(
    input clk, //clock
    input resetn, //low activate reset signal
    input [`SA_NUM-1:0][3:0] pool_rd_en, // ppoling enable signal
    input [`SA_NUM-1:0][`SA_OUTPUT_WIDTH-1:0]  pool_out , // pooling output
    input [`SA_NUM-1:0][`SRAM_ADDR_SIZE-1:0] fifo_wr_addr , // fifo writing address
    output logic [`SRAM_ADDR_SIZE-1:0] sram_wr_addr, // sram writing address
    output logic [`SA_OUTPUT_WIDTH-1:0] sram_wr_data, // sram writing data
    output logic sram_wr_en, // sram write enable signal
    output logic fifo_full_out
);

logic [`SA_NUM-1:0] fifo_empty;
logic [`SA_NUM-1:0] fifo_full;
logic [`SA_NUM-1:0] gnt;
FIFO_ENTRY_t fifo_out[`SA_NUM-1:0];
FIFO_ENTRY_t fifo_in[`SA_NUM-1:0];

rr_arbiter #(.NUM_REQ(`SA_NUM)) rra (
    .clk(clk),
    .rstn(resetn),
    .gnt_en(1'b1), // fix me should this be 1?
    .req(~fifo_empty), //~empty in FIFO
    .gnt(gnt) // gnt/rd_en in FIFO
);

always_comb begin
    sram_wr_addr = '0;
    for(int i=0; i<`SA_NUM; ++i)begin
        if(gnt[i])begin
            sram_wr_addr = fifo_out[i].addr;
            sram_wr_data = fifo_out[i].data;
        end
    end
end

always_ff @ (posedge clk)begin
    if(~resetn)begin
        fifo_full_out <= '0;
    end else begin
        fifo_full_out <= |fifo_full;
    end

end

// assign sram_wr_addr =   (gnt[0])? fifo_out[0].addr :
//                         (gnt[1])? fifo_out[1].addr :
//                         (gnt[2])? fifo_out[2].addr : '0;

// assign sram_wr_data =   (gnt[0])? fifo_out[0].data :
//                         (gnt[1])? fifo_out[1].data :
//                         (gnt[2])? fifo_out[2].data : '0;

assign sram_wr_en = |gnt;


generate
    for(genvar i=0; i< `SA_NUM; ++i)begin : gen_sa_pool_fifo
        assign fifo_in[i].addr = fifo_wr_addr[i];
        assign fifo_in[i].data = pool_out[i];
        FIFO #(.FIFO_DEPTH(`FIFO_DEPTH))pool_fifo (
            .clk(clk),
            .rstn(resetn),

            .wr_en(|pool_rd_en[i]),
            .data_in(fifo_in[i]),

            .rd_en(gnt[i]),
            .data_out(fifo_out[i]),

            .empty(fifo_empty[i]),
            .full(fifo_full[i])
        );

    end

endgenerate

endmodule