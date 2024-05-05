module mux_h1 #(parameter WIDTH= 17)
(
	input wire [1:0] sel,
	input wire [WIDTH-1:0] est1, est2, 
	input wire [WIDTH-1:0] div_res_1, div_res_2,
	output reg [WIDTH-1:0] h_eqlz_1
);

always @(*) begin
	case (sel)
        'b00:  h_eqlz_1= est1;
        'b01:  h_eqlz_1= div_res_2;
        'b11:  h_eqlz_1= div_res_1;
        'b10:  h_eqlz_1= est2;
        default: h_eqlz_1='b0;
    endcase
end

endmodule