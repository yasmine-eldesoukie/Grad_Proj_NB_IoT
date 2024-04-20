module estimate_mux #(parameter WIDTH=16)(
	input wire [WIDTH-1:0] in0, in1,
	input wire sel,
	output reg [WIDTH-1:0] out
);

always @(*) begin
	 case (sel) 
	     'b0: out=in0;
	     'b1: out=in1;
	 endcase
end
endmodule