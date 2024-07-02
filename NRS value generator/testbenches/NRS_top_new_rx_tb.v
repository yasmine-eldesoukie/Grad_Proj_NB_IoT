//needs modification for the new c_n_est instead of the old nrs_est_dut (NRS_decision_muxes)
`timescale 1ns/1ps
module NRS_top_new_rx_tb 
#(parameter 
    WIDTH_REG=16, 
    WIDTH_B=9,
    LINES= $clog2(WIDTH_REG), 
    NRS_WIDTH_R_I=16,
    CLK_PERIOD=2,
    NUM_SHIFTS= 1600-31+1
);

reg clk, rst, new_frame_tb, new_subframe_tb, est_ack_tb; 
reg [WIDTH_B-1:0] N_cell_ID_tb;
//reg [LINES-1:0] rd_addr_est_tb, rd_addr_fine_tb;
reg [LINES-1:0] rd_addr_est_tb; 
//wire [NRS_WIDTH_R_I-1:0] nrs_est_dut, nrs_fine_dut;
wire nrs_est_r_dut, nrs_est_i_dut, NRS_gen_ready_dut;

reg [4:0] ns_tb;
reg [2:0] l_tb;
reg [30:0] x1,x2;
reg c_n_r_expec, c_n_i_expec;
reg [3:0] n;  //counter
reg NRS_r_expec, NRS_i_expec, NRS_gen_ready_expec; 
reg [27:0] cinit_tb; 
reg first; //control signal

//dut instantiation
NRS_top_new_rx dut (
    .clk(clk),
    .rst(rst),
    .new_frame(new_frame_tb),
    .new_subframe(new_subframe_tb),
    .est_ack(est_ack_tb),
    .N_cell_ID(N_cell_ID_tb),
    .rd_addr_est(rd_addr_est_tb),
    //.rd_addr_fine(rd_addr_fine_tb),
    .nrs_est_r(nrs_est_r_dut),
    .nrs_est_i(nrs_est_i_dut),
    //.nrs_fine(nrs_fine_dut)
    .NRS_gen_ready(NRS_gen_ready_dut)
);

//clk generation
initial begin
    clk=1'b0;
    forever #(CLK_PERIOD/2) clk=~clk;
end

//stimulus generation 
integer i,j,k,m,b; 

initial begin
    rst= 1'b0;
    repeat (20) @(negedge clk);

    //test functionality 
    rst=1'b1;
    first=1'b1; 
    //repeat (10) @(negedge clk);
    
    est_ack_tb=1'b0;
    n=0;
    for (i=0; i<505; i=i+1) begin
        repeat (10) @(negedge clk); //delay of new frame
        N_cell_ID_tb=i;
        new_frame_tb=1'b1;
        x1=31'b1;

        @(negedge clk);
        new_frame_tb=1'b0;
        for (j=0; j<20; j=j+1) begin //slot update
            if (j!=10 & j!=11) begin
                ns_tb=j;
                //if (j%2==0)
                   //n='d0; //new subframe each even slot--> reset n counter
                for (k=5; k<7; k=k+1) begin //update l
                    l_tb=k;
                    //all variables ready--> calculate cinit
                    cinit_tb={(7*(ns_tb+1)+l_tb+1)*(2*N_cell_ID_tb+1)*1024}+ 2* N_cell_ID_tb+1;
                    x2=cinit_tb;
                    /* 1st time after reset takes 7 clks after cinit_run. After the 1st frame, the new cinit is ready after just 6 clks--> why? 
                      cinit_run takes 2 clks after the new_frame signal, one of them is used when N_cell_ID is updated
                      then one more clk for init signal (SEED state)
                      --> 9 clks after reset, 8 for the 1st evaluation of each new frame and 1 clk (SEED state) for others
                    */
                    //waiting
                    if (first==1) begin
                       repeat (9) @(negedge clk);
                       first='b0;
                    end
                    else if (j==0 & k==5) begin //new frame
                       repeat (9) @(negedge clk);
                    end
                    //else if (k==6) begin //SEED state delay
                       //@(negedge clk);
                    //end
                    else if (new_subframe_tb==1) begin
                        @(negedge clk);
                        new_subframe_tb=1'b0; 
                        repeat (10-1) @(negedge clk);
                    end
                    else begin
                       /*repeat (2)*/ @(negedge clk);
                    end

                    //shifting 
                    for (m=0; m<NUM_SHIFTS+4; m =m+1) begin //get expected nrs value
                        x1={(x1[0]^x1[3]),x1[30:1]};
                        x2={(x2[3]^x2[2]^x2[1]^x2[0]), x2[30:1]}; 

                        @(negedge clk); //to see change of each shift

                        if (m>=NUM_SHIFTS) begin //evaluate and check
                            NRS_gen_ready_expec= 1'b1;
                            if (NRS_gen_ready_expec != NRS_gen_ready_dut) begin
                                $display("ERROR: NRS_gen_ready wrong");
                                $stop;
                            end
                        end
                    end //shifting

                    est_ack_tb=1'b1;
                    NRS_gen_ready_expec=1'b0;
                    @(negedge clk);
                    if (NRS_gen_ready_expec != NRS_gen_ready_dut) begin
                        $display("ERROR: NRS_gen_ready wrong");
                        $stop;
                    end
                    
                    est_ack_tb= 1'b0;
                    for (b=0; b<2; b=b+1) begin
                        rd_addr_est_tb=n;
                        @(posedge clk);

                        if (b==0) c_n_r_expec= x1[26]^x2[26];
                        else c_n_r_expec= x1[26+2]^x2[26+2];

                        if (b==0) c_n_i_expec= x1[27]^x2[27];
                        else c_n_i_expec= x1[27+2]^x2[27+2];

                        if (nrs_est_r_dut != c_n_r_expec) begin
                            $display("ERROR: Real wrong");
                            $stop;
                        end

                        if (nrs_est_i_dut != c_n_i_expec) begin
                            $display("ERROR: Imag wrong");
                            $stop;
                        end 
                        n=n+2;
                        @(negedge clk);
                    end //repeat 2
                end //k
            end //slot = 10 nor 11 cond

            if (j%2 == 1 & (j!=19)) begin
                repeat (5) @(negedge clk); 
                new_subframe_tb=1'b1;
            end
        end //j
    end //i
    @(negedge clk);

    //test NRS_gen_ready 
    rst=1'b0;
    repeat (5) @(negedge clk);
    rst=1'b1;

    new_frame_tb=1'b1;
    @(negedge clk);
    new_frame_tb=1'b0;

    repeat (10+NUM_SHIFTS) @(negedge clk);
    NRS_gen_ready_expec=1'b1;

    for (i=0; i<10; i=i+1) begin
        if (NRS_gen_ready_expec!=NRS_gen_ready_dut) begin
            $display("ERROR: NRS_gen_ready");
            $stop;
        end
        @(negedge clk);
    end

    est_ack_tb=1'b1;
    @(negedge clk);
    NRS_gen_ready_expec=1'b0;
    if (NRS_gen_ready_expec!=NRS_gen_ready_dut) begin
            $display("ERROR: NRS_gen_ready");
            $stop;
    end
    @(negedge clk);
    $stop;
end //initial
endmodule



