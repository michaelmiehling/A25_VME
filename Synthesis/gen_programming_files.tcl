##############################################################-
## File          : gen_programming_files.tcl
## Author        : Andreas Geissler
## Email         : Andreas.Geissler@men.de
## Organization  : MEN Mikroelektronik Nuernberg GmbH
## Created       : 05/12/14
##############################################################-
## Description : This TCL script shall be used to generate
## all importen programming files for a Altera FPGA:
##
## *.rbf   -> Raw binary file (compressed)
## *.bin   -> Raw binary file with MEN Header (compressed)
## *.dedi  -> Dediprog file (= *.rbf + *.bin)
## *.hex   -> Intel HEX format file (= *.bin)
## *.sof   -> Altera nonvolatile FPGA programming file
## *.jic   -> Altera Flash FPGA programming file (depends on *.cof)
## *.jam   -> STAPL format file (depends on *.jic)
##
##############################################################-
## Copyright (C) 2014, MEN Mikroelektronik Nuernberg GmbH
##
##   All rights reserved. Reproduction in whole or part is 
##      prohibited without the written permission of the 
##                    copyright owner.
##############################################################-
set module [lindex $quartus(args) 0]

# all paths are relative to the synthesis folder (for example "D:\work_16g216c01\HWARE\Artikel\16\16g216c01\ic001a\synthesis")

# project files and directories
#Path of the synthesis folder
variable PROJECT_SYNTHESIS          "./"
#Name of the quartus project
variable PROJECT_FILE_NAME          "A25_top"
#Name of the programming files which are generated
variable PROJECT_RELEASE_NAME       "16A025-00_02_04"
#Folder of the programming files which are generated
variable PROJECT_RELEASE_FOLDER     "./fpga_files/"
#Folder of the Quartus automatically generated programming files relative to the PROJECT_SYNTHESIS
#For quartus version < 14.0 the programming files are always in the synthesis folder
variable PROJECT_QUARTUS_PROG_DIR  "./"
#For quartus version >= 14.0 the default path is "./output_files/"
#variable PROJECT_QUARTUS_PROG_DIR   "./output_files/"
#Name of the converstion file to generate *.jic
variable COF_FILE_NAME              "A25_top.cof"

# NOTE: the *.cof file can be generate with Quartus in menu -> File/Convert Programming Files...
#       A *.cof file is need because quartus_cpf does not offere a console input for complex designs.
#       Use the generated *.hex file for the FPGA Image with the MEN Header in Convert Programming File
#       tool. For the FPGA Fallback Image the *.sof file shall be used (do not forget to enable the compression).

# project configurations
variable HWARE_BOARD_NAME        "16A025-00"
variable DEVICE                  "EP4CGX30"
variable FLASH                   "EPCS32"
variable FPGA_IMAGE_OFFSET       200000
#8MByte Flash
variable FLASH_SIZE_IN_BYTE_HEX  800000


# program paths for Windows synthesis
# variable BIN2IHEX                "../16t029-00_src/Bin/bin2ihex.exe"
# variable GENDEDIPROG             "../16t032-00_src/Bin/genDediprog.exe"
#variable ALTERA_QUARTUS_CPF      "$::env(QUARTUS_ROOTDIR)bin64/quartus_cpf.exe"
#variable FPGA_ADDHEADER          "../16t036-00_src/Bin/fpga_addheader.exe"

# program paths for Linux synthesis
variable BIN2IHEX                "../16t029-00_src/Bin/bin2ihex"
variable GENDEDIPROG             "../16t032-00_src/Bin/genDediProg"
variable ALTERA_QUARTUS_CPF      "$::env(QUARTUS_ROOTDIR)bin/quartus_cpf"
variable FPGA_ADDHEADER          "../16t036-00_src/Bin/fpga_addheader"

