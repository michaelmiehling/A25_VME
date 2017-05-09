Programm        : bin2ihex.exe                           
Author          : Andreas Geissler                       
Email           : Andreas.Geissler@men.de                
Organization    : MEN Mikroelektronik Nuernberg GmbH     
Created         : 30/10/13                               
License         : GPLv3                                  
Current version : 1.2

Description : 
 This programm converts a file to intel hex format. The bytes 
 and the bits can be swapped. Any offset within the file can 
 be chosen as well as the maximum bytes which should be 
 converted. This intel hex file can be implemented in JIC 
 files and read from quartus software directly. 
Maximal file size = 2GByte.

Usage:
   bin2ihex.exe file_in file_out <options>

Options:
  -v               => tool version
  -h               => print this help
  -w               => print the address
  -s               => swap bits within a byte (e.g. 1000 0100 => 0010 0001)
  -b               => use big endian instead of little endian (swap bytes)
  -m=0xXXXXXXXX    => maximum bytes are converted (cut file)
                      Must be set with 0x<Hexdecimal>
  -o=0xXXXXXXXX    => offset address to the first byte of the input file, where
                      the conversion should be started.
                      Must be set with 0x<Hexdecimal>
Example:
  bin2ihex.exe -b test.bin test.hex


