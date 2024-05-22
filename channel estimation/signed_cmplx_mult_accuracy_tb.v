module signed_cmplx_mult_tb #(parameter 
    WIDTH_R_I=16,
    LONG_WIDTH= 28,
    MEM_ELEMENTS= ((32768/32)+1)**2
 );
 //signal declaration
 reg clk, rst, en_tb;
 reg [1:0] wr_addr_tb, rd_addr_tb;
 reg signed [WIDTH_R_I-1:0] rx_r_tb, rx_i_tb;
 reg signed [WIDTH_R_I-1:0] rx_r_signed_tb, rx_i_signed_tb;

 reg nrs_r_tb, nrs_i_tb;
 wire signed [WIDTH_R_I :0] real_part_reg_dut, imag_part_reg_dut; 
 wire signed [WIDTH_R_I :0] real_part_dut, imag_part_dut; 

 reg  signed [WIDTH_R_I:0] real_part_reg_expec, imag_part_reg_expec;

 //reg  signed [LONG_WIDTH-1:0] real_part_expec, real_part_reg_expec;

 //internal signals
 //reg [15:0] nrs_r_value, nrs_i_value, nrs_i_value_neg; 
 //reg signed [26:0] x,y;
 //reg signed [11:0] nrs_r_signed_value, nrs_i_signed_value, nrs_i_value_signed_neg;
 
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
    .imag_part(imag_part_dut),
    .real_part_reg(real_part_reg_dut), 
    .imag_part_reg(imag_part_reg_dut)
 );

 //txt file smemories
 reg [WIDTH_R_I:0] real_mem [MEM_ELEMENTS-1:0];
 reg [WIDTH_R_I:0] imag_mem [MEM_ELEMENTS-1:0];


 //clk generation 
 initial begin
    clk=1'b0;
    forever #1 clk=~clk;
 end

 //stimulus generation
 integer i,j,m,g,f;
 initial begin
    rst=1'b0;
    repeat (30) @(negedge clk);
    rst=1'b1;
    en_tb=1'b1;

    $readmemb("h_r_bin.txt", real_mem);
    $readmemb("h_i_bin.txt", imag_mem);

    {nrs_r_tb,nrs_i_tb}=0;
    //nrs_r_value= (nrs_r_tb)? 'b11111_0100101_1000: 'b00000_1011010_1000;
    //nrs_i_value= (nrs_i_tb)? 'b11111_0100101_1000: 'b00000_1011010_1000;
    m=0;
    g=0;
    f=0;
    for (i=0; i<=32768; i=i+32) begin
        rx_r_tb= (i==32768)? i-1: i;
        for (j=0; j<=32768; j=j+32) begin
            rx_i_tb= (j==32768)? j-1: j;

            
            @(posedge clk);
            wr_addr_tb=m;
            repeat (2) @(negedge clk);
            rd_addr_tb=m;
            //@(negedge clk);

            real_part_reg_expec=real_mem[m];
            imag_part_reg_expec=imag_mem[m];

            if (real_part_reg_dut!=real_part_reg_expec) begin
               $display("ERROR: real_part at rx_r=%0d and rx_i=%0d, dut=%d and matlab=%d", i,j,real_part_reg_dut, real_part_reg_expec );
               g=g+1;
               //$stop;
            end
            if (imag_part_reg_dut!=imag_part_reg_expec) begin
               $display("ERROR: imag_part at rx_r=%0d and rx_i=%0d, dut=%d and matlab=%d", i,j, imag_part_reg_dut, imag_part_reg_expec);
               f=f+1;
               //$stop;
            end
            //@(negedge clk);
            m=m+1;
        end
    end

    @(negedge clk);
    $stop;
 end
endmodule
 


 /*
x*pos + y*neg
y*pos - x*neg = y*pos + x*pos

x*neg + y*pos
y*neg - x*pos = y*neg + x*neg

x*neg + y*neg
y*neg - x*neg
 */
