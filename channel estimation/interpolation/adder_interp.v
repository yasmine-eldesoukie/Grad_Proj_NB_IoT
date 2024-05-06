module adder_interp #(parameter IN_WIDTH= 19, OUT_WIDTH=19) 
(
	input wire signed [IN_WIDTH-1:0] a, b,
	output reg signed [OUT_WIDTH-1:0] out
);

always @(*) begin
	out= a+b;
end

endmodule