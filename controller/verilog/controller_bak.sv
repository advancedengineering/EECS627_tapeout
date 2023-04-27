import DEFINE_PKG::*;

module controller 
(
    input clk, rstn, 
    input [`INST_SIZE-1:0] inst,
    //input sram_wr_en, // sram write control signal from SA_Array

    //setup
    output logic bit_mode_o, //2/4bit 0 for 2, 1 for 4
    output logic is_sign_o, //sign1, unsign0
    output logic mode_o,//v/hmode
    output logic [$clog2(`SA_NUM):0] sa_num_o,//sa number

    output logic [3:0 ][$clog2(`SA_NUM):0] sa_select_o ,//shifter input goes into which sa, kh=0 
    
    //load_weight and pe enable signal during both compute and load weight stage
    output logic [3:0][`SA_NUM-1:0] load_weight_en_line_o ,
    
    //SA's PE shift enable signal
    output logic [`SA_NUM-1:0] sa_pe_en_o,

    //shifter
    //work as shifter enable signal, or compute stage enable
    //set high at the same time with data
    output logic valid_in_o,
    //output logic shift_rst,//todo

    //pool
    output logic [`SA_NUM-1:0][3:0] pool_en_o ,//pooling block enable signal.
    //reset the compare register in pooling block

    //write back
    output logic [`SA_NUM-1:0][3:0] pool_rd_en_o ,//calculate write back address

    // SRAM
    output logic [`SRAM_ADDR_SIZE-1:0] sram_w_base_addr_o,//port change
    output logic sram_set_w_base_addr_o,//set the base addr of each output FIFO at SA arrays at first compute instruction's pool_rst. 
    //sa_num above
    output logic [`SRAM_ADDR_SIZE-1:0] sram_r_addr_o,
    output logic sram_r_WEN_o, //sram write enable
    output logic sram_r_CEN_o,//sram write/read chip enable
    output logic sram_w_WEN_o, 
    output logic sram_w_CEN_o,

    output logic f_stage_en //fetch stage enable signal; setup 1 cycle; compute/load depends. when 0 change new instruction
);

logic f_stage_en_d;
//add pipeline stage for retiming
logic bit_mode;
logic is_sign;
logic mode;
logic [$clog2(`SA_NUM):0] sa_num;
logic [3:0 ][$clog2(`SA_NUM):0] sa_select;
logic [3:0][`SA_NUM-1:0] load_weight_en_line;
logic [`SA_NUM-1:0] sa_pe_en;
logic valid_in;
logic [`SA_NUM-1:0][3:0] pool_en ;
logic [`SA_NUM-1:0][3:0] pool_rd_en ;
logic [`SRAM_ADDR_SIZE-1:0] sram_w_base_addr;
logic sram_set_w_base_addr; 
logic [`SRAM_ADDR_SIZE-1:0] sram_r_addr;
logic sram_r_WEN;
logic sram_r_CEN;
logic sram_w_WEN;
logic sram_w_CEN;
always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        bit_mode_o<=0;
        is_sign_o<=0;
        mode_o<=0;
        sa_num_o<=0;
        sa_select_o<=0;
        load_weight_en_line_o<=0;
        sa_pe_en_o<=0;
        valid_in_o<=0;
        pool_en_o<=0;
        pool_rd_en_o<=0;
        sram_w_base_addr_o<=0;
        sram_set_w_base_addr_o<=0;
        sram_r_addr_o<=0;
        sram_r_WEN_o<=0;
        sram_r_CEN_o<=0;
        sram_w_WEN_o<=0;
        sram_w_CEN_o<=0;
    end
    else begin
        bit_mode_o<=bit_mode;
        is_sign_o<=is_sign;
        mode_o<=mode;
        sa_num_o<=sa_num;
        sa_select_o<=sa_select;
        load_weight_en_line_o<=load_weight_en_line;
        sa_pe_en_o<=sa_pe_en;
        valid_in_o<=valid_in;
        pool_en_o<=pool_en;
        pool_rd_en_o<=pool_rd_en;
        sram_w_base_addr_o<=sram_w_base_addr;
        sram_set_w_base_addr_o<=sram_set_w_base_addr;
        sram_r_addr_o<=sram_r_addr;
        sram_r_WEN_o<=sram_r_WEN;
        sram_r_CEN_o<=sram_r_CEN;
        sram_w_WEN_o<=sram_w_WEN;
        sram_w_CEN_o<=sram_w_CEN;
    end
end

/******************signal setup begins******************//******************signal setup begins******************/
/******************signal setup begins******************//******************signal setup begins******************/
/******************signal setup begins******************//******************signal setup begins******************/

//ISA
/*opcode*/ /*load_weights #iteration kh*kw*ic/#of_weights_in_sram_wordline 0-3*/ /* #iteration #sa 0-2*/ /*coumpute #iteration kh*kw*ic/#of_inputs_in_sram_wordline*/
/*modify*/ //kh fixed, mode and #of SAs is given by setup instruction, only need overall loop count
//(compute load_weight) /*opcode 3bits*/ 
//(setup) /*opcode 3bits*/ /*mode 1bit*/ /*bit_mode 1bit*/ /*sa_num 3bits*/ /*is_sign* 1bit/ /*000*/
//(set_base_weight_addr)/*opcode 3bits*//*addr 6->10bits*/
//(set_base_input_addr) /*opcode 3bits*//*addr 6->10bits*/
//(set_base_output_addr)/*opcode 3bits*//*addr 6->10bits*/

//Inst fetch stage
logic [`SRAM_ADDR_SIZE-1:0] base_input_addr;
logic [`SRAM_ADDR_SIZE-1:0] base_input_addr_next;
logic [`SRAM_ADDR_SIZE-1:0] base_output_addr;
logic [`SRAM_ADDR_SIZE-1:0] base_output_addr_next;
logic [`SRAM_ADDR_SIZE-1:0] base_weight_addr;
logic [`SRAM_ADDR_SIZE-1:0] base_weight_addr_next;
logic [2:0] opcode;
logic [2:0] opcode_next;

logic bit_mode_next;//2/4bit 0 for 2, 1 for 4
logic is_sign_next; //sign1, unsign0
logic mode_next;//v/hmode
logic [$clog2(`SA_NUM):0] sa_num_next;//sa number


