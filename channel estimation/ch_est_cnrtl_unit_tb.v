`timescale 1ns/1ps
module ch_est_cntrl_unit_tb #(parameter
	NRS_ADDR=4,
 	OUT_SEL_SEQ_LENGTH= 12,
 	NRS_DELAY_CLK=1600
 	);
 //signal declaration
 //---------- inputs ----------
 reg clk, rst;
 reg demap_ready_tb, NRS_gen_ready_tb;
 reg [2:0] v_shift_tb;
 
 //---------- outputs dut ----------
 //outside --> to other blocks
 wire [3:0] col_dut;
 wire [1:0] nrs_index_addr_dut; 
 wire demap_read_dut;

 wire [NRS_ADDR-1:0] rd_addr_nrs_dut;
 wire valid_eqlz_dut;

 //within channel est. block
 wire [1:0] addr_mem_dut;
 wire mult_mem_en_dut, avg_mem_en_dut; 
 	
 //interpolation 
 wire en_reg_E_dut, en_reg_2E_dut, en_reg_5E_dut;
 wire [2:0] s1a_dut, s1b_dut, s2a_dut, s2b_dut; //adders muxes select signals
 wire [1:0] s_h1_dut, s_h2_dut; //out muxes select signals  
 wire s_est_dut; //estimate muxes select

 // ---------- outputs expec  ----------
 //outside --> to other blocks
 reg [3:0] col_expec;
 reg [1:0] nrs_index_addr_expec;
 reg demap_read_expec;

 reg [NRS_ADDR-1:0] rd_addr_nrs_expec;
 reg valid_eqlz_expec;

 //within channel est. block
 reg [1:0] addr_mem_expec;
 reg mult_mem_en_expec, avg_mem_en_expec; 
 	
 //interpolation 
 reg en_reg_E_expec, en_reg_2E_expec, en_reg_5E_expec;
 reg [2:0] s1a_expec, s1b_expec, s2a_expec, s2b_expec; 
 reg [1:0] s_h1_expec, s_h2_expec; 
 reg s_est_expec;

 //testbench internal signals
 reg [$clog2(NRS_DELAY_CLK)-1:0] x;
 reg slot1;
 reg [15:0] col_reg;


 //instantaition
 ch_est_cntrl_unit dut (
 	.clk(clk), 
 	.rst(rst),  
 	.demap_ready(demap_ready_tb),  
 	.NRS_gen_ready(NRS_gen_ready_tb), 
 	.v_shift(v_shift_tb), 

 	.col(col_dut), 
 	.nrs_index_addr(nrs_index_addr_dut), 
 	.demap_read(demap_read_dut), 

 	.rd_addr_nrs(rd_addr_nrs_dut), 
 	.valid_eqlz(valid_eqlz_dut), 

 	.addr_mem(addr_mem_dut), 
 	.mult_mem_en(mult_mem_en_dut), 
 	.avg_mem_en(avg_mem_en_dut), 
 	
 	.en_reg_E(en_reg_E_dut), 
 	.en_reg_2E(en_reg_2E_dut), 
 	.en_reg_5E(en_reg_5E_dut), 
 	.s1a(s1a_dut),  
 	.s1b(s1b_dut), 
 	.s2a(s2a_dut), 
 	.s2b(s2b_dut), 
 	.s_h1(s_h1_dut), 
 	.s_h2(s_h2_dut),  
 	.s_est(s_est_dut)
 );

 //clk generation 
 initial begin
 	clk='b0;
 	forever #1 clk=~clk; 
 end

 //stimulus generation
 integer i,j,k;
 initial begin
 	rst= 'b0;
 	repeat (50) @(negedge clk);
 	rst= 'b1;

    //all registers signals should be at reset value, check on waveform 
 	for (i=0; i<3; i=i+1) begin
 		{demap_ready_tb, NRS_gen_ready_tb}= i;
 		for (j=0; j<6; j=j+1) begin
 			v_shift_tb=j;
 			repeat (100) @(negedge clk);  
 		end
 	end
    
    //test just FSM (Mult. and Adder)
        v_shift_tb=0;
        slot1=1'b0;
        col_reg={4'd13, 4'd12, 4'd6, 4'd5};
 		for (i=0; i<2; i=i+1) begin
 	    	demap_ready_tb=1'b1;
 	    	NRS_gen_ready_tb=1'b1;
 	    	slot1=~slot1;
        	demap_read_expec=1'b1;
        	mult_mem_en_expec=1'b0;
        	avg_mem_en_expec=1'b0;
        	if (i==0) rd_addr_nrs_expec='d14;
            //@(negedge clk);
            //NRS_gen_ready_tb=1'b0;

        	for (j=0; j<4; j=j+1) begin //4 because 4 pilots are operated apon in 1 run
        		addr_mem_expec=j;
        		nrs_index_addr_expec=j;
        		rd_addr_nrs_expec= rd_addr_nrs_expec+2; 
                if (j%2==0) begin
                	col_expec=col_reg[3:0];
                    col_reg=col_reg>>'d4;
                end
        		@(negedge clk); //FSM = MULT_STORE 
        		NRS_gen_ready_tb=1'b0;
        		if (j!=0) begin
        			mult_mem_en_expec=(slot1);
        	        avg_mem_en_expec=(!slot1);
        		end
        		if (demap_read_expec!=demap_read_dut) begin
        			$display ("Error: demap_read");
        			$stop;
        		end
        		if (mult_mem_en_expec!=mult_mem_en_dut) begin
        			$display ("Error: mult_mem_en");
        			$stop;
        		end
        		if (avg_mem_en_expec!=avg_mem_en_dut) begin
        			$display ("Error: avg_mem_en");
        			$stop;
        		end
        		if (addr_mem_expec!=addr_mem_dut) begin
        			$display ("Error: addr_mem");
        			$stop;
        		end
        		if (nrs_index_addr_expec!=nrs_index_addr_dut) begin
        			$display ("Error: nrs_index_addr");
        			$stop;
        		end
        		if (rd_addr_nrs_expec!=rd_addr_nrs_dut) begin
        			$display ("Error: rd_addr_nrs");
        			$stop;
        		end
        		if (col_expec!=col_dut) begin
        			$display ("Error: col");
        			$stop;
        		end
        	end //for j
        	demap_read_expec=1'b0;
        	if (slot1) begin
        		x=NRS_DELAY_CLK/4-4;
 	        	repeat (x) @(negedge clk);    
        	end
 		end //for i
        @(negedge clk);
        $stop;

 end //initial
endmodule
