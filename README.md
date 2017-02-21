# A25_VME
FPGA source and synthesis files for PCIe to VME interface

Contents of this repository:
16t001-00_bin: Tool for building the chameleon table for the FPGA which is used by the drivers to locate the FPGA functions
16t029-00_bin: Tool to convert programming files from bin to hex format
16t032-00_bin: Tool to convert programming files to formate used by Dediprog programmer
16t033-00_src: Script to manage programming file generation during synthesis run
16t036-00_src: Tool to add an header description to the .bin programming file
16z000-00_src: VHDL package for technology definitions
16z002-01_src: VHDL source for Wishbone to VME bus interface
16z024-01_src: VHDL source for FPGA internal ROM (used for chameleon table)
16z091-01_src: VHDL source for Altera PCIe core to Wisbhone interface
16z126-01_src: VHDL source for serial flash remote update
Source:        Main VHDL sources for A25 FPGA
               Hierarchy of the source code:
               A25_top.vhd
                  |- 16z024-01
                  |- 16z091-01
                  |- 16z002-01
                  |- 16z126-01
                  |- wb_bus.vhd
                  |- sram.vhd
                  |- pll_pcie.vhd
               chameleon_V2.xls : Defines contents of the chameleon table
               cham2.bat : Script to generate from chameleon_v2.xls a chameleon.hex file which gets used within 16z024-01 ROM
                  
Synthesis:     Altera Quartus synthesis files
               Important files:
               A25_top.qpf - Quartus project file
               A25_top.qsf - Constraints file
               A25_top.sdc - Timing contraints file
               gen_programming_files.tcl - adopted script to manage programming file generation during synthesis run
               fpga_files - Folder with programming files

How to generate a new programming file:
1) Edit chameleon_V2.xls in order to set new revision (Page "Content", minor revision in C8, major revision in C7) and close xls
2) call cham2.bat for hex file generation
3) Edit Synthesis/gen_programming_files.tcl and change programming file name to new revision in variable PROJECT_RELEASE_NAM "16A025-00_MM_mm"
3) open A25_top.qpf in Quartus 15.1 
4) Run synthesis: if successful, new files with name 16A025-00_MM_mm will be generated in Synthesis/fpga_files

