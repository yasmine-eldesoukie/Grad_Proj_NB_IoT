module complx_mult #(parameter WIDTH_R_I=16)
(
	input wire [2 WIDTH_R_I-1:0] a,b,
	input wire en,
	output reg [4 WIDTH_R_I-1:0] complx_mult_out
 );

wire [WIDTH_R_I-1:0] ar, ai, br, bi;
reg [2 WIDTH_R_I-1:0] s1, s2, s3;
reg [2 WIDTH_R_I-1:0] real_part, imag_part;
always @(*) begin
    ar=a[2 WIDTH_R_I-1:WIDTH_R_I];
    ai=a[WIDTH_R_I-1:0];
    br=b[2 WIDTH_R_I-1:WIDTH_R_I];
    bi=b[WIDTH_R_I-1:0];

	if (en) begin
		s1= ar*ai;
		s2= br*bi;
		s3= (ar+ai)*(br+bi);
		real_part= s1-s2;
		imag_part= s3-s2-s1;
        complx_mult_out= {real_part, imag_part};
	end
	else begin
		s1= 'b0;
		s2= 'b0;
		s3= 'b0;
		real_part= s1-s2;
		imag_part= s3-s2-s1;
        complx_mult_out= {real_part, imag_part};
	end
end
endmodule
//is it better to use submodules of adders and multipliers to be able to completely turn off the complex multiplier?