/*
  division is not synthesizable or with high complexity, but it can be manipulated for lower accuracy
  divison by 3 is the same as multipling by 1/3 or 0.33333 --> in binary it is 0.010101010 depending on accuracy
  0.010101 is approx 0.328125 , mult. by 2^6 --> 21
  so, divison can be implemented by multipling by 21 the shifting to the right by 6 

  Q_8.11 * Q_5.0 = Q_13.11 --> shift 6 bits to the right --> Q_13.5 (19 bits) but with max value calculations it's only 18 bits Q_13.4 ==> est 1
  Q_7.11 * Q_5.0 = Q_12.11 --> shift 6 bits to the right --> Q_12.5 (18 bits) ==> est 2
*/

module div_3 #(parameter //for adder_interp 1 chain 
	IN_WIDTH= 20, 
	CONST= 21,
	CONST_BITS= 5,
	MULT_RES_WIDTH= IN_WIDTH+CONST_BITS,
	SHFT_WIDTH=18,
  OUT_WIDTH= 17
)
(
	input wire signed [IN_WIDTH-1:0] adder_out,
	output reg signed [OUT_WIDTH-1:0] div_3_out
);

reg signed [MULT_RES_WIDTH-1:0] mult_res;
reg signed [SHFT_WIDTH-1:0] shft_6;
always @(*) begin
    mult_res = adder_out * 'sd21;
    shft_6 = mult_res >> 'd6;
    div_3_out= shft_6;
end

endmodule