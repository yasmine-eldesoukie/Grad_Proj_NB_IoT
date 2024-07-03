//needs modification for the new c_n_est instead of the old nrs_est_dut (NRS_decision_muxes)
`timescale 1ns/1ps
module NRS_top_tb 
#(parameter 
    WIDTH_REG=16, 
    WIDTH_B=9,
    LINES= $clog2(WIDTH_REG), 
    NRS_WIDTH_R_I=16,
    CLK_PERIOD=2,
    NUM_SHIFTS= 1600-31+1
);

reg clk, rst, new_frame_tb; 
reg [WIDTH_B-1:0] N_cell_ID_tb;
reg [LINES-1:0] rd_addr_est_tb, rd_addr_fine_tb; 
wire [NRS_WIDTH_R_I-1:0] nrs_est_dut, nrs_fine_dut;

reg [4:0] ns_tb;
reg [2:0] l_tb;
reg [30:0] x1,x2;
reg c_n_expec;
reg [3:0] n;  //counter
reg [NRS_WIDTH_R_I-1:0] NRS_r_expec, NRS_i_expec; 
reg [27:0] cinit_tb; 
reg first; //control signal

//dut instantiation
NRS_top_new_rx dut (
    .clk(clk),
    .rst(rst),
    .new_frame(new_frame_tb),
    .N_cell_ID(N_cell_ID_tb),
    .rd_addr_est(rd_addr_est_tb),
    .rd_addr_fine(rd_addr_fine_tb),
    .nrs_est(nrs_est_dut),
    .nrs_fine(nrs_fine_dut)
);

//clk generation
initial begin
    clk=1'b0;
    forever #(CLK_PERIOD/2) clk=~clk;
end

//stimulus generation 
integer i,j,k,m; 

initial begin
    rst= 1'b0;
    repeat (20) @(negedge clk);

    //test functionality for 1 subframe
    rst=1'b1;
    first=1'b1; 
    //repeat (10) @(negedge clk);

    for (i=0; i<505; i=i+1) begin
        repeat (10) @(negedge clk); //delay of new frame
        N_cell_ID_tb=i;
        new_frame_tb=1'b1;
        @(negedge clk);
        new_frame_tb=1'b0;
        for (j=0; j<20; j=j+1) begin //slot update
            if (j!=10 & j!=11) begin
                ns_tb=j;
                if (j%2==0)
                   n='d0; //new subframe each even slot--> reset n counter
                for (k=5; k<7; k=k+1) begin //update l
                    l_tb=k;
                    //all variables ready--> calculate cinit
                    cinit_tb={(7*(ns_tb+1)+l_tb+1)*(2*N_cell_ID_tb+1)*1024}+ 2* N_cell_ID_tb+1;
                    x1=31'b1;
                    x2=cinit_tb;
                    /* 1st time after reset takes 8 clks after cinit_run. After the 1st frame, the new cinit is ready after just 7 clks
                      cinit_run takes 2 clks after the new_frame signal, one of them is used when N_cell_ID is updated
                      then one more clk for init signal (SEED state)
                      --> 10 clks after reset, 9 for the 1st evaluation of each new frame and 1 clk (SEED state) for others
                    */
                    //waiting
                    if (first==1) begin
                       repeat (10) @(negedge clk);
                       first='b0;
                    end
                    else if (j==0 & k==5) begin //new frame
                       repeat (9) @(negedge clk);
                    end
                    //else if (k==6) begin //SEED state delay
                       //@(negedge clk);
                    //end
                    else begin
                       /*repeat (2)*/ @(negedge clk);
                    end
                    
                    //shifting 
                    for (m=0; m<NUM_SHIFTS+4; m =m+1) begin //get expected nrs value
                        x1={(x1[0]^x1[3]),x1[30:1]};
                        x2={(x2[3]^x2[2]^x2[1]^x2[0]), x2[30:1]};
                        @(negedge clk); //to see change of each shift
                        if (m>=NUM_SHIFTS) begin //evaluate and check
                            c_n_expec=x1[29]^x2[29]; //this value is ready at x[30] when m=NUM_SHIFTS-1 , but c_n mem will be ready after 2 clk (at m= NUM+1)
                            rd_addr_est_tb=n;
                            rd_addr_fine_tb=n;
                            
                            @(posedge clk); 
                            //checking real part
                            if (n%2==0) begin
                                NRS_r_expec=(c_n_expec==0)? 'b00000_1011010_1000: 'b11111_0100101_1000;
                                if (nrs_est_dut!=NRS_r_expec) begin
                                   $display("ERROR: real part of nrs_est is wrong at ns=%0d, l=%0d, N_cell=%0d",ns_tb, l_tb,  N_cell_ID_tb);
                                   $stop;
                                end
                                if (nrs_fine_dut!=NRS_r_expec) begin
                                   $display("ERROR: real part of nrs_fine is wrong at ns=%0d, l=%0d, N_cell=%0d",ns_tb, l_tb, N_cell_ID_tb);
                                   $stop;
                                end        

                            end
                            //checking imag part
                            else begin
                                NRS_i_expec=(c_n_expec==0)? 'b00000_1011010_1000: 'b11111_0100101_1000;
                                if (nrs_est_dut!=NRS_i_expec) begin
                                   $display("ERROR: imag part of nrs_est is wrong at ns=%0d, l=%0d, N_cell=%0d",ns_tb, l_tb, N_cell_ID_tb);
                                   $stop;
                                end
                                if (nrs_fine_dut!=NRS_i_expec) begin
                                   $display("ERROR: imag part of nrs_fine is wrong at ns=%0d, l=%0d, N_cell=%0d",ns_tb, l_tb, N_cell_ID_tb);
                                   $stop;
                                end   
                            end
                            n=n+1;
                        end //evaluation
                    end //m .. shift and evalute
                end //k
            end //slot = 10 nor 11 cond
        end //j
    end //i
    @(negedge clk);
    $stop;
end //initial
endmodule



