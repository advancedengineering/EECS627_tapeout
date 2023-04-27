// Ordering of Systolic Arrays
import DEFINE_PKG::*;
module SA_Array
(
    input clk,
    input resetn,

    input control_signal, // comes from the controller, decides SAs to be vertically or horizontally arranged. 1: vertical, 0: horizontal

    input [3:0][$clog2(`SA_NUM):0]    SA_select, //decides which SA to stream inputs into when in vertical mode

    input [$clog2(`SA_NUM):0]         SA_num, //Decides how many SAs does this computation need
    input [`SA_NUM-1:0]         PE_enable, //Decides which SA need to enable PE
    input [3:0][`SA_NUM-1:0] load_weight_en_line, //Decides which SA row needs to load weight

    input [`SA_NUM-1:0][3:0] pool_reset,
    input out_model,    //1 for 4bit mult, 0 for 2bit mult
    input is_signed,         //Sign or unsigned multiplication       

    input [3:0][3:0] in,  //assuming buffer sends in 1 row per cycle from read port

    //write back sram address from controller's setup stage
    input [`SRAM_ADDR_SIZE-1:0] sram_w_base_addr, //base addr for SA0
    input                       sram_set_w_base_addr,
    input [`SA_NUM-1:0][3:0] pool_rd_en,
    //wr_addr and data after arbitration
    output logic [`SRAM_ADDR_SIZE-1:0] sram_wr_addr, 
    output logic [`SA_OUTPUT_WIDTH-1:0] sram_wr_data,
    output logic                        sram_wr_en, 

    // output  logic [3:0][SA_OUTPUT_WIDTH-1:0]   out_bot,  //potentially 12 different 12-bit output 
    output  logic [`SA_NUM-1:0][`SA_OUTPUT_WIDTH-1:0]   pool_out 
);

logic    [`SA_NUM-1:0][3:0][3:0]  SA_input_stream_left;
// logic    [3:0][3:0]  SA2_input_stream_left;
// logic    [3:0][3:0]  SA3_input_stream_left;

logic    [`SA_NUM-1:0][3:0][`SA_OUTPUT_WIDTH-1:0]  SA_input_stream_top;
// logic    [3:0][SA_OUTPUT_WIDTH-1:0]  SA2_input_stream_top;
// logic    [3:0][SA_OUTPUT_WIDTH-1:0]  SA3_input_stream_top;

logic    [`SA_NUM-1:0][3:0][3:0]  SA_output_stream_r;
// logic    [3:0][3:0]  SA2_output_stream_r;
// logic    [3:0][3:0]  SA3_output_stream_r;

logic    [`SA_NUM-1:0][3:0][`SA_OUTPUT_WIDTH-1:0]  SA_output_stream_bot;
// logic    [3:0][SA_OUTPUT_WIDTH-1:0]  SA2_output_stream_bot;
// logic    [3:0][SA_OUTPUT_WIDTH-1:0]  SA3_output_stream_bot;

//wires for activation select
logic [`SA_NUM-1:0][3:0][`SA_OUTPUT_WIDTH-1:0]   out_bot_tmp; 
logic [`SA_NUM-1:0][3:0][`SA_OUTPUT_WIDTH-1:0]   out_bot_relu ;
logic [`SA_NUM-1:0][3:0][`SA_OUTPUT_WIDTH-1:0]   out_bot_pool ;

logic [`SA_NUM-1:0][3:0]    load_weight;
generate
    for(genvar i = 0; i< `SA_NUM; ++i)begin
        for(genvar j = 0; j< `DIMENSION; ++j)begin
            assign load_weight[i][j] = load_weight_en_line[j][i];
        end

        if(i == 0)begin
            assign SA_input_stream_top[i] = '0;
            for(genvar j = 0; j< `DIMENSION; ++j)begin
                assign  SA_input_stream_left[i][j] = control_signal? (SA_select[j] == i ? in[j] : '0)  : in[j]; 
            end
        end else begin
            assign SA_input_stream_top[i] = control_signal ? SA_output_stream_bot[i-1] : '0;
            for(genvar j = 0; j< `DIMENSION; ++j)begin
                assign  SA_input_stream_left[i][j] = control_signal? (SA_select[j] == i ? in[j] : '0):  
                                                    load_weight[i][j]? in[j] : SA_output_stream_r[i-1][j]; 
            end
        end

        assign  out_bot_tmp[i] = SA_output_stream_bot[i];
    end
endgenerate



// assign SA1_input_stream_top = 0;
// assign SA2_input_stream_top = control_signal ? SA1_output_stream_bot : 0;
// assign SA3_input_stream_top = control_signal ? SA2_output_stream_bot : 0;

// //Demux to select input to SA
// assign  SA1_input_stream_left[0] = control_signal? (SA_select[0] == 0 ? in[0] : 0)  : in[0]; 
// assign  SA1_input_stream_left[1] = control_signal? (SA_select[1] == 0 ? in[1] : 0)  : in[1]; 
// assign  SA1_input_stream_left[2] = control_signal? (SA_select[2] == 0 ? in[2] : 0)  : in[2]; 
// assign  SA1_input_stream_left[3] = control_signal? (SA_select[3] == 0 ? in[3] : 0)  : in[3]; 


// assign  SA2_input_stream_left[0] = control_signal? (SA_select[0] == 1 ? in[0] : 0):  
//                                    load_weight[1][0]? in[0] : SA1_output_stream_r[0]; 
// assign  SA2_input_stream_left[1] = control_signal? (SA_select[1] == 1 ? in[1] : 0):
//                                    load_weight[1][1]? in[1] : SA1_output_stream_r[1]; 
// assign  SA2_input_stream_left[2] = control_signal? (SA_select[2] == 1 ? in[2] : 0):  
//                                    load_weight[1][2]? in[2]: SA1_output_stream_r[2]; 
// assign  SA2_input_stream_left[3] = control_signal? (SA_select[3] == 1 ? in[3] : 0):  
//                                    load_weight[1][3]? in[3] : SA1_output_stream_r[3]; 

// assign  SA3_input_stream_left[0] = control_signal? (SA_select[0] == 2 ? in[0] : 0):  
//                                    load_weight[2][0]? in[0] : SA2_output_stream_r[0]; 
// assign  SA3_input_stream_left[1] = control_signal? (SA_select[1] == 2 ? in[1] : 0)  : 
//                                    load_weight[2][1]? in[1] : SA2_output_stream_r[1]; 
// assign  SA3_input_stream_left[2] = control_signal? (SA_select[2] == 2 ? in[2] : 0)  : 
//                                    load_weight[2][2]? in[2] : SA2_output_stream_r[2]; 
// assign  SA3_input_stream_left[3] = control_signal? (SA_select[3] == 2 ? in[3] : 0)  : 
//                                    load_weight[2][3]? in[3] : SA2_output_stream_r[3]; 


//Mux to select output from which SA

// //Concatenate all output_bottom into one out_bot_tmp array 
// assign  out_bot_tmp = {SA3_output_stream_bot,  SA2_output_stream_bot, SA1_output_stream_bot};


//RELU and Pooling
generate
    for(genvar i =0; i< `SA_NUM; ++ i)begin : gen_SA_inst
        for(genvar j =0; j< `DIMENSION; ++ j)begin : gen_SA_out
            assign out_bot_relu[i][j] = (out_bot_tmp[i][j][`SA_OUTPUT_WIDTH-1] && is_signed)? '0 : out_bot_tmp[i][j];
            pooling max_pool(.clk(clk), .a_reset(resetn), .pool_reset(pool_reset[i][j]), .input_from_RELU(out_bot_relu[i][j]) , .max_out(out_bot_pool[i][j]) );
        end

        assign pool_out[i] = pool_rd_en[i][0] ? out_bot_pool[i][0] :
                            pool_rd_en[i][1] ? out_bot_pool[i][1] :
                            pool_rd_en[i][2] ? out_bot_pool[i][2] :
                            pool_rd_en[i][3] ? out_bot_pool[i][3] : '0;

        SA SA_inst(.clk(clk), .reset(resetn), .load_weight(load_weight[i]),  
                .out_model(out_model), .PE_enable(PE_enable[i]), .is_signed(is_signed), .input_top(SA_input_stream_top[i]), 
                .input_left(SA_input_stream_left[i]), .out_bot(SA_output_stream_bot[i]), .out_right(SA_output_stream_r[i]));

    end
endgenerate


// assign pool_complete = out_model ? ((counter >= 15) ? 1'b1 : 1'b0) : ((counter >= 19) 1'b1 ? 1'b0 ); 

//Instantiate SAs
// SA SA1(.clk(clk), .reset(resetn), .load_weight(load_weight[0]),  
//     .out_model(out_model), .PE_enable(PE_enable[0]), .is_signed(is_signed), .input_top(SA1_input_stream_top), 
//     .input_left(SA1_input_stream_left), .out_bot(SA1_output_stream_bot), .out_right(SA1_output_stream_r));

// SA SA2(.clk(clk), .reset(resetn), .load_weight(load_weight[1]),
//     .out_model(out_model), .PE_enable(PE_enable[1]), .is_signed(is_signed), .input_top(SA2_input_stream_top), 
//     .input_left(SA2_input_stream_left), .out_bot(SA2_output_stream_bot), .out_right(SA2_output_stream_r));
    
// SA SA3(.clk(clk), .reset(resetn), .load_weight(load_weight[2]), 
//     .out_model(out_model), .PE_enable(PE_enable[2]), .is_signed(is_signed), .input_top(SA3_input_stream_top), 
//     .input_left(SA3_input_stream_left), .out_bot(SA3_output_stream_bot), .out_right(SA3_output_stream_r));






// ######## Write Back ADDR ##########

logic [`SA_NUM-1:0][`SRAM_ADDR_SIZE-1:0] SA_base_addr0;
logic [`SA_NUM-1:0][$clog2(`SA_NUM*4):0] SA_addr_cnt;
logic [`SA_NUM-1:0][$clog2(`SA_NUM*4):0] SA_addr_cnt_max;
logic [`SA_NUM-1:0][`SRAM_ADDR_SIZE-1:0] fifo_wr_addr; //

generate
    for (genvar i=0; i< `SA_NUM; ++i)begin
        assign fifo_wr_addr[i] = SA_base_addr0[i] + SA_addr_cnt[i];
    end
endgenerate

always_ff @ (posedge clk or negedge resetn)begin
    if(~resetn)begin
        for (int i=0; i< `SA_NUM; ++i) begin
            SA_base_addr0[i] <= '0;       
            SA_addr_cnt[i] <= '0;     
            SA_addr_cnt_max[i] <= '0;
        end
    end else if (sram_set_w_base_addr) begin
        for (int i=0; i< `SA_NUM; ++i) begin
            SA_addr_cnt[i] <= '0;
        end
        if(~control_signal) begin //hmode
            SA_base_addr0[0] <= sram_w_base_addr;
            if(~(|SA_num))begin
                // if(SA_num == 2'd1)begin
                //     SA_addr_cnt_max[0] <= 4'd4;
                //     SA_addr_cnt_max[1] <= '0;
                //     SA_addr_cnt_max[2] <= '0;
                // end else if (SA_num == 2'd2) begin
                //     SA_addr_cnt_max[0] <= 4'd8;
                //     SA_addr_cnt_max[1] <= 4'd8;
                //     SA_addr_cnt_max[2] <= '0;
                //     SA_base_addr0[1] <= sram_w_base_addr + 8;
                // end else if (SA_num == 2'd3) begin
                //     SA_addr_cnt_max[0] <= 4'd12;
                //     SA_addr_cnt_max[1] <= 4'd12;
                //     SA_addr_cnt_max[2] <= 4'd12;
                //     SA_base_addr0[1] <= sram_w_base_addr + 12;
                //     SA_base_addr0[2] <= sram_w_base_addr + 24;
                // end
                for (int i=0; i< `SA_NUM; ++i) begin
                    if(i< SA_num )begin
                        SA_addr_cnt_max[i] <= 4 * SA_num;
                        if(i != 0)begin
                            SA_base_addr0[i] <= sram_w_base_addr + i * SA_num * 4;
                        end
                    end else begin
                        SA_addr_cnt_max[i] <= '0;
                    end
                    SA_addr_cnt[i] <= '0;
                end
            end 
        end else begin //vmode
            // if(SA_num == 2'd1)begin
            //     SA_base_addr0[0] <= sram_w_base_addr;
            //     SA_addr_cnt_max[0] <= 4'd4;
            //     SA_addr_cnt_max[1] <= 4'd0;
            //     SA_addr_cnt_max[2] <= 4'd0;
            // end else if(SA_num == 2'd2)begin
            //     SA_base_addr0[1] <= sram_w_base_addr;
            //     SA_addr_cnt_max[0] <= 4'd0;
            //     SA_addr_cnt_max[1] <= 4'd4;
            //     SA_addr_cnt_max[2] <= 4'd0;
            // end else if(SA_num == 2'd3)begin
            //     SA_base_addr0[2] <= sram_w_base_addr;
            //     SA_addr_cnt_max[0] <= 4'd0;
            //     SA_addr_cnt_max[1] <= 4'd0;
            //     SA_addr_cnt_max[2] <= 4'd4;
            // end

            for (int i=0; i< `SA_NUM; ++i) begin
                if(~(|SA_num) && (SA_num == i + 1))begin
                    SA_base_addr0[i] <= sram_w_base_addr;
                    SA_addr_cnt_max[0] <= 4;
                end else begin
                    SA_addr_cnt_max[i] <= '0;
                end
            end

        end

    end else begin
        if(~control_signal) begin //hmode
            for(int i=0; i< `SA_NUM; ++i)begin //each SA
                if(|pool_rd_en[i]) begin
                    if(SA_addr_cnt[i] + 1 == SA_addr_cnt_max[i]) begin
                        SA_addr_cnt[i] <= '0;
                        SA_base_addr0[i] <= SA_base_addr0[i] + SA_addr_cnt_max[0] + SA_addr_cnt_max[1] + SA_addr_cnt_max[2];
                    end else begin
                        SA_addr_cnt[i] <= SA_addr_cnt[i] + 1;
                    end
                end
            end
        end else begin //vmode
            for(int i=0; i< `SA_NUM; ++i) begin
                if(~(|SA_num) && (SA_num == i+1)&&(|pool_rd_en[i]))begin
                    if(SA_addr_cnt[i] + 1 == SA_addr_cnt_max[i]) begin
                        SA_addr_cnt[i] <= '0;
                        SA_base_addr0[i] <= SA_base_addr0[i] + SA_addr_cnt_max[i];
                    end else begin
                        SA_addr_cnt[i] <= SA_addr_cnt[i] + 1;
                    end
                end

            end
            // if((SA_num == 2'd1) && (|pool_rd_en[0])) begin //only SA1
            //     if(SA_addr_cnt[0] + 1 == SA_addr_cnt_max[0]) begin
            //         SA_addr_cnt[0] <= '0;
            //         SA_base_addr0[0] <= SA_base_addr0[0] + SA_addr_cnt_max[0];
            //     end else begin
            //         SA_addr_cnt[0] <= SA_addr_cnt[0] + 1;
            //     end
            // end else if((SA_num == 2'd2) && (|pool_rd_en[1])) begin //only SA2
            //     if(SA_addr_cnt[1] + 1 == SA_addr_cnt_max[1]) begin
            //         SA_addr_cnt[1] <= '0;
            //         SA_base_addr0[1] <= SA_base_addr0[1] + SA_addr_cnt_max[1];
            //     end else begin
            //         SA_addr_cnt[1] <= SA_addr_cnt[1] + 1;
            //     end
            // end else if((SA_num == 2'd3) && (|pool_rd_en[2])) begin //only SA3
            //     if(SA_addr_cnt[2] + 1 == SA_addr_cnt_max[2]) begin
            //         SA_addr_cnt[2] <= '0;
            //         SA_base_addr0[2] <= SA_base_addr0[2] + SA_addr_cnt_max[2];
            //     end else begin
            //         SA_addr_cnt[2] <= SA_addr_cnt[2] + 1;
            //     end
            // end
        end

    end

end


// ######### Write Back Arbiter and FIFO

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
    sram_wr_data = '0;

    for(int i=0; i<`SA_NUM; ++i)begin
        if(gnt[i])begin
            sram_wr_addr = fifo_out[i].addr;
            sram_wr_data = fifo_out[i].data;
        end
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
        FIFO #(.FIFO_DEPTH(64))pool_fifo (
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
