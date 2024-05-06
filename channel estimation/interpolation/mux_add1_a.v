module mux_add1_a #(parameter IN_WIDTH= 17, OUT_WIDTH= 19)
(
	input wire [2:0] sel,
	input wire signed [IN_WIDTH-1:0] E2, E3,
	input wire signed [IN_WIDTH:0] reg_2E,
    input wire signed [OUT_WIDTH-1:0] reg_5E, 
	output reg signed [OUT_WIDTH-1:0] add1_a
);

always @(*) begin
	case (sel)
        'b000:  add1_a= !E2;
        'b001:  add1_a= !{E2, 1'b0}; //! (2E2) 
        'b011:  add1_a= E2;
        'b010:  add1_a= reg_2E; //-2E2
        'b110:  add1_a= {E3, 1'b0}; // (2E3) 
        'b100:  add1_a= !{E3, 1'b0};
        'b101:  add1_a= reg_5E; //5E1
        default: add1_a='b0;
    endcase
end

endmodule