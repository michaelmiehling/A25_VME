#!/usr/bin/perl -w
################################################################################
#
# Author        : michael.ernst@men.de
# Organization  : MEN Mikro Elektronik GmbH
  my $date     = "07-10-02";
  my $version  = "1.0";
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
#                                    History
################################################################################
#  $Revision: 1.2 $
# 
#  $Log: WriteLut.pm,v $
#  Revision 1.2  2013/04/19 14:51:07  mernst
#  R: 1. Offset generation may sometimes not be needed when generating an address decoder
#     2. Minor revision newly added to DSFI
#     3. TCL Integration in Quartus
#     4. Quartus outputs a warning if the chameleon.hex is not aligned to 2^n
#     5. Excel sometimes used erronous
#     6. New multichannel device 16z075-01 available
#  M: 1. a) Offset Generation is now optional when generating an address decoder
#        b) Integrity check is now performed to ensure that the offsets are correctly assigned
#            - Checks address map overlappings
#            - Checks Bar size
#            - Checks Instance numberings
#     2. Added optional automatic minor revision increment
#     3. a) Write Excel is now always executed so the excel file revision is up to date
#        b) Fixed an Error in WriteExcel
#        c) Added options to set the major and minor revision by command line
#        d) Added option to manually set the used device_config.xml
#        e) Added support for quartus tcl script
#     4. Hex File size is now aligned to 2^n in size
#     5. Comments are now added to Excel to explain usage of each cell
#     6. Added multichannel device for 16z075-01
#        - Fixed HSSL definition
#        - Added Patterngenerator Definition
#
#  Revision 1.1  2007/12/12 16:09:35  mernst
#  Initial Revision
#
# 
#-------------------------------------------------------------------------------

package WriteLut;
use base 'Exporter';
our @EXPORT = ('generateLut');

use Descriptor;
use strict;
use HelpFunctions;
use POSIX;

our $DEBUG = 0;

sub generateLut{
   my @lines = @{shift()};
   
   
   print "\n";
   print "Generating Look-Up-Table\n";
   
   ##########
   # Compute the size of the Chameleon Table
   my $tablesize = 0;
   my $node = get_root();
   while (defined($node))
   {
      $tablesize += $node->getSize();
      
      $node = $node->{nxt};  
   }
   
   $tablesize += 4;                         # add 4, for end descriptor
   
   my $neededexp = 0;
   $neededexp++ while ($tablesize > 2**$neededexp);
   $tablesize = 2**$neededexp;
   
   print "Required chameleon size is $tablesize\n";  

   print "Starting to generate VHDL file\n";
   
   my $adrwidth = $neededexp - 1;
   print "Required address space: $adrwidth\n";
   
   my $rel_path = Descriptor->getContentVar("rel_path");
   open(OUTFILE, ">$rel_path/chameleon_lut.vhd") or die "Could not open output file for lookuptable";
   
   print OUTFILE
   "   LIBRARY ieee;
   USE ieee.std_logic_1164.ALL;
   
   ENTITY chameleon_lut IS
      GENERIC
      (
         USEDW_WIDTH : positive  := $neededexp;
         LOCATION    : string    := \"\"
      );
   
      PORT
      (
         address  : IN STD_LOGIC_VECTOR ($adrwidth DOWNTO 0);
         byteena  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
         clock    : IN STD_LOGIC ;
         data     : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
         wren     : IN STD_LOGIC ;
         q        : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
   	);   
   END ENTITY chameleon_lut;
   
   ARCHITECTURE chameleon_lut_arch OF chameleon_lut IS
   
      SIGNAL address_q : std_logic_vector($adrwidth downto 0) := (OTHERS => \'0\');

   BEGIN
   rom: PROCESS(clock)
   BEGIN
      IF(rising_edge(clock)) THEN
         address_q <= address;
         
         CASE address_q($adrwidth downto 2) IS
"; 
   if ($neededexp > 10){
      die "Chameleon Table Size is not supported - Maximum is 1024 at the moment";
   }    
   for(my $i = 0; $i < (2**($neededexp-2)); $i++ ){
      my $value = "";
      if(defined($lines[$i])){
         #get line
      my @bytes = split /;/,$lines[$i];
         $value = $bytes[4].$bytes[5].$bytes[6].$bytes[7];
      }
      else   
      {
         # use FFFFFFFF
         $value = "FFFFFFFF";  
      }
      my @a = split //, unpack("b8", pack("i",$i));
      
      print OUTFILE "            WHEN \"";
      for(my $k = $adrwidth - 2; $k >= 0; $k--){
         print OUTFILE $a[$k];  
      }
      print OUTFILE "\" => q <= x\"$value\";\n";
   }
       
   print OUTFILE      
"        
            WHEN OTHERS => q <= x\"FFFFFFFF\"; 
         END CASE;
      END IF;
   END PROCESS;
   END ARCHITECTURE chameleon_lut_arch;
";
   
   close OUTFILE;
}


sub debug {
    my ( $level, $caller, $time, $debug, @message, );
    return $DEBUG unless @_;
    $caller = (ref $_[0]) ? ref shift : ($_[0] eq __PACKAGE__) ? shift : (caller)[0];
    $debug  = exists $::{$caller}{DEBUG} ? ${$::{$caller}{DEBUG}} : $DEBUG || 0;

    if ( $_[0] =~ /^\d+$/ ) {
        $level = shift;
    }
    else {
        $level = 1;
    }

    return undef if $debug < $level;
    @message =  @_;
    return undef unless @message;
    $time = strftime "%H%M%S", localtime; 

    printf STDERR "D %s %2i %s: %s\n", $caller, $level, $time, shift @message;
    while ( my $line = shift @message ) {
        printf STDERR "D".( ' ' x (11+length $caller) ).": %s\n", $line;
    }
    return 1;
}


1;