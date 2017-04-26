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
# Description: This file contains the PCI Address Decoder Creation
#
# Functional Description: write address decoder and instantiantion
#
################################################################################

package Pciadr;
use base 'Exporter';
our @EXPORT = ('init_pciadr', 'generateAdr', 'generateDUMMYadr');
use strict;
use Descriptor;
use HelpFunctions;
use Textblocks;


my $debug; # Debug Module

my $pcidecoder = ""; 
my $wbdecoder = "";
my $modtable ="-- +-Module Name-------------------+-cyc-+---offset-+-----size-+-bar-+\n";   
my $master;
my $project;
my $type;

sub init_pciadr{
   $debug = $_[0];
   $master = $_[1];
   $type = $_[2];
}   

sub generatePciadr;
sub generateWBadr;

sub generateAdr{
   my $var1 = shift;
   my $var2 = shift;
   if ($type =~ m/pcie/i) {
      generatePciEadr($var1, $var2);
      print "Generating PCIe Address Decoder\n";
   }
   elsif ($type =~ m/pci/i) {
      generatePciadr($var1, $var2);
      print "Generating PCI Address Decoder\n";
   }
   elsif ($type =~ m/wb/i) {
      generateWBadr($var1, $var2);
      print "Generating WB Address Decoder\n";
   }
   else
   {
      print "Unknown Address decoder requested - skipped generation\n";
   }
}

