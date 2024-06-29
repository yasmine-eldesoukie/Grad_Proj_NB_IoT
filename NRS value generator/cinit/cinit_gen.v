module cinit_gen #(parameter WIDTH_B=9) (
	input wire clk, rst, run, 
	input wire [WIDTH_B-1:0] N_cell_ID,
	input wire [4:0] slot,
    output reg [27:0] cinit,
    output reg valid
);

reg switch;
reg [2:0] l;

always @(*) begin
	if (run) begin
		cinit = {(7*(slot+1)+l+1)*(2*N_cell_ID+1)}*1024 + 2*N_cell_ID + 1 ;
		valid = !switch;
	end
	else begin
		cinit = 'd0;
		valid = 'd0;
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
	    switch <= 1'b0;
	end
	else if (run) begin
		switch <= !switch;
	end
end

always @(*) begin
	if (switch) begin
		l= 'd6;
	end
	else begin
		l= 'd5;
	end
end

endmodule