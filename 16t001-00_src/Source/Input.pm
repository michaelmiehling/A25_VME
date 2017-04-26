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
# Description: This File contains the XLS Parsing
#		 
# Functional Description: return is the Descriptor array
#
#
################################################################################
#
# History:
#
# $Revision: 1.3 $
#
# $Log: Input.pm,v $
# Revision 1.3  2013/04/19 14:51:19  mernst
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
# Revision 1.2  2008/03/31 14:06:43  mernst
# Changed location
#
# Revision 1.2  2007/04/24 14:21:40  mErnst
# - Added error message in case xls file does not exist
# - Changed push_desc
# - Removed -p option
# - Added -a <type> option to generate wb/pci address decoder
#
# Revision 1.1  2006/04/25 11:48:15  mErnst
# Added automatic offset generation
# Added PCI Address Decoder generation
# Added PCI Wrapper Generation
# Added Configuration File
# Split up file into multiple modules for better handling
# Changed Data format to linked list
#
#
################################################################################

# - Added support for PCI Header values
# - Added support for Model (Char) field
# - Added new debug support

package Input;
use base 'Exporter';
our @EXPORT = ('init_input', 'parseChameleon');
use strict;
use Descriptor;
use HelpFunctions;

use POSIX;

our $DEBUG = 100;

my $debug; # Debug Module
my $genoffset;
my $warning;
my $list_ref;
sub init_input{
   $debug = $_[0];
   if ($debug == 1) {
      debug(1, "Input.pm - Debug enabled\n");
   }
   else
   {
      $DEBUG = 0;
   }
   $genoffset = $_[1];
   $warning = $_[2];
}

