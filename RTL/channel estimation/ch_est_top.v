module ch_est_top #(parameter 
	WIDTH_EST=17,
	OUT_WIDTH=17,
	WIDTH_RX=16,
	NRS_ADDR=4
 )
 //signals 
 (   	
 	input wire clk, rst, 

    //from demapper to multiplier
	input wire signed [WIDTH_RX-1:0] rx_r, rx_i,
	input wire nrs_r, nrs_i,
    
    //from other blocks to control unit "ch_est_cntrl_unit"
	input wire demap_ready, NRS_gen_ready,
 	input wire [2:0] v_shift,
    
    //to equalizer
 	output wire signed [OUT_WIDTH-1:0] h_eqlz_1_r, h_eqlz_2_r,
	output wire signed [OUT_WIDTH-1:0] h_eqlz_1_i, h_eqlz_2_i,
	output wire valid_eqlz,

    //to demapper
 	output wire [3:0] col_demap,
 	output wire demap_read, est_ack_demap,
 	//output reg [3:0] row, //it's calculated at nrs_index gen

 	//to nrs_index_gen
 	output wire [1:0] nrs_index_addr, 

 	//to nrs_value_gen 
 	output wire [NRS_ADDR-1:0] rd_addr_nrs,
 	output wire est_ack_nrs
 	
 );

 //internal signals
 wire mult_mem_en;
 wire [1:0] addr_mem;
 wire signed [WIDTH_EST-1 :0] E_r_1, E_r_2, E_i_1, E_i_2, E1_r, E2_r, E3_r, E4_r, E1_i, E2_i, E3_i, E4_i;
 wire [2:0] s1a, s1b, s2a, s2b;
 wire [1:0] s_h1, s_h2;
 wire s_est;
 wire [1:0] shift;
 
 wire avg_mem_en, en_reg_E, en_reg_2E, en_reg_5E;

 //complex mult
 signed_modified_complx_mult cmplx_mult (
 	.clk(clk),
 	.rst(rst),
 	.en(mult_mem_en),
	.wr_addr(addr_mem),
	.rd_addr(addr_mem),
	.rx_r(rx_r),
	.rx_i(rx_i),
	.nrs_r(nrs_r),
	.nrs_i(nrs_i),
	.real_part_reg(E_r_1),
	.real_part(E_r_2),
	.imag_part_reg(E_i_1), 
	.imag_part(E_i_2)
 );

 //adder average
 adder_avg adder_avg_r (
 	.clk(clk),
 	.rst(rst),
 	.en(avg_mem_en),
	.wr_addr(addr_mem),
	.a(E_r_1),
	.b(E_r_2),
	.E1(E1_r),
	.E2(E2_r), 
	.E3(E3_r), 
	.E4(E4_r)
 );

 adder_avg adder_avg_i (
 	.clk(clk),
 	.rst(rst),
 	.en(avg_mem_en),
	.wr_addr(addr_mem),
	.a(E_i_1),
	.b(E_i_2),
	.E1(E1_i),
	.E2(E2_i), 
	.E3(E3_i), 
	.E4(E4_i)
 );
 
 //interpolation
 interpolation_top interpolation (
    .clk(clk), 
    .rst(rst),
    .s1a(s1a), 
    .s1b(s1b), 
    .s2a(s2a), 
    .s2b(s2b), 
    .s_h1(s_h1), 
    .s_h2(s_h2),
    .sel_est(s_est),
    .en_reg_E(en_reg_E), 
    .en_reg_2E(en_reg_2E), 
    .en_reg_5E(en_reg_5E),
	.shift(shift),
    .E1_r(E1_r), 
    .E2_r(E2_r), 
    .E3_r(E3_r), 
    .E4_r(E4_r),
    .E1_i(E1_i), 
    .E2_i(E2_i), 
    .E3_i(E3_i), 
    .E4_i(E4_i),
	.h_eqlz_1_r(h_eqlz_1_r), 
	.h_eqlz_2_r(h_eqlz_2_r),
	.h_eqlz_1_i(h_eqlz_1_i), 
	.h_eqlz_2_i(h_eqlz_2_i)
 );
 
 //control unit
 ch_est_cntrl_unit cntrl_unit (
 	.clk(clk), 
    .rst(rst), 
 	.demap_ready(demap_ready), 
 	.NRS_gen_ready(NRS_gen_ready),
 	.v_shift(v_shift),
 	.col(col_demap),
 	.nrs_index_addr(nrs_index_addr), 
 	.demap_read(demap_read),
    .est_ack_nrs(est_ack_nrs), 
    .est_ack_demap(est_ack_demap),
 	.rd_addr_nrs(rd_addr_nrs),
 	.valid_eqlz(valid_eqlz),
 	.addr_mem(addr_mem),
 	.mult_mem_en(mult_mem_en), 
 	.avg_mem_en(avg_mem_en), 
 	.en_reg_E(en_reg_E), 
    .en_reg_2E(en_reg_2E), 
    .en_reg_5E(en_reg_5E),
 	.s1a(s1a), 
    .s1b(s1b), 
    .s2a(s2a), 
    .s2b(s2b), 
    .s_h1(s_h1), 
    .s_h2(s_h2),
 	.s_est(s_est),
 	.shift(shift)
 );
 
endmodule
