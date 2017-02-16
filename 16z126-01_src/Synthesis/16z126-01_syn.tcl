set_global_assignment -name STRATIXIII_UPDATE_MODE REMOTE

set_global_assignment -name RESERVE_DATA0_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_DATA1_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_FLASH_NCE_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_DCLK_AFTER_CONFIGURATION "USE AS REGULAR IO"

set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_wbmon.vhd"
set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_wb2pasmi.vhd"
set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_wb_pkg.vhd"
set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_wb_if_arbiter.vhd"
set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_top.vhd"
set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_pkg.vhd"
set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_indi_if_ctrl_regs.vhd"
set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_fifo_d1.vhd"
set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_clk_trans_wb2wb.vhd"
set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_switch_fab_2.vhd"

set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_pasmi/z126_01_pasmi_m25p32.vhd"
set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_pasmi/z126_01_pasmi_m25p64.vhd"
set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_pasmi/z126_01_pasmi_m25p128.vhd"

#For CYCLONE V
set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_ru_ctrl_cyc5.vhd"
#For CYCLONE V AND EPCS16
set_global_assignment -name QIP_FILE "../../../16z126-01/Source/z126_01_ru/z126_01_ru_cyclonev_m25p32/synthesis/z126_01_ru_cyclonev_m25p32.qip"
#For CYCLONE V AND EPCS64
set_global_assignment -name QIP_FILE "../../../16z126-01/Source/z126_01_ru/z126_01_ru_cyclonev_m25p64/synthesis/z126_01_ru_cyclonev_m25p64.qip"
#For CYCLONE V AND EPCS128
set_global_assignment -name QIP_FILE "../../../16z126-01/Source/z126_01_ru/z126_01_ru_cyclonev_m25p128/synthesis/z126_01_ru_cyclonev_m25p128.qip"

#For CYCLONE IV
set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_ru_ctrl_cyc.vhd"
set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_ru/z126_01_ru_cycloneiv.vhd.vhd"

#For CYCLONE III
set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_ru_ctrl_cyc.vhd"
set_global_assignment -name VHDL_FILE "../../../16z126-01/Source/z126_01_ru/z126_01_ru_cycloneiii.vhd.vhd"
