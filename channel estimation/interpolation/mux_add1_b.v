module mux_add1_b #(parameter WIDTH= 17)
(
	input wire [2:0] sel,
	input wire [WIDTH-1:0] E1, E3, E4, 
    input wire [WIDTH:0] reg_2E,
	input wire [WIDTH+3-1:0] reg_5E, //E max could be + or - (16) --> 5E could be 80 
	output reg [WIDTH+3-1:0] add1_b
);

always @(*) begin
	case (sel)
        'b000:  add1_b= 'b1;
        'b001:  add1_b= {E3, 1'b0}; //(2E3)
        'b011:  add1_b= {E4, 1'b0}; //(2E4)
        'b010:  add1_b= reg_5E;
        'b110:  add1_b= E1;
        'b100:  add1_b= reg_2E; //-2E3
        default: add1_b='b0;
    endcase
end

endmodule