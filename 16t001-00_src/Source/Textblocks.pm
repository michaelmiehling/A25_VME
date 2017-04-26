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
# Description: This Package contains all Functions for text output strings
#							 
# Functional Description: Functions in this Module return text strings
#
################################################################################
#
# History:
#
# $Revision: 1.3 $
#
# $Log: Textblocks.pm,v $
# Revision 1.3  2013/04/19 14:51:03  mernst
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
# Revision 1.2  2009/03/02 11:04:38  MErnst
# R: 1. New version of PCI Bus changed vector size of signal mod_hit_vector
# M: 1. Changed width of address decoder signal
#
# Revision 1.1  2007/12/12 16:09:33  mernst
# Initial Revision
#
# Revision 1.2  2007/04/24 14:21:42  mErnst
# - Added error message in case xls file does not exist
# - Changed push_desc
# - Removed -p option
# - Added -a <type> option to generate wb/pci address decoder
#
# Revision 1.1  2006/04/25 11:48:18  mErnst
# Added automatic offset generation
# Added PCI Address Decoder generation
# Added PCI Wrapper Generation
# Added Configuration File
# Split up file into multiple modules for better handling
# Changed Data format to linked list
#
#
################################################################################

package Textblocks;
use base 'Exporter';
our @EXPORT = ('init_textblocks', 'createWBStartString', 'createWBEndString', 'createStartString', 'createEndString', 'createInst', 'createWrapper', 'createPCIeStartString', 'createPCIeEndString');


use strict;
use HelpFunctions;

my $debug;
my $date;
my $version;

sub init_textblocks{
   $debug   = $_[0];
   $version = $_[1];
   $date    = $_[2];
}

################################################################################
# createStartString
################################################################################
# Description: returns the start of the address decoder (WB)
#
# Inputs     : [0] project name
#              [1] module table description for header
#              [2] number of modules
#         
# Output     : string
#
# History    : /mE 07/04/23 Added
################################################################################
sub createWBStartString{
   my $project = $_[0];
   my $modtable = $_[1];
   my $modulNo  = $_[2];
   my $barno    = $_[3];
   my @now = localtime(time());
   my $date_now = ($now[5]+1900)."/".($now[4]+1)."/".$now[3]."  -  ".$now[2].":".$now[1].":".$now[0];
   my $copyr = $now[5]+1900;
return "
---------------------------------------------------------------
-- Title         : Adress decoder for whisbone bus
-- Project       : $project
---------------------------------------------------------------
-- File          : wb_adr_dec.vhd
-- Author        : Chameleon_V2.exe
-- Email         : michael.ernst\@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : $date_now
---------------------------------------------------------------
-- Simulator     : 
-- Synthesis     : 
---------------------------------------------------------------
-- Description : Created with Chameleon_V2.exe  
--               v$version 
--               $date
--
-- 
$modtable
--
--
---------------------------------------------------------------
-- Hierarchy:
--
-- 
---------------------------------------------------------------
-- Copyright (C) $copyr, MEN Mikroelektronik Nuernberg GmbH
--
--   All rights reserved. Reproduction in whole or part is 
--      prohibited without the written permission of the 
--                    copyright owner.           
---------------------------------------------------------------
--                         History                                    
---------------------------------------------------------------
-- ".chr(0x24)."Revision: ".chr(0x24)."
--
-- ".chr(0x24)."Log: ".chr(0x24)."
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.all;

ENTITY wb_adr_dec IS
PORT (
   pci_cyc_i      : IN std_logic_vector(".($barno-1)." DOWNTO 0);
   wbm_adr_o_q    : IN std_logic_vector(31 DOWNTO 2);

   wbm_cyc_o      : OUT std_logic_vector(".($modulNo-1)." DOWNTO 0)

   );
END wb_adr_dec;

ARCHITECTURE wb_adr_dec_arch OF wb_adr_dec IS 
SIGNAL zero : std_logic_vector(".($barno-1)." DOWNTO 0);
BEGIN
   zero <= (OTHERS => '0');
   PROCESS(wbm_adr_o_q, pci_cyc_i)
      VARIABLE wbm_cyc_o_int : std_logic_vector(".($modulNo-1)." DOWNTO 0);
      BEGIN
         wbm_cyc_o_int := (OTHERS => '0');

			";
}

################################################################################
# createEndString
################################################################################
# Description: returns the end of the address decoder (WB)
#
# Inputs     : none
#         
# Output     : string
#
# History    : /mE 07/04/23 Added to this module
################################################################################
sub createWBEndString{
 return "  	
      wbm_cyc_o <= wbm_cyc_o_int;
	  	
	  	END PROCESS;
	  
END wb_adr_dec_arch;
 ";
}

