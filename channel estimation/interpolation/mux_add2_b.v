module mux_add2_b #(parameter IN_WIDTH= 17, OUT_WIDTH= 19)
(
	input wire [2:0] sel,
	input wire signed [IN_WIDTH-1:0] E1, E3, E4,
    input wire signed [IN_WIDTH-1:0] reg_E,
	output reg signed [OUT_WIDTH-1:0] add2_b
);

always @(*) begin
    case (sel)
        'b000:  add2_b= E3;
        'b001:  add2_b= E3<<1; //(2E3) witten this way instead of {E3, 1'b0} for sign extension--> to work with -ve numbers 
        'b011:  add2_b= E4;
        'b010:  add2_b= reg_E;
        'b110:  add2_b= 'b1;
        'b100:  add2_b= E1<<2; //(4E1) 
        default: add2_b='b0;
    endcase
end

endmodule