//need ptr reset signal, when the last 
module shifter
(
    input [15:0] shift_in,
    input valid_in, //arrives with data from buffer, 
    input clk,
    input rstn,

    output logic [15:0] shift_out
);
logic [15:0] shifter [3:0];
logic [1:0] ptr;
logic valid_in_d;

always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        shifter[0]<=0;
        shifter[1]<=0;
        shifter[2]<=0;
        shifter[3]<=0;
        valid_in_d<=0;
    end
    else begin
        shifter[ptr]<=shift_in;
        valid_in_d<=valid_in;
    end
end

always_ff @(posedge clk or negedge rstn) begin//todo reset ptr at new inst
    if(!rstn || !valid_in) ptr<=0;
    else if(valid_in) ptr <= (ptr == 2'b11) ? 0 : ptr+1;
    else ptr<=ptr;
end

logic [1:0] ptr_d;
always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) ptr_d<=0;
    else ptr_d<=ptr;
end
//output for different lines of SAs
always_comb begin
    case (ptr_d)
	2'b00: begin
	    shift_out[3:0]   = shifter[0][3 : 0];
	    shift_out[7:4]   = shifter[1][15 : 12];
	    shift_out[11:8]  = shifter[2][11 : 8];
	    shift_out[15:12] = shifter[3][7 : 4]; 
	end

	2'b01: begin
	    shift_out[3:0]   = shifter[0][7 : 4];
	    shift_out[7:4]   = shifter[1][3 : 0];
	    shift_out[11:8]  = shifter[2][15 : 12];
	    shift_out[15:12] = shifter[3][11 : 8]; 
	end

	2'b10: begin
	    shift_out[3:0]   = shifter[0][11 : 8];
	    shift_out[7:4]   = shifter[1][7 : 4];
	    shift_out[11:8]  = shifter[2][3 : 0];
	    shift_out[15:12] = shifter[3][15 : 12]; 
	end

	2'b11: begin
	    shift_out[3:0]   = shifter[0][15 : 12];
	    shift_out[7:4]   = shifter[1][11 : 8];
	    shift_out[11:8]  = shifter[2][7 : 4];
	    shift_out[15:12] = shifter[3][3 : 0]; 
	end
    endcase
end

endmodule
