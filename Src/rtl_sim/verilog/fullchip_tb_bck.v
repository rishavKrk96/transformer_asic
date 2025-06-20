// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

`timescale 1ns/1ps

module fullchip_tb;

//parameter total_cycle = 8;   // how many streamed Q vectors will be processed

parameter total_cycle = 8;   // how many streamed Q vectors will be processed
parameter bw = 4;            // Q & K vector bit precision
parameter bw_psum = 2*bw+4;  // partial sum bit precision
parameter pr = 8;           // how many products added in each dot product 
parameter col = 8;           // how many dot product units are equipped

localparam EIGHT_B_EIGHT_B = 2'b00;
localparam FOUR_B_EIGHT_B = 2'b01;
localparam FOUR_B_FOUR_B = 2'b10;

integer qk_file ; // file handler
integer qk_scan_file ; // file handler


integer  captured_data;
integer  weight [col*pr-1:0];

integer error =  0;

`define NULL 0




integer  K[col-1:0][pr-1:0];
integer  Q[total_cycle-1:0][pr-1:0];
integer  K2[col-1:0][pr-1:0];
integer  Q2[total_cycle-1:0][pr-1:0];

integer  result[total_cycle-1:0][col-1:0];
integer  sum[total_cycle-1:0];
integer  result2[total_cycle-1:0][col-1:0];
integer  sum1[total_cycle-1:0];
integer  sum2[total_cycle-1:0];

integer i,j,k,t,p,q,s,u, m;





reg reset = 1;
reg clk = 0;
reg [pr*bw-1:0] mem_in; 
reg ofifo_rd = 0;
wire [28:0] inst;
reg start = 0;
reg qmem_rd = 0;
reg qmem_wr = 0; 
reg kmem_rd = 0; 
reg kmem_wr = 0;
reg pmem_rd = 0; 
reg pmem_wr = 0; 
reg execute = 0;
reg load = 0;
reg [3:0] qkmem_add = 0;
reg [3:0] pmem_add = 0;
reg [1:0] mode = 0;
reg override_rd = 0;
reg override_wr = 1;
reg [2:0] gate_col = 2;
reg [4:0] num_inputs = total_cycle;

reg norm_wr = 0;
reg div = 0;
reg norm_mem_rd = 0;
reg norm_mem_wr = 0;
reg [3:0] norm_mem_add = 0;

assign inst[28] = norm_mem_wr;
assign inst[27:24] = norm_mem_add ;
assign inst[23] = norm_mem_rd;
assign inst[22] = norm_wr;
assign inst[21] = div;
assign inst[19] = start;
assign inst[18:17] = mode;
assign inst[16] = ofifo_rd;
assign inst[15:12] = qkmem_add;
assign inst[11:8]  = pmem_add;
assign inst[7] = execute;
assign inst[6] = load;
assign inst[5] = qmem_rd;
assign inst[4] = qmem_wr;
assign inst[3] = kmem_rd;
assign inst[2] = kmem_wr;
assign inst[1] = pmem_rd;
assign inst[0] = pmem_wr;



reg [2*bw_psum-1:0] temp5b;
reg [bw_psum - 1:0] temp5b_short;
reg [2*bw_psum-1:0] temp5b2;
reg [bw_psum - 1:0] temp5b_short2;


reg [bw_psum+3:0] temp_sum;
reg [bw_psum*col-1:0] temp16b;
reg [bw_psum+3:0] temp_sum2;
reg [bw_psum*col-1:0] temp16b2;


reg [2*bw_psum-1:0] norm5b;
reg [2*bw_psum*col-1:0] norm16b;
reg [2*bw_psum-1:0] norm5b2;
reg [2*bw_psum*col-1:0] norm16b2;


wire [2*bw_psum*col-1:0] pmem_out;
wire [bw_psum+3:0] sum_out;


wire clk1;
wire clk2;

wire reset1;
wire reset2;

reg [pr*bw-1:0] mem_in1;
reg [pr*bw-1:0] mem_in2; 

wire [28:0] inst1;
wire [28:0] inst2;

