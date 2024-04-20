//this module gets interpolated values of real and imag parts of h --> each block is instantiated twice !!
module interpolation_top 
#(parameter 
	IN_WIDTH= 17, 
	OUT_WIDTH= 16
)
(
	input wire clk, rst,
	input wire [1:0] s1a, s1b, s2a, s2b, s_h1, s_h2,
	input wire en_reg_h6, en_reg_2h6, en_reg_5h9,
	input wire [IN_WIDTH-1:0] h0_r, h6_r, h3_r, h9_r,
	input wire [IN_WIDTH-1:0] h0_i, h6_i, h3_i, h9_i,
	output wire [OUT_WIDTH-1:0] h_eqlz_1_r, h_eqlz_2_r,
	output wire [OUT_WIDTH-1:0] h_eqlz_1_i, h_eqlz_2_i
);

wire [IN_WIDTH:0] reg_2h6_r, reg_2h6_i;
wire [IN_WIDTH:0] add1_a_r, add1_a_i, add2_a_r, add2_a_i;
wire [IN_WIDTH+3-1:0] reg_5h9_r, reg_5h9_i;
wire [IN_WIDTH+3-1:0] add1_b_r, add1_b_i;
wire [IN_WIDTH-1:0] reg_h6_r, reg_h6_i;
wire [IN_WIDTH+2-1:0] add2_b_r, add2_b_i;
wire [IN_WIDTH+3-1:0] add1_r, add2_r, add1_i, add2_i;
wire [OUT_WIDTH-1:0] div1_res_r, div1_res_i, div2_res_r, div2_res_i;

//real part
mux_add1_a mux_add1_a_r (
	.sel(s1a),
	.h6(h6_r),
	.reg_2h6(reg_2h6_r),
	.add1_a(add1_a_r)
);

mux_add1_b mux_add1_b_r (
	.sel(s1b),
	.h3(h3_r),
	.h9(h9_r),
	.reg_5h9(reg_5h9_r),
	.add1_b(add1_b_r)
);

mux_add2_a mux_add2_a_r (
	.sel(s2a),
	.h3(h3_r),
	.h9(h9_r),
	.reg_h6(reg_h6_r),
	.add2_a(add2_a_r)
);

mux_add2_b mux_add2_b_r (
	.sel(s2b),
	.h0(h0_r),
	.h6(h6_r),
	.h9(h9_r),
	.add2_b(add2_b_r)
);

adder_interp adder1_r (
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
	.en_reg_h6(en_reg_h6), 
	.en_reg_2h6(en_reg_2h6), 
	.en_reg_5h9(en_reg_5h9),
	.adder1_res(add1_r), 
	.adder2_res(add2_r),
	.reg_h6(reg_h6_r),
	.reg_2h6(reg_2h6_r),
	.reg_5h9(reg_5h9_r)
); 

div_3 divider_1_r (
	.adder_out(add1_r),
	.div_3_out(div1_res_r)
);



div_3 divider_2_r (
	.adder_out(add2_r),
	.div_3_out(div2_res_r)
);

mux_h1 mux_h1_r (
	.sel(s_h1),
	.h0(h0_r[IN_WIDTH-1:1]),
	.h6(h6_r[IN_WIDTH-1:1]),
	.div_res_1(div1_res_r),
	.div_res_2(div2_res_r),
	.h_eqlz_1(h_eqlz_1_r)
);

mux_h2 mux_h2_r (
	.sel(s_h2),
	.h3(h3_r[IN_WIDTH-1:1]),
	.h9(h9_r[IN_WIDTH-1:1]),
	.div_res_1(div1_res_r),
	.div_res_2(div2_res_r),
	.h_eqlz_2(h_eqlz_2_r)
);

//imag part
mux_add1_a mux_add1_a_i (
	.sel(s1a),
	.h6(h6_i),
	.reg_2h6(reg_2h6_i),
	.add1_a(add1_a_i)
);

mux_add1_b mux_add1_b_i (
	.sel(s1b),
	.h3(h3_i),
	.h9(h9_i),
	.reg_5h9(reg_5h9_i),
	.add1_b(add1_b_i)
);

mux_add2_a mux_add2_a_i (
	.sel(s2a),
	.h3(h3_i),
	.h9(h9_i),
	.reg_h6(reg_h6_i),
	.add2_a(add2_a_i)
);

mux_add2_b mux_add2_b_i (
	.sel(s2b),
	.h0(h0_i),
	.h6(h6_i),
	.h9(h9_i),
	.add2_b(add2_b_i)
);

adder_interp adder1_i (
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
	.en_reg_h6(en_reg_h6), 
	.en_reg_2h6(en_reg_2h6), 
	.en_reg_5h9(en_reg_5h9),
	.adder1_res(add1_i), 
	.adder2_res(add2_i),
	.reg_h6(reg_h6_i),
	.reg_2h6(reg_2h6_i),
	.reg_5h9(reg_5h9_i)
); 

div_3 divider_1_i (
	.adder_out(add1_i),
	.div_3_out(div1_res_i)
);



div_3 divider_2_i (
	.adder_out(add2_i),
	.div_3_out(div2_res_i)
);

mux_h1 mux_h1_i (
	.sel(s_h1),
	.h0(h0_i[IN_WIDTH-1:1]),
	.h6(h6_i[IN_WIDTH-1:1]),
	.div_res_1(div1_res_i),
	.div_res_2(div2_res_i),
	.h_eqlz_1(h_eqlz_1_i)
);

mux_h2 mux_h2_i (
	.sel(s_h2),
	.h3(h3_i[IN_WIDTH-1:1]),
	.h9(h9_i[IN_WIDTH-1:1]),
	.div_res_1(div1_res_i),
	.div_res_2(div2_res_i),
	.h_eqlz_2(h_eqlz_2_i)
);

endmodule