sub generateWBadr{
   ## Split up relevant data
   
   my $descriptor;
   my @descriptors = @{$_[0]};
   my $project = $_[1];
   
   ## Sort Descriptors by offset
   Descriptor->sortbyhex("offset");
   Descriptor->sortbyhex("bar");
 
  
   ## Create Adr Dec
   # iterate through the modules to get max offset in bars
   my @maxoffset;
   my @barmask;
   my $barNo = 0;
   my $node = get_root();
   while (defined($node)){
      $descriptor = $node;
      if ($descriptor->getType < 2){
         my $bar     = $descriptor->getVar("bar");
         my $offset  = $descriptor->getVar("offset");
         my $size    = $descriptor->getVar("size");
         if (exists($maxoffset[$bar]))
         {
            if (hex($maxoffset[$bar]) < hex($offset))
            {
               $maxoffset[$bar] = $offset;
               # Find Barsize of each bar
               # ceil to 2^x numbers, so address mask can be used properly
               my $neededexp = 0;
               my $adr =  hex($offset)+hex($size)-1;
               $neededexp++ while ($adr > 2**$neededexp); # increase needed exponent until address is bigger
               $adr = 2**$neededexp;                      # save computed address to variable
               
               $barmask[$bar]   = hex("FFFFFFFF") - $adr + 1; # need to substract 1 as its a mask
            }
         }
         else
         {
            $maxoffset[$bar] = $offset;
            $barmask[$bar]   = hex("FFFFFFFF") - (hex($offset)+hex($size)-1);
         } 
         
         $barNo = $bar if ($barNo < $bar);
      }
      $node = $node->{nxt};
   }
   $barNo++;
   
   ## Create ADR decoders for each Module
   ## 3 cases:
   ## Maxoffset == 0             --> No adr Decoder for Bar
   ## Maxoffset == Size          --> One Bit
   ## Maxoffset > Size           --> More than one Bit
   
   my $moduleNo = 0;
   my $node = get_root();
   while (defined($node)){
      
      $descriptor = $node;
      #print "$node->{content}->{name}\n";
      if ($descriptor->getType < 2){
      
         my $bar     = $descriptor->getVar("bar");
         my $offset  = $descriptor->getVar("offset");
         my $size    = $descriptor->getVar("size");
         my $name    = $descriptor->getVar("name");
         my @mobits  = split (//, createBits($maxoffset[$bar]));
         my @ofbits  = split (//, createBits($offset));
         my @sibits  = split (//, createBits($size));
         my $mo      = $maxoffset[$bar];
         
         # add module Information infront of module and into overview table
         $wbdecoder .= "\n         -- $name - cycle $moduleNo - offset $offset - size $size --\n";
         if ($descriptor->{wrapper} == 1)
         {
            foreach (@{$descriptor->{wrapped_desc}}){
                  my $bar     = $_->getVar("bar");
                  my $offset  = $_->getVar("offset");
                  my $size    = $_->getVar("size");
                  my $name    = $_->getVar("name");
                  $wbdecoder .= "         -- $name - cycle $moduleNo - offset $offset - size $size --\n";
            }  
         }
         $modtable .= sprintf "-- |% 30s |  %2d | %8x | %8x | %3d |\n", $name, $moduleNo, hex($offset), hex($size), $bar;
         
              
         if (hex($mo) != 0)
         {
            if (hex($mo) == hex($size)){
               # One Bit in Adress Decoder
               # Find first Bit on MaxOffset from left
               my $po = 31;
               while ($mobits[$po] == 0)
               {
                  $po--;
               }
               my $bit = $ofbits[$po];
               
               $wbdecoder .= "         IF pci_cyc_i($bar) = '1' AND wbm_adr_o_q($po) = '$bit' THEN\n";
   				$wbdecoder .= "            wbm_cyc_o_int($moduleNo) := '1';\n";
   				$wbdecoder .= "         ELSE\n";
   				$wbdecoder .= "            wbm_cyc_o_int($moduleNo) := '0';\n";
   				$wbdecoder .= "         END IF;\n\n";
               
               $descriptor->setCycleNo($moduleNo);
   				
   				$moduleNo++;
            }
            else
            {
               # Adress range in Adress Decoder
               # Find first Bit on MaxOffset from left
               my $left = 31;
               while ($mobits[$left] == 0 && $left > 0)
               {
                  $left--;
               }
               #Find right alignement in Size
               my $right = 0;
               while ($right < 32 && $sibits[$right] == 0)
               {
                  $right++;
               }
               # Create Bit vector
               my $bitvec = "";
               for (my $i = $left; $i >= $right; $i--)
               {
                $bitvec .= $ofbits[$i];
               }
               $wbdecoder .= "         IF pci_cyc_i($bar) = '1' AND wbm_adr_o_q($left DOWNTO $right) = \"$bitvec\" THEN\n";
   				$wbdecoder .= "            wbm_cyc_o_int($moduleNo) := '1';\n";				
   				$wbdecoder .= "         ELSE\n";
   				$wbdecoder .= "            wbm_cyc_o_int($moduleNo) := '0';\n";
   				$wbdecoder .= "         END IF;\n\n";
               
               $descriptor->setCycleNo($moduleNo);
   				
   				$moduleNo++;
            }
         }
         else
         {
               # No adress Decoder for Bar
               $wbdecoder .= "         IF pci_cyc_i($bar) = '1' THEN\n";
   				$wbdecoder .= "            wbm_cyc_o_int($moduleNo) := '1';\n";				
   				$wbdecoder .= "         ELSE\n";
   				$wbdecoder .= "            wbm_cyc_o_int($moduleNo) := '0';\n";
   				$wbdecoder .= "         END IF;\n\n";
   				
   				$descriptor->setCycleNo($moduleNo);
   								
   				$moduleNo++;
         }
      }
      $node = $node->{nxt};
   }
   
   # Create end of Modtable
   $modtable .= "-- +-------------------------------+-----+----------+----------+-----+";
   
   # Address Chameleon table if no other module is addressed but design hit
   my $zerovec = "";
   for (my $i = 0; $i < $moduleNo;$i++)
   {
      $zerovec .= "0";
   }
   
   $wbdecoder .= "         IF pci_cyc_i /= zero AND wbm_cyc_o_int = \"$zerovec\" THEN\n";
	$wbdecoder .= "            wbm_cyc_o_int(0) := '1';\n";				
	$wbdecoder .= "         END IF;\n\n";
     
   my $rel_path = Descriptor->getContentVar("rel_path");
   
   open (OUTFILE, ">$rel_path/wb_adr_dec.vhd") or die "ERROR: Could not open wb_adr_dec.vhd for output\n";
   print OUTFILE createWBStartString("<$project>", $modtable, $moduleNo, $barNo);
   print OUTFILE $wbdecoder;  
   print OUTFILE createWBEndString();
   close OUTFILE;

}

sub generateDUMMYadr{
   ## Split up relevant data
   my $return_table;
   my $descriptor;
   
   ## Sort Descriptors by offset
   Descriptor->sortbyhex("offset");
   Descriptor->sortbyhex("bar");
 
  
   ## Create Adr Dec
   # iterate through the modules to get max offset in bars
   my @maxoffset;
   my @barmask;
   my $barNo = 0;
   my $node = get_root();
   while (defined($node)){
      $descriptor = $node;
      if ($descriptor->getType < 2){
         my $bar     = $descriptor->getVar("bar");
         my $offset  = $descriptor->getVar("offset");
         my $size    = $descriptor->getVar("size");
         if (exists($maxoffset[$bar]))
         {
            if (hex($maxoffset[$bar]) < hex($offset))
            {
               $maxoffset[$bar] = $offset;
               # Find Barsize of each bar
               # ceil to 2^x numbers, so address mask can be used properly
               my $neededexp = 0;
               my $adr =  hex($offset)+hex($size)-1;
               $neededexp++ while ($adr > 2**$neededexp); # increase needed exponent until address is bigger
               $adr = 2**$neededexp;                      # save computed address to variable
               
               $barmask[$bar]   = hex("FFFFFFFF") - $adr + 1; # need to substract 1 as its a mask
            }
         }
         else
         {
            $maxoffset[$bar] = $offset;
            $barmask[$bar]   = hex("FFFFFFFF") - (hex($offset)+hex($size)-1);
         } 
         
         $barNo = $bar if ($barNo < $bar);
      }
      $node = $node->{nxt};
   }
   $barNo++;
   
   ## Create ADR decoders for each Module
   ## 3 cases:
   ## Maxoffset == 0             --> No adr Decoder for Bar
   ## Maxoffset == Size          --> One Bit
   ## Maxoffset > Size           --> More than one Bit
   
   my $moduleNo = 0;
   my $node = get_root();
   while (defined($node)){
      
      $descriptor = $node;
      #print "$node->{content}->{name}\n";
      if ($descriptor->getType < 2){
      
         my $bar     = $descriptor->getVar("bar");
         my $offset  = $descriptor->getVar("offset");
         my $size    = $descriptor->getVar("size");
         my $name    = $descriptor->getVar("name");
         my @mobits  = split (//, createBits($maxoffset[$bar]));
         my @ofbits  = split (//, createBits($offset));
         my @sibits  = split (//, createBits($size));
         my $mo      = $maxoffset[$bar];
         
         # add module Information infront of module and into overview table
         $wbdecoder .= "\n         -- $name - cycle $moduleNo - offset $offset - size $size --\n";
         if ($descriptor->{wrapper} == 1)
         {
            foreach (@{$descriptor->{wrapped_desc}}){
                  my $bar     = $_->getVar("bar");
                  my $offset  = $_->getVar("offset");
                  my $size    = $_->getVar("size");
                  my $name    = $_->getVar("name");
                  $wbdecoder .= "         -- $name - cycle $moduleNo - offset $offset - size $size --\n";
            }  
         }
         $return_table .= sprintf "-- |% 30s |  %2d | %8x | %8x | %3d |\n", $name, $moduleNo, hex($offset), hex($size), $bar;
      
          
         if (hex($mo) != 0)
         {
            if (hex($mo) == hex($size)){
               
   				$moduleNo++;
            }
            else
            {
          		
   				$moduleNo++;
            }
         }
         else
         {
   				$moduleNo++;
         }
      }
      
      $node = $node->{nxt};
   }
   return $return_table;
}


sub generatePciEadr{
   ## Split up relevant data
   
   my $descriptor;
   my @descriptors = @{$_[0]};
   my $project = $_[1];
   
   ## Sort Descriptors by offset
   Descriptor->sortbyhex("offset");
   Descriptor->sortbyhex("bar");
   
   my $arch_name = Descriptor->getContentVar("archname");
   $arch_name = $arch_name ne "" ? $arch_name : "pcie";
   
   ## Create Adr Dec
   # iterate through the modules to get max offset in bars
   my @maxoffset;
   my @barmask;
   my $barNo = 0;
   my $node = get_root();
   while (defined($node)){
      $descriptor = $node;
      if ($descriptor->getType < 2){
         my $bar     = $descriptor->getVar("bar");
         my $offset  = $descriptor->getVar("offset");
         my $size    = $descriptor->getVar("size");
         if (exists($maxoffset[$bar]))
         {
            if (hex($maxoffset[$bar]) < hex($offset))
            {
               $maxoffset[$bar] = $offset;
               # Find Barsize of each bar
               # ceil to 2^x numbers, so address mask can be used properly
               my $neededexp = 0;
               my $adr =  hex($offset)+hex($size)-1;
               $neededexp++ while ($adr > 2**$neededexp); # increase needed exponent until address is bigger
               $adr = 2**$neededexp;                      # save computed address to variable
               
               $barmask[$bar]   = hex("FFFFFFFF") - $adr + 1; # need to substract 1 as its a mask
            }
         }
         else
         {
            $maxoffset[$bar] = $offset;
            $barmask[$bar]   = hex("FFFFFFFF") - (hex($offset)+hex($size)-1);
         } 
         
         $barNo = $bar if ($barNo < $bar);
      }
      $node = $node->{nxt};
   }
   $barNo++;
   
   ## Create ADR decoders for each Module
   ## 3 cases:
   ## Maxoffset == 0             --> No adr Decoder for Bar
   ## Maxoffset == Size          --> One Bit
   ## Maxoffset > Size           --> More than one Bit
   
   my $moduleNo = 0;
   my $node = get_root();
   while (defined($node)){
      
      $descriptor = $node;
      #print "$node->{content}->{name}\n";
      if ($descriptor->getType < 2){
      
         my $bar     = $descriptor->getVar("bar");
         my $offset  = $descriptor->getVar("offset");
         my $size    = $descriptor->getVar("size");
         my $name    = $descriptor->getVar("name");
         my @mobits  = split (//, createBits($maxoffset[$bar]));
         my @ofbits  = split (//, createBits($offset));
         my @sibits  = split (//, createBits($size));
         my $mo      = $maxoffset[$bar];
         
         # add module Information infront of module and into overview table
         $wbdecoder .= "\n         -- $name - cycle $moduleNo - offset $offset - size $size --\n";
         if ($descriptor->{wrapper} == 1)
         {
            foreach (@{$descriptor->{wrapped_desc}}){
                  my $bar     = $_->getVar("bar");
                  my $offset  = $_->getVar("offset");
                  my $size    = $_->getVar("size");
                  my $name    = $_->getVar("name");
                  $wbdecoder .= "         -- $name - cycle $moduleNo - offset $offset - size $size --\n";
            }  
         }
         $modtable .= sprintf "-- |% 30s |  %2d | %8x | %8x | %3d |\n", $name, $moduleNo, hex($offset), hex($size), $bar;
         
              
         if (hex($mo) != 0)
         {
            if (hex($mo) == hex($size)){
               # One Bit in Adress Decoder
               # Find first Bit on MaxOffset from left
               my $po = 31;
               while ($mobits[$po] == 0)
               {
                  $po--;
               }
               my $bit = $ofbits[$po];
               
               $wbdecoder .= "         IF pci_cyc_i($bar) = '1' AND wbm_adr_o_q($po) = '$bit' THEN\n";
   				$wbdecoder .= "            wbm_cyc_o_int($moduleNo) := '1';\n";
   				$wbdecoder .= "         ELSE\n";
   				$wbdecoder .= "            wbm_cyc_o_int($moduleNo) := '0';\n";
   				$wbdecoder .= "         END IF;\n\n";
               
               $descriptor->setCycleNo($moduleNo);
   				
   				$moduleNo++;
            }
            else
            {
               # Adress range in Adress Decoder
               # Find first Bit on MaxOffset from left
               my $left = 31;
               while ($mobits[$left] == 0 && $left > 0)
               {
                  $left--;
               }
               #Find right alignement in Size
               my $right = 0;
               while ($right < 32 && $sibits[$right] == 0)
               {
                  $right++;
               }
               # Create Bit vector
               my $bitvec = "";
               for (my $i = $left; $i >= $right; $i--)
               {
                $bitvec .= $ofbits[$i];
               }
               $wbdecoder .= "         IF pci_cyc_i($bar) = '1' AND wbm_adr_o_q($left DOWNTO $right) = \"$bitvec\" THEN\n";
   				$wbdecoder .= "            wbm_cyc_o_int($moduleNo) := '1';\n";				
   				$wbdecoder .= "         ELSE\n";
   				$wbdecoder .= "            wbm_cyc_o_int($moduleNo) := '0';\n";
   				$wbdecoder .= "         END IF;\n\n";
               
               $descriptor->setCycleNo($moduleNo);
   				
   				$moduleNo++;
            }
         }
         else
         {
               # No adress Decoder for Bar
               $wbdecoder .= "         IF pci_cyc_i($bar) = '1' THEN\n";
   				$wbdecoder .= "            wbm_cyc_o_int($moduleNo) := '1';\n";				
   				$wbdecoder .= "         ELSE\n";
   				$wbdecoder .= "            wbm_cyc_o_int($moduleNo) := '0';\n";
   				$wbdecoder .= "         END IF;\n\n";
   				
   				$descriptor->setCycleNo($moduleNo);
   								
   				$moduleNo++;
         }
      }
      $node = $node->{nxt};
   }
   
   # Create end of Modtable
   $modtable .= "-- +-------------------------------+-----+----------+----------+-----+";
   
   # Address Chameleon table if no other module is addressed but design hit
   my $zerovec = "";
   for (my $i = 0; $i < $moduleNo;$i++)
   {
      $zerovec .= "0";
   }
   
   $wbdecoder .= "         IF pci_cyc_i /= \"0000000\" AND wbm_cyc_o_int = \"$zerovec\" THEN\n";
	$wbdecoder .= "            wbm_cyc_o_int(0) := '1';\n";
	$wbdecoder .= "         END IF;\n\n";
     
   my $rel_path = Descriptor->getContentVar("rel_path");
   open (OUTFILE, ">$rel_path/".$arch_name."_adr_dec.vhd") or die "ERROR: Could not open ".$arch_name."_adr_dec.vhd for output\n";
   print OUTFILE createPCIeStartString("<$project>", $modtable, $moduleNo, $barNo, $arch_name."_arch");
   print OUTFILE $wbdecoder;  
   print OUTFILE createPCIeEndString($arch_name."_arch");
   close OUTFILE;

}

sub generatePciadr{  
   ## Split up relevant data
   
   my $descriptor;
   my @descriptors = @{$_[0]};
   my $project = $_[1];
   
   ## Sort Descriptors by offset
   Descriptor->sortbyhex("offset");
   Descriptor->sortbyhex("bar");
 
  
   ## Create Adr Dec
   # iterate through the modules to get max offset in bars
   my @maxoffset;
   my @barmask;
   my $barNo = 0;
   my $node = get_root();
   while (defined($node)){
      $descriptor = $node;
      if ($descriptor->getType < 2){
         my $bar     = $descriptor->getVar("bar");
         my $offset  = $descriptor->getVar("offset");
         my $size    = $descriptor->getVar("size");
         if (exists($maxoffset[$bar]))
         {
            if (hex($maxoffset[$bar]) < hex($offset))
            {
               $maxoffset[$bar] = $offset;
               # Find Barsize of each bar
               # ceil to 2^x numbers, so address mask can be used properly
               my $neededexp = 0;
               my $adr =  hex($offset)+hex($size)-1;
               $neededexp++ while ($adr > 2**$neededexp); # increase needed exponent until address is bigger
               $adr = 2**$neededexp;                      # save computed address to variable
               
               $barmask[$bar]   = hex("FFFFFFFF") - $adr + 1; # need to substract 1 as its a mask
            }
         }
         else
         {
            $maxoffset[$bar] = $offset;
            $barmask[$bar]   = hex("FFFFFFFF") - (hex($offset)+hex($size)-1);
         } 
         
         $barNo = $bar if ($barNo < $bar);
      }
      $node = $node->{nxt};
   }
   $barNo++;
   
   ## Create ADR decoders for each Module
   ## 3 cases:
   ## Maxoffset == 0             --> No adr Decoder for Bar
   ## Maxoffset == Size          --> One Bit
   ## Maxoffset > Size           --> More than one Bit
   
   my $moduleNo = 0;
   my $node = get_root();
   while (defined($node)){
      
      $descriptor = $node;
      #print "$node->{content}->{name}\n";
      if ($descriptor->getType < 2){
      
         my $bar     = $descriptor->getVar("bar");
         my $offset  = $descriptor->getVar("offset");
         my $size    = $descriptor->getVar("size");
         my $name    = $descriptor->getVar("name");
         my @mobits  = split (//, createBits($maxoffset[$bar]));
         my @ofbits  = split (//, createBits($offset));
         my @sibits  = split (//, createBits($size));
         my $mo      = $maxoffset[$bar];
         
         # add module Information infront of module and into overview table
         $pcidecoder .= "\n         -- $name - cycle $moduleNo - offset $offset - size $size --\n";
         if ($descriptor->{wrapper} == 1)
         {
            foreach (@{$descriptor->{wrapped_desc}}){
                  my $bar     = $_->getVar("bar");
                  my $offset  = $_->getVar("offset");
                  my $size    = $_->getVar("size");
                  my $name    = $_->getVar("name");
                  $pcidecoder .= "         -- $name - cycle $moduleNo - offset $offset - size $size --\n";
            }  
         }
         $modtable .= sprintf "-- |% 30s |  %2d | %8x | %8x | %3d |\n", $name, $moduleNo, hex($offset), hex($size), $bar;
         
              
         if (hex($mo) != 0)
         {
            if (hex($mo) == hex($size)){
               # One Bit in Adress Decoder
               # Find first Bit on MaxOffset from left
               my $po = 31;
               while ($mobits[$po] == 0)
               {
                  $po--;
               }
               my $bit = $ofbits[$po];
               
               $pcidecoder .= "         IF mod_hit_vec_q($bar) = '1' AND fkt_hit = '1' AND wbm_adr_o_q($po) = '$bit' THEN\n";
   				$pcidecoder .= "            wbm_cyc_o_int($moduleNo) := '1';\n";
   				$pcidecoder .= "         ELSE\n";
   				$pcidecoder .= "            wbm_cyc_o_int($moduleNo) := '0';\n";
   				$pcidecoder .= "         END IF;\n\n";
               
               $descriptor->setCycleNo($moduleNo);
   				
   				$moduleNo++;
            }
            else
            {
               # Adress range in Adress Decoder
               # Find first Bit on MaxOffset from left
               my $left = 31;
               while ($mobits[$left] == 0 && $left > 0)
               {
                  $left--;
               }
               #Find right alignement in Size
               my $right = 0;
               while ($right < 32 && $sibits[$right] == 0)
               {
                  $right++;
               }
               # Create Bit vector
               my $bitvec = "";
               for (my $i = $left; $i >= $right; $i--)
               {
                $bitvec .= $ofbits[$i];
               }
               $pcidecoder .= "         IF mod_hit_vec_q($bar) = '1' AND fkt_hit = '1' AND wbm_adr_o_q($left DOWNTO $right) = \"$bitvec\" THEN\n";
   				$pcidecoder .= "            wbm_cyc_o_int($moduleNo) := '1';\n";				
   				$pcidecoder .= "         ELSE\n";
   				$pcidecoder .= "            wbm_cyc_o_int($moduleNo) := '0';\n";
   				$pcidecoder .= "         END IF;\n\n";
               
               $descriptor->setCycleNo($moduleNo);
   				
   				$moduleNo++;
            }
         }
         else
         {
               # No adress Decoder for Bar
               $pcidecoder .= "         IF mod_hit_vec_q($bar) = '1' AND fkt_hit = '1' THEN\n";
   				$pcidecoder .= "            wbm_cyc_o_int($moduleNo) := '1';\n";				
   				$pcidecoder .= "         ELSE\n";
   				$pcidecoder .= "            wbm_cyc_o_int($moduleNo) := '0';\n";
   				$pcidecoder .= "         END IF;\n\n";
   				
   				$descriptor->setCycleNo($moduleNo);
   								
   				$moduleNo++;
         }
      }
      $node = $node->{nxt};
   }
   
   # Create end of Modtable
   $modtable .= "-- +-------------------------------+-----+----------+----------+-----+";
   
   # Address Chameleon table if no other module is addressed but design hit
   my $zerovec = "";
   for (my $i = 0; $i < $moduleNo;$i++)
   {
      $zerovec .= "0";
   }
   
   $pcidecoder .= "         IF mod_hit_vec_q(5 downto 0) /= \"000000\" AND fkt_hit = '1' AND wbm_cyc_o_int = \"$zerovec\" THEN\n";
	$pcidecoder .= "            wbm_cyc_o_int(0) := '1';\n";				
	$pcidecoder .= "         END IF;\n\n";
     
   my $rel_path = Descriptor->getContentVar("rel_path");
   
   open (OUTFILE, ">$rel_path/pci_adr_dec.vhd") or die "ERROR: Could not open pci_adr_dec.vhd for output\n";
   print OUTFILE createStartString("<$project>", $modtable, $moduleNo);
   print OUTFILE $pcidecoder;  
   print OUTFILE createEndString();
   close OUTFILE;
   
   # Create Instantiation of the PCI Core for Inclusion in Top file
   if (defined($master) and $master == 1)
   {
      $master = "TRUE";
   }
   else
   {
      $master = "FALSE";
   }
   
   for(my $i = 0; $i < 6; $i++){
      $barmask[$i] = hex("ffff0000") unless (exists($barmask[$i]));
   }
   
   # Create PCI Instance
   my $rel_path = Descriptor->getContentVar("rel_path");
   open (OUTFILE, ">$rel_path/pci_inst.vhd") or die "ERROR: Could not open pci_inst.vhd for output\n";
   print OUTFILE createInst($moduleNo, $master, $barmask[0], $barmask[1], $barmask[2], $barmask[3], $barmask[4], $barmask[5], $barNo, $modtable);
   close OUTFILE;
   
   #Create PCI Wrapper
   open (OUTFILE, ">$rel_path/pci_wrap.vhd") or die "ERROR: Could not open pci_wrap.vhd for output\n";
   print OUTFILE createWrapper($moduleNo, $master, $barmask[0], $barmask[1], $barmask[2], $barmask[3], $barmask[4], $barmask[5], $barNo, $modtable, "<$project>");
   close OUTFILE;
   
   
}   
 
 
sub sortByOffset{
   my $bara = $a->getHexVar("bar");
   my $barb = $b->getHexVar("bar");
   if ($bara == $barb){
      my $sizea = $a->getHexVar("offset");
      my $sizeb = $b->getHexVar("offset");
                 
      return $sizea-$sizeb;
      
   }
   else
   {
      return $bara-$barb;
   }
}  
   
1;