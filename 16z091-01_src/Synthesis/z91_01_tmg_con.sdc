#-------------------------------------------------------------------------------
# Title       : 16z091-01 timing constraints
# Project     : MAIN
#-------------------------------------------------------------------------------
# File        : z91_01_tmg_con.sdc
# Author      : Thomas Wickleder
# Email       : Thomas.Wickleder@men.de
# Organization: MEN Mikro Elektronik Nuremberg GmbH
# Created     : 2011-04-19
#-------------------------------------------------------------------------------
# Simulator   : 
#-------------------------------------------------------------------------------
# Description : 
# Timing constraints for Cyclone IV. Created by Thomas Wickleder for G215, 
# adapted by Susanne Reinfelder for 16z091-01.
#-------------------------------------------------------------------------------
# Hierarchy   : 
#-------------------------------------------------------------------------------
# Copyright (C) 2011, MEN Mikro Elektronik Nuremberg GmbH
# 
# All rights reserved. Reproduction in whole or part is
# prohibited without the written permission of the
# copyright owner.
#-------------------------------------------------------------------------------

create_clock -name pcie_clk     -period 10.000 -waveform {0.000 5.000} [get_ports {pcie_clk}]
create_clock -name pcie_sys_clk -period 8.000 -waveform {0 4} [get_nets {*altpcie_hip_pipen1b_inst|core_clk_out}] -add

set_false_path -from [get_clocks {pcie_sys_clk}] -to [get_clocks {clk_wb}]
set_false_path -from [get_clocks {clk_wb}] -to [get_clocks {pcie_sys_clk}]

set_false_path -from * -to [get_keepers {*~OBSERVABLEDPRIODISABLE*}]
set_false_path -from * -to [get_keepers {*~OBSERVABLEDPRIOLOAD*}]
set_false_path -from * -to [get_keepers {*~OBSERVABLERXANALOGRESET*}]
set_false_path -from * -to [get_keepers {*~OBSERVABLERXDIGITALRESET*}]
set_false_path -from * -to [get_keepers {*~OBSERVABLETXDIGITALRESET*}]
set_false_path -from * -to [get_keepers {*~OBSERVABLE_DIGITAL_RESET*}]
