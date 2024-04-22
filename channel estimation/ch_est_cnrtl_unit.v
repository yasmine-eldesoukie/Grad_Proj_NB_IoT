module ch_est_cntrl_unit #( parameter 
 	NRS_ADDR=4,
 	OUT_SEL_SEQ_LENGTH= 12
)
(
 	input wire clk, rst, 
 	input wire demap_ready, NRS_gen_ready,
 	input wire [2:0] v_shift,

    //outside --> to other blocks
 	output reg [3:0] col,
 	output reg [1:0] nrs_index_addr, 
 	output reg demap_read,
 	//output reg [3:0] row, //it's calculated at nrs_index gen

 	output reg [NRS_ADDR-1:0] rd_addr_nrs,
 	output reg valid_eqlz,

 	//within channel est. block
 	output reg [1:0] addr_mem, //for wr_addr_mult_mem, wr_addr_avg_mem and rd_addr_mult_mem
 	output reg mult_mem_en, avg_mem_en, 
 	
 	//----- interpolation -----
 	output reg en_reg_E, en_reg_2E, en_reg_5E,
 	output reg [2:0] s1a, s1b, s2a, s2b, //adders muxes select signals
 	output reg [1:0] s_h1, s_h2, //out muxes select signals  
 	output reg s_est //there are 4 estimate muxes but their select signal is the same 
);

localparam 
    //FSM states
    IDLE=2'b00,
    MULT_STORE=2'b01,
    MULT_ADD=2'b11,
    //interpolation FSM adder1 
    A1_IDLE   =4'b0000,
    A1_E2     =4'b0010, //calculate neg 2nd Estimate

    A1_2E2    =4'b0011,
    A1_E2_2E3 =4'b0001,
    A1_E2_2E4 =4'b0100,
    A1_2E2_5E4=4'b0101,

    A1_2E3_E1 =4'b1000,

    A1_2E3    =4'b1100,
    A1_5E1_2E3=4'b1110,
    
    //interpolation FSM adder2 
    A2_IDLE   =4'b0000,
    A2_2E1_E3 =4'b0001,
    A2_E1_2E3 =4'b0011,
    A2_2E2_E3 =4'b0010,
    A2_2E2_E4 =4'b0100,
    A2_4E4_E4 =4'b0101,
    A2_4E4_E2 =4'b0111,

    A2_E3     =4'b1000,
    A2_4E1_E3 =4'b1010,
    A2_5E1    =4'b1011;

// internal signals
 reg [1:0] cs, ns;
 reg [3:0] cs_A1, cs_A2, ns_A1, ns_A2;

 reg [1:0] counter4;
 reg counter4_done;
 reg go_1, go_2, first_slot;
 reg E1_ready, E2_ready, E3_ready;
 reg [1:0] shift;
 reg load_sel;
 reg [OUT_SEL_SEQ_LENGTH-1:0] s_h1_reg, s_h2_reg;
 reg [1:0] col_addr;

// ==============================================================================
// ============================ current state logic =============================
// ==============================================================================

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        cs<=IDLE;
        cs_A1<=A1_IDLE;
        cs_A2<=A2_IDLE;
    end
    else begin
        cs<=ns;
        cs_A1<=ns_A1;
        cs_A2<=ns_A2;
    end
end

// ==============================================================================
// ============================== next state logic ==============================
// ==============================================================================

//multiplier next state logic
always @(*) begin
    case (cs) 
        IDLE: begin
            if (demap_ready & NRS_gen_ready & first_slot) begin
                ns= MULT_STORE;
            end
            else if (demap_ready & NRS_gen_ready & !first_slot) begin
                ns= MULT_ADD;
            end
            else begin
                ns= IDLE;
            end
        end

        MULT_STORE: begin
            if (counter4_done) begin
                ns=IDLE;
            end
            else begin
                ns=MULT_STORE;
            end
        end

        MULT_ADD: begin
            if (counter4_done) begin
                ns=IDLE;
            end
            else begin
                ns=MULT_ADD;
            end
        end

        default: ns=IDLE;
    endcase
end

