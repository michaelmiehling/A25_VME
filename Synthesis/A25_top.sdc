## Generated SDC file "A21_top.out.sdc"

## Copyright (C) 1991-2011 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 11.1 Build 173 11/01/2011 SJ Full Version"

## DATE    "Mon Jul 23 13:48:47 2012"

##
## DEVICE  "EP4CGX30CF23I7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk_16mhz} -period 62.500 -waveform { 0.000 31.250 } [get_ports {clk_16mhz}]
create_clock -name {refclk} -period 10.000 -waveform { 0.000 5.000 } [get_ports {refclk}]



#**************************************************************
# Create Generated Clock
#**************************************************************
#derive_pll_clocks
create_generated_clock -name {clk_125} -source [get_ports {clk_16mhz}] -duty_cycle 50.000 -multiply_by 125 -divide_by 16 -master_clock {clk_16mhz} [get_pins {pll|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {clk_50} -source [get_ports {clk_16mhz}] -duty_cycle 50.000 -multiply_by 25 -divide_by 8 -master_clock {clk_16mhz} [get_pins {pll|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {sys_clk} -source [get_ports {clk_16mhz}] -duty_cycle 50.000 -multiply_by 25 -divide_by 6 -master_clock {clk_16mhz} [get_pins {pll|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {clk_33} -source [get_ports {clk_16mhz}] -duty_cycle 50.000 -multiply_by 25 -divide_by 12 -master_clock {clk_16mhz} [get_pins {pll|altpll_component|auto_generated|pll1|clk[4]}] 
#create_generated_clock -name {sr_clk_int} -source [get_ports {clk_16mhz}] -duty_cycle 50.000 -multiply_by 25 -divide_by 6 -phase -50 -master_clock {clk_16mhz} [get_ports {sr_clk}] 

create_generated_clock -source [get_pins {pll|altpll_component|auto_generated|pll1|clk[3]}] -duty_cycle 50.000 -multiply_by 25 -divide_by 6 -phase 0 -name sr_clk_ext [get_ports {sr_clk}]

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty
#set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020 
#set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020 
#set_clock_uncertainty -rise_from [get_clocks {clk_16mhz}] -rise_to [get_clocks {clk_16mhz}]  0.020 
#set_clock_uncertainty -rise_from [get_clocks {clk_16mhz}] -fall_to [get_clocks {clk_16mhz}]  0.020 
#set_clock_uncertainty -rise_from [get_clocks {pcie_sys_clk}] -rise_to [get_clocks {pcie_sys_clk}]  0.020 
#set_clock_uncertainty -rise_from [get_clocks {pcie_sys_clk}] -fall_to [get_clocks {pcie_sys_clk}]  0.020 
#set_clock_uncertainty -rise_from [get_clocks {clk_125}] -rise_to [get_clocks {clk_125}]  0.020 
#set_clock_uncertainty -rise_from [get_clocks {clk_125}] -fall_to [get_clocks {clk_125}]  0.020 
#set_clock_uncertainty -rise_from [get_clocks {clk_50}] -rise_to [get_clocks {clk_50}]  0.020 
#set_clock_uncertainty -rise_from [get_clocks {clk_50}] -fall_to [get_clocks {clk_50}]  0.020 
#set_clock_uncertainty -rise_from [get_clocks {sys_clk}] -rise_to [get_clocks {sys_clk}]  0.020 
#set_clock_uncertainty -rise_from [get_clocks {sys_clk}] -fall_to [get_clocks {sys_clk}]  0.020 
#set_clock_uncertainty -rise_from [get_clocks {clk_33}] -rise_to [get_clocks {clk_33}]  0.020 
#set_clock_uncertainty -rise_from [get_clocks {clk_33}] -fall_to [get_clocks {clk_33}]  0.020 


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  10.000 [get_ports {fpga_test*}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {fpga_test*}]
set_input_delay -add_delay -max -clock sr_clk_ext  8.500 [get_ports {sr_d[*}]
set_input_delay -add_delay -min -clock sr_clk_ext  3.100 [get_ports {sr_d[*}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_a[*}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_a[*}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_acfail_i_n}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_acfail_i_n}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_am[*}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_am[*}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_as_i_n}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_as_i_n}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_bbsy_i_n}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_bbsy_i_n}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_bclr_i_n}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_bclr_i_n}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_berr_i_n}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_berr_i_n}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_bg_i_n*}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_bg_i_n*}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_br_i_n*}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_br_i_n*}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_d[*}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_d[*}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_ds_i_n*}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_ds_i_n*}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_dtack_i_n}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_dtack_i_n}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_iack_i_n}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_iack_i_n}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_iack_n}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_iack_n}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_irq_i_n*}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_irq_i_n*}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_retry_i_n}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_retry_i_n}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_sysfail_i_n}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_sysfail_i_n}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_sysres_i_n}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_sysres_i_n}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_write_n}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_write_n}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_ga[*}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_ga[*}]
set_input_delay -add_delay -max -clock [get_clocks {sys_clk}]  12.000 [get_ports {vme_gap}]
set_input_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_gap}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  1.000 [get_ports {fpga_test*}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {fpga_test*}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  2.000 [get_ports {led*}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {led*}]
set_output_delay -add_delay -max -clock sr_clk_ext  2.700 [get_ports {sr_a[*}]
set_output_delay -add_delay -min -clock sr_clk_ext  -0.200 [get_ports {sr_a[*}]
set_output_delay -add_delay -max -clock sr_clk_ext  2.700 [get_ports {sr_adsc_n}]
set_output_delay -add_delay -min -clock sr_clk_ext  -0.200 [get_ports {sr_adsc_n}]
set_output_delay -add_delay -max -clock sr_clk_ext  2.700 [get_ports {sr_bw_n}]
set_output_delay -add_delay -min -clock sr_clk_ext  -0.200 [get_ports {sr_bw_n}]
set_output_delay -add_delay -max -clock sr_clk_ext  2.700 [get_ports {sr_bwa_n}]
set_output_delay -add_delay -min -clock sr_clk_ext  -0.200 [get_ports {sr_bwa_n}]
set_output_delay -add_delay -max -clock sr_clk_ext  2.700 [get_ports {sr_bwb_n}]
set_output_delay -add_delay -min -clock sr_clk_ext  -0.200 [get_ports {sr_bwb_n}]
set_output_delay -add_delay -max -clock sr_clk_ext  2.700 [get_ports {sr_cs1_n}]
set_output_delay -add_delay -min -clock sr_clk_ext  -0.200 [get_ports {sr_cs1_n}]
set_output_delay -add_delay -max -clock sr_clk_ext  2.700 [get_ports {sr_d*}]
set_output_delay -add_delay -min -clock sr_clk_ext  -0.200 [get_ports {sr_d*}]
set_output_delay -add_delay -max -clock sr_clk_ext  2.700 [get_ports {sr_oe_n}]
set_output_delay -add_delay -min -clock sr_clk_ext  -0.200 [get_ports {sr_oe_n}]

set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  5.000 [get_ports {v2p_rstn}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {v2p_rstn}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_br_o*}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_br_o*}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_am[*}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_am[*}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_a[*}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_a[*}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_a_dir}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_a_dir}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_a_oe_n}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_a_oe_n}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_am_dir}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_am_dir}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_am_oe_n}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_am_oe_n}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_as_o_n}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_as_o_n}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_as_oe}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_as_oe}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_bbsy_o}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_bbsy_o}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_bclr_o_n}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_bclr_o_n}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_berr_o}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_berr_o}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_bg_o_n*}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_bg_o_n*}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_d[*}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_d[*}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_d_dir}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_d_dir}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_d_oe_n}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_d_oe_n}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_ds_o_n*}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_ds_o_n*}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_ds_oe}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_ds_oe}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_dtack_o}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_dtack_o}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_iack_n}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_iack_n}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_iack_o_n}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_iack_o_n}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_irq_o*}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_irq_o*}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_retry_o_n}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_retry_o_n}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_retry_oe}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_retry_oe}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_scon}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_scon}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_sysclk}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_sysclk}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_sysfail_o}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_sysfail_o}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_sysres_o}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_sysres_o}]
set_output_delay -add_delay -max -clock [get_clocks {sys_clk}]  4.000 [get_ports {vme_write_n}]
set_output_delay -add_delay -min -clock [get_clocks {sys_clk}]  0.000 [get_ports {vme_write_n}]


