module adder_interp #(parameter WIDTH_SMALL= 18, WIDTH_BIG= 20, OUT_WIDTH=20)
(
	input wire [WIDTH_SMALL-1:0] a,
	input wire [WIDTH_BIG-1:0] b,
	output reg [OUT_WIDTH-1:0] out
);

always @(*) begin
	out= a+b;
end

endmodule