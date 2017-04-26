#!/usr/bin/perl
################################################################################
#
# File          : Chameleon_V2.pl
# Author        : michael.ernst@men.de
# Organization  : MEN Mikro Elektronik GmbH
#
   my $version = "1.18";
   my $date    = "2016-06-14";
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
# Description: This script creates a chameleon table hex file out of a excel
#              Spreadsheet. It requires the module spreasheet-parseexcel-simple
#							 
# Functional Description:
#              In order to create a valid chameleon table you should know about
#              the Intel Hex Format. A source for information about that is:
#              http://www.cs.net/lucid/intel.htm
#
#              There are 2 functions in the file, one that outputs the usage
#              message if needed and one that creates a single line out of a
#              byte array and appends the checksum.
#
#              At first all lines are written into an array (@lines). They are
#              refferred to by the address they have inside the line.
#              At first the module lines are created. Then the finish marker
#              and in the end the header. Therefore the address has to be set to
#              0 after the finish marker.
#
#              After creating the single lines, the lines are written into a
#              text file and then a hex file end record is appended.
#
#              To Create Executable: pp -o Chameleon_V2.exe Chameleon_V2.pl -M PerlIO
#
# IMPORTANT NOTE: This Perls script is for the new Chameleon Table (V2),
#                 use cham.pl for Chameleon 0 and 1 tables
#
################################################################################

##########
# required modules
use strict;                         # use strict variable names
use warnings;
use Getopt::Mixed;                  # command agruement parsing
use Spreadsheet::ParseExcel;		   # Advanced Excel Spreadsheet parsing needed for sheet names
use Descriptor;                     # Object model for descriptors
use Textblocks;
use HelpFunctions;
use Input;
use Offset;
use Pciadr;
use WriteChamExcel;
use WriteLut;
use IntegrityCheck;

##########
# This string defines the command line arguments
#
# s              : string
# i              : number
# without define : flag
#
Getopt::Mixed::init( 'i=s a=s c=s r=i d s o p j=i L h x=s v=s m output>c input>i help>h usage>h debug>v adrdec>a');



##########
# Variable Defines

my $list;            # list root

my $project = "";    # porject string for use in PCI Address Decoder

my $update_pci_header_hex = 0;

my $infile;          # Inputfilename

my $descriptor;

my $usage;           # Usage flag
my $genadrdec = 0;   # Generate PCI Address Decoder flag
my $genoffset = 0;   # Generate Offsets flag -> autoactive if pci decoder generated
my @debug;
my $debug = 0;       # Debug Flag
my $master;          # master setting

my $adr = 4;         # address

my @bytes;           # bytes for the line
my @adrslices;       # sliced address (make 2x1 byte out of 2 byte address)
my @oLines;          # output Array

my $adrdectype = "WB"; #default address decoder is Wishbone
my $outfile ="chameleon.hex";
my $testbenchtype = "pci";
my $genlookup = 0;
my $set_min_revision = undef;
my $set_maj_revision = undef;
my $synthesis = 0;
my $manual_config = undef;

my $relative_path = 0;

##########
# function defines (needed as strict is in use)
sub err_usage;
sub makeline;
print "Excel to Chameleon_V2 Conversion v $version\n";
print "$date Michael Ernst\n";
print "michael.ernst\@men.de\n";
print "Copyright (C) 2007-2013, MEN Mikroelektronik Nuernberg GmbH\n\n";



