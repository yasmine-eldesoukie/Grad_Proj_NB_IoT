module mux_add2_a #(parameter IN_WIDTH= 17, OUT_WIDTH= 19)
(
	input wire [2:0] sel,
	input wire signed [IN_WIDTH-1:0] E1, E2, E3, E4,
	input wire signed [IN_WIDTH-1:0] reg_E, //it will be connected actually with reg_2E (reg sharing) just named that way for simplicity
	output reg signed [OUT_WIDTH-1:0] add2_a //max output is 4E
);

always @(*) begin
	case (sel)
        'b000:  add2_a= {E1, 1'b0}; //2E1
        'b001:  add2_a= E1;
        'b011:  add2_a= {E2, 1'b0}; //2E2
        'b010:  add2_a= {E4, 2'b0}; //4E4
        'b110:  add2_a= !E3;
        'b100:  add2_a= reg_E;
        default: add2_a='b0;
    endcase
end

endmodule