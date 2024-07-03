module x2_LFSR #(parameter WIDTH=31)
(
input wire clk, rst, en, init, out,
input wire [27:0] seed,
output reg x
);

reg [WIDTH-1:0] LFSR;
reg feedback;

always @(*) begin
	feedback=(LFSR[0] ^ LFSR[1] ^ LFSR[2] ^ LFSR[3]);
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		LFSR<='b0;
	end
	else if (init) begin
		LFSR<= seed;
	end
	else if (en) begin
		LFSR<={feedback, LFSR[WIDTH-1:1]};
	end 
end

always @(*) begin
	if (out) begin
		x=LFSR[WIDTH-1];
	end
	else begin
		x=1'b0;
	end
end

endmodule 