##########
# Command Line Parsing
while( my( $option, $value, $pretty ) = Getopt::Mixed::nextOption())
   {
    OPTION: {
         $option eq 'i' and do {
            $infile = $value;
            last OPTION;
         };
         $option eq 'c' and do {
            $outfile = $value;
            last OPTION;
         };
         $option eq 'p' and do{
            $update_pci_header_hex = 1;
            last OPTION;
         };
         $option eq 'a' and do{
            $genadrdec = 1;
            $adrdectype = $value;
            last OPTION;
         };
         $option eq 'o' and do{
            $genoffset = 1;
            last OPTION;
         };
         $option eq 'h' and do{
            $usage = 1;
            last OPTION;
         };
         $option eq 's' and do{
            $synthesis = 1;
            last OPTION;
         };
         $option eq 'r' and do{
            $set_min_revision = $value;
            $synthesis = 1;
            last OPTION;
         };
         $option eq 'j' and do{
            $set_maj_revision = $value;
            $synthesis = 1;
            last OPTION;
         };
         $option eq 'x' and do{
            $manual_config = $value;
            last OPTION;
         };
         $option eq 'L' and do{
            $genlookup = 1;
            last OPTION;
         };
         $option eq 'v' and do{
            @debug = split(//, $value);;
            $debug = $debug[0] if (exists($debug[0]));
            last OPTION;
         };
         $option eq 'm' and do{
            $master = 1;
            last OPTION;
         };
         $option eq 'd' and do {
            $relative_path = 1;
            last OPTION;
         };
         
      }
   }

  Getopt::Mixed::cleanup();


##########
# if mendatory command line arguements are missing the usage message is printed
  if (!($infile) || $usage){
      err_usage;
  }

my $warning = 0;

##########
# Initialize Sub Modules

init_descriptor(exists($debug[1]) ? $debug[1] : 0, \$warning, $genoffset, $manual_config);
init_helpfunctions(exists($debug[2])? $debug[2] : 0);
init_offset(exists($debug[3]) ? $debug[3] : 0);
init_input(exists($debug[4]) ? $debug[4] : 0, $genoffset, $warning);
init_textblocks(exists($debug[5]) ? $debug[5] : 0, $version, $date);
init_pciadr(exists($debug[6]) ? $debug[6] : 0, $master, $adrdectype);
init_integrityCheck(exists($debug[7]) ? $debug[7] : 0);

##########
## Define Content Variables
my %content;
my @descriptors;
my @designinfo;

##########
## Parse Excel and save descriptors to Array and a list
parseChameleon($infile, \$project, \@descriptors, \@designinfo);

##########
## Find special devices (e.g. UART, SDRAM) - multichannel, singlecycle
#if ($genadrdec == 1){
   Descriptor->configEval();
#}
#else
#{
#   Descriptor->configEvalNoAdr();
#}

##########
# Automatically Assign Offsets (Optional)
if ($genoffset == 1){
   generateOffsets(\@descriptors);   
}

my $rel_path = ".";

if ($relative_path == 1) {
   # Get relative path from input filename
   $infile =~ m/(.*)\/.*/;
   $rel_path = $1;

}

Descriptor->setContentVar("rel_path", $rel_path);


##########
# CHeck Integrity of the addresses

$warning += checkIntegrity(\@descriptors);

##########
## Create PCI Address Decoder
if ($genadrdec == 1)
{
   Descriptor->setContentVar("adrdec", $adrdectype);
   generateAdr(\@descriptors, $project);
}

##########
## Check integrity of address decoder
if (!defined($adrdectype)) {
   $adrdectype = Descriptor->getContentVar("adrdec");
}

$warning += check_adr_dec($adrdectype);


##########
## Increment minor revision if synthesis flag is set
## Output a Warning if minor revision is 255 already
if ($synthesis == 1) {
   print "MinRevision incremented\n";
   
   my $minrevision = Descriptor->getContentVar('minrevision');
   if (defined($minrevision) && $minrevision ne "") {
      $minrevision++;
      if ($minrevision > 255) {
         $minrevision = 255;
         print "WARNING: Minor revision already at maximum!\n";
         print "         Either increase major revision or reset minor revision to a lower value.\n\n";
         $warning++; 
      }
   } else {
      $minrevision = 0;
   }
   Descriptor->setContentVar("minrevision", $minrevision);
}

if (defined($set_min_revision)) {
   Descriptor->setContentVar("minrevision", $set_min_revision);
}

if (defined($set_maj_revision)) {
   Descriptor->setContentVar("revision", $set_maj_revision);
}


my $maj_rev = Descriptor->getContentVar('revision');
my $min_rev = Descriptor->getContentVar("minrevision");
##########
## sort with group order and save into array

Descriptor->getChamArray(\@descriptors);

## Output Chameleon table to command line
print "+-------------------------------+----------+----------+-----+-----+\n";
print "| Device Name                   |  Offset  |   Size   | Bar | Grp |\n";
print "+-------------------------------+----------+----------+-----+-----+\n";
foreach $descriptor (@descriptors){
   if (defined $descriptor->{type} && $descriptor->{type} == 0){
      my $name   = $descriptor->{content}->{name};
      my $offset = hex($descriptor->{content}->{offset});
      my $size   = hex($descriptor->{content}->{size});
      my $bar    = $descriptor->{content}->{bar};
      my $group  = $descriptor->{content}->{group};
      my $instance = $descriptor->{content}->{instance};
      printf "|% 30s | %8x | %8x | %3d | %3d |\n", $name, $offset, $size, $bar, $group;  
   }
   elsif(defined $descriptor->{type} && $descriptor->{type} == 1)
   {
      my $name   = $descriptor->{content}->{name};
      my $offset = hex($descriptor->{content}->{offset});
      my $size   = hex($descriptor->{content}->{size});
      my $bar    = $descriptor->{content}->{bar};
      my $group  = $descriptor->{content}->{group};
      printf "|% 30s | %8x | %8x | %3d | %3d |\n", $name, $offset, $size, $bar, $group;    
   }
}
print "+-------------------------------+----------+----------+-----+-----+\n";


##########
## Prepare Outputlines


$adr = 0;
my @lines;
my @chameleon;
foreach $descriptor (@descriptors){
   #print "Descriptor ".$descriptor."\n";
   if (defined($descriptor->{type})){   
      #print $descriptor->{content}->{name}."\n";
      $descriptor->getBytes(\@lines);
      push @chameleon, @lines;
      foreach(@lines){
         @bytes = split(/;/, $_);
         
         @adrslices = unpack("A2" x 2, unpack("H4", pack("i", $adr)));
         
            
         $bytes[1] = $adrslices[1];  # adr bytes
         $bytes[2] = $adrslices[0];  # adr bytes
         $oLines[$adr] = makeline(@bytes); # call to sub makelines
         print $oLines[$adr]."\n\n" if $debug == 1;
         $adr++;
      }
   }
}

my $real_items = @oLines*4;
   
# Create End Descriptor
while (not_aligned($adr)) {
   # 4th record of the line
   @adrslices = unpack("A2" x 2, unpack("H4", pack("i", $adr)));
   $bytes[0] = "04";    # number of bytes in data section
   $bytes[1] = $adrslices[1];# 2 bytes
   $bytes[2] = $adrslices[0];# 2 bytes
   $bytes[3] = "00";    # marks a data record
   $bytes[4] = "ff";  # databyte 1
   $bytes[5] = "ff";  # databyte 1
   $bytes[6] = "ff";  # databyte 2
   $bytes[7] = "ff";  # databyte 2
   push @chameleon, "04;00;00;00;FF;FF;FF;FF";
   $oLines[$adr] = makeline(@bytes);
   print $oLines[$adr]."\n\n" if $debug == 1;
   $adr++;
}



open (OUTFILE, ">$rel_path/$outfile") or die "ERROR: Could not open $outfile for output\n";
   foreach(@oLines){
      print OUTFILE $_."\n";
   }
   # print hex file end record
   print OUTFILE ":00000001ff\n";
close OUTFILE;



Descriptor->updatePCIHeader() if $update_pci_header_hex == 1;

generateExcel($infile);
generateLut(\@chameleon) if ($genlookup == 1);

print "Written ".(@oLines+1)." records into output file.\n";
printf "Chameleon will require 0x%x of address space\n", @oLines*4;
printf "The descriptors use 0x%x of the address space\n", $real_items;
printf "Empty items are filled with 0xFFFFFFFF\n";
printf "%d Major Revision\n", hex($maj_rev);
printf "%d Minor Revision\n", hex($min_rev);

if ($warning == 0) {
   print "No Error during creation\n";
} else {
   print "$warning Warnings during creation\n";
}

 
################################################################################
# err_usage
################################################################################
# Description: Usage Output - terminates the script
#
# Inputs     : none
#         
# Output     : std_out message
#
# History    : /mE 06/03/03 Added to this module
#              /mE 07-04-24 Changed to fit v1.8
################################################################################  
## 
sub err_usage {
   
   print "Usage:\n\n" ;
   print "   cham2 -i=infile [-c=<outfile>] [-v=<debug>] [-h] [-a=<type>] [-s] [-r=<minor_revision] [-R=<major_revision>] [-x=<device_config.xml>]\n\n";
   print "   -h          -> Show this message\n";
   print "   -i          -> Input Filename\n";
   print "   -c          -> Output file name (default: chameleon.hex)\n";
   print "   -a          -> Generate Address Decoder and\n";
   print "                  Automatically assign Offsets\n";
   print "                  wb  -> generate Wishbone address decoder\n";
   print "                  pci -> generate PCI address decoder\n";
   print "   -L          -> Generate Chameleon table as lookuptable\n";
   print "                  to save internal FPGA RAM\n";
   print "   -p          -> Update pci_header.hex\n";
   print "   -v          -> enable Debug Outputs for modules\n";
   print "                  0/1 switches debug \n";
   print "   -v=xxxxxxxx -> enable debug for module\n";
   print "      |||||||+--  Intergity Checks\n";
   print "      ||||||+---  Pciadr\n";
   print "      |||||+----  Textblocks\n";
   print "      ||||+-----  Input\n";
   print "      |||+------  Offset\n";
   print "      ||+-------  Helpfunctions\n";
   print "      |+--------  Descriptor \n";
   print "      +---------  Not used\n";
   print "   -x          -> Manual definition of device_config.xml\n";
   print "   -s          -> Increment minor revision\n";
   print "   -r          -> Set minor revision to be used\n";
   print "   -j          -> Set major revision to be used\n";
   print "   -d          -> put all files into same folder as the excel\n";
   exit; 
}  