################################################################################
# createStartString
################################################################################
# Description: returns the start of the address decoder (WB)
#
# Inputs     : [0] project name
#              [1] module table description for header
#              [2] number of modules
#         
# Output     : string
#
# History    : /mE 07/04/23 Added
################################################################################
sub createPCIeStartString{
   my $project = $_[0];
   my $modtable = $_[1];
   my $modulNo  = $_[2];
   my $barno    = $_[3];
   my $arch_name = $_[4];
   my @now = localtime(time());
   my $date_now = ($now[5]+1900)."/".($now[4]+1)."/".$now[3]."  -  ".$now[2].":".$now[1].":".$now[0];
   my $copyr = $now[5]+1900;
   
return "
---------------------------------------------------------------
-- Title         : Adress decoder for PCIe
-- Project       : $project
---------------------------------------------------------------
-- File          : ".$arch_name."_adr_dec.vhd
-- Author        : Chameleon_V2.exe
-- Email         : michael.ernst\@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : $date_now
---------------------------------------------------------------
-- Simulator     : 
-- Synthesis     : 
---------------------------------------------------------------
-- Description : Created with Chameleon_V2.exe  
--               v$version 
--               $date
--
-- 
$modtable
--
--
---------------------------------------------------------------
-- Hierarchy:
--
-- 
---------------------------------------------------------------
-- Copyright (C) $copyr, MEN Mikroelektronik Nuernberg GmbH
--
--   All rights reserved. Reproduction in whole or part is 
--      prohibited without the written permission of the 
--                    copyright owner.           
---------------------------------------------------------------
--                         History                                    
---------------------------------------------------------------
-- ".chr(0x24)."Revision: ".chr(0x24)."
--
-- ".chr(0x24)."Log: ".chr(0x24)."
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.all;

ARCHITECTURE $arch_name OF z091_01_wb_adr_dec IS 
BEGIN
   PROCESS(wbm_adr_o_q, pci_cyc_i)
      VARIABLE wbm_cyc_o_int : std_logic_vector(".($modulNo-1)." DOWNTO 0);
      BEGIN
         wbm_cyc_o_int := (OTHERS => '0');

			";
}


################################################################################
# createEndString
################################################################################
# Description: returns the end of the address decoder (WB)
#
# Inputs     : none
#         
# Output     : string
#
# History    : /mE 07/04/23 Added to this module
################################################################################
sub createPCIeEndString{
   
 my $arch_name = $_[0];
 return "  	
      wbm_cyc_o <= wbm_cyc_o_int;
	  	
	  	END PROCESS;
	  
END $arch_name;
 ";
}

################################################################################
# createStartString
################################################################################
# Description: returns the start of the address decoder
#
# Inputs     : [0] project name
#              [1] module table description for header
#              [2] number of modules
#         
# Output     : string
#
# History    : /mE 06/03/03 Added to this module
################################################################################
sub createStartString{
   my $project = $_[0];
   my $modtable = $_[1];
   my $modulNo  = $_[2];
   my @now = localtime(time());
   my $date_now = ($now[5]+1900)."/".($now[4]+1)."/".$now[3]."  -  ".$now[2].":".$now[1].":".$now[0];
   my $copyr = $now[5]+1900;
return "
---------------------------------------------------------------
-- Title         : Adress decoder for whisbone bus
-- Project       : $project
---------------------------------------------------------------
-- File          : pci_adr_dec.vhd
-- Author        : Chameleon_V2.exe
-- Email         : michael.ernst\@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : $date_now
---------------------------------------------------------------
-- Simulator     : 
-- Synthesis     : 
---------------------------------------------------------------
-- Description : Created with Chameleon_V2.exe  
--               v$version 
--               $date
--
-- 
$modtable
--
--
---------------------------------------------------------------
-- Hierarchy:
--
-- 
---------------------------------------------------------------
-- Copyright (C) $copyr, MEN Mikroelektronik Nuernberg GmbH
--
--   All rights reserved. Reproduction in whole or part is 
--      prohibited without the written permission of the 
--                    copyright owner.           
---------------------------------------------------------------
--                         History                                    
---------------------------------------------------------------
-- ".chr(0x24)."Revision: ".chr(0x24)."
--
-- ".chr(0x24)."Log: ".chr(0x24)."
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.all;

ENTITY pci_adr_dec IS
PORT (
	mod_hit_vec_q	: IN std_logic_vector(5 DOWNTO 0);
	wbm_adr_o_q		: IN std_logic_vector(31 DOWNTO 2);
	fkt_hit_q		: IN std_logic_vector(8 DOWNTO 1);

	wbm_cyc_o		: OUT std_logic_vector(".($modulNo-1)." DOWNTO 0)

     );
END pci_adr_dec;

ARCHITECTURE pci_adr_dec_arch OF pci_adr_dec IS 

BEGIN

	PROCESS(mod_hit_vec_q, wbm_adr_o_q, fkt_hit_q)
		VARIABLE wbm_cyc_o_int : std_logic_vector(".($modulNo-1)." DOWNTO 0);
		VARIABLE fkt_hit : std_logic;
	  BEGIN
	  	wbm_cyc_o_int := (OTHERS => '0');

		
			fkt_hit := fkt_hit_q(1);
			
			";
}

################################################################################
# createEndString
################################################################################
# Description: returns the end of the address decoder
#
# Inputs     : none
#         
# Output     : string
#
# History    : /mE 06/03/03 Added to this module
################################################################################
sub createEndString{
 return "  	
	  	wbm_cyc_o <= wbm_cyc_o_int;
	  	
	  END PROCESS;
	  
END pci_adr_dec_arch;
 ";
}



