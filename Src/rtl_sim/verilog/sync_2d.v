module sync_2d(d,clk,q);

input d;
input clk;
output reg q;

reg d1;

always@(posedge clk)
begin
  d1 <= d;
  q <= d1;  
end

endmodule
