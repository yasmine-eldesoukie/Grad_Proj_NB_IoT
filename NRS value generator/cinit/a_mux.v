module a_mux #(parameter WIDTH=18)(
	input wire [1:0] s4,
	input wire [WIDTH-1:0] adder_out,
	input wire [8:0] N_cell_ID,
	input wire [4:0] ns,
	output reg [WIDTH-1:0] out_a
);
always @(*) begin
	 case (s4)
        'b00:  out_a=ns; 
        'b01:  out_a=adder_out;
        'b11:  out_a={N_cell_ID,1'b0};
        default: out_a='b0;
    endcase
end
endmodule