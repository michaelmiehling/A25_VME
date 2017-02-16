--------------------------------------------------------------------------------
-- Title         : WBB to VME Bridge
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : wbb2vme_top.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 13/01/12
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- The IP-core WBB2VME is used for interfacing the VME bus as master and as 
-- slave. It is able to control external driver chips as 74VMEH22501 or 74ABT125. 
-- An external SRAM is used for shared memory applications and can be accessed 
-- from CPU and VME side. 
-- The main functions of the 16z002-01 are: 
--	o Wishbone to VME access: VME master D08(EO):D16:D32:D64:A16:A24:A32; BLT; 
--   non-privileged program/data; supervisory
--	o VME to Wishbone access: VME slave D08(EO):D16:D32:D64:A16:A24:A32; BLT
--	o VME slave access routing to SRAM or other bus via Wishbone bus (e.g. PCI)
--	o VME Slot1 function with auto-detection
--	o VME Interrupter D08(O):I(7-1):ROAK
--	o VME Interrupt Handler D08(O):IH(7-1)
--	o VME Bus requester 
--  o ROR (release on request); 
--  o RWD (release-when done); 
--  o SGL (single level 3 fair requester)
--	o VME multi-level 0-3 bus arbiter
--	o BTO – VME Bus time out
--	o ADO – VME Address only cycles
--	o mailbox functionality
--	o VME location monitor A16:A24:A32
--	o DMA controller with scatter gather capabilities (A24; A32; D32; D64; 
--   non-privileged; supervisory)
--	o DMA access capabilities VME, SRAM and other bus via Wishbone bus (e.g. PCI)
--	o VME utility functions
--	o access to 1 MByte local SRAM accessible via Wishbone bus
--	o VME Slot geographical addressing

--------------------------------------------------------------------------------
-- Hierarchy:
--
-- wbb2vme
--    vme_ctrl
--       vme_du
--       vme_au
--       vme_locmon
--       vme_mailbox
--       vme_master
--       vme_slave
--       vme_requester
--       vme_bustimer
--       vme_sys_arbiter
--       vme_arbiter
--       vme_wbm
--       vme_wbs
--    vme_dma
--       vme_dma_mstr
--       vme_dma_slv
--       vme_dma_arbiter
--       vme_dma_du
--       vme_dma_au
--       vme_dma_fifo
--          fifo_256x32bit
--------------------------------------------------------------------------------
-- Copyright (c) 2016, MEN Mikro Elektronik GmbH
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------------
-- History:
--------------------------------------------------------------------------------
-- $Revision: 1.7 $
--
-- $Log: wbb2vme_top.vhd,v $
-- Revision 1.7  2015/09/16 09:19:48  mwawrik
-- Added generics A16_REG_MAPPING and USE_LONGADD
--
-- Revision 1.6  2014/04/17 07:35:18  MMiehling
-- added generic LONGADD_SIZE
-- added status outputs vme_berr and vme_mstr_busy
-- added signal prevent_sysrst
--
-- Revision 1.5  2013/09/12 08:45:19  mmiehling
-- added bit 8 of tga for address modifier extension
--
-- Revision 1.4  2012/11/15 09:43:50  MMiehling
-- connected each interrupt source to interface in order to support edge triggered msi
--
-- Revision 1.3  2012/09/25 11:21:37  MMiehling
-- added wbm_err signal for error signalling from pcie to vme
--
-- Revision 1.2  2012/08/27 12:57:00  MMiehling
-- changed comments
--
-- Revision 1.1  2012/03/29 10:14:27  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.vme_pkg.all;

ENTITY wbb2vme_top IS
GENERIC (
   A16_REG_MAPPING   : boolean := TRUE;                        -- if true, access to vme slave A16 space goes to vme runtime registers and above 0x800 to sram (compatible to old revisions)
                                                               -- if false, access to vme slave A16 space goes to sram
   LONGADD_SIZE      : integer range 3 TO 8:=3;
   USE_LONGADD       : boolean := TRUE                          -- If FALSE, bits (7 DOWNTO 5) of SIGNAL longadd will be allocated to vme_adr_out(31 DOWNTO 29)
   );
