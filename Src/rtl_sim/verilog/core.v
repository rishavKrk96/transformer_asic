// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module core (clk, sum_out, mem_in, out, inst, reset, sum_in,rx_req,tx_ack,tx_req,rx_ack);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+3;
parameter pr = 8;

output [bw_psum+3:0] sum_out;
output [2*bw_psum*col-1:0] out;
wire   [bw_psum*col-1:0] pmem_out;
input  [pr*bw-1:0] mem_in;
input  clk;
input  [38:0] inst; 
input  reset;


input  [bw_psum+3:0] sum_in; 

input rx_req;
input tx_ack;
output reg tx_req;
output reg rx_ack;

wire  [pr*bw-1:0] mac_in;
wire  [pr*bw-1:0] kmem_out;
wire  [pr*bw-1:0] qmem_out;
wire  [bw_psum*col-1:0] pmem_in;
wire  [bw_psum*col-1:0] fifo_out;
wire  [bw_psum*col-1:0] sfp_out;
wire  [bw_psum*col-1:0] array_out;
wire  [col-1:0] fifo_wr;
wire  ofifo_rd;
wire [3:0] qkmem_add;
wire [3:0] pmem_add;
wire [3:0] controller_pmem_add;
wire [3:0] qmem_add;
wire [3:0] kmem_add;

wire [3:0] qmem_add_final;
wire [3:0] kmem_add_final;

wire  qmem_rd;
wire  qmem_wr; 
wire  kmem_rd;
wire  kmem_wr; 
wire  pmem_rd;
wire  pmem_wr; 

wire controller_qmem_wr;
wire controller_qmem_rd;
wire controller_kmem_wr;
wire controller_kmem_rd;

wire controller_ofifo_rd;

wire [1:0] mode;

//wire override_rd;
//wire override_wr;

wire mac_load_b;

//assign override_rd = 1'b0;
//assign override_wr = 1'b1;

wire div;
wire norm_mem_rd;
wire norm_mem_wr;
wire norm_wr;
wire norm_full;
wire norm_o_ready;
wire [2*bw_psum-1:0] norm_out;
reg [2*bw_psum*col-1:0] norm_out_merged;
wire [2*bw_psum*col-1:0] norm_out_merged_rd;
reg reset_norm;
reg [3:0] count_div;
reg [3:0] count_add;
reg [bw_psum+3:0] sum_1;
reg [bw_psum+3:0] sum_2;
wire [bw_psum+3:0] sum_out_norm;
wire [bw_psum+3:0] sum_out_final;
wire [3:0] norm_mem_add;
wire [bw_psum-1:0] norm_in;

reg  [bw_psum*col-1:0] pmem_out_reg;
reg div_d;
reg div_2d;
//reg div_3d;
//reg div_4d;
reg pmem_rd_d;
reg norm_mem_rd_d;


wire rx_req_sync;
wire tx_ack_sync;
wire reset_handshake;
reg latch_sum;



wire qmem_en;
wire qmem_clk;

wire kmem_en;
wire kmem_clk;

wire pmem_en;
wire pmem_clk;

wire norm_mem_en;
wire norm_mem_clk;
wire [4:0] num_inputs;
wire [2:0] gate_col;
wire override_rd;
wire override_wr;

assign num_inputs = inst[38:34];
assign gate_col = inst[33:31];
assign override_wr = inst[30];
assign override_rd = inst[29];
assign norm_mem_wr = inst[28];
assign norm_mem_add = inst[27:24];
assign norm_mem_rd = inst[23];
assign div = inst[21];
assign norm_wr = inst[22];

assign ofifo_rd = (override_rd)?inst[16]:controller_ofifo_rd;

assign qkmem_add = inst[15:12];
assign pmem_add = (override_rd)?inst[11:8]:controller_pmem_add;

assign qmem_add_final = (qmem_rd)? qmem_add : qkmem_add ;
assign kmem_add_final = (kmem_rd)? kmem_add : qkmem_add ;

assign qmem_rd = (override_rd)?inst[5]:controller_qmem_rd;
assign qmem_wr = (override_wr)?inst[4]:controller_qmem_wr;
assign kmem_rd = (override_rd)?inst[3]:controller_kmem_rd;
assign kmem_wr = (override_wr)?inst[2]:controller_kmem_wr;
assign pmem_rd = inst[1];
assign pmem_wr = (override_rd)?inst[0]:ofifo_rd;

assign mac_in  = (mac_load_b) ? kmem_out : qmem_out;
assign pmem_in = fifo_out;

assign mode = inst[18:17];
assign start = inst[19];


assign out = (pmem_rd_d)? pmem_out:((norm_mem_rd_d)?norm_out_merged_rd:0); 


controller controller_inst(
        .clk(clk),
	.reset(reset),
        .start(start),
	.k_load_done(k_load_done),
	.num_inputs(num_inputs),
	.kmem_rd(controller_kmem_rd),
	.qmem_rd(controller_qmem_rd),
	.kmem_add(kmem_add),
	.qmem_add(qmem_add),
	.mac_load_b(mac_load_b),
	.exec(exec),
	.reset_array(reset_array),
	.kmem_wr(controller_kmem_wr),
	.qmem_wr(controller_qmem_wr),
	.ofifo_rd(controller_ofifo_rd),
	.ofifo_valid(fifo_valid),
	.pmem_add(controller_pmem_add),
	.set(4'b1)
);

mac_array #(.bw(bw), .col(col), .pr(pr)) mac_array_instance (
        .in(mac_in), 
        .clk(clk), 
        .reset(reset | reset_array), 
        .inst({exec,mac_load_b}),     
        .fifo_wr(fifo_wr),     
	.out(array_out),
	.mode(mode),
	.k_load_done(k_load_done),
	.gate_col(gate_col)
);

