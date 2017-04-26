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
# Description: This file contains the integrity checks of the table
#		 
#              Performed at the moment are:
#                 - Address Map Check (overlapping areas)
#                 - Bar size (Check Bar descriptors if available)
#                 - Instance numbers - ensure they are unique for each device id
#
################################################################################
#
# History:
#
# $Revision: 1.1 $
#
# $Log: IntegrityCheck.pm,v $
# Revision 1.1  2013/04/19 14:51:09  mernst
# Initial Revision
#
# 
#
#
#
################################################################################

package IntegrityCheck;
use strict;
use Descriptor;
use Pciadr;
use POSIX;

use base 'Exporter';
our @EXPORT = ('init_integrityCheck', 'checkIntegrity', 'check_adr_dec');

our $DEBUG;
my $debug;

sub init_integrityCheck {
  $debug = $_[0];  
  debug(80, "Init of IntegrityCheck done");
}

my %max_instance;
my %max_instance_offset;

sub instance_check {
   my $num_warn = shift;
   my $node = shift;
   
   my $instance = $node->{content}->{instance};
   my $dev_no   = $node->{content}->{device} . "-" . $node->{content}->{variant} ."-". $node->{wrapped};
   my $dev_name = $node->{content}->{name};
   
#   print "$dev_no\n";
#   print "$instance\n";
#   print "$dev_name\n\n";
   
   if (exists($max_instance{$dev_no.$instance})) {
      
      print  "\nWARNING: Duplicate Instance Number\n";
      print  "   ".$dev_name."\n";
      printf "   Bar:        %1d\n", $node->{content}->{bar};
      printf "   Offset:     0x%08x\n", $max_instance_offset{$dev_no.$instance};
      printf "   Offset:     0x%08x\n", hex($node->{content}->{offset});
      printf "   Both using Instance Number %3d\n\n", $instance;
      
      $max_instance{$dev_no.$instance} = $instance;
      $max_instance_offset{$dev_no.$instance} = hex($node->{content}->{offset});
      $num_warn++;
   } else {
      $max_instance{$dev_no.$instance} = $instance;
      $max_instance_offset{$dev_no.$instance} = hex($node->{content}->{offset});
   }   
   return $num_warn;
}


sub checkIntegrity {
   
   Descriptor->sortbyhex("offset");
   Descriptor->sortbyhex("bar");
   
   my $num_warn = 0;
   
   # Iterate through the Descriptors and check the width and the offset and the maximum address of the last item
   
   my $last_offset = -1;
   my $last_size = -1;
   my $last_bar = -1;
   my $last_device = -1;
   my %max_bar;
   my %max_bar_name;
   
   
   # Output violations and overlappings
   
   my $node = get_root();
   
   while (defined($node)) {
      if ($node->{type} == 0) {
         
         my $bar     = $node->{content}->{bar};   
         my $size    = hex($node->{content}->{size});  
         my $offset  = hex($node->{content}->{offset});
         
         if ($last_offset + $last_size > $offset && $bar == $last_bar) {
            
            print "\nWARNING: Possible overlapping area in address mapping\n";
            print  "  +-------------------------------------------------------+\n";
            printf "  | Device: %-45s |\n",$last_device; 
            print  "  +-------------------------------------------------------+\n";
            printf "  |   Bar:    %2i                                          |\n", $last_bar;
            printf "  |   Offset: 0x%08x                                  |\n", $last_offset;
            printf "  |   Size:   0x%08x                                  |\n", $last_size;
            print  "  +-------------------------------------------------------+\n";
            printf "  | Device: %-45s |\n", $node->{content}->{name};
            print  "  +-------------------------------------------------------+\n";
            printf "  |   Bar:    %2i                                          |\n", $bar;
            printf "  |   Offset: 0x%08x                                  |\n", $offset;
            print  "  +-------------------------------------------------------+\n\n";
            
            $num_warn ++;
         }
         $last_offset = $offset;
         $last_size = $size;
         $last_bar = $bar;
         $last_device = $node->{content}->{name};
         
         # Save maximum bar addresses
         if (!exists($max_bar{$bar}) || $max_bar{$bar} < $offset + $size) {
            $max_bar{$bar} = $offset + $size;
            $max_bar_name{$bar} = $node->{content}->{name};
         }         
      }
      $node = $node->{nxt};
   }
   
   # Check maximum address per bar
      # Addresses have been retrieved during last operation - this is just the check comparing the values
     
   my $bar = 0;
   
   $node = get_root();
   
   while (defined($node)) {
     
      if ($node->{type} == 3) {
         
         my $bar_name= $node->{content}->{name};   
         my $baseadr = hex($node->{content}->{baseadr});  
         my $barsize = hex($node->{content}->{barsize});
         
         if ($max_bar{$bar} > $barsize) {
            print  "\nWARNING: Exceeding bar size in $bar_name (Bar $bar)\n";
            printf "   Bar size: %8x\n", $barsize;
            printf "   Max adr:  %8x\n", $max_bar{$bar};
            print  "   used by ".$max_bar_name{$bar}."\n\n";
            $num_warn++;
         }         
         $bar ++;
      }
      
      $node = $node->{nxt};
   } 
   
   Descriptor->sortbyhex("instance");
   
   # Check instances
   $node = get_root();
   while (defined($node)) {
     
      if ($node->{type} == 0) {
         
         # Have to Iterate through wrapped items as well
         if ($node->{wrapper}) {
            foreach my $descriptor (@{$node->{wrapped_desc}}) { 
               $num_warn = instance_check($num_warn, $descriptor);
            }
         } else {
            $num_warn = instance_check($num_warn, $node);
         }
      }
      
      $node = $node->{nxt};
   }  
      # 
   
   
   
   
   return $num_warn;
}

