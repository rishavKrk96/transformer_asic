module icg(clk_in, en, clk_out);

  input clk_in;
  input en;
  output clk_out;
  reg en_neg;

  assign clk_out = en_neg && clk_in;

  always @ (negedge clk_in) begin
    en_neg <= en;
  end


endmodule

