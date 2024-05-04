module NRS_decision_muxes_tx #(parameter NRS_WIDTH_R_I=16)(
	input wire c0, c1, c2, c3,  
	output reg [NRS_WIDTH_R_I-1:0] nrs_mapper_1r, nrs_mapper_1i, nrs_mapper_2r, nrs_mapper_2i
);

//1st pilot real part
always @(*) begin
	if (c0) begin
		nrs_mapper_1r='b11111_0100101_1000;
	end
	else begin
		nrs_mapper_1r='b00000_1011010_1000;
	end
end

//1st pilot imag part
always @(*) begin
	if (c1) begin
		nrs_mapper_1i='b11111_0100101_1000;
	end
	else begin
		nrs_mapper_1i='b00000_1011010_1000;
	end
end

//2nd pilot real part
always @(*) begin
	if (c2) begin
		nrs_mapper_2r='b11111_0100101_1000;
	end
	else begin
		nrs_mapper_2r='b00000_1011010_1000;
	end
end

//2nd pilot imag part
always @(*) begin
	if (c3) begin
		nrs_mapper_2i='b11111_0100101_1000;
	end
	else begin
		nrs_mapper_2i='b00000_1011010_1000;
	end
end

endmodule