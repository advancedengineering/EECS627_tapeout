
// in controller.sv
input  [`SA_NUM-1:0] req;
output logic [`SA_NUM-1:0] gnt;

rr_arbiter #(.NUM_REQ(`SA_NUM)) rra (
    .clk(clk),
    .rstn(rstn),
    .gnt_en(), // fix me should this be 1?
    .req(req), //~empty in FIFO
    .gnt(gnt) // gnt/rd_en in FIFO
);























//in SA_array.sv
//FIFO

input [`SA_NUM-1:0] fifo_wr_en; // the new pool read without reset
input [`SA_NUM-1:0][SRAM_ADDR_SIZE-1:0] fifo_wr_addr; //w_addr


input [`SA_NUM-1:0] gnt; //controller's arbiter
output logic [`SA_NUM-1:0] req; //controller's arbiter

output [`SRAM_ADDR_SIZE-1:0] sram_wr_addr; //wr_addr and data after arbitration
output [`SA_OUTPUT_WIDTH-1:0] sram_wr_data; 


logic [`SA_NUM-1:0] fifo_empty;
logic [`SA_NUM-1:0] fifo_full;
FIFO_ENTRY_t fifo_data_out[`SA_NUM-1:0];
FIFO_ENTRY_t fifo_data_in[`SA_NUM-1:0];


assign sram_wr_addr =   (gnt[0])? fifo_data_out[0].addr :
                        (gnt[1])? fifo_data_out[1].addr :
                        (gnt[2])? fifo_data_out[2].addr : '0;

assign sram_wr_data =   (gnt[0])? fifo_data_out[0].data :
                        (gnt[1])? fifo_data_out[1].data :
                        (gnt[2])? fifo_data_out[2].data : '0;


generate
    for(int i=0; i< `SA_NUM; ++i)begin : gen_pool_fifo
        assign fifo_data_in[i].addr = fifo_wr_addr[i];
        assign fifo_data_in[i].data = pool_out[i];
        assign req[i] = ~fifo_empty[i];
        FIFO #(.FIFO_DEPTH(8))pool_fifo (
            .clk(clk),
            .rstn(resetn),

            .wr_en(fifo_wr_en[i]),
            .data_in(fifo_data_in[i]),

            .rd_en(gnt[i]),
            .data_out(fifo_data_out[i]),

            .empty(fifo_empty[i]),
            .full(fifo_full[i])
        );

    end

endgenerate