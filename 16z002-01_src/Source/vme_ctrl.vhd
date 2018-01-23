--------------------------------------------------------------------------------
-- Title         : VME IP Core Toplevel
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : vme_ctrl.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 15/12/16
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--

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
-- $Revision: 1.10 $
--
-- $Log: vme_ctrl.vhd,v $
-- Revision 1.10  2015/09/16 09:20:07  mwawrik
-- Added generics A16_REG_MAPPING and USE_LONGADD
--
-- Revision 1.9  2015/04/07 14:30:14  AGeissler
-- R1: New signals sl_acc_valid and asn_in_sl_reg
-- M1: Connected these signals to the corresponding component
--
-- Revision 1.8  2014/04/17 07:35:27  MMiehling
-- added generic LONGADD_SIZE
-- added signal prevent_sysrst
--
-- Revision 1.7  2013/09/12 08:45:32  mmiehling
-- added bit 8 of tga for address modifier extension (supervisory, non-privileged data/program)
--
-- Revision 1.6  2012/11/22 09:20:43  MMiehling
-- removed dummy signal
--
-- Revision 1.5  2012/11/15 09:43:55  MMiehling
-- connected each interrupt source to interface in order to support edge triggered msi
--
-- Revision 1.4  2012/11/12 08:13:13  MMiehling
-- changed comments
--
-- Revision 1.3  2012/09/25 11:21:47  MMiehling
-- removed unused signals
--
-- Revision 1.2  2012/08/27 12:57:20  MMiehling
-- general rework
--
-- Revision 1.1  2012/03/29 10:14:49  MMiehling
-- Initial Revision
--
-- Revision 1.14  2010/03/12 13:38:20  mmiehling
-- changed commments
--
-- Revision 1.13  2006/06/02 15:48:57  MMiehling
-- changed comment
--
-- Revision 1.12  2006/05/18 14:29:05  MMiehling
-- added sl_acc for mailbox
--
-- Revision 1.11  2005/02/04 13:44:14  mmiehling
-- added generic simulation; added combinations of addr3+4
--
-- Revision 1.10  2004/11/02 11:29:55  mmiehling
-- moved dma_reg to vme_du
--
-- Revision 1.9  2004/07/27 17:15:39  mmiehling
-- changed pci-core to 16z014
-- changed wishbone bus to wb_bus.vhd
-- added clk_trans_wb2wb.vhd
-- improved dma
--
-- Revision 1.8  2004/06/17 13:02:29  MMiehling
-- removed clr_hit and sl_acc_reg
--
-- Revision 1.7  2003/12/17 15:51:45  MMiehling
-- byte swapping in "not swapped" mode was wrong
--
-- Revision 1.6  2003/12/01 10:03:53  MMiehling
-- changed all
--
-- Revision 1.5  2003/07/14 08:38:08  MMiehling
-- changed rst_counter; added lwordn
--
-- Revision 1.4  2003/06/24 13:47:08  MMiehling
-- removed burst; added loc_keep and rst_aonly
--
-- Revision 1.3  2003/06/13 10:06:35  MMiehling
-- improved
--
-- Revision 1.2  2003/04/22 11:03:00  MMiehling
-- added locmon and mailbox
--
-- Revision 1.1  2003/04/01 13:04:42  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;     
USE work.vme_pkg.all;

ENTITY vme_ctrl IS
GENERIC (
   A16_REG_MAPPING   : boolean := TRUE;                        -- if true, access to vme slave A16 space goes to vme runtime registers and above 0x800 to sram (compatible to old revisions)
                                                               -- if false, access to vme slave A16 space goes to sram
   LONGADD_SIZE      : integer range 3 TO 8:=3;
   USE_LONGADD       : boolean := TRUE                          -- If FALSE, bits (7 DOWNTO 5) of SIGNAL longadd will be allocated to vme_adr_out(31 DOWNTO 29)
                                                                -- If TRUE, number of bits allocated to vme_adr_out depends on GENERIC LONGADD_SIZE
   );
PORT (
   clk               : IN std_logic;                        -- 66 MHz
   rst               : IN std_logic;                        -- global reset signal (asynch)
   startup_rst       : IN std_logic;                        -- powerup reset
   postwr            : OUT std_logic;                       -- posted write indication
   vme_irq           : OUT std_logic_vector(7 DOWNTO 0);    -- interrupt request to pci-bus
   berr_irq          : OUT std_logic;                       -- signal berrn interrupt request
   locmon_irq        : OUT std_logic_vector(1 DOWNTO 0);    -- interrupt request location monitor to pci-bus
   mailbox_irq       : OUT std_logic_vector(1 DOWNTO 0);    -- interrupt request mailbox to pci-bus
   prevent_sysrst    : IN std_logic;                        -- if "1", sysrst_n_out will not be activated after powerup,
                                                            -- if "0", sysrst_n_out will be activated if in slot1 and system reset is active (sysc_bit or rst)
   test_vec          : OUT test_vec_type;

   -- dma
   dma_sta           : OUT std_logic_vector(9 DOWNTO 0);
   clr_dma_en        : IN std_logic;
   set_dma_err       : IN std_logic;
   dma_act_bd        : IN std_logic_vector(7 DOWNTO 4);
    
   -- mensb slave
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

   -- mensb master
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
   
   v2p_rst           : OUT std_logic                           -- Reset between VMEbus and Host CPU
     );
END vme_ctrl;

