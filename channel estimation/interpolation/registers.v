module registers #(parameter REG1=17, REG2=18, REG3=20, ADD=20)
(
	input wire clk, rst,
	input wire en_reg_h6, en_reg_2h6, en_reg_5h9,
	input wire [ADD-1:0] adder1_res, adder2_res,
	output reg [REG1-1:0] reg_h6,
	output reg [REG2-1:0] reg_2h6,
	output reg [REG3-1:0] reg_5h9
);

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		reg_h6<='b0;
	end
	else if (en_reg_h6) begin
		reg_2h6<=adder1_res;
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		reg_2h6<='b0;
	end
	else if (en_reg_2h6) begin
		reg_2h6<=adder1_res;
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		reg_5h9<='b0;
	end
	else if (en_reg_5h9) begin
		reg_2h6<=adder2_res;
	end
end

endmodule