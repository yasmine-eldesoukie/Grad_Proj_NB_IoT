module signed_cmplx_mult_tb #(parameter 
    WIDTH_R_I=16
 );
 //signal declaration
 reg clk, rst, en_tb;
 reg [1:0] wr_addr_tb, rd_addr_tb;
 reg signed [WIDTH_R_I-1:0] rx_r_tb, rx_i_tb;
 reg nrs_r_tb, nrs_i_tb;
 wire signed [WIDTH_R_I :0] real_part_dut, imag_part_dut; 

 reg signed [27:0] real_part_expec, imag_part_expec;

 //internal signals
 reg [WIDTH_R_I-1:0] nrs_r_value, nrs_i_value;
 //instantiation
 signed_modified_complx_mult dut (
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
 integer i;
 initial begin
    rst=1'b0;
    repeat (30) @(negedge clk);
    rst=1'b1;
    en_tb=1'b1;

    rx_r_tb= 'b1111_1111_1111_1111;
    rx_i_tb= 'b1111_1111_1111_1111;
    for (i=0; i<4; i=i+1) begin
        {nrs_r_tb,nrs_i_tb}=i;
        nrs_r_value= (nrs_r_tb)? 16'b11111_0100101_1000: 16'b00000_1011010_1000;
        nrs_i_value= (nrs_i_tb)? 16'b11111_0100101_1000: 16'b00000_1011010_1000;

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

    @(negedge clk);
    $stop;
 end
endmodule
 


 
