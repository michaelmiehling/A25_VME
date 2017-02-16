#-------------------------------------------------------------------------------
# Title       : synthesis settings for 16z091-01 on CycloneV
# Project     : 
#-------------------------------------------------------------------------------
# File        : z091_01_syn_con_cyc5.tcl
# Author      : Susanne Reinfelder
# Email       : susanne.reinfelder@men.de
# Organization: MEN Mikro Elektronik Nuremberg GmbH
# Created     : 2014-12-03
#-------------------------------------------------------------------------------
# Simulator   : -
# Synthesis   : -
#-------------------------------------------------------------------------------
# Description :
# Includes all file references for CycloneV
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
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_rx
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_tx
set_instance_assignment -name IO_STANDARD HCSL -to pcie_clk

set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/CycV/PCIeHardIPCycV.vhd" -library PCIeHardIPCycV
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/CycV/CycVTransReconf.vhd" -library CycVTransReconf
set_global_assignment -name QIP_FILE "../16z091-01_src/Source/CycV/PCIeHardIPCycV.qip"
set_global_assignment -name QIP_FILE "../16z091-01_src/Source/CycV/CycVTransReconf.qip"
set_global_assignment -name VHDL_FILE "../16z000-00_src/Source/fpga_pkg_2.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/src_utils_pkg.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/rx_fifo.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/tx_data_fifo.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/tx_header_fifo.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/err_fifo.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/rx_len_cntr.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/rx_get_data.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/rx_ctrl.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/rx_module.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/z091_01_wb_master.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/error.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/tx_put_data.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/tx_compl_timeout.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/tx_ctrl.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/tx_module.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/init.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/z091_01_wb_slave.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/interrupt_core.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/interrupt_wb.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/pcie_msi.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/ip_16z091_01.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/z091_01_wb_adr_dec.vhd"
set_global_assignment -name VHDL_FILE "../16z091-01_src/Source/ip_16z091_01_top.vhd"
