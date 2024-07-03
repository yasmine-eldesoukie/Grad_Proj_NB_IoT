//how do we know that a new frame has arrived ? to make sure that the N_cell_ID value we use for the new cinit calculations is correct
//in this design , an input of a signal to indicate a new frame is assumed
module NRS_control_unit_rx 
#(parameter
  WIDTH_REG=16,
  LINES= $clog2(WIDTH_REG),
  NUM_SHIFTS=1600-31+1, // ((1600/31)-1)*31 + 1= shift clks , add 4 to that for evaluation clks
  //states
  IDLE= 3'b000, 
  FIRE_CINIT= 3'b001, 
  SEED= 3'b011,   
  SHIFT= 3'b010,  
  EVALUATE= 3'b110 
)
(
	input wire clk, rst,
	input wire cinit_valid, 
	input wire new_frame, new_subframe,
	input wire last_run, first_run,
	input wire est_ack,
	output reg shift_x, out, wr_en, init_x1, init_x2, cinit_run, //cinit_run is a signal to enable cinit_generator
	output reg [LINES-1:0] wr_addr,
	output reg NRS_gen_ready
); 

reg [$clog2(1600)-1:0] counter_shifts;
reg en_shift_counter, shift_done, evaluate_done, stop_cinit_run, subframe_done;
reg [2:0] cs, ns;

//current state logic
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		cs<=IDLE;
	end
	else begin
		cs<=ns;
	end
end

//next state logic
always @(*) begin
	case (cs) 
	    IDLE: begin
	    	if (new_frame | new_subframe) begin
	    		ns = FIRE_CINIT;
	    	end
	    	else begin
	    		ns= IDLE;
	    	end
	    end

	    FIRE_CINIT: begin
	    	if (cinit_valid) begin
	    		ns= SEED;
	    	end
	    	else begin
	    		ns= FIRE_CINIT;
	    	end
	    end

	    SEED: begin
	    	ns= SHIFT;
	    end

	    SHIFT: begin
	    	if (shift_done) begin
	    		ns= EVALUATE;
	    	end
	    	else begin
	    		ns= SHIFT;
	    	end
	    end

	    EVALUATE: begin
	    	if (evaluate_done & subframe_done) begin
	    		ns= IDLE;
	    	end
	    	else if (evaluate_done) begin
	    		ns= SEED;
	    	end
	    	else begin
	    		ns = EVALUATE;
	    	end
	    end   

	    default: begin
	    	ns= IDLE;
	    end     
	endcase
end

///////////////////////------------ output stage ------------///////////////////////
always @(*) begin
    init_x2= (cs==SEED); 
	init_x1= (cs==SEED & first_run);
	shift_x= (cs==SHIFT | cs==EVALUATE);
    out= (cs==EVALUATE);
    wr_en= (cs==EVALUATE);
end

//------------ sequntial output stage ------------

/* cinit_run :  enables cinit_generator
      1) in the FIRE_CINIT state, after reset once a new frame is detected
      2) in the SEED state, after the 1st value of the 1st subframe and until the frame ends. 
*/
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		cinit_run<=1'b0;
		stop_cinit_run<=1'b0;
	end
	else if (!stop_cinit_run & cs==FIRE_CINIT) begin //ns==FIRE_CINIT can save 1 clk
		cinit_run<=1'b1;
		stop_cinit_run<=1'b1;
	end
	else if (cs==SEED & !last_run) begin
		cinit_run<=1'b1;
		stop_cinit_run<=1'b0;
	end
	else begin
		cinit_run<=1'b0;
	end
end

//wr_addr : during EVALUATION, incremented each clk
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		wr_addr<='b0;
	end
	else if (wr_en) begin
		wr_addr<=wr_addr+1;
	end
end

////////////////////////////// internal control signals and counters //////////////////////////////
always @(*) begin
	en_shift_counter= (cs==SHIFT | cs==EVALUATE);
	shift_done= (counter_shifts == NUM_SHIFTS-1);
	evaluate_done= (counter_shifts == NUM_SHIFTS-1+4);
end

//shifts counter
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		counter_shifts<='b0;
	end
	else if (en_shift_counter) begin //on for NUM_shifts shift then 4 for evaluation
		counter_shifts<=counter_shifts+1;
	end
	else begin
		counter_shifts<='b0;
	end
end

//frame done
always @(posedge clk or negedge rst) begin
	if (!rst) begin
        subframe_done<= 1'b0;
	end
	else if (cs==SEED & last_run) begin
	    subframe_done<=1'b1;
	end
	else if (cs==IDLE) begin
	    subframe_done<=1'b0;
	end
end

//NRS_gen_ready 
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        NRS_gen_ready<=1'b0;
    end
    else if (est_ack) begin
    	NRS_gen_ready<=1'b0;
    end
    else if (cs==EVALUATE) begin
        NRS_gen_ready<= 1'b1;
    end
end

endmodule