#**************************************************************
# Set Clock Groups
#**************************************************************

#set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
#set_clock_groups -asynchronous -group [get_clocks {clk_125}] 
#set_clock_groups -asynchronous -group [get_clocks {clk_50}] 
#set_clock_groups -asynchronous -group [get_clocks {sys_clk}] 
#set_clock_groups -asynchronous -group [get_clocks {sr_clk}] 
#set_clock_groups -asynchronous -group [get_clocks {clk_33}] 
#set_clock_groups -asynchronous -group [get_clocks {clk_16mhz}] 
#set_clock_groups -asynchronous -group [get_clocks {refclk}] 
#set_clock_groups -asynchronous -group [get_clocks {pcie_sys_clk}] 

set_clock_groups -exclusive -group {refclk} \
                            -group {clk_125} \
                            -group {clk_50} \
                            -group {sys_clk} \
                            -group {clk_33} \

#**************************************************************
# Set False Path
#**************************************************************
set_false_path -from [get_clocks {pcie_sys_clk}] -to [get_clocks {clk_125}]
set_false_path -from [get_clocks {clk_125}] -to [get_clocks {pcie_sys_clk}]
#set_false_path  -from  [get_clocks {clk_16mhz}]  -to  [get_clocks {altera_reserved_tck}]
set_false_path  -from  [get_clocks {clk_16mhz}]  -to  [get_clocks {refclk}]
set_false_path  -from  [get_clocks {clk_16mhz}]  -to  [get_clocks {pcie_sys_clk}]
set_false_path  -from  [get_clocks {sys_clk}]  -to  [get_clocks {pcie_sys_clk}]
set_false_path  -from  [get_clocks {pcie_sys_clk}]  -to  [get_clocks {sys_clk}]
#set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_re9:dffpipe18|dffe19a*}]
#set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_qe9:dffpipe14|dffe15a*}]
set_false_path -to [get_keepers {*fifo_ram*}]
set_false_path -to [get_keepers {*~OBSERVABLEDPRIODISABLE*}]
set_false_path -to [get_keepers {*~OBSERVABLEDPRIOLOAD*}]
set_false_path -to [get_keepers {*~OBSERVABLERXDIGITALRESET*}]
set_false_path -to [get_keepers {*~OBSERVABLETXDIGITALRESET*}]
set_false_path -to [get_keepers {*~OBSERVABLE_DIGITAL_RESET*}]
set_false_path -from [get_keepers {*~ALTERA_DATA0*}] 
set_false_path -to [get_keepers {*~ALTERA_DCLK*}]
set_false_path -to [get_keepers {*~ALTERA_SCE*}]
set_false_path -to [get_keepers {*~ALTERA_SDO*}]
set_false_path  -from  [get_clocks {clk_16mhz}]  -to  [get_ports {vme_sysclk}]
set_false_path -from [get_ports {hreset_n}] 
set_false_path -from [get_keepers {porst_n}] 


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************