wire [2*bw_psum*col-1:0] pmem_out1;
wire [2*bw_psum*col-1:0] pmem_out2;

assign clk1 = clk;
assign #0.1 clk2 = clk;

assign reset1 = reset;
assign #0.1 reset2 = reset;


assign inst1 = inst;
assign #0.1 inst2 = inst;

//assign pmem_out = pmem_out1; // temporary

//fullchip #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) fullchip_instance (


fullchip fullchip_instance (
      .reset1(reset1),
      .reset2(reset2),
      .clk1(clk1),
      .clk2(clk2), 
      .mem_in1(mem_in1), 
      .inst1(inst1),
      .sum_out(sum_out),
      .pmem_out1(pmem_out1),
      .mem_in2(mem_in2),
      .inst2(inst2),
      .pmem_out2(pmem_out2),
      .override_rd(override_rd),
      .override_wr(override_wr),
      .gate_col(gate_col),
      .num_inputs(num_inputs)
);

real CLK_PERIOD = 1;

always #(CLK_PERIOD/2) clk = ~clk;


initial begin 

  $dumpfile("fullchip_tb.vcd");
  $dumpvars(0,fullchip_tb);

  gate_col = 2;
  override_rd = 0;
  override_wr = 1;
  
  clk = 1'b1;

  #0.8;
///// Q data txt reading /////

