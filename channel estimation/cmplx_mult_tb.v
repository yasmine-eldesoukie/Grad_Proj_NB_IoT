module cmplx_mult_tb #(parameter 
    WIDTH_R_I=16
 );
 //signal declaration
 reg clk, rst, en_tb;
 reg [1:0] wr_addr_tb, rd_addr_tb;
 reg [WIDTH_R_I-1:0] rx_r_tb, rx_i_tb;
 reg nrs_r_tb, nrs_i_tb;
 wire [WIDTH_R_I-1 :0] real_part_dut, imag_part_dut; 

 reg [2*WIDTH_R_I :0] real_part_expec, imag_part_expec;

 //internal signals
 reg [WIDTH_R_I-1:0] nrs_r_value, nrs_i_value;
 //instantiation
 modified_complx_mult dut (
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
 integer i,j,k;
 initial begin
    rst=1'b0;
    repeat (30) @(negedge clk);
    rst=1'b1;
    en_tb=1'b1;

    //test for +ve values of rx_r and rx_i
    repeat (2) begin
        nrs_r_tb='b0;
        nrs_i_tb='b0;
        nrs_r_value= 16'b00000_1011010_1000;
        nrs_i_value= 16'b00000_1011010_1000;
        for (i=0; i<32767; i=i+1) begin
            rx_r_tb=i;
            for (j=0; j<32767; j=j+1) begin
                rx_i_tb=j;
                for (k=0; k<4; k=k+1) begin
                    wr_addr_tb=k;
                    @(negedge clk);
                    rd_addr_tb=k;
                    real_part_expec=(!en_tb)? 'b0: (rx_r_tb* nrs_r_value)+(rx_i_tb* nrs_i_value); 
                    imag_part_expec=(!en_tb)? 'b0: (rx_i_tb* nrs_r_value)+(~(rx_r_tb* nrs_i_value)+1'd1);

                    @(negedge clk);
                    if (real_part_expec!=real_part_dut) begin
                        $display("ERROR: real_part wrong at rx_r= %0d, rx_i= %0d", i,j);
                        $stop;
                    end
                    if (imag_part_expec!=imag_part_dut) begin
                        $display("ERROR: imag_part wrong at rx_r= %0d, rx_i= %0d", i,j);
                        $stop;
                    end
                end//for k
            end//for j
        end//for i
        en_tb=1'b0; 
    end
    $stop;
 end 
 endmodule

