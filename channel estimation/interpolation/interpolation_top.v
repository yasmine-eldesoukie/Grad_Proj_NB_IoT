//this module gets interpolated values of real and imag parts of h --> each block is instantiated twice !!
module interpolation_top 
#(parameter 
	IN_WIDTH= 17, 
	OUT_WIDTH= 17
)
(
	input wire clk, rst,
	input wire [2:0] s1a, s1b, s2a, s2b, 
	input wire [1:0] s_h1, s_h2,
	input wire sel_est,
	input wire en_reg_E, en_reg_2E, en_reg_5E,
	input wire [IN_WIDTH-1:0] E1_r, E2_r, E3_r, E4_r,
	input wire [IN_WIDTH-1:0] E1_i, E2_i, E3_i, E4_i,
	output wire [OUT_WIDTH-1:0] h_eqlz_1_r, h_eqlz_2_r,
	output wire [OUT_WIDTH-1:0] h_eqlz_1_i, h_eqlz_2_i
);

wire [IN_WIDTH:0] reg_2E_r, reg_2E_i;
wire [IN_WIDTH+3-1:0] add1_a_r, add1_a_i; //20 bits
wire [IN_WIDTH+1:0] add2_a_r, add2_a_i; //19 bits
wire [IN_WIDTH+3-1:0] reg_5E_r, reg_5E_i;
wire [IN_WIDTH+3-1:0] add1_b_r, add1_b_i;
wire [IN_WIDTH-1:0] reg_E_r, reg_E_i;
wire [IN_WIDTH+2-1:0] add2_b_r, add2_b_i;
wire [IN_WIDTH+3-1:0] add1_r, add2_r, add1_i, add2_i;
wire [OUT_WIDTH-1:0] div1_res_r, div1_res_i, div2_res_r, div2_res_i; 
wire [IN_WIDTH-1:0] est1_r, est2_r, est3_r, est4_r, est1_i, est2_i, est3_i, est4_i;

//real part
mux_add1_a mux_add1_a_r (
	.sel(s1a),
	.E2(E2_r),
	.E3(E3_r),
	.reg_2E(reg_2E_r),
	.reg_5E(reg_5E_r),
	.add1_a(add1_a_r)
);

mux_add1_b mux_add1_b_r (
	.sel(s1b),
	.E1(E1_r),
	.E3(E3_r),
	.E4(E4_r),
	.reg_2E(reg_2E_r),
	.reg_5E(reg_5E_r),
	.add1_b(add1_b_r)
);

mux_add2_a mux_add2_a_r (
	.sel(s2a),
	.E1(E1_r),
	.E2(E2_r),
	.E3(E3_r),
	.E4(E4_r),
	.reg_E(reg_E_r),
	.add2_a(add2_a_r)
);

mux_add2_b mux_add2_b_r (
	.sel(s2b),
	.E1(E1_r),
	.E3(E3_r),
	.E4(E4_r),
	.reg_E(reg_E_r),
	.add2_b(add2_b_r)
);

adder_interp #(.WIDTH_SMALL(IN_WIDTH+3)) adder1_r (
	.a(add1_a_r),
	.b(add1_b_r),
	.out(add1_r)
);

adder_interp #(.WIDTH_BIG(IN_WIDTH+2)) adder2_r (
	.a(add2_a_r),
	.b(add2_b_r),
	.out(add2_r)
);

registers regs_r (
	.clk(clk),
	.rst(rst),
	.en_reg_E(en_reg_E), 
	.en_reg_2E(en_reg_2E), 
	.en_reg_5E(en_reg_5E),
	.adder1_res(add1_r), 
	.adder2_res(add2_r),
	.reg_E(reg_E_r),
	.reg_2E(reg_2E_r),
	.reg_5E(reg_5E_r)
); 

div_3 divider_1_r (
	.adder_out(add1_r),
	.div_3_out(div1_res_r)
);



div_3 divider_2_r (
	.adder_out(add2_r),
	.div_3_out(div2_res_r)
);

estimate_mux estimate_mux_r (
    .E1(E1_r),
    .E2(E2_r),
    .E3(E3_r),
    .E4(E4_r),
    .sel(sel_est),
    .est1(est1_r),
    .est2(est2_r),
    .est3(est3_r),
    .est4(est4_r)
);

mux_h1 mux_h1_r (
	.sel(s_h1),
	.est1(est1_r),
	.est2(est2_r),
	.div_res_1(div1_res_r),
	.div_res_2(div2_res_r),
	.h_eqlz_1(h_eqlz_1_r)
);

mux_h2 mux_h2_r (
	.sel(s_h2),
	.est3(est3_r),
	.est4(est4_r),
	.div_res_1(div1_res_r),
	.div_res_2(div2_res_r),
	.h_eqlz_2(h_eqlz_2_r)
);

//imag part
mux_add1_a mux_add1_a_i (
	.sel(s1a),
	.E2(E2_i),
	.E3(E3_i),
	.reg_2E(reg_2E_i),
	.reg_5E(reg_5E_i),
	.add1_a(add1_a_i)
);

mux_add1_b mux_add1_b_i (
	.sel(s1b),
	.E1(E1_i),
	.E3(E3_i),
	.E4(E4_i),
	.reg_2E(reg_2E_i),
	.reg_5E(reg_5E_i),
	.add1_b(add1_b_i)
);

mux_add2_a mux_add2_a_i (
	.sel(s2a),
	.E1(E1_i),
	.E2(E2_i),
	.E3(E3_i),
	.E4(E4_i),
	.reg_E(reg_E_i),
	.add2_a(add2_a_i)
);

mux_add2_b mux_add2_b_i (
	.sel(s2b),
	.E1(E1_i),
	.E3(E3_i),
	.E4(E4_i),
	.reg_E(reg_E_i),
	.add2_b(add2_b_i)
);

adder_interp #(.WIDTH_SMALL(IN_WIDTH+3)) adder1_i (
	.a(add1_a_i),
	.b(add1_b_i),
	.out(add1_i)
);

adder_interp #(.WIDTH_BIG(IN_WIDTH+2)) adder2_i (
	.a(add2_a_i),
	.b(add2_b_i),
	.out(add2_i)
);

registers regs_i (
	.clk(clk),
	.rst(rst),
	.en_reg_E(en_reg_E), 
	.en_reg_2E(en_reg_2E), 
	.en_reg_5E(en_reg_5E),
	.adder1_res(add1_i), 
	.adder2_res(add2_i),
	.reg_E(reg_E_i),
	.reg_2E(reg_2E_i),
	.reg_5E(reg_5E_i)
); 

div_3 divider_1_i (
	.adder_out(add1_i),
	.div_3_out(div1_res_i)
);



div_3 divider_2_i (
	.adder_out(add2_i),
	.div_3_out(div2_res_i)
);

estimate_mux estimate_mux_i (
    .E1(E1_i),
    .E2(E2_i),
    .E3(E3_i),
    .E4(E4_i),
    .sel(sel_est),
    .est1(est1_i),
    .est2(est2_i),
    .est3(est3_i),
    .est4(est4_i)
);

mux_h1 mux_h1_i (
	.sel(s_h1),
	.est1(est1_i),
	.est2(est2_i),
	.div_res_1(div1_res_i),
	.div_res_2(div2_res_i),
	.h_eqlz_1(h_eqlz_1_i)
);

mux_h2 mux_h2_i (
	.sel(s_h2),
	.est3(est3_i),
	.est4(est4_i),
	.div_res_1(div1_res_i),
	.div_res_2(div2_res_i),
	.h_eqlz_2(h_eqlz_2_i)
);


endmodule