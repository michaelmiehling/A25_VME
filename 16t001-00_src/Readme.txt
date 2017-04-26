+--------------------------+
| 16t001-00 chameleon tool |
+--------------------------+
General description:
Excel to Chameleon_V2 conversion tool


Use the create_exe.bat to create an executable from the perl script file. It will be generated in ../../16t001-00_bin/Bin.

Tool usage:
   Chameleon_V2.exe -i=infile [-c=<outfile>] [-v=<debug>] [-h] [-a=<type>] [-s] [-r=<minor_revision] [-R=<major_revision>] [-x=<device_config.xml>]

   -h          -> Show this message
   -i          -> Input Filename
   -c          -> Output file name (default: chameleon.hex)
   -a          -> Generate Address Decoder and
                  Automatically assign Offsets
                  wb  -> generate Wishbone address decoder
                  pci -> generate PCI address decoder
   -L          -> Generate Chameleon table as lookuptable
                  to save internal FPGA RAM
   -p          -> Update pci_header.hex
   -v          -> enable Debug Outputs for modules
                  0/1 switches debug
   -v=xxxxxxxx -> enable debug for module
      |||||||+--  Intergity Checks
      ||||||+---  Pciadr
      |||||+----  Textblocks
      ||||+-----  Input
      |||+------  Offset
      ||+-------  Helpfunctions
      |+--------  Descriptor
      +---------  Not used
   -x          -> Manual definition of device_config.xml
   -s          -> Increment minor revision
   -r          -> Set minor revision to be used
   -j          -> Set major revision to be used
   -d          -> put all files into same folder as the excel