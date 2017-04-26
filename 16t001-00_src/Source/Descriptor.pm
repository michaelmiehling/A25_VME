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
# Description: This Package describes the Descriptor Object
#							 
# Functional Description: This pakcage implements the Descriptor Object with
#              The Descriptor object is initialized with the type, so it knows
#              what data is being saved inside.
#              There are furthermore some functions which enable the user to
#              read, save, modify and output data.
#              The Descriptor contents are defined within an array, so new
#              descriptors and modifications of old descriptors can be
#              implemented easily.
#              
#              Internal Descriptor References: ($type)
#                 0 General Descriptor
#                 1 Bridge Descriptor
#                 2 CPU Descriptor
#                 3 Bar Descriptor
#                98 Bar Header
#                99 Configuration Descriptor (Head)
#
# IMPORTANT NOTE: Object Tutorial at http://www.perlmonks.com/?node_id=218778
#
################################################################################
#
# History:
#
# $Revision: 1.4 $
#
# $Log: Descriptor.pm,v $
# Revision 1.4  2013/04/19 14:51:16  mernst
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
# Revision 1.3  2008/06/23 15:35:38  mernst
# Added group field to bridge descriptor
# Suppressed Warning message for pseudo groups
#
# Revision 1.2  2008/03/31 14:06:41  mernst
# Changed location
# Fix for better order in chameleon.hex
#
# Revision 1.10  2007/04/26 09:30:55  mErnst
# - Fixed missing header descriptor in v1.8/1.9
#
# Revision 1.9  2007/04/26 09:07:08  mErnst
# - Fixed 16z063- recognition for standard designs
#
# Revision 1.8  2007/04/24 14:21:35  mErnst
# - Added error message in case xls file does not exist
# - Changed push_desc
# - Removed -p option
# - Added -a <type> option to generate wb/pci address decoder
#
# Revision 1.7  2006/11/20 09:58:00  mernst
# - Fixed an issue where address overlapping would cause an error if only 1 bar is used in xls
#
# Revision 1.6  2006/08/11 16:20:27  mernst
# Fixed an issue where cpu descriptors would indicate an overlapping address space
# Updated Revision and Date in Main Script
#
# Revision 1.5  2006/08/11 15:55:44  mernst
# Added support for execution out of PATH variable
# Fixed issue with group sorting while not using automatic offset sorting
#
# Revision 1.4  2006/08/10 13:32:48  mernst
# Added Check for Address Space Integrity
#
# Revision 1.3  2006/04/25 11:48:11  mErnst
# Added automatic offset generation
# Added PCI Address Decoder generation
# Added PCI Wrapper Generation
# Added Configuration File
# Split up file into multiple modules for better handling
# Changed Data format to linked list
#
# Revision 1.2  2006/01/24 10:56:01  MErnst
# corrected an error with cpu descriptor and bridge descriptor creation
#
# Revision 1.1  2005/07/26 14:18:33  MErnst
# Initial Revision
#
################################################################################

##########
# changelog temp
# MErnst - 11/10/05

package Descriptor;
use base 'Exporter';
our @EXPORT = ('init_descriptor', 'push_desc', 'set_root', 'get_root', 'subst_desc', 'del_desc', 'getContentVar', 'setContentVar');
use strict;
use HelpFunctions;
use XML::Simple;
use XML::SAX::PurePerl;
use Cwd;
use POSIX;

our $DEBUG;
our $pcidescriptor = undef;
our %pcidescriptor;
my $debug; # Debug Module
my $root;

# Find and Open Config File
#;
my $ref;
my $xmlfile = "";

my $newest = 0;
my $used   = 0;
my $xmlfound = 0;

sub sortByGroup;
my $genoffset = 0;

sub init_descriptor{
   $debug = $_[0];   
   
   my $warning = $_[1];
   $genoffset = $_[2];
   my $manual_config = $_[3];
   
   if (defined($manual_config)) {
      if ( -e "$manual_config"){
         $ref = XMLin("$manual_config");
         $xmlfile = "$manual_config";
         print "\nUsing File ",cwd(),"/$manual_config\n\n";
         $xmlfound = 1;
         my @stat = stat("$manual_config");
         $used   = $stat[9];
         $newest = $stat[9];
      } else {
         die "Manual configuration file defined but not found!\n";
      } 
   }
   
   print "Searching for Device Configuration";
   print ".";
   
   if ( -e "device_config.xml" && !$xmlfound){
      $ref = XMLin("device_config.xml");
      $xmlfile = "device_config.xml";
      print "\nUsing File ",cwd(),"/device_config.xml\n\n";
      $xmlfound = 1;
      my @stat = stat("device_config.xml");
      $used   = $stat[9];
      $newest = $stat[9];
   }
   foreach my $path (split(/;/,$ENV{path}))
   {
      print "." unless $xmlfound;
      if (-e $path."\\device_config.xml")
         {
         if ($xmlfound == 0){
            $ref = XMLin($path."\\device_config.xml");
            print "\nUsing File ",$path,"\\device_config.xml\n\n";    
            $xmlfile = $path."\\device_config.xml";
            $xmlfound = 1;
            my @stat = stat ($path."\\device_config.xml");      
            $used   = $stat[9];
            $newest = $stat[9];
            }
         my @stat = stat ($path."\\device_config.xml");
         if ($stat[9] > $used)
         {
            print "\n\nWARNING: $path\\device_config.xml is newer than the used file!\n\n";
         }
      }
   }
   print "\n";
   if ($xmlfound == 0){
      print "\nERROR: Device Configuration file not found.\n";
      die;
   }
}


##########
## Descriptor contents
my @genDescCont = ("Name      ","Device    ", "Variant   ","Revision  ","Interrupt ","Group     ","Instance  ","BAR       ","Offset    ","Size      ");
my @genDescBit  = ("NA"        ,"I"         , "H"         ,"H"         ,"H"         ,"H"         ,"H"         ,"H"         ,"H"         ,"H"         );


my @briDescCont = ("Name      ","Device    ","Variant   ","Revision  ","Interrupt ","Group     ","DBAR      ","Instance  ","BAR       ","Chamoffset","Offset    ","Size      ");
my @briDescBit  = ("NA"        ,"I"         ,"H"         ,"H"         ,"H"         ,"H"         ,"H"         ,"H"         ,"H"         ,"H"         ,"H"         ,"H"         );

my @cpuDescCont = ("Name      ","Device    ","Variant   ","Revision  ","Interrupt ","Group     ","Instance  ","Bootadr   ");
my @cpuDescBit  = ("NA"        ,"I"         ,"H"         ,"H"         ,"H"         ,"H"         ,"H"         ,"H"         );