set_max_delay -to [get_ports { ip_16z091_01_top:pcie|Hard_IP_x4:\gen_x4:Hard_IP_x4_comp|Hard_IP_x4_serdes:serdes|Hard_IP_x4_serdes_alt_c3gxb_41f8:Hard_IP_x4_serdes_alt_c3gxb_41f8_component|transmit_pcs0~OBSERVABLE_DIGITAL_RESET }] 20.000
set_max_delay -to [get_ports { ip_16z091_01_top:pcie|Hard_IP_x4:\gen_x4:Hard_IP_x4_comp|Hard_IP_x4_serdes:serdes|Hard_IP_x4_serdes_alt_c3gxb_41f8:Hard_IP_x4_serdes_alt_c3gxb_41f8_component|transmit_pcs0~OBSERVABLEQUADRESET }] 20.000
set_max_delay -to [get_ports { ip_16z091_01_top:pcie|Hard_IP_x4:\gen_x4:Hard_IP_x4_comp|Hard_IP_x4_serdes:serdes|Hard_IP_x4_serdes_alt_c3gxb_41f8:Hard_IP_x4_serdes_alt_c3gxb_41f8_component|receive_pcs0~OBSERVABLE_DIGITAL_RESET }] 20.000
set_max_delay -to [get_ports { ip_16z091_01_top:pcie|Hard_IP_x4:\gen_x4:Hard_IP_x4_comp|Hard_IP_x4_serdes:serdes|Hard_IP_x4_serdes_alt_c3gxb_41f8:Hard_IP_x4_serdes_alt_c3gxb_41f8_component|receive_pcs0~OBSERVABLEQUADRESET }] 20.000
set_max_delay -to [get_ports { ip_16z091_01_top:pcie|Hard_IP_x4:\gen_x4:Hard_IP_x4_comp|Hard_IP_x4_serdes:serdes|Hard_IP_x4_serdes_alt_c3gxb_41f8:Hard_IP_x4_serdes_alt_c3gxb_41f8_component|cent_unit0~OBSERVABLEDPRIODISABLE }] 20.000
set_max_delay -to [get_ports { ip_16z091_01_top:pcie|Hard_IP_x4:\gen_x4:Hard_IP_x4_comp|Hard_IP_x4_serdes:serdes|Hard_IP_x4_serdes_alt_c3gxb_41f8:Hard_IP_x4_serdes_alt_c3gxb_41f8_component|cent_unit0~OBSERVABLERXDIGITALRESET }] 20.000
set_max_delay -to [get_ports { ip_16z091_01_top:pcie|Hard_IP_x4:\gen_x4:Hard_IP_x4_comp|Hard_IP_x4_serdes:serdes|Hard_IP_x4_serdes_alt_c3gxb_41f8:Hard_IP_x4_serdes_alt_c3gxb_41f8_component|cent_unit0~OBSERVABLETXDIGITALRESET }] 20.000
set_max_delay -to [get_ports { ip_16z091_01_top:pcie|Hard_IP_x4:\gen_x4:Hard_IP_x4_comp|Hard_IP_x4_serdes:serdes|Hard_IP_x4_serdes_alt_c3gxb_41f8:Hard_IP_x4_serdes_alt_c3gxb_41f8_component|cent_unit0~OBSERVABLEDPRIOLOAD }] 20.000


