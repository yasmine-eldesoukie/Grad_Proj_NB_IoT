/*
N_cell_ID is 9 bits and can take values from 0 to 504 so :
powers of 2 --> value --> mod 6 
0_0000_0001 --> 1     --> 1
0_0000_0010 --> 2     --> 2
0_0000_0100 --> 4     --> 4
0_0000_1000 --> 8     --> 2
0_0001_0000 --> 16    --> 4
0_0010_0000 --> 32    --> 2
0_0100_0000 --> 64    --> 4
0_1000_0000 --> 128   --> 2
1_0000_0000 --> 256   --> 4

x= n[0] + 2(n[1] + n[3] + n[5] + n[7]) + 4(n[2] + n[4] + n[6] + n[8]) , where n is N_cell_ID
N_cell_ID that gives max x is 1_1111_0111 --> 503
x max is 23 --> 5 bits

*/
module nrs_index_gen (
 	input wire [8:0] N_cell_ID,
 	input wire [1:0] est_rd_addr,
 	output reg [3:0] index_demap, /*id_1, id_2, id_3, id_4,*/
 	output reg [2:0] v_shift
);

//N_cell_ID mod 6
always @(*) begin
	x= N_cell_ID[0] + 2(N_cell_ID[1] + N_cell_ID[3] + N_cell_ID[5] + N_cell_ID[7]) + 4(N_cell_ID[2] + N_cell_ID[4] + N_cell_ID[6] + N_cell_ID[8]);
	if (x<6) 
	  v_shift= x;
	else if (x<12) 
	  v_shift= x-6;
	else if (x<18) 
	  v_shift= x-12;
	else // x<24
	  v_shift= x-18; 
end

always @(*) begin
	id_1= v_shift; //pilot 1 slot 1 
	id_2= id_1+3;  //pilot 1 slot 2
	id_3= id_2+3;  //pilot 2 slot 1
	if (v_shift>2) begin
		id_4= v_shift-3; 
	end
	else begin
		id_4= id_3+3;
	end
end

always @(*) begin
    case (est_rd_addr)
        'd0: index_demap= id_1; 
        'd1: index_demap= id_3; //channel estimation processes pilot 2 slot 1 then pilot 1 slot 2
        'd2: index_demap= id_2; 
        'd3: index_demap= id_4; 
    endcase
end

endmodule