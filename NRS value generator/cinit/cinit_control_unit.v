/*------ l=5 then l=6 , ns --> [0:19] , N_cell_ID : upper layer parameter------
  cinit   = 2^10[7(ns+1)+l+1][2N_cell_ID+1] + 2N_cell_ID + 1 
  for l=5 : 2^10[2(7ns+ 13)(N_cell_ID)+(7ns+ 13)] + 2N_cell_ID + 1 
  for l=6 : 2^10[2(7ns+ 13 +1)(N_cell_ID)+(7ns+ 13 +1)] + 2N_cell_ID + 1     
*/

module cinit_control_unit 
#(parameter
	IDLE=         3'b000,
	A_NS_2NS=     3'b001,  //Add ns + 2ns --> 3ns
	A_A_4NS=      3'b011,  //Add Adder result + 4ns --> 7ns
	A_A_13=       3'b010,  //Add Adder result + 13 --> 7ns+ 13 
	A_A_1=        3'b110,  //Add Adder result + 1 --> 7ns+14 , for the "l=6" case
	M_A_N=        3'b100,  //Multiply Adder result * N_cell_ID --> (7ns+ 13)(N_cell_ID) or (7ns+ 13 +1)(N_cell_ID)
	A_A_2M_STORE= 3'b101,  //Add Adder result (7ns+13) + 2 Multiplier result --> 2(7ns+ 13)(N_cell_ID)+(7ns+ 13) and Store it in adder_register
	A_2N_1=       3'b111   //Add 2N_cell_ID +1 and turn on the valid signal
)
(   
input wire clk, rst,
input wire run, //control signal from the NRS_value_gen control unit 
output reg [1:0] s4, 
output reg [2:0] s5,
output reg en_add, en_mult, en_add_reg,
output reg valid 
);

reg l_five;
reg [2:0] cs,ns;

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		cs<=IDLE;
	end
	else begin
		cs<=ns;
	end
end

//next state logic and combinational output stages (Moore FSM) ; output depends on state only.
always @(*) begin
    //default values
    s4= 2'b00;
    s5= 3'b000;
    en_add=1'b1;
    en_mult=1'b0;
	case (cs) 
	IDLE: begin
	    en_add=1'b0;
		if (run) begin
			ns=A_NS_2NS;
		end
		else begin
			ns=IDLE;
		end
	end

	A_NS_2NS: begin
		ns=A_A_4NS;
		s4=2'b00;
        s5=3'b000;
	end

	A_A_4NS: begin
		ns=A_A_13;
		s4=2'b01;
        s5=3'b001;
	end

	A_A_13:begin
	    s4=2'b01;
        s5=3'b011;
		if (l_five==1) begin //l=5
			ns=M_A_N;
		end
		else begin
			ns=A_A_1;
		end
	end

	A_A_1: begin
		ns=M_A_N;
		s4= 2'b01;
        s5= 3'b110;
	end

	M_A_N: begin
	    en_add=1'b0;
	    en_mult=1'b1;
		ns=A_A_2M_STORE;
		//they are irrelevant here, but set to their next (A_A_2M_STORE case) values
		s4= 2'b01;
        s5= 3'b010;
	end

	A_A_2M_STORE: begin
		ns=A_2N_1;
		s4= 2'b01;
        s5= 3'b010;
	end

    A_2N_1: begin
        s4= 2'b11;
        s5= 3'b110;
        if (run) begin
        	ns=A_NS_2NS;
        end
        else begin
        	ns=A_2N_1;
        end
    end
    default: begin
    	ns=IDLE;
    end
    endcase
end


//output stage 
always @(*) begin
	valid= (l_five & cs==A_2N_1); //only cs==A_2N_1 is needed but l_five is added to prevent valid to be on for the last run of the subframe, as this gets NRS out of FIRE_CINIT state incorrectly
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		en_add_reg<=1'b0;
	end
	else if (cs==A_A_2M_STORE) begin
		en_add_reg<=1'b1;
	end
	else begin
		en_add_reg<=1'b0;
	end
end

//sequential internal control dignals
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		l_five<=1'b0;
	end
	else if (run) begin
		l_five<= !l_five;
	end
end

endmodule
