#-------------------------------------------------------------------------------
# Title       : synthesis settings for 16z091-01 on CycloneV
# Project     : 
#-------------------------------------------------------------------------------
# File        : z91_01_syn_con.tcl
# Author      : Thomas Wickleder
# Email       : Thomas.Wickleder@men.de
# Organization: MEN Mikroelektronik Nuernberg GmbH
# Created     : 19/04/11
#-------------------------------------------------------------------------------
# Simulator   : -
# Synthesis   : -
#-------------------------------------------------------------------------------
# Description :
# Created by Thomas Wickleder for G215,
# adapted by Susanne Reinfelder for 16z091-01
#-------------------------------------------------------------------------------
# Hierarchy   :
# none
#-------------------------------------------------------------------------------
# Copyright (C) 2011, MEN Mikroelektronik Nuernberg GmbH
#
# All rights reserved. Reproduction in whole or part is 
# prohibited without the written permission of the 
# copyright owner.
#-------------------------------------------------------------------------------
set_global_assignment -name VHDL_FILE "../16z000-00_src/Source/fpga_pkg_2.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/src_utils_pkg.vhd"

set_global_assignment -name VERILOG_FILE "../16z091-01_src/Source/x1/ip_compiler_for_pci_express-library/pciexp_dcram.v"
set_global_assignment -name VERILOG_FILE "../16z091-01_src/Source/x1/ip_compiler_for_pci_express-library/altpcie_rs_serdes.v"
set_global_assignment -name VERILOG_FILE "../16z091-01_src/Source/x1/ip_compiler_for_pci_express-library/altpcie_hip_pipen1b.v"

set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/alt_reconf.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/x1/Hard_IP_x1_serdes.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/x1/Hard_IP_x1_core.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/x1/Hard_IP_x1.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/z091_01_wb_slave.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/z091_01_wb_master.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/tx_put_data.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/tx_header_fifo.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/tx_data_fifo.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/tx_compl_timeout.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/tx_ctrl.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/tx_module.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/rx_len_cntr.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/rx_fifo.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/rx_get_data.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/rx_ctrl.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/rx_module.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/interrupt_wb.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/interrupt_core.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/init.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/err_fifo.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/error.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/ip_16z091_01.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/ip_16z091_01_top.vhd"

set_global_assignment -name VHDL_FILE ../Source/z091_01_wb_adr_dec.vhd
