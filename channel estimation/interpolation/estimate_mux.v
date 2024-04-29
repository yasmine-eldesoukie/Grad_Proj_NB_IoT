module estimate_mux #(parameter WIDTH=16)(
	input wire [WIDTH-1:0] E1, E2, E3, E4, 
	input wire sel,
	output reg [WIDTH-1:0] est1, est2, est3, est4
);

always @(*) begin
	 case (sel) 
	     'b0: begin
	     	est1=E1;
	     	est2=E2;
	     	est3=E3;
	     	est4=E4; 
	     end
	     'b1: begin
	     	est1=E3;
	     	est2=E4;
	     	est3=E1;
	     	est4=E2; 
	     end
	 endcase
end
endmodule