/*
   (rx_r+ j rx_i)(nrs_r -j nrs_i) = [(rx_r* nrs_r)+(rx_i* nrs_i)] +j [(rx_i* nrs_r)-(rx_r* nrs_i)]
   s1= rx_r* nrs_r
   s2= rx_i* nrs_i
   s3= (nrs_r- nrs_i)(rx_r+ rx_i)
   real_part_reg= s1-s2
   imag_part_reg= s3-s2-s1

   nrs real or imag. parts take one of two values: + or - (1/root(2)) . Hence, nrs can take one of 4 options: 
      1- (+)(+j)
      2- (+)(-j)
      3- (-)(+j)
      4- (-)(-j)

   s1 and s2 multiplications are modified to a multiplication by a const (1/root(2)) and a multiplexer.
   for example: s1= rx_r* (1/root(2)) or  -rx_r* (1/root(2))

   s3 is modified in the same way with an added option of zero result if (nrs_r + nrs_i)=0

   for that we only need the sign of the nrs parts, this reduces complexity of design, area and power of multipliers  

*/
module signed_modified_complx_mult 
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

reg signed [WIDTH_R_I+PILOT_FLOAT_BITS-1:0] m1, s1, m2, s2; //27 bits
reg signed [WIDTH_R_I+PILOT_FLOAT_BITS+1:0] m3, s3; //29 bits
reg signed [WIDTH_R_I+PILOT_FLOAT_BITS:0] real_long; //28 bits 
reg signed [WIDTH_R_I+PILOT_FLOAT_BITS:0] imag_long; 

reg signed [WIDTH_R_I:0] real_est_mem [3:0];
reg signed [WIDTH_R_I:0] imag_est_mem [3:0];

integer i;
always @(*) begin
	//s1
	m1=rx_r* VALUE;
	if (nrs_r) begin
		s1= ~(m1)+1; //its 2's comp
	end
	else begin
		s1= m1;
	end

	//s2
	m2=rx_i* VALUE;
	if (nrs_i) begin
		s2= ~(m2)+1; //its 2's comp
	end
	else begin
		s2= m2;
	end

	//s3
	m3= (rx_r+ rx_i) *2 * VALUE ;
	if (nrs_r~^nrs_i) begin //xnor
		s3='d0;
	end
	else if (nrs_r) begin
		s3= ~(m3)+1;
	end
	else begin
		s3= m3; 
	end
    

	real_long= s1+s2;
	imag_long= s3+s2-s1;

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
