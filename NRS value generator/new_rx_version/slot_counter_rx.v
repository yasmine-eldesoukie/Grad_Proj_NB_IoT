module slot_counter_rx (
	input clk, rst, cinit_run,
	output reg last_run, first_run,
	output reg [4:0] slot
);

reg [5:0] runs_counter;

// /*
always @(posedge clk or negedge rst) begin
	if (!rst) begin
 		runs_counter<='d63;
	end
	else if (cinit_run & runs_counter==(4*10-1)) begin 
		runs_counter<='d0; //reset 
	end
	else if (cinit_run & runs_counter==4*5-1) begin
		runs_counter<=runs_counter+5;
	end
	else if (cinit_run) begin
		runs_counter<=runs_counter+1;
	end
end

always @(*) begin
	last_run= (runs_counter==4*10-1); 
	first_run= (runs_counter=='d0);
	slot= (runs_counter/2);
end

endmodule