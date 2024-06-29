`timescale 1ns/1ps
module cinit_gen_tb #(parameter WIDTH=18 , WIDTH_A=8 , WIDTH_B=9, CLK_PERIOD=2);
reg clk, rst, run_tb;
reg [WIDTH_B-1:0] N_cell_ID_tb;
reg [4:0] ns_tb;
wire [27:0] cinit_dut;
wire cinit_valid_dut, last_run_dut ;

reg [2:0] l_tb;
reg [27:0] cinit_expec;
reg cinit_valid_expec /*, last_run_expec*/;

cinit_gen dut (
	.clk(clk),
	.rst(rst), 
	.run(run_tb),
	.N_cell_ID(N_cell_ID_tb),
	.slot(ns_tb),
	.cinit(cinit_dut),
	.valid(cinit_valid_dut)
	//.last_run(last_run_dut)
);

//clk generation
initial begin
	clk= 1'b0;
	forever #(CLK_PERIOD/2) clk=~clk;
end

//stimulus generation
integer i,j,k;
initial begin
	rst=1'b0;
	run_tb=1'b0;
	repeat (20) @(negedge clk);

	/*
	//test reset dominance 
	run_tb=1'b1;
	repeat (5) @(negedge clk);
	*/

	//test that as long as run != 1 , block is off
	rst=1'b1;
	run_tb=1'b0;

	cinit_expec='b0;
    cinit_valid_expec=1'b0;
    //last_run_expec=1'b0; 

	for (i=0; i<505; i=i+1) begin
		N_cell_ID_tb=i;
		repeat (5) @(negedge clk); // delay for a new farme
		for (j=0; j<20; j=j+1) begin
			if (~(j==10 | j==11 )) begin
	            for (k=5; k<7; k=k+1) begin
                    /*
                    if (k==5)
			           repeat (7) @(negedge clk); 
			        else
			           repeat (8) @(negedge clk); //one more clk for l=6			        
                    */
                    @(negedge clk);

			        if (cinit_expec!= cinit_dut) begin
				        $display ("ERROR: cinit value wrong at ns_tb=%0d, l=%0d, N_cell_ID= %0d", ns_tb, l_tb, N_cell_ID_tb);
				        $stop;
			        end
			        if (j==0 & k==5 & (cinit_valid_expec != cinit_valid_dut)) begin
				       $display ("ERROR: cinit valid wrong");
				       $stop;
			        end
			        /*
			        if (j==19 & k==6) begin
 			           if (last_run_dut!= last_run_expec) begin
 			           	   $display ("ERROR: last run wrong");
				           $stop;
 			           end
			        end
			        */

			    repeat (2) @(negedge clk); //some delay before the new test
                end
			end
		end
	end

	//test functionality , a new output each 8 clks , test for 10 now then change later
	for (i=0; i<505; i=i+1) begin
		N_cell_ID_tb=i;
		repeat (5) @(negedge clk); // delay for a new farme
		//last_run_expec=1'b0; 
		for (j=0; j<20; j=j+1) begin
			if (~(j==10 | j==11 )) begin
 	            ns_tb=j;
	            for (k=5; k<7; k=k+1) begin
                    l_tb=k;
                    run_tb=1'b1;
			        /*
			        if (k==5)
			           repeat (6) @(negedge clk); //make it 6 for now
			        else
			           repeat (7) @(negedge clk); //one more clk for l=6
			        */
            	    cinit_expec={(7*(ns_tb+1)+l_tb+1)*(2*N_cell_ID_tb+1)*1024}+ 2* N_cell_ID_tb+1;
 			        cinit_valid_expec=(k==5);
                    
                    @(posedge clk);
			        if (cinit_expec!= cinit_dut) begin
				        $display ("ERROR: cinit value wrong at ns_tb=%0d, l=%0d, N_cell_ID= %0d", ns_tb, l_tb, N_cell_ID_tb);
				        $stop;
			        end
			        if (j==0 & k==5 & (cinit_valid_expec != cinit_valid_dut)) begin
				       $display ("ERROR: cinit valid wrong");
				       $stop;
			        end
			        /*
			        if (j==19 & k==6) begin
 			           last_run_expec=1'b1;
 			           if (last_run_dut!= last_run_expec) begin
 			           	   $display ("ERROR: last run wrong");
				           $stop;
 			           end
			        end
			        */

			    //@(negedge clk); //some delay before the new run
                end
			end
		end
	end

	@(negedge clk);
	$stop;

end
endmodule
