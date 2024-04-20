module multiplier #(parameter WIDTH_A=8, WIDTH_B=9)(
	input wire clk, rst, en,
    input wire [WIDTH_A-1:0] a,
	input wire [WIDTH_B-1:0] b,
	output reg [WIDTH_A+WIDTH_B-1:0] mult_out
	//output reg mult_done
	);

reg [WIDTH_A+WIDTH_B-1:0] mult_out_comp;
always @(*) begin
	if (en) begin
		mult_out_comp=a*b;
		//mult_done=1'b1;
	end
	else begin
		mult_out_comp='b0;
		//mult_done=1'b0;
	end
end
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		mult_out<='b0;
	end
	else begin
		mult_out<=mult_out_comp;
	end
end
endmodule