module signed_cmplx_mult_tb #(parameter 
    WIDTH_R_I=16,
    LONG_WIDTH= 28,
    MEM_ELEMENTS= (32768/64)**2
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
 reg  signed [LONG_WIDTH-1:0] real_long_expec, imag_long_expec;

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
 reg [LONG_WIDTH-1:0] real_long_mem [MEM_ELEMENTS:0];
 reg [LONG_WIDTH-1:0] imag_long_mem [MEM_ELEMENTS:0];
 reg [WIDTH_R_I:0] real_mem [MEM_ELEMENTS-1:0];
 reg [WIDTH_R_I:0] imag_mem [MEM_ELEMENTS-1:0];


 //clk generation 
 initial begin
    clk=1'b0;
    forever #1 clk=~clk;
 end

 //stimulus generation
 integer i,j,m;
 initial begin
    rst=1'b0;
    repeat (30) @(negedge clk);
    rst=1'b1;
    en_tb=1'b1;

    $readmemb("real_long_bin.txt", real_long_mem);
    $readmemb("real_bin.txt", real_mem);
    $readmemb("imag_long_bin.txt", imag_long_mem);
    $readmemb("imag_bin.txt", imag_mem);

    {nrs_r_tb,nrs_i_tb}=0;
    //nrs_r_value= (nrs_r_tb)? 'b11111_0100101_1000: 'b00000_1011010_1000;
    //nrs_i_value= (nrs_i_tb)? 'b11111_0100101_1000: 'b00000_1011010_1000;
    m=0;
    for (i=0; i<32767; i=i+64) begin
        rx_r_tb= i;
        for (j=0; j<32767; j=j+64) begin
            rx_i_tb= j;
            
            @(posedge clk);
            wr_addr_tb=i;
            repeat (2) @(negedge clk);
            rd_addr_tb=i;
            @(negedge clk);

            real_long_expec=real_long_mem[m];
            imag_long_expec=imag_long_mem[m];

            real_part_reg_expec=real_mem[m];
            imag_part_reg_expec=imag_mem[m];


            if (dut.real_long!=real_long_expec) begin
               $display("ERROR: real_long at rx_r=%0d and rx_i=%0d", i,j);
               $stop;
            end
            if (dut.imag_long!=imag_long_expec) begin
               $display("ERROR: imag_long at rx_r=%0d and rx_i=%0d", i,j);
               $stop;
            end
            if (real_part_reg_dut!=real_part_reg_expec) begin
               $display("ERROR: real_part at rx_r=%0d and rx_i=%0d", i,j);
               $stop;
            end
            if (imag_part_reg_dut!=imag_part_reg_expec) begin
               $display("ERROR: imag_part at rx_r=%0d and rx_i=%0d", i,j);
               $stop;
            end
            @(negedge clk);
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
