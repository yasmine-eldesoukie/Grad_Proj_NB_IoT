module cmplx_mult_tb #(parameter 
	WIDTH_R_I=16
 );
 //signal declaration
 reg clk, rst, en_tb;
 reg [1:0] wr_addr_tb, rd_addr_tb;
 reg [WIDTH_R_I-1:0] rx_r_tb, rx_i_tb;
 reg nrs_r_tb, nrs_i_tb;
 wire [WIDTH_R_I-1 :0] real_part_dut, imag_part_dut; 

 reg [2*WIDTH_R_I :0] real_part_expec, imag_part_expec;

 //internal signals
 reg [WIDTH_R_I-1:0] nrs_r_value, nrs_i_value_true, nrs_i_value_filpped;
 //instantiation
 modified_complx_mult dut (
 	.clk(clk), 
 	.rst(rst), 
 	.en(en_tb),
	.wr_addr(wr_addr_tb), 
	.rd_addr(rd_addr_tb),
	.rx_r(rx_r_tb), 
	.rx_i(rx_i_tb),
	.nrs_r(nrs_r_tb), 
	.nrs_i(nrs_i_tb),
	.real_part(real_part_dut), 
	.imag_part(imag_part_dut)
 );

 //clk generation 
 initial begin
 	clk=1'b0;
 	forever #1 clk=~clk;
 end

 //stimulus generation
 integer i,j,k,m;
 initial begin
 	rst=1'b0;
 	repeat (30) @(negedge clk);
 	rst=1'b1;
    en_tb=1'b1;

    repeat (2) begin
        for (i=0; i<4; i=i+1) begin
    	    {nrs_r_tb, nrs_i_tb}=i;
    	    nrs_r_value         =(nrs_r_tb)? 16'b11111_0100101_1000: 16'b00000_1011010_1000 ;
    	    nrs_i_value_true    =(nrs_i_tb)? 16'b11111_0100101_1000: 16'b00000_1011010_1000 ; //it deals with signed numbers in a way that is not 2's comp.-->this is to get correct results
    	    nrs_i_value_filpped =(nrs_i_tb)? 16'b00000_1011010_1000: 16'b11111_0100101_1000 ;
    	    for (j=0; j<65536; j=j+1) begin
 			    rx_r_tb=j;
 		        for (k=0; k<65536; k=k+1) begin
 				    rx_i_tb=k;
 			        for (m=0; m<4; m=m+1) begin //4+1
 		                wr_addr_tb=m;
 		                @(negedge clk);
 		                rd_addr_tb=m;
 		                //if (m>0) begin
 		                	real_part_expec=(!en_tb)? 'b0: (rx_r_tb* nrs_r_value)     +(rx_i_tb* nrs_i_value_filpped); 
                            imag_part_expec=(!en_tb)? 'b0: (rx_r_tb* nrs_i_value_true)+(rx_i_tb* nrs_r_value);

                            @(negedge clk);
                            if (real_part_expec[2*WIDTH_R_I:WIDTH_R_I+1]!=real_part_dut) begin
                    	        $display("ERROR: real_part wrong at i= %0b, m= %0d, rx_r= %0d, rx_i= %0d", i,m,j,k);
                    	        $stop;
                            end
                            if (imag_part_expec[2*WIDTH_R_I:WIDTH_R_I+1]!=imag_part_dut) begin
                    	        $display("ERROR: imag_part wrong at i= %0b, j= %0d, rx_r= %0d, rx_i= %0d", i,m,j,k);
                    	        $stop;
                            end
 		                //end //if
 			        end//for m
 		        end//for k
 	        end//for j
        end//for i
    
        rst=1'b0; //just to see it on waveform easily
        repeat (10) @(negedge clk);
        en_tb=1'b0;
    end	//repeat
    $stop;
 end 
 endmodule