sub parseChameleon{
   debug(10, "Called Parse Chameleon\n");
   my $curref;
   my $infile = $_[0];
   my @descriptors;
   my $descriptors_ref = $_[2];
   my $project;
   my $project_ref = $_[1];
   
   my $disccnt = 0;     # Used in Table Parsing
   my $starttable = 0;  # Used in Table Parsing
   my $cnt = 0;         # Used in Table Parsing
   my $descriptor;      # Temporary Descriptor variable
   my @descCont;        # Temporary Descriptor variable
   
   ##########
   # Open Excel
   my @lines;
   my $sR;
   my $sC;
   my $xls;
   my ($iR, $iC, $oWkS, $oWkC, $oWkV);
   
      
   if (-e $infile) {
      print "Opening $infile\n";
      $xls = Spreadsheet::ParseExcel::Workbook->Parse($infile);
   }
   else
   {
      print "Error: $infile not found!\n";
      exit;
   }
   
       
   ##########
   # INPUT SECTION
   foreach my $oWkS (@{$xls->{Worksheet}}) {
      ##########
      ## Search for Header Information in Content Sheet
      if ($oWkS->{Name} =~ /Content/){
         debug(40, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");   
         debug(40, "Header Section\n\n");
         $descriptor = Descriptor->new(99);
         push @descriptors, $descriptor;              # Create new Descriptor object
         #$curref = push_desc($curref, $descriptor);   # push Object into descriptor list
         $descriptor->push_desc();
         
         for(my $iR = $oWkS->{MinRow};defined $oWkS->{MaxRow} && $iR <= $oWkS->{MaxRow}; $iR++) {
            for(my $iC = $oWkS->{MinCol};defined $oWkS->{MaxCol} && $iC <= $oWkS->{MaxCol}; $iC++) {
               $oWkC = $oWkS->{Cells}[$iR][$iC];
               $oWkV = $oWkS->{Cells}[$iR][$iC+1];
               if ($oWkV){
                  if( $oWkC && $oWkC->Value =~ /Bus Type/){
                     debug(40, "Bus Type   ". $oWkV->Value);
                     $descriptor->addVar("bustype", $oWkV->Value);
                  }
                  if( $oWkC && $oWkC->Value =~ /Bus Number/){
                     debug(40, "Bus Number ". $oWkV->Value);
                     $descriptor->addVar("busnumber", $oWkV->Value);
                  }
                  if( $oWkC && $oWkC->Value =~ /Model \(Char\)/){ # Fix to let Model be entered as character
                     my $model = ord($oWkV->Value);
                     debug(40, "Model      ". $model);
                     $descriptor->addVar("model", $model);
                  }
                  elsif( $oWkC && $oWkC->Value =~ /Model/){
                     debug(40, "Model      ". hex($oWkV->Value));
                     $descriptor->addVar("model", hex($oWkV->Value));
                  }
                  
                  if( $oWkC && $oWkC->Value =~ /^Revision/){
                     debug(40, "Revision   ". $oWkV->Value);
                     $descriptor->addVar("revision", $oWkV->Value);
                  }
                  if( $oWkC && $oWkC->Value =~ /^ArchName/){
                     debug(40, "ArchName   ". $oWkV->Value);
                     $descriptor->addVar("archname", $oWkV->Value);
                  }
                  if( $oWkC && $oWkC->Value =~ /^AdrDec/){
                     debug(40, "AdrDec     ". $oWkV->Value);
                     $descriptor->addVar("adrdec", $oWkV->Value);
                  }
                  if( $oWkC && $oWkC->Value =~ /MinRevision/){
                     debug(40, "Revision   ". $oWkV->Value);
                     $descriptor->addVar("minrevision", $oWkV->Value);
                  }
                  if( $oWkC && $oWkC->Value =~ /Filename/){
                     debug(40, "Filename   ". $oWkV->Value);
                     $project = $oWkV->Value;
                     $descriptor->addVar("filename", $oWkV->Value);
                  }
                  # PCI Header Content
                  if( $oWkC && $oWkC->Value =~ /Device ID/){
                     debug(40, "Device ID  ". $oWkV->Value);
                     $descriptor->addVar("deviceid", $oWkV->Value);
                  }
                  if( $oWkC && $oWkC->Value =~ /Vendor ID/){
                     debug(40, "Vendor ID  ". $oWkV->Value);
                     $descriptor->addVar("vendorid", $oWkV->Value);
                  }
                  if( $oWkC && $oWkC->Value =~ /SubSysID/){
                     debug(40, "SubSys ID  ". $oWkV->Value);
                     $descriptor->addVar("subsysid", $oWkV->Value);
                  }
                  if( $oWkC && $oWkC->Value =~ /SubSysVend/){
                     debug(40, "SubSysVend ". $oWkV->Value);
                     $descriptor->addVar("subsysvend", $oWkV->Value);
                  }
                  if( $oWkC && $oWkC->Value =~ /Interrupt Pin/){
                     debug(40, "IRQ Pin    ". $oWkV->Value);
                     $descriptor->addVar("irqpin", $oWkV->Value);
                  }
                  if( $oWkC && $oWkC->Value =~ /Interrupt Line/){
                     debug(40, "IRQ Line   ". $oWkV->Value);
                     $descriptor->addVar("irqline", $oWkV->Value);
                  }
                  if( $oWkC && $oWkC->Value =~ /Class Code/){
                     debug(40, "Class Code ". $oWkV->Value);
                     $descriptor->addVar("classcode", $oWkV->Value);
                  }
                  if( $oWkC && $oWkC->Value =~ /Lat Timer/){
                     debug(40, "Lat Timer  ". $oWkV->Value);
                     $descriptor->addVar("lattimer", $oWkV->Value);
                  }
               }
            }
         }
         debug(40, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n");
      }
      
      ##########
      ## Search for general descriptors
       if ($oWkS->{Name} =~ /Type0-General/){
         $disccnt = 0;
         debug(40, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
         debug(40, "General Descriptors\n\n");
         $starttable = 0;
         
         #Find Table start and save to $sR and $sC
         for(my $iR = $oWkS->{MinRow};defined $oWkS->{MaxRow} && $iR <= $oWkS->{MaxRow}; $iR++) {
            for(my $iC = $oWkS->{MinCol}; defined $oWkS->{MaxCol} && $iC <= $oWkS->{MaxCol}; $iC++) {
               $oWkC = $oWkS->{Cells}[$iR][$iC];
               # Find starting egde of table
               if( $oWkC && $oWkC->Value =~ /Name/){
                  $sR = $iR;
                  $sC = $iC;  
                  $starttable = 1;
               }   
            }
         }
         $iR = $sR+1;
         $iC = $sC;
         $cnt = 0;
         
         
         #Parse Table and save values
         while (defined $oWkS->{MaxRow} && 
                  $iR <= $oWkS->{MaxRow} && 
                  $oWkS->{Cells}[$iR][$iC] &&
                  $oWkS->{Cells}[$iR][$iC]->Value ne ""){
                     
            push @descriptors, Descriptor->new(0);              # Create new Descriptor object
            
            $descriptor = @descriptors[(scalar @descriptors) -1];  # Get Object for local use
            
            #$curref = push_desc($curref, $descriptor);
            $descriptor->push_desc();            
            @descCont = @{$descriptor->{DescCont}};
            
            # while a name is specified, the rest of the fields is used as values
            debug(40, "   --------------------------------------------------------\n");
            debug(40, "   Found Descriptor for ". $oWkS->{Cells}[$iR][$iC]->Value."\n");
            debug(40, "   --------------------------------------------------------\n");
            $disccnt++;
            foreach my $entry (@descCont){
               if($oWkS->{Cells}[$iR][$iC] && $oWkS->{Cells}[$iR][$iC]->Value ne ""){
                  debug(40, "   -".$entry."- ". $oWkS->{Cells}[$iR][$iC]->Value);
                  $entry =~ s/^([a-zA-Z]*)[ ]*$/$1/;
                  $entry = lc($entry);
                  $descriptor->addVar($entry, $oWkS->{Cells}[$iR][$iC++]->Value);
               }
               else
               {
                  if ($entry ne "Offset" || $genoffset == 0)
                  {
                     print "   WARNING: Undefined field in Excel Sheet ",$oWkS->{Name},"\n";
                     print "            $entry not defined in field ", $iR,"-", $iC++,"\n";
                     $warning++;
                  }
                  $entry =~ s/^([a-zA-Z]*)[ ]*$/$1/; 
                  $entry = lc($entry); 
                  $descriptor->addVar($entry,"0");
               }
            }
            debug(40, "   --------------------------------------------------------\n\n");
             
            $iR++;
            $iC = $sC;
         }
         debug(40, "\nFound $disccnt Descriptors in this section\n");
         debug(40, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n");
               
      }
      
      ##########
      ## Search for bridge descriptors
      if ($oWkS->{Name} =~ /Type1-Bridge/){
         $disccnt = 0;
         debug(40, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
         debug(40, "Bridge Descriptors\n\n");
         $starttable = 0;
         
         #Find Table start and save to $sR and $sC
         for(my $iR = $oWkS->{MinRow};defined $oWkS->{MaxRow} && $iR <= $oWkS->{MaxRow}; $iR++) {
            for(my $iC = $oWkS->{MinCol}; defined $oWkS->{MaxCol} && $iC <= $oWkS->{MaxCol}; $iC++) {
               $oWkC = $oWkS->{Cells}[$iR][$iC];
               # Find starting egde of table
               if( $oWkC && $oWkC->Value =~ /Name/){
                   $sR = $iR;
                  $sC = $iC;  
                  $starttable = 1;
               }   
            }
         }
         $iR = $sR+1;
         $iC = $sC;
         $cnt = 0;
        
         
         #Parse Table and save values
         while (defined $oWkS->{MaxRow} && 
                  $iR <= $oWkS->{MaxRow} && 
                  $oWkS->{Cells}[$iR][$iC] &&
                  $oWkS->{Cells}[$iR][$iC]->Value ne ""){
            push @descriptors, Descriptor->new(1);              # Create new Descriptor object
            $descriptor = @descriptors[(scalar @descriptors) -1];  # Get Object for local use
            
            #$curref = push_desc($curref, $descriptor);
            $descriptor->push_desc();
            
            @descCont = @{$descriptor->{DescCont}};
            # while a name is specified, the rest of the fields is used as values
            debug(40, "   --------------------------------------------------------\n");
            debug(40, "   Found Descriptor for ". $oWkS->{Cells}[$iR][$iC]->Value."\n");
            debug(40, "   --------------------------------------------------------\n");
            $disccnt++;
            foreach my $entry (@descCont){
               if($oWkS->{Cells}[$iR][$iC]){
                  debug(40, "   ".$entry." ". $oWkS->{Cells}[$iR][$iC]->Value);
                  $entry =~ s/^([a-zA-Z]*)[ ]*$/$1/; 
                  $entry = lc($entry);   
                  $descriptor->addVar($entry, $oWkS->{Cells}[$iR][$iC++]->Value);
               }
               else
               {
                  if ($entry ne "Offset" || $genoffset == 0)
                  {
                     print "   WARNING: Undefined field in Excel Sheet ",$oWkS->{Name},"\n";
                     print "            $entry not defined in field ", $iR,"-", $iC++,"\n";
                     $warning++;
                  }
                  $entry =~ s/^([a-zA-Z]*)[ ]*$/$1/; 
                  $entry = lc($entry); 
                  $descriptor->addVar($entry,"0");
               }
            }
            debug(40, "   --------------------------------------------------------\n\n");
             
            $iR++;
            $iC = $sC;
         }   
         debug(40, "\nFound $disccnt Descriptors in this section\n");
         debug(40, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n");
           
      }
      
      ##########
      ## Search for CPU descriptors
      if ($oWkS->{Name} =~ /Type2-CPU/){
         $disccnt = 0;
         debug(40, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
         debug(40, "CPU Descriptors\n\n");
         $starttable = 0;
         
         #Find Table start and save to $sR and $sC
         for(my $iR = $oWkS->{MinRow};defined $oWkS->{MaxRow} && $iR <= $oWkS->{MaxRow}; $iR++) {
            for(my $iC = $oWkS->{MinCol}; defined $oWkS->{MaxCol} && $iC <= $oWkS->{MaxCol}; $iC++) {
               $oWkC = $oWkS->{Cells}[$iR][$iC];
               # Find starting egde of table
               if( $oWkC && $oWkC->Value =~ /Name/){
                  $sR = $iR;
                  $sC = $iC;  
                  $starttable = 1;
               }   
            }
         }
         $iR = $sR+1;
         $iC = $sC;
         $cnt = 0;
         
         
         #Parse Table and save values
         while (defined $oWkS->{MaxRow} && 
                  $iR <= $oWkS->{MaxRow} && 
                  $oWkS->{Cells}[$iR][$iC] &&
                  $oWkS->{Cells}[$iR][$iC]->Value ne ""){
            # while a name is specified, the rest of the fields is used as values
            push @descriptors, Descriptor->new(2);              # Create new Descriptor object
            $descriptor = @descriptors[(scalar @descriptors) -1];  # Get Object for local use
            
            #$curref = push_desc($curref, $descriptor);
            $descriptor->push_desc();
            
            @descCont = @{$descriptor->{DescCont}};
            debug(40, "   --------------------------------------------------------\n");
            debug(40, "   Found Descriptor for ". $oWkS->{Cells}[$iR][$iC]->Value."\n");
            debug(40, "   --------------------------------------------------------\n");
            $disccnt++;
            foreach my $entry (@descCont){
               if($oWkS->{Cells}[$iR][$iC]){
                  debug(40, "   ".$entry." ". $oWkS->{Cells}[$iR][$iC]->Value);
                  $entry =~ s/^([a-zA-Z]*)[ ]*$/$1/; 
                  $entry = lc($entry);     
                  $descriptor->addVar($entry, $oWkS->{Cells}[$iR][$iC++]->Value);
               }
               else
               {
                  print "WARNING: Undefined field in Excel Sheet ",$oWkS->{Name},"\n";
                  print "         $entry not defined in field ", $iR,"-", $iC++,"\n";
                  $warning++;
                  $entry =~ s/^([a-zA-Z]*)[ ]*$/$1/; 
                  $entry = lc($entry); 
                  $descriptor->addVar($entry,"0");
               }
            }
            debug(40, "   --------------------------------------------------------\n\n");
                
            
            $iR++;
            $iC = $sC;
         } 
         debug(40, "\nFound $disccnt Descriptors in this section\n");
         debug(40, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n");
             
      }
      
      ##########
      ## Search for BAR descriptors
      if ($oWkS->{Name} =~ /Type3-BAR/){
         $debug = 1;
         $disccnt = 0;
         debug(40, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
         debug(40, "BAR Descriptors\n\n");
         $starttable = 0;
         
         #Find Table start and save to $sR and $sC
         for(my $iR = $oWkS->{MinRow};defined $oWkS->{MaxRow} && $iR <= $oWkS->{MaxRow}; $iR++) {
            for(my $iC = $oWkS->{MinCol}; defined $oWkS->{MaxCol} && $iC <= $oWkS->{MaxCol}; $iC++) {
               $oWkC = $oWkS->{Cells}[$iR][$iC];
               # Find starting egde of table
               if( $oWkC && $oWkC->Value =~ /Name/){
                  $sR = $iR;
                  $sC = $iC;  
                  $starttable = 1;
               }   
            }
         }
         $iR = $sR+1;
         $iC = $sC;
         $cnt = 0;
         # get size of table and if not empty, generate Bar header with Bar count
         while (defined $oWkS->{MaxRow} && 
                  $iR <= $oWkS->{MaxRow} && 
                  $oWkS->{Cells}[$iR][$iC] &&
                  $oWkS->{Cells}[$iR][$iC]->Value ne ""){
            # while a name is specified, the rest of the fields is used as values
            $cnt++;
            $iR++;
            $iC = $sC;
         }
         
         # if a Bar descriptor is needed, the header is created first
         if ($cnt > 0){
            push @descriptors, Descriptor->new(98);              # Create new Descriptor object
            $descriptor = @descriptors[(scalar @descriptors) -1];  # Get Object for local use
            
            $descriptor->addVar("barcnt", $cnt);
            #$curref = push_desc($curref, $descriptor);
            $descriptor->push_desc();
         }
         
         
         $iR = $sR+1;
         $iC = $sC;
         #Parse Table and save values
         while (defined $oWkS->{MaxRow} && 
                  $iR <= $oWkS->{MaxRow} && 
                  $oWkS->{Cells}[$iR][$iC] &&
                  $oWkS->{Cells}[$iR][$iC]->Value ne ""){
            # while a name is specified, the rest of the fields is used as values
            push @descriptors, Descriptor->new(3);              # Create new Descriptor object
            $descriptor = @descriptors[(scalar @descriptors) -1];  # Get Object for local use
            #$curref = push_desc($curref, $descriptor);
            $descriptor->push_desc();
            
            debug(40, "   --------------------------------------------------------\n");
            debug(40, "   Found Descriptor for ". $oWkS->{Cells}[$iR][$iC]->Value."\n");
            debug(40, "   --------------------------------------------------------\n");
            $disccnt++;
            @descCont = @{$descriptor->{DescCont}};
            foreach my $entry (@descCont){
               if($oWkS->{Cells}[$iR][$iC]){
                  debug(40, "   ".$entry." ". $oWkS->{Cells}[$iR][$iC]->Value);  
                  $entry =~ s/^([a-zA-Z]*)[ ]*$/$1/;
                  $entry = lc($entry);    
                  $descriptor->addVar($entry, $oWkS->{Cells}[$iR][$iC++]->Value);
               }
               else
               {
                  print "WARNING: Undefined field in Excel Sheet ",$oWkS->{Name},"\n";
                  print "         $entry not defined in field ", $iR,"-", $iC++,"\n";
                  $warning++;
                  $entry =~ s/^([a-zA-Z]*)[ ]*$/$1/; 
                  $entry = lc($entry); 
                  $descriptor->addVar($entry,"0");
               }
            }
            debug(40, "   --------------------------------------------------------\n\n");
             
            
            
            $iR++;
            $iC = $sC;
         }
         debug(40, "\nFound $disccnt Descriptors in this section\n");
         debug(40, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
         $debug = 0;     
      }
   
   }
   
   ${$project_ref} = $project;
   @{$descriptors_ref} = @descriptors;
   return @descriptors;
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