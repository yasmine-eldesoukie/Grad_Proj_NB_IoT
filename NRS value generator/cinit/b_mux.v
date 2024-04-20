module b_mux #(parameter WIDTH=18)(
	input wire [2:0] s5,
	input wire [16:0] mult_out,
	input wire [4:0] ns,
	output reg [WIDTH-1:0] b_out
);
always @(*) begin
	 case (s5)
        'b000:  b_out={ns,1'b0}; //2ns
        'b001:  b_out={ns,2'b0}; //4ns 
        'b011:  b_out='d13;
        'b010:  b_out={mult_out,1'b0}; //2 mult_out
        'b110:  b_out='d1;
        default: b_out='d0;
    endcase

end
endmodule