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
# Description: This File contains Offset Generation
#		 
# Functional Description: edit the Descriptor array
#
################################################################################
#
# History:
#
# $Revision: 1.3 $
#
# $Log: Offset.pm,v $
# Revision 1.3  2009/03/02 11:04:48  MErnst
# Changed some debug stuff
#
# Revision 1.2  2008/03/31 14:06:45  mernst
# Changed location
#
# Revision 1.1  2006/04/25 11:48:17  mErnst
# Added automatic offset generation
# Added PCI Address Decoder generation
# Added PCI Wrapper Generation
# Added Configuration File
# Split up file into multiple modules for better handling
# Changed Data format to linked list
#
#
################################################################################

package Offset;
use base 'Exporter';
our @EXPORT = ('init_offset', 'generateOffsets');
use strict;
use Descriptor;
use HelpFunctions;


my $debug; # Debug Module
sub init_offset{
   $debug = $_[0];
}   
   
sub generateOffsets{

   my @descriptors;
   
   my $descriptor;  
    
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
   printf "   Chameleon real Size:                         0x%x\n", $tablesize;
   
   my $neededexp = 0;
   $neededexp++ while ($tablesize > 2**$neededexp);
   $tablesize = 2**$neededexp;
   
   printf "   Needed Address space for chameleon table:    0x%x\n\n", $tablesize;

   ##########
   # Split general and bridge descriptors from array
   # and change Chameleon Size while interating through the array
   #  0 General Descriptor
   #  1 Bridge Descriptor
   #  2 CPU Descriptor
   #  3 Bar Descriptor
   # 98 Bar Header
   # 99 Configuration Descriptor (Head)
   
   my @descStart;
   my @descMid;
   my @descEnd;
   my $gotone = 0;
   $node = get_root();
   # save Chameleon size into root
   $node->{chameleonsize} = $tablesize;
   while(defined($node)){
      $descriptor = $node;
      if ($descriptor->getType > 1 && $gotone == 0) 
      {
         push @descStart, $descriptor;         
      }
      if ($descriptor->getType < 2)
      {
         if ($descriptor->getVar("name") =~ /Chameleon/)
         {
            $descriptor->addVar( "size", createHex($tablesize));
         }
         push @descMid, $descriptor;
         $gotone = 1;
      }
      if ($descriptor->getType > 1 && $gotone == 1)
      {
         push @descEnd, $descriptor;
      }
      $node = $node->{nxt};
   }
   
#   
#   foreach $descriptor (@descriptors){
#      
#      if ($descriptor->getType > 1 && $gotone == 0) 
#      {
#         push @descStart, $descriptor;         
#      }
#      if ($descriptor->getType < 2)
#      {
#         if ($descriptor->getVar("name") =~ /Chameleon/)
#         {
#            $descriptor->addVar( "size", createHex($tablesize));
#         }
#         push @descMid, $descriptor;
#         $gotone = 1;
#      }
#      if ($descriptor->getType > 1 && $gotone == 1)
#      {
#         push @descEnd, $descriptor;
#      }
#   }
#   
   ##########
   # Sort by Size
   print "Sort now\n" if $debug == 1;
   @descMid = sort sortBySize @descMid;
   my $chameleon = 0;
   for(my $i = 0; $i < @descMid; $i++)
   {
      my $descriptor = $descMid[$i];
      $descriptor->showAll() if $debug == 1;
      if ($descriptor->getVar("name")  =~ /Chameleon/)
      {
         $chameleon = $i;
         print "Found Chameleon at No $i\n" if $debug == 1;
         $descriptor->showAll() if $debug == 1;
      }
      
   }
   
   my @position;
   my $curBar = -1;
   ##########
   ## Create Offsets
   for (my $i = $chameleon; $i < @descMid; $i++)
   {
      my $descriptor = $descMid[$i];
      
      # check whcih bar is handled and reset current position in bar if new bar starts
      # As we sort by Bar as primary resource, no other security is needed here
      if ($curBar == -1)
      {
         $curBar = $descriptor->getVar("bar");
         $position[$curBar] = 0;
      }
      
      if ($curBar != $descriptor->getVar("bar"))
      {
         $curBar = $descriptor->getVar("bar");
         $position[$curBar] = 0;
      }
      
      $position[$curBar] = createOffset($descriptor, $position[$curBar]);
   }
   
   for (my $i = 0; $i < $chameleon; $i++)
   {
      
      my $descriptor = $descMid[$i];
      
      # Add bigger Modules (sorted before Chameleon)
         $curBar = $descriptor->getVar("bar");
         $position[$curBar] = createOffset($descriptor, $position[$curBar]);
      
   }
   
   # Check for empty bars in the middle
   for (my $i = 0; $i < @position; $i++)
   {
      if (!(exists($position[$i]) && $position[$i] > 0))
      {
         print "ERROR: Bar $i empty allthough there is another bar afterwards\n\n";
         for (my $x = 0; $x < @position; $x++)
         {
            if (!(exists($position[$x])))
            {
               $position[$x] = 0;
            }
            print "Bar $x - size 0x".createHex($position[$x])."\n";
         }
         print "Exiting due to Errors\n";
         exit;
      }
   } 
      
 
   
   ##########
   # Delete old array
   for (my $i = @descriptors; $i >= 0; $i--){
      delete $descriptors[$i];
   }
   
   ##########
   # Readd all elements
   foreach my $value (@descStart)
   {
      push @descriptors, $value;
   }
   
   foreach my $value (@descMid)
   {
      push @descriptors, $value;
   }
   
   foreach my $value (@descEnd)
   {
      push @descriptors, $value;
   }   
   
   ## Output new order
   foreach $descriptor (@descriptors)
   {
      #$descriptor->showAll();
   }
}


sub sortBySize{
   my $bara = $a->getHexVar("bar");
   my $barb = $b->getHexVar("bar");
   if ($bara == $barb){
      my $sizea = $a->getHexVar("size");
      my $sizeb = $b->getHexVar("size");
      print $a->getVar("name")." ".$b->getVar("name")." ";
      print " found cham " if $a->getVar("name") =~ /Chameleon/;
      if ($sizea == $sizeb && $a->getVar("name") =~ /Chameleon/)
      {
         print "a is cham";
         return -1;
      }
      
      if ($sizea == $sizeb && $b->getVar("name") =~ /Chameleon/)
      {
         print "b is cham";
         return 1;
      }
           
      print "\n";
      return $sizeb-$sizea;
      
   }
   else
   {
      return $bara-$barb;
   }
}



1;