PORT (
   clk               : IN std_logic;                      -- 66 MHz
   rst               : IN std_logic;                      -- global reset signal (asynch)
   startup_rst       : IN std_logic;                      -- powerup reset
   postwr            : OUT std_logic;                     -- posted write
   vme_irq           : OUT std_logic_vector(7 DOWNTO 0);  -- interrupt request to pci-bus
   berr_irq          : OUT std_logic;                     -- signal berrn interrupt request
   locmon_irq        : OUT std_logic_vector(1 DOWNTO 0);  -- interrupt request location monitor to pci-bus
   mailbox_irq       : OUT std_logic_vector(1 DOWNTO 0);  -- interrupt request mailbox to pci-bus
   dma_irq           : OUT std_logic;                     -- interrupt request dma to pci-bus
   prevent_sysrst    : IN std_logic;                      -- if "1", sysrst_n_out will not be activated after powerup,
                                                          -- if "0", sysrst_n_out will be activated if in slot1 and system reset is active (sysc_bit or rst)
   test_vec          : OUT test_vec_type;

   -- vmectrl slave
   wbs_stb_i         : IN std_logic;
   wbs_ack_o         : OUT std_logic;
   wbs_err_o         : OUT std_logic;
   wbs_we_i          : IN std_logic;
   wbs_sel_i         : IN std_logic_vector(3 DOWNTO 0);
   wbs_cyc_i         : IN std_logic;
   wbs_adr_i         : IN std_logic_vector(31 DOWNTO 0);
   wbs_dat_o         : OUT std_logic_vector(31 DOWNTO 0);
   wbs_dat_i         : IN std_logic_vector(31 DOWNTO 0);
   wbs_tga_i         : IN std_logic_vector(8 DOWNTO 0);

   -- vmectrl master
   wbm_ctrl_stb_o    : OUT std_logic;
   wbm_ctrl_ack_i    : IN std_logic;
   wbm_ctrl_err_i    : IN std_logic;
   wbm_ctrl_we_o     : OUT std_logic;
   wbm_ctrl_sel_o    : OUT std_logic_vector(3 DOWNTO 0);
   wbm_ctrl_cyc_sram : OUT std_logic;
   wbm_ctrl_cyc_pci  : OUT std_logic;
   wbm_ctrl_adr_o    : OUT std_logic_vector(31 DOWNTO 0);
   wbm_ctrl_dat_o    : OUT std_logic_vector(31 DOWNTO 0);
   wbm_ctrl_dat_i    : IN std_logic_vector(31 DOWNTO 0);

   wbm_dma_stb_o    : OUT std_logic;
   wbm_dma_ack_i    : IN std_logic;
   wbm_dma_we_o     : OUT std_logic;
   wbm_dma_cti      : OUT std_logic_vector(2 DOWNTO 0);
   wbm_dma_tga_o    : OUT std_logic_vector(8 DOWNTO 0);
   wbm_dma_err_i    : IN std_logic;
   wbm_dma_sel_o    : OUT std_logic_vector(3 DOWNTO 0);
   wbm_dma_cyc_sram : OUT std_logic;
   wbm_dma_cyc_vme  : OUT std_logic;
   wbm_dma_cyc_pci  : OUT std_logic;
   wbm_dma_adr_o    : OUT std_logic_vector(31 DOWNTO 0);
   wbm_dma_dat_o    : OUT std_logic_vector(31 DOWNTO 0);
   wbm_dma_dat_i    : IN std_logic_vector(31 DOWNTO 0);

   -- vmebus
   va                : INOUT std_logic_vector(31 DOWNTO 0);    -- address   
   vd                : INOUT std_logic_vector(31 DOWNTO 0);    -- data   
   vam               : INOUT std_logic_vector(5 DOWNTO 0);     -- address modifier
   writen            : INOUT std_logic;                        -- write enable      
   iackn             : INOUT std_logic;                        -- Handler's output 
   irq_i_n           : IN std_logic_vector(7 DOWNTO 1);        -- interrupt request inputs
   irq_o_n           : OUT std_logic_vector(7 DOWNTO 1);       -- interrupt request outputs
   as_o_n            : OUT   std_logic;                        -- address strobe out  
   as_oe_n           : OUT   std_logic;                        -- address strobe output enable  
   as_i_n            : IN    std_logic;                        -- address strobe in
   sysresn           : OUT   std_logic;                        -- system reset out 
   sysresin          : IN    std_logic;                        -- system reset in
   ds_o_n            : OUT   std_logic_vector(1 DOWNTO 0);     -- data strobe outputs
   ds_i_n            : IN   std_logic_vector(1 DOWNTO 0);      -- data strobe inputs
   ds_oe_n           : OUT std_logic;                          -- data strobe output enable
   berrn             : OUT   std_logic;                        -- bus error out    
   berrin            : IN    std_logic;                        -- bus error in 
   dtackn            : OUT   std_logic;                        -- dtack out   
   dtackin           : IN    std_logic;                        -- dtack in
   slot01n           : OUT   std_logic;                        -- indicates whether controller has detected position in slot 1 (low active)
   sysfail_i_n       : IN   std_logic;                        -- system failure interrupt input
   sysfail_o_n       : OUT   std_logic;                        -- system failure interrupt output
   bbsyn             : OUT   std_logic;                        -- bus busy out    
   bbsyin            : IN    std_logic;                        -- bus busy in     
   bclr_i_n          : IN std_logic;                           -- bus clear input
   bclr_o_n          : OUT std_logic;                          -- bus clear output
   retry_i_n         : IN std_logic;                           -- bus retry input
   retry_o_n         : OUT std_logic;                          -- bus retry output
   retry_oe_n        : OUT std_logic;                          -- bus retry output enable
   br_i_n            : IN std_logic_vector(3 DOWNTO 0);        -- bus request inputs
   br_o_n            : OUT std_logic_vector(3 DOWNTO 0);       -- bus request outputs
   iackin            : IN    std_logic;                        -- Interrupter's input
   iackoutn          : OUT   std_logic;                        -- Interrupter's output
   acfailn           : IN    std_logic;                        -- from Power Supply
   bg_i_n            : IN  std_logic_vector(3 DOWNTO 0);       -- bus grant input
   bg_o_n            : OUT std_logic_vector(3 DOWNTO 0);       -- bus grant output
   ga                : IN std_logic_vector(4 DOWNTO 0);        -- geographical addresses
   gap               : IN std_logic;                           -- geographical addresses parity

   -- vme status signals
   vme_berr          : OUT std_logic;                          -- indicates vme bus error (=MSTR(2)), must be cleared by sw           
   vme_mstr_busy     : OUT std_logic;                          -- indicates vme bus master is active
        
   --data bus bus control signals for vmebus drivers
   d_dir             : OUT std_logic;                          -- external driver control data direction (1: drive to vmebus 0: drive to fpga)
   d_oe_n            : OUT std_logic;                          -- external driver control data output enable low active
   am_dir            : OUT std_logic;                          -- external driver control address modifier direction (1: drive to vmebus 0: drive to fpga)
   am_oe_n           : OUT std_logic;                          -- external driver control address modifier output enable low activ 
   a_dir             : OUT std_logic;                          -- external driver control address direction (1: drive to vmebus 0: drive to fpga)
   a_oe_n            : OUT std_logic;                          -- external driver control address output enable low activ
   
   v2p_rstn          : OUT   std_logic                         -- Reset from VMEbus to System on board
     );