ARCHITECTURE vme_ctrl_arch OF vme_ctrl IS 
   
   COMPONENT vme_du 
   GENERIC (
      LONGADD_SIZE      : integer range 3 TO 8:=3;
      USE_LONGADD       : boolean := TRUE                            -- If FALSE, bits (7 DOWNTO 5) of SIGNAL longadd will be allocated to vme_adr_out(31 DOWNTO 29)
                                                                     -- If TRUE, number of bits allocated to vme_adr_out depends on GENERIC LONGADD_SIZE
      );                                                             
   PORT (                                                            
      clk                     : IN std_logic;                        -- 66 MHz
      rst                     : IN std_logic;                        -- global reset signal (asynch)
      startup_rst             : IN std_logic;                        -- powerup reset
      vme_irq                 : OUT std_logic_vector(7 DOWNTO 0);    -- interrupt request to pci-bus
      berr_irq                : OUT std_logic;                       -- signal berrn interrupt request
      locmon_irq              : OUT std_logic_vector(1 DOWNTO 0);    -- interrupt request location monitor to pci-bus
      mailbox_irq             : OUT std_logic_vector(1 DOWNTO 0);    -- interrupt request mailbox to pci-bus
   
      -- dma
      dma_sta                 : OUT std_logic_vector(9 DOWNTO 0);
      clr_dma_en              : IN std_logic;
      set_dma_err             : IN std_logic;
      dma_act_bd              : IN std_logic_vector(7 DOWNTO 4);
   
      -- arbiter
      sel_reg_data_in         : IN std_logic;                        -- mux select signal for wbb/vme register access
      sel_loc_data_out        : IN std_logic_vector(1 DOWNTO 0);     -- mux select signal for 0=reg, 1=vme data_out
      en_wbm_dat_o            : IN std_logic;                        -- enable for wbm_dat_o
      
      -- requester
      brl                     : OUT std_logic_vector(1 DOWNTO 0);    -- bus request leve
   
      -- vme_au
      int_adr                 : IN std_logic_vector(18 DOWNTO 0);    -- internal adress for reg
      int_be                  : IN std_logic_vector(3 DOWNTO 0);     -- internal byte enables
      vme_adr_out             : IN std_logic_vector(31 DOWNTO 0);    -- vme adress lines
      byte_routing            : IN std_logic;                        -- mux select for byte routing
      vme_adr_in              : OUT std_logic_vector(31 DOWNTO 0);   -- vme adress input lines
      my_iack                 : IN std_logic;
      d64                     : IN std_logic;                        -- indicates d64 mblt
      vam_reg                 : IN std_logic_vector(5 DOWNTO 0);     -- registered vam_in for location monitoring and berr_adr (registered with en_vme_adr_in)
      vme_adr_in_reg          : IN std_logic_vector(31 DOWNTO 2);    -- vme adress for location monitoring and berr_adr (registered with en_vme_adr_in)
      sl_writen_reg           : IN std_logic;                        -- vme read/wrtie signal (registered with en_vme_adr_in)
      iackn_in_reg            : IN std_logic;                        -- iack signal (registered with en_vme_adr_in)
   
      -- sys_arbiter
      lwordn                  : IN std_logic;                        -- stored for vme slave access
      
      -- ctrl_mux
      write_flag              : IN std_logic;                        -- write flag for register write access
                                                                     
      -- master                                                      
      oe_vd                   : IN std_logic;                        -- output enable for vme data
      oe_va                   : IN std_logic;                        -- output enable for vme adress
      second_word             : IN std_logic;                        -- indicates data phase of d64
                                                                     
      -- slave                                                       
      sel_vme_data_out        : IN std_logic_vector(1 DOWNTO 0);     -- mux select for vme data out
      en_vme_data_out_reg     : IN std_logic;                        -- register enable for vme data out
      en_vme_data_out_reg_high: IN std_logic;                        -- register enable for vme data out high long
      en_vme_data_in_reg      : IN std_logic;                        -- register enable for vme data in
      en_vme_data_in_reg_high : IN std_logic;                        -- register enable for vme data in high long
      clr_intreq              : IN std_logic;                        -- clear interrupt request (intr(3) <= '0'
      
      -- wbb_slave
      wbs_dat_o               : OUT std_logic_vector(31 DOWNTO 0);
      wbs_dat_i               : IN std_logic_vector(31 DOWNTO 0);
      wbs_tga_i               : IN std_logic_vector(8 DOWNTO 0);     -- indicates dma(1) or normal(0) access
      swap                    : IN std_logic;                        -- swapps bytes when enabled
   
      -- wbb_master
      wbm_ack_i               : IN std_logic;
      wbm_err_i               : IN std_logic;
      wbm_dat_o               : OUT std_logic_vector(31 DOWNTO 0);
      wbm_dat_i               : IN std_logic_vector(31 DOWNTO 0);
      sel_wbm_dat_o           : IN std_logic;                        -- selects between low and high d32
   
      -- register out
      longadd                 : OUT std_logic_vector(7 DOWNTO 0);    -- upper 3 address bits for A32 mode or dependent on LONGADD_SIZE
      mstr_reg                : OUT std_logic_vector(13 DOWNTO 0);   -- master register (aonly, postwr, iberr, berr, req, rmw, A16_MODE, A24_MODE, A32_MODE)
      sysc_reg                : OUT std_logic_vector(2 DOWNTO 0);    -- system control register (ato, sysr, sysc)
      slv16_reg               : OUT std_logic_vector(4 DOWNTO 0);    -- slave A16 base address register
      slv24_reg               : OUT std_logic_vector(15 DOWNTO 0);   -- slave A24 base address register
      slv32_reg               : OUT std_logic_vector(23 DOWNTO 0);   -- slave A32 base address register
      slv24_pci_q             : OUT std_logic_vector(15 DOWNTO 0);   -- slave A24 base address register for PCI
      slv32_pci_q             : OUT std_logic_vector(23 DOWNTO 0);   -- slave A32 base address register for PCI
      intr_reg                : OUT std_logic_vector(3 DOWNTO 0);    -- interrupt request register
      pci_offset_q            : OUT std_logic_vector(31 DOWNTO 2);   -- pci offset address for vme to pci access
      
      -- register bits
      set_berr                : IN std_logic;                        -- if bit is set => berr bit will be set
      rst_rmw                 : IN std_logic;                        -- if bit is set => rmw bit will be cleared
      set_sysc                : IN std_logic;                        -- if bit is set => sysc bit will be set
      set_ato                 : IN std_logic;                        -- if bit is set => ato bit will be set
      clr_sysr                : IN std_logic;                        -- if bit is set => sysr bit will be cleared
      mail_irq                : IN std_logic_vector(7 DOWNTO 0);     -- mailbox interrupt flags
      loc_am_0                : OUT std_logic_vector(1 DOWNTO 0);    -- loc-monitor #0 - adress modus "00"-A32, "10"-A16, "11"-A24
      loc_am_1                : OUT std_logic_vector(1 DOWNTO 0);    -- loc-monitor #1 - adress modus "00"-A32, "10"-A16, "11"-A24
      loc_irq_0               : IN std_logic;                        -- loc-monitor #0 - irq
      loc_irq_1               : IN std_logic;                        -- loc-monitor #1 - irq
      loc_rw_0                : OUT std_logic_vector(1 DOWNTO 0);    -- [0]: read; [1]: write
      loc_rw_1                : OUT std_logic_vector(1 DOWNTO 0);    -- [0]: read; [1]: write
      loc_adr_0               : OUT std_logic_vector(31 DOWNTO 0);   -- location monitor #0 adress
      loc_adr_1               : OUT std_logic_vector(31 DOWNTO 0);   -- location monitor #1 adress
      loc_sel                 : IN std_logic_vector(1 DOWNTO 0);     -- these bits are loaded with combinations of address bits [4:3] if locmon hit address         
      rst_aonly               : IN std_logic;                        -- resets aonly bit
      clr_locmon              : OUT std_logic_vector(1 DOWNTO 0);    -- clear address combination bits when clear status bit
      
      -- irq pins
      irq_i_n                 : IN std_logic_vector(7 DOWNTO 1);
      irq_o_n                 : OUT std_logic_vector(7 DOWNTO 1);
      acfailn                 : IN  std_logic;                       -- ACFAIL# input from Power Supply
      
      --vme
      ga                      : IN std_logic_vector(4 DOWNTO 0);     -- geographical addresses
      gap                     : IN std_logic;                        -- geographical addresses parity
      vd                      : INOUT std_logic_vector(31 DOWNTO 0);
      va                      : INOUT std_logic_vector(31 DOWNTO 0) 
   );
   END COMPONENT;
   
   COMPONENT vme_sys_arbiter
   PORT (
      clk                           : IN std_logic;                -- 66 MHz
      rst                           : IN std_logic;                -- global reset signal (asynch)
                                    
      io_ctrl                       : OUT io_ctrl_type;              
      ma_io_ctrl                    : IN io_ctrl_type;              
      sl_io_ctrl                    : IN io_ctrl_type;              
                                    
      mensb_req                     : IN std_logic;               -- request signal for mensb slave access
      slave_req                     : IN std_logic;               -- request signal for slave access
      mstr_busy                     : IN std_logic;               -- master busy
      mstr_vme_req                  : IN std_logic;               -- master request VME interface
                                    
      mensb_active                  : OUT std_logic;            -- acknoledge/active signal for mensb slave access
      slave_active                  : OUT std_logic;            -- acknoledge/active signal for slave access
                                    
      lwordn_slv                    : IN std_logic;                        -- stored for vme slave access
      lwordn_mstr                   : IN std_logic;                        -- master access lwordn
      lwordn                        : OUT std_logic;            -- lwordn for vme_du multiplexer
                                    
      write_flag                    : OUT std_logic;            -- write flag for register access dependent on arbitration
      ma_byte_routing               : IN std_logic;
      sl_byte_routing               : IN std_logic;
      byte_routing                  : OUT std_logic;
                                    
      sl_sel_vme_data_out           : IN std_logic_vector(1 DOWNTO 0);      -- mux select: 00=wbm_dat_i 01=wbs_dat_i 10=reg_data
      sel_vme_data_out              : OUT std_logic_vector(1 DOWNTO 0);
                                    
      ma_oe_vd                      : IN std_logic;                        -- master output enable signal for VAD
      sl_oe_vd                      : IN std_logic;                        -- slave output enable signal for VAD
      oe_vd                         : OUT std_logic;                       -- output enable signal for VAD
                                    
      ma_oe_va                      : IN std_logic;                        -- master output enable signal for VAD
      sl_oe_va                      : IN std_logic;                        -- slave output enable signal for VAD
      oe_va                         : OUT std_logic;                       -- output enable signal for VAD
      
      ma_second_word                : IN std_logic;            -- differs between address and data phase in d64
      sl_second_word                : IN std_logic;            -- differs between address and data phase in d64
      second_word                   : OUT std_logic;           -- differs between address and data phase in d64
      
      ma_en_vme_data_out_reg        : IN std_logic;   
      sl_en_vme_data_out_reg        : IN std_logic;   
      reg_en_vme_data_out_reg       : IN std_logic;   
      en_vme_data_out_reg           : OUT std_logic;   
      
      ma_en_vme_data_out_reg_high   : IN std_logic;   
      sl_en_vme_data_out_reg_high   : IN std_logic;   
      en_vme_data_out_reg_high      : OUT std_logic;   
      
      swap                          : OUT std_logic;            -- swapping of data bytes on/off
      ma_swap                       : IN std_logic;
                                    
      sl_d64                        : IN std_logic;                     -- indicates a d64 burst transmission
      ma_d64                        : IN std_logic;      
      d64                           : OUT std_logic;            -- indicates d64 master access
      
      ma_en_vme_data_in_reg         : IN std_logic;            -- master enable of vme data in registers
      sl_en_vme_data_in_reg         : IN std_logic;            -- slave enable of vme data in registers
      en_vme_data_in_reg            : OUT std_logic;            -- enable of vme data in registers
      
      ma_en_vme_data_in_reg_high    : IN std_logic;            -- master enable of vme data high in registers
      sl_en_vme_data_in_reg_high    : IN std_logic;            -- slave enable of vme data high in registers
      en_vme_data_in_reg_high       : OUT std_logic;            -- enable of vme data high in registers
      
      vme_adr_locmon                : OUT std_logic_vector(31 DOWNTO 2);   -- adress for location monitor (either vme_adr_in or vme_adr_out)
      vme_adr_in_reg                : IN std_logic_vector(31 DOWNTO 2);      -- vme adress sampled with en_vme_adr_in
      vme_adr_out                   : IN std_logic_vector(31 DOWNTO 2);      -- vme adress for master access
                                    
      loc_write_flag                : IN std_logic;               -- write flag for register access from mensb side
      sl_write_flag                 : IN std_logic                  -- write flag for register access from vme side
   );
   END COMPONENT;
   
   COMPONENT vme_wbs 
   PORT (
      clk                        : IN std_logic;                      -- 66 MHz
      rst                        : IN std_logic;                      -- global reset signal (asynch)
                                 
      -- wbs             
      wbs_stb_i                  : IN std_logic;
      wbs_ack_o                  : OUT std_logic;
      wbs_err_o                  : OUT std_logic;
      wbs_we_i                   : IN std_logic;
      wbs_cyc_i                  : IN std_logic;
      wbs_adr_i                  : IN std_logic_vector(31 DOWNTO 0);
      wbs_sel_i                  : IN std_logic_vector(3 DOWNTO 0);
      wbs_sel_int                : OUT std_logic_vector(3 DOWNTO 0);
      wbs_tga_i                  : IN std_logic_vector(8 DOWNTO 0);
      
      loc_write_flag             : OUT std_logic;                     -- write flag for register
      ma_en_vme_data_out_reg     : OUT std_logic;                  -- for normal d32 or d64 low
      ma_en_vme_data_out_reg_high: OUT std_logic;                  -- for d64 high
      set_berr                   : IN std_logic;
      wb_dma_acc                 : OUT std_logic;                     -- indicates dma_access
      
      mensb_req                  : OUT std_logic;                     -- request line for reg access
      mensb_active               : IN std_logic;                     -- acknoledge line
                                 
      vme_acc_type               : OUT std_logic_vector(8 DOWNTO 0);   -- signal indicates the type of VME access
                                 
      run_mstr                   : OUT std_logic;                     -- starts vme master
      mstr_ack                   : IN std_logic;         -- this pulse indicates the end of Master transaction
      mstr_busy                  : IN std_logic;                     -- if master is busy => 1
      burst                      : OUT std_logic;                     -- indicates a burst transfer from dma to vme
                                 
      sel_loc_data_out           : OUT std_logic_vector(1 DOWNTO 0)   -- mux select signal for 0=reg, 1=vme data_out
   );
   END COMPONENT;
   
   COMPONENT vme_au
   GENERIC (
      A16_REG_MAPPING   : boolean := TRUE;         -- if true, access to vme slave A16 space goes to vme runtime registers and above 0x800 to sram (compatible to old revisions)
                                                   -- if false, access to vme slave A16 space goes to sram
      LONGADD_SIZE      : integer range 3 TO 8:=3; 
      USE_LONGADD       : boolean := TRUE          -- If FALSE, bits (7 DOWNTO 5) of SIGNAL longadd will be allocated to vme_adr_out(31 DOWNTO 29)
                                                   -- If TRUE, number of bits allocated to vme_adr_out depends on GENERIC LONGADD_SIZE
      );
   PORT (
      clk                     : IN std_logic;                        -- 66 MHz
      rst                     : IN std_logic;                        -- global reset signal (asynch)
      test                    : OUT std_logic;
      
      -- mensb slave
      wbs_adr_i               : IN std_logic_vector(31 DOWNTO 0);    -- mensb slave adress lines
      wbs_sel_i               : IN std_logic_vector(3 DOWNTO 0);     -- mensb slave byte enable lines
      wbs_we_i                : IN std_logic;                        -- mensb slave read/write
      vme_acc_type            : IN std_logic_vector(8 DOWNTO 0);     -- signal indicates the type of VME slave access
      ma_en_vme_data_out_reg  : IN std_logic;                        -- enable of vme_adr_out
      wbs_tga_i               : IN std_logic_vector(8 DOWNTO 0);
      
      -- mensb master
      wbm_adr_o               : OUT std_logic_vector(31 DOWNTO 0);   -- mensb master adress lines
      wbm_sel_o               : OUT std_logic_vector(3 DOWNTO 0);    -- mensb master byte enable lines
      wbm_we_o                : OUT std_logic;                       -- mensb master read/write
      sram_acc                : OUT std_logic;                       -- sram access is requested by vmebus
      pci_acc                 : OUT std_logic;                       -- pci access is requested by vmebus
      reg_acc                 : OUT std_logic;                       -- reg access is requested by vmebus
      sl_acc_wb               : OUT std_logic_vector(4 DOWNTO 0);    -- sampled with ld_loc_adr_cnt
                              
      -- vme                  
      vme_adr_in              : IN std_logic_vector(31 DOWNTO 0);    -- vme address input lines
      vme_adr_out             : OUT std_logic_vector(31 DOWNTO 0);   -- vme address output lines
      
      ---------------------------------------------------------------------------------------------------
      -- pins to vmebus
      asn_in                  : IN std_logic;                        -- vme adress strobe input
      vam                     : INOUT std_logic_vector(5 DOWNTO 0);  -- vme address modifier
      dsan_out                : OUT std_logic;                       -- data strobe byte(0) out
      dsbn_out                : OUT std_logic;                       -- data strobe byte(1) out
      dsan_in                 : IN std_logic;                        -- data strobe byte(0) in
      dsbn_in                 : IN std_logic;                        -- data strobe byte(1) in
      writen                  : INOUT std_logic;                     -- write enable      tco = tbd.   tsu <= tbd.   PIN tbd.
      iackn                   : INOUT std_logic;                     -- handler's output !   PIN tbd.
      iackin                  : IN std_logic;                        -- vme daisy chain interrupt acknoledge input
      iackoutn                : OUT std_logic;                       -- vme daisy chain interrupt acknoledge output
      ---------------------------------------------------------------------------------------------------
      
      mensb_active            : IN std_logic;                        -- acknoledge/active signal for mensb slave access
                                                                     
      -- vme master                                                  
      mstr_cycle              : OUT std_logic;                       -- number of master cycles should be done (0=1x, 1=2x)
      second_word             : IN std_logic;                        -- indicates the second transmission if in D16 mode and 32bit should be transmitted
      dsn_ena                 : IN std_logic;                        -- signal switches dsan_out and dsbn_out on and off
      vam_oe                  : IN std_logic;                        -- vam output enable
      ma_d64                  : OUT std_logic;                       -- indicates a d64 burst transmission
      sl_d64                  : OUT std_logic;                       -- indicates a d64 burst transmission
      
      -- vme slave
      sl_acc                  : OUT std_logic_vector(4 DOWNTO 0);    -- slave access hits and burst data transmission type
      sl_acc_valid            : OUT std_logic;                       -- sl_acc has been calculated and is valid
      asn_in_sl_reg           : IN std_logic;                        -- registered asn signal
      ld_loc_adr_m_cnt        : IN std_logic;                        -- load address counter
      inc_loc_adr_m_cnt       : IN std_logic;                        -- increment address counter
      sl_inc_loc_adr_m_cnt    : IN std_logic;                        -- increment address counter
      sl_writen_reg           : OUT std_logic;                       
      iackn_in_reg            : OUT std_logic;                       -- iack signal (registered with en_vme_adr_in)
      my_iack                 : OUT std_logic;                       
      clr_intreq              : IN std_logic;                        -- clear interrupt request (intr(3) <= '0'
      sl_en_vme_data_in_reg   : IN std_logic;                        -- register enable for vme data in
      en_vme_adr_in           : IN std_logic;                        -- samples adress and am after asn goes low
      
      -- sys_arbiter
      sl_byte_routing         : OUT std_logic;                       -- to mensb byte routing
      ma_byte_routing         : OUT std_logic;                       -- signal for byte swapping
      sl_sel_vme_data_out     : OUT std_logic_vector(1 DOWNTO 0);    -- mux select: 00=loc_data_in_m 01=loc_data_in_s 10=reg_data
      lwordn_slv              : OUT std_logic;                       -- stored for vme slave access
      lwordn_mstr             : OUT std_logic;                       -- master access lwordn
      
      -- locmon
      vam_reg                 : OUT std_logic_vector(5 DOWNTO 0);    -- registered vam_in for location monitoring and berr_adr (registered with en_vme_adr_in)
      vme_adr_in_reg          : OUT std_logic_vector(31 DOWNTO 2);   -- vme adress for location monitoring and berr_adr (registered with en_vme_adr_in)
                              
      -- vme_du               
      mstr_reg                : IN std_logic_vector(13 DOWNTO 0);    -- master register (aonly, postwr, iberr, berr, req, rmw, A16_MODE, A24_MODE, A32_MODE)
      longadd                 : IN std_logic_vector(7 DOWNTO 0);     -- upper 3 address bits for A32 mode or dependent on LONGADD_SIZE
      slv16_reg               : IN std_logic_vector(4 DOWNTO 0);     -- slave A16 base address register
      slv24_reg               : IN std_logic_vector(15 DOWNTO 0);    -- slave A24 base address register
      slv32_reg               : IN std_logic_vector(23 DOWNTO 0);    -- slave A32 base address register
      slv24_pci_q             : IN std_logic_vector(15 DOWNTO 0);    -- slave A24 base address register for PCI
      slv32_pci_q             : IN std_logic_vector(23 DOWNTO 0);    -- slave A32 base address register for PCI
      intr_reg                : IN std_logic_vector(3 DOWNTO 0);     -- interrupt request register
      sysc_reg                : IN std_logic_vector(2 DOWNTO 0);     -- system control register (ato, sysr, sysc)
      pci_offset_q            : IN std_logic_vector(31 DOWNTO 2);    -- pci offset address for vme to pci access        
                              
      int_be                  : OUT std_logic_vector(3 DOWNTO 0);    -- internal byte enables
      int_adr                 : OUT std_logic_vector(18 DOWNTO 0)    -- internal adress
   );
   END COMPONENT;
   
   COMPONENT vme_master 
     PORT (
      clk                     : IN  std_logic;        -- 66 MHz
      rst                     : IN  std_logic;
      
      test_c                  : OUT std_logic;
      
      -- control signals from/to mensb_slave
      run_mstr                : IN  std_logic;        -- this pulse triggers start of Master
      mstr_ack                : OUT std_logic;        -- this pulse indicates the end of Master transaction
      mstr_busy               : OUT std_logic;        -- master busy, set when running
      vme_req                 : out std_logic;        -- request VME interface access
      burst                   : IN std_logic;         -- indicates a vme burst request
      ma_en_vme_data_in_reg   : OUT std_logic;        -- load register signal in data switch unit for rd vme
      ma_en_vme_data_in_reg_high : OUT std_logic;     -- load high register signal in data switch unit for rd vme
      brel                    : OUT std_logic;        -- release signal for Requester
      wbs_we_i                : IN std_logic;         -- read /write
      wb_dma_acc              : IN std_logic;         -- indicates dma_access
      
      -- requester
      dwb                     : OUT std_logic;        -- device wants vme bus
      dgb                     : IN std_logic;         -- device gets vme bus
      
      -------------------------------------------------------------------------------
      -- PINs:
      -- control signals from VMEbus:
      berrn_in                : IN std_logic;         -- vme bus error signal   
      dtackn_in               : IN std_logic;         -- vme bus data acknoledge signal
      
      -- control signals to VMEbus
      asn_out                 : OUT std_logic;
      
      -------------------------------------------------------------------------------    
      -- connected with vme_du:
      rst_rmw                 : OUT std_logic;        -- if bit is set => berr bit will be set    
      set_berr                : OUT std_logic;        -- if bit is set => rmw bit will be cleared 
      ma_oe_vd                : OUT std_logic;        -- output enable for vme data
      ma_oe_va                : OUT std_logic;        -- output enable for vme adress
      mstr_reg                : IN std_logic_vector(5 DOWNTO 0);    -- master configuration register(BERR-bit, REQ-bit, RMW-bit)
      rst_aonly               : OUT std_logic;        -- resets aonly bit
      
      -- connected with vme_au
      dsn_ena                 : OUT std_logic;        -- signal switches dsan and dsbn on and off
      mstr_cycle              : IN std_logic;         -- signal indicates one or two cycles must be done
      second_word             : OUT std_logic;        -- signal indicates the actual master cycle
      vam_oe                  : OUT std_logic;        -- vam output enable   
      d64                     : IN std_logic;         -- indicates a d64 burst transmission
      
      -- connected with slave:
      asn_in                  : IN std_logic;         -- to detect a transaction
      
      --data bus bus control signals for vmebus drivers
      ma_io_ctrl              : OUT io_ctrl_type
   );
   
   END COMPONENT;
   
   COMPONENT vme_requester
     PORT (
      clk         : IN  std_logic;          
      rst         : IN  std_logic;
   -------------------------------------------------------------------------------
   -- PINS:
      -- Requesters Pins:
      br_i_n      : IN  std_logic_vector(3 DOWNTO 0);            -- bus requests monitored (FAIR)
      br_o_n      : OUT std_logic_vector(3 DOWNTO 0);            -- bus request
      bg_o_n      : OUT std_logic_vector(3 DOWNTO 0);            -- passed in idle state
      
      bbsyn_in    : IN std_logic;
      bbsyn       : OUT std_logic;            -- bus busy signal
   -------------------------------------------------------------------------------    
      -- connected with PowerPC Access
      dwb         : IN  std_logic;
      dgb         : OUT std_logic;
      
      FairReqEn   : IN std_logic;
      brl         : IN std_logic_vector(1 DOWNTO 0);              -- bus request level
      
      -- from Arbiter:
      bgintn      : IN  std_logic_vector(3 DOWNTO 0);       -- from internal Arbiter if in Slot 1,
                                                            -- else outside from VMEbus
      -- connected with master unit:
      req_bit     : IN  std_logic;                          -- '0'= release on request; '1'= release when done
      brel        : IN  std_logic                           -- indicates whether the bus arbitration can be released
      );
   END COMPONENT;
   
   COMPONENT vme_arbiter 
   PORT (
      clk               : IN  std_logic;     
      rst               : IN  std_logic;
   
      bgintn            : OUT std_logic_vector(3 DOWNTO 0); -- bus grant for all levels
       
      -- vme_du
      set_ato           : OUT std_logic;     -- if bit is set => ato bit will be set
      sysc_bit          : IN  std_logic;     -- '1' if board is in slot 1 => enables this vme arbiter
      bgouten           : IN  std_logic;     -- enables SGL and bg3out signal
       
      -- PINs:
      br_i_n            : IN std_logic_vector(3 DOWNTO 0);            -- bus requests monitored (FAIR)
      bg_i_n            : IN std_logic_vector(3 DOWNTO 0);            -- passed in idle state
      bbsyn_in          : IN  std_logic
   );
   END COMPONENT;
   
   COMPONENT vme_bustimer 
   PORT (
      clk               : IN  std_logic;           -- global clock
      rst               : IN  std_logic;           -- global reset
      startup_rst       : IN std_logic;            -- powerup reset
      prevent_sysrst    : IN std_logic;            -- if "1", sysrst_n_out will not be activated after powerup,
                                                   -- if "0", sysrst_n_out will be activated if in slot1 and system reset is active (sysc_bit or rst)
      
      set_sysc          : OUT std_logic;           -- if set sysc-bit will be set
      sysc_bit          : IN std_logic;            -- 1=slot1 0=slotx
      clr_sysr          : OUT std_logic;           -- if set sysr-bit will be cleared
      sysr_bit          : IN std_logic;            -- 1=system reset
      
      -- connected with Slave Unit
      dsain             : IN std_logic;            -- data strobe a in
      dsbin             : IN std_logic;            -- data strobe b in
      bgouten           : OUT std_logic;           -- enables SGL and bg3out signal
      
      -- bus grant daisy chain is driven through requester in Access VME:
      -----------------------------------------------------------------------
      -- PINs:
      sysfailn          : OUT   std_logic;         -- indicates when A15 is not ready or in reset
      sysrstn_in        : IN  std_logic;
      sysrstn_out       : OUT std_logic;
      v2p_rst           : OUT std_logic;           -- Reset between VMEbus and Host CPU
      bg3n_in           : IN  std_logic;           -- bus grant signal in (if not connected => slot01)
      slot01n           : OUT std_logic;           -- enables V_SYSCLK (16 MHz)
      berrn_out         : OUT std_logic            -- bus error 
       );
   END COMPONENT;
   
   COMPONENT vme_slave 
   PORT (   
      clk                     : IN std_logic;                     -- this Unit works at 66 MHz
      rst                     : IN std_logic;
      -------------------------------------------------------------------------------
      -- PINS (VMEbus, inputs asynchronous !):
      asn_in                  : IN std_logic;                     -- vme adress strobe input
      dsan_in                 : IN std_logic;                     -- vme data strobe A input
      dsbn_in                 : IN std_logic;                     -- vme data strobe B input
      dtackn_out              : OUT std_logic;                    -- vme data acknowledge output
      sl_writen_reg           : IN std_logic;                     -- vme read/write
      
      -------------------------------------------------------------------------------
      -- vme-mstr
      mstr_busy               : IN std_logic;                     -- if set, vme-master is busy
      
      -- vme_au
      sl_acc                  : IN std_logic_vector(4 DOWNTO 0);  -- A16 hit, A24 hit, A32 hit, D32 blt, D64 blt
      sl_acc_valid            : IN std_logic;                     -- sl_acc has been calculated and is valid
      my_iack                 : IN std_logic;
      wbm_we_o                : IN std_logic;                     -- mensb master read/write
      reg_acc                 : IN std_logic;                     -- reg access is requested by vmebus
      en_vme_adr_in           : OUT std_logic;                    -- samples adress and am after asn goes low
      asn_in_sl_reg           : OUT std_logic;                    -- registered asn signal
      
      -- sys_arbiter
      slave_req               : OUT std_logic;                    -- request signal for slave access
      slave_active            : IN std_logic;                     -- acknowledge/active signal for slave access
      sl_write_flag           : OUT std_logic;                    -- write flag for register access from vme side
      sl_second_word          : OUT std_logic;                    -- differs between address and data phase in d64 accesses
      
      -- vme_du
      sl_en_vme_data_in_reg   : OUT std_logic;                    -- enable vme input reg
      sl_en_vme_data_in_reg_high   : OUT std_logic;               -- slave enable of vme data high in registers
      sl_oe_vd                : OUT std_logic;                    -- output enable for vme data
      sl_oe_va                : OUT std_logic;                    -- output enable for vme adress
      reg_en_vme_data_out_reg : OUT std_logic;                    -- enable vme output reg
      sl_io_ctrl              : OUT io_ctrl_type;                 
      ld_loc_adr_m_cnt        : OUT std_logic;                    -- load address counter
      sl_inc_loc_adr_m_cnt    : OUT std_logic;                    -- increment address counter
      clr_intreq              : OUT std_logic;                    -- clear interrupt request (intr(3) <= '0'
                                                                  
      -- mensb_master                                             
      loc_keep                : OUT std_logic;                    -- if '1', csn remains active (keeps bus)
      mensb_mstr_req          : OUT std_logic;                    -- mensb master request
      mensb_mstr_ack          : IN std_logic                      -- mensb master acknowledge
        );
   END COMPONENT;
   
   COMPONENT vme_wbm 
   PORT (
      clk               : IN std_logic;
      rst               : IN std_logic;
      
      -- mensb master
      loc_keep          : IN std_logic;            -- if '1', csn remains active (keeps bus)
      wbm_stb_o         : OUT std_logic;
      wbm_ack_i         : IN std_logic;
      wbm_err_i         : IN std_logic;
      wbm_we_o          : IN std_logic;
      vme_cyc_sram      : OUT std_logic;           -- keeps bus arbitration to sram as long as active
      vme_cyc_pci       : OUT std_logic;           -- keeps bus arbitration to pci as long as active
      
      -- vme_slave
      mensb_mstr_req    : IN std_logic;            -- mensb master request
      mensb_mstr_ack    : OUT std_logic;           -- mensb master acknoledge
      
      -- vme_du
      sel_wbm_dat_o     : OUT std_logic;
      en_wbm_dat_o      : OUT std_logic;
      sl_en_vme_data_out_reg      : OUT std_logic; -- for normal d32 or d64 low
      sl_en_vme_data_out_reg_high : OUT std_logic; -- for d64 high
      
      -- vme_au
      inc_loc_adr_m_cnt : OUT std_logic;
      sl_acc_wb         : IN std_logic_vector(4 DOWNTO 0); -- slave access hits and burst data transmission type
      pci_acc           : IN std_logic;            -- pci access is requested by vmebus
      sram_acc          : IN std_logic             -- sram access is requested by vmebus
        );
   END COMPONENT;
   
   COMPONENT vme_mailbox 
   PORT (
      clk               : IN std_logic;                     -- 66 MHz
      rst               : IN std_logic;                     -- global reset signal (asynch)
      
      sl_acc            : IN std_logic_vector(4 DOWNTO 0);  -- slave access address type (sl16_hit, sl24_hit, sl32_hit, sl_blt32, sl_blt64)
      wbm_adr_o         : IN std_logic_vector(19 DOWNTO 2); -- mensb master adress lines
      wbm_we_o          : IN std_logic;                     -- mensb master read/write
      mensb_mstr_req    : IN std_logic;                     -- mensb master request
      ram_acc           : IN std_logic;                     -- external ram access
      mail_irq          : OUT std_logic_vector(7 DOWNTO 0)  -- mailbox interrupt requests (flags)
        );
   END COMPONENT;
      
   COMPONENT vme_locmon
   PORT (
      clk                     : IN std_logic;                     -- 66 MHz
      rst                     : IN std_logic;                     -- global reset signal (asynch)
      
      en_vme_adr_in           : IN std_logic;                     -- samples adress and am after asn goes low
      ma_en_vme_data_out_reg  : IN std_logic;                     -- enable of vme_adr_out
      sl_writen_reg           : IN std_logic;                     -- vme write/read
      vme_adr_locmon          : IN std_logic_vector(31 DOWNTO 2); -- vme adress for location monitoring (registered with en_vme_adr_in)
      vam_reg                 : IN std_logic_vector(5 DOWNTO 0);  -- vme registered vam_in
      
      clr_locmon              : IN std_logic_vector(1 DOWNTO 0);  -- clear address combination bits when clear status bit
      loc_sel                 : OUT std_logic_vector(1 DOWNTO 0); -- these bits are loaded with combinations of address bits [4:3] if locmon hit address         
      loc_am_0                : IN std_logic_vector(1 DOWNTO 0);  -- loc-monitor #0 - adress modus "00"-A32, "10"-A16, "11"-A24
      loc_am_1                : IN std_logic_vector(1 DOWNTO 0);  -- loc-monitor #1 - adress modus "00"-A32, "10"-A16, "11"-A24
      loc_irq_0               : OUT std_logic;                    -- loc-monitor #0 - irq
      loc_irq_1               : OUT std_logic;                    -- loc-monitor #1 - irq
      loc_rw_0                : IN std_logic_vector(1 DOWNTO 0);  -- [0]: read; [1]: write
      loc_rw_1                : IN std_logic_vector(1 DOWNTO 0);  -- [0]: read; [1]: write
      loc_adr_0               : IN std_logic_vector(31 DOWNTO 0); -- location monitor #0 adress
      loc_adr_1               : IN std_logic_vector(31 DOWNTO 0)  -- location monitor #1 adress
        );
   END COMPONENT;
   
   SIGNAL oe_vme_an                    : std_logic;                        -- data output enable A->B  
   SIGNAL oe_vme_dn                    : std_logic;                        -- data latch enable A->B   
   SIGNAL l_fpga_an                    : std_logic;                        -- address output enable B->A  
   SIGNAL oe_fpga_an                   : std_logic;                        -- address output enable A->B  
   SIGNAL dir_vam                      : std_logic;
                                       
   -- vme_wbs                          
   SIGNAL loc_write_flag               : std_logic;
   SIGNAL sel_loc_data_out             : std_logic_vector(1 DOWNTO 0);
   SIGNAL mensb_req                    : std_logic;
   SIGNAL vme_acc_type                 : std_logic_vector(8 DOWNTO 0);     -- signal indicates the type of VME access
   SIGNAL ma_en_vme_data_out_reg       : std_logic;   
   SIGNAL wb_dma_acc                   : std_logic;                        -- indicates dma_access
                                       
   -- mensb_mstr                       
   SIGNAL mensb_mstr_ack               : std_logic;
   SIGNAL wbs_sel_int                  : std_logic_vector(3 DOWNTO 0);
   SIGNAL burst                        : std_logic;
   SIGNAL sel_wbm_dat_o                : std_logic;
                                       
   -- vme_du                           
   SIGNAL clr_locmon                   : std_logic_vector(1 DOWNTO 0);     -- clear address combination bits when clear status bit
   SIGNAL vme_adr_out                  : std_logic_vector(31 DOWNTO 0);
   SIGNAL mstr_reg                     : std_logic_vector(13 DOWNTO 0);
   SIGNAL sysc_reg                     : std_logic_vector(2 DOWNTO 0);
   SIGNAL longadd                      : std_logic_vector(7 DOWNTO 0);
   SIGNAL slv16_reg                    : std_logic_vector(4 DOWNTO 0);
   SIGNAL slv24_reg                    : std_logic_vector(15 DOWNTO 0);
   SIGNAL slv32_reg                    : std_logic_vector(23 DOWNTO 0);
   SIGNAL slv24_pci_q                  : std_logic_vector(15 DOWNTO 0);    -- slave A24 base address register
   SIGNAL slv32_pci_q                  : std_logic_vector(23 DOWNTO 0);    -- slave A32 base address register
   SIGNAL intr_reg                     : std_logic_vector(3 DOWNTO 0);
   SIGNAL loc_am_0                     : std_logic_vector(1 DOWNTO 0);     -- loc-monitor #0 - adress modus "00"-A32, "10"-A16, "11"-A24
   SIGNAL loc_am_1                     : std_logic_vector(1 DOWNTO 0);     -- loc-monitor #1 - adress modus "00"-A32, "10"-A16, "11"-A24
   SIGNAL loc_irq_0                    : std_logic;                        -- loc-monitor #0 - irq
   SIGNAL loc_irq_1                    : std_logic;                        -- loc-monitor #1 - irq
   SIGNAL loc_rw_0                     : std_logic_vector(1 DOWNTO 0);     -- [0]: read; [1]: write
   SIGNAL loc_rw_1                     : std_logic_vector(1 DOWNTO 0);     -- [0]: read; [1]: write
   SIGNAL loc_adr_0                    : std_logic_vector(31 DOWNTO 0);    -- location monitor #0 adress
   SIGNAL loc_adr_1                    : std_logic_vector(31 DOWNTO 0);    -- location monitor #1 adress
   SIGNAL loc_sel                      : std_logic_vector(1 DOWNTO 0);     -- these bits are loaded with address bits [4:3] if locmon hit address         
   SIGNAL pci_offset_q                 : std_logic_vector(31 DOWNTO 2);    -- pci offset address for vme to pci access
   SIGNAL FairReqEn                    : std_logic;
   SIGNAL brl                          : std_logic_vector(1 DOWNTO 0);
                                       
   -- vme_au                           
   SIGNAL sl_acc_wb                    : std_logic_vector(4 DOWNTO 0);     -- sampled with ld_loc_adr_cnt
   SIGNAL ma_d64                       : std_logic;
   SIGNAL sl_d64                       : std_logic;
   SIGNAL vam_reg                      : std_logic_vector(5 DOWNTO 0);
   SIGNAL int_adr                      : std_logic_vector(18 DOWNTO 0);
   SIGNAL vme_adr_in                   : std_logic_vector(31 DOWNTO 0);
   SIGNAL wbm_adr_o_int                : std_logic_vector(31 DOWNTO 0);
   SIGNAL sl_sel_vme_data_out          : std_logic_vector(1 DOWNTO 0);
   SIGNAL int_be                       : std_logic_vector(3 DOWNTO 0);
   SIGNAL ma_byte_routing              : std_logic;
   SIGNAL sl_byte_routing              : std_logic;
   SIGNAL sl_acc                       : std_logic_vector(4 DOWNTO 0);
   SIGNAL sl_writen_reg                : std_logic;
   SIGNAL iackn_in_reg                 : std_logic;                        -- iack signal (registered with en_vme_adr_in)
   SIGNAL reg_acc                      : std_logic;
   SIGNAL sram_acc                     : std_logic;
   SIGNAL pci_acc                      : std_logic;
   SIGNAL clr_intreq                   : std_logic;
   SIGNAL my_iack                      : std_logic;
   SIGNAL wbm_we_o_int                 : std_logic;
   SIGNAL lwordn_slv                   : std_logic;                        -- stored for vme slave access
   SIGNAL lwordn_mstr                  : std_logic;                        -- master access lwordn
   SIGNAL vme_adr_in_reg               : std_logic_vector(31 DOWNTO 2);
   
   -- vme_sys_arbiter
   SIGNAL d64                          : std_logic;
   SIGNAL vme_adr_locmon               : std_logic_vector(31 DOWNTO 2);
   SIGNAL en_wbm_dat_o                 : std_logic;                        -- enable for wbm_dat_o
   SIGNAL sel_vme_data_out             : std_logic_vector(1 DOWNTO 0);
   SIGNAL mensb_active                 : std_logic;
   SIGNAL slave_active                 : std_logic;
   SIGNAL write_flag                   : std_logic;
   SIGNAL byte_routing                 : std_logic;
   SIGNAL oe_va                        : std_logic;
   SIGNAL oe_vd                        : std_logic;
   SIGNAL en_vme_data_out_reg          : std_logic;   
   SIGNAL ma_en_vme_data_out_reg_high  : std_logic:='0';
   SIGNAL sl_en_vme_data_out_reg_high  : std_logic;
   SIGNAL en_vme_data_out_reg_high     : std_logic:='0';
   SIGNAL en_vme_data_in_reg           : std_logic;
   SIGNAL lwordn                       : std_logic;                        -- lwordn for vme_du multiplexer
   SIGNAL swap                         : std_logic;
   SIGNAL en_vme_data_in_reg_high      : std_logic:='0';
   SIGNAL l_fpga_an_int                : std_logic;
   
   -- vme_master
   SIGNAL ma_oe_va                     : std_logic;
   SIGNAL ma_oe_vd                     : std_logic;
   SIGNAL ma_en_vme_data_in_reg        : std_logic;
   SIGNAL ma_en_vme_data_in_reg_high   : std_logic;                        -- load high register signal in data switch unit for rd vme
   SIGNAL dwb                          : std_logic;
   SIGNAL run_mstr                     : std_logic;
   SIGNAL mstr_busy                    : std_logic;
   SIGNAL mstr_vme_req                 : std_logic;
   SIGNAL mstr_ack                     : std_logic;
   SIGNAL brel                         : std_logic;
   SIGNAL rst_rmw                      : std_logic;
   SIGNAL set_berr                     : std_logic;
   SIGNAL dsn_ena                      : std_logic;
   SIGNAL mstr_cycle                   : std_logic;
   SIGNAL sl_second_word               : std_logic;
   SIGNAL ma_second_word               : std_logic;
   SIGNAL second_word                  : std_logic;
   SIGNAL vam_oe                       : std_logic;
   SIGNAL oe_vme_an_m                  : std_logic;
   SIGNAL oe_vme_dn_m                  : std_logic;
   SIGNAL oe_fpga_an_m                 : std_logic;
   SIGNAL l_fpga_an_m                  : std_logic;
   SIGNAL rst_aonly                    : std_logic;
   SIGNAL asn_out                      : std_logic;
   SIGNAL ds_o_n_int                   : std_logic_vector(1 DOWNTO 0);
   
   -- vme_slave
   SIGNAL sl_acc_valid                 : std_logic;
   SIGNAL asn_in_sl_reg                : std_logic;
   SIGNAL sl_en_vme_data_out_reg       : std_logic;
   SIGNAL reg_en_vme_data_out_reg      : std_logic;
   SIGNAL sl_write_flag                : std_logic;
   SIGNAL sl_oe_va                     : std_logic;
   SIGNAL sl_oe_vd                     : std_logic;
   SIGNAL sl_en_vme_data_in_reg        : std_logic;
   SIGNAL sl_en_vme_data_in_reg_high   : std_logic;
   SIGNAL slave_req                    : std_logic;
   SIGNAL ld_loc_adr_m_cnt             : std_logic;
   SIGNAL inc_loc_adr_m_cnt            : std_logic;
   SIGNAL sl_inc_loc_adr_m_cnt         : std_logic;
   SIGNAL mensb_mstr_req               : std_logic;
   SIGNAL loc_keep                     : std_logic;                        -- if '1', csn remains active (keeps bus)
   SIGNAL en_vme_adr_in                : std_logic;                        -- samples adress and am after asn goes low
   
   -- bustimer
   SIGNAL set_sysc                     : std_logic:='0';
   SIGNAL bgouten                      : std_logic;
   SIGNAL clr_sysr                     : std_logic;
   
   -- location
   
   -- vmearbiter
   SIGNAL bgintn                       : std_logic_vector(3 DOWNTO 0);
   SIGNAL set_ato                      : std_logic;
   
   -- interrupter
   
   -- handler
   
   -- requester
   SIGNAL dgb                          : std_logic;
   
   -- mailbox
   SIGNAL mail_irq                     : std_logic_vector(7 DOWNTO 0);
   
   SIGNAL io_ctrl                      : io_ctrl_type;
   SIGNAL ma_io_ctrl                   : io_ctrl_type;
   SIGNAL sl_io_ctrl                   : io_ctrl_type;
BEGIN
   
   d_dir     <= io_ctrl.d_dir  ; -- NOT oe_fpga_dn_int;
   d_oe_n    <= io_ctrl.d_oe_n ; -- '0';
   am_dir    <= io_ctrl.am_dir ; -- dir_vam;
   am_oe_n   <= io_ctrl.am_oe_n; -- '0';
   a_dir     <= io_ctrl.a_dir  ; -- ;
   a_oe_n    <= io_ctrl.a_oe_n ; -- '0';  
   
   test_vec.ato <= sysc_reg(2);
   
   ds_oe_n   <= '0' WHEN ds_o_n_int(0) = '0' OR ds_o_n_int(1) = '0' ELSE '1';
   ds_o_n <= ds_o_n_int;
   
   as_o_n <= asn_out;
   as_oe_n <= asn_out;
   
   vme_mstr_busy <= mstr_busy;
   vme_berr <= mstr_reg(2);
   postwr <= mstr_reg(4);
   FairReqEn <= mstr_reg(6);
   
   wbm_we_o <= wbm_we_o_int;
   wbm_adr_o <= wbm_adr_o_int;
   
   du : vme_du 
   GENERIC MAP (
      LONGADD_SIZE      => LONGADD_SIZE,
      USE_LONGADD       => USE_LONGADD
      )
   PORT MAP (
      clk                        => clk,
      rst                        => rst,
      dma_sta                    => dma_sta,
      clr_dma_en                 => clr_dma_en,
      set_dma_err                => set_dma_err,
      dma_act_bd                 => dma_act_bd,
      wbm_err_i                  => wbm_err_i,
      wbm_ack_i                  => wbm_ack_i,
      startup_rst                => startup_rst,
      vme_irq                    => vme_irq,
      berr_irq                   => berr_irq,
      locmon_irq                 => locmon_irq ,
      mailbox_irq                => mailbox_irq,
      write_flag                 => write_flag,
      d64                        => d64,
      vam_reg                    => vam_reg,
      vme_adr_in_reg             => vme_adr_in_reg,
      sl_writen_reg              => sl_writen_reg,
      iackn_in_reg               => iackn_in_reg,
      sel_reg_data_in            => mensb_active,
      sel_loc_data_out           => sel_loc_data_out,
      en_wbm_dat_o               => en_wbm_dat_o,
      brl                        => brl,
      second_word                => second_word,
      sel_wbm_dat_o              => sel_wbm_dat_o,
      wbs_tga_i                  => wbs_tga_i,
      swap                       => swap,
      lwordn                     => lwordn,
      int_adr                    => int_adr,
      int_be                     => int_be,
      clr_intreq                 => clr_intreq,
      vme_adr_out                => vme_adr_out,
      byte_routing               => byte_routing,
      vme_adr_in                 => vme_adr_in,
      oe_va                      => oe_va,
      oe_vd                      => oe_vd,
      sel_vme_data_out           => sel_vme_data_out,
      en_vme_data_out_reg        => en_vme_data_out_reg,
      en_vme_data_out_reg_high   => en_vme_data_out_reg_high,
      en_vme_data_in_reg         => en_vme_data_in_reg,
      en_vme_data_in_reg_high    => en_vme_data_in_reg_high,
      clr_locmon                 => clr_locmon,
      longadd                    => longadd,
      mstr_reg                   => mstr_reg,
      sysc_reg                   => sysc_reg,
      set_berr                   => set_berr,
      my_iack                    => my_iack,
      rst_rmw                    => rst_rmw,
      set_sysc                   => set_sysc,
      set_ato                    => set_ato,
      clr_sysr                   => clr_sysr,
      wbs_dat_o                  => wbs_dat_o,
      wbs_dat_i                  => wbs_dat_i,
      wbm_dat_o                  => wbm_dat_o,
      wbm_dat_i                  => wbm_dat_i,
      slv16_reg                  => slv16_reg,
      slv24_reg                  => slv24_reg,
      slv32_reg                  => slv32_reg,
      slv24_pci_q                => slv24_pci_q,
      slv32_pci_q                => slv32_pci_q,
      mail_irq                   => mail_irq,
      loc_am_0                   => loc_am_0,
      loc_am_1                   => loc_am_1,
      loc_irq_0                  => loc_irq_0,
      loc_irq_1                  => loc_irq_1,
      loc_rw_0                   => loc_rw_0,
      loc_rw_1                   => loc_rw_1,
      loc_adr_0                  => loc_adr_0,
      loc_adr_1                  => loc_adr_1,
      loc_sel                    => loc_sel,
      intr_reg                   => intr_reg,
      pci_offset_q               => pci_offset_q,
      rst_aonly                  => rst_aonly,
      irq_i_n                    => irq_i_n,
      irq_o_n                    => irq_o_n,
      acfailn                    => acfailn,
      ga                         => ga,
      gap                        => gap,
      vd                         => vd,
      va                         => va
   );
   
   sys_arbiter : vme_sys_arbiter
   PORT MAP (
      clk                  => clk,
      rst                  => rst,
      
      io_ctrl              => io_ctrl,
      ma_io_ctrl           => ma_io_ctrl,
      sl_io_ctrl           => sl_io_ctrl,
      
      mensb_req            => mensb_req,
      slave_req            => slave_req,
      mstr_busy            => mstr_busy,
      mstr_vme_req         => mstr_vme_req,
      mensb_active         => mensb_active,
      slave_active         => slave_active,
      
      lwordn_slv           => lwordn_slv,
      lwordn_mstr          => lwordn_mstr,
      lwordn               => lwordn,
      
      write_flag           => write_flag,
      ma_byte_routing      => ma_byte_routing,
      sl_byte_routing      => sl_byte_routing,
      byte_routing         => byte_routing,
      
      sl_sel_vme_data_out  => sl_sel_vme_data_out,
      sel_vme_data_out     => sel_vme_data_out,
      
      oe_vd                => oe_vd,
      ma_oe_vd             => ma_oe_vd,
      sl_oe_vd             => sl_oe_vd,
      
      oe_va                => oe_va,
      ma_oe_va             => ma_oe_va,
      sl_oe_va             => sl_oe_va,
      
      ma_second_word       => ma_second_word,
      sl_second_word       => sl_second_word,
      second_word          => second_word,
      
      ma_en_vme_data_out_reg  => ma_en_vme_data_out_reg,
      sl_en_vme_data_out_reg  => sl_en_vme_data_out_reg,
      reg_en_vme_data_out_reg => reg_en_vme_data_out_reg,
      en_vme_data_out_reg     => en_vme_data_out_reg,
      
      ma_en_vme_data_out_reg_high   => ma_en_vme_data_out_reg_high,
      sl_en_vme_data_out_reg_high   => sl_en_vme_data_out_reg_high,
      en_vme_data_out_reg_high      => en_vme_data_out_reg_high,
      
      swap               => swap,
      ma_swap            => vme_acc_type(5),
      
      ma_d64            => ma_d64,
      sl_d64            => sl_d64,
      d64               => d64,
      
      ma_en_vme_data_in_reg      => ma_en_vme_data_in_reg,
      sl_en_vme_data_in_reg      => sl_en_vme_data_in_reg,
      en_vme_data_in_reg         => en_vme_data_in_reg,
      
      ma_en_vme_data_in_reg_high => ma_en_vme_data_in_reg_high,
      sl_en_vme_data_in_reg_high => sl_en_vme_data_in_reg_high,
      en_vme_data_in_reg_high    => en_vme_data_in_reg_high,
      
      vme_adr_locmon             => vme_adr_locmon,
      vme_adr_in_reg             => vme_adr_in_reg,
      vme_adr_out                => vme_adr_out(31 DOWNTO 2),
      
      loc_write_flag             => loc_write_flag,
      sl_write_flag              => sl_write_flag
   );
   
   wbs : vme_wbs 
   PORT MAP (
      clk                           => clk,
      rst                           => rst,
      set_berr                      => set_berr,
      wbs_stb_i                     => wbs_stb_i,
      wbs_ack_o                     => wbs_ack_o,
      wbs_err_o                     => wbs_err_o,
      wbs_we_i                      => wbs_we_i,
      wbs_cyc_i                     => wbs_cyc_i,
      wbs_adr_i                     => wbs_adr_i,
      wbs_sel_i                     => wbs_sel_i,
      wbs_sel_int                   => wbs_sel_int,
      wbs_tga_i                     => wbs_tga_i,
      wb_dma_acc                    => wb_dma_acc,
      loc_write_flag                => loc_write_flag,
      ma_en_vme_data_out_reg        => ma_en_vme_data_out_reg,
      ma_en_vme_data_out_reg_high   => ma_en_vme_data_out_reg_high,
      mensb_req                     => mensb_req,
      mensb_active                  => mensb_active,
      vme_acc_type                  => vme_acc_type,
      run_mstr                      => run_mstr,
      mstr_ack                      => mstr_ack,
      mstr_busy                     => mstr_busy,
      burst                         => burst,
      sel_loc_data_out              => sel_loc_data_out
   );
   
   au : vme_au
   GENERIC MAP (
      A16_REG_MAPPING   => A16_REG_MAPPING,
      LONGADD_SIZE      => LONGADD_SIZE,
      USE_LONGADD       => USE_LONGADD
   )
   PORT MAP (
      clk                     => clk,
      rst                     => rst,
      test                    => open,
      wbs_adr_i               => wbs_adr_i,
      wbs_sel_i               => wbs_sel_int,
      wbs_we_i                => wbs_we_i,
      wbs_tga_i               => wbs_tga_i,
      vme_adr_in              => vme_adr_in,
      vme_adr_out             => vme_adr_out,
      vme_adr_in_reg          => vme_adr_in_reg,
      sl_acc_wb               => sl_acc_wb,
      ma_en_vme_data_out_reg  => ma_en_vme_data_out_reg,
      asn_in                  => as_i_n,
      mensb_active            => mensb_active,
      int_be                  => int_be,
      int_adr                 => int_adr,
      clr_intreq              => clr_intreq,
      iackn                   => iackn,
      iackin                  => iackin,
      iackoutn                => iackoutn,
      vam_oe                  => vam_oe,
      vam                     => vam,
      vme_acc_type            => vme_acc_type,
      second_word             => second_word,
      dsn_ena                 => dsn_ena,
      mstr_reg                => mstr_reg,
      longadd                 => longadd,
      mstr_cycle              => mstr_cycle,
      ma_byte_routing         => ma_byte_routing,
      sysc_reg                => sysc_reg,
      sl_sel_vme_data_out     => sl_sel_vme_data_out,
      sl_byte_routing         => sl_byte_routing,
      ld_loc_adr_m_cnt        => ld_loc_adr_m_cnt,
      inc_loc_adr_m_cnt       => inc_loc_adr_m_cnt,
      sl_inc_loc_adr_m_cnt    => sl_inc_loc_adr_m_cnt,
      sl_en_vme_data_in_reg   => sl_en_vme_data_in_reg,
      writen                  => writen,
      sram_acc                => sram_acc,
      pci_acc                 => pci_acc,
      ma_d64                  => ma_d64,
      sl_d64                  => sl_d64,
      reg_acc                 => reg_acc,
      intr_reg                => intr_reg,
      lwordn_slv              => lwordn_slv,
      lwordn_mstr             => lwordn_mstr,
      en_vme_adr_in           => en_vme_adr_in,
      my_iack                 => my_iack,
      wbm_adr_o               => wbm_adr_o_int,
      wbm_sel_o               => wbm_sel_o,
      wbm_we_o                => wbm_we_o_int,
      vam_reg                 => vam_reg,
      dsan_out                => ds_o_n_int(0),
      dsbn_out                => ds_o_n_int(1),
      dsan_in                 => ds_i_n(0),
      dsbn_in                 => ds_i_n(1),
      sl_writen_reg           => sl_writen_reg,
      iackn_in_reg            => iackn_in_reg,
      sl_acc                  => sl_acc,
      sl_acc_valid            => sl_acc_valid,
      pci_offset_q            => pci_offset_q,
      asn_in_sl_reg           => asn_in_sl_reg,
      slv24_pci_q             => slv24_pci_q,
      slv32_pci_q             => slv32_pci_q,
      slv16_reg               => slv16_reg,
      slv24_reg               => slv24_reg,
      slv32_reg               => slv32_reg
   );
   
   master : vme_master 
   PORT MAP(
      clk                        => clk,
      rst                        => rst,
      test_c                     => OPEN,
      run_mstr                   => run_mstr,
      mstr_ack                   => mstr_ack,
      mstr_busy                  => mstr_busy,
      vme_req                    => mstr_vme_req,
      burst                      => burst,
      ma_en_vme_data_in_reg      => ma_en_vme_data_in_reg,
      ma_en_vme_data_in_reg_high => ma_en_vme_data_in_reg_high,
      wb_dma_acc                 => wb_dma_acc,
      brel                       => brel,
      wbs_we_i                   => wbs_we_i,
      dwb                        => dwb,
      dgb                        => dgb,
      berrn_in                   => berrin,
      dtackn_in                  => dtackin,
      d64                        => ma_d64,
      asn_out                    => asn_out,
      rst_aonly                  => rst_aonly,
      rst_rmw                    => rst_rmw,
      set_berr                   => set_berr,
      vam_oe                     => vam_oe,
      ma_oe_va                   => ma_oe_va,
      ma_oe_vd                   => ma_oe_vd,
      dsn_ena                    => dsn_ena,
      mstr_cycle                 => mstr_cycle,
      second_word                => ma_second_word,
      asn_in                     => as_i_n,
      mstr_reg                   => mstr_reg(5 DOWNTO 0),
      ma_io_ctrl                 => ma_io_ctrl
   );
   
   requester : vme_requester
   PORT MAP (
      clk                 => clk,
      rst                 => rst,
      br_i_n             => br_i_n,
      br_o_n             => br_o_n,
      bg_o_n             => bg_o_n,
      bbsyn_in            => bbsyin,
      bbsyn               => bbsyn,
      dwb                 => dwb,
      dgb                 => dgb,
      FairReqEn           => FairReqEn,
      brl                 => brl,
      bgintn              => bgintn,
      req_bit             => mstr_reg(1),
      brel                => brel
   );
   
   arbiter : vme_arbiter 
   PORT MAP (
      clk            => clk,
      rst            => rst,
      bgintn         => bgintn,
      set_ato        => set_ato,
      sysc_bit       => sysc_reg(0),
      bgouten        => bgouten,
      br_i_n         => br_i_n,
      bbsyn_in       => bbsyin,
      bg_i_n         => bg_i_n
   );
   
   bustimer : vme_bustimer 
   PORT MAP (
      clk               => clk,
      rst               => rst,
      startup_rst       => startup_rst,
      prevent_sysrst    => prevent_sysrst,
      set_sysc          => set_sysc,
      sysc_bit          => sysc_reg(0),
      clr_sysr          => clr_sysr,
      sysr_bit          => sysc_reg(1),
      dsain             => ds_i_n(0),
      dsbin             => ds_i_n(1),
      bgouten           => bgouten,
      sysfailn          => sysfail_o_n,
      sysrstn_in        => sysresin,
      sysrstn_out       => sysresn,
      v2p_rst           => v2p_rst,
      bg3n_in           => bg_i_n(3),
      slot01n           => slot01n,
      berrn_out         => berrn
      );
   
   slave : vme_slave 
   PORT MAP (
      clk                        => clk,
      rst                        => rst,
      loc_keep                   => loc_keep,
      mstr_busy                  => mstr_busy,
      asn_in                     => as_i_n,
      dsan_in                    => ds_i_n(0),
      dsbn_in                    => ds_i_n(1),
      reg_acc                    => reg_acc,
      sl_writen_reg              => sl_writen_reg,
      en_vme_adr_in              => en_vme_adr_in,
      wbm_we_o                   => wbm_we_o_int,
      dtackn_out                 => dtackn,
      slave_req                  => slave_req,
      slave_active               => slave_active,
      sl_write_flag              => sl_write_flag,
      sl_second_word             => sl_second_word,
      clr_intreq                 => clr_intreq,
      sl_acc                     => sl_acc,
      sl_acc_valid               => sl_acc_valid,
      asn_in_sl_reg              => asn_in_sl_reg,
      my_iack                    => my_iack,
      sl_en_vme_data_in_reg      => sl_en_vme_data_in_reg,
      sl_en_vme_data_in_reg_high => sl_en_vme_data_in_reg_high,
      sl_oe_va                   => sl_oe_va,
      sl_oe_vd                   => sl_oe_vd,
      reg_en_vme_data_out_reg    => reg_en_vme_data_out_reg,
      sl_io_ctrl                 => sl_io_ctrl,
      ld_loc_adr_m_cnt           => ld_loc_adr_m_cnt,
      sl_inc_loc_adr_m_cnt       => sl_inc_loc_adr_m_cnt,
      mensb_mstr_req             => mensb_mstr_req,
      mensb_mstr_ack             => mensb_mstr_ack
   );
   
   wbm : vme_wbm 
   PORT MAP (
      clk                           => clk,
      rst                           => rst,
      loc_keep                      => loc_keep,
      vme_cyc_sram                  => vme_cyc_sram,
      vme_cyc_pci                   => vme_cyc_pci,
      wbm_stb_o                     => wbm_stb_o,
      wbm_err_i                     => wbm_err_i,
      wbm_ack_i                     => wbm_ack_i,
      wbm_we_o                      => wbm_we_o_int,
      sl_en_vme_data_out_reg        => sl_en_vme_data_out_reg,
      sl_en_vme_data_out_reg_high   => sl_en_vme_data_out_reg_high,
      mensb_mstr_req                => mensb_mstr_req,
      mensb_mstr_ack                => mensb_mstr_ack,
      sel_wbm_dat_o                 => sel_wbm_dat_o,
      en_wbm_dat_o                  => en_wbm_dat_o,
      inc_loc_adr_m_cnt             => inc_loc_adr_m_cnt,
      sl_acc_wb                     => sl_acc_wb,
      pci_acc                       => pci_acc,
      sram_acc                      => sram_acc
   );
   
   mailbox : vme_mailbox 
   PORT MAP(
      clk               => clk,
      rst               => rst,
      
      sl_acc            => sl_acc,
      wbm_adr_o         => wbm_adr_o_int(19 DOWNTO 2),
      wbm_we_o          => wbm_we_o_int,
      mensb_mstr_req    => mensb_mstr_req,
      ram_acc           => sram_acc,
      mail_irq          => mail_irq
   );
   
   locmon : vme_locmon
   PORT MAP(
      clk                     => clk,
      rst                     => rst,
      en_vme_adr_in           => en_vme_adr_in,
      ma_en_vme_data_out_reg  => ma_en_vme_data_out_reg,
      sl_writen_reg           => sl_writen_reg,
      vme_adr_locmon          => vme_adr_locmon,
      vam_reg                 => vam_reg,
      clr_locmon              => clr_locmon,
      loc_sel                 => loc_sel,
      loc_am_0                => loc_am_0,
      loc_am_1                => loc_am_1,
      loc_irq_0               => loc_irq_0,
      loc_irq_1               => loc_irq_1,
      loc_rw_0                => loc_rw_0,
      loc_rw_1                => loc_rw_1,
      loc_adr_0               => loc_adr_0,
      loc_adr_1               => loc_adr_1
   );
   
END vme_ctrl_arch;