################################################################################
# createInst
################################################################################
# Description: returns the Instantiation of the PCI Core
#
# Inputs     : [0] Number of Modules
#              [1] Master True/False
#              [2]..[7] Bar Masks
#              [8] Number of Bars
#              [9] Module Table Overview 
#         
# Output     : string
#
# History    : /mE 06/03/03 Added to this module
################################################################################
sub createInst{
   my @barmask;
   my $modulNo = $_[0];
   my $master  = $_[1];
   $barmask[0] = createHex($_[2]);
   $barmask[1] = createHex($_[3]);
   $barmask[2] = createHex($_[4]);
   $barmask[3] = createHex($_[5]);
   $barmask[4] = createHex($_[6]);
   $barmask[5] = createHex($_[7]);
   my $barNo = $_[8];
   my $modtable = $_[9];
   
   return "--
--
-- PCI Mapping
--
$modtable
--
--

SIGNAL wbmo_0_cyc		: std_logic_vector(".($modulNo-1)." DOWNTO 0);

COMPONENT pci_top
GENERIC (
	pci_header_string : string:= \"pci_header.hex\";			-- path of pci-header file
	falling_edge_reg	: boolean:= FALSE; 						-- adds falling edge register for pci-input signals
	pci_mstr_used		: boolean := FALSE;						-- true: pci-master will be inserted
																			-- false: pci-master won't be inserted
	no_of_functions	: integer := 3;							-- 1 to 8 functions supported
	no_of_bar      		: int_array := (4, 0, 0, 0, 0, 0, 0, 0);-- number of bars
	no_of_comp			: integer := 3;							-- number of cyc signals
	disc_cnt_en			: boolean := TRUE;						-- enables the disconnect counter
	disc_cnt_q			: std_logic_vector(3 DOWNTO 0):=\"1000\";-- defines the number of clk-cycles after a retry will be done in case the wb-answer takes more time (default: \"1000\"
	bar_mask_f1 		: bar_type := (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",	x\"ffff0001\", x\"ffff0000\", x\"ffff0000\");	-- bar5,4,3,2,1,0
	bar_mask_f2 		: bar_type := (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",	x\"ffff0001\", x\"ffff0000\", x\"ffff0000\");	-- bar5,4,3,2,1,0
	bar_mask_f3 		: bar_type := (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",	x\"ffff0001\", x\"ffff0000\", x\"ffff0000\");	-- bar5,4,3,2,1,0
	bar_mask_f4 		: bar_type := (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",	x\"ffff0001\", x\"ffff0000\", x\"ffff0000\");	-- bar5,4,3,2,1,0
	bar_mask_f5 		: bar_type := (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",	x\"ffff0001\", x\"ffff0000\", x\"ffff0000\");	-- bar5,4,3,2,1,0
	bar_mask_f6 		: bar_type := (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",	x\"ffff0001\", x\"ffff0000\", x\"ffff0000\");	-- bar5,4,3,2,1,0
	bar_mask_f7 		: bar_type := (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",	x\"ffff0001\", x\"ffff0000\", x\"ffff0000\");	-- bar5,4,3,2,1,0
	bar_mask_f8 		: bar_type := (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",	x\"ffff0001\", x\"ffff0000\", x\"ffff0000\") 	-- bar5,4,3,2,1,0																			
	);
PORT (
	-- pci-bus
	clk			: IN  std_logic;									-- 33MHz or 66MHz
	rst_n			: IN  std_logic;									-- async system reset
	ad				: INOUT  std_logic_vector(31 DOWNTO 0);	-- adress/data lines
	cbe_n			: INOUT  std_logic_vector(3 DOWNTO 0);		-- command/byte enables
	par			: INOUT  std_logic;								-- parity
	frame_n		: INOUT  std_logic; 								-- cycle frame
	trdy_n		: INOUT  std_logic; 								-- target ready
	irdy_n		: INOUT  std_logic; 								-- initiator ready
	stop_n		: INOUT  std_logic; 								-- stop for target abort
	devsel_n		: INOUT  std_logic; 								-- device select
	idsel_i		: IN  std_logic; 									-- initialisation device select
	perr_n		: INOUT  std_logic; 								-- parity error
	serr_n		: INOUT  std_logic; 								-- system error
	req_n			: OUT  std_logic; 								-- request bus
	gnt_n			: IN  std_logic; 									-- grant bus
	inta_n		: OUT  std_logic; 								-- interrupt request
	
	test			: OUT std_logic_vector(7 DOWNTO 0);			-- test signals

	-- whisbone bus
	wb_int		: IN  std_logic; 									-- interrupt request line
	
	-- whisbone master bus
	wbm_stb_o	: OUT std_logic;									-- strobe (request)
	wbm_adr_o	: OUT std_logic_vector(31 DOWNTO 0);		-- address
	wbm_dat_o	: OUT std_logic_vector(31 DOWNTO 0);		-- data out
	wbm_sel_o	: OUT std_logic_vector(3 DOWNTO 0);			-- byte enables
	wbm_we_o		: OUT std_logic;									-- 1=write, 0=read
	wbm_tga_o	: OUT std_logic_vector(5 DOWNTO 0);			-- additional information (bar-encoding)
	wbm_bte_o	: OUT std_logic_vector(1 DOWNTO 0);			-- block transfer type
	wbm_cti_o	: OUT std_logic_vector(2 DOWNTO 0);			-- transfer mode
	wbm_ack_i	: IN std_logic;									-- acknoledge
	wbm_dat_i	: IN std_logic_vector(31 DOWNTO 0);			-- data in
	wbm_cyc_o	: OUT std_logic_vector( (no_of_comp - 1) DOWNTO 0);	-- chip selects
	
	-- whisbone slave bus
	wbs_stb_i	: IN std_logic;									-- strobe (request)
	wbs_adr_i	: IN std_logic_vector(31 DOWNTO 0);			-- address
	wbs_dat_i	: IN std_logic_vector(31 DOWNTO 0);			-- data input
	wbs_sel_i	: IN std_logic_vector(3 DOWNTO 0);			-- byte enables
	wbs_we_i		: IN std_logic;									-- 1=write, 0=read
	wbs_tga_i	: IN std_logic_vector(5 DOWNTO 0);			-- additional information (not used)
	wbs_bte_i	: IN std_logic_vector(1 DOWNTO 0);			-- block transfer type
	wbs_cti_i	: IN std_logic_vector(2 DOWNTO 0);			-- transfer mode
	wbs_ack_o	: OUT std_logic;									-- acknoledge
	wbs_err_o	: OUT std_logic;									-- error
	wbs_dat_o	: OUT std_logic_vector(31 DOWNTO 0);		-- data output
	wbs_cyc_i	: IN std_logic										-- chip select
	
     );
END COMPONENT;



the_pci_top : pci_top
GENERIC MAP(
   pci_header_string => \"pci_header.hex\",                -- path of pci-header file
   falling_edge_reg  => FALSE,                           -- adds falling edge register for pci-input signals
   pci_mstr_used     => $master,                           -- true: pci-master will be inserted
                                                         -- false: pci-master won't be inserted
   no_of_bar         => ($barNo, 0, 0, 0, 0, 0, 0, 0),        -- number of bars for function 1,2,3,4,5,6,7,8                                                         
   no_of_functions   => 1,                               -- 1 to 8 functions supported
   no_of_comp        => $modulNo,                               -- number of cyc signals
   disc_cnt_en       => TRUE,                            -- enables the disconnect counter
   disc_cnt_q        => \"1000\",                          -- defines the number of clk-cycles after a retry will be done in case the wb-answer takes more time (default: \"1000\"
   bar_mask_f1       => (x\"$barmask[5]\", x\"$barmask[4]\", x\"$barmask[3]\",   x\"$barmask[2]\", x\"$barmask[1]\", x\"$barmask[0]\"),   -- bar5,4,3,2,1,0
   bar_mask_f2       => (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",   x\"ffff0001\", x\"ffff0000\", x\"ffff0000\"),   -- bar5,4,3,2,1,0
   bar_mask_f3       => (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",   x\"ffff0001\", x\"ffff0000\", x\"ffff0000\"),   -- bar5,4,3,2,1,0
   bar_mask_f4       => (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",   x\"ffff0001\", x\"ffff0000\", x\"ffff0000\"),   -- bar5,4,3,2,1,0
   bar_mask_f5       => (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",   x\"ffff0001\", x\"ffff0000\", x\"ffff0000\"),   -- bar5,4,3,2,1,0
   bar_mask_f6       => (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",   x\"ffff0001\", x\"ffff0000\", x\"ffff0000\"),   -- bar5,4,3,2,1,0
   bar_mask_f7       => (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",   x\"ffff0001\", x\"ffff0000\", x\"ffff0000\"),   -- bar5,4,3,2,1,0
   bar_mask_f8       => (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",   x\"ffff0001\", x\"ffff0000\", x\"ffff0000\")    -- bar5,4,3,2,1,0                                                
   )
PORT MAP(
   -- pci-bus
   clk         => clk33,                                    -- 33MHz or 66MHz
   rst_n       => rst_n,                                    -- async system reset
   ad          => ad,                                       -- adress/data lines
   cbe_n       => cbe_n,                                    -- command/byte enables
   par         => par,                                      -- parity
   frame_n     => frame_n,                                  -- cycle frame
   trdy_n      => trdy_n,                                   -- target ready
   irdy_n      => irdy_n,                                   -- initiator ready
   stop_n      => stop_n,                                   -- stop for target abort
   devsel_n    => devsel_n,                                 -- device select
   idsel_i     => idsel_i,                                  -- initialisation device select
   perr_n      => perr_n,                                   -- parity error
   serr_n      => serr_n,                                   -- system error
   req_n       => req_n,                                    -- request bus
   gnt_n       => gnt_n,                                    -- grant bus
   inta_n      => OPEN,                                     -- interrupt request
   
   test        => OPEN,                                     -- test signals

   -- whisbone bus
   wb_int      => '0',                                      -- interrupt request line
   
   -- whisbone master bus
	wbm_stb_o	=> wbmo_0.stb,                               -- strobe (request)
	wbm_adr_o	=> wbmo_0.adr,                               -- address
	wbm_dat_o	=> wbmo_0.dat,                               -- data out
	wbm_sel_o	=> wbmo_0.sel,                               -- byte enables
	wbm_we_o		=> wbmo_0.we,                                -- 1=write, 0=read
	wbm_tga_o	=> wbmo_0.tga,                               -- additional information (bar-encoding)
	wbm_bte_o	=> wbmo_0.bte,                               -- block transfer type
	wbm_cti_o	=> wbmo_0.cti,                               -- transfer mode
	wbm_ack_i	=> wbmi_0.ack,                               -- acknowledge
	wbm_dat_i	=> wbmi_0.dat,                               -- data in
	wbm_cyc_o	=> wbmo_0_cyc,                               -- chip selects
   
	-- whisbone slave bus         
	wbs_stb_i	=> wbsi_0.stb,                               -- strobe (request)
	wbs_adr_i	=> wbsi_0.adr,                               -- address
	wbs_dat_i	=> wbsi_0.dat,                               -- data input
	wbs_sel_i	=> wbsi_0.sel,                               -- byte enables
	wbs_we_i		=> wbsi_0.we,                                -- 1=write, 0=read
	wbs_tga_i	=> wbsi_0.tga,                               -- additional information (not used)
	wbs_bte_i	=> wbsi_0.bte,                               -- block transfer type
	wbs_cti_i	=> wbsi_0.cti,                               -- transfer mode
--	wbs_ack_o	=> wbso_0.ack,                               -- acknoledge
--	wbs_err_o	=> wbso_0.err,                               -- error
--	wbs_dat_o	=> wbso_0.dat,                               -- data output
	wbs_cyc_i	=> '0' -- not used                           -- chip select
   
     );   
     
     
     
the_pci_wrap : pci_wrap
PORT MAP(
   -- pci-bus
   clk         => clk33,                                    -- 33MHz or 66MHz
   rst_n       => rst_n,                                    -- async system reset
   ad          => ad,                                       -- adress/data lines
   cbe_n       => cbe_n,                                    -- command/byte enables
   par         => par,                                      -- parity
   frame_n     => frame_n,                                  -- cycle frame
   trdy_n      => trdy_n,                                   -- target ready
   irdy_n      => irdy_n,                                   -- initiator ready
   stop_n      => stop_n,                                   -- stop for target abort
   devsel_n    => devsel_n,                                 -- device select
   idsel_i     => idsel_i,                                  -- initialisation device select
   perr_n      => perr_n,                                   -- parity error
   serr_n      => serr_n,                                   -- system error
   req_n       => req_n,                                    -- request bus
   gnt_n       => gnt_n,                                    -- grant bus
   inta_n      => OPEN,                                     -- interrupt request
   
   test        => OPEN,                                     -- test signals

   -- whisbone bus
   wb_int      => '0',                                      -- interrupt request line
   
   -- whisbone master bus
	wbm_stb_o	=> wbmo_0.stb,                               -- strobe (request)
	wbm_adr_o	=> wbmo_0.adr,                               -- address
	wbm_dat_o	=> wbmo_0.dat,                               -- data out
	wbm_sel_o	=> wbmo_0.sel,                               -- byte enables
	wbm_we_o		=> wbmo_0.we,                                -- 1=write, 0=read
	wbm_tga_o	=> wbmo_0.tga,                               -- additional information (bar-encoding)
	wbm_bte_o	=> wbmo_0.bte,                               -- block transfer type
	wbm_cti_o	=> wbmo_0.cti,                               -- transfer mode
	wbm_ack_i	=> wbmi_0.ack,                               -- acknowledge
	wbm_dat_i	=> wbmi_0.dat,                               -- data in
	wbm_cyc_o	=> wbmo_0_cyc,                               -- chip selects
   
	-- whisbone slave bus         
	wbs_stb_i	=> wbsi_0.stb,                               -- strobe (request)
	wbs_adr_i	=> wbsi_0.adr,                               -- address
	wbs_dat_i	=> wbsi_0.dat,                               -- data input
	wbs_sel_i	=> wbsi_0.sel,                               -- byte enables
	wbs_we_i		=> wbsi_0.we,                                -- 1=write, 0=read
	wbs_tga_i	=> wbsi_0.tga,                               -- additional information (not used)
	wbs_bte_i	=> wbsi_0.bte,                               -- block transfer type
	wbs_cti_i	=> wbsi_0.cti,                               -- transfer mode
--	wbs_ack_o	=> wbso_0.ack,                               -- acknoledge
--	wbs_err_o	=> wbso_0.err,                               -- error
--	wbs_dat_o	=> wbso_0.dat,                               -- data output
	wbs_cyc_i	=> '0' -- not used                           -- chip select
   
     );   
   ";
}

################################################################################
# createWrapper
################################################################################
# Description: returns the Wrapper for the PCI Core
#
# Inputs     : [0] Number of Modules
#              [1] Master True/False
#              [2]..[7] Bar Masks
#              [8] Number of Bars
#              [9] Module Table Overview 
#         
# Output     : string
#
# History    : /mE 06/04/18 Added to this module
################################################################################
sub createWrapper{
   my @barmask;
   my $modulNo = $_[0];
   my $mod_range = $modulNo - 1;
   my $master  = $_[1];
   $barmask[0] = createHex($_[2]);
   $barmask[1] = createHex($_[3]);
   $barmask[2] = createHex($_[4]);
   $barmask[3] = createHex($_[5]);
   $barmask[4] = createHex($_[6]);
   $barmask[5] = createHex($_[7]);
   my $barNo = $_[8];
   my $modtable = $_[9];
   my $project = $_[10];
   my @now = localtime(time());
   my $date_now = ($now[5]+1900)."/".($now[4]+1)."/".$now[3]."  -  ".$now[2].":".$now[1].":".$now[0];
   my $copyr = $now[5]+1900;
   
   return "
   ---------------------------------------------------------------
-- Title         : Adress decoder for whisbone bus
-- Project       : $project
---------------------------------------------------------------
-- File          : pci_wrap.vhd
-- Author        : Chameleon_V2.exe
-- Email         : michael.ernst\@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : $date_now
---------------------------------------------------------------
-- Simulator     : 
-- Synthesis     : 
---------------------------------------------------------------
-- Description : Created with Chameleon_V2.exe  
--               v$version 
--               $date
--
-- 
$modtable
--
--
---------------------------------------------------------------
-- Hierarchy:
--
-- 
---------------------------------------------------------------
-- Copyright (C) $copyr, MEN Mikroelektronik Nuernberg GmbH
--
--   All rights reserved. Reproduction in whole or part is 
--      prohibited without the written permission of the 
--                    copyright owner.           
---------------------------------------------------------------
--                         History                                    
---------------------------------------------------------------
-- ".chr(0x24)."Revision: ".chr(0x24)."
--
-- ".chr(0x24)."Log: ".chr(0x24)."
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.all;
USE work.pci_pkg.ALL;

ENTITY pci_wrap IS
PORT (
	-- pci-bus
	clk			: IN  std_logic;									-- 33MHz or 66MHz
	rst_n			: IN  std_logic;									-- async system reset
	ad				: INOUT  std_logic_vector(31 DOWNTO 0);	-- adress/data lines
	cbe_n			: INOUT  std_logic_vector(3 DOWNTO 0);		-- command/byte enables
	par			: INOUT  std_logic;								-- parity
	frame_n		: INOUT  std_logic; 								-- cycle frame
	trdy_n		: INOUT  std_logic; 								-- target ready
	irdy_n		: INOUT  std_logic; 								-- initiator ready
	stop_n		: INOUT  std_logic; 								-- stop for target abort
	devsel_n		: INOUT  std_logic; 								-- device select
	idsel_i		: IN  std_logic; 									-- initialisation device select
	perr_n		: INOUT  std_logic; 								-- parity error
	serr_n		: INOUT  std_logic; 								-- system error
	req_n			: OUT  std_logic; 								-- request bus
	gnt_n			: IN  std_logic; 									-- grant bus
	inta_n		: OUT  std_logic; 								-- interrupt request
	
	test			: OUT std_logic_vector(7 DOWNTO 0);			-- test signals

	-- whisbone bus
	wb_int		: IN  std_logic; 									-- interrupt request line
	
	-- whisbone master bus
	wbm_stb_o	: OUT std_logic;									-- strobe (request)
	wbm_adr_o	: OUT std_logic_vector(31 DOWNTO 0);		-- address
	wbm_dat_o	: OUT std_logic_vector(31 DOWNTO 0);		-- data out
	wbm_sel_o	: OUT std_logic_vector(3 DOWNTO 0);			-- byte enables
	wbm_we_o		: OUT std_logic;									-- 1=write, 0=read
	wbm_tga_o	: OUT std_logic_vector(5 DOWNTO 0);			-- additional information (bar-encoding)
	wbm_bte_o	: OUT std_logic_vector(1 DOWNTO 0);			-- block transfer type
	wbm_cti_o	: OUT std_logic_vector(2 DOWNTO 0);			-- transfer mode
	wbm_ack_i	: IN std_logic;									-- acknoledge
	wbm_dat_i	: IN std_logic_vector(31 DOWNTO 0);			-- data in
	wbm_cyc_o	: OUT std_logic_vector( $mod_range DOWNTO 0);	-- chip selects
	
	-- whisbone slave bus
	wbs_stb_i	: IN std_logic;									-- strobe (request)
	wbs_adr_i	: IN std_logic_vector(31 DOWNTO 0);			-- address
	wbs_dat_i	: IN std_logic_vector(31 DOWNTO 0);			-- data input
	wbs_sel_i	: IN std_logic_vector(3 DOWNTO 0);			-- byte enables
	wbs_we_i		: IN std_logic;									-- 1=write, 0=read
	wbs_tga_i	: IN std_logic_vector(5 DOWNTO 0);			-- additional information (not used)
	wbs_bte_i	: IN std_logic_vector(1 DOWNTO 0);			-- block transfer type
	wbs_cti_i	: IN std_logic_vector(2 DOWNTO 0);			-- transfer mode
	wbs_ack_o	: OUT std_logic;									-- acknoledge
	wbs_err_o	: OUT std_logic;									-- error
	wbs_dat_o	: OUT std_logic_vector(31 DOWNTO 0);		-- data output
	wbs_cyc_i	: IN std_logic										-- chip select
	
     );
END ENTITY pci_wrap;


ARCHITECTURE pci_wrap_arch of pci_wrap IS

COMPONENT pci_top
GENERIC (
	pci_header_string : string:= \"pci_header.hex\";			-- path of pci-header file
	falling_edge_reg	: boolean:= FALSE; 						-- adds falling edge register for pci-input signals
	pci_mstr_used		: boolean := FALSE;						-- true: pci-master will be inserted
																			-- false: pci-master won't be inserted
	no_of_functions	: integer := 3;							-- 1 to 8 functions supported
	no_of_bar      		: int_array := (4, 0, 0, 0, 0, 0, 0, 0);-- number of bars
	no_of_comp			: integer := 3;							-- number of cyc signals
	disc_cnt_en			: boolean := TRUE;						-- enables the disconnect counter
	disc_cnt_q			: std_logic_vector(3 DOWNTO 0):=\"1000\";-- defines the number of clk-cycles after a retry will be done in case the wb-answer takes more time (default: \"1000\"
	bar_mask_f1 		: bar_type := (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",	x\"ffff0001\", x\"ffff0000\", x\"ffff0000\");	-- bar5,4,3,2,1,0
	bar_mask_f2 		: bar_type := (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",	x\"ffff0001\", x\"ffff0000\", x\"ffff0000\");	-- bar5,4,3,2,1,0
	bar_mask_f3 		: bar_type := (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",	x\"ffff0001\", x\"ffff0000\", x\"ffff0000\");	-- bar5,4,3,2,1,0
	bar_mask_f4 		: bar_type := (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",	x\"ffff0001\", x\"ffff0000\", x\"ffff0000\");	-- bar5,4,3,2,1,0
	bar_mask_f5 		: bar_type := (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",	x\"ffff0001\", x\"ffff0000\", x\"ffff0000\");	-- bar5,4,3,2,1,0
	bar_mask_f6 		: bar_type := (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",	x\"ffff0001\", x\"ffff0000\", x\"ffff0000\");	-- bar5,4,3,2,1,0
	bar_mask_f7 		: bar_type := (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",	x\"ffff0001\", x\"ffff0000\", x\"ffff0000\");	-- bar5,4,3,2,1,0
	bar_mask_f8 		: bar_type := (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",	x\"ffff0001\", x\"ffff0000\", x\"ffff0000\") 	-- bar5,4,3,2,1,0																			
	);
PORT (
	-- pci-bus
	clk			: IN  std_logic;									-- 33MHz or 66MHz
	rst_n			: IN  std_logic;									-- async system reset
	ad				: INOUT  std_logic_vector(31 DOWNTO 0);	-- adress/data lines
	cbe_n			: INOUT  std_logic_vector(3 DOWNTO 0);		-- command/byte enables
	par			: INOUT  std_logic;								-- parity
	frame_n		: INOUT  std_logic; 								-- cycle frame
	trdy_n		: INOUT  std_logic; 								-- target ready
	irdy_n		: INOUT  std_logic; 								-- initiator ready
	stop_n		: INOUT  std_logic; 								-- stop for target abort
	devsel_n		: INOUT  std_logic; 								-- device select
	idsel_i		: IN  std_logic; 									-- initialisation device select
	perr_n		: INOUT  std_logic; 								-- parity error
	serr_n		: INOUT  std_logic; 								-- system error
	req_n			: OUT  std_logic; 								-- request bus
	gnt_n			: IN  std_logic; 									-- grant bus
	inta_n		: OUT  std_logic; 								-- interrupt request
	
	test			: OUT std_logic_vector(7 DOWNTO 0);			-- test signals

	-- whisbone bus
	wb_int		: IN  std_logic; 									-- interrupt request line
	
	-- whisbone master bus
	wbm_stb_o	: OUT std_logic;									-- strobe (request)
	wbm_adr_o	: OUT std_logic_vector(31 DOWNTO 0);		-- address
	wbm_dat_o	: OUT std_logic_vector(31 DOWNTO 0);		-- data out
	wbm_sel_o	: OUT std_logic_vector(3 DOWNTO 0);			-- byte enables
	wbm_we_o		: OUT std_logic;									-- 1=write, 0=read
	wbm_tga_o	: OUT std_logic_vector(5 DOWNTO 0);			-- additional information (bar-encoding)
	wbm_bte_o	: OUT std_logic_vector(1 DOWNTO 0);			-- block transfer type
	wbm_cti_o	: OUT std_logic_vector(2 DOWNTO 0);			-- transfer mode
	wbm_ack_i	: IN std_logic;									-- acknoledge
	wbm_dat_i	: IN std_logic_vector(31 DOWNTO 0);			-- data in
	wbm_cyc_o	: OUT std_logic_vector( (no_of_comp - 1) DOWNTO 0);	-- chip selects
	
	-- whisbone slave bus
	wbs_stb_i	: IN std_logic;									-- strobe (request)
	wbs_adr_i	: IN std_logic_vector(31 DOWNTO 0);			-- address
	wbs_dat_i	: IN std_logic_vector(31 DOWNTO 0);			-- data input
	wbs_sel_i	: IN std_logic_vector(3 DOWNTO 0);			-- byte enables
	wbs_we_i		: IN std_logic;									-- 1=write, 0=read
	wbs_tga_i	: IN std_logic_vector(5 DOWNTO 0);			-- additional information (not used)
	wbs_bte_i	: IN std_logic_vector(1 DOWNTO 0);			-- block transfer type
	wbs_cti_i	: IN std_logic_vector(2 DOWNTO 0);			-- transfer mode
	wbs_ack_o	: OUT std_logic;									-- acknoledge
	wbs_err_o	: OUT std_logic;									-- error
	wbs_dat_o	: OUT std_logic_vector(31 DOWNTO 0);		-- data output
	wbs_cyc_i	: IN std_logic										-- chip select
	
     );
END COMPONENT;

BEGIN


the_pci_top : pci_top
GENERIC MAP(
   pci_header_string => \"pci_header.hex\",                -- path of pci-header file
   falling_edge_reg  => FALSE,                           -- adds falling edge register for pci-input signals
   pci_mstr_used     => $master,                           -- true: pci-master will be inserted
                                                         -- false: pci-master won't be inserted
   no_of_bar         => ($barNo, 0, 0, 0, 0, 0, 0, 0),        -- number of bars for function 1,2,3,4,5,6,7,8                                                         
   no_of_functions   => 1,                               -- 1 to 8 functions supported
   no_of_comp        => $modulNo,                               -- number of cyc signals
   disc_cnt_en       => TRUE,                            -- enables the disconnect counter
   disc_cnt_q        => \"1000\",                          -- defines the number of clk-cycles after a retry will be done in case the wb-answer takes more time (default: \"1000\"
   bar_mask_f1       => (x\"$barmask[5]\", x\"$barmask[4]\", x\"$barmask[3]\",   x\"$barmask[2]\", x\"$barmask[1]\", x\"$barmask[0]\"),   -- bar5,4,3,2,1,0
   bar_mask_f2       => (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",   x\"ffff0001\", x\"ffff0000\", x\"ffff0000\"),   -- bar5,4,3,2,1,0
   bar_mask_f3       => (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",   x\"ffff0001\", x\"ffff0000\", x\"ffff0000\"),   -- bar5,4,3,2,1,0
   bar_mask_f4       => (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",   x\"ffff0001\", x\"ffff0000\", x\"ffff0000\"),   -- bar5,4,3,2,1,0
   bar_mask_f5       => (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",   x\"ffff0001\", x\"ffff0000\", x\"ffff0000\"),   -- bar5,4,3,2,1,0
   bar_mask_f6       => (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",   x\"ffff0001\", x\"ffff0000\", x\"ffff0000\"),   -- bar5,4,3,2,1,0
   bar_mask_f7       => (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",   x\"ffff0001\", x\"ffff0000\", x\"ffff0000\"),   -- bar5,4,3,2,1,0
   bar_mask_f8       => (x\"ffff0000\", x\"ffff0008\", x\"ffff0000\",   x\"ffff0001\", x\"ffff0000\", x\"ffff0000\")    -- bar5,4,3,2,1,0                                                
   )
PORT MAP(
   -- pci-bus
   clk         => clk,                                    -- 33MHz or 66MHz
   rst_n       => rst_n,                                    -- async system reset
   ad          => ad,                                       -- adress/data lines
   cbe_n       => cbe_n,                                    -- command/byte enables
   par         => par,                                      -- parity
   frame_n     => frame_n,                                  -- cycle frame
   trdy_n      => trdy_n,                                   -- target ready
   irdy_n      => irdy_n,                                   -- initiator ready
   stop_n      => stop_n,                                   -- stop for target abort
   devsel_n    => devsel_n,                                 -- device select
   idsel_i     => idsel_i,                                  -- initialisation device select
   perr_n      => perr_n,                                   -- parity error
   serr_n      => serr_n,                                   -- system error
   req_n       => req_n,                                    -- request bus
   gnt_n       => gnt_n,                                    -- grant bus
   inta_n      => inta_n,                                     -- interrupt request
   
   test        => test,                                     -- test signals

   -- whisbone bus
   wb_int      => '0',                                      -- interrupt request line
   
   -- whisbone master bus
	wbm_stb_o	=> wbm_stb_o,                               -- strobe (request)
	wbm_adr_o	=> wbm_adr_o,                               -- address
	wbm_dat_o	=> wbm_dat_o,                               -- data out
	wbm_sel_o	=> wbm_sel_o,                               -- byte enables
	wbm_we_o		=> wbm_we_o,                                -- 1=write, 0=read
	wbm_tga_o	=> wbm_tga_o,                               -- additional information (bar-encoding)
	wbm_bte_o	=> wbm_bte_o,                               -- block transfer type
	wbm_cti_o	=> wbm_cti_o,                               -- transfer mode
	wbm_ack_i	=> wbm_ack_i,                               -- acknowledge
	wbm_dat_i	=> wbm_dat_i,                               -- data in
	wbm_cyc_o	=> wbm_cyc_o,                               -- chip selects
   
	-- whisbone slave bus         
	wbs_stb_i	=> wbs_stb_i,                               -- strobe (request)
	wbs_adr_i	=> wbs_adr_i,                               -- address
	wbs_dat_i	=> wbs_dat_i,                               -- data input
	wbs_sel_i	=> wbs_sel_i,                               -- byte enables
	wbs_we_i		=> wbs_we_i,                                -- 1=write, 0=read
	wbs_tga_i	=> wbs_tga_i,                               -- additional information (not used)
	wbs_bte_i	=> wbs_bte_i,                               -- block transfer type
	wbs_cti_i	=> wbs_cti_i,                               -- transfer mode
	wbs_ack_o	=> wbs_ack_o,                               -- acknoledge
	wbs_err_o	=> wbs_err_o,                               -- error
	wbs_dat_o	=> wbs_dat_o,                               -- data output
	wbs_cyc_i	=> wbs_cyc_i-- not used                     -- chip select
   
     );
     
END ARCHITECTURE pci_wrap_arch; 
   ";
}

1;