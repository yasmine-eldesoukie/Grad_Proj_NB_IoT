module NRS_top 
#(parameter 
	WIDTH_REG=16, 
	WIDTH_B=9,
	LINES= $clog2(WIDTH_REG), 
	NRS_WIDTH_R_I=16
)
(
	input wire clk, rst, new_frame,
	input wire [WIDTH_B-1:0] N_cell_ID,
	input wire [LINES-1:0] rd_addr_est, rd_addr_fine, 
	output wire [NRS_WIDTH_R_I-1:0] nrs_est, nrs_fine
);

wire cinit_run;
wire [4:0] slot;
wire [27:0] cinit;
wire cinit_valid;
wire last_run;
wire shift_x, init, out, x1, x2, c_n;
wire wr_en;
wire [LINES-1:0] wr_addr;
wire c_n_fine,c_n_est;

cinit_gen_top cinit_generator (
	.clk(clk),
	.rst(rst), 
	.run(cinit_run),
	.N_cell_ID(N_cell_ID),
	.slot(slot),
	.cinit(cinit),
	.valid(cinit_valid)
);

slot_counter slot_counter (
	.clk(clk),
	.rst(rst), 
	.cinit_run(cinit_run),
	.slot(slot),
	.last_run(last_run)
);

x1_LFSR x1_LFSR (
	.clk(clk),
	.rst(rst),  
	.en(shift_x),
	.init(init), 
	.out(out),
	.x(x1)
);

x2_LFSR x2_LFSR (
	.clk(clk),
	.rst(rst),  
	.en(shift_x),
	.init(init), 
	.out(out),
	.seed(cinit),
	.x(x2)
);

XOR XOR (
	.x1(x1),
	.x2(x2),
	.c_n(c_n)
);

NRS_reg NRS_reg (
	.clk(clk), 
	.rst(rst), 
	.wr_en(wr_en),
	.c_n(c_n),
	.wr_addr(wr_addr),
	.rd_addr_est(rd_addr_est),
	.rd_addr_fine(rd_addr_fine),
	.c_n_est(c_n_est), 
	.c_n_fine(c_n_fine)
);

NRS_decision_muxes NRS_decision_muxes (
	.c_n_est(c_n_est), 
	.c_n_fine(c_n_fine),
	.nrs_fine(nrs_fine),
    .nrs_est(nrs_est)
);

NRS_control_unit NRS_control_unit (
	.clk(clk),
	.rst(rst), 
	.cinit_valid(cinit_valid),
	.new_frame(new_frame),
	.last_run(last_run),
	.shift_x(shift_x), 
	.out(out), 
	.wr_en(wr_en), 
	.init(init), 
	.cinit_run(cinit_run),
	.wr_addr(wr_addr)
);

endmodule