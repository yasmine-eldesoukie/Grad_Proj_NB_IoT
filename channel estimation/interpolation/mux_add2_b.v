module mux_add2_b #(parameter WIDTH= 17)
(
	input wire [2:0] sel,
	input wire [WIDTH-1:0] E1, E3, E4,
    input wire [WIDTH-1:0] reg_E,
	output reg [WIDTH+2-1:0] add2_b
);

always @(*) begin
    case (sel)
        'b000:  add2_b= E3;
        'b001:  add2_b= {E3, 1'b0}; //(2E3) 
        'b011:  add2_b= E4;
        'b010:  add2_b= reg_E;
        'b110:  add2_b= 'b1;
        'b100:  add2_b= {E1, 2'b0}; //(4E1) 
        default: add2_b='b0;
    endcase
end

endmodule