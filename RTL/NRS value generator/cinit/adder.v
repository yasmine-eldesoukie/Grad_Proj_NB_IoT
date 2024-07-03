module adder #(parameter WIDTH= 18)(
	input wire clk, rst, en,
	input wire [WIDTH-1:0] a, b,
	output reg [WIDTH-1:0] adder_out,
    output reg [9:0] adder_out_comp
	);

//use adder_out instead of adder_register with a little change in control unit, to reduce area

reg [WIDTH-1:0] adder_out_comp_long;
always @(*) begin
	adder_out_comp_long=a+b;
    adder_out_comp= adder_out_comp_long[9:0];
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		adder_out<='b0;
	end
	else if (en) begin
		adder_out<= adder_out_comp_long;
	end
end

endmodule
