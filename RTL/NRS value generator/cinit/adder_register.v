module adder_register #(parameter WIDTH=18)(
	input wire clk, rst, en,
	input wire [WIDTH-1:0] adder_out,
	output reg [WIDTH-1:0] adder_MSB
	);
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		adder_MSB<='b0;
	end
	else if (en) begin
		adder_MSB<=adder_out;
	end
end
endmodule