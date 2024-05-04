//no fine sync in the design
module NRS_top_new_tx 
#(parameter 
	WIDTH_REG=16, 
	WIDTH_B=9,
	LINES= $clog2(WIDTH_REG), 
	NRS_WIDTH_R_I=16
)
(
	input wire clk, rst, new_frame, new_subframe, 
	//input wire est_ack,
	input wire [WIDTH_B-1:0] N_cell_ID,
	//input wire [LINES-1:0] rd_addr_mapper, rd_addr_fine, 
	input wire [LINES-1:0] rd_addr_mapper_1r, rd_addr_mapper_1i, rd_addr_mapper_2r, rd_addr_mapper_2i,
	//output wire [NRS_WIDTH_R_I-1:0] nrs_mapper, nrs_fine
	output wire [WIDTH_REG-1:0] nrs_mapper_1r, nrs_mapper_1i, nrs_mapper_2r, nrs_mapper_2i
	//output wire NRS_gen_ready
);

wire cinit_run;
wire [4:0] slot;
wire [27:0] cinit;
wire cinit_valid;
wire last_run, first_run;
wire shift_x, init_x1, init_x2, out, x1, x2, c_n, c0, c1, c2, c3;
wire wr_en;
wire [LINES-1:0] wr_addr;
//wire c_n_fine,c_n_est;
//wire c_n_est;

cinit_gen_top cinit_generator (
	.clk(clk),
	.rst(rst), 
	.run(cinit_run),
	.N_cell_ID(N_cell_ID),
	.slot(slot),
	.cinit(cinit),
	.valid(cinit_valid)
);

slot_counter_tx slot_counter (
	.clk(clk),
	.rst(rst), 
	.cinit_run(cinit_run),
	.slot(slot),
	.last_run(last_run),
	.first_run(first_run)
);

x1_LFSR x1_LFSR (
	.clk(clk),
	.rst(rst),  
	.en(shift_x),
	.init(init_x1), 
	.out(out),
	.x(x1)
);

x2_LFSR x2_LFSR (
	.clk(clk),
	.rst(rst),  
	.en(shift_x),
	.init(init_x2), 
	.out(out),
	.seed(cinit),
	.x(x2)
);

XOR XOR (
	.x1(x1),
	.x2(x2),
	.c_n(c_n)
);

NRS_reg_new_tx NRS_reg (
	.clk(clk), 
	.rst(rst), 
	.wr_en(wr_en),
    .c_n(c_n),	
	.wr_addr(wr_addr),
	.rd_addr_mapper_1r(rd_addr_mapper_1r),
	.rd_addr_mapper_1i(rd_addr_mapper_1i),
	.rd_addr_mapper_2r(rd_addr_mapper_2r),
	.rd_addr_mapper_2i(rd_addr_mapper_2i),
    .c0(c0), 
	.c1(c1), 
	.c2(c2), 
	.c3(c3) 
);

NRS_decision_muxes_tx NRS_decision_muxes (
	.c0(c0), 
	.c1(c1), 
	.c2(c2), 
	.c3(c3), 
	.nrs_mapper_1r(nrs_mapper_1r), 
	.nrs_mapper_1i(nrs_mapper_1i), 
	.nrs_mapper_2r(nrs_mapper_2r), 
	.nrs_mapper_2i(nrs_mapper_2i)
);

NRS_control_unit_tx NRS_control_unit (
	.clk(clk),
	.rst(rst), 
	.cinit_valid(cinit_valid),
	.new_frame(new_frame),
	.new_subframe(new_subframe),
	.last_run(last_run),
	.first_run(first_run),
	//.est_ack(est_ack),
	.shift_x(shift_x), 
	.out(out), 
	.wr_en(wr_en), 
	.init_x1(init_x1),
	.init_x2(init_x2), 
	.cinit_run(cinit_run),
	.wr_addr(wr_addr)
	//.NRS_gen_ready(NRS_gen_ready)
);

endmodule