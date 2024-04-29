module registers #(parameter REG1=17, REG2=18, REG3=20, ADD=20)
(
	input wire clk, rst,
	input wire en_reg_E, en_reg_2E, en_reg_5E,
	input wire [ADD-1:0] adder1_res, adder2_res,
	output reg [REG1-1:0] reg_E,
	output reg [REG2-1:0] reg_2E,
	output reg [REG3-1:0] reg_5E
);

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		reg_E<='b0;
	end
	else if (en_reg_E) begin
		reg_2E<=adder1_res;
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		reg_2E<='b0;
	end
	else if (en_reg_2E) begin
		reg_2E<=adder1_res;
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		reg_5E<='b0;
	end
	else if (en_reg_5E) begin
		reg_2E<=adder2_res;
	end
end

endmodule