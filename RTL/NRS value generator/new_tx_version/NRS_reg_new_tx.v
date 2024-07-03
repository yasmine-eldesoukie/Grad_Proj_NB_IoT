module NRS_reg_new_tx #(parameter WIDTH_REG=16 , LINES= $clog2(WIDTH_REG))
(
	input wire clk, rst, wr_en,
	input wire c_n,
	input wire [LINES-1:0] wr_addr,
	input wire [LINES-1:0] rd_addr_mapper_1r, rd_addr_mapper_1i, rd_addr_mapper_2r, rd_addr_mapper_2i,
	//input wire [LINES-1:0] rd_addr_fine,
	output reg  c0, c1, c2, c3
	//output reg c_n_fine
);

reg [WIDTH_REG-1:0] mem;
always @(posedge clk or negedge rst) begin
	if (!rst) begin
        mem<='d0;
	end
	else if (wr_en) begin
		mem[wr_addr]<=c_n;
	end
end

always @(*) begin
	c0=mem[rd_addr_mapper_1r];
	c1=mem[rd_addr_mapper_1i];
	c2=mem[rd_addr_mapper_2r];
	c3=mem[rd_addr_mapper_2i];
end
 
endmodule