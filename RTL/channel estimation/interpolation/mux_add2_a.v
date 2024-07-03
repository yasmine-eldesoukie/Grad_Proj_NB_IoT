module mux_add2_a #(parameter IN_WIDTH= 17, OUT_WIDTH= 19)
(
	input wire [2:0] sel,
    input wire [1:0] shift,
	input wire signed [IN_WIDTH-1:0] E1, E2, E3, E4,
	input wire signed [IN_WIDTH:0] reg_E, //it will be connected actually with reg_2E (reg sharing) just named that way for simplicity
	output reg signed [OUT_WIDTH-1:0] add2_a //max output is 4E
);

always @(*) begin
	case (sel)
        'b000:  add2_a= E1<<1; //2E1 witten this way instead of {E3, 1'b0} for sign extension--> to work with -ve numbers
        'b001:  add2_a= E1;
        'b011:  add2_a= E2<<1; //2E2
        'b010:  add2_a= E4<<2; //4E4
        'b110:  add2_a= ~E3;
        'b100:  
            begin
               if (shift=='d1) begin
                   add2_a= reg_E;
               end
               else begin
                   add2_a= { reg_E[IN_WIDTH], reg_E[IN_WIDTH],  reg_E[IN_WIDTH:1] }; // reg_E/2
               end
            end 
        default: add2_a='b0;
    endcase
end

endmodule