#**************************************************************
# Set Minimum Delay
#**************************************************************

set_min_delay -to [get_ports { ip_16z091_01_top:pcie|Hard_IP_x4:\gen_x4:Hard_IP_x4_comp|Hard_IP_x4_serdes:serdes|Hard_IP_x4_serdes_alt_c3gxb_41f8:Hard_IP_x4_serdes_alt_c3gxb_41f8_component|transmit_pcs0~OBSERVABLE_DIGITAL_RESET }] 0.000
set_min_delay -to [get_ports { ip_16z091_01_top:pcie|Hard_IP_x4:\gen_x4:Hard_IP_x4_comp|Hard_IP_x4_serdes:serdes|Hard_IP_x4_serdes_alt_c3gxb_41f8:Hard_IP_x4_serdes_alt_c3gxb_41f8_component|transmit_pcs0~OBSERVABLEQUADRESET }] 0.000
set_min_delay -to [get_ports { ip_16z091_01_top:pcie|Hard_IP_x4:\gen_x4:Hard_IP_x4_comp|Hard_IP_x4_serdes:serdes|Hard_IP_x4_serdes_alt_c3gxb_41f8:Hard_IP_x4_serdes_alt_c3gxb_41f8_component|receive_pcs0~OBSERVABLE_DIGITAL_RESET }] 0.000
set_min_delay -to [get_ports { ip_16z091_01_top:pcie|Hard_IP_x4:\gen_x4:Hard_IP_x4_comp|Hard_IP_x4_serdes:serdes|Hard_IP_x4_serdes_alt_c3gxb_41f8:Hard_IP_x4_serdes_alt_c3gxb_41f8_component|receive_pcs0~OBSERVABLEQUADRESET }] 0.000
set_min_delay -to [get_ports { ip_16z091_01_top:pcie|Hard_IP_x4:\gen_x4:Hard_IP_x4_comp|Hard_IP_x4_serdes:serdes|Hard_IP_x4_serdes_alt_c3gxb_41f8:Hard_IP_x4_serdes_alt_c3gxb_41f8_component|cent_unit0~OBSERVABLEDPRIODISABLE }] 0.000
set_min_delay -to [get_ports { ip_16z091_01_top:pcie|Hard_IP_x4:\gen_x4:Hard_IP_x4_comp|Hard_IP_x4_serdes:serdes|Hard_IP_x4_serdes_alt_c3gxb_41f8:Hard_IP_x4_serdes_alt_c3gxb_41f8_component|cent_unit0~OBSERVABLERXDIGITALRESET }] 0.000
set_min_delay -to [get_ports { ip_16z091_01_top:pcie|Hard_IP_x4:\gen_x4:Hard_IP_x4_comp|Hard_IP_x4_serdes:serdes|Hard_IP_x4_serdes_alt_c3gxb_41f8:Hard_IP_x4_serdes_alt_c3gxb_41f8_component|cent_unit0~OBSERVABLETXDIGITALRESET }] 0.000
set_min_delay -to [get_ports { ip_16z091_01_top:pcie|Hard_IP_x4:\gen_x4:Hard_IP_x4_comp|Hard_IP_x4_serdes:serdes|Hard_IP_x4_serdes_alt_c3gxb_41f8:Hard_IP_x4_serdes_alt_c3gxb_41f8_component|cent_unit0~OBSERVABLEDPRIOLOAD }] 0.000


#**************************************************************
# Set Input Transition
#**************************************************************


#*******************************************************************************************************************************************
# set false path to signal tap instance
# will be ignored if signal tap is not included
#*******************************************************************************************************************************************
set_false_path -from *                    -to [get_registers sld*]
set_false_path -from [get_registers sld*] -to * 