END wbb2vme_top;

ARCHITECTURE wbb2vme_top_arch OF wbb2vme_top IS 
COMPONENT vme_ctrl 
GENERIC (
   A16_REG_MAPPING   : boolean := TRUE;                        -- if true, access to vme slave A16 space goes to vme runtime registers and above 0x800 to sram (compatible to old revisions)
                                                               -- if false, access to vme slave A16 space goes to sram
   LONGADD_SIZE      : integer range 3 TO 8:=3;
   USE_LONGADD       : boolean := TRUE                          -- If FALSE, bits (7 DOWNTO 5) of SIGNAL longadd will be allocated to vme_adr_out(31 DOWNTO 29)
   );
PORT (
   clk               : IN std_logic;                      -- 66 MHz
   rst               : IN std_logic;                      -- global reset signal (asynch)
   startup_rst       : IN std_logic;                      -- powerup reset
   postwr            : OUT std_logic;                     -- posted write
   vme_irq           : OUT std_logic_vector(7 DOWNTO 0);  -- interrupt request to pci-bus
   berr_irq          : OUT std_logic;                     -- signal berrn interrupt request
   locmon_irq        : OUT std_logic_vector(1 DOWNTO 0);  -- interrupt request location monitor to pci-bus
   mailbox_irq       : OUT std_logic_vector(1 DOWNTO 0);  -- interrupt request mailbox to pci-bus
   prevent_sysrst    : IN std_logic;                        -- if "1", sysrst_n_out will not be activated after powerup,
                                                            -- if "0", sysrst_n_out will be activated if in slot1 and system reset is active (sysc_bit or rst)
   test_vec          : OUT test_vec_type;

   -- dma
   dma_sta           : OUT std_logic_vector(9 DOWNTO 0);
   clr_dma_en        : IN std_logic;
   set_dma_err       : IN std_logic;
   dma_act_bd        : IN std_logic_vector(7 DOWNTO 4);
    
   -- vmectrl slave
   wbs_stb_i         : IN std_logic;
   wbs_ack_o         : OUT std_logic;
   wbs_err_o         : OUT std_logic;
   wbs_we_i          : IN std_logic;
   wbs_sel_i         : IN std_logic_vector(3 DOWNTO 0);
   wbs_cyc_i         : IN std_logic;
   wbs_adr_i         : IN std_logic_vector(31 DOWNTO 0);
   wbs_dat_o         : OUT std_logic_vector(31 DOWNTO 0);
   wbs_dat_i         : IN std_logic_vector(31 DOWNTO 0);
   wbs_tga_i         : IN std_logic_vector(8 DOWNTO 0);

   -- vmectrl master
   wbm_stb_o         : OUT std_logic;
   wbm_ack_i         : IN std_logic;
   wbm_err_i         : IN std_logic;
   wbm_we_o          : OUT std_logic;
   wbm_sel_o         : OUT std_logic_vector(3 DOWNTO 0);
   vme_cyc_sram      : OUT std_logic;
   vme_cyc_pci       : OUT std_logic;
   wbm_adr_o         : OUT std_logic_vector(31 DOWNTO 0);
   wbm_dat_o         : OUT std_logic_vector(31 DOWNTO 0);
   wbm_dat_i         : IN std_logic_vector(31 DOWNTO 0);
      
   -- the VME signals:
   va                : INOUT std_logic_vector(31 DOWNTO 0);    -- address   
   vd                : INOUT std_logic_vector(31 DOWNTO 0);    -- data   
   vam               : INOUT std_logic_vector(5 DOWNTO 0);     -- address modifier
   writen            : INOUT std_logic;                        -- write enable      
   iackn             : INOUT std_logic;                        -- Handler's output 
   irq_i_n           : IN std_logic_vector(7 DOWNTO 1);        -- interrupt request inputs
   irq_o_n           : OUT std_logic_vector(7 DOWNTO 1);       -- interrupt request outputs
   as_o_n            : OUT   std_logic;                        -- address strobe out  
   as_oe_n           : OUT   std_logic;                        -- address strobe output enable  
   as_i_n            : IN    std_logic;                        -- address strobe in
   sysresn           : OUT   std_logic;                        -- system reset out 
   sysresin          : IN    std_logic;                        -- system reset in
   ds_o_n            : OUT   std_logic_vector(1 DOWNTO 0);     -- data strobe outputs
   ds_i_n            : IN   std_logic_vector(1 DOWNTO 0);      -- data strobe inputs
   ds_oe_n           : OUT std_logic;                          -- data strobe output enable
   berrn             : OUT   std_logic;                        -- bus error out    
   berrin            : IN    std_logic;                        -- bus error in 
   dtackn            : OUT   std_logic;                        -- dtack out   
   dtackin           : IN    std_logic;                        -- dtack in
   slot01n           : OUT   std_logic;                        -- indicates whether controller has detected position in slot 1 (low active)
   sysfail_i_n       : IN   std_logic;                        -- system failure interrupt input
   sysfail_o_n       : OUT   std_logic;                        -- system failure interrupt output
   bbsyn             : OUT   std_logic;                        -- bus busy out    
   bbsyin            : IN    std_logic;                        -- bus busy in     
   br_i_n            : IN std_logic_vector(3 DOWNTO 0);        -- bus request inputs
   br_o_n            : OUT std_logic_vector(3 DOWNTO 0);       -- bus request outputs
   iackin            : IN    std_logic;                        -- Interrupter's input
   iackoutn          : OUT   std_logic;                        -- Interrupter's output
   acfailn           : IN    std_logic;                        -- from Power Supply
   bg_i_n            : IN  std_logic_vector(3 DOWNTO 0);       -- bus grant input
   bg_o_n            : OUT std_logic_vector(3 DOWNTO 0);       -- bus grant output
   ga                : IN std_logic_vector(4 DOWNTO 0);        -- geographical addresses
   gap               : IN std_logic;                           -- geographical addresses parity

   -- vme status signals
   vme_berr          : OUT std_logic;                          -- indicates vme bus error (=MSTR(2)), must be cleared by sw           
   vme_mstr_busy     : OUT std_logic;                          -- indicates vme bus master is active
   
   --data bus bus control signals for vmebus drivers
   d_dir             : OUT std_logic;                          -- external driver control data direction (1: drive to vmebus 0: drive to fpga)
   d_oe_n            : OUT std_logic;                          -- external driver control data output enable low active
   am_dir            : OUT std_logic;                          -- external driver control address modifier direction (1: drive to vmebus 0: drive to fpga)
   am_oe_n           : OUT std_logic;                          -- external driver control address modifier output enable low activ 
   a_dir             : OUT std_logic;                          -- external driver control address direction (1: drive to vmebus 0: drive to fpga)
   a_oe_n            : OUT std_logic;                          -- external driver control address output enable low activ
   
   v2p_rstn          : OUT   std_logic                         -- Reset from VMEbus to System on board
     );
