
import DEFINE_PKG::*;
module FIFO #(parameter FIFO_DEPTH = `FIFO_DEPTH)(
    input clk,
    input rstn,

    input wr_en,
    input FIFO_ENTRY_t data_in,

    input rd_en,
    output FIFO_ENTRY_t data_out,

    output logic empty,
    output logic full
);

parameter IDX_SIZE = $clog2(FIFO_DEPTH);

FIFO_ENTRY_t fifo_arr[FIFO_DEPTH-1:0];

// wrap around pointer: ptr[x-1:0] is used for idx, ptr[x] is used for full and empty
logic [IDX_SIZE:0] rd_ptr, wr_ptr;

assign empty = rd_ptr == wr_ptr;
assign full =  (rd_ptr[IDX_SIZE] ^ wr_ptr[IDX_SIZE]) &
            (rd_ptr[IDX_SIZE-1:0] == wr_ptr[IDX_SIZE-1:0]);

assign data_out = empty? '{default:0} : fifo_arr[rd_ptr[IDX_SIZE-1:0]];

always_ff @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        rd_ptr <= '0;
        wr_ptr <= '0;
        for (int i=0; i< FIFO_DEPTH; ++ i)begin
            fifo_arr[i] <= '{default:0};
        end
    end else begin
        if(rd_en & wr_en)begin
            //FIFO DEPTH must be power of 2, otherwise won't work
            rd_ptr <= rd_ptr + 1;
            wr_ptr <= wr_ptr + 1;
            fifo_arr[wr_ptr[IDX_SIZE-1:0]] <= data_in;
        end else if(rd_en & ~empty)begin
            rd_ptr <= rd_ptr + 1;
        end else if(wr_en & ~full)begin
            fifo_arr[wr_ptr[IDX_SIZE-1:0]] <= data_in;
            wr_ptr <= wr_ptr + 1;
        end
    end

end



endmodule
