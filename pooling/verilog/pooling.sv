
import DEFINE_PKG::*;
module pooling (
    input clk,
    input a_reset,
    input pool_reset,
    // input out_model, //two case: high for 4*4, low for 2*2
    // input pool_enable,  //enable Pooling
    // input 2bit_iter, //Which iteration of 2 bit multiplication 

    input [`SA_OUTPUT_WIDTH-1 : 0] input_from_RELU,

    output logic [`SA_OUTPUT_WIDTH-1:0] max_out 
);

logic [`SA_OUTPUT_WIDTH -1:0] curr_max;  // Output pooling result for 4 2x2 matrix at once (2bit mult) Every 8 cycles, or 1 2x2 matrix at once (4bit mult) Every 4 cycles

logic [`SA_OUTPUT_WIDTH -1:0] next_max; 

assign max_out = (curr_max > input_from_RELU) ? curr_max : input_from_RELU;
assign next_max = (curr_max > input_from_RELU) ? curr_max : input_from_RELU;

always_ff @(posedge clk or negedge a_reset) begin 
    if(!a_reset) begin 
        curr_max <= '0;
    end else if (pool_reset) begin
	curr_max <= '0;
    end
    else begin
        curr_max <= next_max;
    end    
end

endmodule
