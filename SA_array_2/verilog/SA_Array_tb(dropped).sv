parameter BIT_WIDTH = 4;
parameter DIMENSION = 4;
parameter DIMENSION_V = 12;
parameter SA_OUTPUT_WIDTH = 12;

//stretch arrays are for delayed input and output/ie. the 0s
typedef bit [BIT_WIDTH-1:0] normal_arr_in_t_weight [DIMENSION_V-1:0][DIMENSION-1:0];
typedef bit [BIT_WIDTH-1:0] normal_arr_in_t_input [DIMENSION-1:0][DIMENSION_V-1:0];
typedef bit [3*(BIT_WIDTH)-1:0]  normal_arr_out_t [DIMENSION-1:0][DIMENSION-1:0];



//Matrix multiplication for golden model
function normal_arr_out_t matrix_mult(normal_arr_in_t_input A, normal_arr_in_t_weight B, bit is_signed);
  normal_arr_out_t res;
  bit [3*(BIT_WIDTH)-1:0] sum;
  for(int i=0; i<DIMENSION; ++i)begin
    for(int j=0; j<DIMENSION; ++j)begin
      sum = '0;
      for(int k=0; k<DIMENSION_V; ++k)begin
        if(is_signed)begin      
          sum = $signed(sum) + $signed(A[i][k]) * $signed(B[k][j]);
        end else begin
          sum += A[i][k] * B[k][j];
//        $display("i=%d, j=%d, k=%d, sum=%d, A[i][k]=%d, B[k][j]=%d", i, j, k, $signed(sum), $signed(A[i][k]), $signed(B[k][j]));
        end
      end
      res[i][j] = sum;
  	end
  end
  return res;
endfunction



//generate random input and weight matrix
class matrix_pkt;
  rand normal_arr_in_t in;
  rand normal_arr_in_t w;
  bit is_signed;
    constraint c1{
    foreach(in[i,j]){
      in[i][j] <= 15;
    }
    foreach(w[i,j]){
      w[i][j] <= 15;
    }
  }
endclass

