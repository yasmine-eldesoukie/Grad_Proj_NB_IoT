module ns_mux (
	input wire [3:0] nsf,
	input wire sel_ns,
	output reg [4:0] ns
	);
always @(*) begin
	if (sel_ns==1'b0) begin
		ns={nsf,1'b0};
	end
	else begin
		ns={nsf,1'b1};
	end
end
endmodule