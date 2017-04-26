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
# Description: This Package describes the function used to output the excel file
#							 
################################################################################
#
# History:
#
# $Revision: 1.2 $
#
# $Log: WriteChamExcel.pm,v $
# Revision 1.2  2013/04/19 14:51:05  mernst
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
# Revision 1.1  2007/12/12 16:09:34  mernst
# Initial Revision
#
#
################################################################################


package WriteChamExcel;
use base 'Exporter';
our @EXPORT = ('generateExcel');

use Descriptor;
use strict;
use HelpFunctions;
use Spreadsheet::WriteExcel;
use POSIX;


our $DEBUG = 0;

sub generateExcel{
   my $infile = shift;
   # Generate Spreadsheet Filename from project
   $infile =~ s/.xls//;
   #print "Model Found    ".chr(Descriptor->getContentVar("model"))."\n";
   #print "Revision Found ".Descriptor->getContentVar("revision")."\n";
   #print "generating Excel File Name\n";
   #$infile .="_".chr(Descriptor->getContentVar("model")).Descriptor->getContentVar("revision");
   #print $infile.".xls"."\n";
   
   # Check if file already exists and backup file as .bak in case
   if (-e $infile.".xls"){
      print "Excel file already exists, renaming to .bak\n";
      rename $infile.".xls", $infile.".bak" ;
   }
   
   # Create new Excel Spreadsheet
   my $workbook     = Spreadsheet::WriteExcel->new($infile.".xls") or die "Cannot open Excel File - Please make sure it is not opened in Excel and try again!"; 
   
   
   # setup format and headers
   my $f_header  = $workbook->addformat();
   my $f_tb = $workbook->addformat();
   my $f_tb_grey = $workbook->addformat();
   my $f_tb_grey_head = $workbook->addformat();
   my $f_tb_grey_head_rot = $workbook->addformat();
   
   $f_header->set_properties(font => 'Arial', size => 14, num_format => '@');
   $f_tb_grey->set_properties(bg_color => "silver", border => 1, num_format => '@');
   $f_tb->set_properties(border => 1, align => 'right', num_format => '@');
   $f_tb_grey_head->set_properties(bold => 1, bg_color => "silver", border => 1, num_format => '@');
   $f_tb_grey_head_rot->set_properties(bold => 1, bg_color => "silver", rotation => 90, border => 1, align => 'center', num_format => '@');
   
   
   # Format Content Tab
   my $contentsheet = $workbook->addworksheet("Content");
   $contentsheet->write('A1', "Chameleon V2", $f_header);
   $contentsheet->set_column(0, 0, 10.71);
   $contentsheet->set_column(1, 1, 11.57);
   $contentsheet->set_column(2, 3, 13.29);
   my @textarray = ('Bus Type','','Model (Char)','Revision','MinRevision','','Filename','','ArchName','AdrDec','',
                    'Device ID','Vendor ID','SubSysID','SubSysVend','','Interrupt Pin',
                    'Interrupt Line','Class Code','Lat Timer');
   for(my $i = 3; $i < 20; $i++){
      $contentsheet->write($i, 1, "", $f_tb_grey);
      $contentsheet->write($i, 2, "", $f_tb);
   }
   $contentsheet->write_col(3,1,\@textarray, $f_tb_grey);                    
   
   # Add comment boxes
   $contentsheet->write_comment(3,1,"Integer Value\n-------------------------------\nIdentifying the bus type:\n0 - Wishbone\n1 - Avalon\n2 - LPC\n3 - ISA\n", height => 7*14);
   $contentsheet->write_comment(5,1,"ASCII Character\n-------------------------------\nIdentifies the model\n", height => 3*14);
   $contentsheet->write_comment(6,1,"Hex Value\n-------------------------------\nMajor Revision of the FPGA File\n", height => 4*14);
   $contentsheet->write_comment(7,1,"Integer Value\n-------------------------------\nMinor Revision of the FPGA File\nLeave blank for initial Revision\nThe value is incremented automatically by Quartus", height => 8*14);
   $contentsheet->write_comment(9,1,"Text (max 12 chars)\n-------------------------------\nFPGA-filename ASCII encoded", height => 4*14);
   $contentsheet->write_comment(11,1,"Text\n-------------------------------\nArchitecture Name for address decoder\nUsed for PCIe address decoder\n_arch will automatically be appended", height => 8*14);
   $contentsheet->write_comment(12,1,"Text\n-------------------------------\nType of address decoder:\nwb - Wishbone\npci - PCI\npcie - PCI Express", height => 8*14);
   
   # Format General Tab
   my $generalsheet = $workbook->addworksheet("Type0-General");
   $generalsheet->write('A1', "General Descriptors", $f_header);
   $generalsheet->write('B3', "Name", $f_tb_grey_head);
   my @textarray = ('Device','Variant','Revision','Interrupt','Group','Instance','BAR','Offset','Size');
   $generalsheet->write_row(2,2, \@textarray, $f_tb_grey_head_rot);
   $generalsheet->set_column(0, 0, 10.71);
   $generalsheet->set_column(1, 1, 20);
   $generalsheet->set_column(2, 8, 3.57);
   $generalsheet->set_column(10, 11, 8.57);
   for(my $i = 3; $i <18; $i++){
      for(my $k = 2; $k <11; $k++){
         $generalsheet->write($i, $k, "", $f_tb);
      }
      $generalsheet->write($i, 1, "", $f_tb_grey);
   }
   
   $generalsheet->write_comment(2,2,"Integer\n-------------------------------\nDevice ID of the IP Core\ne.g. 87 for Ethernet IP Core", height => 4*14);
   $generalsheet->write_comment(2,3,"Hex Value\n-------------------------------\nVariant of the IP Core\ne.g. 3 for 16z043-03", height => 4*14);
   $generalsheet->write_comment(2,4,"Hex Value\n-------------------------------\nRevision of the IP Core", height => 3*14);
   $generalsheet->write_comment(2,5,"Hex Value\n-------------------------------\nInterrupt vector ID for the core", height => 4*14);
   $generalsheet->write_comment(2,6,"Hex Value\n-------------------------------\nGroup ID", height => 3*14);
   $generalsheet->write_comment(2,7,"Hex Value\n-------------------------------\nInstance of the item. Should be unique for each IP Core", height => 5*14);
   $generalsheet->write_comment(2,8,"Hex Value\n-------------------------------\nBAR the IP Core is located in", height => 4*14);
   $generalsheet->write_comment(2,9,"Hex Value\n-------------------------------\nOffset - may be left blank if auto assignment is used", height => 5*14);
   $generalsheet->write_comment(2,10,"Hex Value\n-------------------------------\nSize - Size of address space used by the IP Core (e.g. 0x100 for 16z087-)", height => 6*14);
   
   # Format Bridge Tab
   my $bridgesheet  = $workbook->addworksheet("Type1-Bridge");
   $bridgesheet->write('A1', "Bridge Descriptors", $f_header);
   $bridgesheet->write('B3', "Name", $f_tb_grey_head);
   my @textarray = ('Device','Variant','Revision','Interrupt','DBAR','Instance','BAR','Cham Offset','Offset','Size');
   $bridgesheet->write_row(2,2, \@textarray, $f_tb_grey_head_rot);
   $bridgesheet->set_column(0,0,  10.71);
   $bridgesheet->set_column(1,1,  20);
   $bridgesheet->set_column(2,6,   7.57);
   $bridgesheet->set_column(7,7,  10.71);
   $bridgesheet->set_column(8,8,   7.57);
   $bridgesheet->set_column(9,11, 7.57);
   for(my $i = 3; $i <18; $i++){
      for(my $k = 2; $k <12; $k++){
         $bridgesheet->write($i, $k, "", $f_tb);
      }
      $bridgesheet->write($i, 1, "", $f_tb_grey);
   }
   
   # Format Cpu Tab
   my $cpusheet     = $workbook->addworksheet("Type2-CPU");
   $cpusheet->write('A1', "CPU Descriptors", $f_header);
   $cpusheet->write('B3', "Name", $f_tb_grey_head);
   my @textarray = ('Device','Variant','Revision','Interrupt','Group','Instance','Boot Address');
   $cpusheet->write_row(2,2, \@textarray, $f_tb_grey_head_rot);
   $cpusheet->set_column(0,0, 10.71);
   $cpusheet->set_column(1,1, 20);
   $cpusheet->set_column(2,6, 7.57);
   $cpusheet->set_column(7,8, 10.71);
   for(my $i = 3; $i <18; $i++){
      for(my $k = 2; $k <9; $k++){
         $cpusheet->write($i, $k, "", $f_tb);
      }
      $cpusheet->write($i, 1, "", $f_tb_grey);
   }
   
   # Format BAR Tab
   my $barsheet     = $workbook->addworksheet("Type3-BAR");
   $barsheet->write('A1', "BAR Descriptors", $f_header);
   $barsheet->write('B3', "Name", $f_tb_grey_head);
   $barsheet->write('C3', "Base Address", $f_tb_grey_head);
   $barsheet->write('D3', "Bar Size", $f_tb_grey_head);
   $barsheet->set_column(0,0, 10.71); 
   $barsheet->set_column(1,1, 20);
   $barsheet->set_column(2,2, 11.71);
   $barsheet->set_column(3,3, 10.71);
   for(my $i = 3; $i <18; $i++){
      for(my $k = 2; $k <4; $k++){
         $barsheet->write($i, $k, "", $f_tb);
      }
      $barsheet->write($i, 1, "", $f_tb_grey);
   }
   
   
   # Generate Entries
   # Go through all nodes and insert values into the excel file
   Descriptor->sortbyhex("offset");
   Descriptor->sortbyhex("bar");
   
   my $node = Descriptor->get_root();
   my $general_line = 3;
   my $bar_line = 3;
   while (defined($node)){
      
      # type content  
      if ($node->{type} == 99){
         debug(50, "Found Content Descriptor - Starting output to Excel File");
         #print "--".$node->{content}->{minrevision}."--\n";
         
         my @textarray = ( $node->{content}->{bustype},
                           '',
                           uc(chr($node->{content}->{model})),
                           $node->{content}->{revision},
                           $node->{content}->{minrevision},
                           '',
                           $node->{content}->{filename},
                           '',
                           $node->{content}->{archname},
                           $node->{content}->{adrdec},
                           '',
                           $node->{content}->{deviceid},
                           $node->{content}->{vendorid},
                           $node->{content}->{subsysid},
                           $node->{content}->{subsysvend},
                           '',
                           $node->{content}->{irqpin},
                           $node->{content}->{irqline},
                           $node->{content}->{classcode},
                           $node->{content}->{lattimer});
         $contentsheet->write_col(3,2,\@textarray, $f_tb);  
         
      }
      elsif ($node->{type} == 0){
         debug(50, "Found General Descriptor - Starting output to Excel File");
         if ($node->{wrapper} == 1){
            my $p = 0;
            while (defined($node->{wrapped_desc}[$p])){
               my $node = $node->{wrapped_desc}[$p];  
               my $offset = $node->{content}->{offset};
               $offset =~ s/^0*(.+)$/$1/;
               
               $generalsheet->write($general_line, 1, $node->{content}->{name}, $f_tb_grey);
               $generalsheet->write_string($general_line, 2, $node->{content}->{device}, $f_tb);
               $generalsheet->write_string($general_line, 3, $node->{content}->{variant}, $f_tb);
               $generalsheet->write_string($general_line, 4, $node->{content}->{revision}, $f_tb);
               $generalsheet->write_string($general_line, 5, $node->{content}->{interrupt}, $f_tb);
               $generalsheet->write_string($general_line, 6, $node->{content}->{group}, $f_tb);
               $generalsheet->write_string($general_line, 7, $node->{content}->{instance}, $f_tb);
               $generalsheet->write_string($general_line, 8, $node->{content}->{bar}, $f_tb);
               $generalsheet->write_string($general_line, 9, $offset, $f_tb);
               $generalsheet->write_string($general_line, 10, $node->{content}->{size}, $f_tb);
               $general_line ++;
               $p++;
            }            
         }
         else
         {
            my $offset = $node->{content}->{offset};
            $offset =~ s/^0*(.+)$/$1/;
          
            $generalsheet->write($general_line, 1, $node->{content}->{name}, $f_tb_grey);
            $generalsheet->write_string($general_line, 2, $node->{content}->{device}, $f_tb);
            $generalsheet->write_string($general_line, 3, $node->{content}->{variant}, $f_tb);
            $generalsheet->write_string($general_line, 4, $node->{content}->{revision}, $f_tb);
            $generalsheet->write_string($general_line, 5, $node->{content}->{interrupt}, $f_tb);
            $generalsheet->write_string($general_line, 6, $node->{content}->{group}, $f_tb);
            $generalsheet->write_string($general_line, 7, $node->{content}->{instance}, $f_tb);
            $generalsheet->write_string($general_line, 8, $node->{content}->{bar}, $f_tb);
            $generalsheet->write_string($general_line, 9, $offset, $f_tb);
            $generalsheet->write_string($general_line, 10, $node->{content}->{size}, $f_tb);
            $general_line ++;
         }
         $generalsheet->data_validation($general_line, 1, $general_line, 10, {validate => "any", show_error => 0}); 
      }
      elsif ($node->{type} == 98) {
         debug(50, "Found Bar Header Descriptor - Bar header only countains the bar count and is not part of the excel sheet");
         
      }
      elsif ($node->{type} == 3) {
         debug(50, "Found Bar Descriptor - Starting output to Excel File");
         $barsheet->write_string($bar_line, 1, "BAR".($bar_line - 3) , $f_tb_grey);
         $barsheet->write_string($bar_line, 2, $node->{content}->{baseadr}, $f_tb);
         $barsheet->write_string($bar_line, 3, $node->{content}->{barsize}, $f_tb);
         
         $bar_line++;
      }
      else
      {
         my $type = $node->{type};
         die "Output for Type $type not supported yet by this script.\n Please contact the author!\n";
      }
      
      $node = $node->{nxt};
   }
   # Close Workbook
   
   
};


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