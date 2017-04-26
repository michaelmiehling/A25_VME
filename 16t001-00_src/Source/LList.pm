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
################################################################################
#
# History:
#
# $Revision: 1.1 $
#
# $Log: LList.pm,v $
# Revision 1.1  2007/12/12 16:09:30  mernst
# Initial Revision
#
# Revision 1.1  2006/04/25 11:48:16  mErnst
# Added automatic offset generation
# Added PCI Address Decoder generation
# Added PCI Wrapper Generation
# Added Configuration File
# Split up file into multiple modules for better handling
# Changed Data format to linked list
#
#
################################################################################

package LList;
use strict;
use Descriptor;


################################################################################
# new
################################################################################
# Description: Create a new list and return blessed reference on it
#
# Inputs     : none
#              
#         
# Output     : blessed reference on list object
#
# History    : /mE 06/03/14 Added to this module
################################################################################
sub new{
   my $class = shift;
   my $self  =  {};
   my $root  = new_list_item();
   $self->{root} = \$root;
   #print "Created Root\n";
   #print $self->{root}."\n\n";
   return bless $self, $class;
}

################################################################################
# new_list_item
################################################################################
# Description: Create a new list item and return blessed reference on it
#
# Inputs     : none
#              
#         
# Output     : blessed reference on list object
#
# History    : /mE 06/03/14 Added to this module
################################################################################
sub new_list_item{
   my $class = shift;
   my $self = {};
   return bless $self, $class;
}

################################################################################
# list_push
################################################################################
# Description: add object t o end of list ... function interates through the 
#              list and stops at the end of the list 
#
# Inputs     : obj (ref to object), (node)
#              
#         
# Output     : blessed reference on list object
#
# History    : /mE 06/03/14 Added to this module
################################################################################
sub list_push{
   my $self = shift;
   my $obj  = shift;
   my $node = shift;
   if ($node == undef)
   {
      $node = $self->{root};
      #print "\n--- NEW ITEM ---\n";
   }
   if ($$node->{nxt} == undef)
   {
      my $newitem   = new_list_item();
      $$node->{nxt} = \$newitem;
      $newitem->{obj} = $obj;
      $newitem->{prv} = $node;
      #print "Added Descriptor to list:\n";
      #print "obj ".$newitem->{obj}."\n";
      #print $newitem->{obj}."\n";
   }
   else
   {
      $self->list_push($obj, $$node->{nxt});
   }
}

################################################################################
# nxt
################################################################################
# Description: returns the node after the given node
#
# Inputs     : node - return first node if undef
#         
# Output     : reference on list object
#
# History    : /mE 06/03/14 Added to this module
################################################################################
sub nxt{
   my $self = shift;
   my $node = shift;
   if ($node == undef)
   {
   $node = $self->{root};
   }
   
   my $startnode = $self->{root};
   while ($startnode != $node)
   {
      $startnode = $$startnode->{nxt};
   }
   #print "return $$startnode->{nxt} \n";
   return  $$startnode->{nxt};
}

1;