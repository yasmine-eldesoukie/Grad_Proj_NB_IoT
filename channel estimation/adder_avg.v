//this module gets average values of real or imag parts of subcarrier h --> instantiated twice !!
module adder_avg #(parameter WIDTH_EST= 17, IN_WIDTH=17)
(
	input wire clk, rst, en,
	input wire [1:0] wr_addr,
	input wire [IN_WIDTH-1:0] a, b,
	output reg [WIDTH_EST-1:0] E1, E2, E3, E4
);

reg [WIDTH_EST:0] c;
reg [WIDTH_EST-1:0] adder_avg;
reg [WIDTH_EST-1:0] adder_avg_mem [3:0];

integer i;
always @(*) begin
	if (en) begin
	    c=a+b;
		adder_avg= c[WIDTH_EST:1];
	end
	else begin
		c='b0;
		adder_avg='b0;
	end
    
    E1= adder_avg_mem[0];
    E2= adder_avg_mem[1];
    E3= adder_avg_mem[2];
    E4= adder_avg_mem[3];

end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		for (i=0; i<4; i=i+1) begin
	    	adder_avg_mem[i]<= 'b0;
	    end
	end
	else if (en) begin
		adder_avg_mem[wr_addr]<=adder_avg;
	end
end

endmodule