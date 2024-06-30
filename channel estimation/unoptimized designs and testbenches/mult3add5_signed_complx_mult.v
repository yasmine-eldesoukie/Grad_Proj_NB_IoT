/*
   (rx_r+ j rx_i)(nrs_r -j nrs_i) = [(rx_r* nrs_r)+(rx_i* nrs_i)] +j [(rx_i* nrs_r)-(rx_r* nrs_i)]
   s1= rx_r* nrs_r
   s2= rx_i* nrs_i
   s3= (nrs_r- nrs_i)(rx_r+ rx_i)
   real_part_reg= s1+s2
   imag_part_reg= s3+s2-s1
   
   using 3 mult instead of 4 and 5 adders instead of 2

*/
module mult3add5_signed_complx_mult 
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

reg signed [WIDTH_R_I+PILOT_FLOAT_BITS-1:0] s1, s2; //27 bits
reg signed [WIDTH_R_I+PILOT_FLOAT_BITS+1:0] s3; //29 bits
reg signed [PILOT_FLOAT_BITS:0] pilot_r, pilot_i;
reg signed [WIDTH_R_I+PILOT_FLOAT_BITS:0] real_long; //28 bits 
reg signed [WIDTH_R_I+PILOT_FLOAT_BITS:0] imag_long; 

reg signed [WIDTH_R_I:0] real_est_mem [3:0];
reg signed [WIDTH_R_I:0] imag_est_mem [3:0];

integer i;
always @(*) begin
	pilot_r=(nrs_r)? 12'sb1_0100101_1000: 12'sb0_1011010_1000;
	pilot_i=(nrs_i)? 12'sb1_0100101_1000: 12'sb0_1011010_1000;
    
    s1= rx_r* pilot_r ;
    s2= rx_i* pilot_i ;
    s3= (pilot_r- pilot_i)*(rx_r+ rx_i) ;

	real_long= s1 + s2 ;
	imag_long= s3 + s2 - s1 ;

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