END COMPONENT;

COMPONENT vme_dma
PORT (
   rst           : IN std_logic;
   clk            : IN std_logic;
   irq_o          : OUT std_logic;

   -- vme_du
   dma_sta        : IN std_logic_vector(9 DOWNTO 0);
   clr_dma_en     : OUT std_logic;
   set_dma_err    : OUT std_logic;
   dma_act_bd     : OUT std_logic_vector(7 DOWNTO 4);

   -- wb-slave
   stb_i          : IN std_logic;
   ack_o          : OUT std_logic;
   we_i           : IN std_logic;
   cyc_i          : IN std_logic;
   sel_i          : IN std_logic_vector(3 DOWNTO 0);
   adr_i          : IN std_logic_vector(31 DOWNTO 0);
   slv_dat_i      : IN std_logic_vector(31 DOWNTO 0);
   slv_dat_o      : OUT std_logic_vector(31 DOWNTO 0);
   
   -- wb-master
   stb_o          : OUT std_logic;
   ack_i          : IN std_logic;
   we_o           : OUT std_logic;
   cti            : OUT std_logic_vector(2 DOWNTO 0);
   tga_o          : OUT std_logic_vector(8 DOWNTO 0);      -- type of dma
   err_i          : IN std_logic;
   cyc_o_sram     : OUT std_logic;
   cyc_o_vme      : OUT std_logic;
   cyc_o_pci      : OUT std_logic;
   sel_o          : OUT std_logic_vector(3 DOWNTO 0);
   adr_o          : OUT std_logic_vector(31 DOWNTO 0);
   mstr_dat_o     : OUT std_logic_vector(31 DOWNTO 0);
   mstr_dat_i     : IN std_logic_vector(31 DOWNTO 0)

     );
