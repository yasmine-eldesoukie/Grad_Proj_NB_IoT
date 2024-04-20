module div_3 #(parameter IN_WIDTH= 20, OUT_WIDTH=16)
(
	input wire [IN_WIDTH-1:0] adder_out,
	output reg [OUT_WIDTH-1:0] div_3_out
);

always @(*) begin
	div_3_out= adder_out/3;
end

endmodule