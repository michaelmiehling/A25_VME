The 16t033-00 (gen_programming_files.tcl) is a TCL script file for Altera FPGAs to create all need programming Files.
The following files are generated from the TCL script and from Quartus:

   *.rbf   -> Raw binary file (compressed)

   *.bin   -> Raw binary file with MEN Header (compressed)

   *.dedi  -> Dediprog file (= *.rbf + *.bin)

   *.hex   -> Intel HEX format file (= *.bin)

   *.sof   -> Altera nonvolatile FPGA programming file

   *.jic   -> Altera Flash FPGA programming file (depends on *.cof)

   *.jam   -> STAPL format file (depends on *.cdf)
   
The fileset HWARE\16\16t032-00\16t032-00_bin and HWARE\16\16t029-00\16t029-00_bin should be also checked out when using the 16t033-00.
This file is only a template and shall be copied to the Synthesis Folder. The Script file must be added to the *.qsf file
with the global assignment:

   set_global_assignment -name POST_MODULE_SCRIPT_FILE "quartus_sh:gen_programming_files.tcl"

NOTE:

jam file generation
--------------------
 quartus generates this file automatically from the *.cdf file
 go to Quartus -> Assignments -> Device -> Device and Pin Options... -> Programming files and enable JEDEC STAPL Format File (.jam)

rbf file generation
---------------------
 quartus generates this file automatically from the *.sof file
 go to Quartus -> Assignments -> Device -> Device and Pin Options... -> Programming files and enable Raw Binary File (.rbf)

---------------------------------------------
Dummy hex (dummy.hex):
---------------------------------------------
The dummy.hex file shall be used to generated the *.cof file when there is no *.hex file already.
-> Rename the dummy.hex into {PROJECT_FILE_NAME}.hex and move it to PROJECT_QUARTUS_PROG_DIR
Then you can create a *.cof and start a syntheses which replaces the dummy.hex file with the correct generated file.

---------------------------------------------
The following variables must be adjusted:
---------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------
!!! => all paths are relative to the synthesis folder (for example "D:\work_16g216c01\HWARE\Artikel\16\16g216c01\ic001a\synthesis") <= !!!
------------------------------------------------------------------------------------------------------------------------------------------
   
   Path to Synthesis Folder (= Path to *.rbf):
      variable PROJECT_SYNTHESIS       "./"
      
   Name of the project (= Top File name):
      variable PROJECT_FILE_NAME       "g215_top"
      
   Name of the project revision (programming filename):
      variable PROJECT_RELEASE_NAME    "16G215-ff_00_01"
      
   Path to Folder were all programming files shall be stored:
      variable PROJECT_RELEASE_FOLDER  "./fpga_files/"
      
   Folder of the Quartus automatically generated programming files relative to the PROJECT_SYNTHESIS.
   For quartus version < 14.0 the programming files are always in the synthesis folder variable PROJECT_QUARTUS_PROG_DIR  "./"
   For quartus version >= 14.0 the default path is variable PROJECT_QUARTUS_PROG_DIR   "./output_files"
      variable PROJECT_QUARTUS_PROG_DIR   "./output_files"
      
   Path to the ALTERA "Conversion Setup File":
      variable COF_FILE_NAME           "g215_top.cof"
      
      NOTE: the *.cof file can be generate with Quartus in menu -> File/Convert Programming Files...
         A *.cof file is need because quartus_cpf does not offere a console input for complex designs.
         Use the generated *.hex file for the FPGA Image with the MEN Header in Convert Programming File
         tool. For the FPGA Fallback Image the *.sof file shall be used (do not forget to enable the compression).
         An example of a *.cof file can be found in HWARE/16/16g216c01/ic001a/synthesis/g216c01_top.cof.
         
   Name of the hardware board on with the FPGA is assembled:
      variable HWARE_BOARD_NAME        "02G215-04"
      
   Name of the FPGA Device:
      variable DEVICE                  "EP4CGX30"
   Name of the used Flash Device:
      variable FLASH                   "EPCS64"
      
   Offset address of FPGA Image in hexadecimal:
      variable FPGA_IMAGE_OFFSET       200000
      
   Size of the used Flash Device in bytes and hexadecimal:
      variable FLASH_SIZE_IN_BYTE_HEX  800000
      
   Path to the ALTERA Program "Convert Programming File":
      variable ALTERA_QUARTUS_CPF      "$::env(QUARTUS_ROOTDIR)bin64/quartus_cpf.exe"
      
   Path to the 16t029-00 "bin2ihex.exe":
      variable BIN2IHEX                "../../../16t029-00/Bin/release/bin2ihex.exe"
      
   Path to the 16t032-00 "genDediprog.exe":
      variable GENDEDIPROG             "../../../16t032-00/Bin/release/genDediprog.exe"
      
   Path to the fpga_addheader.exe:
      variable FPGA_ADDHEADER          "../../../../../../NT/OBJ/EXE/MEN/I386/CHECKED/fpga_addheader.exe"