my @barDescCont = ("Name      ","Baseadr   ","BARsize   ");
my @barDescBit  = ("NA"        ,"H"         ,"H"         );

my @barHeadCont = ("BARcnt    ");
my @barHeadBit  = ("I"         );

my @conDescCont = ("Bustype   ","Model     ","Revision  ","MinRevision","Filename  ","ArchName   ","AdrDec     ","Deviceid  ","Vendorid  ","Subsysid  ","Subsysvend","Irqpin    ","Irqline   ","Classcode ","Lattimer  ");
my @conDescBit  = ("I"         ,"I"         ,"H"         ,"H"          ,"t"         ,"t"          ,"t"          ,"H"         ,"H"         ,"H"         ,"H"         ,"H"         ,"H"         ,"H"         ,"H"         );

##########
# Descriptor Format
# NA[x:y]         - Reserved bits, will be filled with 'F'
# variable[x:y]   - Bits of variable
# T(abcd)[x:y]    - Text "abcd" will be converted and bits x-y will be used
# H(cdef)[x:y]    - Hex value "cdef" will be converted as Hex 
# I(z)[x:y]       - Decimal Value z and bits x-y will be used (size 0..255)

our @conDescFor;
push @conDescFor, "bustype[7:0];minrevision[7:0];model[7:0];revision[7:0]";
push @conDescFor, "NA[15:0];H(ABCE)[15:0]";
push @conDescFor, "filename[71:64];filename[79:72];filename[87:80];filename[95:88]";
push @conDescFor, "filename[39:32];filename[47:40];filename[55:48];filename[63:56]";
push @conDescFor, "filename[7:0];filename[15:8];filename[23:16];filename[31:24]";

our @genDescFor;
push @genDescFor, "I(0)[3:0];Device[9:0];Variant[5:0];Revision[5:0];Interrupt[5:0]";
push @genDescFor, "NA[16:0];Group[5:0];Instance[5:0];BAR[2:0]";
push @genDescFor, "Offset[31:0]";
push @genDescFor, "Size[31:0]";

our @briDescFor;
push @briDescFor, "I(1)[3:0];Device[9:0];Variant[5:0];Revision[5:0];Interrupt[5:0]";
push @briDescFor, "NA[13:0];Group[5:0];DBAR[2:0];Instance[5:0];BAR[2:0]";
push @briDescFor, "Chamoffset[31:0]";
push @briDescFor, "Offset[31:0]";  
push @briDescFor, "Size[31:0]";

our @cpuDescFor;
push @cpuDescFor, "I(2)[3:0];Device[9:0];Variant[5:0];Revision[5:0];Interrupt[5:0]";
push @cpuDescFor, "NA[16:0];Group[5:0];Instance[5:0];NA[2:0]";
push @cpuDescFor, "bootadr[31:0]";

our @barDescFor;
push @barDescFor, "Baseadr[31:0]";
push @barDescFor, "BARsize[31:0]";

our @barHeadFor;
push @barHeadFor, "I(3)[3:0];NA[21:0];BARcnt[5:0]";

our @pciHeaderFor;
push @pciHeaderFor, "Deviceid[15:0];Vendorid[15:0]";      # 
push @pciHeaderFor, "I(0)[31:0]";                         # Status Register / Command Register
push @pciHeaderFor, "Classcode[23:0];Revision[7:0]";      #
push @pciHeaderFor, "I(0)[15:0];Lattimer[7:0];I(0)[7:0]"; #
push @pciHeaderFor, "I(0)[31:0]";                         # Bar0
push @pciHeaderFor, "I(0)[31:0]";                         # Bar1
push @pciHeaderFor, "I(0)[31:0]";                         # Bar2
push @pciHeaderFor, "I(0)[31:0]";                         # Bar3
push @pciHeaderFor, "I(0)[31:0]";                         # Bar4
push @pciHeaderFor, "I(0)[31:0]";                         # Bar5
push @pciHeaderFor, "I(0)[31:0]";                         # CardBus CIS Pointer
push @pciHeaderFor, "Subsysid[15:0];Subsysvend[15:0]";    # 
push @pciHeaderFor, "I(0)[31:0]";                         # Expansion ROM Base Address Register
push @pciHeaderFor, "I(0)[31:0]";                         # Reserved
push @pciHeaderFor, "I(0)[31:0]";                         # Reserved
push @pciHeaderFor, "H(FF)[7:0];H(01)[7:0];Irqpin[7:0];Irqline[7:0]";

################################################################################
# new
################################################################################
# Description: Creates a new Descriptor object
#
# Inputs     : class - automated
#              type  - type of descriptor
#         
# Output     : blessed descriptor object
#
# History    : /mE 06/04/07 Added to this module description
################################################################################

sub new{
   # Creates a new Descriptor Object, type selects the descriptor type
   # The appropreate stuff (Cont and Bit will be saved into the object)
   my $class = shift;
   my $self = {};
   my $type = shift;
   my %content;
   my @DescCont;
   @DescCont = @genDescCont if ($type == 0);
   @DescCont = @briDescCont if ($type == 1);
   @DescCont = @cpuDescCont if ($type == 2);
   @DescCont = @barDescCont if ($type == 3);
   @DescCont = @barHeadCont if ($type == 98);
   @DescCont = @conDescCont if ($type == 99);   
   
   my @DescBit;
   @DescBit = @genDescBit if ($type == 0);
   @DescBit = @briDescBit if ($type == 1);
   @DescBit = @cpuDescBit if ($type == 2);
   @DescBit = @barDescBit if ($type == 3);
   @DescBit = @barHeadBit if ($type == 98);
   @DescBit = @conDescBit if ($type == 99);
   
   my @DescFor;
   @DescFor = @genDescFor if ($type == 0);
   @DescFor = @briDescFor if ($type == 1);
   @DescFor = @cpuDescFor if ($type == 2);
   @DescFor = @barDescFor if ($type == 3);
   @DescFor = @barHeadFor if ($type == 98);
   @DescFor = @conDescFor if ($type == 99);      
   
   if ($type == 99){
      $pcidescriptor = $self;  
   }
   
   
   $self->{DescCont} = \@DescCont;
   $self->{DescBit}  = \@DescBit;
   $self->{DescFor}  = \@DescFor;
   
   $self->{type} = $type;
   
   $self->{wrapper}     = 0; # ignore for chameleon table creation
   $self->{wrapped}     = 0; # ignore for address decoder creation
   $self->{master}      = 0; # Device is Group Master
   $self->{content}->{group} = -1;
   my @wrapped_desc;
   $self->{wrapped_desc} = \@wrapped_desc;
   
   $self->{multichannel}= 0;
   $self->{singlecycle} = 0;
   
   $self->{cycle} = 0;
   
   $self->{prv} = undef;
   $self->{nxt} = undef;
   
   return bless $self, $class;
}



