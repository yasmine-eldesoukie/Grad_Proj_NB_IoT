module XOR (
	input wire x1, x2,
	output reg c_n
);
always @(*) begin
	c_n= x1^x2;
end
endmodule