module cmplx_mult_tb #(parameter 
	WIDTH_R_I=16,
	PILOT_FLOAT_BITS= 11, 
    VALUE= 11'b1011010_1000 //00000_1011010_1000 =  1/root(2)
 );
 //signal declaration
 reg clk, rst, en_tb;
 reg [1:0] wr_addr_tb, rd_addr_tb;
 reg [WIDTH_R_I-1:0] rx_r_tb, rx_i_tb;
 reg nrs_r_tb, nrs_i_tb;
 wire [WIDTH_R_I :0] real_part_dut, imag_part_dut;

 reg [WIDTH_R_I :0] real_part_expec, imag_part_expec;

 //internal signals

 //instantiation
 