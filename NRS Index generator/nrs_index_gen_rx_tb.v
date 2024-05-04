module nrs_index_gen_rx_tb ();
//signal declaration
 reg [8:0] N_cell_ID_tb;
 reg [1:0] est_rd_addr_tb;
 reg [3:0] index_demap_expec; 
 reg [2:0] v_shift_expec;

 wire [3:0] index_demap_dut;
 wire [2:0] v_shift_dut;

  //internal signals 
  reg m;
  reg [1:0] v;
  reg [3:0] v_eq;

//instantiation
 nrs_index_gen_rx dut (
 	.N_cell_ID(N_cell_ID_tb),
 	.est_rd_addr(est_rd_addr_tb),
 	.index_demap(index_demap_dut),
 	.v_shift(v_shift_dut)
 );

 //stimulus generation 
 /*j=0--> m=0 , v=0
   j=1--> m=1 , v=0 
   j=2--> m=1 , v=3 
   j=3--> m=1 , v=3 
  */
 integer i,j;
 initial begin
 	for (i=0; i<505; i=i+1) begin
 		N_cell_ID_tb=i;
 		m='b1;
 		for (j=0; j<4; j=j+1) begin
 			est_rd_addr_tb=j;
            m=~m;
            v=(j>1)? 'd3 : 'd0;
 			v_shift_expec= N_cell_ID_tb % 6;
 			v_eq= 6*m+ (v+v_shift_expec);
 			index_demap_expec= (v_eq>11)? (v_eq-'d12) : v_eq;
 			#5
 			if (v_shift_expec!=v_shift_dut) begin
 				$display ("Error: v_shift");
 				$stop;
 			end
 			if (index_demap_expec!=index_demap_dut) begin
 				$display ("Error: index_demap");
 				$stop;
 			end
 		end
 	end
 	#5
 	$stop;
 end
 endmodule