sub check_adr_dec {
   my $warning = 0;
   # Check if an address decoder is available - name is assumed to be wb_adr_dec and pci_adr_dec located in the local folder
   my $adrdectype = lc(Descriptor->getContentVar("adrdec"));
   my $archname = lc(Descriptor->getContentVar("archname"));
   if (!defined($adrdectype)) {
      print "No address decoder type defined, cannot check decoder!";
      return 1;  
   }
      
   Descriptor->sortbyhex("offset");
   Descriptor->sortbyhex("bar");
   
   my $filename = "None";
   
   # Create filename
   if ($adrdectype =~ m/wb/i) {
      $filename = "wb_adr_dec.vhd";
   }
   if (lc($adrdectype) =~ m/pcie/i) {
      $filename = "pcie_adr_dec.vhd";
      chomp $archname;
      if (defined($archname) && $archname ne "") {
         $filename = $archname."_adr_dec.vhd";
      }
   } elsif ($adrdectype =~ m/pci/i) {
      $filename = "pci_adr_dec.vhd";
   }
   
   # Need to retrieve the table from header. The header is the same for all address decoder types
   # The decoder type gives the filename which has to be scanned though
      
   # Open the decoder
   my $rel_path = Descriptor->getContentVar("rel_path");
   print "$filename $archname $adrdectype $rel_path\n";
   
   
   if (-e "$rel_path/$filename") {
      open (ADRDEC, "$rel_path/$filename") or die "ERROR: Could not open address decoder $rel_path/$filename for reading\n\n";
      my $in_table = 0;
      
      my $modtable = generateDUMMYadr();
      my $oldtable = "";
      
      # parse the table
      while(<ADRDEC>) {
         chomp;
         my $line = $_;
         #print $_."\n";  
         if (m/\+-Module Name-*/) {
            $in_table = 1;
            next;
         }
         if (m/\+-*\+/){
            $in_table = 0;
            next;
         }
         if ($in_table == 1) {
            # parse the individual lines and connect the cycles to the offsets and sizes
            $oldtable .= $_ ."\n";
         }
         
      }
      
      
      
      if ($oldtable ne $modtable) {
         print "Warning: Mod Table contained in address decoder does not match the new table.\n";
         print "         The Excel has probably been changed!\n\n";
         print "         Create a new address decoder to ensure the chameleon.hex matches.\n\n";
         $warning++;   
      }
   } else {
      print "Warning: Could not open Address decoder for verification\n\n";
      $warning++;  
   }
   return $warning;
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