//interpolation next state logic
always @(*) begin
    case (shift)
        'd0: begin
            case (cs_A1)
                A1_IDLE: begin
                    if (E2_ready) begin
                        ns_A1= A1_E2;
                    end
                    else begin
                        ns_A1= A1_IDLE;
                    end
                end

                A1_E2: begin
                    ns_A1= A1_2E2;
                end

                A1_2E2: begin
                    if (go_1) begin
                        ns=A1_E2_2E3;
                    end
                    else begin
                        ns=A1_2E2;
                    end
                end

                A1_E2_2E3: begin
                    if (go_1) begin
                        ns_A1= A1_E2_2E4;
                    end
                    else begin
                        ns_A1= A1_E2_2E3;
                    end
                    
                end

                A1_E2_2E4: begin
                    ns_A1= A1_2E2_5E4;
                end

                A1_2E2_5E4: begin
                    ns_A1= A1_IDLE;
                end

                default: begin
                    ns_A1= A1_IDLE;
                end
            endcase

            case (cs_A2)
                A2_IDLE: begin
                    if (E3_ready) begin
                        ns_A2= A2_2E1_E3;
                    end
                    else begin
                        ns_A2= A2_IDLE;
                    end
                end

                A2_2E1_E3: ns_A2= A2_E1_2E3;
                A2_E1_2E3: ns_A2= A2_2E2_E3;
                A2_2E2_E3: ns_A2= A2_2E2_E4;
                A2_2E2_E4: ns_A2= A2_4E4_E4;
                A2_4E4_E4: ns_A2= A2_4E4_E2;
                A2_4E4_E2: ns_A2= A2_IDLE;
                default:   ns_A2= A2_IDLE;
            endcase
        end

        'd1: begin
            case (cs_A1) 
                A1_IDLE: if (cs_A2==A2_4E1_E3) begin
                    ns_A1= A1_2E3_E1;
                end
                else begin
                    ns_A1= A1_IDLE;
                end

                A1_2E3_E1: ns_A1= A1_E2_2E3;
                A1_E2_2E3: begin
                    if (go_1) begin
                        ns_A1= A1_E2;
                    end
                    else begin
                        ns_A1= A1_E2_2E3;
                    end
                end
                A1_E2: ns_A1= A1_E2_2E4;
                A1_E2_2E4: begin
                    ns_A1= A1_IDLE;
                end

                default: begin
                    ns_A1= A1_IDLE;
                end
            endcase

            case (cs_A2)
                A2_IDLE: begin
                    if (E3_ready) begin
                        ns_A2= A2_E3;
                    end
                    else begin
                        ns_A2= A2_IDLE;
                    end
                end

                A2_E3: ns_A2= A2_4E1_E3;
                A2_4E1_E3: ns_A2= A2_2E1_E3;
                A2_2E1_E3: begin
                    if (go_2) begin
                        ns_A2= A2_2E2_E3;
                    end
                    else begin
                        ns_A2= A2_2E1_E3;
                    end
                end
                A2_2E2_E3: ns_A2= A2_2E2_E4;
                A2_2E2_E4: begin
                    if (go_2) begin
                        ns_A2= A2_4E4_E2;
                    end
                    else begin
                        ns_A2= A2_2E2_E4;
                    end
                end

                A2_4E4_E2: ns_A2= A2_IDLE;
                default:   ns_A2= A2_IDLE;
            endcase
        end

        'd2: begin
            case (cs_A1)
                A1_IDLE: begin
                    if (E3_ready) begin
                       ns_A1= A1_2E3;
                    end
                    else begin
                        ns_A1= A1_IDLE;
                    end
                end

                A1_2E3: ns_A1= A1_5E1_2E3;
                A1_5E1_2E3: begin
                    if (go_1) begin
                        ns_A1= A1_2E3_E1;
                    end
                    else begin
                        ns_A1= A1_5E1_2E3;
                    end
                end

                A1_2E3_E1: ns_A1= A1_E2_2E3;
                A1_E2_2E3: begin
                    if (go_1) begin
                        ns_A1= A1_E2_2E4;
                    end
                    else begin
                        ns_A1= A1_E2_2E3;
                    end
                end

                A1_E2_2E4: begin
                    ns_A1= A1_IDLE;
                end

                default: begin
                    ns_A1= A1_IDLE;
                end
            endcase

            case (cs_A2)
                A2_IDLE: begin
                    if (E1_ready) begin
                        ns_A2= A2_5E1;
                    end
                    else begin
                        ns_A2= A2_IDLE;
                    end
                end

                A2_5E1: ns_A2= A2_E3;
                A2_4E1_E3: ns_A2= A2_2E1_E3;
                A2_2E1_E3: begin
                    if (go_2) begin
                        ns_A2= A2_2E2_E3;
                    end
                    else begin
                        ns_A2= A2_2E1_E3;
                    end
                end
                A2_2E1_E3: ns_A2= A2_2E2_E4;

                A2_2E2_E4: ns_A2= A2_IDLE;
                default:   ns_A2= A2_IDLE;
            endcase
        end
    endcase
end

// ==============================================================================
// ================================ output stage ================================
// ==============================================================================