//counter signals
logic kh_next;
logic sa_next;
logic [1:0] kh_cnt;
logic [`SA_COUNTER_WIDTH:0] sa_cnt;
logic cnt_stage_en;
logic need_cnt;
logic need_cnt_d;

//logic cnt_new_inst;//counter controll signal, reset counter value to 0
//logic f_stage_en_t;

//setup

//Compute stage

logic load_counter_max; //when sa=sa_num-1 kh=2
logic load_counter_max_d;
logic load_counter_max_dd;
logic load_counter_max_ddd;

logic load_weight_en0;
logic load_weight_en1;
logic load_weight_en2;
logic load_weight_en3;

logic compute_counter_max; //when sa=sa_num-1 kh=2
logic compute_counter_max_d;
logic compute_counter_max_dd;
logic compute_counter_max_ddd;
logic compute_counter_max_dddd;

//logic sel;

//pool stage
logic pool0_next;
logic pool1_next;
logic [`POOL_COUNTER_WIDTH-1:0] pool0_cnt;
logic [`POOL_COUNTER_WIDTH-1:0] pool1_cnt;
logic [`POOL_COUNTER_WIDTH-1:0] pool0_max_count;
logic [`POOL_COUNTER_WIDTH-1:0] pool1_max_count;
logic pool0_inc;
logic pool1_inc;


/******************signal setup ends******************//******************signal setup ends******************/
/******************signal setup ends******************//******************signal setup ends******************/
/******************signal setup ends******************//******************signal setup ends******************/

//Inst Fetch & Decode
always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        mode<=0;
        opcode<=0;
        sa_num<=0;
        bit_mode<=0;
        is_sign<=0;
        base_input_addr<=0;
        base_weight_addr<=0;
        base_output_addr<=0;

        mode_next<=0;
        opcode_next<=0;
        sa_num_next<=0;
        bit_mode_next<=0;
        is_sign_next<=0;
        base_input_addr_next<=0;
        base_weight_addr_next<=0;
        base_output_addr_next<=0;
    end
    else if(f_stage_en) begin
        opcode<=opcode_next;
        opcode_next<=inst[`INST_SIZE-1:`INST_SIZE-3];
        if(opcode_next==`setup) begin
            mode<=mode_next;
            sa_num<=sa_num_next;
            bit_mode<=bit_mode_next; 
            is_sign<=is_sign_next;
        end
        else if(opcode_next==`set_base_weight_addr) begin
            base_weight_addr<=base_weight_addr_next;
        end
        else if(opcode_next==`set_base_input_addr) begin
            base_input_addr<=base_input_addr_next;
        end
        else if(opcode_next==`set_base_output_addr) begin
            base_output_addr<=base_output_addr_next;
        end

        if(inst[`INST_SIZE-1:`INST_SIZE-3]==`setup) begin
            // mode_next<=inst[`INST_SIZE-4];
            // sa_num_next<=inst[3:1];
            // bit_mode_next<=inst[4]; 
            // is_sign_next<=inst[0];
            mode_next<=inst[`INST_SIZE-4];
            bit_mode_next<=inst[8]; 
            sa_num_next<=inst[7:4];
            is_sign_next<=inst[3];
        end
        else if(inst[`INST_SIZE-1:`INST_SIZE-3]==`set_base_weight_addr) begin
            base_weight_addr_next<=inst[`SRAM_ADDR_SIZE-1:0];
        end
        else if(inst[`INST_SIZE-1:`INST_SIZE-3]==`set_base_input_addr) begin
            base_input_addr_next<=inst[`SRAM_ADDR_SIZE-1:0];
        end
        else if(inst[`INST_SIZE-1:`INST_SIZE-3]==`set_base_output_addr) begin
            base_output_addr_next<=inst[`SRAM_ADDR_SIZE-1:0];
        end
    end
end

//counter stage 
assign need_cnt=(opcode==`load_weight) || (opcode==`compute);
always_ff @(posedge clk or negedge rstn) begin
    if(!rstn)
        need_cnt_d<=0;
    else
        need_cnt_d<=need_cnt;
end

always_ff @(posedge clk or negedge rstn) begin
    if(!rstn)
        f_stage_en_d<=0;
    else
        f_stage_en_d<=f_stage_en;
end

logic [$clog2(`SA_NUM):0] sa_max_count;
always_ff@(posedge clk or negedge rstn) begin
    if(!rstn)
        sa_max_count<=0; 
    else if(cnt_stage_en)
        sa_max_count<=(sa_num-2'b1);   
end

counter1 #(.BIT_WIDTH(2)) kh_counter (.clk(clk), .inc(cnt_stage_en), .rstn(rstn), .max_count(2'b11), .overflow(kh_next), .out(kh_cnt));
counter3 #(.BIT_WIDTH(`SA_COUNTER_WIDTH)) sa_counter (.clk(clk), .inc(kh_next&&cnt_stage_en), .rstn(rstn), .max_count(sa_max_count), .overflow(sa_next), .out(sa_cnt));
counter2 #(.BIT_WIDTH(`POOL_COUNTER_WIDTH)) pool_counter0 (.clk(clk), .inc(pool0_inc), .rstn(rstn), .max_count(pool0_max_count), .overflow(pool0_next), .out(pool0_cnt));
counter2 #(.BIT_WIDTH(`POOL_COUNTER_WIDTH)) pool_counter1 (.clk(clk), .inc(pool1_inc), .rstn(rstn), .max_count(pool1_max_count), .overflow(pool1_next), .out(pool1_cnt));

//fsm for dual pool counters
logic [2:0] state;
logic [2:0] next_state;

always_ff@(posedge clk or negedge rstn) begin
    if(!rstn)
        state<=0; 
    else
        state<=next_state;   
end

always_comb begin
    if(pool0_inc && !pool1_inc && !(pool0_cnt==pool0_max_count))
        next_state=`pool0_busy;
    else if(pool1_inc && !pool0_inc &&!(pool1_cnt==pool1_max_count))
        next_state=`pool1_busy;
    else if(pool0_inc && pool1_inc && ((state==`pool0_busy)||(state==`both_busy_pool0)))
        next_state=`both_busy_pool0;
    else if(pool0_inc && pool1_inc && ((state==`pool1_busy)||(state==`both_busy_pool1)))
        next_state=`both_busy_pool1;
    else if((pool0_inc && !pool1_inc && (pool0_cnt==pool0_max_count)) || (state==`idle_pool0))
        next_state=`idle_pool0;
    else if((pool1_inc && !pool0_inc && (pool1_cnt==pool1_max_count))||(state==`idle_pool1))
        next_state=`idle_pool1;
    else
        next_state=`idle;
end

//pool_inc
logic pool0_req;
assign pool0_req=((next_state==`idle)||(next_state==`pool1_busy)||(next_state==`both_busy_pool0)||(next_state==`idle_pool1));

always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        pool0_inc<=0;
        pool1_inc<=0;
    end
    else if((opcode==`compute) || (opcode==`load_weight)) begin
            if(mode==`v_mode) begin
                if(pool0_req && (compute_counter_max||load_counter_max))
                    pool0_inc<=1;
                else if (!pool0_req && (compute_counter_max||load_counter_max))
                    pool1_inc<=1;
                else if((pool0_cnt==pool0_max_count))
                    pool0_inc<=0;
                else if((pool1_cnt==pool1_max_count))
                    pool1_inc<=0;
                else begin
                    pool0_inc<=pool0_inc;
                    pool1_inc<=pool1_inc;
                end
            end
           else begin
                if(pool0_req && ((sa_cnt==0)&& kh_cnt==2))
                    pool0_inc<=1;
                else if(!pool0_req && ((sa_cnt==0)&& kh_cnt==2))
                    pool1_inc<=1;
                else if((pool0_cnt==pool0_max_count))
                    pool0_inc<=0;
                else if((pool1_cnt==pool1_max_count))
                    pool1_inc<=0;
                else begin
                    pool0_inc<=pool0_inc;   
                    pool1_inc<=pool1_inc;
                end
            end
    end
end

//pool_max_count
always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        pool1_max_count<=0;
        pool0_max_count<=0;
    end
    else begin
        if((opcode== `load_weight)||(opcode==`compute)) begin
            if(pool0_req && !pool0_inc) begin
                if(mode==`h_mode)
                    pool0_max_count<=(sa_num<<3);
                else //vmode
                    pool0_max_count<=5'b01000;
            end
            else if (!pool0_req && !pool1_inc) begin
                if(mode==`h_mode)
                    pool1_max_count<=(sa_num<<3);
                else //vmode
                    pool1_max_count<=5'b01000;
            end
        end
        else begin
            pool0_max_count<=0;
            pool1_max_count<=0;
        end
    end
end

//FSM
logic pool_sel;
always_ff @(posedge clk or negedge rstn) begin
    if(!rstn)
        pool_sel<=1;
    else if(f_stage_en_d && ((opcode==`load_weight)||(opcode==`compute)))
        pool_sel<=!pool_sel;
end

logic pool_max;
assign pool_max=(pool_sel)?(pool1_next && (pool1_cnt!=0)):(pool0_next&&(pool0_cnt!=0));
logic pool_max_d;//setup after compute, f_stage_en fetch a cycle later when pool_cnt is maximum
always_ff @(posedge clk or negedge rstn) begin
    if(!rstn)
        pool_max_d<=1;
    else
        pool_max_d<=pool_max;
end


always_comb begin
    case(opcode)
	`setup: begin
        f_stage_en=1;//fetch stage enable
        cnt_stage_en=0;
        sram_r_CEN=1;
        sram_r_WEN=0;
        sram_r_addr=0;
	end
	`load_weight: begin
        //weight read address
        sram_r_addr= (base_weight_addr+sa_cnt*4+kh_cnt);
        sram_r_CEN=0;
        sram_r_WEN=1;

        //fetch stage enable
        f_stage_en=load_counter_max;

        //counter stage 
        cnt_stage_en= (need_cnt_d && !(kh_next&&sa_next))||f_stage_en_d ;
	end
	`compute: begin
        //input read address
        sram_r_addr= (base_input_addr+sa_cnt*4+kh_cnt);
        sram_r_CEN=0;
        sram_r_WEN=1;
        
        //fetch stage enable
        f_stage_en= (opcode_next==`load_weight) ? compute_counter_max : 
                    (opcode_next==`compute) ? compute_counter_max_dddd :  //stall for 2 cycle because of pooling counter hazard, stall for another 2 cycle because valid in should be set to high when ptr is 0,
                    (pool_max_d); 
        
        //counter stage 
        cnt_stage_en=need_cnt_d && !(kh_next&&sa_next) || f_stage_en_d;
    end
    default: begin
        f_stage_en=1;
        cnt_stage_en=0;
        sram_r_CEN=1;
        sram_r_WEN=0;
        sram_r_addr=0;
    end
    endcase
end

//sa_select, select the output of shifter to which sa.
always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
            sa_select[0]<=0;
    end
    else begin
        if((opcode==`compute)||(opcode==`load_weight))
            for(int i=0;i<=`SA_NUM-1;i++) begin
                if((sa_cnt==i)&&(kh_cnt>=1)|| ((sa_cnt==i+1)&&(kh_cnt<1)))
                    sa_select[0]<=i;
            end
    end
end

//Compute/load weight Stage
//after all the weights have shifted out sa input shifter

assign compute_counter_max=  (kh_cnt==2) && (sa_cnt==sa_num-2'b1) && (opcode==`compute);
assign load_counter_max= (kh_cnt==2) && (sa_cnt==sa_num-2'b1) && (opcode==`load_weight);
always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        load_counter_max_d<=0;
        load_counter_max_dd<=0;
        load_counter_max_ddd<=0;
        compute_counter_max_dddd<=0;
        compute_counter_max_ddd<=0;
        compute_counter_max_dd<=0;
        compute_counter_max_d<=0;
    end else begin
        load_counter_max_d<=load_counter_max;
        load_counter_max_dd<=load_counter_max_d;
        load_counter_max_ddd<=load_counter_max_dd;
        compute_counter_max_d<=compute_counter_max;
        compute_counter_max_dd<=compute_counter_max_d;
        compute_counter_max_ddd<=compute_counter_max_dd;
        compute_counter_max_dddd<=compute_counter_max_ddd;
    end
end

logic valid_in_curr;
logic valid_in_prev;
logic valid_switch;
always_ff@(posedge clk or negedge rstn) begin
    if(!rstn) begin
        valid_in_curr<=0;
        valid_in_prev<=0;
        valid_switch<=0;
    end
    else begin
        if( !valid_switch && (sa_cnt==0 && kh_cnt==0)&& ((opcode==`load_weight)||(opcode==`compute))) begin
            valid_in_prev<=1;
            valid_switch<=!valid_switch;
        end  
        else if(pool0_cnt==(pool0_max_count-3))
            valid_in_prev<=0;

        if( valid_switch && (sa_cnt==0 && kh_cnt==0) && ((opcode==`load_weight)||(opcode==`compute))) begin
            valid_in_curr<=1;
            valid_switch<=!valid_switch;
        end
        else if(pool1_cnt==(pool1_max_count-3))
            valid_in_curr<=0;


    end
end
assign valid_in=valid_in_curr||valid_in_prev;

always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        load_weight_en0<=0;
        load_weight_en1<=0;
        load_weight_en2<=0;
        load_weight_en3<=0;
    end else begin
            if((opcode==`load_weight)&&(sa_cnt==0 && kh_cnt==1))
                load_weight_en0<=1; 
            else if( load_counter_max_ddd)
                load_weight_en0<=0;
            else
                load_weight_en0<=load_weight_en0; 

        load_weight_en1<=load_weight_en0;
        load_weight_en2<=load_weight_en1;
        load_weight_en3<=load_weight_en2;
    end
end
demux demux0 (.in(load_weight_en0), .sel(sa_select[0]), .out(load_weight_en_line[0])); //load_weight_en_(line number) [(sa number)]
demux demux1 (.in(load_weight_en1), .sel(sa_select[1]), .out(load_weight_en_line[1])); 
demux demux2 (.in(load_weight_en2), .sel(sa_select[2]), .out(load_weight_en_line[2]));
demux demux3 (.in(load_weight_en3), .sel(sa_select[3]), .out(load_weight_en_line[3]));

//valid_in signal for shifter input, affects ptr in shifter.


//sa's pe enable signal

logic sa_pe_en0_curr;
logic sa_pe_en0_prev;

logic cnt_switch0;
                
logic [(`SA_NUM-1)*4-1:0] sa_pe_en_delayed;

assign sa_pe_en[0]=sa_pe_en0_curr||sa_pe_en0_prev;

generate
    for(genvar i=1; i<=`SA_NUM-1;i++)
        assign sa_pe_en[i]=sa_pe_en_delayed[3+(i-1)*4];
endgenerate

shifter_reg delay_shift (.in(sa_pe_en[0]),.clk(clk),.rstn(rstn),.delayed_out(sa_pe_en_delayed));
always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        sa_pe_en0_prev <= 1'b0;
        sa_pe_en0_curr <= 1'b0;
        cnt_switch0<=0;

    end
    else begin
         /////////////////////////prev
            if((!cnt_switch0)&&((sa_cnt==0)&&(kh_cnt==1))) begin
                    sa_pe_en0_prev <= 1'b1;
                    cnt_switch0<=!cnt_switch0;
            end

            for(int i=1; i<=2 ; i++) begin
                if(sa_num==i) begin
                    if(pool0_cnt==(pool0_max_count-(i-1)*4))
                        sa_pe_en0_prev <= 1'b0;
                end
            end

            for(int i=3; i<=`SA_NUM ; i++) begin
                if(sa_num==i) begin
                    if((mode==`v_mode)?(compute_counter_max_d||load_counter_max_d) :(pool0_cnt==pool0_max_count-8))
                        sa_pe_en0_prev <= 1'b0;
                end
            end
        /////////////////////////curr
            if((cnt_switch0)&&((sa_cnt==0)&&(kh_cnt==1))) begin
                    sa_pe_en0_curr <= 1'b1;
                    cnt_switch0<=!cnt_switch0;
            end

            for(int i=1; i<=2 ; i++) begin
                if(sa_num==i) begin
                    if(pool1_cnt==(pool1_max_count-(i-1)*4))
                        sa_pe_en0_curr <= 1'b0;
                end
            end

            for(int i=3; i<=`SA_NUM ; i++) begin
                if(sa_num==i) begin
                    if((mode==`v_mode)?(compute_counter_max_d||load_counter_max_d) :(pool1_cnt==pool1_max_count-8))
                        sa_pe_en0_curr <= 1'b0;
                end
            end
        end
end


//sa_select, select the output of shifter to which sa.
always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        sa_select[1]<=0;
        sa_select[2]<=0;
        sa_select[3]<=0;
    end else begin
        sa_select[1]<=sa_select[0];
        sa_select[2]<=sa_select[1];
        sa_select[3]<=sa_select[2];
    end
end

//pool stage
//pool

logic [`SA_NUM-1:0] pool_rd_mask ;

logic [3:0] pool_en0_temp;

generate 
    for (genvar i=0 ; i<=`SA_NUM-1 ;i++) begin
        assign pool_rd_en[i]=(mode==`h_mode)?({4{pool_rd_mask[i]}} & pool_en[i]):
                                        ((mode==`v_mode)&&(sa_num==i+1))?({4{pool_rd_mask[0]}} & pool_en[i]) : '0;
    end
endgenerate

logic pool_en_mask_prev;
logic pool_en_mask_curr;
logic pool_en_mask;

logic [(`SA_NUM-1)*4-1:0] [3:0]  pool_en_delayed ;

always_comb begin
    for(int i=0; i<=`SA_NUM-1 ;i++) begin
        if(i==0)
            pool_en[i] = (mode==`h_mode)? pool_en0_temp : ((mode==`v_mode)&&(sa_num==i+1)) ? pool_en0_temp : '0;
        else
            pool_en[i] = (mode==`h_mode)? pool_en_delayed[i*4-1] : ((mode==`v_mode)&&(sa_num==i+1)) ? pool_en0_temp : '0;
    end
end

assign pool_en_mask=pool_en_mask_prev||pool_en_mask_curr;

always_ff @(posedge clk or negedge rstn) begin
    if(!rstn)
        pool_en_mask_prev<=0;
    else if((pool0_cnt==0)&&((opcode==`load_weight)))
             pool_en_mask_prev<=0;
    else if(pool1_inc)
             pool_en_mask_prev<=1;
end
always_ff @(posedge clk or negedge rstn) begin
    if(!rstn)
        pool_en_mask_curr<=0;
    else if(pool1_cnt==0)
             pool_en_mask_curr<=0;
    else if(pool0_inc)
             pool_en_mask_curr<=1;
end

// modified
// always_ff @(posedge clk or negedge rstn) begin
//     for(int i=0; i<=`SA_NUM-1;i++) begin
//         if(!rstn)
//             pool_rd_mask[i]<=0;
//         else if((pool0_cnt==1+i*4)||(pool1_cnt==1+i*4))
//                 pool_rd_mask[i]<=0;
//         else if((pool0_cnt==5+i*4)||(pool1_cnt==5+i*4))
//                 pool_rd_mask[i]<=1;
//     end
// end

always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) 
        pool_rd_mask <= 0;
    else begin
        for(int i=0; i<=`SA_NUM-1;i++) begin
            if((pool0_cnt==1+i*4)||(pool1_cnt==1+i*4))
                pool_rd_mask[i]<=0;
            else if((pool0_cnt==5+i*4)||(pool1_cnt==5+i*4))
                pool_rd_mask[i]<=1;
        end
    end
end


always_ff @(posedge clk or negedge rstn) begin
    if(!rstn)
        pool_en0_temp<=0;
    else if(pool_en_mask&&((pool0_cnt==1)||(pool0_cnt==5)||(pool0_cnt==9)||(pool0_cnt==13)||(pool1_cnt==1)||(pool1_cnt==5)||(pool1_cnt==9)||(pool1_cnt==13)))
        pool_en0_temp<=4'b0001;
    else if(pool_en_mask&&(pool0_cnt!=0) || (pool1_cnt!=0))
        pool_en0_temp<={pool_en0_temp[2:0],pool_en0_temp[3]};
    else
        pool_en0_temp<=0;

end
shifter_reg_4bits pool_en_delay_shifter (.clk(clk),.in(pool_en[0]),.rstn(rstn),.shift(pool_en_delayed));

// Write Back stage
// WB enable signal following the pooling counter
assign sram_set_w_base_addr=(opcode==`setup);
assign sram_w_base_addr=base_output_addr;
// always_comb begin
//     if(sram_wr_en) begin
//         sram_w_WEN<=0;
//         sram_w_CEN<=0;
//     end
//     else begin
//         sram_w_WEN<=0;
//         sram_w_CEN<=1;
//     end

// end
endmodule



