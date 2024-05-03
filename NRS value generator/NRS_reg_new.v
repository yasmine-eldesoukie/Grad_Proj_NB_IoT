module NRS_reg_new #(parameter WIDTH_REG=16 , LINES= $clog2(WIDTH_REG))
(
	input wire clk, rst, wr_en,
	input wire c_n,
	input wire [LINES-1:0] wr_addr,
	input wire [LINES-1:0] rd_addr_est,
	//input wire [LINES-1:0] rd_addr_fine,
	output reg c_n_est //will be nrs_est, no need for the whole value, this bit is enough for channel estimation modified complex mult.
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
	c_n_est=mem[rd_addr_est];
	//c_n_fine=mem[rd_addr_fine];
end
 
endmodule