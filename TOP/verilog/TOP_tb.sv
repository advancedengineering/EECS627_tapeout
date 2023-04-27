import DEFINE_PKG::*;

//stretch arrays are for delayed input and output/ie. the 0s
typedef bit [`BIT_WIDTH-1:0] normal_arr_in_t [][];
typedef bit [`SA_OUTPUT_WIDTH-1:0]  normal_arr_out_t [][];
typedef sram_addr_t[1:0] sram_addr_arr_t; 
typedef struct{
    sram_addr_t addr;
    bit [`SA_OUTPUT_WIDTH-1:0] data;
}sram_ent_t;
typedef sram_ent_t sram_ent_arr_t[];

typedef class matrix_pkt;
typedef class seq_item;
typedef class driver;
typedef class monitor;
typedef class env;





// ############ change the sequence in run() ##################
class generator;
    mailbox drv_mbx;
    event drv_done;

    task run();
        seq_item spkt;
        sram_addr_arr_t cur_addr;
        int id = 1;
        cur_addr = '0;

        for (int i=0; i<1; ++i)begin
            spkt = new(.id(id));
            spkt.randomize();
            cur_addr = spkt.p_randomize(cur_addr);
            drv_mbx.put(spkt);
            id += 1;
            @(drv_done);
        end
    endtask;

endclass


module testbench();
    logic clk;
    logic resetn;
    logic [16:0]cyc_cnt;
    //######## controller ############
    top_if t_if(clk, resetn, cyc_cnt);
    env e0;

    controller c0 (
        .clk(t_if.clk), .rstn(t_if.rstn), .inst(t_if.inst),
        // .sram_wr_en(t_if.sram_wr_en),
        .bit_mode_o(t_if.bit_mode),
        .is_sign_o(t_if.is_sign), 
        .mode_o(t_if.mode),
        .sa_num_o(t_if.sa_num),
        .sa_select_o(t_if.sa_select),
        .load_weight_en_line_o(t_if.load_weight_en_line),
        .sa_pe_en_o(t_if.sa_pe_en),
        .valid_in_o(t_if.valid_in),
        .pool_en_o(t_if.pool_en),
        .pool_rd_en_o(t_if.pool_rd_en),
        .sram_w_base_addr_o(t_if.sram_w_base_addr), 
        .sram_set_w_base_addr_o(t_if.sram_set_w_base_addr),
        .sram_r_addr_o(t_if.sram_r_addr),
        .sram_r_WEN_o(t_if.sram_r_WEN), //sram write enable
        .sram_r_CEN_o(t_if.sram_r_CEN),//sram write/read chip enable
        .sram_w_WEN_o(t_if.sram_w_WEN), 
        .sram_w_CEN_o(t_if.sram_w_CEN),
        .f_stage_en(t_if.f_stage_en)
    );

    // ########### shifter ###########


    shifter shift0(
        .shift_in(t_if.shift_in),
        .valid_in(t_if.valid_in), //arrives with data from buffer, 
        .clk(t_if.clk),
        .rstn(t_if.rstn),
        .shift_out(t_if.shift_out)
    );



    // ########## SA_ARRAY #########

    
    SA_array_part SA_p0(
        .clk(clk),
        .resetn(t_if.rstn),
        .control_signal(t_if.mode), // comes from the controller(), decides SAs to be vertically or horizontally arranged. 1: vertical(), 0: horizontal
        .SA_select(t_if.sa_select), //decides which SA to stream inputs into when in vertical mode
        .SA_num(t_if.sa_num), //Decides how many SAs does this computation need
        .PE_enable(t_if.sa_pe_en), //Decides which SA need to enable PE
        .load_weight_en_line(t_if.load_weight_en_line), //Decides which SA row needs to load weight
        .pool_reset(t_if.pool_en),
        .out_model(t_if.bit_mode),    //1 for 4bit mult(), 0 for 2bit mult
        .is_signed(t_if.is_sign),         //Sign or unsigned multiplication       
        .in0({t_if.shift_out[15:12], t_if.shift_out[11:8], t_if.shift_out[7:4], t_if.shift_out[3:0]}),  //assuming buffer sends in 1 row per cycle from read port
        .sram_w_base_addr(t_if.sram_w_base_addr),
        .sram_set_w_base_addr(t_if.sram_set_w_base_addr),
        .pool_rd_en(t_if.pool_rd_en),
        .pool_rd_en_out(t_if.pool_rd_en_out),
        .fifo_wr_addr(t_if.fifo_wr_addr),
        .pool_out(t_if.pool_out)
    );

    write_back_part WB_p0(
        .clk(clk),
        .resetn(t_if.rstn),
        .pool_rd_en(t_if.pool_rd_en_out),
        .pool_out(t_if.pool_out),
        .fifo_wr_addr(t_if.fifo_wr_addr),
        .sram_wr_addr(t_if.sram_wr_addr),
        .sram_wr_data(t_if.sram_wr_data),
        .sram_wr_en(t_if.sram_wr_en),
        .fifo_full_out(t_if.fifo_full)
    );

    //input and weight
    sram sram0 (
        //scan in / write
        .ADRA(t_if.scan_in_addr),
        .DA(t_if.scan_in_data),
        .WEA(1'b1), //write enable
        .OEA(1'b0), //output enable
        .MEA(t_if.scan_in_en),          //memory enable
        .CLKA(t_if.clk),
        .RMA(4'b1110),
        .QA(t_if.sram0_QA),
        
        //shift in / read
        .ADRB(t_if.sram_r_addr),
        .DB('0),
        .WEB(1'b0),
        .OEB(1'b1),
        .MEB(~t_if.sram_r_CEN),
        .CLKB(clk),
        .RMB(4'b1110),
        .QB(t_if.shift_in)
    );

    //output
    sram sram1 (
        //output / write
        .ADRA(t_if.sram_wr_addr),
        .DA({3'b000,t_if.sram_wr_data}),
        .WEA(1'b1), //write enable
        .OEA(1'b0), //output enable
        .MEA(t_if.sram_wr_en),          //memory enable
        .CLKA(clk),
        .RMA(4'b1110),
        .QA(t_if.sram1_QA),
        
        //scan out /read
        .ADRB(t_if.scan_out_addr),
        .DB('0),
        .WEB(1'b0),
        .OEB(1'b1),
        .MEB(t_if.scan_out_en),
        .CLKB(t_if.clk),
        .RMB(4'b1110),
        .QB(t_if.scan_out_data)
    );

`ifndef APR
    generate
        for(genvar i = 0; i< `SA_NUM; ++i)begin
            for(genvar j = 0; j< `DIMENSION; ++j)begin
                for(genvar k = 0; k< `DIMENSION; ++k)begin
                    if((j == 0) || (j ==  `DIMENSION-1)) begin
                        assign t_if.SA_weight[i][j][k] = SA_p0.gen_SA_inst[i].SA_inst.gen_sa_row[j].gen_sa_col[k].genblk1.genblk1.PE_ij.weight;
                    end else begin
                        assign t_if.SA_weight[i][j][k] = SA_p0.gen_SA_inst[i].SA_inst.gen_sa_row[j].gen_sa_col[k].genblk1.PE_ij.weight;
                    end
                end
            end
        end
    endgenerate
`endif



    //--- Clock Generation Block ---//
    always
    begin
        #(5) clk=~clk;
    end


    always @ (posedge clk)begin
        if (~resetn)begin
            cyc_cnt <= 0;
        end else begin
            cyc_cnt <= cyc_cnt + 1;
        end
    end

    //--- Value Setting Block ---//
    initial begin
        $dumpfile("sim.dump.vcd"); 
        $dumpvars(0, testbench);
        // $fsdbDumpfile("TB.fsdb");
        // $fsdbDumpvars(0, testbench); 

        $sdf_annotate("sdf/SA_array_part.apr.sdf",SA_p0,,,"MAXIMUM"); 
        $sdf_annotate("sdf/write_back_part.apr.sdf", WB_p0,,,"MAXIMUM");  
        $sdf_annotate("sdf/controller.apr.sdf", c0,,,"MAXIMUM");  
        $sdf_annotate("sdf/shifter.apr.sdf", shift0,,,"MAXIMUM"); 
    end


    initial begin
        clk = 0;
        resetn = 0;
        e0 = new;
        e0.t_if = t_if;
        t_if.inst = gen_instruction(.opcode(3'b111));
        t_if.scan_in_en = 0;
        t_if.scan_out_en = 0;

        t_if.fd_pkt = $fopen("tb_pkt.txt", "w");
        t_if.fd_check = $fopen("tb_weight_check.txt", "w");
        t_if.fd_check2 = $fopen("tb_pool_out_check.txt", "w");
        t_if.fd_check3 = $fopen("tb_wb_check.txt", "w");

        $fdisplay(t_if.fd_pkt, "--Start of File--");
        $fdisplay(t_if.fd_check, "--Start of File--");
        $fdisplay(t_if.fd_check2, "--Start of File--");
        $fdisplay(t_if.fd_check3, "--Start of File--");
        $display("############");
        

        @(negedge clk);
        @(negedge clk);
        resetn=1;
        e0.run();

        #100;
        $fclose(t_if.fd_pkt);
        $fclose(t_if.fd_check);
        $fclose(t_if.fd_check2);
        $fclose(t_if.fd_check3);
        $finish;
    end

    
endmodule //testbench




//generate random input and weight matrix
class matrix_pkt;
    rand normal_arr_in_t in;
    rand normal_arr_in_t w;
    normal_arr_out_t out;
    normal_arr_out_t pool_out;
    bit mode; //1->v;  0 = h
    bit [$clog2(`SA_NUM):0] sa_num;
    bit bit_mode;  //0->2bit; 1->4bit
    bit is_signed;
    int unsigned id;
    sram_addr_t output_addr;

    function matrix_pkt copy();
        matrix_pkt cp;
        cp = new(.inst('1));
        cp.in = this.in;
        cp.w = this.w;
        cp.out = this.out;
        cp.pool_out = this.pool_out;
        cp.mode = this.mode;
        cp.sa_num = this.sa_num;
        cp.bit_mode = this.bit_mode;
        cp.is_signed = this.is_signed;
        cp.id = this.id;
        return cp;
    endfunction

    function new(inst_t inst, int unsigned id = 0, sram_addr_t output_addr = 0);
        /*
            input matrix = IN_V * W_V;
            weight matrix = W_V * W_H;
            out matrix =   IN_V * W_H
        */
        int W_V;
        int W_H;
        int IN_V;

        if(inst[`INST_SIZE-1:`INST_SIZE-3] == 3'b000)begin
            this.mode = inst[`INST_SIZE-4];
            this.sa_num = inst[7:4];
            this.bit_mode = inst[8]; 
            this.is_signed = inst[3];
            if(mode)begin // vmode
                W_V = sa_num * 4;
                W_H = 4;
                IN_V = 4;
            end else begin // hmode
                IN_V = sa_num * 4;
                W_V = 4;
                W_H = sa_num * 4;
            end
        end else begin
            W_V = 12; 
            W_H = 4;
            IN_V = 4; 
            this.is_signed = 1'b1;
            if(inst!= '1)
                $error("pkt constructor with non setup instruction");
        end

        this.id = id;
        this.output_addr = output_addr;

        this.in = new[IN_V];
        this.w = new[W_V];
        this.out = new[IN_V];
        this.pool_out = new[IN_V/4];

        foreach (this.in[i])begin
            this.in[i] = new[W_V];
        end

        foreach(this.w[i])begin
            this.w[i] = new[W_H];
        end

        foreach(this.out[i])
            this.out[i] = new[W_H];

        foreach (this.pool_out[i])
            this.pool_out[i] = new[W_H];
    endfunction


    function void matrix_mult();
        bit [`SA_OUTPUT_WIDTH-1:0] sum;
        for(int i=0; i<out.size(); ++i)begin
            for(int j=0; j<out[0].size(); ++j)begin
                sum = '0;
                for(int k=0; k<in[0].size(); ++k)begin
                    if(this.is_signed)begin   
                        if(this.bit_mode)begin //4bit   
                            sum = $signed(sum) + $signed(in[i][k]) * $signed(w[k][j]);
                        end else begin //2bit
                            sum = $signed(sum) + $signed(in[i][k][3:2]  * w[k][j][3:2]) + $signed(in[i][k][1:0] * w[k][j][1:0]);
                        end
                    end else begin
                        if(this.bit_mode)begin //4bit   
                            sum += in[i][k] * w[k][j];
                        end else begin
                            sum = sum + in[i][k][3:2]  * w[k][j][3:2] + in[i][k][1:0] * w[k][j][1:0];
                        end
            //        $display("i=%d, j=%d, k=%d, sum=%d, A[i][k]=%d, B[k][j]=%d", i, j, k, $signed(sum), $signed(A[i][k]), $signed(B[k][j]));
                    end
                end
                out[i][j] = sum;
            end
        end

        for(int i=0; i<pool_out.size(); ++i) begin
            for(int j=0; j<pool_out[0].size(); ++j) begin
                bit[`SA_OUTPUT_WIDTH-1:0] tmp_arr[4];
                bit[`SA_OUTPUT_WIDTH-1:0] tmp_max[$];
                for (int z = 0; z < 4; ++z)begin
                    tmp_arr[z] = (this.is_signed & out[i*4+z][j][3*(`BIT_WIDTH)-1]) ? '0 : out[i*4+z][j];
                end
                tmp_max = tmp_arr.max();
                pool_out[i][j] = tmp_max[0];
            end

        end
    endfunction

    function void print_pkt(bit pt_w = 1'b1);
        $display("Input Matrix:");
        print_normal_in(this.in, this.is_signed);
        if(pt_w)begin
            $display("Weight Matrix:");
            print_normal_in(this.w, this.is_signed);
        end
        $display("Output Matrix");
        print_normal_out(this.out, this.is_signed);
    endfunction

    function void fprint_pkt(int fd, bit pt_w = 1'b1, int rp = 0);
        $fdisplay(fd, "\n########");
        $fdisplay(fd, "Sequence ID = %0d, repeat = %0d", this.id, rp);
        $fdisplay(fd, "Input Matrix:");
        fprint_normal_in(fd, this.in, this.is_signed);
        $fdisplay(fd, "\n");
        if(pt_w)begin
            $fdisplay(fd, "Weight Matrix:");
            fprint_normal_in(fd, this.w, this.is_signed);
            $fdisplay(fd, "\n");
        end
        $fdisplay(fd, "Expected Output Matrix");
        fprint_normal_out(fd, this.out, this.is_signed);
        $fdisplay(fd, "\n");
        $fdisplay(fd, "Expected Pool Out Matrix");
        fprint_normal_out(fd, this.pool_out, this.is_signed);
        $fdisplay(fd, "########\n\n");
    endfunction
endclass

class seq_item;

    sram_addr_t weight_addr;
    sram_addr_t input_addr;
    sram_addr_t output_addr;
    rand bit mode; //1->v;  0 = h
    rand bit [$clog2(`SA_NUM):0] sa_num;
    rand bit bit_mode;  //0->2bit; 1->4bit
    rand bit is_signed;
    rand int unsigned num_repeat; //how many times the input will be repeated
    int unsigned id;

    // function new( bit mode = 1'b1, bit [$clog2(`SA_NUM):0] sa_num = 3, bit bit_mode = 1'b1, bit is_signed = 1'b1, bit[3:0] num_repeat = 1, int unsigned id = 0);
    //     this.mode =  mode;
    //     this.sa_num =  sa_num;
    //     this.bit_mode =  bit_mode;
    //     this.is_signed =  is_signed;
    //     this.num_repeat = num_repeat;
    //     this.id = id;
    // endfunction

    function new(int unsigned id = 0);
        this.id = id;
    endfunction

    function sram_addr_arr_t p_randomize(sram_addr_arr_t prev_addr); 
        /*  
            weight matrix = W_V * W_H;
            input matrix = IN_V * W_V;   
            out matrix =   IN_V * W_H
        */
        sram_addr_arr_t nxt_addr;
        int W_V;
        int W_H;
        int IN_V;
        int IN_Mat_SIZE;
        int W_Mat_SIZE;
        int Out_Mat_SIZE;
        if(mode)begin // vmode
            W_V = sa_num * 4;
            W_H = 4;
            IN_V = 4;
        end else begin // hmode
            IN_V = sa_num * 4;
            W_V = 4;
            W_H = sa_num * 4;
        end
        W_Mat_SIZE = W_V * W_H/4;
        IN_Mat_SIZE = IN_V * W_V/4;
        Out_Mat_SIZE = IN_V/4 * W_H;

        if((1024 - prev_addr[0]) > ( W_Mat_SIZE + IN_Mat_SIZE * this.num_repeat)) 
            this.weight_addr = prev_addr[0];
        else
            this.weight_addr = '0;

        this.input_addr = this.weight_addr + W_Mat_SIZE;

        if((1024 - prev_addr[1]) > (Out_Mat_SIZE* this.num_repeat))
            this.output_addr = prev_addr[1];
        else
            this.output_addr = '0;
        
        nxt_addr[0] = this.weight_addr + W_Mat_SIZE + IN_Mat_SIZE * this.num_repeat;
        nxt_addr[1] = this.output_addr + Out_Mat_SIZE * this.num_repeat;
        return nxt_addr;
    endfunction

    constraint hmode_c {
        // solve mode before num_repeat;
        // solve bit_mode before is_signed;
        // (~mode) -> (num_repeat == 1);
        // (~bit_mode) -> (is_signed == 0);
        // sa_num != 0;
        // sa_num < `SA_NUM;
        // num_repeat < 10;

        num_repeat == 5;
        bit_mode == 1;
        is_signed == 1;
        mode == 1;
        sa_num == `SA_NUM;

    }

endclass


class driver;
    // virtual control_if cif;
    virtual top_if t_if;
    event drv_done;
    mailbox drv_mbx;
    mailbox load_mbx;
    mailbox comp_mbx;
    int wait_cyc;

    task run();
        wait_cyc = 0;

        forever begin
            seq_item spkt;
            matrix_pkt pkt;
            sram_addr_t w_addr;

            //wait for previous hmode
            while(wait_cyc > 0)begin
                t_if.inst = gen_instruction(.opcode(3'b111));
                wait_cyc -= 1;
                @(negedge t_if.clk);
            end
            drv_mbx.get(spkt);
            // $display("cyc = %0d, Driver received new sequence; sequence ID = %3d, mode = %0b, sa_num = %0d, num_repeat = %0d, is_signed = %0d, bit_mode = %0b",
            //          t_if.cyc_cnt, spkt.id, spkt.mode, spkt.sa_num, spkt.num_repeat, spkt.is_signed, spkt.bit_mode);
            $fdisplay(t_if.fd_pkt, "cyc = %0d, mode = %0b, bit_mode = %0b, sa_num = %0d, is_signed = %0b, num_repeat = %0d, sequence ID = %3d", t_if.cyc_cnt, spkt.mode, spkt.bit_mode, spkt.sa_num, spkt.is_signed, spkt.num_repeat, spkt.id);
            //setup
            wait_next_f_en(); 
            t_if.inst = gen_instruction(.opcode(3'd0), .mode(spkt.mode), .bit_mode(spkt.bit_mode), .sa_num(spkt.sa_num), .is_signed(spkt.is_signed));
            pkt=new(.inst(t_if.inst), .id(spkt.id), .output_addr(spkt.output_addr));
            pkt.randomize();
            pkt.matrix_mult();
            pkt.fprint_pkt(.fd(t_if.fd_pkt));

            @(negedge t_if.clk)
        
            //load base address
            wait_next_f_en();           
            t_if.inst = gen_instruction(.opcode(3'b011), .base_addr(spkt.weight_addr));
            @(negedge t_if.clk)
            t_if.inst = gen_instruction(.opcode(3'b100), .base_addr(spkt.input_addr));
            @(negedge t_if.clk)
            t_if.inst = gen_instruction(.opcode(3'b101), .base_addr(spkt.output_addr));
            @(negedge t_if.clk)
            $display("cyc: %0d, id: %0d, w_addr: %0d, in_addr: %0d, out_addr: %0d",
                    t_if.cyc_cnt, pkt.id, spkt.weight_addr, spkt.input_addr, spkt.output_addr);

            // //write weight and input into sram////////////
            fork begin
                w_addr = spkt.weight_addr;
                t_if.scan_in_en = 1;
                if(~spkt.mode) begin //hmode
                    for (int j =0; j< spkt.sa_num; j++)begin //weight
                        for(int i=0; i< 4; i++)begin
                            t_if.scan_in_addr = w_addr;
                            t_if.scan_in_data = {pkt.w[i][0+4*j], pkt.w[i][1+4*j], pkt.w[i][2+4*j], pkt.w[i][3+4*j]};
                            @(negedge t_if.clk);
                            w_addr += 1;
                        end 
                    end

                    for (int j =0; j< spkt.sa_num; ++ j)begin //input
                        for(int i=0; i< 4;i++)begin
                            t_if.scan_in_addr = w_addr;
                            t_if.scan_in_data = {pkt.in[3+4*j][i], pkt.in[2+4*j][i], pkt.in[1+4*j][i], pkt.in[0+4*j][i]};
                            @(negedge t_if.clk);
                            w_addr += 1;
                        end
                    end
                end else begin //vmode
                    for(int i=0; i< spkt.sa_num * 4;i++)begin //w
                        t_if.scan_in_addr = w_addr;
                        t_if.scan_in_data = {pkt.w[i][0], pkt.w[i][1], pkt.w[i][2], pkt.w[i][3]};
                        @(negedge t_if.clk);
                        w_addr += 1;
                    end

                    for(int i=0; i< spkt.sa_num * 4;i++)begin //in
                        t_if.scan_in_addr = w_addr;
                        t_if.scan_in_data = {pkt.in[3][i], pkt.in[2][i], pkt.in[1][i], pkt.in[0][i]};
                        @(negedge t_if.clk);
                            w_addr += 1;
                    end
                end

                t_if.scan_in_en = 0;        
            end join_none
            ////////////////////////////////////////

            t_if.inst=gen_instruction(.opcode(3'b001));//loadweight
            @(negedge t_if.clk);
            t_if.inst=gen_instruction(.opcode(3'b010));//compute
            @(negedge t_if.clk); //counter
            

            fork begin        
                if(~spkt.mode)begin// hmode
                    while(~t_if.valid_in)begin
                        @(negedge t_if.clk);
                    end
                    load_mbx.put(pkt);
                    for (int j =0; j< spkt.sa_num; j++)begin //load weight
                        for(int i=0; i< 4; i++)begin
                            // t_if.shift_in = {pkt.w[i][0+4*j], pkt.w[i][1+4*j], pkt.w[i][2+4*j], pkt.w[i][3+4*j]};
                            if(t_if.shift_in != {pkt.w[i][0+4*j], pkt.w[i][1+4*j], pkt.w[i][2+4*j], pkt.w[i][3+4*j]})begin
                                $display("cyc: %0d, id: %0d, weight shift_in mismatch", t_if.cyc_cnt, pkt.id);
                            end
                            @(negedge t_if.clk);
                        end 
                    end

                    for (int i=0; i< 4; ++ i)begin
                        @(negedge t_if.clk);
                    end

                    for (int r =0; r< spkt.num_repeat; ++r)begin //compute
                        matrix_pkt pkt_tmp;

                        if(r != 0)begin
                            //4 cycles between compute
                            @(negedge t_if.clk);
                            pkt.w.rand_mode(0);
                            pkt.randomize();
                            pkt.matrix_mult();
                            pkt.fprint_pkt(.fd(t_if.fd_pkt), .pt_w(1'b0), .rp(r));
                            
                            // write repeated input into sram
                            fork begin
                                t_if.scan_in_en = 1;
                                for (int j =0; j< spkt.sa_num; ++ j)begin //input
                                    for(int i=0; i< 4;i++)begin
                                        t_if.scan_in_addr = w_addr;
                                        t_if.scan_in_data = {pkt.in[3+4*j][i], pkt.in[2+4*j][i], pkt.in[1+4*j][i], pkt.in[0+4*j][i]};
                                        @(negedge t_if.clk);
                                        w_addr += 1;
                                    end
                                end
                                t_if.scan_in_en = 0;
                            end join_none
                            //

                            for(int i=0; i<3; ++i)begin
                                @(negedge t_if.clk);
                            end
                            
                        end 

                        pkt_tmp = pkt.copy();
                        pkt_tmp.output_addr = pkt.output_addr + r * pkt.pool_out[0].size() * pkt.pool_out.size();
                        comp_mbx.put(pkt_tmp);

                        for (int j =0; j< spkt.sa_num; ++ j)begin
                            for(int i=0; i< 4;i++)begin
                                // t_if.shift_in = {pkt.in[3+4*j][i], pkt.in[2+4*j][i], pkt.in[1+4*j][i], pkt.in[0+4*j][i]};
                                if(t_if.shift_in != {pkt.in[3+4*j][i], pkt.in[2+4*j][i], pkt.in[1+4*j][i], pkt.in[0+4*j][i]})begin
                                    $display("cyc: %0d, id: %0d, input shift_in mismatch, expected: %0x", t_if.cyc_cnt, pkt.id, {pkt.in[3+4*j][i], pkt.in[2+4*j][i], pkt.in[1+4*j][i], pkt.in[0+4*j][i]});
                                end
                                @(negedge t_if.clk);
                            end
                        end

                    end

                    wait_cyc += pkt.pool_out[0].size() * pkt.pool_out.size();

                    
                end else begin //vmode
                    while(~t_if.valid_in)begin
                        @(negedge t_if.clk);
                    end 
                    load_mbx.put(pkt);
                    for(int i=0; i< spkt.sa_num * 4;i++)begin //load  weight
                        // t_if.shift_in = {pkt.w[i][0], pkt.w[i][1], pkt.w[i][2], pkt.w[i][3]};
                        if(t_if.shift_in != {pkt.w[i][0], pkt.w[i][1], pkt.w[i][2], pkt.w[i][3]})begin
                            $display("cyc: %0d, id: %0d, input shift_in mismatch, expected: %0x", t_if.cyc_cnt, pkt.id, {pkt.w[i][0], pkt.w[i][1], pkt.w[i][2], pkt.w[i][3]});
                        end
                        @(negedge t_if.clk);
                    end
                    for (int i=0; i< 4; ++ i)begin
                        @(negedge t_if.clk);
                    end
                    for (int r =0; r< spkt.num_repeat; ++r)begin
                        matrix_pkt pkt_tmp;
                        if(r != 0)begin
                            //4 cycles between compute
                            // t_if.shift_in = '0;
                            @(negedge t_if.clk); 
                            pkt.w.rand_mode(0);
                            pkt.randomize();
                            pkt.matrix_mult();
                            pkt.fprint_pkt(.fd(t_if.fd_pkt), .pt_w(1'b0), .rp(r)); 

                            // write repeated input into sram
                            fork begin
                                t_if.scan_in_en = 1;
                                for(int i=0; i< spkt.sa_num * 4;i++)begin //in
                                    t_if.scan_in_addr = w_addr;
                                    t_if.scan_in_data = {pkt.in[3][i], pkt.in[2][i], pkt.in[1][i], pkt.in[0][i]};
                                    @(negedge t_if.clk);
                                    w_addr += 1;
                                end
                                t_if.scan_in_en = 0;
                            end join_none
                            /////
                            for(int i=0; i<3; ++i)begin
                                @(negedge t_if.clk);
                            end
                                                         
                        end
                        
                        pkt_tmp = pkt.copy();
                        pkt_tmp.output_addr = pkt.output_addr + r * pkt.pool_out[0].size() * pkt.pool_out.size();
                        comp_mbx.put(pkt_tmp);
                        
                        for(int i=0; i< spkt.sa_num * 4;i++)begin //compute
                            // t_if.shift_in = {pkt.in[3][i], pkt.in[2][i], pkt.in[1][i], pkt.in[0][i]};
                            if(t_if.shift_in != {pkt.in[3][i], pkt.in[2][i], pkt.in[1][i], pkt.in[0][i]})begin
                                $display("cyc: %0d, id: %0d, input shift_in mismatch, expected: %0x", t_if.cyc_cnt, pkt.id, {pkt.in[3][i], pkt.in[2][i], pkt.in[1][i], pkt.in[0][i]});
                            end
                            @(negedge t_if.clk);
                        end
                    end


                end
                // t_if.shift_in = '0;
            end join_none


            for (int r =0; r< spkt.num_repeat; ++r)begin
                @(negedge t_if.clk);
                wait_next_f_en();
            end
            ->drv_done;

        end

    endtask



    task wait_next_f_en();
        while(~t_if.f_stage_en)begin
            @(negedge t_if.clk);
        end    
    endtask


endclass




class monitor;
    mailbox load_mbx;
    mailbox comp_mbx;
    semaphore sem;
    virtual top_if t_if;

    task run();
        fork
            //lw_check();
            comp_check();
        join
    endtask

    task lw_check();
        //check for load weight
        forever begin
            matrix_pkt pkt;
            normal_arr_in_t rtl_w;
            bit error;
            load_mbx.get(pkt);

            error = 0;

            rtl_w = new[pkt.w.size()];
            foreach (rtl_w[i])begin
                rtl_w[i] = new[pkt.w[0].size()];
            end

            //wait until all weights are loaded
            for(int i=0; i< 4 * pkt.sa_num + 6; ++i)begin
                @(negedge t_if.clk);
            end

            if(pkt.mode)begin//vmode
                for(int i = 0; i< pkt.sa_num; ++i)begin
                    for(int j = 0; j < `DIMENSION; ++j) begin
                        for(int k=0; k< `DIMENSION; ++k)begin
                            rtl_w[i*4 + j][k] = t_if.SA_weight[i][j][k];
                        end
                    end
                end
            end else begin //hmode
                for(int i = 0; i< pkt.sa_num; ++i)begin
                    for(int j = 0; j < `DIMENSION; ++j) begin
                        for(int k=0; k< `DIMENSION; ++k)begin
                            rtl_w[j][k + i*4] = t_if.SA_weight[i][j][k];
                        end
                    end
                end
            end
            for (int i=0; i< rtl_w.size(); ++i)begin
                for(int j =0; j< rtl_w[0].size(); ++j)begin
                    if(rtl_w[i][j] != pkt.w[i][j])begin
                        error = 1;
                    end
                end
            end
            if(error)begin
                $display("ERROR! Load Weight check failed:  cyc: %3d, ID: %2d", t_if.cyc_cnt, pkt.id);
                $fdisplay(t_if.fd_check, "\n\n##############\n cyc: %3d, ID: %2d, Weight mismatch:\nExpected:", t_if.cyc_cnt, pkt.id);
                fprint_normal_in(t_if.fd_check, pkt.w, pkt.is_signed);
                $fdisplay(t_if.fd_check, "actual: ");
                fprint_normal_in(t_if.fd_check, rtl_w, pkt.is_signed);
            end
        end
    endtask;

    task comp_check();
        forever begin
            matrix_pkt pkt;
            bit error, error2;
            normal_arr_out_t rtl_pool_out;
            sram_ent_arr_t rtl_wb;
            sram_ent_arr_t golden_wb;
            comp_mbx.get(pkt);

            //delay 2 cycles for register retiming
            for(int i=0; i<2; ++i)begin
                @(negedge t_if.clk);
            end
// `ifndef APR
            fork begin
                error = 0;
                rtl_pool_out = new[pkt.pool_out.size()];
                foreach (rtl_pool_out[i])begin
                    rtl_pool_out[i] = new[pkt.pool_out[0].size()];
                end

                rtl_wb = new[pkt.pool_out.size() * pkt.pool_out[0].size()];
                golden_wb = new[pkt.pool_out.size() * pkt.pool_out[0].size()];

                if(pkt.mode) begin//vmode
                    for(int i=0; i< 4 * pkt.sa_num + 4; ++i)begin
                        @(negedge t_if.clk);
                    end

                    for(int i = 0; i< `DIMENSION; ++i)begin
                        if (~t_if.pool_rd_en_out[pkt.sa_num-1][i])begin
                            $display("Error! Cyc: %0d, id: %0d, pool_rd_en[%0d][%0d] should be high", t_if.cyc_cnt, pkt.id,  pkt.sa_num-1, i);
                        end
                        rtl_pool_out[0][i] = t_if.pool_out[pkt.sa_num-1];
                        @(negedge t_if.clk);
                    end

                end else begin //hmode
                    for(int i=0; i< 4 + 4; ++i)begin
                        @(negedge t_if.clk);
                    end

                    for(int z = 0; z < pkt.sa_num; ++z)begin
                        if(z+1 != pkt.sa_num)begin //1:N-1 SA
                            fork
                            begin
                                int tmp_z = z;
                                for(int j = 0; j< rtl_pool_out.size(); ++j)begin
                                    for(int i = 0; i< `DIMENSION; ++i)begin
                                        if (~t_if.pool_rd_en_out[tmp_z][i])begin
                                            $display("Error! Cyc: %0d, id: %0d, pool_rd_en[%0d][%0d] should be high", t_if.cyc_cnt, pkt.id, tmp_z, i);
                                        end

                                        rtl_pool_out[j][i+4*tmp_z] = t_if.pool_out[tmp_z];

                                        if(rtl_pool_out[j][i+4*tmp_z] != pkt.pool_out[j][i+4*tmp_z])begin
                                            error = 1;
                                        end
                                        @(negedge t_if.clk);
                                    end
                                end
                            end
                            join_none

                            for(int t = 0; t< 4; ++t)begin 
                                @(negedge t_if.clk);
                            end
                        end else begin //last SA
                            begin
                                for(int j = 0; j< rtl_pool_out.size(); ++j)begin
                                    for(int i = 0; i< `DIMENSION; ++i)begin
                                        if (~t_if.pool_rd_en_out[z][i])begin
                                            $display("Error! Cyc: %0d, id: %0d, pool_rd_en[%0d][%0d] should be high", t_if.cyc_cnt, pkt.id, z, i);
                                        end

                                        rtl_pool_out[j][i+4*z] = t_if.pool_out[z];

                                        if(rtl_pool_out[j][i+4*z] != pkt.pool_out[j][i+4*z])begin
                                            $display("ERROR! Pool Out check failed:  cyc: %3d, ID: %2d, expected:%0x, actual:%0x", t_if.cyc_cnt, pkt.id, pkt.pool_out[j][i+4*z], rtl_pool_out[j][i+4*z]);
                                            error = 1;
                                        end
                                        @(negedge t_if.clk);
                                    end
                                end
                            end
                        end
                    end    //for z
                end //else hmode



                if(error)begin
                    $display("ERROR! Pool Out check failed:  cyc: %3d, ID: %2d", t_if.cyc_cnt, pkt.id);
                    // print_normal_out(pkt.pool_out, pkt.is_signed);
                    // print_normal_out(rtl_pool_out, pkt.is_signed);
                    $fdisplay(t_if.fd_check2, "\n\n##############\n cyc: %3d, ID: %2d, Pool Out mismatch:\nExpected:", t_if.cyc_cnt, pkt.id);
                    fprint_normal_out(t_if.fd_check2, pkt.pool_out, pkt.is_signed);
                    $fdisplay(t_if.fd_check2, "actual: ");
                    fprint_normal_out(t_if.fd_check2, rtl_pool_out, pkt.is_signed);
                end
// `endif
                for(int i=0; i< pkt.pool_out.size() * pkt.pool_out[0].size() + 50;++i)begin
                    @(negedge t_if.clk);
                end


                sem.get();
                error2 = 0;     
                t_if.scan_out_en = 1;
                for(int i=0; i< pkt.pool_out.size() * pkt.pool_out[0].size();++i)begin
                    int sa_id, row_idx, col_idx, sa_rem;
                    sa_id = i /(pkt.pool_out.size() * 4);
                    sa_rem = i % (pkt.pool_out.size() * 4);
                    row_idx = sa_rem / 4;
                    col_idx = sa_rem % 4 + 4 * sa_id;
                    t_if.scan_out_addr = pkt.output_addr + i;

                    @(negedge t_if.clk);

                    if(t_if.scan_out_data[`SA_OUTPUT_WIDTH-1:0] != pkt.pool_out[row_idx][col_idx])begin
                        error2 = 1;
                        //$display("ERROR! Write Back check failed: cyc: %0d, ID: %0d, scanout: %0x, golden: %0x",  t_if.cyc_cnt, pkt.id, t_if.scan_out_data[`SA_OUTPUT_WIDTH-1:0], pkt.pool_out[row_idx][col_idx]);
                    end

                    golden_wb[i].addr = t_if.scan_out_addr;
                    rtl_wb[i].addr = t_if.scan_out_addr;

                    golden_wb[i].data = pkt.pool_out[row_idx][col_idx];
                    rtl_wb[i].data = t_if.scan_out_data[`SA_OUTPUT_WIDTH-1:0];
                end
                t_if.scan_out_en = 0;

                if(error2)begin
                    
                    $display("ERROR! Write Back check failed: cyc: %0d, ID: %0d",  t_if.cyc_cnt, pkt.id);
                    $fdisplay(t_if.fd_check3, "\n\n##############\n cyc: %3d, ID: %2d, Write Back mismatch:\nExpected:", t_if.cyc_cnt, pkt.id);
                    fprint_wb(t_if.fd_check3, golden_wb);
                    $fdisplay(t_if.fd_check3, "actual: ");
                    fprint_wb(t_if.fd_check3, rtl_wb);
                    
                end
                sem.put();

            end join_none

        end//forever
    endtask


endclass



class env;
    generator g0;
    driver d0;
    monitor m0;

    event drv_done;

    mailbox drv_mbx;
    mailbox load_mbx;
    mailbox comp_mbx;


    virtual top_if t_if;

    function new();
        g0 = new;
        d0 = new;
        m0 = new;
        drv_mbx = new();
        load_mbx = new();
        comp_mbx = new();

        m0.sem = new(1);
        g0.drv_mbx = drv_mbx;
        d0.drv_mbx = drv_mbx;

        d0.drv_done = drv_done;
        g0.drv_done = drv_done;

        m0.load_mbx = load_mbx;
        d0.load_mbx = load_mbx;
        m0.comp_mbx = comp_mbx;
        d0.comp_mbx= comp_mbx;
    endfunction


    task run();
        d0.t_if = t_if;
        m0.t_if = t_if;
        fork
            g0.run();
            d0.run();
            m0.run();
        join_any

    endtask


endclass


interface top_if(input bit clk, input bit rstn, input bit [16:0]cyc_cnt);
    int fd_pkt;
    int fd_check;
    int fd_check2;
    int fd_check3;


    inst_t inst; 
    logic bit_mode; //2/4bit 0 for 2, 1 for 4
    logic is_sign; //sign1, unsign0
    logic mode;//v/hmode


    logic [$clog2(`SA_NUM):0] sa_num;//sa number

    logic [3:0][$clog2(`SA_NUM):0] sa_select ;//shifter input goes into which sa, kh=0 
    
    //load_weight and pe enable signal during both compute and load weight stage
    logic [3:0][`SA_NUM-1:0] load_weight_en_line ;

    logic [`SA_NUM-1:0] sa_pe_en;

    // //shifter
    logic valid_in;


    logic [`SA_NUM-1:0][3:0] pool_en ;//pooling block enable signal.
    //reset the compare register in pooling block

    //write back
    logic [`SA_NUM-1:0][3:0] pool_rd_en ;//calculate write back address
    logic [`SA_NUM-1:0][3:0] pool_rd_en_out;

    logic f_stage_en;
    

    //Write Back
    logic [`SRAM_ADDR_SIZE-1:0] sram_w_base_addr; 
    logic  sram_set_w_base_addr; 
    logic [`SRAM_ADDR_SIZE-1:0] sram_r_addr;
    logic sram_r_WEN; //sram write enable
    logic sram_r_CEN;//sram write/read chip enable
    logic sram_w_WEN; 
    logic sram_w_CEN;



    //shifter
    logic [15:0] shift_out;
    logic [15:0] shift_in;


    //sa_array
    logic [`SA_NUM-1:0][`SRAM_ADDR_SIZE-1:0] fifo_wr_addr;
    logic [`SA_NUM-1:0][`SA_OUTPUT_WIDTH-1:0]   pool_out;

    //write_back_part
    logic [`SRAM_ADDR_SIZE-1:0] sram_wr_addr; 
    logic [`SA_OUTPUT_WIDTH-1:0] sram_wr_data;
    logic                        sram_wr_en;
    logic                        fifo_full;
    

    logic scan_in_en;
    logic scan_out_en;
    logic [`SRAM_ADDR_SIZE-1:0] scan_in_addr;
    logic [`SA_WB_WIDTH-1:0] scan_in_data; //DA

    logic [`SRAM_ADDR_SIZE-1:0] scan_out_addr;
    logic [`SA_WB_WIDTH-1:0] scan_out_data; //QB

    logic [`SA_WB_WIDTH-1:0] sram0_QA;
    logic [`SA_WB_WIDTH-1:0] sram1_QA;



    logic [`SA_NUM-1:0][`DIMENSION-1:0][`DIMENSION-1:0][`BIT_WIDTH-1:0]SA_weight;

    //######### assertion #############
    generate
    for(genvar i=0; i<`SA_NUM; ++ i)begin
        assert property (@(posedge clk)
            load_weight_en_line[0][i] |-> ##4 ~load_weight_en_line[0][i]
        )else $display("cyc = %2d, SA = %1d, lw_en_line should be low after 4 cycs", cyc_cnt, i);
        for (genvar j = 1; j< `DIMENSION; ++j)begin
            assert property (@(posedge clk)
                load_weight_en_line[j-1][i] |-> ##1 load_weight_en_line[j][i] ##4 ~load_weight_en_line[j][i]
            )else $display("cyc = %2d, SA = %1d, lw_en_line[%1d]->lw_en_line[%1d]", cyc_cnt, i, j-1, j);
        end
        
    end
    for (genvar j = 0; j< `SA_NUM; ++j)begin
        for(genvar i =1; i< `DIMENSION; ++i)begin
            assert property(@(posedge clk)
                pool_en[j][i-1] |-> ##1 pool_en[j][i]
            )else $display("cyc = %2d, SA = %1d, line = %1d, pool_en rise edge", cyc_cnt, j, i);
            assert property(@(posedge clk)
                ~pool_en[j][i-1] |-> ##1 ~pool_en[j][i]
            )else $display("cyc = %2d, SA = %1d, line = %1d, pool_en fall edge", cyc_cnt, j, i);

        end
    end
    endgenerate
endinterface
    


function void print_normal_in(normal_arr_in_t arr, bit is_signed);
  $write("\n");
  for(int i=0; i<arr.size(); ++i)begin
    for(int j=0; j<arr[0].size(); ++j)begin
      if(~is_signed)
        $write("%h ", arr[i][j]);
      else
        $write("%h ", $signed(arr[i][j]));
    end
    $write("\n");
  end
endfunction

function void fprint_normal_in(int fd, normal_arr_in_t arr, bit is_signed);
  $fwrite(fd, "\n");
  for(int i=0; i<arr.size(); ++i)begin
    for(int j=0; j<arr[0].size(); ++j)begin
      if(~is_signed)
        $fwrite(fd, "%h ", arr[i][j]);
      else
        $fwrite(fd, "%h ", $signed(arr[i][j]));
    end
    $fwrite(fd, "\n");
  end
endfunction


function void print_normal_out(normal_arr_out_t arr, bit is_signed);
  $write("\n");
  for(int i=0; i<arr.size(); ++i)begin
    for(int j=0; j<arr[0].size(); ++j)begin
      if(~is_signed)
        $write("%h ", arr[i][j]);
      else
        $write("%h ", $signed(arr[i][j]));
    end
    $write("\n");
  end
endfunction


function void fprint_normal_out(int fd, normal_arr_out_t arr, bit is_signed);
  $fwrite(fd, "\n");
  for(int i=0; i<arr.size(); ++i)begin
    for(int j=0; j<arr[0].size(); ++j)begin
      if(~is_signed)
        $fwrite(fd, "%h ", arr[i][j]);
      else
        $fwrite(fd, "%h ", $signed(arr[i][j]));
    end
    $fwrite(fd, "\n\n");
  end
endfunction

function void fprint_wb(int fd, sram_ent_arr_t arr);
  $fwrite(fd, "\n");
  for(int i=0; i<arr.size(); ++i)begin
    $fdisplay(fd, "SRAM[%0x] = %0x", arr[i].addr, arr[i].data);
  end
  $fwrite(fd, "\n\n");
endfunction

function inst_t gen_instruction(bit [2:0] opcode = '0, bit mode = 0, bit [$clog2(`SA_NUM):0] sa_num = 3, bit bit_mode = 1, 
                                bit is_signed=1, bit [`SRAM_ADDR_SIZE-1:0] base_addr = '0);
    inst_t inst = '0;
    inst[`INST_SIZE-1: `INST_SIZE-3] = opcode;
    if(opcode == 3'b011 || opcode == 3'b100 || opcode == 3'b101)begin //set_base_addr
        inst[`SRAM_ADDR_SIZE-1:0] = base_addr;
    end else if ( opcode != 3'b010 && opcode != 3'b001)begin //setup
            inst[`INST_SIZE-4] = mode;
            inst[8] = bit_mode; 
            inst[7:4] = sa_num;        
            inst[3] = is_signed;
    end
    return inst;

endfunction