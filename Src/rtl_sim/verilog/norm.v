// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module norm (clk, in, out_final, div, wr, o_full, reset, o_ready, sum_q, sum_in);

  parameter bw = 4;
  parameter width = 1;

  input  clk;
  input  wr;
  input  div;
  input  reset;
  input  [bw-1:0] in;
  output o_full;
  output o_ready;
  output [2*bw-1:0] out_final;
  //output reg  [2*bw-1:0] sum_q;

  output reg  [bw+3:0] sum_q;
  input [bw+3:0] sum_in;

  wire [bw-1:0] fifo_out;
  wire empty;
  wire full;
  wire [2*bw-1:0] div_out;
  assign div_out = (fifo_out[bw-1] == 0)?{fifo_out, 8'b00000000} / sum_in : ~({{(bw){1'b0}},~fifo_out + 1'b1,8'b00000000}/sum_in) + 1'b1;

  reg [2*bw-1:0] out;
  
  assign out_final = out; 

  fifo_top #(.bw(bw), .width(width)) fifo_top_instance (
	 .clk(clk),
	 .rd(div), //Add the correct variable / value in the bracket
	 .wr(wr),
	 .in(in),
	 .out(fifo_out),
         .reset(reset),
	 .o_full(o_full),
	 .o_ready(o_ready)
  );

  always @ (posedge clk) begin
   if (reset) begin
      sum_q <= 0;
   end
   else begin
      if (wr & (in[bw-1] == 0)) 
        sum_q <= sum_q + {{(4){1'b0}},in};
      else if (wr & (in[bw-1] == 1))
	sum_q <= sum_q + {{(4){1'b0}},(~in + 1'b1)}; 
      else if (div) 
      begin
        out <= div_out;
      end
   end
  end

endmodule
