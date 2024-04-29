module mux_h2 #(parameter WIDTH= 16)
(
	input wire [1:0] sel,
	input wire [WIDTH-1:0] est3, est4, 
	input wire [WIDTH-1:0] div_res_1, div_res_2,
	output reg [WIDTH-1:0] h_eqlz_2
);

always @(*) begin
	case (sel)
        'b00:  h_eqlz_2= div_res_2;
        'b01:  h_eqlz_2= est3;
        'b11:  h_eqlz_2= est4;
        'b10:  h_eqlz_2= div_res_1;
        default: h_eqlz_2='b0;
    endcase
end

endmodule