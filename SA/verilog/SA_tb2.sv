parameter BIT_WIDTH = 4;
parameter DIMENSION = 4;

//stretch arrays are for delayed input and output/ie. the 0s
typedef bit [BIT_WIDTH-1:0] stretch_arr_in_t [DIMENSION+2:0][DIMENSION-1:0];
typedef bit [BIT_WIDTH-1:0] normal_arr_in_t [DIMENSION-1:0][DIMENSION-1:0];
typedef bit [3*(BIT_WIDTH)-1:0]  stretch_arr_out_t [DIMENSION+2:0][DIMENSION-1:0];
typedef bit [3*(BIT_WIDTH)-1:0]  normal_arr_out_t [DIMENSION-1:0][DIMENSION-1:0];

//Convert 4 bit normal matrix to stretched matrix to drive input
function stretch_arr_in_t norm2stretch_in(normal_arr_in_t arr);
  stretch_arr_in_t res;
  foreach(arr[i, j])begin 
    res[i+j][j] = arr[i][j];
  end
  return res;
endfunction

//Convert 8 bit stretched matrix to normal matrix; used for output 
function normal_arr_out_t stretch2norm_out(stretch_arr_out_t arr);
  normal_arr_out_t res;
  foreach(res[i, j])begin 
    res[i][j] = arr[i+j][j];
  end
  return res;
endfunction

//Matrix multiplication for golden model
function normal_arr_out_t matrix_mult(normal_arr_in_t A, normal_arr_in_t B, bit is_signed);
  normal_arr_out_t res;
  bit [3*(BIT_WIDTH)-1:0] sum;
  for(int i=0; i<DIMENSION; ++i)begin
    for(int j=0; j<DIMENSION; ++j)begin
      sum = '0;
      for(int k=0; k<DIMENSION; ++k)begin
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
    logic clk;
    logic reset;//negative activate
    logic load_weight;
    // logic load_weight_1;// load weight enable for first row
    // logic load_weight_2;// load weight enable for second row
    // logic load_weight_3;// load weight enable for thrid row
    // logic load_weight_4;// load weight enable for fourth row
    logic out_model; //two case: 4*4, 2*2
    logic PE_enable; //1 for work
    logic is_signed;
    logic [DIMENSION-1:0] [3*(BIT_WIDTH)-1:0] input_top ;
    logic [DIMENSION-1:0] [BIT_WIDTH-1:0] input_left ;
    logic [DIMENSION-1:0] [3*(BIT_WIDTH)-1:0] out_bot ;
    logic [DIMENSION-1:0] [BIT_WIDTH-1:0] out_right ;


    logic [7:0] cyc_cnt;
    

    SA DUT(
        .clk(clk), .reset(reset),
        .load_weight({load_weight, load_weight, load_weight, load_weight}),
        .out_model(out_model),
        .PE_enable(PE_enable),
        .is_signed(is_signed),
        .input_left(input_left), .input_top(input_top),
        .out_bot(out_bot), .out_right(out_right)
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
    $sdf_annotate("../syn/SA.syn.sdf",DUT);
    end

    matrix_pkt pkt;
    stretch_arr_in_t in;
    stretch_arr_out_t out;
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
        pkt=new;
        pkt.randomize();
        $display("input matrix:");
        print_normal_in(pkt.in, is_signed);
        $display("W matrix:");
        print_normal_in(pkt.w, is_signed);
        $display("Expected Out:");
        golden_out = matrix_mult(pkt.in, pkt.w, is_signed);
        print_normal_out_dec(golden_out, is_signed);
        // print_normal_out_bin(golden_out, is_signed);


        in = norm2stretch_in(pkt.in);

        // load weight:4 cycle
        @(posedge clk);
        @(negedge clk);
        reset = 1;
        load_weight = 1;
        for(int i=DIMENSION-1; i>=0; --i)begin//clock cycle
            for(int j=0; j<DIMENSION; ++j)begin
                input_left[j] = pkt.w[j][i];
            end
            @(negedge clk);
        end

        load_weight = 0;

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
                // print_normal_out_bin(n_out, is_signed);
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
