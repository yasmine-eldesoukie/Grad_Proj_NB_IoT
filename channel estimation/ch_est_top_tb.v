module ch_est_top_tb #(parameter
	WIDTH_EST=17,
	OUT_WIDTH=17,
	WIDTH_RX=16,
	NRS_ADDR=4
 );
 //signal declaration
 reg clk, rst;
 reg signed [WIDTH_RX-1:0] rx_r_tb, rx_i_tb;
 reg nrs_r_tb, nrs_i_tb;
 reg demap_ready_tb, NRS_gen_ready_tb;
 reg [2:0] v_shift_tb;

 wire signed [OUT_WIDTH-1:0] h_eqlz_1_r_dut, h_eqlz_2_r_dut;
 wire signed [OUT_WIDTH-1:0] h_eqlz_1_i_dut, h_eqlz_2_i_dut;
 wire valid_eqlz_dut;
 wire [3:0] col_demap_dut;
 wire demap_read_dut, est_ack_demap_dut;
 wire [1:0] nrs_index_addr_dut;
 wire [NRS_ADDR-1:0] rd_addr_nrs_dut;
 wire est_ack_nrs_dut;

 reg signed [OUT_WIDTH-1:0] h_eqlz_1_r_expec, h_eqlz_2_r_expec;
 reg signed [OUT_WIDTH-1:0] h_eqlz_1_i_expec, h_eqlz_2_i_expec;
 reg valid_eqlz_expec;
 reg [3:0] col_demap_expec;
 reg demap_read_expec, est_ack_demap_expec;
 reg [1:0] nrs_index_addr_expec;
 reg [NRS_ADDR-1:0] rd_addr_nrs_expec;
 reg est_ack_nrs_expec;

 //internal signals

 //instantiation
 ch_est_top dut (
 	.clk(clk),
 	.rst(rst),
 	.rx_r(rx_r_tb),
 	.rx_i(rx_i_tb),
 	.nrs_r(nrs_r_tb), 
 	.nrs_i(nrs_i_tb),
 	.demap_ready(demap_ready_tb), 
 	.NRS_gen_ready(NRS_gen_ready_tb),
 	.v_shift(v_shift_tb),
 	.h_eqlz_1_r(h_eqlz_1_r_dut), 
 	.h_eqlz_2_r(h_eqlz_2_r_dut),
 	.h_eqlz_1_i(h_eqlz_1_i_dut), 
 	.h_eqlz_2_i(h_eqlz_2_i_dut),
 	.valid_eqlz(valid_eqlz_dut),
 	.col_demap(col_demap_dut),
 	.demap_read(demap_read_dut), 
 	.est_ack_demap(est_ack_demap_dut),
 	.nrs_index_addr(nrs_index_addr_dut),
 	.rd_addr_nrs(rd_addr_nrs_dut),
 	.est_ack_nrs(est_ack_nrs_dut)
 );

 //clk generation
 initial begin
 	clk='b0;
 	forever #1 clk=~clk;
 end

 //stimulus generation
 integer i,j,k;
 initial begin
 	rst='b0; 
 	repeat (30) @(negedge clk);

    rst=1'b1;
    v_shift_tb='d0;
    NRS_gen_ready_tb=1'b1; //at negedge, then follow it with a posedge
    demap_ready_tb=1'b1;
    @(posedge clk); //MULT_STORE
    rx_r_tb= 'd1234;
    rx_i_tb= 'd3456;
    nrs_r_tb=1'b0;
    nrs_i_tb=1'b0;
    @(posedge clk);
    rx_r_tb= 'd1122;
    rx_i_tb= -'sd1732;
    nrs_r_tb=1'b0;
    nrs_i_tb=1'b0;
    NRS_gen_ready_tb=1'b0;
    repeat (2) @(negedge clk); //any delay

    NRS_gen_ready_tb=1'b1;
    @(posedge clk); //2nd MULT_STORE
    rx_r_tb= 'd15567;
    rx_i_tb= 'd1077;
    nrs_r_tb=1'b0;
    nrs_i_tb=1'b0;
    @(posedge clk);
    rx_r_tb= 'd15507;
    rx_i_tb= 'd1097;
    nrs_r_tb=1'b0;
    nrs_i_tb=1'b0;
    NRS_gen_ready_tb=1'b0;
    repeat (2) @(negedge clk);

    NRS_gen_ready_tb=1'b1;
    @(posedge clk); //MULT_ADD
    rx_r_tb= 'd1034;
    rx_i_tb= 'd3496;
    nrs_r_tb=1'b0;
    nrs_i_tb=1'b0;
    @(posedge clk);
    rx_r_tb= 'd13322;
    rx_i_tb= -'sd1232;
    nrs_r_tb=1'b0;
    nrs_i_tb=1'b0;
    NRS_gen_ready_tb=1'b0;
    repeat (2) @(negedge clk);

    NRS_gen_ready_tb=1'b1;
    @(posedge clk); //2nd MULT_ADD
    rx_r_tb= 'd11567;
    rx_i_tb= 'd1007;
    nrs_r_tb=1'b0;
    nrs_i_tb=1'b0;
    @(posedge clk);
    rx_r_tb= 'd1527;
    rx_i_tb= 'd1007;
    nrs_r_tb=1'b0;
    nrs_i_tb=1'b0;

    NRS_gen_ready_tb=1'b0;
    demap_ready_tb=1'b0;


    
    for (i=0; i<20; i=i+1) begin
     @(negedge clk);
    end
 	//test functionality (simple)
 	/*
 	for (i=0; i<4; i=i+1) begin
        {nrs_r_tb,nrs_i_tb}=i;
        //nrs_r_value= (nrs_r_tb)? 16'b11111_0100101_1000: 16'b00000_1011010_1000;
        //nrs_i_value= (nrs_i_tb)? 16'b11111_0100101_1000: 16'b00000_1011010_1000;

        real_part_expec=(!en_tb)? 'b0: (rx_r_tb* nrs_r_value)+ (rx_i_tb* nrs_i_value); 
        imag_part_expec=(!en_tb)? 'b0: (rx_i_tb* nrs_r_value)+~(rx_r_tb* nrs_i_value)+1'd1;

        wr_addr_tb=i;
        @(negedge clk);
        rd_addr_tb=i;

        if (real_part_expec[27:11]!=real_part_dut) begin
           $display("ERROR: real_part at i");
           //$stop;
        end
        if (imag_part_expec[27:11]!=imag_part_dut) begin
           $display("ERROR: imag_part at i");
           //$stop;
        end
        @(negedge clk);
    end 
    */	
    $stop;

 end

endmodule