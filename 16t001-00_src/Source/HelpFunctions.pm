################################################################################
#
# Author        : michael.ernst@men.de
# Organization  : MEN Mikro Elektronik GmbH
#
################################################################################
#
# Copyright (c) 2016, MEN Mikro Elektronik GmbH
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
################################################################################
#
# Description: This Package contains all helper functions for the main module
#							 
# Functional Description:
#
#
################################################################################
#
# History:
#
# $Revision: 1.2 $
#
# $Log: HelpFunctions.pm,v $
# Revision 1.2  2013/04/19 14:50:59  mernst
# R: 1. Offset generation may sometimes not be needed when generating an address decoder
#    2. Minor revision newly added to DSFI
#    3. TCL Integration in Quartus
#    4. Quartus outputs a warning if the chameleon.hex is not aligned to 2^n
#    5. Excel sometimes used erronous
#    6. New multichannel device 16z075-01 available
# M: 1. a) Offset Generation is now optional when generating an address decoder
#       b) Integrity check is now performed to ensure that the offsets are correctly assigned
#           - Checks address map overlappings
#           - Checks Bar size
#           - Checks Instance numberings
#    2. Added optional automatic minor revision increment
#    3. a) Write Excel is now always executed so the excel file revision is up to date
#       b) Fixed an Error in WriteExcel
#       c) Added options to set the major and minor revision by command line
#       d) Added option to manually set the used device_config.xml
#       e) Added support for quartus tcl script
#    4. Hex File size is now aligned to 2^n in size
#    5. Comments are now added to Excel to explain usage of each cell
#    6. Added multichannel device for 16z075-01
#       - Fixed HSSL definition
#       - Added Patterngenerator Definition
#
# Revision 1.1  2007/12/12 16:09:29  mernst
# Initial Revision
#
# Revision 1.2  2007/04/24 14:21:38  mErnst
# - Added error message in case xls file does not exist
# - Changed push_desc
# - Removed -p option
# - Added -a <type> option to generate wb/pci address decoder
#
# Revision 1.1  2006/04/25 11:48:13  mErnst
# Added automatic offset generation
# Added PCI Address Decoder generation
# Added PCI Wrapper Generation
# Added Configuration File
# Split up file into multiple modules for better handling
# Changed Data format to linked list
#
#
################################################################################

package HelpFunctions;
use base 'Exporter';
our @EXPORT = ('init_helpfunctions','createHex', 'createBits', 'createOffset', 'makeline', 'not_aligned');

use strict;
use POSIX;
use Descriptor;

my $debug;

sub init_helpfunctions{
   $debug = $_[0];
}

################################################################################
# createHex
################################################################################
# Description: returns the input value as 8 Byte Hex value
#
# Inputs     : Integer Number
#         
# Output     : String with 8 Hex numbers
#
# History    : /mE 06/03/03 Added to this module
################################################################################
sub createHex{
   my @tmp;            
   @tmp = split(//, unpack("H8", pack("i",$_[0]))."\n");
   return $tmp[6].$tmp[7].$tmp[4].$tmp[5].$tmp[2].$tmp[3].$tmp[0].$tmp[1];
}


################################################################################
# createBits
################################################################################
# Description: returns the input value as 32 Bit Bit Vector
#
# Inputs     : Integer Number
#         
# Output     : 32 Bit Bitvector as string
#
# History    : /mE 06/03/03 Added to this module
################################################################################
sub createBits{
   my $size = $_[0];
   my @sizebits;
   my @sizebytes;
   # Fill so all got 8 Hex Format
   while (length($size) < 8){
      $size = "0".$size;
   }
   @sizebytes = unpack("B8" x 4, pack("H8", $size));
   # split up bytes into bits
   foreach (@sizebytes)
   {
      push @sizebits, split(//, $_);         
   }
   @sizebits = reverse @sizebits; # to bring bit 0 to [0]
   
   return join "", @sizebits;
}



################################################################################
# createOffset
################################################################################
# Description: Create a new offset based on position and the descriptor
#              Logic will check if enough space is on current position, 
#              or if some more space is needed
#
# Inputs     : [0] Descriptor Object
#              [1] position
#         
# Output     : new position as integer
#
# History    : /mE 06/03/03 Added to this module
################################################################################
sub createOffset{
   my $descriptor = $_[0];
   my $position   = $_[1];
   
   if (hex($descriptor->getVar("size")) != 0)
      {
         
         if ($position % hex($descriptor->getVar("size")) == 0) # address is not uneven for module
         {
            print "adr ok - use as offset\n" if $debug == 1;
            $descriptor->addVar( "offset", createHex($position));
            print $descriptor->getVar("name")." ".$descriptor->getVar("size")." ".$descriptor->getVar("offset")."\n" if $debug == 1;
            $position = $position + hex($descriptor->getVar("size"));
         }
         else
         {
            print "adr not ok - creating new one\n" if $debug == 1;
            $position = (ceil($position / hex($descriptor->getVar("size")))) * hex($descriptor->getVar("size")) ;
            $descriptor->addVar( "offset", createHex($position));
            print $descriptor->getVar("name")." ".$descriptor->getVar("size")." ".$descriptor->getVar("offset")."\n" if $debug == 1;
            $position = $position + hex($descriptor->getVar("size"));
         }
    }
    else
    {
       print "Error: Size of Module is 0\n\n";
       $descriptor->showAll();
       exit;
    }
    return $position;
}

################################################################################
# makeline
################################################################################
# Description: makes a single line out of a byte array and appends the checksum
#
# Inputs     : Vector of input Bytes
#         
# Output     : hex file compatible Output line with checksum
#
# History    : /mE 06/03/03 Added to this module
################################################################################
sub makeline {
   my $chk = 0;
   my $line = ":";
   foreach(@_){
      $chk += hex($_);
      $line .= $_;
   }
   $chk = hex(unpack("H2", pack("i", $chk)));
   $chk = 0x100 - $chk;
   $line .= unpack("H2", pack("i", $chk));
   return $line }



sub not_aligned {
   my $adr = shift;
   for (my $i = 1; $i < 10; $i++) {
      if (2**$i == $adr) {
         return 0;  
      }
   }
   return 1;
}
 
1;