ofifo #(.bw(bw_psum), .col(col))  ofifo_inst (
        .reset(reset),
        .clk(clk),
        .in(array_out),
        .wr(fifo_wr),
        .rd(ofifo_rd),
        .o_valid(fifo_valid),
        .out(fifo_out)
);



assign qmem_en = qmem_rd || qmem_wr;
assign kmem_en = kmem_rd || kmem_wr;
assign pmem_en = pmem_rd || pmem_wr;
assign norm_mem_en =  norm_mem_rd || norm_mem_wr;

icg icg_qmem_instance(
    .clk_in(clk), 
    .en(qmem_en),
    .clk_out(qmem_clk)
);

icg icg_kmem_instance(
    .clk_in(clk), 
    .en(kmem_en),
    .clk_out(kmem_clk)
);

icg icg_pmem_instance(
    .clk_in(clk), 
    .en(pmem_en),
    .clk_out(pmem_clk)
);


icg icg_norm_mem_instance(
    .clk_in(clk), 
    .en(norm_mem_en),
    .clk_out(norm_mem_clk)
);



sram_w16 #(.sram_bit(pr*bw)) qmem_instance (
        .CLK(qmem_clk),
        .D(mem_in),
        .Q(qmem_out),
        .CEN(!qmem_en),
        .WEN(!qmem_wr), 
        .A(qmem_add_final)
);

sram_w16 #(.sram_bit(pr*bw)) kmem_instance (
        .CLK(kmem_clk),
        .D(mem_in),
        .Q(kmem_out),
        .CEN(!kmem_en),
        .WEN(!kmem_wr), 
        .A(kmem_add_final)
);

sram_w16 #(.sram_bit(col*bw_psum)) pmem_instance (
        .CLK(pmem_clk),
        .D(pmem_in),
        .Q(pmem_out),
        .CEN(!pmem_en),
        .WEN(!pmem_wr), 
        .A(pmem_add)
);


sram_w16 #(.sram_bit(col*2*bw_psum)) norm_mem_instance (
        .CLK(norm_mem_clk),
        .D(norm_out_merged),
        .Q(norm_out_merged_rd),
        .CEN(!norm_mem_en),
        .WEN(!norm_mem_wr), 
        .A(norm_mem_add)
);


norm #(.bw(bw_psum)) norm_instance(
        .clk(clk),
	.in(norm_in),
	.out_final(norm_out),
	.div(div_d),
        .wr(norm_wr),
	.o_full(norm_full),
	.reset(reset || reset_norm),
	.o_ready(norm_o_ready),
	.sum_q(sum_out_norm),
	.sum_in(sum_out_final)
);

assign norm_in = (norm_wr & !pmem_rd)?(pmem_out_reg[2*bw_psum-1:0]):0;
//assign norm_in = (norm_wr & !pmem_rd)?((pmem_out_reg[bw_psum-1])?((~pmem_out_reg[bw_psum-1:0]) + 1'b1):pmem_out_reg[bw_psum-1:0]):0;// absolute value

assign sum_out_final = sum_1 + sum_2;
assign sum_out = sum_1;


always@(posedge clk)
begin	

  if(reset)
  begin
    norm_out_merged <= 0;
    reset_norm <= 0;
    sum_1 <= 0;
    count_div <= 0;
    count_add <= 0;
    div_d <= 0;
    div_2d <= 0;
  end

  else begin

  div_d <= div;
  div_2d <= div_d;
  //div_3d <= div_2d;
  //div_4d <= div_3d;
  pmem_rd_d <= pmem_rd;
  norm_mem_rd_d <= norm_mem_rd;

  if(norm_wr & !pmem_rd)
  begin
    //norm_in <= pmem_out_reg[bw_psum-1:0];
    pmem_out_reg <= {{(bw_psum){1'b0}},pmem_out_reg[bw_psum*col-1:bw_psum]};
  end
  else if(pmem_rd)
  begin
    pmem_out_reg <= pmem_out;
  end
  else
  begin
    //norm_in <= 0;
    pmem_out_reg <= 0;
  end	  

  if(div_2d)
  begin
   norm_out_merged <= {norm_out,norm_out_merged[bw_psum*2*col-1:bw_psum*2]}; 
   //count_div <= count_div + 1'b1;
  end

  //if(count_div == 8)
  //begin
  //  count_div <= 0;	  
  //end
  
  count_div <= (count_div == 8)? 0:((div_2d)? count_div+1'b1:count_div);
  count_add <= (count_add == 8)? 0:((norm_wr)? count_add + 1'b1:count_add);
  sum_1 <= (count_add == 8)? sum_out_norm: sum_1;
  reset_norm <= (count_div == 8)? 1'b1:1'b0;

  end

end



sync_2d rx_req_sync_inst(
 .d(rx_req),
 .clk(clk),
 .q(rx_req_sync)
);


sync_2d rx_ack_sync_inst(
 .d(tx_ack),
 .clk(clk),
 .q(tx_ack_sync)
);

assign reset_handshake = reset || reset_norm;


// handshake controller
always@(posedge clk)
begin

  if(reset_handshake) begin
  
    tx_req <= 1'b0;
    rx_ack <= 1'b0;
    sum_2 <= 0;
    latch_sum <= 1'b1;  
  end

  else begin

    if(count_add == 8)
      tx_req <= 1'b1;
    else if(tx_ack_sync)
      tx_req <= 1'b0;
    
    if(rx_req_sync)
    begin	  
      if(latch_sum)  
      begin	      
        sum_2 <= sum_in;
        latch_sum <= 1'b0;
      end
      rx_ack <= 1'b1;      
    end 
    else
      rx_ack <= 1'b0;

  end

end


endmodule
