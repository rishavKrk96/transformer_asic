module controller(clk,reset,start,k_load_done,,kmem_rd,qmem_rd,mac_load_b,exec,set,kmem_add,qmem_add,kmem_wr,qmem_wr,reset_array,ofifo_valid,ofifo_rd,pmem_add,num_inputs);

localparam IDLE = 5'b0001;
localparam MAC_ARR_RST_ASRT = 5'b00010;
localparam MAC_ARR_RST_DEASRT = 5'b00100;
localparam MAC_LOAD_B = 5'b01000;
localparam ARRAY_EXE = 5'b10000;

input clk;
input reset;
input start;
input k_load_done;
input [3:0] set;
input ofifo_valid;
input [4:0] num_inputs;

output reg exec;
output reg mac_load_b;
output reg qmem_rd;
output reg kmem_rd;
output reg [3:0] kmem_add;
output reg [3:0] qmem_add;
output reg kmem_wr;
output reg qmem_wr;
output reg reset_array;
output reg [3:0] pmem_add;
output ofifo_rd;



reg [4:0] next_state;
reg [4:0] current_state;

reg [4:0] inputs_counter;

reg count_set;
wire last_set;
wire exec_done;

assign last_set = (count_set == 0)? 1'b1:1'b0;

assign ofifo_rd = ofifo_valid;
assign exec_done = (inputs_counter == num_inputs)? 1'b1:1'b0;


always@(*)
begin
  case(current_state)
  IDLE                  : next_state = (start)? MAC_ARR_RST_ASRT:IDLE;
  MAC_ARR_RST_ASRT      : next_state = MAC_ARR_RST_DEASRT;
  MAC_ARR_RST_DEASRT    : next_state = MAC_LOAD_B;  
  MAC_LOAD_B            : next_state = (k_load_done)? ARRAY_EXE: MAC_LOAD_B;       
  ARRAY_EXE             : next_state = (exec_done)?((last_set)? IDLE: MAC_ARR_RST_ASRT):ARRAY_EXE;
  default               : next_state = current_state;
  endcase
end

always@(posedge clk)
begin
 if(reset)
   current_state <= IDLE;	 
 else
   current_state <= next_state;
end


always@(posedge clk)
begin
 if(reset)
 begin
   mac_load_b <= 1'b0;
   exec <= 1'b0;	
   qmem_rd <= 1'b0;
   kmem_rd <= 1'b0;
   qmem_add <= 4'b0;
   kmem_add <= 4'b0;
   reset_array <= 1'b0;
   kmem_wr <= 1'b0;
   qmem_wr <= 1'b0;
 end
 else
 begin
   case(next_state)
   IDLE                   : begin
	                    mac_load_b <= 1'b0;
                            exec <= 1'b0;
		            qmem_rd <= 1'b0;
		            kmem_rd <= 1'b0;
		            kmem_add <= 4'b0;
		            qmem_add <= 4'b0;
		            reset_array <= 1'b0;
	                    end
   MAC_ARR_RST_ASRT       : begin 
	                    reset_array <= 1'b1;
                            qmem_rd <= 1'b0;  
		            exec <= 1'b0;
		            end
   MAC_ARR_RST_DEASRT     : reset_array <= 1'b0;   
   MAC_LOAD_B             : begin
	                    mac_load_b <= 1'b1;
	                    kmem_rd <= mac_load_b;
	                    kmem_add <= (kmem_rd)? (kmem_add + 1'b1):4'b0;
		            reset_array <= 1'b0;
	                    end
   ARRAY_EXE              : begin
	                    mac_load_b <= 1'b0;
                            qmem_rd <= 1'b1;
			    exec <= 1'b1;
	                    qmem_add <= (qmem_rd)? qmem_add + 1'b1:4'b0;
	                    kmem_rd <= 1'b0;
	                    end
   endcase	   
 end
end

always@(posedge clk)
begin
  if(reset)
    count_set <= 4'b0;
  else
  begin
    count_set <= (current_state == ARRAY_EXE)? (count_set - 1'b1):((current_state == IDLE)? set : count_set);
  end
end	

always@(posedge clk)
begin
  if(reset)
    pmem_add <= 4'b0;
  else
  begin
    pmem_add <= (ofifo_rd)? (pmem_add + 1'b1):pmem_add;
  end
end

always@(posedge clk)
begin
  if(reset)
    inputs_counter <= 5'b0;
  else
  begin
    if(next_state == ARRAY_EXE)
      inputs_counter <= inputs_counter + 1'b1;
    else
      inputs_counter <= 5'b0;
  end
end

endmodule
