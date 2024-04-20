module cinit_gen_top #(parameter WIDTH=18 , WIDTH_A=8 , WIDTH_B=9)
(
	input wire clk, rst, run, 
	input wire [WIDTH_B-1:0] N_cell_ID,
	input wire [4:0] slot,
    output wire [27:0] cinit,
    output wire valid
);

wire [1:0] s4;
wire [2:0] s5;
wire [WIDTH-1:0] adder_out, out_a, b_out;
wire [WIDTH_A+WIDTH_B-1:0] mult_out;
wire en_add, en_mult, en_add_reg;

a_mux a_mux (
	.s4(s4),
	.adder_out(adder_out),
	.N_cell_ID(N_cell_ID),
	.ns(slot),
	.out_a(out_a)
	);

b_mux b_mux (
	.s5(s5),
	.mult_out(mult_out),
	.ns(slot),
	.b_out(b_out)
	);

adder adder (
	.clk(clk),
	.rst(rst),
	.en(en_add),
	.a(out_a),
	.b(b_out),
	.adder_out(adder_out)
	);

multiplier multiplier (
	.clk(clk),
	.rst(rst),
	.en(en_mult),
	.a(adder_out[WIDTH_A-1:0]),
	.b(N_cell_ID),
	.mult_out(mult_out)
	);

adder_register adder_register (
	.clk(clk),
	.rst(rst),
	.en(en_add_reg),
	.adder_out(adder_out),
	.adder_MSB(cinit[27:27-WIDTH+1])
	);

assign cinit[9:0] = adder_out[9:0];

cinit_control_unit cinit_control_unit (
	.clk(clk),
	.rst(rst),
	.run(run),
	.s4(s4),
	.s5(s5),
	.en_add(en_add),
	.en_mult(en_mult),
	.en_add_reg(en_add_reg),
	.valid(valid)
	);

endmodule
