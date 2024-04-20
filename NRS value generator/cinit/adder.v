module adder #(parameter WIDTH= 18)(
	input wire clk, rst, en,
	input wire [WIDTH-1:0] a, b,
	output reg [WIDTH-1:0] adder_out
	);

reg [WIDTH-1:0] adder_out_comp;
always @(*) begin
	adder_out_comp=a+b;
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		adder_out<='b0;
	end
	else if (en) begin
		adder_out= adder_out_comp;
	end
end
endmodule