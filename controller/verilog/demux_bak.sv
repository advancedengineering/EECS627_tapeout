module demux
(
    input  in,
    input [1:0] sel,
    output logic out_1,
    output logic out_2,
    output logic out_3
);

always_comb begin
    case (sel)
	2'b00: begin
	    out_1 = in;
	    out_2 = 16'b0;
	    out_3 = 16'b0;
	end

	2'b01: begin
	    out_1 = 16'b0;
	    out_2 = in;
	    out_3 = 16'b0;
	end

	2'b10: begin
	    out_1 = 16'b0;
	    out_2 = 16'b0;
	    out_3 = in;
	end

	2'b11: begin
		out_1 = 16'b0;
	    out_2 = 16'b0;
	    out_3 = 16'b0;
	end
    endcase
end

endmodule
