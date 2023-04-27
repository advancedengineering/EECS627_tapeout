import DEFINE_PKG::*;
//ISA
/*opcode*/ /*load_weights #iteration kh*kw*ic/#of_weights_in_sram_wordline 0-3*/ /* #iteration #sa 0-2*/ /*coumpute #iteration kh*kw*ic/#of_inputs_in_sram_wordline*/
/*modify*/ //kh fixed, mode and #of SAs is given by setup instruction, only need overall loop count
//(compute load_weight) /*opcode 3bits*/ 
//(setup) /*opcode 3bits*/ /*mode 1bit*/ /*bit_mode 1bit*/ /*sa_num 3bits*/ /*is_sign* 1bit/ /*000*/
//(set_base_weight_addr)/*opcode 3bits*//*addr 6->10bits*/
//(set_base_input_addr) /*opcode 3bits*//*addr 6->10bits*/
//(set_base_output_addr)/*opcode 3bits*//*addr 6->10bits*/

// `define setup 3'b000
// `define load_weight 3'b001
// `define compute 3'b010
// `define set_base_weight_addr 3'b011
// `define set_base_input_addr 3'b100
// `define set_base_output_addr 3'b101

// `define v_mode 1
// `define h_mode 0

// `define bit2_mode 0
// `define bit4_mode 1

module controller_tb;
    logic clk;
    logic rstn;
    logic [12:0] inst;

controller DUT(.clk(clk), .rstn(rstn), .inst(inst));
always
begin
    #5 clk=~clk;
end

//initial $sdf_annotate("../syn/SA.syn.sdf", DUT,,, "MAXIMUM");
//initial $sdf_annotate("../syn/SA.syn.sdf", DUT);

initial begin
    $dumpfile("sim.dump.vcd"); 
    $dumpvars(0, controller_tb);

    clk=0;
    rstn=0;
    @(negedge clk);
    @(negedge clk);
    rstn=1;
    inst=13'b0001101101000; //setup, vmode, 4bit, 6sa, signed
    @(negedge clk);
    inst=13'b0010000000000;//loadweight
    for(int i=0; i<=100;i++)
        @(negedge clk);
    inst=13'b0100000000000;//compute
    for(int i=0; i<=100;i++)
        @(negedge clk);
    @(negedge clk);
    @(negedge clk);
 
    inst=13'b0000101101000; //setup, vmode, 4bit, 6sa, signed
    for(int i=0; i<=50;i++)
        @(negedge clk);
    @(negedge clk);
    inst=13'b0010000000000;//loadweight
    for(int i=0; i<=100;i++)
        @(negedge clk);
    inst=13'b0100000000000;//compute
    for(int i=0; i<=100;i++)
        @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    $stop;
end


endmodule