
set clock_cycle 1 
set io_delay 0.2 

set clock_port1 clk1
set clock_port2 clk2

create_clock -name clk1 -period $clock_cycle [get_ports $clock_port1]
create_clock -name clk2 -period $clock_cycle [get_ports $clock_port2]

set_clock_groups -logically_exclusive -group [get_clocks clk1] -group [get_clocks clk2]


##set_input_delay  $io_delay -clock $clock_port1 [all_inputs] 
set_input_delay  $io_delay -clock $clock_port1 [get_ports mem_in1*] 
set_input_delay  $io_delay -clock $clock_port1 [get_ports inst1*] 
set_input_delay  $io_delay -clock $clock_port1 [get_ports reset1*] 
##set_output_delay $io_delay -clock $clock_port1 [all_outputs]
set_output_delay $io_delay -clock $clock_port1 [get_ports pmem_out1*]

##set_input_delay  $io_delay -clock $clock_port2 [all_inputs] 
set_input_delay  $io_delay -clock $clock_port2 [get_ports mem_in2*] 
set_input_delay  $io_delay -clock $clock_port2 [get_ports inst2*] 
set_input_delay  $io_delay -clock $clock_port2 [get_ports reset2*] 
##set_output_delay $io_delay -clock $clock_port2 [all_outputs]
set_output_delay $io_delay -clock $clock_port2 [get_ports pmem_out2*]

set_multicycle_path -setup 6 -from [get_pins core_instance_1/norm_instance/fifo_top_instance/fifo_instance/rd_ptr_reg[*]/clocked_on ] -to [get_pins core_instance_1/norm_instance/out_reg[*]/next_state ] 
set_multicycle_path -setup 6 -from [get_pins core_instance_1/sum_1_reg[*]/clocked_on ] -to [get_pins core_instance_1/norm_instance/out_reg[*]/next_state  ] 
set_multicycle_path -setup 6 -from [get_pins core_instance_1/sum_2_reg[*]/clocked_on ] -to [get_pins core_instance_1/norm_instance/out_reg[*]/next_state  ] 
set_multicycle_path -setup 6 -from [get_pins core_instance_1/norm_instance/fifo_top_instance/fifo_instance/q*_reg[*]/clocked_on ] -to [get_pins core_instance_1/norm_instance/out_reg[*]/next_state ] 


set_multicycle_path -setup 6 -from [get_pins core_instance_2/norm_instance/fifo_top_instance/fifo_instance/rd_ptr_reg[*]/clocked_on ] -to [get_pins core_instance_2/norm_instance/out_reg[*]/next_state ] 
set_multicycle_path -setup 6 -from [get_pins core_instance_2/sum_1_reg[*]/clocked_on ] -to [get_pins core_instance_2/norm_instance/out_reg[*]/next_state  ] 
set_multicycle_path -setup 6 -from [get_pins core_instance_2/sum_2_reg[*]/clocked_on ] -to [get_pins core_instance_2/norm_instance/out_reg[*]/next_state  ]  
set_multicycle_path -setup 6 -from [get_pins core_instance_2/norm_instance/fifo_top_instance/fifo_instance/q*_reg[*]/clocked_on ] -to [get_pins core_instance_2/norm_instance/out_reg[*]/next_state ] 

set_multicycle_path -hold 5 -from [get_pins core_instance_1/norm_instance/fifo_top_instance/fifo_instance/rd_ptr_reg[*]/clocked_on ] -to [get_pins core_instance_1/norm_instance/out_reg[*]/next_state ]
set_multicycle_path -hold 5 -from [get_pins core_instance_1/sum_1_reg[*]/clocked_on ] -to [get_pins core_instance_1/norm_instance/out_reg[*]/next_state  ] 
set_multicycle_path -hold 5 -from [get_pins core_instance_1/sum_2_reg[*]/clocked_on ] -to [get_pins core_instance_1/norm_instance/out_reg[*]/next_state  ] 
set_multicycle_path -hold 5 -from [get_pins core_instance_1/norm_instance/fifo_top_instance/fifo_instance/q*_reg[*]/clocked_on ] -to [get_pins core_instance_1/norm_instance/out_reg[*]/next_state ] 


set_multicycle_path -hold 5 -from [get_pins core_instance_2/norm_instance/fifo_top_instance/fifo_instance/rd_ptr_reg[*]/clocked_on ] -to [get_pins core_instance_2/norm_instance/out_reg[*]/next_state ] 
set_multicycle_path -hold 5 -from [get_pins core_instance_2/sum_1_reg[*]/clocked_on ] -to [get_pins core_instance_2/norm_instance/out_reg[*]/next_state  ] 
set_multicycle_path -hold 5 -from [get_pins core_instance_2/sum_2_reg[*]/clocked_on ] -to [get_pins core_instance_2/norm_instance/out_reg[*]/next_state  ] 
set_multicycle_path -hold 5 -from [get_pins core_instance_2/norm_instance/fifo_top_instance/fifo_instance/q*_reg[*]/clocked_on ] -to [get_pins core_instance_2/norm_instance/out_reg[*]/next_state ] 
