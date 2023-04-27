import DEFINE_PKG::*;
module TOP(
    input clk_en,
    input [1:0] stage_tune,
    input [1:0] divide_tune,
    //input clk,
    input rstn,//for chip, todo:need another rst for scan chain?
    input [`INST_SIZE-1:0] inst, //inst sequence connected to inst scan chain, with saturation counter to choose which inst to feed to controller inst input.
    output logic f_stage_en, //todo:add synchronizer to those signal which is not connected to data input pin of synchronizer

    input scan_in_en, //0 -> controller read;          1 -> scan_chain/tb write
    input [`SRAM_ADDR_SIZE-1:0] scan_in_addr,
    input [`SA_WB_WIDTH-1:0] scan_in_data, //DA

    input scan_out_en, //0 -> write_back_part write;    1 -> scan_chain/tb read);
    input [`SRAM_ADDR_SIZE-1:0] scan_out_addr,
    
    output logic [`SA_WB_WIDTH-1:0] scan_out_data //QB
);

    // top_if t_if(.clk(clk), .rstn(rstn), .inst(inst), .scan_in_en(scan_in_en), .scan_in_addr(scan_in_addr),
    //             .scan_in_data(scan_in_data), .scan_out_en(scan_out_en), .scan_out_addr(scan_out_addr), 
    //             .scan_out_data(scan_out_data), .f_stage_en(f_stage_en));
    // assign tmp_out  = shift_out;

    logic clk;
    
    // #### start #####
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

    //Write Back
    logic [`SRAM_ADDR_SIZE-1:0] sram_w_base_addr; 
    logic  sram_set_w_base_addr; 
    logic [`SRAM_ADDR_SIZE-1:0] sram_r_addr;
    logic sram_r_WEN; //sram write enable
    logic sram_r_CEN;//sram write/read chip enable
    logic sram_w_WEN; 
    logic sram_w_CEN;
    logic fifo_full;



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


    //sram
    logic [`SA_WB_WIDTH-1:0] sram0_QA;

    logic [`SA_WB_WIDTH-1:0] sram1_QA;


    // ######## start of instance ###########

    controller c0 (
        .clk(clk), .rstn(rstn), .inst(inst),
        .bit_mode_o(bit_mode),
        .is_sign_o(is_sign), 
        .mode_o(mode),
        .sa_num_o(sa_num),
        .sa_select_o(sa_select),
        .load_weight_en_line_o(load_weight_en_line),
        .sa_pe_en_o(sa_pe_en),
        .valid_in_o(valid_in),
        .pool_en_o(pool_en),
        .pool_rd_en_o(pool_rd_en),
        .sram_w_base_addr_o(sram_w_base_addr), 
        .sram_set_w_base_addr_o(sram_set_w_base_addr),
        .sram_r_addr_o(sram_r_addr),
        .sram_r_WEN_o(sram_r_WEN), //sram write enable
        .sram_r_CEN_o(sram_r_CEN),//sram write/read chip enable
        .sram_w_WEN_o(sram_w_WEN), 
        .sram_w_CEN_o(sram_w_CEN),
        .f_stage_en(f_stage_en)
    );

    // ########### shifter ###########


    shifter shift0(
        .shift_in(shift_in),
        .valid_in(valid_in), //arrives with data from buffer, 
        .clk(clk),
        .rstn(rstn),
        .shift_out(shift_out)
    );



    // ########## SA_ARRAY #########

    
    SA_array_part SA_p0(
        .clk(clk),
        .resetn(rstn),
        .control_signal(mode), // comes from the controller(), decides SAs to be vertically or horizontally arranged. 1: vertical(), 0: horizontal
        .SA_select(sa_select), //decides which SA to stream inputs into when in vertical mode
        .SA_num(sa_num), //Decides how many SAs does this computation need
        .PE_enable(sa_pe_en), //Decides which SA need to enable PE
        .load_weight_en_line(load_weight_en_line), //Decides which SA row needs to load weight
        .pool_reset(pool_en),
        .out_model(bit_mode),    //1 for 4bit mult(), 0 for 2bit mult
        .is_signed(is_sign),         //Sign or unsigned multiplication       
        .in0({shift_out[15:12], shift_out[11:8], shift_out[7:4], shift_out[3:0]}),  //assuming buffer sends in 1 row per cycle from read port
        .sram_w_base_addr(sram_w_base_addr),
        .sram_set_w_base_addr(sram_set_w_base_addr),
        .pool_rd_en(pool_rd_en),
        .pool_rd_en_out(pool_rd_en_out),
        .fifo_wr_addr(fifo_wr_addr),
        .pool_out(pool_out)
    );

    write_back_part WB_p0(
        .clk(clk),
        .resetn(rstn),
        .pool_rd_en(pool_rd_en_out),
        .pool_out(pool_out),
        .fifo_wr_addr(fifo_wr_addr),
        .sram_wr_addr(sram_wr_addr),
        .sram_wr_data(sram_wr_data),
        .sram_wr_en(sram_wr_en),
        .fifo_full_out(fifo_full)
    );

    //input and weight
    sram sram0 (
        //scan in / write
        .ADRA(scan_in_addr),
        .DA(scan_in_data),
        .WEA(1'b1), //write enable
        .OEA(1'b0), //output enable
        .MEA(scan_in_en),          //memory enable
        .CLKA(clk),
        .RMA(4'b1110),
        .QA(sram0_QA),
        
        //shift in / read
        .ADRB(sram_r_addr),
        .DB('0),
        .WEB(1'b0),
        .OEB(1'b1),
        .MEB(~sram_r_CEN),
        .CLKB(clk),
        .RMB(4'b1110),
        .QB(shift_in)
    );

    //output
    sram sram1 (
        
        //scan out /read
        .ADRA(scan_out_addr),
        .DA('0),
        .WEA(1'b0),
        .OEA(1'b1),
        .MEA(scan_out_en),
        .CLKA(clk),
        .RMA(4'b1110),
        .QA(scan_out_data),

         //output / write
        .ADRB(sram_wr_addr),
        .DB({3'b000,sram_wr_data}),
        .WEB(1'b1), //write enable
        .OEB(1'b0), //output enable
        .MEB(sram_wr_en),          //memory enable
        .CLKB(clk),
        .RMB(4'b1110),
        .QB(sram1_QA)
    );

    Ring clk_gen (
        .clk_en(clk_en), .stage_tune(stage_tune), .divide_tune(divide_tune), .clk(clk)
    );

endmodule 