################################################################################
# addVar
################################################################################
# Description: Adds a new variable into the descriptor object
#              it also manages the offsets of all wrapped objects, if module
#              is a wrapper.
#
# Inputs     : $self
#              varname - name of variable to save
#              value   - value to save
#
# Output     : none
#
# History    : /mE 06/04/07 Added to this module description
#              /mE 07-04-24 Added Hardcoded offsets for NAND devices
################################################################################

sub addVar{
   # adds the variable $varname with $value to the data hash
   my $self = shift;
   my $varname = shift;
   my $value = shift;
   
   ## if offset is updated and descriptor is a wrapper then
   ## all submodules need to be updated too
   if ($varname eq "offset" && $self->{wrapper} == 1)
   {
      ## case multichannel device
      ## channelsize is saved in descriptors as size
      
      if ($self->{multichannel} > 0)
      {
         my $localoffset = hex($value);
         foreach my $descriptor (@{$self->{wrapped_desc}})
         {
            $descriptor->addVar("offset", createHex($localoffset));  
            $localoffset = $localoffset + $descriptor->getHexVar("size");
         }  
      }
      
      ## case singlecycle offset in device is saved as offset in descriptors
      if ($self->{content}->{device} == 70){
         
         print "Reassigning offset $value to Nand Flash\n";  
         #$self->showAll();
         foreach my $descriptor (@{$self->{wrapped_desc}})
         {
            if ($descriptor->{content}->{device} == 63){
               $descriptor->addVar("offset", createHex(hex($value)+hex(600)));
            }
            if ($descriptor->{content}->{device} == 68){
               $descriptor->addVar("offset", createHex(hex($value)+hex(2000)));
            }
         }
      }
      elsif ($self->{singlecycle} == 1)
      {
         foreach my $descriptor (@{$self->{wrapped_desc}})
         {
            $descriptor->addVar("offset", createHex(hex($value)+$descriptor->getHexVar("offset")));  
         }
      }
   }
   
   $self->{content}{$varname} = $value;
}

################################################################################
# showVar
################################################################################
# Description: Outputs a variable with variable name and value to stdOut
#
# Inputs     : $self
#              varname - name of variable to save
#              value   - value to save
#
# Output     : none (prints to stdOut)
#
# History    : /mE 06/04/07 Added to this module description
################################################################################

sub showVar{
   my $self = shift;
   my $varname = shift;
   my %content = %{$self->{content}};
   print "$varname: ", $content{$varname}, "\n"; 
}

################################################################################
# showAll
################################################################################
# Description: prints content of descriptor to stdOut, adds all sub descriptors
#              if module is a wrapper 
#           
# Inputs     : $self
#
# Output     : none
#
# History    : /mE 06/04/07 Added to this module description
################################################################################

sub showAll{
   my $self = shift;
   my $cn;
   my $key;
   my %content = %{$self->{content}};
   
   print ("---------------------\n");
   print $self->{type}."\n";
   foreach $cn (@{$self->{DescCont}})
   {
      $cn =~ s/([a-zA-Z]*) */$1/;
      $cn = lc($cn);
      print "$cn: ", $content{$cn}, "\n"; 
      next;
   }
   print "    Singlecycle: ".$self->{singlecycle}."\n";
   print "    Multichannel: ".$self->{multichannel}."\n";
   print "    Wrapper: ".$self->{wrapper}."\n";
   print "    Wrapped: ".$self->{wrapped}."\n";
   print ("---------------------\n");
   if ($self->{wrapper} == 1){
      print "# Content of wrapper #\n";
      print "# Channels: ".@{$self->{wrapped_desc}}."\n";
      foreach (@{$self->{wrapped_desc}})
      {
         $_->showAll();  
      }
      print "######################\n";
   }
}

################################################################################
# getSize
################################################################################
# Description: returns the outputsize of the descriptor, depending on type
#              returns sum of subcomponents if module is a wrapper
#
# Inputs     : $self
#
# Output     : none
#
# History    : /mE 06/04/07 Added to this module description
################################################################################

sub getSize{
   my $self = shift;
   if ($self->{wrapper} == 0){
      return @{$self->{DescFor}} * 4;   
   }
   else
   {
      my $sum = 0;
      foreach (@{$self->{wrapped_desc}})
      {
         $sum += $_->getSize();
      }
      return $sum;
   }         
}

################################################################################
# addSize
################################################################################
# Description: adds a given size value to current size variable
#
# Inputs     : $self
#              toadd   - size which should be added to local value
#
# Output     : none
#
# History    : /mE 06/04/07 Added to this module description
################################################################################

sub addSize{
   my $self = shift;
   my $toadd = hex($_[0]);
   my $addto = hex($self->{content}->{size});
   $self->{content}->{size} = createHex($addto+$toadd);
}

################################################################################
# getHexVar
################################################################################
# Description: return integer of a saved hex value
#
# Inputs     : $self
#              varname - name of variable
#
# Output     : none
#
# History    : /mE 06/04/07 Added to this module description
################################################################################

sub getHexVar{
   my $self = shift;
   my $varname = shift;
   my %content = %{$self->{content}};
   return hex($content{$varname});  
}

################################################################################
# addVar
################################################################################
# Description: returns variable
#
# Inputs     : $self
#              varname - name of variable
#
# Output     : none
#
# History    : /mE 06/04/07 Added to this module description
################################################################################

sub getVar{
   my $self = shift;
   my $varname = shift;
   my %content = %{$self->{content}};
   return $content{$varname};     
}

sub getContentVar{
   my $self = shift;
   my $varname = shift;
   my %content = %{$pcidescriptor->{content}};
   return $content{$varname}; 
}

sub setContentVar{
   my $self = shift;
   my $varname = shift;
   my $value = shift;
   $pcidescriptor->{content}->{$varname} = $value;
}
   

################################################################################
# getType
################################################################################
# Description: return type of descriptor
#
# Inputs     : $self
#
# Output     : none
#
# History    : /mE 06/04/07 Added to this module description
################################################################################

sub getType{
   my $self = shift;
   return $self->{type};
}