if [string match "quartus_asm" $module] {
 
    # include commands here that are run after the assember
   post_message "+--------------------------------------------------------------+"
   post_message "| Running after assembler..."
   post_message "| now generating ${PROJECT_RELEASE_NAME}.jic automatically"
   post_message "+--------------------------------------------------------------+"
   
   # command run after the assember
   post_message "Used QUARTUS:         $::env(QUARTUS_ROOTDIR)"
   post_message "Used quartus_cpf:     ${ALTERA_QUARTUS_CPF}"
   post_message "Used bin2ihex:        ${BIN2IHEX}"
   post_message "Used genDediprog:     ${GENDEDIPROG}"
   post_message "Used fpga_addheader:  ${FPGA_ADDHEADER}"
   
   # delete existing files
   #--------------------------------------------
   # delete *.jic file
   if {[file exists ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.jic]} {
      post_message "Delete existing ${PROJECT_QUARTUS_PROG_DIR}$PROJECT_FILE_NAME.jic"
      file delete ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.jic
   }
   # delete *.jam file
   if {[file exists ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.jam]} {
      post_message "Delete existing ${PROJECT_QUARTUS_PROG_DIR}$PROJECT_FILE_NAME.jam"
      file delete ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.jam
   }
   # delete Intel HEX file *.hex
   if {[file exists ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.hex]} {
      post_message "Delete existing ${PROJECT_QUARTUS_PROG_DIR}$PROJECT_FILE_NAME.hex"
      file delete ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.hex
   }
   # delete binary file with MEN Header *.bin
   if {[file exists ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.bin]} {
      post_message "Delete existing ${PROJECT_QUARTUS_PROG_DIR}$PROJECT_FILE_NAME.bin"
      file delete ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.bin
   }
   # delete binary file with MEN Header *.dedi
   if {[file exists ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.dedi]} {
      post_message "Delete existing ${PROJECT_QUARTUS_PROG_DIR}$PROJECT_FILE_NAME.dedi"
      file delete ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.dedi
   }
   
   # create folders
   #--------------------------------------------
   # create release folder if it not exist
   if {![file exists ${PROJECT_RELEASE_FOLDER}]} {
      post_message "Create $PROJECT_RELEASE_FOLDER"
      file mkdir ${PROJECT_RELEASE_FOLDER}
   }
   
   post_message "+-------------------------------+"
   post_message "| Generate programming files:"
   post_message "+-------------------------------+"
   
   # bin file generation
   #----------------------------------------------------------
   post_message "Generate *.bin: "
   post_message "----------------"
   
   if { [catch {exec ${FPGA_ADDHEADER} -l ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.rbf ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.bin ${DEVICE} ${HWARE_BOARD_NAME} ${FPGA_IMAGE_OFFSET}} input] } {
      return -code error $input
   } else {
      post_message $input
   }
   
   # hex file generation
   #----------------------------------------------------------
   post_message "Generate *.hex: "
   post_message "----------------"
   
   if { [catch {exec ${BIN2IHEX} -s -b ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.bin ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.hex} input] } {
      return -code error $input
   } else {
      post_message $input
   }
   
   # Dediprog file generation
   #----------------------------------------------------------
   post_message "Generate *.dedi: "
   post_message "-----------------"
   
   if { [catch {exec ${GENDEDIPROG} -s -x=0xFF -o=0x${FPGA_IMAGE_OFFSET} -f=0x${FLASH_SIZE_IN_BYTE_HEX} ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.rbf ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.bin ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.dedi} input] } {
      return -code error $input
   } else {
      post_message $input
   }
   
   # jic file generation
   #----------------------------------------------------------
   post_message "Generate *.jic: "
   post_message "----------------"
   
   if { [catch {exec ${ALTERA_QUARTUS_CPF} -c ${PROJECT_SYNTHESIS}${COF_FILE_NAME}} input] } {
      return -code error $input
   } else {
      post_message $input
   }
   
   # jam file generation
   #----------------------------------------------------------
   post_message "Generate *.jam: "
   post_message "----------------"
   
   if { [catch {exec ${ALTERA_QUARTUS_CPF} -c ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.jic ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.jam} input] } {
      return -code error $input
   } else {
      post_message $input
   }
   
   # rbf file generation
   #----------------------------------------------------------
   # quartus generates this file automatically from the *.sof file
   # go to Quartus -> Assignments -> Device -> Device and Pin Options... -> Programming files and enable Raw Binary File (.rbf)
   
   post_message "Copy programming files from Quartus synthesis: "
   post_message "-----------------------------------------------"
   file copy -force ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.rbf  ${PROJECT_RELEASE_FOLDER}${PROJECT_RELEASE_NAME}.rbf
   file copy -force ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.bin  ${PROJECT_RELEASE_FOLDER}${PROJECT_RELEASE_NAME}.bin
   file copy -force ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.dedi ${PROJECT_RELEASE_FOLDER}${PROJECT_RELEASE_NAME}.dedi
   file copy -force ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.hex  ${PROJECT_RELEASE_FOLDER}${PROJECT_RELEASE_NAME}.hex
   file copy -force ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.sof  ${PROJECT_RELEASE_FOLDER}${PROJECT_RELEASE_NAME}.sof
   file copy -force ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.jic  ${PROJECT_RELEASE_FOLDER}${PROJECT_RELEASE_NAME}.jic
   file copy -force ${PROJECT_QUARTUS_PROG_DIR}${PROJECT_FILE_NAME}.jam  ${PROJECT_RELEASE_FOLDER}${PROJECT_RELEASE_NAME}.jam
   
}