END COMPONENT;

   SIGNAL dma_sta           : std_logic_vector(9 DOWNTO 0);
   SIGNAL clr_dma_en        : std_logic;
   SIGNAL set_dma_err       : std_logic;
   SIGNAL dma_act_bd        : std_logic_vector(7 DOWNTO 4);

BEGIN
   bclr_o_n   <= '1';
   retry_o_n  <= '1';
   retry_oe_n <= '1';

vmectrl: vme_ctrl 
GENERIC MAP (
   A16_REG_MAPPING   => A16_REG_MAPPING,
   LONGADD_SIZE      => LONGADD_SIZE,
   USE_LONGADD       => USE_LONGADD
   )
PORT MAP(
   clk               => clk          ,
   rst               => rst         ,
   startup_rst       => startup_rst,
   postwr            => postwr       ,
   vme_irq           => vme_irq      ,
   berr_irq          => berr_irq,
   locmon_irq        => locmon_irq ,
   mailbox_irq       => mailbox_irq,
   prevent_sysrst    => prevent_sysrst,
   test_vec          => test_vec         ,
                                     
   dma_sta           => dma_sta      ,
   clr_dma_en        => clr_dma_en   ,
   set_dma_err       => set_dma_err  ,
   dma_act_bd        => dma_act_bd   ,
                                     
   wbs_stb_i         => wbs_stb_i    ,
   wbs_ack_o         => wbs_ack_o    ,
   wbs_err_o         => wbs_err_o    ,
   wbs_we_i          => wbs_we_i     ,
   wbs_sel_i         => wbs_sel_i    ,
   wbs_cyc_i         => wbs_cyc_i    ,
   wbs_adr_i         => wbs_adr_i    ,
   wbs_dat_o         => wbs_dat_o    ,
   wbs_dat_i         => wbs_dat_i    ,
   wbs_tga_i         => wbs_tga_i    ,
                                     
   wbm_stb_o         => wbm_ctrl_stb_o    ,
   wbm_ack_i         => wbm_ctrl_ack_i    ,
   wbm_err_i         => wbm_ctrl_err_i    ,
   wbm_we_o          => wbm_ctrl_we_o     ,
   wbm_sel_o         => wbm_ctrl_sel_o    ,
   vme_cyc_sram      => wbm_ctrl_cyc_sram ,
   vme_cyc_pci       => wbm_ctrl_cyc_pci  ,
   wbm_adr_o         => wbm_ctrl_adr_o    ,
   wbm_dat_o         => wbm_ctrl_dat_o    ,
   wbm_dat_i         => wbm_ctrl_dat_i    ,
                                     
   va                => va         ,
   vd                => vd         ,
   vam               => vam        ,
   writen            => writen     ,
   iackn             => iackn      ,
   irq_i_n           => irq_i_n    ,
   irq_o_n           => irq_o_n    ,
   as_o_n            => as_o_n     ,
   as_oe_n           => as_oe_n    ,
   as_i_n            => as_i_n     ,
   sysresn           => sysresn    ,
   sysresin          => sysresin   ,
   ds_o_n            => ds_o_n     ,
   ds_i_n            => ds_i_n     ,
   ds_oe_n           => ds_oe_n    ,
   berrn             => berrn      ,
   berrin            => berrin     ,
   dtackn            => dtackn     ,
   dtackin           => dtackin    ,
   slot01n           => slot01n    ,
   sysfail_i_n       => sysfail_i_n,
   sysfail_o_n       => sysfail_o_n,
   bbsyn             => bbsyn      ,
   bbsyin            => bbsyin     ,
   br_i_n            => br_i_n     ,
   br_o_n            => br_o_n     ,
   iackin            => iackin     ,
   iackoutn          => iackoutn   ,
   acfailn           => acfailn    ,
   bg_i_n            => bg_i_n     ,
   bg_o_n            => bg_o_n     ,
   ga                => ga ,
   gap               => gap,
   vme_berr          => vme_berr     ,
   vme_mstr_busy     => vme_mstr_busy,
   d_dir             => d_dir      ,
   d_oe_n            => d_oe_n     ,
   am_dir            => am_dir     ,
   am_oe_n           => am_oe_n    ,
   a_dir             => a_dir      ,
   a_oe_n            => a_oe_n     ,
   v2p_rstn          => v2p_rstn   
     );

