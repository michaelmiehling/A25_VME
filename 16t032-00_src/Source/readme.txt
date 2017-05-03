Programm        : genDediProg.exe                        
Author          : Andreas Geissler                       
Email           : Andreas.Geissler@men.de                
Organization    : MEN Mikroelektronik Nuernberg GmbH     
Created         : 23/10/14                               
License         : GPLv3                                  
Current version : 1.0

-------------------------------------------------------------------------
Copyright (c) 2016, MEN Mikro Elektronik GmbH

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------

Description : 
 This programm combines two binary files. The bytes
 and the bits can be swapped. The offset for the second input file
 can be chosen as well as the minimum file size in bytes which should be
 fill with filler(<x>). This program shall be used to generate program files
 for Dedi programmer
Maximal file size = 2GByte.

Usage:
   genDediprog.exe file1_in file2_in file_out <options>

Options:
  -v               => tool version
  -h               => print this help
  -s               => swap bits within a byte (e.g. 1000 0100 => 0010 0001)
  -x=0xXX          => configure filler for unused space in file
  -f=0xXXXXXXXX    => configure minimal file size. if it is less than the input
                   => files, the option will be ignored
                      Must be set with 0x<Hexdecimal>
  -o=0xXXXXXXXX    => offset address to the first byte of the input file, where
                      the conversion should be started.
                      Must be set with 0x<Hexdecimal>
Example:
  genDediprog.exe -x=0xFF -o=0x100000 test.rbf test.bin test.dedi
