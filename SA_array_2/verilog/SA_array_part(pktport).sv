// Ordering of Systolic Arrays
import DEFINE_PKG::*;
module SA_array_part
(
    input clk,
    input resetn,

    input control_signal, // comes from the controller, decides SAs to be vertically or horizontally arranged. 1: vertical, 0: horizontal

    //input [3:0][$clog2(`SA_NUM):0]    SA_select, //decides which SA to stream inputs into when in vertical mode

    input [$clog2(`SA_NUM):0]         SA_num, //Decides how many SAs does this computation need
    //input [`SA_NUM-1:0]         PE_enable, //Decides which SA need to enable PE
    //input [3:0][`SA_NUM-1:0] load_weight_en_line, //Decides which SA row needs to load weight

    //input [`SA_NUM-1:0][3:0] pool_reset,
    input out_model,    //1 for 4bit mult, 0 for 2bit mult
    input is_signed,         //Sign or unsigned multiplication       

    //input [3:0][3:0] in,  //assuming buffer sends in 1 row per cycle from read port
    input POOL_PACKED_t [`SA_NUM-1:0] pool_pkt,
    input ARR_CTRL_PACKED [`DIMENSION-1:0]sa_ctrl_pkt,
    input SHIFT_OUT_t [`DIMENSION-1:0] in_pkt,

    //write back sram address from controller's setup stage
    input [`SRAM_ADDR_SIZE-1:0] sram_w_base_addr, //base addr for SA0
    input sram_set_w_base_addr,
    //input [3:0] pool_rd_en[`SA_NUM-1:0],
    //wr_addr and data after arbitration
    output SAA_WB_SANUM_PACKED_t [`SA_NUM-1:0] saa_wb_pkt
    // output logic  [`SA_NUM-1:0][`SRAM_ADDR_SIZE-1:0] fifo_wr_addr ,
    // output logic  [`SA_NUM-1:0][`SA_OUTPUT_WIDTH-1:0]   pool_out 
);

logic [`SA_NUM-1:0][3:0] pool_rd_en;
logic [`SA_NUM-1:0]         PE_enable;
logic [`SA_NUM-1:0][3:0] pool_reset;

logic [3:0][$clog2(`SA_NUM):0]    SA_select;
logic [3:0][`SA_NUM-1:0] load_weight_en_line;
logic [3:0][3:0] in;

logic  [`SA_NUM-1:0][`SRAM_ADDR_SIZE-1:0] fifo_wr_addr ;
logic  [`SA_NUM-1:0][`SA_OUTPUT_WIDTH-1:0]   pool_out ;



generate
    for(genvar i = 0; i< `SA_NUM; ++i)begin
        assign pool_rd_en[i] = pool_pkt[i].pool_rd_en ;
        assign pool_reset[i] = pool_pkt[i].pool_en ;
        assign PE_enable[i] = pool_pkt[i].sa_pe_en ;

        assign saa_wb_pkt[i].fifo_wr_addr = fifo_wr_addr[i] ;
        assign saa_wb_pkt[i].pool_out = pool_out[i];
    end

    for(genvar i =0; i< `DIMENSION; ++i)begin
        assign SA_select[i] = sa_ctrl_pkt[i].sa_select;
        assign load_weight_en_line[i] = sa_ctrl_pkt[i].load_weight_en_line;
        ////updated because innovus port name error Apr.4 by tgc
        //assign in[i] = in_pkt[i];
        assign in[i] = in_pkt[i].in;

    end

endgenerate

logic    [`SA_NUM-1:0][3:0][3:0]  SA_input_stream_left;

logic    [`SA_NUM-1:0][3:0][`SA_OUTPUT_WIDTH-1:0]  SA_input_stream_top;

logic    [`SA_NUM-1:0][3:0][3:0]  SA_output_stream_r;


logic    [`SA_NUM-1:0][3:0][`SA_OUTPUT_WIDTH-1:0]  SA_output_stream_bot;

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


// ######## Write Back ADDR ##########

logic [`SA_NUM-1:0][`SRAM_ADDR_SIZE-1:0] SA_base_addr0;
logic [`SA_NUM-1:0][$clog2(`SA_NUM*4):0] SA_addr_cnt;
logic [`SA_NUM-1:0][$clog2(`SA_NUM*4):0] SA_addr_cnt_max;
// logic [`SA_NUM-1:0][`SRAM_ADDR_SIZE-1:0] fifo_wr_addr; //

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

        end

    end

end



endmodule
