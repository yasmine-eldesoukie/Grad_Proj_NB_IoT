module NRS_decision_muxes #(parameter NRS_WIDTH_R_I=16)(
	input wire c_n_fine, c_n_est,
	output reg [NRS_WIDTH_R_I-1:0] nrs_fine, nrs_est
);

always @(*) begin
	if (c_n_est) begin
		nrs_est='b11111_0100101_1000;
	end
	else begin
		nrs_est='b00000_1011010_1000;
	end
end

always @(*) begin
	if (c_n_fine) begin
		nrs_fine='b11111_0100101_1000;
	end
	else begin
		nrs_fine='b00000_1011010_1000;
	end
end

endmodule