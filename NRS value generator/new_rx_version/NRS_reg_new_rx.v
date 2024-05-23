module NRS_reg_new_rx #(parameter WIDTH_REG=16 , LINES= $clog2(WIDTH_REG))
(
	input wire clk, rst, wr_en,
	input wire c_n,
	input wire [LINES-1:0] wr_addr,
	input wire [LINES-1:0] rd_addr_est,
	//input wire [LINES-1:0] rd_addr_fine,
	output reg c_n_est_r, c_n_est_i //will be nrs_est, no need for the whole value, this bit is enough for channel estimation modified complex mult.
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
	c_n_est_r=mem[rd_addr_est];
	c_n_est_i=mem[{rd_addr_est[LINES-1:1], 1'b1}]; //eqivlant to rd_addr_est+1 and since rd_add is always 0, 2, 4, etc (LSB is 0) , add +1 will just replace LSB by 1

	//c_n_fine=mem[rd_addr_fine];
end
 
endmodule