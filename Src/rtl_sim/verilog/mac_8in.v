// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_8in (out, a, b, clk, mode);

parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 8; // parallel factor: number of inputs = 64
localparam EIGHT_B_EIGHT_B = 2'b00;
localparam FOUR_B_EIGHT_B = 2'b01;
localparam FOUR_B_FOUR_B= 2'b10;


output [bw_psum-1:0] out;
input  [pr*bw-1:0] a;
input  [pr*bw-1:0] b;
input  clk;
input  [1:0] mode;

wire		[2*bw-1:0]	product0	;
wire		[2*bw-1:0]	product1	;
wire		[2*bw-1:0]	product2	;
wire		[2*bw-1:0]	product3	;
wire		[2*bw-1:0]	product4	;
wire		[2*bw-1:0]	product5	;
wire		[2*bw-1:0]	product6	;
wire		[2*bw-1:0]	product7	;



reg	[2*bw-1:0]	product0_reg	;
reg	[2*bw-1:0]	product1_reg	;
reg	[2*bw-1:0]	product2_reg	;
reg	[2*bw-1:0]	product3_reg	;
reg	[2*bw-1:0]	product4_reg	;
reg	[2*bw-1:0]	product5_reg	;
reg	[2*bw-1:0]	product6_reg	;
reg	[2*bw-1:0]	product7_reg	;

reg    [bw_psum-1:0] out1;
reg    [bw_psum-1:0] out2;

genvar i;


assign	product0	= (!(mode==EIGHT_B_EIGHT_B))? {{(bw){a[bw*	1	-1]}},	a[bw*	1	-1:bw*	0	]}	*	{{(bw){1'b0}},	b[bw*	1	-1:	bw*	0	]}:{{(bw){a[bw*	1	-1]}},	a[bw*	1	-1:bw*	0	]}	*	{{(bw){b[bw* 1 - 1]}},	b[bw*	1	-1:	bw*	0	]};

assign	product1	= (!(mode==EIGHT_B_EIGHT_B))? {{(bw){a[bw*	2	-1]}},	a[bw*	2	-1:bw*	1	]}	*	{{(bw){1'b0}},	b[bw*	2	-1:	bw*	1	]}:{{(bw){a[bw*	2	-1]}},	a[bw*	2	-1:bw*	1	]}	*	{{(bw){b[bw* 2 - 1]}},	b[bw*	2	-1:	bw*	1	]};

assign	product2	= (!(mode==EIGHT_B_EIGHT_B))? {{(bw){a[bw*	3	-1]}},	a[bw*	3	-1:bw*	2	]}	*	{{(bw){1'b0}},	b[bw*	3	-1:	bw*	2	]}:{{(bw){a[bw*	3	-1]}},	a[bw*	3	-1:bw*	2	]}	*	{{(bw){b[bw* 3 - 1]}},	b[bw*	3	-1:	bw*	2	]};

assign	product3	= (!(mode==EIGHT_B_EIGHT_B))? {{(bw){a[bw*	4	-1]}},	a[bw*	4	-1:bw*	3	]}	*	{{(bw){1'b0}},	b[bw*	4	-1:	bw*	3	]}:{{(bw){a[bw*	4	-1]}},	a[bw*	4	-1:bw*	3	]}	*	{{(bw){b[bw* 4 - 1]}},	b[bw*	4	-1:	bw*	3	]};

assign	product4	= (!(mode==EIGHT_B_EIGHT_B))? {{(bw){a[bw*	5	-1]}},	a[bw*	5	-1:bw*	4	]}	*	{{(bw){1'b0}},	b[bw*	5	-1:	bw*	4	]}:{{(bw){a[bw*	5	-1]}},	a[bw*	5	-1:bw*	4	]}	*	{{(bw){b[bw* 5 - 1]}},	b[bw*	5	-1:	bw*	4	]};

assign	product5	= (!(mode==EIGHT_B_EIGHT_B))? {{(bw){a[bw*	6	-1]}},	a[bw*	6	-1:bw*	5	]}	*	{{(bw){1'b0}},	b[bw*	6	-1:	bw*	5	]}:{{(bw){a[bw*	6	-1]}},	a[bw*	6	-1:bw*	5	]}	*	{{(bw){b[bw* 6 - 1]}},	b[bw*	6	-1:	bw*	5	]};


assign	product6	= (!(mode==EIGHT_B_EIGHT_B))? {{(bw){a[bw*	7	-1]}},	a[bw*	7	-1:bw*	6	]}	*	{{(bw){1'b0}},	b[bw*	7	-1:	bw*	6	]}:{{(bw){a[bw*	7	-1]}},	a[bw*	7	-1:bw*	6	]}	*	{{(bw){b[bw* 7 - 1]}},	b[bw*	7	-1:	bw*	6	]};


assign	product7	= (!(mode==EIGHT_B_EIGHT_B))? {{(bw){a[bw*	8	-1]}},	a[bw*	8	-1:bw*	7	]}	*	{{(bw){1'b0}},	b[bw*	8	-1:	bw*	7	]}:{{(bw){a[bw*	8	-1]}},	a[bw*	8	-1:bw*	7	]}	*	{{(bw){b[bw* 8 - 1]}},	b[bw*	8	-1:	bw*	7	]};

always@(posedge clk)
begin	
  product0_reg <= product0;
  product1_reg <= product1;
  product2_reg <= product2;
  product3_reg <= product3;
  product4_reg <= product4;
  product5_reg <= product5;
  product6_reg <= product6;
  product7_reg <= product7;
  out1 <=  
                {{(4){product0_reg[2*bw-1]}},product0_reg	}
	+	{{(4){product1_reg[2*bw-1]}},product1_reg	}
	+	{{(4){product2_reg[2*bw-1]}},product2_reg	}
	+	{{(4){product3_reg[2*bw-1]}},product3_reg	};

  out2 <=
        	{{(4){product4_reg[2*bw-1]}},product4_reg	}
	+	{{(4){product5_reg[2*bw-1]}},product5_reg	}
	+	{{(4){product6_reg[2*bw-1]}},product6_reg	}
	+	{{(4){product7_reg[2*bw-1]}},product7_reg	};
end


assign out = out1 + out2; 



endmodule
