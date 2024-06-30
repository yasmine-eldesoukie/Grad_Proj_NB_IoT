/*
   (rx_r+ j rx_i)(nrs_r -j nrs_i) = [(rx_r* nrs_r)+(rx_i* nrs_i)] +j [(rx_i* nrs_r)-(rx_r* nrs_i)]
   using 4 mult and 2 adders
*/
module simple_signed_complx_mult 
#(parameter 
	WIDTH_R_I=16,
	PILOT_FLOAT_BITS= 11, 
    VALUE= 12'sb0_1011010_1000 //00000_1011010_1000 =  1/root(2)
)
(
	input wire clk, rst, en,
	input wire [1:0] wr_addr, rd_addr,
	input wire signed [WIDTH_R_I-1:0] rx_r, rx_i,
	input wire nrs_r, nrs_i,
	output reg signed [WIDTH_R_I :0] real_part_reg, imag_part_reg, //max needed bits are 17 
	output reg signed [WIDTH_R_I :0] real_part, imag_part
);

//reg signed [WIDTH_R_I+PILOT_FLOAT_BITS-1:0] m1, s1, m2, s2; //27 bits
//reg signed [WIDTH_R_I+PILOT_FLOAT_BITS+1:0] m3, s3; //29 bits
reg signed [PILOT_FLOAT_BITS:0] pilot_r, pilot_i;
reg signed [WIDTH_R_I+PILOT_FLOAT_BITS:0] real_long; //28 bits 
reg signed [WIDTH_R_I+PILOT_FLOAT_BITS:0] imag_long; 

reg signed [WIDTH_R_I:0] real_est_mem [3:0];
reg signed [WIDTH_R_I:0] imag_est_mem [3:0];

integer i;
always @(*) begin
	pilot_r=(nrs_r)? 12'sb1_0100101_1000: 12'sb0_1011010_1000;
	pilot_i=(nrs_i)? 12'sb1_0100101_1000: 12'sb0_1011010_1000;
	real_long= rx_r* pilot_r + rx_i* pilot_i;
	imag_long= rx_i* pilot_r - rx_r* pilot_i;

	real_part= real_long[WIDTH_R_I+PILOT_FLOAT_BITS:PILOT_FLOAT_BITS];
	imag_part= imag_long[WIDTH_R_I+PILOT_FLOAT_BITS:PILOT_FLOAT_BITS];

	real_part_reg= real_est_mem[rd_addr];
	imag_part_reg= imag_est_mem[rd_addr];
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
	    for (i=0; i<4; i=i+1) begin
	    	real_est_mem[i]<= 'b0;
		    imag_est_mem[i]<= 'b0;
	    end
	end
	else if (en) begin
		real_est_mem[wr_addr]<= real_long[WIDTH_R_I+PILOT_FLOAT_BITS:PILOT_FLOAT_BITS];
		imag_est_mem[wr_addr]<= imag_long[WIDTH_R_I+PILOT_FLOAT_BITS:PILOT_FLOAT_BITS];
	end
end
endmodule
