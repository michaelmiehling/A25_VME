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

create_generated_clock -name {pcie_clk1250} \
                       -source [get_ports {pcie_clk}] \
                       -divide_by 2 \
                       -multiply_by 25 \
                       -duty_cycle 50 \
                       -phase 0 \
                       {ip_16z091_01_top_i0|*|serdes|*_component|pll0|auto_generated|pll1|clk[0]}
create_generated_clock -name {pcie_clk250_1} \
                       -source [get_ports {pcie_clk}] \
                       -divide_by 2 \
                       -multiply_by 5 \
                       -duty_cycle 50 \
                       -phase 0 \
                       {ip_16z091_01_top_i0|*|serdes|*_component|pll0|auto_generated|pll1|clk[1]}
create_generated_clock -name {pcie_clk250_2} \
                       -source [get_ports {pcie_clk}] \
                       -divide_by 2 \
                       -multiply_by 5 \
                       -duty_cycle 20 \
                       -phase 0 \
                       {ip_16z091_01_top_i0|*|serdes|*_component|pll0|auto_generated|pll1|clk[2]}
create_generated_clock -name {pcie_icdrclk} \
                       -source [get_ports {pcie_clk}] \
                       -divide_by 2 \
                       -multiply_by 25 \
                       -duty_cycle 50 \
                       -phase 0 \
                       {ip_16z091_01_top_i0|*|serdes|*_component|pll0|auto_generated|pll1|icdrclk}
set_clock_groups -exclusive -group {pcie_clk} \
                            -group {pcie_clk1250} \
                            -group {pcie_clk250_1} \
                            -group {pcie_clk250_2} \
                            -group {pcie_icdrclk}

set_false_path -from [get_clocks {pcie_sys_clk}] -to [get_clocks {clk_wb}]
set_false_path -from [get_clocks {clk_wb}] -to [get_clocks {pcie_sys_clk}]

set_false_path -from * -to [get_keepers {*~OBSERVABLEDPRIODISABLE*}]
set_false_path -from * -to [get_keepers {*~OBSERVABLEDPRIOLOAD*}]
set_false_path -from * -to [get_keepers {*~OBSERVABLERXANALOGRESET*}]
set_false_path -from * -to [get_keepers {*~OBSERVABLERXDIGITALRESET*}]
set_false_path -from * -to [get_keepers {*~OBSERVABLETXDIGITALRESET*}]
set_false_path -from * -to [get_keepers {*~OBSERVABLE_DIGITAL_RESET*}]
