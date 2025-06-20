// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

module fullchip (clk1, clk2, mem_in1, inst1, reset1, pmem_out1, mem_in2, inst2, reset2, pmem_out2);
//sum_out, override_rd, override_wr, gate_col, num_inputs);


parameter col = 8;
parameter bw = 4;
parameter bw_psum = 2*bw+4;
parameter pr = 8;



input  clk1;
input  clk2;
input  [pr*bw-1:0] mem_in1; 
input  [38:0] inst1; 
input  reset1;
//output [bw_psum+3:0] sum_out;

input  [pr*bw-1:0] mem_in2; 
input  [38:0] inst2; 
input  reset2;

output [2*bw_psum*col-1:0] pmem_out1;
output [2*bw_psum*col-1:0] pmem_out2;

wire  [bw_psum+3:0] sum_in_1;
wire  [bw_psum+3:0] sum_out_1;
wire  tx_ack_1;
wire  rx_req_1;
wire  tx_req_1;
wire  rx_ack_1;


wire  [bw_psum+3:0] sum_in_2;
wire  [bw_psum+3:0] sum_out_2;
wire  tx_ack_2;
wire  rx_req_2;
wire  tx_req_2;
wire  rx_ack_2;


wire  [pr*bw-1:0] mem_in1_q; 
wire  [38:0] inst1_q; 
wire  [pr*bw-1:0] mem_in2_q; 
wire  [38:0] inst2_q; 

assign tx_ack_1 = rx_ack_2;
assign rx_req_1 = tx_req_2;
assign tx_ack_2 = rx_ack_1;
assign rx_req_2 = tx_req_1;

assign sum_in_1 = sum_out_2;
assign sum_in_2 = sum_out_1;

//assign sum_out = sum_out_1 + sum_out_2 ; 

//input override_rd;
//input override_wr;
//input [2:0] gate_col;
//input [4:0] num_inputs;


core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance_1 (
      .reset(reset1), 
      .clk(clk1), 
      .mem_in(mem_in1_q), 
      .inst(inst1_q),
      .out(pmem_out1),
      .sum_out(sum_out_1),
      .tx_ack(tx_ack_1),
      .rx_req(rx_req_1),
      .tx_req(tx_req_1),
      .rx_ack(rx_ack_1),
      .sum_in(sum_in_1)
      //.override_rd(override_rd),
      //.override_wr(override_wr),
      //.gate_col(gate_col),
      //.num_inputs(num_inputs)
);


core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance_2 (
      .reset(reset2), 
      .clk(clk2), 
      .mem_in(mem_in2_q), 
      .inst(inst2_q),
      .out(pmem_out2),
      .sum_out(sum_out_2),
      .tx_ack(tx_ack_2),
      .rx_req(rx_req_2),
      .tx_req(tx_req_2),
      .rx_ack(rx_ack_2),
      .sum_in(sum_in_2)
      //.override_rd(override_rd),
      //.override_wr(override_wr),
      //.gate_col(gate_col),
      //.num_inputs(num_inputs)
);


genvar i;
genvar k;

for(i=0; i<39 ;i = i+1) begin
  sync_2d inst1_sync(
  .d(inst1[i]),  
  .clk(clk1),
  .q(inst1_q[i])  
  );


  sync_2d inst2_sync(
  .d(inst2[i]),  
  .clk(clk2),
  .q(inst2_q[i])  
  );

end


for(k=0; k<pr*bw ;k = k+1) begin
  sync_2d mem1_sync(
  .d(mem_in1[k]),  
  .clk(clk1),
  .q(mem_in1_q[k])  
  );


  sync_2d mem2_sync(
  .d(mem_in2[k]),  
  .clk(clk2),
  .q(mem_in2_q[k])  
  );

end

endmodule