//valid signal  
/*
  signal is set with the evaluation-of-1st_h state in each shift case
  signal is back to 0 when last state is reached, last state differes dep. on shift value, but the common condition is after the last state--> IDLE
  from the states: adder2 finishes last excpet for shift =2, adder1 changes last
  conclusion: ns is used 
*/
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        valid_eqlz<=1'b0;
    end
    else if ( (shift== 'd2 & ns_A1==A1_IDLE) | (shift!= 'd2 & ns_A2==A2_IDLE) ) begin 
        valid_eqlz<= 1'b0;
    end
    //(shift=='d0) & (cs_A2==A2_2E1_E3)) | ((shift=='d1) & (cs_A2==A2_4E1_E3)) | ((shift=='d2) & (cs_A2==A2_4E1_E3)) --> detailed condition
    else if ( (shift=='d0 & cs_A2==A2_2E1_E3) | (cs_A2==A2_4E1_E3) ) begin
        valid_eqlz<=1'b1;
    end
end

//FSM dependant 
always @(*) begin
    addr_mem= counter4; //changes with MULT_STORE and MULT_ADD but only needed and considered when MULT_ADD
    demap_read= (cs==MULT_STORE | cs== MULT_ADD);
end

always @(posedge clk or negedge rst) begin
     if (!rst) begin
        mult_mem_en<= 1'b0;
     end
     else if (cs==MULT_STORE) begin
        mult_mem_en<= 1'b1;
     end
     else begin
        mult_mem_en<= 1'b0;
     end
 end 

 always @(posedge clk or negedge rst) begin
     if (!rst) begin
        avg_mem_en<= 1'b0;
     end
     else if (cs==MULT_ADD) begin
        avg_mem_en<= 1'b1;
     end
     else begin
        avg_mem_en<= 1'b0;
     end
 end 
//Adders states dependant
always @(*) begin
    // because it is comb. --> value is calculated in a state and ready at its end, enbale is set with the following state
    en_reg_E=  ( ((shift=='d0) & (cs_A1==A1_2E2))    | ((shift=='d1) & (cs_A1==A1_E2_2E4)) );  //-ve value of an estimate E
    en_reg_2E= ( ((shift=='d0) & (cs_A1==A1_E2_2E3)) | ((shift=='d1) & (cs_A2==A2_4E1_E3)) | ((shift=='d2) & (cs_A1==A1_5E1_2E3)) ); //-ve 2*value of an estimate, execption: when shift=1, -E3 is stored 
    en_reg_5E= ( ((shift=='d0) & (cs_A2==A2_4E4_E2)) | ((shift=='d2) & (cs_A2==A2_4E4_E2)) ); //5*value of an estimate
end

// ----------------------------------------------------
// ---------------  muxes select signals ---------------
// ----------------------------------------------------

//adder1 muxes select signals 
always @(*) begin
    case (cs_A1)
        A1_IDLE: begin
            s1a=  'b111;
            s1b=  'b111;
        end

        A1_E2: begin
            s1a=  'b000; 
            s1b=  'b000;
        end

        A1_2E2: begin
            s1a=  'b001; 
            s1b=  'b000;
        end

        A1_E2_2E3: begin
            s1a=  'b011;
            s1b=  'b001;
        end

        A1_E2_2E4: begin
            s1a=  'b011; 
            s1b=  'b011;
        end

        A1_2E2_5E4: begin
            s1a=  'b010;
            s1b=  'b010;
        end

        A1_2E3_E1: begin
            s1a=  'b110;
            s1b=  'b110;
        end

        A1_2E3: begin
            s1a=  'b100;
            s1b=  'b000;
        end

        A1_5E1_2E3: begin
            s1a=  'b101;
            s1b=  'b100;
        end

        default: begin
            s1a=  'b111;
            s1b=  'b111;
        end
    endcase
end

//adder2 muxes select signals 
always @(*) begin
    case (cs_A2)
        A2_IDLE: begin
            s2a=  'b111;
            s2b=  'b111;
        end

        A2_2E1_E3: begin
            s2a=  'b000; 
            s2b=  'b000;
        end

        A2_E1_2E3: begin
            s2a=  'b001; 
            s2b=  'b001;
        end

        A2_2E2_E3: begin
            s2a=  'b011;
            s2b=  'b000;
        end

        A2_2E2_E4: begin
            s2a=  'b011; 
            s2b=  'b011;
        end

        A2_4E4_E4: begin
            s2a=  'b010;
            s2b=  'b011;
        end

        A2_4E4_E2: begin
            s2a=  'b010;
            s2b=  'b010;
        end

        A2_E3: begin
            s2a=  'b110;
            s2b=  'b110;
        end

        A2_4E1_E3: begin
            s2a=  'b100;
            s2b=  'b100;
        end

        A2_5E1: begin
            s2a=  'b001;
            s2b=  'b100;
        end

        default: begin
            s2a=  'b111;
            s2b=  'b111;
        end
    endcase
end

//out muxes select signals 
always @(*) begin
        s_h1= s_h1_reg[1:0];
        s_h2= s_h2_reg[1:0];
end

//estimate muxes select signals
/*
 for both shift=0 or 2 : out_mux 1 gets E1, E2 and out_mux 2 gets E3, E4 --> default values
 for shift =1 : out_mux 1 gets E3, E4 and out_mux 2 gets E1, E2 --> different case
*/
always @(*) begin
    s_est= shift[0]; //1st bit is 0 for shift=0 and 2, and it is 1 for shift=1
end

// ---------------------------------------------------------
// --------------- demap col and row signals ---------------
// ---------------------------------------------------------

//col_addr
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        col_addr<= 'b0;
    end
    else if ((cs== MULT_STORE | cs==MULT_ADD) & !counter4[0]) begin
        col_addr<=col_addr+1;
    end
end

//col
always @(*) begin
    case (col_addr) 
        'd0: col= 'd5;
        'd1: col= 'd6;
        'd2: col= 'd12;
        'd3: col= 'd13;
    endcase
end

//rd_addr_nrs & nrs_index_addr  sent to index_gen and gets "row" to demapper
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        nrs_index_addr<= 'b0;
        rd_addr_nrs<='b0;
    end
    else if (!counter4_done &(cs== MULT_STORE | cs==MULT_ADD))  begin
        nrs_index_addr<=nrs_index_addr+1;
        rd_addr_nrs<=rd_addr_nrs+2;
    end
end

// ==============================================================================
// ========================== internal control signals ==========================
// ==============================================================================

//load_sel and ready signals
/* 
 load sel registers, signal is to be set 1 clk begore the valid signal is set, and since load_sel is comb. --> same cond. of valid signal
 same cond. --> comb: in the same clk of the state , seq: in the following clk
*/
always @(*) begin
    load_sel= ( (shift=='d0 & cs_A2==A2_2E1_E3) | (cs_A2==A2_4E1_E3) ); 
    E1_ready= (cs==MULT_ADD & counter4=='d1);
    E2_ready= (cs==MULT_ADD & counter4=='d2);
    E3_ready= (cs==MULT_ADD & counter4=='d3);
end

//shift signal
always @(*) begin
    if (v_shift=='d0 | v_shift=='d3) begin
        shift='d0;
    end
    else if (v_shift=='d1 | v_shift=='d4) begin
        shift='d1;
    end
    else begin
        shift='d2;
    end
end

//counter4 
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        counter4<='d0;
        counter4_done<=1'b0;
    end
    else if (cs== MULT_STORE | cs== MULT_ADD) begin
        counter4<=counter4+1;
        counter4_done<=(counter4=='d3);
    end
    else begin
        counter4<= 'd0;
        counter4_done<=1'b0;
    end
end

//first_slot
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        first_slot<=1'b1;
    end
    else if (NRS_gen_ready) begin
        first_slot<=!first_slot;
    end
end

//sequence registers 
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        s_h1_reg<= 'b0;
        s_h2_reg<= 'b0;
    end
    else if (load_sel) begin
        case (shift) 
            'd0: begin
                s_h1_reg<='b 01_11_10_11_01_00;
                s_h2_reg<='b 10_11_00_00_01_00;
            end

            'd1: begin
                s_h1_reg<='b 10_11_01_00_01_01;
                s_h2_reg<='b 00_10_11_10_10_01;
            end

            'd2: begin
                s_h1_reg<='b 01_10_11_11_00_11;
                s_h2_reg<='b 11_10_00_01_00_00; 
            end
            default: begin
                s_h1_reg<='b 01_11_10_11_01_00; //any value
                s_h2_reg<='b 10_11_00_00_01_00;
            end
        endcase
    end
    else if (valid_eqlz) begin
        s_h1_reg<= s_h1_reg>>2; 
        s_h2_reg<= s_h2_reg>>2;
    end
end

// ---------------------------------------------------- 
// -------------------- go signals -------------------- 
// ---------------------------------------------------- 

/*
  go_1 signal : it's like a closed door, state knocks, door opens, state passes, door is locked again
  go_1 set to 0, state ready--> go_1 set to 1 for 1 clk , then goes back to 0, this is just to delay the next state by 1 clk
*/

//go_1
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        go_1<=1'b0;
    end
    else if (go_1) begin
        go_1<=1'b0;
    end
    else if ( (cs_A1==A1_2E2) | (cs_A1==A1_E2_2E3) | (cs_A1==A1_5E1_2E3) ) begin
        go_1<=1'b1;
    end
end

//go_2
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        go_2<=1'b0;
    end
    else if (go_2) begin
        go_2<=1'b0;
    end
    else if ( (cs_A2==A2_2E1_E3) | (cs_A2==A2_2E2_E4) & shift!='d0 ) begin
        go_2<=1'b1;
    end
end

endmodule
