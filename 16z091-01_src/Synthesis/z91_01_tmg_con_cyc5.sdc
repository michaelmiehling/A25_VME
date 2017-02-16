##------------------------------------------------------------------------------
##  Title       : 
##  Project     : 
#-------------------------------------------------------------------------------
# Title       : sdc settings for 16z091-01 on CycloneV
# Project     : MAIN
#-------------------------------------------------------------------------------
# File        : z091_01_tmg_con_cyc5.sdc
# Author      : Susanne Reinfelder
# Email       : susanne.reinfelder@men.de
# Organization: MEN Mikro Elektronik Nuremberg GmbH
# Created     : 2014-12-03
#-------------------------------------------------------------------------------
# Simulator   : 
#-------------------------------------------------------------------------------
# Description : 
# Includes all timing constraints for CycloneV.
#-------------------------------------------------------------------------------
# Hierarchy   : 
# none
#-------------------------------------------------------------------------------
# Copyright (C) 2014, MEN Mikro Elektronik Nuremberg GmbH
# 
# All rights reserved. Reproduction in whole or part is
# prohibited without the written permission of the
# copyright owner.
#-------------------------------------------------------------------------------
set_time_format -unit ns -decimal_places 3

#--------------------
# create PCIe clock
#--------------------
create_clock -name pcie_clk -period 10.000 -waveform {0.000 5.000} [get_ports {pcie_clk}]

#----------------------------------
# derive all PLL clocks in design
#----------------------------------
derive_pll_clocks -create_base_clocks
derive_clock_uncertainty

#-----------------------------------------------------------------
# pcie_clk and coreclkout from hard IP must be in the same group
#-----------------------------------------------------------------
set_clock_groups -exclusive -group {pcie_clk [get_clocks {ip_16z091_01_top_i0|*|coreclkout}]}

set_false_path -from pcie_rst_n -to *