################################################################################
# getBytes
################################################################################
# Description: format descriptor as output for hex file
#
# Inputs     : $self
#              lines_ref - reference to lines array
#
# Output     : lines into array
#
# History    : /mE 06/04/07 Added to this module description
################################################################################

sub getBytes{
   my ($linefor, $command, $value, $var, $upper, $lower, $i, @lines, $method, $line);
   my $self = shift;
   my $lines_ref = shift;
   my $bitString;
   debug(10, "Called getBytes");
   # converts the data inside the content hash into bytes and
   # creates an array for output into hex file
   foreach $linefor(@{$self->{DescFor}}){
      # iterate through the different lines
      # Parse line...
      # .. split up at ;
      my @line;
      push (@line, "04");  # number of databytes
      push (@line, "00");  # adr empty, will be filled by main
      push (@line, "00");  # adr empty, will be filled by main
      push (@line, "00");  # marks data record
      
      
      my @bits;
      foreach $command (split(/;/,$linefor)){
         #print "found command $command" if $debug == 1;
         # Regular Expression to parse command
         $command =~ /([a-zA-Z0-9]*)(\(.*\))?(\[.*\])/;
         #            ||           | |     || |     |    
         #            ||           | |     || |     + save to $3
         #            ||           | |     || + range is in []
         #            ||           | |     |+ variable is optional
         #            ||           | |     + save to $2
         #            ||           | + variable is in brackets
         #            ||           + save to $1
         #            |+ command can be made of chars and numbers
         #            + Begin reg ex
         $var = lc($1);
         $value = $2 ? $2 : 0;
         if( $3 =~ /\[([0-9]*):([0-9]*)/){
            $upper = $1;
            $lower = $2;
         }
         else
         {
            print "Error in Format Description\n";
            die;
         }
         
         $value =~ s/\((.*)\)/$1/;
         print "- var $var - val $value - from $lower to $upper\n" if $debug == 1;
         # Parse unique commands
         
         if ($var eq "na"){
           $method = "na";
         }
         elsif ($var eq "t"){
            $method = "t";
         }
         elsif ($var eq "i"){
            $method = "i";
         }
         elsif ($var eq "h"){
            $method = "h";
         }
         else{
            debug(35, "Found else Tree -> $var");
            my @DescCont = @{$self->{DescCont}};
            my %try = %{$self->{content}};
            debug(35, "Value of $var is $try{$var}");
            $value = $try{$var};
            for ($i = 0; $i < scalar @DescCont; $i++){
               my $l = lc($DescCont[$i]);
               $l =~ s/ //g; # get rid of whitespace
               if ($l eq $var){
               debug(35, "Method is $method");
               $method = lc(@{$self->{DescBit}}[$i]);   
               }
            }   
         }
         
         
         if ($method eq "na"){
            # reserved Bits are filled with 1
            $value = 0;
            for (my $k = $lower; $k <= $upper; $k++){
               push(@bits, "0");
            }
         }
         elsif ($method eq "t"){
            
            # Paste text into it
            my @localBits;
            foreach my $char (split(//, $value)){   
               foreach (split(//, unpack("B8", pack("i", ord($char))))){
                  push(@localBits, $_);
               }
            }
            for (my $k = (scalar @localBits) - 1 - $upper; $k <= (scalar @localBits) - 1 - $lower; $k++){
               if ($k >= 0){
                  push(@bits, $localBits[$k]);
               }
               else
               {
                  push(@bits, "0");
               }
            }
         }
         elsif ($method eq "i"){
            debug(35, "Starting up Method 'I'", "Value $value", "Upper $upper", "Lower $lower");
            # Paste int value into it
            my @localBits;

            foreach (split(//, unpack("b16", pack("i", $value)))){
               debug(35, "Pushing $_");
               push(@localBits, $_);
            }

            debug(80, "scalar localbits ".(scalar @localBits));

            for (my $k = $upper; $k >= $lower; $k--){
               if ($k >= 0){
                  debug(80, "Writing Bit $k into bitvector -".$localBits[$k]);
                  push(@bits, $localBits[$k]);
               }
               else
               {
                  
                  push(@bits, "0");
               }
            }
         }
         elsif ($method eq "h"){
                       
            # Paste hex value into it
            my @localBits;
            debug(60, "Starting Method 'H'", "Value $value", "Upper $upper", "Lower $lower");
            foreach my $char (split(//, $value)){   
               my @lb = split(//, unpack("B4", pack("H", $char)));
               for  (my $k = 0; $k < 4; $k++){
                  push(@localBits, $lb[$k]);
               }
            }
            for (my $k = (scalar @localBits) - 1 - $upper; $k <= (scalar @localBits) - 1 - $lower; $k++){
               if ($k >= 0){
                  push(@bits, $localBits[$k]);
               }
               else
               {                  
                  push(@bits, "0");
               }
            }
         }  
      }
      
      # Save into line
      $bitString = "";
      for(my $k = 0; $k<32; $k++){
         $bitString .= $bits[$k];
      }
      print $bitString, " - ", unpack("H8", pack("B32", $bitString)), " - " if $debug == 1;
      push(@line, unpack("A2" x 4, unpack("H8", pack("B32", $bitString))));
      $line = "";
      foreach(@line){
         $line .= $_ . ";";
         print if $debug == 1;
      }
      print "\n" if $debug == 1;
      push(@lines, $line);
   }
   @{$self->{lines}} = @lines;
   @{$lines_ref} = @lines;
   foreach(@lines){
   print $_,"\n" if $debug == 1;};
}

################################################################################
# set_root
################################################################################
# Description: sets root to given descriptor object
#
# Inputs     : object - object to set descriptor to
#
# Output     : none
#
# History    : /mE 06/04/07 Added to this module description
################################################################################

sub set_root{
   $root = $_[0];
}

################################################################################
# get_root
################################################################################
# Description: returns root descriptor
#
# Inputs     : none
#
# Output     : root descriptor object
#
# History    : /mE 06/04/07 Added to this module description
################################################################################

sub get_root{
   return $root;
}

################################################################################
# getChamArray
################################################################################
# Description: Creates an array which contains all modules, sorted by groups
#              It uses the device_config.xml as input for group definitions
#
# Inputs     : $self
#              $array_ref - reference to array for output
#
# Output     : none
#
# History    : /mE 06/04/07 Added to this module description
################################################################################

sub getChamArray{
   
   my $self = shift;
   my $array_ref = shift;
   debug(10, "Called getChamArray");
   # sort tree by offsets->bars
   Descriptor->sortbyhex("offset");
   Descriptor->sortbyhex("bar");
   
   #Check for Address Integrity
   Descriptor->checkIntegrity();
   
   
   # Create Array with all modules that should show up in chameleon table
   # Hide wrappers and show all elements
   my @array;
   my @tmp;
   my @bridges;
   
   my $node = $root;
   
   while (defined($node))
   {
      
      if ($node->{wrapper} == 0)
      {
         #print "push node with type ".$node->{type}."\n";
         if ($node->{type} < 1){
            push @tmp, $node;
         }
         elsif ($node->{type} == 1)
         {
            push @bridges, $node;
         }
         else
         {
            push @array, $node;
         }
      }
      else
      {
         foreach (@{$node->{wrapped_desc}})
         {
            push @tmp, $_;
         }
      }
      
      $node = $node->{nxt};  
   }
   
   # sort array by groups
   
   @tmp = sort sortByGroup @tmp;
   my @groups;
   foreach my $descriptor (@tmp)
   {
      if ($descriptor->{type} < 1){
         #print "Group Descriptor: ".$descriptor->{content}->{name}."\n";
         my $group = $descriptor->{content}->{group};
         #print "Put Module ".$descriptor->{content}->{name}." into group ".$descriptor->{content}->{group}."\n";
         push @{$groups[$group]}, $descriptor;
      }
   }
   
   foreach my $descriptor (@{$groups[0]}){
      push @array, $descriptor;
   }
   
   for (my $i = 1; $i < @groups; $i++){
      if (exists($groups[$i])){
         # find group master
         my $master = -1;
         for(my $k = 0; $k < @{$groups[$i]}; $k++)
         {
            
            my $descriptor = @{$groups[$i]}[$k];
            if ($descriptor->{master} == 1){
               $master =  $k;
            }
         }
         if ($master == -1){
          die "ERROR: No group master found for Group $i in device_config.xml\n";
         }
         else
         {
            #print "Group Master $master of Group $i\n";
         }
         my @grptmp;
         my $deviceid = $groups[$i][$master]->{content}->{device};
         # output group in order
         foreach my $descriptor (@{$groups[$i]})
         {
            my $added = 0;
            
            
            for(my $k = 0; $k < @{$ref->{device}->{$deviceid}->{grp}}; $k++)
            {
               my $element = $ref->{device}->{$deviceid}->{grp}[$k];
               #print $descriptor->{content}->{device}," - ", $element, "\n";
               if ($descriptor->{content}->{device} == $element)
               {
                  #print "Match (",$groups[$i][$master]->{content}->{device},")->";
                  if(!exists($grptmp[$k]) && $added == 0)
                  {
                     #print " Added";
                     $grptmp[$k] = $descriptor;
                     $added = 1;
                  }
                  #print "\n";
               }            
            }
            if ($added == 0){
               #print @grptmp, "\n", @{$ref->{device}->{$deviceid}->{grp}}, "\n";
               # NOT WORKING -> Errors & Improvments!!!
               #if (@grptmp == @{$ref->{device}->{$deviceid}->{grp}})
               #{
               #   print "WARNING: Too many members in group $i!\n";
               #}
               #else
               #{
                  print "WARNING: Group member not found in group $i!\n";
               #}
               print "         DeviceID Master: $deviceid\n";
               print "         DeviceID Slave:  $descriptor->{content}->{device}\n";
               die; 
            }
         }
         
#         # Check if group is fully set
#         if (@grptmp != @{$ref->{device}->{$deviceid}->{grp}})
#         {
#            if (!@grptmp[1] eq "NA"){
#               foreach (@grptmp) {
#                  print $_->{content}->{name}."\n";
#               }
#               
#               foreach (@{$ref->{device}->{$deviceid}->{grp}}){
#                   print $_."\n";
#                  }
#            print "WARNING: Group $i with master deviceID $deviceid is not full!\n";
#         }
#         }
         push @array, @grptmp;
      } 
      else
      {
         print "WARNING: Group enumeration has gaps!\n";
      }
   }
   
   push @array, @bridges;
   
   # set reference of array to point to new array  
   @{$array_ref} = @array;
}

################################################################################
# setCycleNo
################################################################################
# Description: saves the cycle number into descriptor / subdescriptor objects
#
# Inputs     : $self
#              $no     - cycle number
#
# Output     : none
#
# History    : /mE 06/04/07 Added to this module description
################################################################################

sub setCycleNo{
   my $self = shift;
   my $no   = shift;
   if ($self->{wrapper} == 0){
      $self->{cycle} = $no;
   }
   else
   {
      foreach (@{$self->{wrapped_desc}}){
         $_->setCycleNo($no);  
      }
      $self->{cycle} = $no;
   }
     
}

################################################################################
# push_desc
################################################################################
# Description: Adds the descriptor after the given descriptor into list
#
# Inputs     : $self
#              $curref      - current last member
#              $descriptor  - member to add
#           
#
# Output     : updates reference to current member
#
# History    : /mE 06/04/07 Added to this module description
#              /mE 07-04-20 Changed function to member function
################################################################################

sub push_desc{
   my $self = shift;
   if (!defined($root)){
      #print "-- Create New List\n";
      #print $self."\n";
      set_root($self);
   }
   else
   {
      #print "-- Add Item\n";
      #print $self."\n";
      
      my $lastNode = getLast();
      $self->{prv} = $lastNode;
      $lastNode->{nxt} = $self;
   }
}

################################################################################
# getLast
################################################################################
# Description: Returns the last descriptor in the list
#
# Inputs     : $self
#              
#
# Output     : reference to last member
#
# History    : /mE 07/04/20 Added to this module
################################################################################

sub getLast{
   my $self = shift;
   my $node = $root;
   while (defined($node->{nxt})){
      $node = $node->{nxt};
   }
   return $node;
}

################################################################################
# sortByHex
################################################################################
# Description: Sorts descriptor list by a given variable name.
#              the variable is asumed to be a hex string
#
# Inputs     : $self
#              $order   - sort by this name
#
# Output     : none
#
# Note       : Can be used to sort by integer values if user is sure it's < 10
#              e.g. bar
#
# History    : /mE 06/04/07 Added to this module description
################################################################################

sub sortbyhex{
   my $self = shift;
   my $order = shift;
   my $node;
   
   if ($self eq "Descriptor"){
      $node = $root;   
   }
   else
   {
      $node = $self;
   }
   
   my $nxt = $node->{nxt};
   
   ##########
   ## Sort by Offset
   
   
   ## call sort method for each module recursive
   if (defined($node->{nxt}))
   {
      $nxt->sortbyhex($order);
   }   
      
   if ($node->{type} < 2){
      ## element shifts itself to back if following element is smaller than itself
      # update $nxt as it may be modified by sort function of sub element
      $nxt = $node->{nxt};
      
      
      
      # shift to back until size is ok
      while (defined($nxt) && hex($nxt->{content}->{$order}) < hex($node->{content}->{$order}))
      {
         if (defined($node->{prv}))
         {
            my $prev = $node->{prv};
            $prev->{nxt} = $nxt;   
         }
         if (defined($nxt->{nxt}))
         {
            my $nxtnxt = $nxt->{nxt};
            $nxtnxt->{prv} = $node;
         }        
         
         $node->{nxt} = $nxt->{nxt};
         $nxt->{prv}  = $node->{prv};
         $node->{prv} = $nxt;
         $nxt->{nxt}  = $node;
                 
         $nxt = $node->{nxt};
      }
   }
   
   if ($self eq "Descriptor"){
      ## Get new Root element
      while (defined($node->{prv})){
         $node = $node->{prv};
      }
      $root = $node;
   }
 
}

################################################################################
# checkIntegrity
################################################################################
# Description: Checks if there are overlapping Address Spaces in the table
#
# Inputs     : $self
#
# Output     : none
#
#
# History    : /mE 06/08/10 Added Check Function
################################################################################

sub checkIntegrity{
   my $self = shift;
   my $order = shift;
   my $node;
   
   if ($self eq "Descriptor"){
      $node = $root;   
   }
   else
   {
      $node = $self;
   }
   
   my $nxt = $node->{nxt};
   
   if ($node->{type} == 0){
      if (defined($nxt) && $nxt->{type} == 0){
         if (hex($nxt->{content}->{"bar"}) == hex($node->{content}->{"bar"})){
            if (hex($node->{content}->{"offset"}) + hex($node->{content}->{"size"})
                > hex ($nxt->{content}->{"offset"})){
                  print "WARNING: Address Space overlapping\n";
                  $node->showAll();
                  $nxt->showAll();
            }
         }
      }
   }
            
   if (defined($node->{nxt}))
   {
      $nxt->checkIntegrity();
   } 
 
}


################################################################################
# configEval
################################################################################
# Description: Parses the newly entered descriptors and generates singlecycle,
#              multichannel wrappers and adds group master flag
#
# Inputs     : none
#
# Output     : none (updates list)
#
# Todo       : Add wrapped items - 1 cycle for more than 1 chameleon entry
#
# History    : /mE 06/04/07 Added to this module description
#              /mE 07-04-24 Added hardcoded wrapper for Nand Flash
################################################################################

sub configEval{
   ## open config file
   my $ref = XMLin($xmlfile);
   my $descriptor;
   # only look at bridge and general descriptors
   my $node;
   my %sdevices;
   my %mcdeviceno;
   my %mcdevices;
   
   $node = get_root();
   
   while (defined($node))
   {
      $descriptor = $node;
      if ($descriptor->getType < 2)
      {
         my $deviceid = $descriptor->getVar("device");
         my $bar = $descriptor->getVar("bar");
         if (($deviceid == 63 || $deviceid == 68)&& $genoffset == 1){
            if (defined($sdevices{70}[$descriptor->{content}->{bar}])){
               my $wrapper = $sdevices{70}[$descriptor->{content}->{bar}];
               print "Info: NAND Flash Device detected!\n";
               push @{$wrapper->{wrapped_desc}}, $descriptor;
               if ($deviceid == 63)
               {
                  print  $descriptor->{content}->{offset}."\n";
                  $wrapper->{content}->{offset} = createHex(hex($descriptor->{content}->{offset}) - hex(600));
                  print  $wrapper->{content}->{offset}."\n";
               }  
               else
               {
                  $wrapper->{content}->{offset} = 0;
               }
               $descriptor->{wrapped} = 1;
               del_desc($descriptor); 
            }
            else
            {
               print "Info: NAND Flash Device detected!\n";
               my $wrapper = Descriptor->new($descriptor->{type});
               $sdevices{70}[$descriptor->{content}->{bar}] = $wrapper;
               $wrapper->{wrapper} = 1;
               $descriptor->{wrapped} = 1;
               push @{$wrapper->{wrapped_desc}}, $descriptor;
               $wrapper->{content}->{size} = 4000;
               $wrapper->{content}->{device} = 70;
               $wrapper->{content}->{instance} = 0;
               $wrapper->{content}->{variant} = 0;
               $wrapper->{content}->{revision} = 0;
               $wrapper->{content}->{bar} = $descriptor->{content}->{bar};
               if ($deviceid == 63)
               {
                  print  $descriptor->{content}->{offset}."\n";
                  $wrapper->{content}->{offset} = $descriptor->{content}->{offset} - 600;
               }  
               else
               {
                  $wrapper->{content}->{offset} = 0;
               }
               $wrapper->{content}->{group} = $descriptor->{content}->{group};
               $wrapper->{content}->{interrupt} = 0;
               $wrapper->{content}->{name} = "NAND WRAPPER";
               $wrapper->{singlecycle} = 1;
               subst_desc($descriptor, $wrapper);
            }
         }   
         elsif (exists($ref->{device}->{$deviceid}->{desc})){
            #print "Found $ref->{device}->{$deviceid}->{desc} in config File\n";
            if (exists($ref->{device}->{$deviceid}->{singlecycle}))
            {
               my $desc = $ref->{device}->{$deviceid}->{desc};
               # A singlecycle Device is a device that has once cycle per bar it exists in
               # The addresses assigned consist of a not splitted block
               # The size is the overall size of all available parts of the module
               # offset is set automatically 
            
               #print "SetSingleCycle for device\n";
               $descriptor->{singlecycle}= $ref->{device}->{$deviceid}->{singlecycle};
               $descriptor->{wrapped} = 1;
               if (defined($sdevices{$deviceid}[$descriptor->{content}->{bar}])){
                  # ADD Descriptor size to wrapper size and add descriptor to wrapper
                  #print "Found Another module in same bar\n";
                  my $wrapper = $sdevices{$deviceid}[$descriptor->{content}->{bar}];
                  
                  $wrapper->addSize($descriptor->{content}->{size});
                  push @{$wrapper->{wrapped_desc}}, $descriptor;
                  $descriptor->{wrapped} = 1;
                  
                  # remove descriptor from chain
                  #print "removing decsriptor from device chain\n";
                  del_desc($descriptor);     
               }
               else
               {
                  my $wrapper = Descriptor->new($descriptor->{type});
                  $sdevices{$deviceid}[$descriptor->{content}->{bar}] = $wrapper;
                  $wrapper->{wrapper} = 1;
                  $descriptor->{wrapped} = 1;
                  push @{$wrapper->{wrapped_desc}}, $descriptor;
                  $wrapper->{content}->{size} = $descriptor->{content}->{size};
                  $wrapper->{content}->{device} = $deviceid;
                  $wrapper->{content}->{instance} = 0;
                  $wrapper->{content}->{variant} = $descriptor->{content}->{variant};
                  $wrapper->{content}->{revision} = $descriptor->{content}->{revision};
                  $wrapper->{content}->{bar} = $descriptor->{content}->{bar};
                  $wrapper->{content}->{offset} = $descriptor->{content}->{offset};
                  $wrapper->{content}->{group} = 0;
                  $wrapper->{content}->{interrupt} = 0;
                  $wrapper->{content}->{name} = $desc;
                  $wrapper->{singlecycle} = 1;
                  #print "Found Singlecycle Device $deviceid and added it to new wrapper\n";
                  subst_desc($descriptor, $wrapper);
                  
                  #print "N->P ".$wrapper->{nxt}->{prv}." W ".$wrapper." N ".$node."\n";
                  #print "Prev: ".$descriptor->{prv}."\n";
                  #print "P->N ".$wrapper->{prv}->{nxt}." W ".$wrapper." N ".$node."\n";
               }              
            } 
            if (exists($ref->{device}->{$deviceid}->{multichannel}))
            {
               if ($descriptor->{content}->{bar} != 0)
               {
                  print "ERROR: Multichannel Devices are only allowed in Bar 0\n";
                  die;
               }
               my $multichannel = $ref->{device}->{$deviceid}->{multichannel};
               my $size = $ref->{device}->{$deviceid}->{size};
               my $desc = $ref->{device}->{$deviceid}->{desc};
               $descriptor->{multichannel}= $multichannel;
               if (exists ($mcdevices{$deviceid})){
                  
                  if (@{$mcdevices{$deviceid}->{wrapped_desc}} < $multichannel){
                     #print "Device $deviceid Section already exists, added this unit\n";
                     push @{$mcdevices{$deviceid}->{wrapped_desc}}, $descriptor;
                     $descriptor->{wrapped} = 1;
                     
                     del_desc($descriptor);
                  }
                  else
                  {
                     #print "Found full wrapper:\n";
                     #$mcdevices{$deviceid}->showAll();
                     #print "Last Wrapper already full, so created new one\n";
                     my $wrapper = Descriptor->new($descriptor->{type});
                     $mcdeviceno{$deviceid}++;
                     
                     $wrapper->{content}->{size} = $size;
                     $wrapper->{content}->{device} = $deviceid;
                     $wrapper->{content}->{instance} = $mcdeviceno{$deviceid};
                     $wrapper->{content}->{variant} = $descriptor->{content}->{variant};
                     $wrapper->{content}->{revision} = $descriptor->{content}->{revision};
                     $wrapper->{content}->{bar} = $descriptor->{content}->{bar};
                     $wrapper->{content}->{offset} = $descriptor->{content}->{offset};
                     $wrapper->{content}->{group} = 0;
                     $wrapper->{content}->{interrupt} = 0;
                     $wrapper->{content}->{name} = $desc;
                     $wrapper->{wrapper} = 1;
                     $descriptor->{wrapped} = 1;
                     $mcdevices{$deviceid} = $wrapper;
                     $wrapper->{multichannel} = $descriptor->{multichannel};
                     push @{$wrapper->{wrapped_desc}}, $descriptor;
                     subst_desc($descriptor, $wrapper);
                     $node = $wrapper;
                  }
               }
               else
               {
                  #print "Create new device $deviceid section\n";
                  
                  my $wrapper = Descriptor->new($descriptor->{type});
                  $mcdeviceno{$deviceid} = 0;
                  
                     $wrapper->{content}->{size} = $size;
                     $wrapper->{content}->{device} = $deviceid;
                     $wrapper->{content}->{instance} = $mcdeviceno{$deviceid};
                     $wrapper->{content}->{variant} = $descriptor->{content}->{variant};
                     $wrapper->{content}->{revision} = $descriptor->{content}->{revision};
                     $wrapper->{content}->{bar} = $descriptor->{content}->{bar};
                     $wrapper->{content}->{offset} = $descriptor->{content}->{offset};
                     $wrapper->{content}->{group} = 0;
                     $wrapper->{content}->{interrupt} = 0;
                     $wrapper->{content}->{name} = $desc;
                     $wrapper->{wrapper} = 1;
                     $descriptor->{wrapped} = 1;
                  $mcdevices{$deviceid} = $wrapper;
                  $wrapper->{multichannel} = $descriptor->{multichannel};                  
                  push @{$wrapper->{wrapped_desc}}, $descriptor;
                  subst_desc($descriptor, $wrapper);
                  $node = $wrapper;
               }
            }    
            if (exists( $ref->{device}->{$deviceid}->{grp}) && $ref->{device}->{$deviceid}->{grp} != "NA" && exists($ref->{device}->{$deviceid}->{grp}[0]))
            {
               #print "Device is group Master\n";
               $descriptor->{master} = 1;
            }
            
         }
         
         
         
         
      }
      $node = $node->{nxt};
      #print "next node\n";
   }   
}



sub configEvalNoAdr{
   ## open config file
   my $ref = XMLin($xmlfile);
   my $descriptor;
   # only look at bridge and general descriptors
   my $node;
   my %sdevices;
   my %mcdeviceno;
   my %mcdevices;
   
   $node = get_root();
   
   while (defined($node))
   {
      $descriptor = $node;
      if ($descriptor->getType < 2)
      {
         my $deviceid = $descriptor->getVar("device");
         my $bar = $descriptor->getVar("bar");
         if (exists($ref->{device}->{$deviceid}->{desc})){
            #print "Found $ref->{device}->{$deviceid}->{desc} in config File\n";
            if (exists($ref->{device}->{$deviceid}->{grp}[0]))
            {
               #print "Device is group Master\n";
               $descriptor->{master} = 1;
            }
            
         }
         
         
         
         
      }
      $node = $node->{nxt};
      #print "next node\n";
   }   
}

sub print_all{
   my $node = $root;
   while (defined($node)){
      $node->showAll;
      $node = $node->{nxt};
   }
}

################################################################################
# subst_desc
################################################################################
# Description: substitutes a descriptor with another descriptor in list
#
# Inputs     : $descriptor     - descriptor old
#              $descriptor_new - new descriptor
#
# Output     : none
#
# History    : /mE 06/04/07 Added to this module description
################################################################################

sub subst_desc{
   my $descriptor = shift;
   my $descriptor_new = shift;
   $descriptor_new->{prv} = $descriptor->{prv};
   $descriptor_new->{nxt} = $descriptor->{nxt};
   my $prev = $descriptor->{prv};
   my $nxt = $descriptor->{nxt};
   $prev->{nxt} = $descriptor_new;# if (defined($descriptor_new->{prv}));
   $nxt->{prv} = $descriptor_new;# if (defined($descriptor_new->{nxt}));
}

################################################################################
# updatePCIHeader
################################################################################
# Description: Updates the PCI Header Hex file
#
# Inputs     : none
#
# Output     : none
#
# History    : /mE 07/09/27 Added to this module
################################################################################

sub updatePCIHeader{
   
   # Check if all needed information is available
   die "Missing information (Device ID) to create pci_header.hex\n Please check your xls" 
      unless defined ($pcidescriptor->{content}->{deviceid}) and $pcidescriptor->{content}->{deviceid} ne "";
   die "Missing information (Vendor ID) to create pci_header.hex\n Please check your xls" 
      unless defined ($pcidescriptor->{content}->{vendorid}) and $pcidescriptor->{content}->{vendorid} ne "";
   die "Missing information (Subsystem ID) to create pci_header.hex\n Please check your xls" 
      unless defined ($pcidescriptor->{content}->{subsysid}) and $pcidescriptor->{content}->{subsysid} ne "";
   die "Missing information (Subsystem Vendor ID) to create pci_header.hex\n Please check your xls" 
      unless defined ($pcidescriptor->{content}->{subsysvend}) and $pcidescriptor->{content}->{subsysvend} ne "";
   die "Missing information (Interrupt Pin) to create pci_header.hex\n Please check your xls" 
      unless defined ($pcidescriptor->{content}->{irqpin}) and $pcidescriptor->{content}->{irqpin} ne "";
   die "Missing information (Interrupt Line) to create pci_header.hex\n Please check your xls" 
      unless defined ($pcidescriptor->{content}->{irqline}) and $pcidescriptor->{content}->{irqline} ne "";
   die "Missing information (Class Code) to create pci_header.hex\n Please check your xls" 
      unless defined ($pcidescriptor->{content}->{classcode}) and $pcidescriptor->{content}->{classcode} ne "";
   die "Missing information (Latency Timer) to create pci_header.hex\n Please check your xls" 
      unless defined ($pcidescriptor->{content}->{lattimer}) and $pcidescriptor->{content}->{lattimer} ne "";
   
   $pcidescriptor->{DescFor} = \@pciHeaderFor;
   my @line;
   my $infile;
   $pcidescriptor->getBytes(\@line);
   # copy pci header hex to pci header backup file in case it exists
   if (-e "pci_header.hex"){
      rename("pci_header.hex", "pci_header.bak") or die "Could not rename pci_header.hex\n";
      $infile = "pci_header.bak";
   }
   else
   {
      if (-e "D:/work/HWARE/Artikel/16/16z014-/source/pci_header.hex"){
         $infile = "D:/work/HWARE/Artikel/16/16z014-/source/pci_header.hex";
      }
      else
      {
         die "ERROR: No default input file for pci header";
      }
   }
   
   # open old PCI header hex
   open(INFILE, "< $infile") or die "ERROR: Could not open $infile for reading";
   
   # open new PCI header hex file
   open(OUTFILE, "> pci_header.hex") or die "ERROR: Could not open pci_header.hex for output";
   
   # copy data into new file unless there is new data for the actual line
   my $i = 0;
   my $adr = 0;
   while (<INFILE>){
      if ($i < @line){
         my@bytes = split(/;/, @line[$i]);
         my@adrslices = unpack("A2" x 2, unpack("H4", pack("i", $adr)));
         $bytes[1] = $adrslices[1];  # adr bytes
         $bytes[2] = $adrslices[0];  # adr bytes
         print OUTFILE uc(makeline(@bytes))."\n"; # call to sub makelines
         $adr++;
         $i++;
      }
      else
      {
         print OUTFILE $_;     
      }
   }
   # close files
   close INFILE;
   close OUTFILE;
   print "Successfully updated pci_header.hex\n";
}


################################################################################
# del_desc
################################################################################
# Description: Deletes a descriptor from list
#
# Inputs     : $descriptor
#
# Output     : none
#
# History    : /mE 06/04/07 Added to this module description
################################################################################

sub del_desc{
   my $descriptor = shift;
   
   my $prev = $descriptor->{prv};
   my $next = $descriptor->{nxt};
   $prev->{nxt} = $next;
   $next->{prv} = $prev;
}

################################################################################
# sortByGroup - for Perl sort()
################################################################################
# Description: sort function - sort by group
#
# Inputs     : n/a
#
# Output     : n/a
#
# History    : /mE 06/04/07 Added to this module description
################################################################################

sub sortByGroup{
      my $groupa = 0;
      my $groupb = 0;
      if (defined $a){
         #if (defined($a->{name})){
            
            $groupa = $a->getHexVar("group");
            
         #}
         #else
         #{
         #   print $a;
         #   print "ERROR in SortByGroup: \$a not defined correctly. ".$a."\n";
         #   exit;
         #}
      }
      if (defined $b){
         #if (defined($a->{name})){
            $groupb = $b->getHexVar("group");
            
         #}
         #else
         #{
         #   print "ERROR in SortByGroup: \$b not defined correctly. ".$b."\n";
         #   exit;
         #}
      }
      #printf "a: %i %15s b: %i %15s \n", $a->{type}, $a->{content}->{name}, $b->{type}, $b->{content}->{name};
      return $groupb-$groupa;
      
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

    printf  "D %s %2i %s: %s\n", $caller, $level, $time, shift @message;
    while ( my $line = shift @message ) {
        printf  "D".( ' ' x (11+length $caller) ).": %s\n", $line;
    }

    #printf STDERR "D %s %2i %s: %s\n", $caller, $level, $time, shift @message;
    #while ( my $line = shift @message ) {
    #    printf STDERR "D".( ' ' x (11+length $caller) ).": %s\n", $line;
    #}
    return 1;
}

1;