//needs modification for the new c_n_est instead of the old nrs_mapper_dut (NRS_decision_muxes)
`timescale 1ns/1ps
module NRS_top_new_tx_tb 
#(parameter 
    WIDTH_REG=16, 
    WIDTH_B=9,
    LINES= $clog2(WIDTH_REG), 
    //NRS_WIDTH_R_I=16,
    CLK_PERIOD=2,
    NUM_SHIFTS= 1600-31+1
);

reg clk, rst, new_frame_tb, new_subframe_tb; 
reg [WIDTH_B-1:0] N_cell_ID_tb;
//reg [LINES-1:0] rd_addr_mapper_tb, rd_addr_fine_tb;
reg [LINES-1:0] rd_addr_mapper_1r_tb, rd_addr_mapper_1i_tb, rd_addr_mapper_2r_tb, rd_addr_mapper_2i_tb;
//wire [NRS_WIDTH_R_I-1:0] nrs_mapper_dut, nrs_fine_dut;
wire [WIDTH_REG-1:0] nrs_mapper_1r_dut, nrs_mapper_1i_dut, nrs_mapper_2r_dut, nrs_mapper_2i_dut;

reg [4:0] ns_tb;
reg [2:0] l_tb;
reg [30:0] x1,x2;
reg c_n_expec;
//reg [3:0] n;  //counter
reg [LINES-1:0] x;
//reg [WIDTH_REG-1:0] NRS_1r_expec, NRS_1i_expec, NRS_2r_expec, NRS_2i_expec; 
reg [27:0] cinit_tb; 
reg first; //control signal

reg [WIDTH_REG-1:0] nrs_mapper_reg [WIDTH_REG-1:0];

//dut instantiation
NRS_top_new_tx dut (
    .clk(clk),
    .rst(rst),
    .new_frame(new_frame_tb),
    .new_subframe(new_subframe_tb),
    .N_cell_ID(N_cell_ID_tb),
    .rd_addr_mapper_1r(rd_addr_mapper_1r_tb),
    .rd_addr_mapper_1i(rd_addr_mapper_1i_tb),
    .rd_addr_mapper_2r(rd_addr_mapper_2r_tb),
    .rd_addr_mapper_2i(rd_addr_mapper_2i_tb),
    .nrs_mapper_1r(nrs_mapper_1r_dut), 
    .nrs_mapper_1i(nrs_mapper_1i_dut), 
    .nrs_mapper_2r(nrs_mapper_2r_dut), 
    .nrs_mapper_2i(nrs_mapper_2i_dut)
);

//clk generation
initial begin
    clk=1'b0;
    forever #(CLK_PERIOD/2) clk=~clk;
end

//stimulus generation 
integer i,j,k,m,y; 

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
        x1=31'b1; //only initialized once every new frame

        new_subframe_tb=1'b0;
        x=0;
        @(negedge clk);
        new_frame_tb=1'b0;
        for (j=0; j<20; j=j+1) begin //slot update
            if (j!=10 & j!=11) begin //skip subframe 5 
                ns_tb=j;
                //if (j%2==0)
                   //n='d0; //new subframe each even slot--> reset n counter
                for (k=5; k<7; k=k+1) begin //update l
                    l_tb=k;
                    //all variables ready--> calculate cinit
                    cinit_tb={(7*(ns_tb+1)+l_tb+1)*(2*N_cell_ID_tb+1)*1024}+ 2* N_cell_ID_tb+1;
                    x2=cinit_tb;
                    /* 1st time after reset takes 8 clks after cinit_run. After the 1st frame, the new cinit is ready after just 7 clks--> why? 
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
                    else if (new_subframe_tb==1) begin
                        @(negedge clk);
                        new_subframe_tb=1'b0; 
                        repeat (9-1) @(negedge clk);
                    end
                    else begin
                       /*repeat (2)*/ @(negedge clk);
                    end
                    
                    
                    //shifting 
                    for (m=0; m<NUM_SHIFTS+4; m =m+1) begin //get expected nrs value
                        x1={(x1[0]^x1[3]),x1[30:1]};
                        x2={(x2[3]^x2[2]^x2[1]^x2[0]), x2[30:1]};
                        @(negedge clk); //to see change of each shift
                        if (m>=NUM_SHIFTS) begin //evaluate
                            c_n_expec=x1[29]^x2[29]; //this value is ready at x[30] when m=NUM_SHIFTS-1 , but c_n mem will be ready after 2 clk (at m= NUM+1)
                            nrs_mapper_reg[x] = (c_n_expec==0)? 'b00000_1011010_1000: 'b11111_0100101_1000;
                            x=x+1;
                            //n=n+1;
                        end //evaluation
                    end //m .. shift and evalute
                end //k
                @(negedge clk);
                if (j%2==1) begin
                    //now all 8 pilots of the subframe are ready and can be read by mapper
                
                    for (y=0; y<16; y=y+4) begin
                        rd_addr_mapper_1r_tb=y;
                        rd_addr_mapper_1i_tb=y+1;
                        rd_addr_mapper_2r_tb=y+2;
                        rd_addr_mapper_2i_tb=y+3;
                        @(negedge clk);

                        //check
                        if (nrs_mapper_reg[y]   != nrs_mapper_1r_dut) begin
                            $display("ERROR: pilot 1 real part wrong at OFDM symbol= %0d and subframe = %0d, N_cell_ID= %0d", y/4, j/2, i);
                            $stop;
                        end

                        if (nrs_mapper_reg[y+1] != nrs_mapper_1i_dut) begin
                            $display("ERROR: pilot 1 imag part wrong at OFDM symbol= %0d and subframe = %0d, N_cell_ID= %0d", y/4, j/2, i);
                            $stop;
                        end

                        if (nrs_mapper_reg[y+2] != nrs_mapper_2r_dut) begin
                            $display("ERROR: pilot 2 real part wrong at OFDM symbol= %0d and subframe = %0d, N_cell_ID= %0d", y/4, j/2, i);
                            $stop;
                        end

                        if (nrs_mapper_reg[y+3] != nrs_mapper_2i_dut) begin
                            $display("ERROR: pilot 2 imag part wrong at OFDM symbol= %0d and subframe = %0d, N_cell_ID= %0d", y/4, j/2, i);
                            $stop;
                        end
                    end
                
                    repeat (5) @(negedge clk); 
                    if (j!=19) new_subframe_tb=1'b1;
                end //check
            end //slot != 10 nor 11 cond
        end //j
    end //i
    @(negedge clk);
    $stop;
end //initial
endmodule