module testbench;//4bit model test
    logic clk,
    logic resetn,

    // logic control_signal, // comes from the controller, decides SAs to be vertically or horizontally arranged. 1: vertical, 0: horizontal

    // logic [3:0][1:0]    SA_select; //decides which SA to stream inputs into when in vertical mode

    // logic [1:0]         SA_num; //Decides how many SAs does this computation need
    // logic [2:0]         PE_enable; //Decides which SA need to enable PE
    // logic [2:0][3:0]    load_weight; //Decides which SA row needs to load weight

    // logic [2:0][3:0] pool_reset;
    // logic out_model;    //1 for 4bit mult, 0 for 2bit mult
    // logic is_signed;         //Sign or unsigned multiplication       

    // logic [3:0][3:0] shift_out;  //assuming buffer sends in 1 row per cycle from read port

    // logic [3:0][SA_OUTPUT_WIDTH-1:0]   out_bot;  //potentially 12 different 12-bit output 
    // logic [SA_OUTPUT_WIDTH-1:0]   pool_out;

    // logic [15:0] shift_in;

    // logic valid_in;
    

    // SA_Array SA_Array0(
    //   .clk(clk),INST_SIZE
    //   .load_weight(load_weight),
    //   .pool_reset(pool_reset),
    //   .out_model(out_model),
    //   .is_signed(is_signed),
    //   .in({shift_out[3], shift_out[2], shift_out[1], shift_out[0]}),
    //   .out_bot(out_bot),
    //   .pool_out(pool_out)
    // );

    // shifter shifter0(
    //   .shift_in(shift_in),
    //   .valid_in(valid_in), //arrives with data from buffer, 
    //   .clk(clk),
    //   .rstn(resetn),
    //   .shift_out(shift_out);
    // );
     //######## controller ############
    logic [`INST_SIZE-1:0] inst; //

    logic bit_mode; //2/4bit 0 for 2, 1 for 4
    logic is_sign; //sign1, unsign0
    logic mode;//v/hmode
    logic [1:0] sa_num;//sa number
    logic [1:0] sa_select0;//shifter input goes into which sa, kh=0
    logic [1:0] sa_select1;
    logic [1:0] sa_select2;
    logic [1:0] sa_select3;

    //load_weight enable signal
    logic load_weight_en_line0 [2:0];
    logic load_weight_en_line1 [2:0];
    logic load_weight_en_line2 [2:0];
    logic load_weight_en_line3 [2:0];

    //shifter
    //work as shifter enable signal, or compute stage enable
    //set high at the same time with data
    logic valid_in;

    //pool
    logic [3:0] pool_en0;//pooling block enable signal.
    logic [3:0] pool_en1;//reset the compare register in pooling block
    logic [3:0] pool_en2;
    

    //Write Back
    logic [`SRAM_ADDR_SIZE-1:0] sram_addr; 
    logic sram_WEN; //sram write enable
    logic sram_CEN;//todo sram write/read chip enable


    controller c0 (
        .clk(clk), .rstn(rstn), .inst(inst),
        .bit_mode(bit_mode),
        .is_sign(is_sign), 
        .mode(mode),
        .sa_num(sa_num),
        .sa_select0(sa_select0),
        .sa_select1(sa_select1),
        .sa_select2(sa_select2),
        .sa_select3(sa_select3),
        .load_weight_en_line0(load_weight_en_line0),
        .load_weight_en_line1(load_weight_en_line1),
        .load_weight_en_line2(load_weight_en_line2),
        .load_weight_en_line3(load_weight_en_line3),
        .valid_in(valid_in),
        .pool_en0(pool_en0),
        .pool_en1(pool_en1),
        .pool_en2(pool_en2),
        .sram_addr(sram_addr),
        .sram_WEN(sram_WEN),
        .sram_CEN(sram_CEN)
    );

    // ########### shifter ###########
    logic [15:0] shift_out;
    logic [15:0] shift_in;

    shifter shift0(
        .shift_in(shift_in),
        .valid_in(valid_in), //arrives with data from buffer, 
        .clk(clk),
        .rstn(rstn),
        .shift_out(shift_out)
    );



    // ########## SA_ARRAY #########

    logic [2:0][3:0]    load_weight;
    assign load_weight[0][0] = load_weight_en_line0[0];
    assign load_weight[1][0] = load_weight_en_line0[1];
    assign load_weight[2][0] = load_weight_en_line0[2];

    assign load_weight[0][1] = load_weight_en_line1[0];
    assign load_weight[1][1] = load_weight_en_line1[1];
    assign load_weight[2][1] = load_weight_en_line1[2];

    assign load_weight[0][2] = load_weight_en_line2[0];
    assign load_weight[1][2] = load_weight_en_line2[1];
    assign load_weight[2][2] = load_weight_en_line2[2];

    assign load_weight[0][3] = load_weight_en_line3[0];
    assign load_weight[1][3] = load_weight_en_line3[1];
    assign load_weight[2][3] = load_weight_en_line3[2];


    logic [`SA_OUTPUT_WIDTH-1:0]   pool_out;

    SA_Array sa_array0
    (
    .clk(clk),
    .resetn(resetn),
    .control_signal(mode), // comes from the controller(), decides SAs to be vertically or horizontally arranged. 1: vertical(), 0: horizontal
    .SA_select({sa_select3, sa_select2, sa_select1, sa_select0}), //decides which SA to stream inputs into when in vertical mode
    .SA_num(sa_num), //Decides how many SAs does this computation need
    .PE_enable({pe_en_sa2, pe_en_sa1, pe_en_sa0}), //Decides which SA need to enable PE
    .load_weight(load_weight), //Decides which SA row needs to load weight
    .pool_reset({pool_en2, pool_en1, pool_en0}),
    .out_model(bit_mode),    //1 for 4bit mult(), 0 for 2bit mult
    .is_signed(is_sign),         //Sign or unsigned multiplication       
    .in({shift_out[15:12], shift_out[11:8], shift_out[7:4], shift_out[3:0]}),  //assuming buffer sends in 1 row per cycle from read port
    // .out_bot(out_bot)  //potentially 12 different 12-bit output 
    .pool_out(pool_out)
    );




    //--- Clock Generation Block ---//
    always
    begin
        #5 clk=~clk;
    end


    always @ (posedge clk)begin
        if (~reset)begin
            cyc_cnt <= 0;
        end else begin
            cyc_cnt <= cyc_cnt + 1;
        end
    end

    //--- Value Setting Block ---//
    initial begin
    $dumpfile("sim.dump"); 
    $dumpvars(0, testbench);
    end

    matrix_pkt pkt;
    normal_arr_out_t n_out;
    normal_arr_out_t golden_out;
    

    initial begin
        clk = 0;
        reset = 0;
        load_weight = 0;
        out_model = 1;//4bit * 4bit
        PE_enable = 1;
        is_signed = 1;
        for(int i=0; i<DIMENSION; ++i)begin
          input_left[i] = 0;
          input_top[i] = 0;
        end

        $display("############");
        pkt1=new;
        pkt1.randomize();
        pkt2=new;
        pkt2.randomize();
        pkt3=new;
        pkt3.randomize();
        $display("input matrix:");
        print_normal_in(pkt.in, is_signed);
        $display("W matrix:");
        print_normal_in(pkt.w, is_signed);
        $display("Expected Out:");
        golden_out = matrix_mult(pkt.in, pkt.w, is_signed);
        print_normal_out_dec(golden_out, is_signed);
        print_normal_out_bin(golden_out, is_signed);


        in = norm2stretch_in_input(pkt.in);
        weight = norm2stretch_in_weight(pkt.w);

        // load weight:12 cycle
        @(posedge clk);
        @(negedge clk);
        reset = 1;
        load_weight = 1;
        

        //matrix mult
        fork
            begin //drive input
                for(int i=0; i<2*DIMENSION-1; ++i)begin//clock cycle
                    for(int j=0; j<DIMENSION; ++j)begin
                    input_left[j] = in[i][j];     	
                    end
                    @(negedge clk);
                end
            end
            
            begin//monitor the output
                //wait for 4 cycles for output
                for(int i=0; i<DIMENSION; ++i)begin
                    @(posedge clk);
                end

                //collect output in form of stretched matrix
                for(int i=0; i<2*DIMENSION-1; ++i)begin
                    @(posedge clk);
                    for(int j=0; j<DIMENSION; ++j)begin
                        out[i][j] = out_bot[j];
                    end
                end
                $display("Actual Output:");
                n_out = stretch2norm_out(out);
                //print_stretch_out(out, is_signed);
                print_normal_out_dec(n_out, is_signed);
                print_normal_out_bin(n_out, is_signed);
                for(int i=0; i<DIMENSION; ++i)begin
                    for(int j=0; j<DIMENSION; ++j)begin
                        if(n_out[i][j]!= golden_out[i][j])
                            $display("The %0d th row from Input and %0d th col from Weight is incorrect", i, j);
                        end
                end
                
            end   
        join
        #50;

        $finish;
    end

    
endmodule

function void print_stretch_in(stretch_arr_in_t arr, bit is_signed);
  $write("\n");
  for(int i=0; i<DIMENSION+3; ++i)begin
    for(int j=0; j<DIMENSION; ++j)begin
      if(~is_signed)
        $write("%d ", arr[i][j]);
      else
        $write("%d ", $signed(arr[i][j]));
    end
    $write("\n\n");
  end
endfunction


function void print_normal_in(normal_arr_in_t arr, bit is_signed);
  $write("\n");
  for(int i=0; i<DIMENSION; ++i)begin
    for(int j=0; j<DIMENSION; ++j)begin
      if(~is_signed)
        $write("%d ", arr[i][j]);
      else
        $write("%d ", $signed(arr[i][j]));
    end
    $write("\n\n");
  end
endfunction


function void print_stretch_out(stretch_arr_out_t arr, bit is_signed);
  $write("\n");
  for(int i=0; i<DIMENSION+3; ++i)begin
    for(int j=0; j<DIMENSION; ++j)begin
      if(~is_signed)
        $write("%d ", arr[i][j]);
      else
        $write("%d ", $signed(arr[i][j]));
    end
    $write("\n\n");
  end
endfunction


function void print_normal_out_bin(normal_arr_out_t arr, bit is_signed);
  $write("\n");
  for(int i=0; i<DIMENSION; ++i)begin
    for(int j=0; j<DIMENSION; ++j)begin
      if(~is_signed)
        $write("%b ", arr[i][j]);
      else
        $write("%b ", $signed(arr[i][j]));
    end
    $write("\n\n");
  end
endfunction

function void print_normal_out_dec(normal_arr_out_t arr, bit is_signed);
  $write("\n");
  for(int i=0; i<DIMENSION; ++i)begin
    for(int j=0; j<DIMENSION; ++j)begin
      if(~is_signed)
        $write("%d ", arr[i][j]);
      else
        $write("%d ", $signed(arr[i][j]));
    end
    $write("\n\n");
  end
endfunction