vmedma: vme_dma
PORT MAP (
   rst           => rst       ,
   clk            => clk        ,
   irq_o          => dma_irq      ,
                                
   dma_sta        => dma_sta    ,
   clr_dma_en     => clr_dma_en ,
   set_dma_err    => set_dma_err,
   dma_act_bd     => dma_act_bd ,
                                
   stb_i          => '0'  ,
   ack_o          => open  ,
   we_i           => '0'  ,
   cyc_i          => '0'  ,
   sel_i          => (OTHERS => '0')  ,
   adr_i          => (OTHERS => '0')  ,
   slv_dat_i      => (OTHERS => '0')  ,
   slv_dat_o      => open  ,
                                
   stb_o          => wbm_dma_stb_o      ,
   ack_i          => wbm_dma_ack_i      ,
   we_o           => wbm_dma_we_o       ,
   cti            => wbm_dma_cti,
   tga_o          => wbm_dma_tga_o      ,
   err_i          => wbm_dma_err_i      ,
   cyc_o_sram     => wbm_dma_cyc_sram ,
   cyc_o_vme      => wbm_dma_cyc_vme  ,
   cyc_o_pci      => wbm_dma_cyc_pci  ,
   sel_o          => wbm_dma_sel_o      ,
   adr_o          => wbm_dma_adr_o      ,
   mstr_dat_o     => wbm_dma_dat_o ,
   mstr_dat_i     => wbm_dma_dat_i 

     );
END wbb2vme_top_arch;
