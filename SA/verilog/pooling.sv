module pooling #(parameter SA_NUM = 3,
                 parameter SA_OUTPUT_WIDTH = 14)
(
    input clk,
    input reset,
    input out_model, 
    input pool_enable,
    input Sx, Sy,
    input [SA_OUTPUT_WIDTH -1 : 0] input_from_SA ,

    output logic [SA_OUTPUT_WIDTH -1:0] max_out 
);

logic [SA_OUTPUT_WIDTH -1:0] curr_max;
// logic [SA_OUTPUT_WIDTH -1:0] next_max;
logic [1:0] counter;


assign max_out = (counter == 3) ? curr_max : '0;

always_ff @(posedge clk) begin
    if(pool_enable) begin
        if(out_model)begin //4*4
            curr_max <= (Sx == 1) ? (($signed(curr_max) > $signed(input_from_SA)) ?  curr_max : input_from_SA ) :
                                    ((curr_max > input_from_SA) ? curr_max : input_from_SA);
            
        end
        else begin //2*2
            curr_max[13:7] <= (Sx == 1) ? (($signed(curr_max[13:7]) > $signed(input_from_SA[13:7])) ? curr_max[13:7] : input_from_SA[13:7]) : 
                                         ((curr_max[13:7] > input_from_SA[13:7]) ? curr_max[13:7] : input_from_SA[13:7]);
            curr_max[6:0] <= (Sx == 1) ? (($signed(curr_max[6:0]) > $signed(input_from_SA[6:0])) ? curr_max[6:0] : input_from_SA[6:0]):
                                          ((curr_max[6:0] > input_from_SA[6:0]) ? curr_max[6:0] : input_from_SA[6:0])  ;
        end
        counter <= counter + '1;
    end
    else begin
        counter <= '0;
        curr_max <= '0;
    end
    
end
endmodule