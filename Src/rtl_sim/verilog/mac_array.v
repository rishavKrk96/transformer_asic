// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_array (clk, reset, in, out, fifo_wr, inst , k_load_done, gate_col, mode);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 8;

localparam EIGHT_B_EIGHT_B = 2'b00;
localparam FOUR_B_EIGHT_B = 2'b01;
localparam FOUR_B_FOUR_B = 2'b10;

output [bw_psum*col-1:0] out;
input  [pr*bw-1:0] in;
input  clk, reset;
input  [1:0] inst; // [1]: execute, [0]: load 
input  [1:0] mode;

input [2:0] gate_col;

output [col-1:0] fifo_wr;
output k_load_done;
//wire mode;

wire   [col*bw_psum-1:0] psum;
wire   [2*(col+1)-1:0] inst_temp;
wire   [2*(col+1)*bw*pr-1:0] q_temp;

wire   [bw_psum*col-1:0] temp_out;

reg    [bw_psum*col-1:0] temp_out_d1;
wire   [bw_psum*col-1:0] temp_out_d1_wire;

wire  [col-1:0] fifo_wr_temp;

wire  [col-1:0] fifo_wr_temp_stage2;

wire  [col-1:0] load_ready_q;
wire  [col-1:0] clk_final;
wire  [col-1:0] icg_en;

wire [bw_psum*col-1:0] out_stage1;

genvar i;

//for (i=0; i < col ; i=i+1) begin
//  assign fifo_wr[i] = inst_temp[2*i+1] ;
//end

assign inst_temp[1:0]    = inst;
assign q_temp[bw*pr-1:0] = in;

assign k_load_done = !(load_ready_q[0]); 

always@(posedge clk)
begin
 temp_out_d1 <=  temp_out;
end



assign fifo_wr[0] = (mode==FOUR_B_EIGHT_B)?(fifo_wr_temp_stage2[1]):(fifo_wr_temp_stage2[0]);
assign fifo_wr[2] = (mode==FOUR_B_EIGHT_B)?(fifo_wr_temp_stage2[3]):(fifo_wr_temp_stage2[2]);
assign fifo_wr[4] = (mode==FOUR_B_EIGHT_B)?(fifo_wr_temp_stage2[5]):(fifo_wr_temp_stage2[4]);
assign fifo_wr[6] = (mode==FOUR_B_EIGHT_B)?(fifo_wr_temp_stage2[7]):(fifo_wr_temp_stage2[6]);


assign fifo_wr[1] = fifo_wr_temp_stage2[1];
assign fifo_wr[3] = fifo_wr_temp_stage2[3];
assign fifo_wr[5] = fifo_wr_temp_stage2[5];
assign fifo_wr[7] = fifo_wr_temp_stage2[7];

assign icg_en = (gate_col == 0)? 8'b11111111 : ((gate_col == 1)? 8'b01111111 : ((gate_col == 2)? 8'b00111111 : ((gate_col == 3)? 8'b00011111 : ((gate_col == 4)? 8'b00001111 : ((gate_col == 5)? 8'b00000111 : ((gate_col ==6)? 8'b00000011 : ((gate_col == 7)? 8'b00000001 : 8'b0)) )) )) );


for (i=1; i < col+1 ; i=i+1) begin : col_idx
   mac_col #(.bw(bw), .pr(pr), .col_id(i)) mac_col_inst (
        .q_in( q_temp[pr*bw*i-1    :pr*bw*(i-1)]), 
        .q_out(q_temp[pr*bw*(i+1)-1:pr*bw*i]), 
        .clk(clk_final[i-1]), 
        .reset(reset), 
        .fifo_wr(fifo_wr_temp[i-1]),
        .i_inst(inst_temp[2*i-1:2*(i-1)]),     
        .o_inst(inst_temp[2*(i+1)-1:2*(i)]),     
	.out(temp_out[bw_psum*i-1 : bw_psum*(i-1)]),
	.load_ready_q(load_ready_q[i-1]),
	.gate_col(gate_col),
	.mode(mode)
   );

//assign icg_en[i-1] = (i <= (col - gate_col));

icg mac_col_icg_inst(
  .clk_in(clk),
  .clk_out(clk_final[i-1]),
  .en(icg_en[i-1])
);

assign fifo_wr_temp_stage2[i-1] = (icg_en[i-1])? fifo_wr_temp[i-1]:fifo_wr_temp[0];
assign out[bw_psum*i-1:bw_psum*(i-1)] = (icg_en[i-1])? out_stage1[bw_psum*i-1:bw_psum*(i-1)] : 0;
end

assign temp_out_d1_wire = temp_out_d1;

assign out_stage1[bw_psum*(0+2)-1:bw_psum*0] = (mode==FOUR_B_EIGHT_B)?({{(bw_psum){temp_out_d1_wire[bw_psum*(0+1) - 1]}} , (temp_out_d1_wire[bw_psum*(0+1)-1:bw_psum*(0)] )}  + {{(bw_psum - bw){temp_out[bw_psum*(0+2)-1]}},temp_out[bw_psum*(0+2)-1 : bw_psum*(0+2)-bw],(temp_out[bw_psum*(0+2)-1 :bw_psum*(0+1)] << bw)}):(temp_out[bw_psum*(0+2)-1:bw_psum*0]);
assign out_stage1[bw_psum*(2+2)-1:bw_psum*2] = (mode==FOUR_B_EIGHT_B)?({{(bw_psum){temp_out_d1_wire[bw_psum*(2+1) - 1]}} , (temp_out_d1_wire[bw_psum*(2+1)-1:bw_psum*(2)] )}  + {{(bw_psum - bw){temp_out[bw_psum*(2+2)-1]}},temp_out[bw_psum*(2+2)-1 : bw_psum*(2+2)-bw],(temp_out[bw_psum*(2+2)-1 :bw_psum*(2+1)] << bw)}):(temp_out[bw_psum*(2+2)-1:bw_psum*2]);
assign out_stage1[bw_psum*(4+2)-1:bw_psum*4] = (mode==FOUR_B_EIGHT_B)?({{(bw_psum){temp_out_d1_wire[bw_psum*(4+1) - 1]}} , (temp_out_d1_wire[bw_psum*(4+1)-1:bw_psum*(4)] )}  + {{(bw_psum - bw){temp_out[bw_psum*(4+2)-1]}},temp_out[bw_psum*(4+2)-1 : bw_psum*(4+2)-bw],(temp_out[bw_psum*(4+2)-1 :bw_psum*(4+1)] << bw)}):(temp_out[bw_psum*(4+2)-1:bw_psum*4]);
assign out_stage1[bw_psum*(6+2)-1:bw_psum*6] = (mode==FOUR_B_EIGHT_B)?({{(bw_psum){temp_out_d1_wire[bw_psum*(6+1) - 1]}} , (temp_out_d1_wire[bw_psum*(6+1)-1:bw_psum*(6)] )}  + {{(bw_psum - bw){temp_out[bw_psum*(6+2)-1]}},temp_out[bw_psum*(6+2)-1 : bw_psum*(6+2)-bw],(temp_out[bw_psum*(6+2)-1 :bw_psum*(6+1)] << bw)}):(temp_out[bw_psum*(6+2)-1:bw_psum*6]);

endmodule
