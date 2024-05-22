module registers #(parameter REG1=17, REG2=18, REG3=19, ADD=19)
(
	input wire clk, rst,
	input wire en_reg_E, en_reg_2E, en_reg_5E,
	input wire signed [ADD:0] adder1_res, //max of adder1 result needed is 18 bits, 1 sign bit and 17 LSB
	input wire signed [ADD-1:0] adder2_res,
	output reg signed [REG1-1:0] reg_E,
	output reg signed [REG2-1:0] reg_2E,
	output reg signed [REG3-1:0] reg_5E
);

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		reg_E<='b0;
	end
	else if (en_reg_E) begin
		reg_E<={adder1_res[ADD], adder1_res[REG1-2:0]};
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		reg_2E<='b0;
	end
	else if (en_reg_2E) begin
		reg_2E<={adder1_res[ADD], adder1_res[REG2-2:0]};
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		reg_5E<='b0;
	end
	else if (en_reg_5E) begin
		reg_5E<=adder2_res;
	end
end

endmodule