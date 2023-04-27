module demux
(
    input  in,
    input [$clog2(`SA_NUM):0] sel,
    output logic [`SA_NUM-1:0] out
);

always_comb begin
	for(int i=0;i<=`SA_NUM-1;i++) begin
		if(sel==i)
			out[i]=in;
		else
			out[i]=0;
	end
end

endmodule
