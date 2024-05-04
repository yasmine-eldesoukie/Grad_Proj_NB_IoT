/*
   (rx_r+ j rx_i)(nrs_r -j nrs_i) = [(rx_r* nrs_r)+(rx_i* nrs_i)] +j [(rx_i* nrs_r)- (rx_r* nrs_i)]
   s1= rx_r* nrs_r
   s2= rx_i* nrs_i
   s3= (nrs_r- nrs_i)(rx_r+ rx_i)
   real_part= s1+s2
   imag_part= s3+s2-s1

   nrs real or imag. parts take one of two values: + or - (1/root(2)) . Hence, nrs can take one of 4 options: 
      1- (+)(+j)
      2- (+)(-j)
      3- (-)(+j)
      4- (-)(-j)

   s1 and s2 multiplications are modified to a multiplication by a const (1/root(2)) and a mux.
   for example: s1= rx_r* (1/root(2)) or  -rx_r* (1/root(2))

   s3 is modified in the same way with an added option of zero result if (nrs_r - nrs_i)=0

   for that we only need the sign of the nrs parts, this reduces complexity of design, area and power of multipliers  

*/
/* take care of sign extension*/
module modified_complx_mult 
#(parameter 
	WIDTH=16,
    VALUE= 15'b1011010_1000 //00000_1011010_1000 =  1/root(2)
)
(
	input wire clk, rst, en,
	input wire [1:0] wr_addr, rd_addr,
	input wire [WIDTH-1:0] rx_r, rx_i,
	input wire nrs_r, nrs_i,
	output reg [WIDTH-1:0] real_part, imag_part //max needed bits are 16 for real and 17 for imag part from original equation and the max actual values 
);

//reg [WIDTH+PILOT_BITS-1:0] m1, s1, m2, s2, m3, s3;
reg [2*WIDTH-3:0] m1, m1_abs, m2, m2_abs;  //max is (-2^15)*(1/root 2)< 2^15 signed --> 15 bit for value and 1 for sign--> (16 bit)
reg [2*WIDTH-1:0] m3, m3_abs; //max is 2*(-2^15)*2*(1/root 2)--> (18 bits) , s1_long and s2_long are sign extended versions
reg [2*WIDTH-2:0] s1, s2;
reg [2*WIDTH:0] s3, s1_long, s2_long;

reg [2*WIDTH-2:0] real_long;
reg [2*WIDTH:0] real_long_ext;
reg [2*WIDTH:0] imag_long;

reg [2*WIDTH:0] real_est_mem [3:0];
reg [2*WIDTH:0] imag_est_mem [3:0];

reg [WIDTH-2:0] rx_r_abs, rx_i_abs;
reg [WIDTH:0] rx;
reg [WIDTH-1:0] rx_abs; 

integer i;
always @(*) begin
	//s1
	if (rx_r[WIDTH-1]) begin
	    rx_r_abs= ~rx_r[WIDTH-2:0]+1'd1;
    end
    else begin
	    rx_r_abs=rx_r[WIDTH-2:0];
    end

	m1=rx_r_abs* VALUE;
	if (nrs_r^rx_r[WIDTH-1]) begin
	    m1_abs= ~m1+1'd1;
		s1= {1'b1, m1_abs[2*WIDTH-3:0]}; //its 2's comp
	end
	else begin
		s1= {1'b0, m1[2*WIDTH-3:0]};
		m1_abs= 'd0;
	end
	s1_long= {{2{s1[2*WIDTH-2]}} ,s1};




	//s2
	if (rx_i[WIDTH-1]) begin
	    rx_i_abs= ~rx_i[WIDTH-2:0]+1'd1;
    end
    else begin
	    rx_i_abs=rx_i[WIDTH-2:0];
    end

	m2=rx_i_abs* VALUE;
	if (nrs_i^rx_i[WIDTH-1]) begin
	    m2_abs= ~m2+1'd1;
		s2= {1'b1, m2_abs[2*WIDTH-3:0]}; //its 2's comp
	end
	else begin
		s2= {1'b0, m2[2*WIDTH-3:0]};
		m2_abs= 'd0;
	end
	s2_long= {{2{s2[2*WIDTH-2]}} ,s2};




	//s3
	rx=(rx_r+ rx_i);
	if (rx[WIDTH]) begin
		rx_abs= ~rx[WIDTH-1:0]+1'd1;
	end
	else begin
		rx_abs=rx[WIDTH-1:0];
	end
	m3= rx_abs * 2 * VALUE ;

	if (nrs_r^(!nrs_i))  begin
		s3='d0;
		m3_abs='d0;
	end
	else if (nrs_r^rx[WIDTH]) begin
        m3_abs= ~m3+1'd1;
        s3= {1'b1, m3_abs[2*WIDTH-1:0]};	
    end
	else begin
		s3= {1'b0, m3[2*WIDTH-1:0]};
		m3_abs='d0;
	end

	real_long= s1+s2;
	real_long_ext= {2{real_long[2*WIDTH-2], real_long}};
	imag_long= s3+ s2_long-s1_long;

	real_part= real_est_mem[rd_addr];
	imag_part= imag_est_mem[rd_addr];
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
	    for (i=0; i<4; i=i+1) begin
	    	real_est_mem[i]<= 'b0;
		    imag_est_mem[i]<= 'b0;
	    end
	end
	else if (en) begin
	    real_est_mem[wr_addr] <= real_long_ext;
	    imag_est_mem[wr_addr] <= imag_long;
	end
end
endmodule
