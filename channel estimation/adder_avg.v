//this module gets average values of real or imag parts of subcarrier h --> instantiated twice !!
module adder_avg #(parameter WIDTH_EST= 17)
(
	input wire clk, rst, en,
	input wire [1:0] wr_addr,
	input wire [WIDTH_PILOT-1:0] a, b,
	output reg [WIDTH_EST-1:0] h0, h6, h3, h9
);

reg [WIDTH_EST:0] c;
reg [WIDTH_EST-1:0] adder_avg;
reg [WIDTH_EST-1:0] adder_avg_mem [3:0];

always @(*) begin
	if (en) begin
	    c=a+b;
		adder_avg= c[WIDTH_EST:1];
	end
	else begin
		c='b0;
		adder_avg='b0;
	end
    
    h0= adder_avg_mem[0];
    h6= adder_avg_mem[1];
    h3= adder_avg_mem[2];
    h9= adder_avg_mem[3];

end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		adder_avg_mem<='b0;
	end
	else if (en) begin
		adder_avg_mem[addr]<=adder_avg;
	end
end

endmodule