$display("##### Q data txt reading #####");


  qk_file = $fopen("qmem_1.txt", "r");

  //// To get rid of first 3 lines in data file ////
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);


  for (q=0; q<total_cycle; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          Q[q][j] = captured_data;
          //$display("%d\n", Q[q][j]);
    end
  end
/////////////////////////////////




  for (q=0; q<2; q=q+1) begin
    #(CLK_PERIOD/2);   
    #(CLK_PERIOD/2);   
  end




///// K data txt reading /////

$display("##### K data txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #(CLK_PERIOD/2);   
    #(CLK_PERIOD/2);   
  end
  reset = 0;

  qk_file = $fopen("ndata_1.txt", "r");

  //// To get rid of first 4 lines in data file ////
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);




  for (q=0; q<col; q=q+2) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K[q][j] = captured_data >> (bw);
	  K[q+1][j] = captured_data % (2**(bw));
    
        //  $display("##### %d %d ", K[q][j], K[q+1][j]);
    end
    $display(" \n ");
  end


  qk_file = $fopen("qmem_2.txt", "r");

  //// To get rid of first 3 lines in data file ////
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);


  for (q=0; q<total_cycle; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          Q2[q][j] = captured_data;
          //$display("%d\n", Q[q][j]);
    end
  end


  qk_file = $fopen("ndata_2.txt", "r");

  for (q=0; q<col; q=q+2) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K2[q][j] = captured_data >> (bw);
	  K2[q+1][j] = captured_data % (2**(bw));
    
        //  $display("##### %d %d ", K[q][j], K[q+1][j]);
    end
    $display(" \n ");
  end

/////////////////////////////////









//////////////////////////////////////////////






///// Qmem writing  /////

$display("##### Qmem writing  #####");

  for (q=0; q<total_cycle; q=q+1) begin

    #(CLK_PERIOD/2);  
    qmem_wr = 1;  if (q>0) qkmem_add = qkmem_add + 1; 
    
    mem_in1[1*bw-1:0*bw] = Q[q][0];
    mem_in1[2*bw-1:1*bw] = Q[q][1];
    mem_in1[3*bw-1:2*bw] = Q[q][2];
    mem_in1[4*bw-1:3*bw] = Q[q][3];
    mem_in1[5*bw-1:4*bw] = Q[q][4];
    mem_in1[6*bw-1:5*bw] = Q[q][5];
    mem_in1[7*bw-1:6*bw] = Q[q][6];
    mem_in1[8*bw-1:7*bw] = Q[q][7];
    mem_in1[9*bw-1:8*bw] = Q[q][8];
    mem_in1[10*bw-1:9*bw] = Q[q][9];
    mem_in1[11*bw-1:10*bw] = Q[q][10];
    mem_in1[12*bw-1:11*bw] = Q[q][11];
    mem_in1[13*bw-1:12*bw] = Q[q][12];
    mem_in1[14*bw-1:13*bw] = Q[q][13];
    mem_in1[15*bw-1:14*bw] = Q[q][14];
    mem_in1[16*bw-1:15*bw] = Q[q][15];


    mem_in2[1*bw-1:0*bw] = Q2[q][0];
    mem_in2[2*bw-1:1*bw] = Q2[q][1];
    mem_in2[3*bw-1:2*bw] = Q2[q][2];
    mem_in2[4*bw-1:3*bw] = Q2[q][3];
    mem_in2[5*bw-1:4*bw] = Q2[q][4];
    mem_in2[6*bw-1:5*bw] = Q2[q][5];
    mem_in2[7*bw-1:6*bw] = Q2[q][6];
    mem_in2[8*bw-1:7*bw] = Q2[q][7];
    mem_in2[9*bw-1:8*bw] = Q2[q][8];
    mem_in2[10*bw-1:9*bw] = Q2[q][9];
    mem_in2[11*bw-1:10*bw] = Q2[q][10];
    mem_in2[12*bw-1:11*bw] = Q2[q][11];
    mem_in2[13*bw-1:12*bw] = Q2[q][12];
    mem_in2[14*bw-1:13*bw] = Q2[q][13];
    mem_in2[15*bw-1:14*bw] = Q2[q][14];
    mem_in2[16*bw-1:15*bw] = Q2[q][15];

    #(CLK_PERIOD/2);  

  end


  #(CLK_PERIOD/2);  
  qmem_wr = 0; 
  qkmem_add = 0;
  #(CLK_PERIOD/2);  
///////////////////////////////////////////





///// Kmem writing  /////

$display("##### Kmem writing #####");

  for (q=0; q<col; q=q+1) begin

    #(CLK_PERIOD/2);  
    kmem_wr = 1; if (q>0) qkmem_add = qkmem_add + 1; 
    
    mem_in1[1*bw-1:0*bw] = K[q][0];
    mem_in1[2*bw-1:1*bw] = K[q][1];
    mem_in1[3*bw-1:2*bw] = K[q][2];
    mem_in1[4*bw-1:3*bw] = K[q][3];
    mem_in1[5*bw-1:4*bw] = K[q][4];
    mem_in1[6*bw-1:5*bw] = K[q][5];
    mem_in1[7*bw-1:6*bw] = K[q][6];
    mem_in1[8*bw-1:7*bw] = K[q][7];
    mem_in1[9*bw-1:8*bw] = K[q][8];
    mem_in1[10*bw-1:9*bw] = K[q][9];
    mem_in1[11*bw-1:10*bw] = K[q][10];
    mem_in1[12*bw-1:11*bw] = K[q][11];
    mem_in1[13*bw-1:12*bw] = K[q][12];
    mem_in1[14*bw-1:13*bw] = K[q][13];
    mem_in1[15*bw-1:14*bw] = K[q][14];
    mem_in1[16*bw-1:15*bw] = K[q][15];

    mem_in2[1*bw-1:0*bw] = K2[q][0];
    mem_in2[2*bw-1:1*bw] = K2[q][1];
    mem_in2[3*bw-1:2*bw] = K2[q][2];
    mem_in2[4*bw-1:3*bw] = K2[q][3];
    mem_in2[5*bw-1:4*bw] = K2[q][4];
    mem_in2[6*bw-1:5*bw] = K2[q][5];
    mem_in2[7*bw-1:6*bw] = K2[q][6];
    mem_in2[8*bw-1:7*bw] = K2[q][7];
    mem_in2[9*bw-1:8*bw] = K2[q][8];
    mem_in2[10*bw-1:9*bw] = K2[q][9];
    mem_in2[11*bw-1:10*bw] = K2[q][10];
    mem_in2[12*bw-1:11*bw] = K2[q][11];
    mem_in2[13*bw-1:12*bw] = K2[q][12];
    mem_in2[14*bw-1:13*bw] = K2[q][13];
    mem_in2[15*bw-1:14*bw] = K2[q][14];
    mem_in2[16*bw-1:15*bw] = K2[q][15];

    #(CLK_PERIOD/2);  

  end

  #(CLK_PERIOD/2);  
  kmem_wr = 0;  
  qkmem_add = 0;
  #(CLK_PERIOD/2);  
///////////////////////////////////////////



  for (q=0; q<2; q=q+1) begin
    #(CLK_PERIOD/2);  
    #(CLK_PERIOD/2);   
  end




///////  K data loading  /////
//$display("##### K data loading to processor #####");
//
//  for (q=0; q<col+1; q=q+1) begin
//    #(CLK_PERIOD/2);  
//    load = 1; 
//    if (q==1) kmem_rd = 1;
//    if (q>1) begin
//       qkmem_add = qkmem_add + 1;
//    end
//
//    #(CLK_PERIOD/2);  
//  end
//
//  #(CLK_PERIOD/2);  
//  kmem_rd = 0; qkmem_add = 0;
//  #(CLK_PERIOD/2);  
//
//  #(CLK_PERIOD/2);  
//  load = 0; 
//  #(CLK_PERIOD/2);  
//
/////////////////////////////////////////////
//
// for (q=0; q<10; q=q+1) begin
//    #(CLK_PERIOD/2);   
//    #(CLK_PERIOD/2);   
// end
//




///// execution  /////
$display("##### execute #####");

$display("Configure mode - 4b 4b or 4b 8b");

  //mode = 1'b1;
  //mode = EIGHT_B_EIGHT_B
  //mode = FOUR_B_EIGHT_B;
  mode = FOUR_B_FOUR_B;
 
  # (CLK_PERIOD/2);
  start = 1'b1;
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  start = 1'b0;

  for (q=0; q<total_cycle; q=q+1) begin
    #(CLK_PERIOD/2);  
  //  execute = 1; 
  //  qmem_rd = 1;

  //  if (q>0) begin
  //     qkmem_add = qkmem_add + 1;
  //  end

    #(CLK_PERIOD/2);  
  end

  #(CLK_PERIOD/2);  
  //qmem_rd = 0; qkmem_add = 0; execute = 0;
  #(CLK_PERIOD/2);  


///////////////////////////////////////////

 for (q=0; q<114; q=q+1) begin
    #(CLK_PERIOD/2);   
    #(CLK_PERIOD/2);   
 end

 #(CLK_PERIOD/2);
 override_rd = 1'b1;
 #(CLK_PERIOD/2);

////////////// output fifo rd and wb to psum mem ///////////////////

//$display("##### move ofifo to pmem #####");
//
//  for (q=0; q<total_cycle; q=q+1) begin
//    #(CLK_PERIOD/2);  
//    ofifo_rd = 1; 
//    pmem_wr = 1; 
//
//    if (q>0) begin
//       pmem_add = pmem_add + 1;
//    end
//
//    #(CLK_PERIOD/2);  
//  end
//
//  #(CLK_PERIOD/2);  
//  pmem_wr = 0; pmem_add = 0; ofifo_rd = 0;
//  #(CLK_PERIOD/2);  

///////////////////////////////////////////

/////////////// Estimated result vs actual result comparison /////////////////


$display("##### Estimated multiplication result #####");

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
       result[t][q] = 0;
       sum1[t] = 0;
       sum2[t] = 0;
     end
  end

  #(CLK_PERIOD/2);
  pmem_rd = 1; 
  #(CLK_PERIOD/2);

  if(mode == FOUR_B_EIGHT_B)
  begin
  for (t=0; t<(total_cycle + 2); t=t+1) begin

     #(CLK_PERIOD/2);

       temp16b = 0;
       temp16b2= 0;
 
       if(t>1) begin
       for (q=0; q<(col-gate_col); q=q+2) begin
           for (k=0; k<pr; k=k+1) begin
              result[t-2][q] = result[t-2][q] + Q[t-2][k] * K[q][k];
              result[t-2][q+1] = result[t-2][q+1] + Q[t-2][k] * K[q+1][k];

              result2[t-2][q] = result2[t-2][q] + Q2[t-2][k] * K2[q][k];
              result2[t-2][q+1] = result2[t-2][q+1] + Q2[t-2][k] * K2[q+1][k];
           end
	   
	   temp5b = ((result[t-2][q])<<bw) + result[t-2][q+1];
     temp5b2 = ((result2[t-2][q])<<bw) + result2[t-2][q+1];
          // $display("##### %d  %d %d %d %d %d %d ",$signed(temp5b),$signed(result[t][q]),$signed(result[t][q+1]),$signed(pmem_out[23:0]),$signed(pmem_out[47:24]),$signed(pmem_out[71:48]),$signed(pmem_out[95:72]));
           
	  // #(CLK_PERIOD/2); 

	  // temp16b = {temp16b[(2*bw_psum)*(col/2-1)-1:0], temp5b};
	   
	   temp16b = {temp16b[(2*bw_psum)*(col/2-1)-1:0], temp5b};
     temp16b2 = {temp16b2[(2*bw_psum)*(col/2-1)-1:0], temp5b2};
          //#(CLK_PERIOD/2);

  end

       if(!(pmem_out2 === temp16b2))
       begin
         error = error + 1;
         $display("prd @cycle%2d: %40h and pmem_out2: %40h do not match %40h", t, temp16b2, pmem_out2,pmem_add);
       end
       else
       begin
         $display("prd @cycle%2d: %40h and pmem_out2: %40h match", t, temp16b2, pmem_out2);
       end     
       
       if(!(pmem_out1 === temp16b))
       begin
         error = error + 1;
         $display("prd @cycle%2d: %40h and pmem_out1: %40h do not match %40h", t, temp16b, pmem_out1,pmem_add);
       end
       else
       begin
         $display("prd @cycle%2d: %40h and pmem_out1: %40h match", t, temp16b, pmem_out1);
           
       end
     
       
       end
       end

     //$display("%d %d %d %d %d %d %d %d", result[t][0], result[t][1], result[t][2], result[t][3], result[t][4], result[t][5], result[t][6], result[t][7]);
     //$display("prd @cycle%2d: %40h", t, temp16b);
     pmem_add = pmem_add + 1'b1;
     if(t == (total_cycle - 1))
     begin
       pmem_rd = 0;
     end
     #(CLK_PERIOD/2);


  

  #(CLK_PERIOD/2);
  pmem_add = 0;
  #(CLK_PERIOD/2);
  
  end

  else begin
	  
  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<(col-gate_col); q=q+1) begin
       result[t][q] = 0;
       result2[t][q] = 0;
       sum1[t] = 0;
       sum2[t]=0;
     end
  end

  #(CLK_PERIOD/2);
  pmem_rd = 1; 
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);

  for (t=0; t<total_cycle + 2; t=t+1) begin

     #(CLK_PERIOD/2);

     pmem_add = pmem_add + 1'b1;
     if(t == (total_cycle - 1))
     begin
       pmem_rd = 0;
     end
     #(CLK_PERIOD/2);

     temp16b = 0;
     temp16b2 = 0;

     if(t>1) begin
     for (q=0; q<(col-gate_col); q=q+1) begin
         for (k=0; k<pr; k=k+1) begin
            result[t-2][q] = result[t-2][q] + Q[t-2][k] * K[q][k];
            result2[t-2][q] = result2[t-2][q] + Q2[t-2][k] * K2[q][k];
         end

         temp5b_short = result[t-2][q];
         temp16b = {temp16b, temp5b_short};

         temp5b_short2 = result2[t-2][q];
         temp16b2 = {temp16b2, temp5b_short2};

     end

     

     if(!(pmem_out1 === temp16b))
     begin
       error = error + 1;
       $display("prd @cycle%2d: %40h and pmem_out1: %40h do not match", t, temp16b, pmem_out1);
     end
     else
     begin
       $display("prd @cycle%2d: %40h and pmem_out1: %40h match", t, temp16b, pmem_out1);
     end     
     

     if(!(pmem_out2 === temp16b2))
     begin
       error = error + 1;
       $display("prd @cycle%2d: %40h and pmem_out2: %40h do not match", t, temp16b2, pmem_out2);
     end
     else
     begin
       $display("prd @cycle%2d: %40h and pmem_out2: %40h match", t, temp16b2, pmem_out2);
     end     
     end
     end




  end
 
  

  #(CLK_PERIOD/2);
  pmem_add = 0;
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  

  if(mode == FOUR_B_FOUR_B) begin

  for(j=0;j<total_cycle;j=j+1) begin

  
  pmem_rd = 1'b1;
  #(CLK_PERIOD/2);

  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  
  norm_wr = 1'b1;
  pmem_rd = 1'b0;


  for(i=0; i<col; i=i+1) begin
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  end

  norm_wr = 1'b0;
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  
  for(i=0;i<total_cycle;i=i+1) begin
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);  
  end


  for(i=0; i<total_cycle; i=i+1) begin

  div = 1'b1;

  //if(i>0)
  //norm_mem_add = norm_mem_add + 1'b1;

  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  div = 1'b0;
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  end


  //norm_mem_add = norm_mem_add + 1'b1;
  
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);

  norm_mem_wr = 1'b1;
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  norm_mem_wr = 1'b0;
  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  
  pmem_add = pmem_add + 1'b1;
  norm_mem_add = norm_mem_add + 1'b1;

  end

  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  norm_mem_add = 0;

  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);

  for(i=0; i<total_cycle; i=i+1) begin
  
  norm_mem_rd = 1'b1;

  if(i>0)
  norm_mem_add = norm_mem_add + 1'b1;

  #(CLK_PERIOD/2);
  #(CLK_PERIOD/2);
  
     if(i>1) begin
     for (q=0; q<col; q=q+1) begin
         temp5b = result[i-2][q];
         temp16b = {temp16b, temp5b};
         if(result[i-2][q] >= 0)  
	         sum1[i-2] = sum1[i-2] +result[i-2][q]; // temporary
         else if(result[i-2][q] < 0)  
	         sum1[i-2] = sum1[i-2] - result[i-2][q];
     

         temp5b2 = result2[i-2][q];
         temp16b2 = {temp16b2, temp5b2};
         if(result2[i-2][q] >= 0)  
	         sum2[i-2] = sum2[i-2] +result2[i-2][q]; // temporary
         else if(result2[i-2][q] < 0)  
	         sum2[i-2] = sum2[i-2] - result2[i-2][q];
     end


     norm16b = 0;
     norm16b2= 0;

     for (q=0; q<(col-gate_col); q=q+1) begin
         norm5b = result[i-2][q]*256/ (sum1[i-2]+sum2[i-2]);
         //$display("prd @cycle%2d: , result[i][q]:%40h  and  norm_5b: %40h and sum: %40h ",i, result[i][q] ,norm5b, sum1[i]);
         norm16b = {norm16b, norm5b[2*bw_psum-1:0]};

         norm5b2 = result2[i-2][q]*256/ (sum1[i-2]+sum2[i-2]);
         norm16b2 = {norm16b2, norm5b2[2*bw_psum-1:0]};
     end

 
     if(!(pmem_out1 === norm16b))
     begin
       error = error + 1;
       $display("prd @cycle%2d: %40h and norm_mem_out: %40h do not match", i, norm16b, pmem_out1);
     end
     else
     begin
       $display("prd @cycle%2d: %40h and norm_mem_out: %40h match", i, norm16b, pmem_out1);
     end     

     if(!(pmem_out2 === norm16b2))
     begin
       error = error + 1;
       $display("prd @cycle%2d: %40h and norm_mem_out: %40h do not match", i, norm16b2, pmem_out2);
     end
     else
     begin
       $display("prd @cycle%2d: %40h and norm_mem_out: %40h match", i, norm16b2, pmem_out2);
     end     

     end

  end

  end

  if(error === 0)
    $display("Test case pased :D with %2d errors ",error);
  else 
    $display("Test case failed :( with %2d errors ",error);
  #10 $finish;


end

endmodule




