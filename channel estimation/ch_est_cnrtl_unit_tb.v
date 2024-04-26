`timescale 1ns/1ps
module ch_est_cntrl_unit_tb #(parameter
	NRS_ADDR=4,
 	OUT_SEL_SEQ_LENGTH= 12
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
 reg slot1;
 reg [15:0] col_reg;
 reg [9*3-1:0] s1a_reg, s1b_reg, s2a_reg, s2b_reg; //10 clks , each part is 3 bits
 reg [9*2-1:0] s_h1_reg, s_h2_reg;
 reg [3:0] x;

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
    col_reg={4'd5, 4'd6, 4'd12, 4'd13};
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
                col_expec=col_reg[15:12];
                col_reg=col_reg<<'d4;
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
 	        repeat (10) @(negedge clk);   //test with any delay >=4
        end
 	end //for i

    //@(negedge clk);
    //$stop;

    //reset again because from the previous for loop, the block is in the interpolation state
    rst=1'b0;
    repeat (10) @(negedge clk);
    rst=1'b1;
    //test interpolation select signals and valid signal with the right latency
    for (i=0; i<6; i=i+1) begin
        v_shift_tb=i;
        s_est_expec= (i==1 | i==4)? 1'b1: 1'b0;

        //assign initial values of select signals registers
        case (i) 
           'd0, 'd3: begin
           	    s1a_reg=  {3'b000, 3'b001, 3'b001, 3'b011, 3'b011, 3'b011, 3'b010, 3'b111, 3'b111}; //LSB are dummy but must be added , because this reg is read from MSB to LSB, and in this case the MSB 8 (3 bits) are considered
           	    s1b_reg=  {3'b000, 3'b000, 3'b000, 3'b001, 3'b001, 3'b011, 3'b010, 3'b111, 3'b111};
           	    s2a_reg=  {3'b111, 3'b000, 3'b001, 3'b011, 3'b011, 3'b010, 3'b010, 3'b111, 3'b111};
           	    s2b_reg=  {3'b111, 3'b000, 3'b001, 3'b000, 3'b011, 3'b011, 3'b010, 3'b111, 3'b111};

           	    s_h1_reg= {2'b00,  2'b00,  2'b01,  2'b11,  2'b10,  2'b11,  2'b01,  2'b00, 2'b00 };//LSB are dummy
           	    s_h2_reg= {2'b00,  2'b00,  2'b01,  2'b00,  2'b00,  2'b11,  2'b10,  2'b00, 2'b00 };
           end

           'd1, 'd4: begin
           	    s1a_reg=  {3'b111, 3'b111, 3'b110, 3'b011, 3'b000, 3'b011, 3'b111, 3'b111, 3'b111};//same
                s1b_reg=  {3'b111, 3'b111, 3'b110, 3'b001, 3'b000, 3'b011, 3'b111, 3'b111, 3'b111};
                s2a_reg=  {3'b110, 3'b100, 3'b000, 3'b000, 3'b011, 3'b011, 3'b010, 3'b111, 3'b111};
                s2b_reg=  {3'b110, 3'b100, 3'b000, 3'b000, 3'b000, 3'b011, 3'b010, 3'b111, 3'b111};

                s_h1_reg= {2'b00,  2'b01,  2'b01,  2'b00,  2'b01,  2'b11,  2'b10,  2'b00, 2'b00 };
                s_h2_reg= {2'b00,  2'b01,  2'b10,  2'b10,  2'b11,  2'b10,  2'b00,  2'b00, 2'b00 };
           end

           'd2, 'd5: begin
           	    s1a_reg=  {3'b111, 3'b100, 3'b101, 3'b101, 3'b110, 3'b011, 3'b011, 3'b011, 3'b111};//here all data is needed
                s1b_reg=  {3'b111, 3'b000, 3'b100, 3'b100, 3'b110, 3'b001, 3'b001, 3'b011, 3'b111};
                s2a_reg=  {3'b001, 3'b110, 3'b100, 3'b000, 3'b000, 3'b011, 3'b011, 3'b111, 3'b111};
                s2b_reg=  {3'b100, 3'b110, 3'b100, 3'b000, 3'b000, 3'b000, 3'b011, 3'b111, 3'b111};


                s_h1_reg= {2'b00,  2'b00,  2'b11,  2'b00,  2'b11,  2'b11,  2'b10,  2'b01, 2'b00 };
                s_h2_reg= {2'b00,  2'b00,  2'b00,  2'b00,  2'b01,  2'b00,  2'b10,  2'b11, 2'b00 };
           end
        endcase

    	demap_ready_tb=1'b1;
        NRS_gen_ready_tb=1'b1;

        valid_eqlz_expec=1'b0;
        s1a_expec='b111;
        s1b_expec='b111;
        s2a_expec='b111;
        s2b_expec='b111;

        s_h1_expec='b00;
        s_h2_expec='b00;

        for (j=0; j<5; j=j+1) begin //4 for MULT_STORE and 1 for the IDLE (before MULT_ADD) in between
        	@(negedge clk);
        	if (valid_eqlz_expec!=valid_eqlz_dut) begin
        		$display ("Error: valid_eqlz");
        		$stop;
        	end

            if (s1a_expec!=s1a_dut) begin
        		$display ("Error: s1a");
        		$stop;
        	end
        	if (s1b_expec!=s1b_dut) begin
        		$display ("Error: s1b");
        		$stop;
        	end
        	if (s2a_expec!=s2a_dut) begin
        		$display ("Error: s2a");
        		$stop;
        	end
        	if (s2b_expec!=s2b_dut) begin
        		$display ("Error: s2b");
        		$stop;
        	end

        	if (s_h1_expec!=s_h1_dut) begin
        		$display ("Error: s_h1");
        		$stop;
        	end
        	if (s_h2_expec!=s_h2_dut) begin
        		$display ("Error: s_h2");
        		$stop;
        	end
        	if (s_est_expec!=s_est_dut) begin
        		$display ("Error: s_est");
        		$stop;
        	end
        end
        @(negedge clk); //extend NRS_gen_ready for 1 more clk, so that ns doesn't change before cs becomes MULT_ADD
        NRS_gen_ready_tb=1'b0; //because when you don't reset it, MULT_ADD doesn't go to IDLE, instead it goes to MULT_STORE while the interpolation is still working

        //determine latency before assigning and checking
        case (i)
            'd1, 'd4: begin //E3_ready is set after nrs_gen_ready by 3 clks
            	repeat (3) @(negedge clk);
            end
            default: begin //waiting for E2_ready
            	repeat (2) @(negedge clk);  
            end
        endcase

        x= (i==2 | i==5)? 'd9 : 'd8;
        
        for (j=0; j<x; j=j+1) begin //from this point and for the upcoming 8,9 clks, test the select and valid signals
            s1a_expec=s1a_reg[26:24];
            s1a_reg=s1a_reg<<'d3;
            s1b_expec=s1b_reg[26:24];
            s1b_reg=s1b_reg<<'d3;
            s2a_expec=s2a_reg[26:24];
            s2a_reg=s2a_reg<<'d3;
            s2b_expec=s2b_reg[26:24];
            s2b_reg=s2b_reg<<'d3;
            
            s_h1_expec=s_h1_reg[17:16];
            s_h2_expec=s_h2_reg[17:16];
            if (j!=(x-1)) begin //in the last run, s_h1 and s_h2 don't change, they remain on their latest value
            	s_h1_reg=s_h1_reg<<'d2;
            	s_h2_reg=s_h2_reg<<'d2;
            end 
            

            if (j==(x-1)) valid_eqlz_expec=1'b0; //j is [0:x-1] , the last run , valid is zero
            else if ( ((i==2 | i==5) & j>2) | (!(i==2 | i==5) & j>1) ) valid_eqlz_expec=1'b1;

            //test en_reg signals
            if ( ((i==0 | i==3) & j==1) | ((i==1 | i==4) & j==5) | ((i==2 | i==5) & j==2) ) en_reg_E_expec=1'b1;
            else en_reg_E_expec=1'b0;

            if ( ((i==0 | i==3) & j==2) | ((i==1 | i==4) & j==1) | ((i==2 | i==5) & j==2) ) en_reg_2E_expec=1'b1;
            else en_reg_2E_expec=1'b0;

            if ( ((i==0 | i==3) & j==6) | ((i==2 | i==5) & j==1) ) en_reg_5E_expec=1'b1;
            else en_reg_5E_expec=1'b0;


            //@(negedge clk); this is an added "wrong" delay, it should be at the for loop end
        	if (valid_eqlz_expec!=valid_eqlz_dut) begin
        		$display ("Error: valid_eqlz");
        		$stop;
        	end

            if (s1a_expec!=s1a_dut) begin
        		$display ("Error: s1a");
        		$stop;
        	end
        	if (s1b_expec!=s1b_dut) begin
        		$display ("Error: s1b");
        		$stop;
        	end
        	if (s2a_expec!=s2a_dut) begin
        		$display ("Error: s2a");
        		$stop;
        	end
        	if (s2b_expec!=s2b_dut) begin
        		$display ("Error: s2b");
        		$stop;
        	end

        	if (s_h1_expec!=s_h1_dut) begin
        		$display ("Error: s_h1");
        		$stop;
        	end
        	if (s_h2_expec!=s_h2_dut) begin
        		$display ("Error: s_h2");
        		$stop;
        	end
        	if (s_est_expec!=s_est_dut) begin
        		$display ("Error: s_est");
        		$stop;
        	end

        	if (en_reg_E_expec!=en_reg_E_dut) begin
        		$display ("Error: en_reg_E");
        		$stop;
        	end
        	if (en_reg_2E_expec!=en_reg_2E_dut) begin
        		$display ("Error: en_reg_2E");
        		$stop;
        	end
        	if (en_reg_5E_expec!=en_reg_5E_dut) begin
        		$display ("Error: en_reg_5E");
        		$stop;
        	end


        	@(negedge clk);
        end //for j
    end //for i
    @(negedge clk);
    $stop;
 end //initial
endmodule
