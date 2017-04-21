--------------------------------------------------------------------------------
-- Title         : VME Address Unit
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : vme_au.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 14/01/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- This module consists of all adress counters, switches and
-- muxes which are controlled by vme_master and vme_slave. 
-- The usage gets arbitrated by vme_sys_arbiter.
--------------------------------------------------------------------------------
-- Hierarchy:
--
-- wbb2vme
--    vme_ctrl
--       vme_au
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
-- $Log: vme_au.vhd,v $
-- Revision 1.7  2015/09/16 09:20:09  mwawrik
-- Added generics A16_REG_MAPPING and USE_LONGADD
--
-- Revision 1.6  2015/04/07 14:30:16  AGeissler
-- R1: MAIN_PR002233
-- M1: Added a valid signal for sl_acc to inform the VME slave component, that
--     it can use sl_acc to define the type of the access
--
-- Revision 1.5  2014/04/17 07:35:31  MMiehling
-- added generic LONGADD_SIZE
-- changed vme slave access to A16 to sram access
-- added address modifiers for vme slave access: 0x3e, 0x3a, 0x0e, 0x0a
--
-- Revision 1.4  2014/02/07 17:00:06  MMiehling
-- bugfix: IACK addressing
--
-- Revision 1.2  2012/08/27 12:57:24  MMiehling
-- added comments
-- changed iackn handling
--
-- Revision 1.1  2012/03/29 10:14:51  MMiehling
-- Initial Revision
--
-- Revision 1.16  2010/03/12 13:38:18  mmiehling
-- changed
-- iackoutn <= iackoutn_int WHEN asn_in = '0' ELSE '1';  -- rising edge of asn_in must inactivate iackoutn immediately!
-- to
-- iackoutn <= iackoutn_int;
--
-- Revision 1.15  2006/11/17 08:55:58  mmiehling
-- added synchronisation register for iack_in and iachin_daisy
--
-- Revision 1.14  2006/06/02 15:48:53  MMiehling
-- logic for iackoutn => when asn=1 then iackoutn<=1
-- corrected condition for entering state otherirq
--
-- Revision 1.13  2006/05/26 14:34:48  MMiehling
-- added fsm for my_iack detection and iack-daisy-chain => irqs will not be lost
--
-- Revision 1.12  2006/05/18 14:29:01  MMiehling
-- iack daisy chain input was not correct detected (when dsa/b goes low is correct)
-- unused address signals of vme-master access are set to '0'
--
-- Revision 1.11  2004/11/02 11:29:50  mmiehling
-- improved timing and area
--
-- Revision 1.10  2004/07/27 17:15:35  mmiehling
-- changed pci-core to 16z014
-- changed wishbone bus to wb_bus.vhd
-- added clk_trans_wb2wb.vhd
-- improved dma
--
-- Revision 1.9  2004/06/17 13:02:23  MMiehling
-- removed clr_hit and sl_acc_reg
--
-- Revision 1.8  2003/12/17 15:51:41  MMiehling
-- byte swapping was wrong in "not swapped" mode
--
-- Revision 1.6  2003/07/14 08:38:04  MMiehling
-- lwordn was wrong
--
-- Revision 1.5  2003/06/24 13:47:04  MMiehling
-- changed int_adr
--
-- Revision 1.4  2003/06/13 10:06:31  MMiehling
-- improved
--
-- Revision 1.3  2003/04/22 11:02:56  MMiehling
-- improved timing
--
-- Revision 1.2  2003/04/02 16:11:31  MMiehling
-- Kommentar entfernt
--
-- Revision 1.1  2003/04/01 13:04:40  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY vme_au IS
   GENERIC (
      A16_REG_MAPPING   : boolean := TRUE;                        -- if true, access to vme slave A16 space goes to vme runtime registers and above 0x800 to sram (compatible to old revisions)
                                                                  -- if false, access to vme slave A16 space goes to sram
      LONGADD_SIZE      : integer range 3 TO 8:=3;
      USE_LONGADD       : boolean := TRUE                          -- If FALSE, bits (7 DOWNTO 5) of SIGNAL longadd will be allocated to vme_adr_out(31 DOWNTO 29)
                                                                   -- If TRUE, number of bits allocated to vme_adr_out depends on GENERIC LONGADD_SIZE
      );
   PORT (
      clk                  : IN std_logic;                      -- 66 MHz
      rst                  : IN std_logic;                      -- global reset signal (asynch)
      test                 : OUT std_logic;
      
      -- mensb slave
      wbs_adr_i               : IN std_logic_vector(31 DOWNTO 0);    -- mensb slave adress lines
      wbs_sel_i               : IN std_logic_vector(3 DOWNTO 0);     -- mensb slave byte enable lines
      wbs_we_i                : IN std_logic;                        -- mensb slave read/write
      vme_acc_type            : IN std_logic_vector(6 DOWNTO 0);     -- signal indicates the type of VME slave access
      ma_en_vme_data_out_reg  : IN std_logic;                        -- enable of vme_adr_out
      wbs_tga_i               : IN std_logic_vector(8 DOWNTO 0);
      
      -- mensb master
      wbm_adr_o            : OUT std_logic_vector(31 DOWNTO 0);   -- mensb master adress lines
      wbm_sel_o            : OUT std_logic_vector(3 DOWNTO 0);    -- mensb master byte enable lines
      wbm_we_o             : OUT std_logic;                       -- mensb master read/write
      sram_acc             : OUT std_logic;                       -- sram access is requested by vmebus
      pci_acc              : OUT std_logic;                       -- pci access is requested by vmebus
      reg_acc              : OUT std_logic;                       -- reg access is requested by vmebus
      sl_acc_wb            : OUT std_logic_vector(4 DOWNTO 0);    -- sampled with ld_loc_adr_cnt
      
      -- vme
      vme_adr_in           : IN std_logic_vector(31 DOWNTO 0);    -- vme address input lines
      vme_adr_out          : OUT std_logic_vector(31 DOWNTO 0);   -- vme address output lines
      
      ---------------------------------------------------------------------------------------------------
      -- pins to vmebus
      asn_in               : IN std_logic;                        -- vme adress strobe input
      vam                  : INOUT std_logic_vector(5 DOWNTO 0);  -- vme address modifier
      dsan_out             : OUT std_logic;                       -- data strobe byte(0) out
      dsbn_out             : OUT std_logic;                       -- data strobe byte(1) out
      dsan_in              : IN std_logic;                        -- data strobe byte(0) in
      dsbn_in              : IN std_logic;                        -- data strobe byte(1) in
      writen               : INOUT std_logic;                     -- write enable      tco = tbd.   tsu <= tbd.   PIN tbd.
      iackn                : INOUT std_logic;                     -- handler's output !   PIN tbd.
      iackin               : IN std_logic;                        -- vme daisy chain interrupt acknoledge input
      iackoutn             : OUT std_logic;                       -- vme daisy chain interrupt acknoledge output
      ---------------------------------------------------------------------------------------------------
      
      mensb_active         : IN std_logic;      -- acknoledge/active signal for mensb slave access
      
      -- vme master
      mstr_cycle           : OUT std_logic;     -- number of master cycles should be done (0=1x, 1=2x)
      second_word          : IN std_logic;      -- indicates the second transmission if in D16 mode and 32bit should be transmitted
      dsn_ena              : IN std_logic;      -- signal switches dsan_out and dsbn_out on and off
      vam_oe               : IN std_logic;      -- vam output enable
      ma_d64               : OUT std_logic;     -- indicates a d64 burst transmission
      sl_d64               : OUT std_logic;     -- indicates a d64 burst transmission
      
      -- vme slave
      sl_acc                  : OUT std_logic_vector(4 DOWNTO 0); -- slave access hits and burst data transmission type
      sl_acc_valid            : OUT std_logic;                    -- sl_acc has been calculated and is valid
      asn_in_sl_reg           : IN std_logic;                     -- registered asn signal
      ld_loc_adr_m_cnt        : IN std_logic;                     -- load address counter
      inc_loc_adr_m_cnt       : IN std_logic;                     -- increment address counter
      sl_inc_loc_adr_m_cnt    : IN std_logic;                     -- increment address counter
      sl_writen_reg           : OUT std_logic;
      my_iack                 : OUT std_logic;
      clr_intreq              : IN std_logic;                     -- clear interrupt request (intr(3) <= '0'
      sl_en_vme_data_in_reg   : IN std_logic;                     -- register enable for vme data in
      en_vme_adr_in           : IN std_logic;                     -- samples adress and am after asn goes low
      
      -- sys_arbiter
      sl_byte_routing      : OUT std_logic;                       -- to mensb byte routing
      ma_byte_routing      : OUT std_logic;                       -- signal for byte swapping
      sl_sel_vme_data_out  : OUT std_logic_vector(1 DOWNTO 0);    -- mux select: 00=loc_data_in_m 01=loc_data_in_s 10=reg_data
      lwordn_slv           : OUT std_logic;                       -- stored for vme slave access
      lwordn_mstr          : OUT std_logic;                       -- master access lwordn
      
      -- locmon
      vam_reg              : OUT std_logic_vector(5 DOWNTO 0);    -- registered vam_in
      vme_adr_in_reg       : OUT std_logic_vector(31 DOWNTO 2);   -- vme adress for location monitoring (registered with en_vme_adr_in)
      
      -- vme_du
      mstr_reg             : IN std_logic_vector(13 DOWNTO 0);    -- master register (aonly, postwr, iberr, berr, req, rmw, A16_MODE, A24_MODE, A32_MODE)
      longadd              : IN std_logic_vector(7 DOWNTO 0);     -- upper 3 address bits for A32 mode or dependent on LONGADD_SIZE
      slv16_reg            : IN std_logic_vector(4 DOWNTO 0);     -- slave A16 base address register
      slv24_reg            : IN std_logic_vector(15 DOWNTO 0);    -- slave A24 base address register
      slv32_reg            : IN std_logic_vector(23 DOWNTO 0);    -- slave A32 base address register
      slv24_pci_q          : IN std_logic_vector(15 DOWNTO 0);    -- slave A24 base address register for PCI
      slv32_pci_q          : IN std_logic_vector(23 DOWNTO 0);    -- slave A32 base address register for PCI
      intr_reg             : IN std_logic_vector(3 DOWNTO 0);     -- interrupt request register
      sysc_reg             : IN std_logic_vector(2 DOWNTO 0);     -- system control register (ato, sysr, sysc)
      pci_offset_q         : IN std_logic_vector(31 DOWNTO 2);    -- pci offset address for vme to pci access
      
      int_be               : OUT std_logic_vector(3 DOWNTO 0);    -- internal byte enables
      int_adr              : OUT std_logic_vector(18 DOWNTO 0)    -- internal adress
   );
END vme_au;

ARCHITECTURE vme_au_arch OF vme_au IS 
   CONSTANT AM_NON_DAT : std_logic_vector(1 DOWNTO 0):="00";   -- address modifier code for non-privileged data access
   CONSTANT AM_NON_PRO : std_logic_vector(1 DOWNTO 0):="01";   -- address modifier code for non-privileged program access
   CONSTANT AM_SUP_DAT : std_logic_vector(1 DOWNTO 0):="10";   -- address modifier code for supervisory data access    
   CONSTANT AM_SUP_PRO : std_logic_vector(1 DOWNTO 0):="11";   -- address modifier code for supervisory program access 
   
   TYPE   irq_states IS (idle, myirq, otherirq);
   SIGNAL irq_state : irq_states;
   SIGNAL vam_in              : std_logic_vector(5 DOWNTO 0);
   SIGNAL vam_out             : std_logic_vector(5 DOWNTO 0);
   SIGNAL vme_a1              : std_logic;
   SIGNAL my_iack_int         : std_logic;
   SIGNAL dsan_out_int        : std_logic;
   SIGNAL dsbn_out_int        : std_logic;
   SIGNAL wbm_adr_o_cnt       : std_logic_vector(31 DOWNTO 1);
   SIGNAL wbm_adr_load        : std_logic_vector(31 DOWNTO 1);
   SIGNAL ld_loc_adr_m_cnt_q  : std_logic;
   SIGNAL vam_in_reg          : std_logic_vector(5 DOWNTO 0);
   SIGNAL dsan_in_reg         : std_logic;
   SIGNAL dsbn_in_reg         : std_logic;
   SIGNAL sl_acc_d_type       : std_logic_vector(3 DOWNTO 0);         -- slave access data type
   SIGNAL wbm_sel_o_int       : std_logic_vector(3 DOWNTO 0);
   SIGNAL sl_byte_routing_int : std_logic;
   SIGNAL sl_hit              : std_logic_vector(2 DOWNTO 0);     -- sl32, sl24, sl16, sl24, sl32
   SIGNAL pci_hit             : std_logic_vector(1 DOWNTO 0);
   SIGNAL sl_acc_valid_int    : std_logic;
   SIGNAL sl_acc_valid_int_q  : std_logic;
   SIGNAL sl_acc_valid_int_qq : std_logic;
   SIGNAL sl_acc_a_type       : std_logic_vector(4 DOWNTO 0);     -- slave access address type (sl16_hit, sl24_hit, sl32_hit, sl_blt32, sl_blt64)
   SIGNAL sl_acc_int          : std_logic_vector(4 DOWNTO 0);
   SIGNAL sl_writen_reg_int   : std_logic;
   SIGNAL sl_writen_int       : std_logic;
   SIGNAL reg_acc_int         : std_logic;
   SIGNAL iackn_out           : std_logic;
   SIGNAL iackn_in            : std_logic;
   SIGNAL iackin_daisy        : std_logic;
   SIGNAL iackn_int_in        : std_logic;
   SIGNAL vme_adr_in_reg_int  : std_logic_vector(31 DOWNTO 0);
   SIGNAL wbm_sel_o_reg       : std_logic_vector(3 DOWNTO 0);
   SIGNAL mstr_cycle_int      : std_logic;
   SIGNAL lwordn_mstr_int     : std_logic;
   SIGNAL sl_acc_reg          : std_logic_vector(5 DOWNTO 0);
   SIGNAL pci_acc_int         : std_logic;
   SIGNAL lwordn_slv_int      : std_logic;
   SIGNAL asn_q               : std_logic;
   SIGNAL iackn_in_q          : std_logic;
   
   SIGNAL vme_a16_mask        : std_logic_vector(31 DOWNTO 12);
   SIGNAL vme_a24_mask        : std_logic_vector(31 DOWNTO 12);
   SIGNAL vme_a32_mask        : std_logic_vector(31 DOWNTO 12);
   SIGNAL vme_a24_pci_mask    : std_logic_vector(31 DOWNTO 12);
   SIGNAL vme_a32_pci_mask    : std_logic_vector(31 DOWNTO 12);
   SIGNAL vme_adr_mask        : std_logic_vector(31 DOWNTO 12);
   SIGNAL iackoutn_int        : std_logic;
   
BEGIN
   
   sl_acc <= sl_acc_reg(4 DOWNTO 0);
   sl_d64 <= sl_acc_reg(0);
   pci_acc <= pci_acc_int;
   lwordn_slv <= lwordn_slv_int;
   lwordn_mstr <= lwordn_mstr_int;
   sl_writen_reg <= sl_writen_reg_int;
   
   mstr_cycle <= mstr_cycle_int;
   reg_acc <= reg_acc_int;
   
   wbm_sel_o <= wbm_sel_o_reg;
   my_iack <= my_iack_int;
   vme_adr_in_reg <= vme_adr_in_reg_int(31 DOWNTO 2);
   
   -- sl_sel_vme_data_out <= "10" WHEN reg_acc_int = '1' OR my_iack_int = '1' ELSE "00";
   sl_sel_vme_data_out <= "10" WHEN reg_acc_int = '1' ELSE "00";
   
   -- if swapping is disabled, dsan and dsbn is exchanged
   -- vme_acc_type(5) = swap-bit
   dsan_out <= dsan_out_int WHEN dsn_ena = '1' AND vme_acc_type(5) = '1' ELSE
               dsbn_out_int WHEN dsn_ena = '1' AND vme_acc_type(5) = '0' ELSE '1';
   dsbn_out <= dsbn_out_int WHEN dsn_ena = '1' AND vme_acc_type(5) = '1' ELSE 
               dsan_out_int WHEN dsn_ena = '1' AND vme_acc_type(5) = '0' ELSE '1';
                  
   vme_adr_out(1 DOWNTO 0) <= vme_a1 & lwordn_mstr_int;
   
   wbm_adr_o      <= wbm_adr_o_cnt(31 DOWNTO 2) & "00";
   
   sl_acc_d_type  <= dsbn_in_reg & dsan_in_reg & wbm_adr_o_cnt(1) & lwordn_slv_int; -- dsan, dsbn, a1, lwordn_slv
   sl_acc_valid   <= sl_acc_valid_int_qq;
   
   -- sl_hit: vme slave base adress is hit in A16, A24, A32 mode       
   -- sl_acc_a_type: AM hit sl16_hit, sl24_hit, sl32_hit, sl_blt32, sl_blt64
   sl_acc_int     <= (sl_hit AND sl_acc_a_type(4 DOWNTO 2)) & sl_acc_a_type(1 DOWNTO 0);
   
   vam_reg        <= vam_in_reg;
   
   -------------------------------------------------------------------------------
   -- IACK-Daisy Chain Driver
   -------------------------------------------------------------------------------  
   -- It is needed to reset the iackn_int_in signal asynchron (if sysc = 1), in
   -- order to meet timing: v_asin = 0->1  => iackout = 0->1 after max 30ns
   -- (spec: page 183 time 35)
   iackn_int_in   <= iackn_in_q  WHEN sysc_reg(0) = '1' ELSE iackin_daisy;    -- if in slot 1, don't wait on asn
   
   iackoutn <= iackoutn_int;
   test <= '0' WHEN irq_state = idle ELSE '1';
   
   irq_fsm : PROCESS (clk, rst)
   BEGIN
      IF rst = '1' THEN
         irq_state      <= idle;
         my_iack_int    <= '0';
         iackoutn_int   <= '1';
         asn_q          <= '1';
         iackin_daisy   <= '1';
         iackn_in_q     <= '1';
      ELSIF clk'EVENT AND clk = '1' THEN
         iackn_in_q <= iackn_in;
         asn_q <= asn_in;
         iackin_daisy <= iackin;
         
         CASE irq_state IS
            WHEN idle =>
               IF iackn_in_q = '0' AND asn_q = '0' AND iackn_int_in = '0' AND (dsan_in_reg = '0' OR dsbn_in_reg = '0') AND
                  intr_reg(3) = '1' AND intr_reg(2 DOWNTO 0) = vme_adr_in_reg_int(3 DOWNTO 1) THEN
                  irq_state <= myirq;
                  my_iack_int <= '1';  -- my iack => answer iack
                  iackoutn_int <= '1';     -- my iack => do not give to next board
               ELSIF iackn_in_q = '0' AND asn_q = '0' AND iackn_int_in = '0' AND (dsan_in_reg = '0' OR dsbn_in_reg = '0') THEN
                  irq_state <= otherirq;
                  my_iack_int <= '0';  -- not my iack => do not answer iack
                  iackoutn_int <= '0';     -- not my iack => give to next board
               ELSE
                  irq_state <= idle;
                  my_iack_int <= '0';
                  iackoutn_int <= '1';
               END IF;
            
            WHEN myirq =>
               IF clr_intreq = '1' THEN 
                  irq_state <= idle;
                  my_iack_int <= '0';
                  iackoutn_int <= '1';
               ELSE
                  irq_state <= myirq;
                  my_iack_int <= '1';  -- my iack => answer iack
                  iackoutn_int <= '1';     -- my iack => do not give to next board
               END IF;
            
            WHEN otherirq =>
               IF asn_q = '1' THEN
                  irq_state <= idle;
                  my_iack_int <= '0';
                  iackoutn_int <= '1';
               ELSE
                  irq_state <= otherirq;
                  my_iack_int <= '0';  -- not my iack => do not answer iack
                  iackoutn_int <= '0';     -- not my iack => give to next board
               END IF;
            
            WHEN OTHERS =>
               irq_state <= idle;
               my_iack_int <= '0';
               iackoutn_int <= '1';
         END CASE;
      END IF;
   END PROCESS irq_fsm;
   
   am : PROCESS(vam, vam_oe, vam_out)
   BEGIN
      IF vam_oe = '1' THEN
         vam <= vam_out;
         vam_in <= to_x01(vam);
      ELSE
         vam <= (OTHERS => 'Z');
         vam_in <= to_x01(vam);
      END IF;
   END PROCESS am;
   
   wri : PROCESS(vam_oe, wbs_we_i, writen)
   BEGIN
      IF vam_oe = '1' THEN
         writen <= NOT wbs_we_i;
         sl_writen_int <= to_x01(writen);
      ELSE
         writen <= 'Z';
         sl_writen_int <= to_x01(writen);
      END IF;
   END PROCESS wri;
   
   iack : PROCESS (vam_oe, iackn, iackn_out)
   BEGIN
      IF vam_oe = '1' THEN
         iackn <= iackn_out;
         iackn_in <= to_x01(iackn);
      ELSE
         iackn <= 'Z';
         iackn_in <= to_x01(iackn);
      END IF;
   END PROCESS iack;
   
   acc_type : PROCESS(sl_acc_d_type, my_iack_int)
   BEGIN
      IF my_iack_int = '1' THEN
         wbm_sel_o_int <= "1111";
         sl_byte_routing_int <= '1';
      ELSE
         CASE sl_acc_d_type IS        -- dsan, dsbn, a1, lwordn_slv
            WHEN "0000" =>    wbm_sel_o_int <= "1111";
                        sl_byte_routing_int <= '0';
                        
            WHEN "0011" =>    wbm_sel_o_int <= "1100";
                        sl_byte_routing_int <= '0';
                        
            WHEN "0001" =>    wbm_sel_o_int <= "0011";
                        sl_byte_routing_int <= '1';
                        
            WHEN "1011" =>    wbm_sel_o_int <= "1000";
                        sl_byte_routing_int <= '0';
                        
            WHEN "0111" =>    wbm_sel_o_int <= "0100";
                        sl_byte_routing_int <= '0';
                        
            WHEN "1001" =>    wbm_sel_o_int <= "0010";
                        sl_byte_routing_int <= '1';
                        
            WHEN "0101" =>    wbm_sel_o_int <= "0001";
                        sl_byte_routing_int <= '1';
                        
            WHEN OTHERS =>    wbm_sel_o_int <= "0000";
                        sl_byte_routing_int <= '0';
         END CASE;
      END IF;
   END PROCESS acc_type;  
   
   mstr_adr : PROCESS(clk, rst)
   BEGIN
      IF rst = '1' THEN
         wbm_adr_o_cnt              <= (OTHERS => '0');
         wbm_adr_load               <= (OTHERS => '0');
         wbm_we_o                   <= '1';
         wbm_sel_o_reg              <= "0000";
         vam_in_reg                 <= (OTHERS => '0');
         dsan_in_reg                <= '1';
         dsbn_in_reg                <= '1';
         sram_acc                   <= '0';
         pci_acc_int                <= '0';
         reg_acc_int                <= '0';
         vme_adr_in_reg_int         <= (OTHERS => '0');
         vme_adr_out(31 DOWNTO 2)   <= (OTHERS => '0');
         int_adr                    <= (OTHERS => '0');
         int_be                     <= (OTHERS => '0');
         ld_loc_adr_m_cnt_q         <= '0';
         lwordn_slv_int             <= '0';
         sl_acc_wb                  <= (OTHERS => '0');
         sl_acc_valid_int           <= '0';
         sl_acc_valid_int_q         <= '0';
         sl_acc_valid_int_qq        <= '0';
         sl_writen_reg_int          <= '0';
         sl_byte_routing            <= '0';
         sl_hit                     <= (OTHERS => '0');
         sl_acc_reg                 <= (OTHERS => '0');
         
      ELSIF clk'EVENT AND clk = '1' THEN
         ld_loc_adr_m_cnt_q <= ld_loc_adr_m_cnt;
         
         --sl_acc_valid
         ------------------------------------------
         -- wait for valid address
         IF asn_in_sl_reg = '1' THEN
            sl_acc_valid_int  <= '0';
         ELSIF en_vme_adr_in = '1' THEN
            sl_acc_valid_int  <= '1';
         END IF;
         
         -- wait until address is check to generate sl_hit signals
         IF asn_in_sl_reg = '1' THEN
            sl_acc_valid_int_q   <= '0';
         ELSE
            sl_acc_valid_int_q   <= sl_acc_valid_int;
         END IF;
         
         -- wait until hit is stored in sl_acc_reg register
         IF asn_in_sl_reg = '1' THEN
            sl_acc_valid_int_qq  <= '0';
         ELSE
            sl_acc_valid_int_qq  <= sl_acc_valid_int_q;
         END IF;
         -----------------------------------------
         
         IF mensb_active = '1' THEN
            int_adr <= wbs_adr_i(18 DOWNTO 0);
            int_be <= wbs_sel_i;
         ELSE
            int_adr <= wbm_adr_o_cnt(18 DOWNTO 2) & "00";
            int_be <= wbm_sel_o_reg;
         END IF;
         
         -- select VME address based on address mode, LONGADD register and generics
         IF ma_en_vme_data_out_reg = '1' THEN
         		if vme_acc_type(1 DOWNTO 0) = "00" then         													-- A24
            	vme_adr_out(31 DOWNTO 2) <= "00000000" & wbs_adr_i(23 DOWNTO 2);
            		
            elsif vme_acc_type(1 downto 0) = "01" then         												-- A32
	            IF wbs_tga_i(7) = '0' THEN   																								-- single access from PCI / no dma?
	              IF USE_LONGADD = TRUE THEN 																								-- flexible size of longadd parameter => not compatible to A21!
	                vme_adr_out(31 DOWNTO 2) <= longadd(7 DOWNTO (8-LONGADD_SIZE)) & wbs_adr_i((31-LONGADD_SIZE) DOWNTO 2);    
	              ELSE  																																		-- compatibility mode: uses 3 bits of longadd (compatible to A21/A15)
	                vme_adr_out(31 DOWNTO 2) <= longadd(2 DOWNTO 0) & wbs_adr_i(28 DOWNTO 2);       
	              END IF;
	            ELSE 																																				-- dma access uses complete address (no LONGADD usage)
								vme_adr_out(31 DOWNTO 2) <= wbs_adr_i(31 DOWNTO 2);
	            END IF;

           	else																																			-- A16
           		vme_adr_out(31 DOWNTO 2) <= "0000000000000000" & wbs_adr_i(15 DOWNTO 2);
            END if;
            	
         END IF;
         
         IF en_vme_adr_in = '1' THEN                         -- samples adress and am at falling edge asn 
            vme_adr_in_reg_int <= vme_adr_in;
            vam_in_reg <= vam_in;
            sl_writen_reg_int <= sl_writen_int;
         END IF;
         
         sl_acc_reg(4 DOWNTO 0) <= sl_acc_int;
         IF (pci_hit(0) = '1' AND sl_hit(0) = '1') OR (pci_hit(1) = '1' AND sl_hit(1) = '1') THEN
            sl_acc_reg(5) <= '1';
         ELSE
            sl_acc_reg(5) <= '0';
         END IF;
         
         IF sl_en_vme_data_in_reg = '1' THEN
            wbm_sel_o_reg <= wbm_sel_o_int;
         END IF;
         sl_byte_routing <= sl_byte_routing_int;
         
         dsan_in_reg <= dsan_in;
         dsbn_in_reg <= dsbn_in;
           
         IF slv16_reg(4) = '1' AND slv16_reg(3 DOWNTO 0) = vme_adr_in_reg_int(15 DOWNTO 12) THEN
            sl_hit(2) <= '1';                                             -- sl16 base address hit
         ELSE
            sl_hit(2) <= '0';
         END IF;
         
         
         IF slv24_reg(4) = '1' AND 
            ( (slv24_reg(3 DOWNTO 0) & (slv24_reg(15 DOWNTO 12) AND slv24_reg(11 DOWNTO 8))) = 
              (vme_adr_in_reg_int(23 DOWNTO 20) & (slv24_reg(15 DOWNTO 12) AND vme_adr_in_reg_int(19 DOWNTO 16))) ) THEN
            sl_hit(1)   <= '1';
            pci_hit(1)  <= '0';                                             -- sl24 base address hit
         ELSIF slv24_pci_q(4) = '1' AND 
            ( (slv24_pci_q(3 DOWNTO 0) & (slv24_pci_q(15 DOWNTO 12) AND slv24_pci_q(11 DOWNTO 8))) = 
              (vme_adr_in_reg_int(23 DOWNTO 20) & (slv24_pci_q(15 DOWNTO 12) AND vme_adr_in_reg_int(19 DOWNTO 16))) ) THEN
            sl_hit(1)   <= '1';
            pci_hit(1)  <= '1';                                             -- sl24 base address hit
         ELSE
            sl_hit(1)   <= '0';
            pci_hit(1)  <= '0';                                             -- sl24 base address hit
         END IF;
         
         IF slv32_reg(4) = '1' AND 
            ( (slv32_reg(3 DOWNTO 0) & (slv32_reg(15 DOWNTO 8) AND slv32_reg(23 DOWNTO 16))) = 
              (vme_adr_in_reg_int(31 DOWNTO 28) & (vme_adr_in_reg_int(27 DOWNTO 20) AND slv32_reg(23 DOWNTO 16))) ) THEN
            sl_hit(0)   <= '1';
            pci_hit(0)  <= '0';                                             -- sl32 base address hit
         ELSIF slv32_pci_q(4) = '1' AND 
            ( (slv32_pci_q(3 DOWNTO 0) & (slv32_pci_q(15 DOWNTO 8) AND slv32_pci_q(23 DOWNTO 16))) = 
              (vme_adr_in_reg_int(31 DOWNTO 28) & (vme_adr_in_reg_int(27 DOWNTO 20) AND slv32_pci_q(23 DOWNTO 16))) ) THEN
            sl_hit(0)   <= '1';
            pci_hit(0)  <= '1';                                             -- sl32 base address hit
         ELSE
            sl_hit(0)   <= '0';
            pci_hit(0)  <= '0';                                             -- sl32 base address hit
         END IF;
         
         IF ld_loc_adr_m_cnt = '1' THEN
            lwordn_slv_int <= vme_adr_in_reg_int(0);
            sl_acc_wb <= sl_acc_reg(4 DOWNTO 0);
            wbm_we_o <= NOT sl_writen_reg_int;
              IF sl_acc_reg(4) = '1' THEN                     -- A16 space is requested by vme bus
                 IF A16_REG_MAPPING THEN
                  -- if true, access to vme slave A16 space goes to vme runtime registers and above 0x800 to sram (compatible to old revisions of A21)
                    IF vme_adr_in_reg_int(11) = '1' THEN          -- sram access is requested (0x800)
                       sram_acc    <= '1';
                       reg_acc_int <= '0';
                    ELSE
                       reg_acc_int <= '1';                        -- register access is requested (0x000)
                       sram_acc    <= '0';
                    END IF;
                  -- if false, access to vme slave A16 space goes to sram
                 ELSE
                    sram_acc        <= '1';
                    reg_acc_int     <= '0';
                 END IF;
                 pci_acc_int     <= '0';
              ELSIF (sl_acc_reg(3) = '1' OR sl_acc_reg(2) = '1') AND sl_acc_reg(5) = '0' THEN   -- A24 or A32 space is requested by vme bus
                 sram_acc        <= '1';                     -- sram access is requested
                 reg_acc_int     <= '0';
                 pci_acc_int     <= '0';
              ELSIF (sl_acc_reg(3) = '1' OR sl_acc_reg(2) = '1') AND sl_acc_reg(5) = '1' THEN   -- A24 or A32 space is requested by vme bus
                 sram_acc        <= '0';
                 reg_acc_int     <= '0';
                 pci_acc_int     <= '1';                     -- pci access is requested
              ELSE
                 sram_acc        <= '0';
                 reg_acc_int     <= '0';
                 pci_acc_int     <= '0';
              END IF;
               
              wbm_adr_load(31 DOWNTO 1) <= vme_adr_mask & vme_adr_in_reg_int(11 DOWNTO 1) ;
              
         END IF;
            
         IF ld_loc_adr_m_cnt_q = '1' AND pci_acc_int = '1' THEN
            wbm_adr_o_cnt <= (wbm_adr_load(31 DOWNTO 12) + pci_offset_q(31 DOWNTO 12)) & wbm_adr_load(11 DOWNTO 1);
         ELSIF ld_loc_adr_m_cnt_q = '1' AND pci_acc_int = '0' THEN
            wbm_adr_o_cnt <= wbm_adr_load;
         ELSIF (inc_loc_adr_m_cnt = '1' OR sl_inc_loc_adr_m_cnt = '1') AND lwordn_slv_int = '0' THEN
            wbm_adr_o_cnt(31 DOWNTO 2) <= wbm_adr_o_cnt(31 DOWNTO 2) + 1;
            wbm_adr_o_cnt(1) <= '0';
         ELSIF (inc_loc_adr_m_cnt = '1' OR sl_inc_loc_adr_m_cnt = '1') AND lwordn_slv_int = '1' THEN
            wbm_adr_o_cnt(31 DOWNTO 1) <= wbm_adr_o_cnt(31 DOWNTO 1) + 1;
         END IF;
       END IF;
   END PROCESS mstr_adr;  
   
   vme_a16_mask          <= "00000000000000000000";
   vme_a24_mask          <= "000000000000" &    (vme_adr_in_reg_int(19 DOWNTO 16) AND NOT slv24_reg(11 DOWNTO 8)) & vme_adr_in_reg_int(15 DOWNTO 12);
   vme_a24_pci_mask      <= "000000000000" &    (vme_adr_in_reg_int(19 DOWNTO 16) AND NOT slv24_pci_q(11 DOWNTO 8)) & vme_adr_in_reg_int(15 DOWNTO 12);
   vme_a32_mask          <= "0000" &          (vme_adr_in_reg_int(27 DOWNTO 20) AND NOT slv32_reg(23 DOWNTO 16))    & vme_adr_in_reg_int(19 DOWNTO 12);
   vme_a32_pci_mask      <= "0000" &          (vme_adr_in_reg_int(27 DOWNTO 20) AND NOT slv32_pci_q(23 DOWNTO 16)) & vme_adr_in_reg_int(19 DOWNTO 12);
   
   vme_adr_mask <= vme_a24_pci_mask   WHEN sl_acc_a_type(4 DOWNTO 3) = "01" AND sl_acc_reg(5) = '1' ELSE
                   vme_a24_mask       WHEN sl_acc_a_type(4 DOWNTO 3) = "01" AND sl_acc_reg(5) = '0' ELSE
                   vme_a16_mask       WHEN sl_acc_a_type(4 DOWNTO 3) = "10" ELSE
                   vme_a32_pci_mask   WHEN sl_acc_a_type(4 DOWNTO 3) = "00" AND sl_acc_reg(5) = '1' ELSE
                   vme_a32_mask;
   
   
   lg_dec : PROCESS(clk, rst)
   BEGIN  
      IF rst = '1' THEN
         sl_acc_a_type <= "00000";
         
      ELSIF clk'EVENT AND clk = '1' THEN
         CASE vam_in_reg(5 DOWNTO 0) IS
                     --  sl_acc_a_type = sl16_hit, sl24_hit, sl32_hit, sl_blt32, sl_blt64
            WHEN "111111" =>   sl_acc_a_type <= "01010";      -- 3f  A24 supervisory block transfer            
            WHEN "111110" =>   sl_acc_a_type <= "01000";      -- 3e  A24 supervisory program access               
            WHEN "111101" =>   sl_acc_a_type <= "01000";      -- 3d  A24 supervisory data access               
            WHEN "111100" =>   sl_acc_a_type <= "01001";      -- 3c  A24 supervisory 64-bit block transfer     
            WHEN "111011" =>   sl_acc_a_type <= "01010";      -- 3b  A24 non privileged block transfer         
            WHEN "111010" =>   sl_acc_a_type <= "01000";      -- 3a  A24 non privileged program transfer         
            WHEN "111001" =>   sl_acc_a_type <= "01000";      -- 39  A24 non privileged data access            
            WHEN "111000" =>   sl_acc_a_type <= "01001";      -- 38  A24 non privileged 64-bit block transfer  
            
            WHEN "101101" =>   sl_acc_a_type <= "10000";      -- 2d  A16 supervisory access
            WHEN "101001" =>   sl_acc_a_type <= "10000";      -- 29  A16 non privileged access
            
            WHEN "001111" =>   sl_acc_a_type <= "00110";      -- 0f  A32 supervisory block transfer
            WHEN "001110" =>   sl_acc_a_type <= "00100";      -- 0e  A32 supervisory program access
            WHEN "001101" =>   sl_acc_a_type <= "00100";      -- 0d  A32 supervisory data access
            WHEN "001100" =>   sl_acc_a_type <= "00101";      -- 0c  A32 supervisory 64-bit block transfer
            WHEN "001011" =>   sl_acc_a_type <= "00110";      -- 0b  A32 non privileged block transfer                
            WHEN "001010" =>   sl_acc_a_type <= "00100";      -- 0a  A32 non privileged program access                   
            WHEN "001001" =>   sl_acc_a_type <= "00100";      -- 09  A32 non privileged data access                   
            WHEN "001000" =>   sl_acc_a_type <= "00101";      -- 08  A32 non privileged 64-bit block transfer         
            WHEN OTHERS =>  sl_acc_a_type <= "00000";
         END CASE;
      END IF;
   END PROCESS lg_dec;
   
   -- vme_acc_type:
   --                  M S B D  A
   -- A16/D16          m 0 0 00 10
   -- A16/D32          m 0 0 01 10
   -- A24/D16          m 0 0 00 00
   -- A24/D32          m 0 0 01 00
   -- CR/CSR           x 0 0 11 00
   -- A32/D32          m 0 0 01 01
   -- IACK             m 0 0 00 11
   -- A32/D32/BLT      m 0 1 01 01
   -- A32/D64/BLT      m 0 1 10 01
   -- A24/D16/BLT      m 0 1 00 00
   -- A24/D32/BLT      m 0 1 01 00
   --  " swapped       m 1 x xx xx
   --
   -- m = 0: non-privileged 
   -- m = 1: supervisory
   
   vam_proc : PROCESS (clk, rst)
   BEGIN
      IF rst = '1' THEN
         vam_out <= (OTHERS => '0');
         lwordn_mstr_int   <= '0';
         ma_byte_routing <= '0';
         mstr_cycle_int   <= '0';
         dsan_out_int <= '1';
         dsbn_out_int <= '1';
         vme_a1 <= '0';
         iackn_out <= '1';
         ma_d64 <= '0';
      ELSIF clk'EVENT AND clk = '1' THEN
         CASE vme_acc_type(4 DOWNTO 0) IS
            WHEN "00011" => vam_out <= "010000";-- x10   IACK-Cycle
                      iackn_out <= '0';
                        lwordn_mstr_int   <= '1';
                      mstr_cycle_int   <= '0';
                      ma_d64 <= '0';
                      IF (wbs_sel_i(0) = '1' OR wbs_sel_i(1) = '1') THEN
                         vme_a1 <= '0';         -- only low word will be transmitted
                         dsan_out_int   <= '0';
                         dsbn_out_int   <= '1';
                         ma_byte_routing <= '1';
                      ELSE
                         vme_a1 <= '1';         -- only high word will be transmitted
                         dsan_out_int   <= '0';
                         dsbn_out_int   <= '1';
                         ma_byte_routing <= '0';
                      END IF;
            WHEN "00010" => 
                      CASE mstr_reg(9 DOWNTO 8) IS                 -- A16_MODE
                         WHEN AM_NON_DAT => vam_out <= "101001";   -- x29   A16 D16 non-privileged access
                         WHEN OTHERS     => vam_out <= "101101";   -- x2D   A16 D16 supervisory access
                      END CASE;
                      iackn_out <= '1';
                      ma_d64 <= '0';
                       lwordn_mstr_int   <= '1';
                        IF (wbs_sel_i(0) = '1' OR wbs_sel_i(1) = '1') AND (wbs_sel_i(2) = '1' OR wbs_sel_i(3) = '1') THEN
                           mstr_cycle_int   <= '1';         -- there must be two master cycles in order to transmitt 32bit in D16 mode
                        ELSE
                           mstr_cycle_int   <= '0';
                        END IF;
                        IF second_word = '0' OR (second_word = '1' AND mstr_cycle_int = '0') THEN      -- first word of two
                           IF (wbs_sel_i(0) = '1' OR wbs_sel_i(1) = '1') THEN
                              vme_a1 <= '0';         -- only low word will be transmitted
                              dsan_out_int   <= NOT wbs_sel_i(1);
                              dsbn_out_int   <= NOT wbs_sel_i(0);
                              ma_byte_routing <= '1';
                           ELSE
                              vme_a1 <= '1';         -- only high word will be transmitted
                              dsan_out_int   <= NOT wbs_sel_i(3);
                              dsbn_out_int   <= NOT wbs_sel_i(2);
                              ma_byte_routing <= '0';
                           END IF;
                        ELSE                     -- second word of two
                           dsan_out_int   <= NOT wbs_sel_i(3);
                           dsbn_out_int   <= NOT wbs_sel_i(2);
                           ma_byte_routing <= '0';
                           vme_a1 <= '1';
                        END IF;
            
            WHEN "00000" => 
                       CASE mstr_reg(11 DOWNTO 10) IS
                          WHEN AM_NON_DAT => vam_out <= "111001";   -- x39   A24 D16 non-privileged data access
                          WHEN AM_NON_PRO => vam_out <= "111010";   -- x3A   A24 D16 non-privileged program access
                          WHEN AM_SUP_DAT => vam_out <= "111101";   -- x3D   A24 D16 supervisory data access    
                          WHEN OTHERS     => vam_out <= "111110";   -- x3E   A24 D16 supervisory program access 
                       END CASE;
                      iackn_out <= '1';
                      ma_d64 <= '0';
                        lwordn_mstr_int   <= '1';
                        IF (wbs_sel_i(0) = '1' OR wbs_sel_i(1) = '1') AND (wbs_sel_i(2) = '1' OR wbs_sel_i(3) = '1') THEN
                           mstr_cycle_int   <= '1';         -- there must be two master cycles in order to transmit 32bit in D16 mode
                        ELSE
                           mstr_cycle_int   <= '0';
                        END IF;
                        IF second_word = '0' OR (second_word = '1' AND mstr_cycle_int = '0') THEN      -- first word of two
                         IF (wbs_sel_i(0) = '1' OR wbs_sel_i(1) = '1') THEN
                              vme_a1 <= '0';         -- only low word will be transmitted
                              dsan_out_int   <= NOT wbs_sel_i(1);
                              dsbn_out_int   <= NOT wbs_sel_i(0);
                              ma_byte_routing <= '1';
                           ELSE
                              vme_a1 <= '1';         -- only high word will be transmitted
                              dsan_out_int   <= NOT wbs_sel_i(3);
                              dsbn_out_int   <= NOT wbs_sel_i(2);
                              ma_byte_routing <= '0';
                           END IF;
                        ELSE                     -- second word of two
                           dsan_out_int   <= NOT wbs_sel_i(3);
                           dsbn_out_int   <= NOT wbs_sel_i(2);
                           ma_byte_routing <= '0';
                           vme_a1 <= '1';
                        END IF;
                        
            WHEN "01100" => 
                      	vam_out <= "101111";   -- x2f   CR/CSR access
                      	iackn_out <= '1';
                      	ma_d64 <= '0';
                        mstr_cycle_int   <= '0';
								IF wbs_sel_i = "1111" THEN          -- D32 access
							      IF vme_acc_type(5) = '1' THEN
								      ma_byte_routing <= '0';
								   ELSE
								      ma_byte_routing <= '1';
								   END IF;
								   dsan_out_int <= '0';
								   dsbn_out_int <= '0';
								   vme_a1 <= '0';
									lwordn_mstr_int   <= '0';
								ELSE                                -- D16 access
								   lwordn_mstr_int   <= '1';
							      IF (wbs_sel_i(0) = '1' OR wbs_sel_i(1) = '1') THEN
							         vme_a1 <= '0';         -- only low word will be transmitted
							         dsan_out_int   <= NOT wbs_sel_i(1);
							         dsbn_out_int   <= NOT wbs_sel_i(0);
							         ma_byte_routing <= '1';
							      ELSE
							         vme_a1 <= '1';         -- only high word will be transmitted
							         dsan_out_int   <= NOT wbs_sel_i(3);
							         dsbn_out_int   <= NOT wbs_sel_i(2);
							         ma_byte_routing <= '0';
							      END IF;
								END IF;

            WHEN "00100" => 
                       CASE mstr_reg(11 DOWNTO 10) IS               
                          WHEN AM_NON_DAT => vam_out <= "111001";   -- x39   A24 D32 non-privileged data access
                          WHEN AM_NON_PRO => vam_out <= "111010";   -- x3A   A24 D32 non-privileged program access
                          WHEN AM_SUP_DAT => vam_out <= "111101";   -- x3D   A24 D32 supervisory data access    
                          WHEN OTHERS     => vam_out <= "111110";   -- x3E   A24 D32 supervisory program access 
                       END CASE;
                      iackn_out <= '1';
                      ma_d64 <= '0';
                      IF wbs_sel_i = "1111" THEN
                           IF vme_acc_type(5) = '1' THEN
                            ma_byte_routing <= '0';
                         ELSE
                            ma_byte_routing <= '1';
                         END IF;
                         mstr_cycle_int   <= '0';
                          dsan_out_int <= '0';
                         dsbn_out_int <= '0';
                         vme_a1 <= '0';
                           lwordn_mstr_int   <= '0';
                      ELSE      -- same as D16 access
                           lwordn_mstr_int   <= '1';
                           IF (wbs_sel_i(0) = '1' OR wbs_sel_i(1) = '1') AND (wbs_sel_i(2) = '1' OR wbs_sel_i(3) = '1') THEN
                              mstr_cycle_int   <= '1';         -- there must be two master cycles in order to transmit 32bit in D16 mode
                           ELSE
                              mstr_cycle_int   <= '0';
                           END IF;
                           IF second_word = '0' OR (second_word = '1' AND mstr_cycle_int = '0') THEN      -- first word of two
                              IF (wbs_sel_i(0) = '1' OR wbs_sel_i(1) = '1') THEN
                                 vme_a1 <= '0';         -- only low word will be transmitted
                                 dsan_out_int   <= NOT wbs_sel_i(1);
                                 dsbn_out_int   <= NOT wbs_sel_i(0);
                                 ma_byte_routing <= '1';
                              ELSE
                                 vme_a1 <= '1';         -- only high word will be transmitted
                                 dsan_out_int   <= NOT wbs_sel_i(3);
                                 dsbn_out_int   <= NOT wbs_sel_i(2);
                                 ma_byte_routing <= '0';
                              END IF;
                           ELSE                     -- second word of two
                              dsan_out_int   <= NOT wbs_sel_i(3);
                              dsbn_out_int   <= NOT wbs_sel_i(2);
                              ma_byte_routing <= '0';
                              vme_a1 <= '1';
                           END IF;
                      END IF;
            
            WHEN "00110" => 
                      CASE mstr_reg(9 DOWNTO 8) IS                 -- A16_MODE
                         WHEN AM_NON_DAT => vam_out <= "101001";   -- x29   A16 D16 non-privileged access
                         WHEN OTHERS     => vam_out <= "101101";   -- x2D   A16 D16 supervisory access
                      END CASE;
                      iackn_out <= '1';
                      ma_d64 <= '0';
                        IF wbs_sel_i = "1111" THEN
                           IF vme_acc_type(5) = '1' THEN
                            ma_byte_routing <= '0';
                         ELSE
                            ma_byte_routing <= '1';
                         END IF;
                         mstr_cycle_int   <= '0';
                          dsan_out_int <= '0';
                         dsbn_out_int <= '0';
                         vme_a1 <= '0';
                           lwordn_mstr_int   <= '0';
                      ELSE      -- same as D16 access
                           lwordn_mstr_int   <= '1';
                           IF (wbs_sel_i(0) = '1' OR wbs_sel_i(1) = '1') AND (wbs_sel_i(2) = '1' OR wbs_sel_i(3) = '1') THEN
                              mstr_cycle_int   <= '1';         -- there must be two master cycles in order to transmitt 32bit in D16 mode
                           ELSE
                              mstr_cycle_int   <= '0';
                           END IF;
                           IF second_word = '0' OR (second_word = '1' AND mstr_cycle_int = '0') THEN      -- first word of two
                              IF (wbs_sel_i(0) = '1' OR wbs_sel_i(1) = '1') THEN
                                 vme_a1 <= '0';         -- only low word will be transmitted
                                 dsan_out_int   <= NOT wbs_sel_i(1);
                                 dsbn_out_int   <= NOT wbs_sel_i(0);
                                 ma_byte_routing <= '1';
                              ELSE
                                 vme_a1 <= '1';         -- only high word will be transmitted
                                 dsan_out_int   <= NOT wbs_sel_i(3);
                                 dsbn_out_int   <= NOT wbs_sel_i(2);
                                 ma_byte_routing <= '0';
                              END IF;
                           ELSE                     -- second word of two
                              dsan_out_int   <= NOT wbs_sel_i(3);
                              dsbn_out_int   <= NOT wbs_sel_i(2);
                              ma_byte_routing <= '0';
                              vme_a1 <= '1';
                           END IF;
                      END IF;
            
            WHEN "00101" =>   
                      CASE mstr_reg(13 DOWNTO 12) IS               -- A32_MODE
                         WHEN AM_NON_DAT => vam_out <= "001001";   -- x09   A32 D32 non-privileged data access
                         WHEN AM_NON_PRO => vam_out <= "001010";   -- x0A   A32 D32 non-privileged program access
                         WHEN AM_SUP_DAT => vam_out <= "001101";   -- x0D   A32 D32 supervisory data access    
                         WHEN OTHERS     => vam_out <= "001110";   -- x0E   A32 D32 supervisory program access 
                      END CASE;
                      iackn_out <= '1';
                      ma_d64 <= '0';
                        IF wbs_sel_i = "1111" THEN
                           IF vme_acc_type(5) = '1' THEN
                            ma_byte_routing <= '0';
                         ELSE
                            ma_byte_routing <= '1';
                         END IF;
                         mstr_cycle_int   <= '0';
                          dsan_out_int <= '0';
                         dsbn_out_int <= '0';
                         vme_a1 <= '0';
                           lwordn_mstr_int   <= '0';
                      ELSE      -- same as D16 access
                           lwordn_mstr_int   <= '1';
                           IF (wbs_sel_i(0) = '1' OR wbs_sel_i(1) = '1') AND (wbs_sel_i(2) = '1' OR wbs_sel_i(3) = '1') THEN
                              mstr_cycle_int   <= '1';         -- there must be two master cycles in order to transmit 32bit in D16 mode
                           ELSE
                              mstr_cycle_int   <= '0';
                           END IF;
                           IF second_word = '0' OR (second_word = '1' AND mstr_cycle_int = '0') THEN      -- first word of two
                              IF (wbs_sel_i(0) = '1' OR wbs_sel_i(1) = '1') THEN
                                 vme_a1 <= '0';         -- only low word will be transmitted
                                 dsan_out_int   <= NOT wbs_sel_i(1);
                                 dsbn_out_int   <= NOT wbs_sel_i(0);
                                 ma_byte_routing <= '1';
                              ELSE
                                 vme_a1 <= '1';         -- only high word will be transmitted
                                 dsan_out_int   <= NOT wbs_sel_i(3);
                                 dsbn_out_int   <= NOT wbs_sel_i(2);
                                 ma_byte_routing <= '0';
                              END IF;
                           ELSE                     -- second word of two
                              dsan_out_int   <= NOT wbs_sel_i(3);
                              dsbn_out_int   <= NOT wbs_sel_i(2);
                              ma_byte_routing <= '0';
                              vme_a1 <= '1';
                           END IF;
                      END IF;
                      
            WHEN "10000" => 
                      IF vme_acc_type(6) = '0' THEN               -- A24_MODE
                         vam_out <= "111011";-- x3b   A24 D16 blt non-privileged
                      ELSE
                         vam_out <= "111111";-- x3f   A24 D16 blt supervisory
                      END IF;
                      iackn_out <= '1';
                      ma_d64 <= '0';
                        lwordn_mstr_int   <= '1';
                        IF (wbs_sel_i(0) = '1' OR wbs_sel_i(1) = '1') AND (wbs_sel_i(2) = '1' OR wbs_sel_i(3) = '1') THEN
                           mstr_cycle_int   <= '1';         -- there must be two master cycles in order to transmit 32bit in D16 mode
                        ELSE
                           mstr_cycle_int   <= '0';
                        END IF;
                        IF second_word = '0' OR (second_word = '1' AND mstr_cycle_int = '0') THEN      -- first word of two
                         IF (wbs_sel_i(0) = '1' OR wbs_sel_i(1) = '1') THEN
                              vme_a1 <= '0';         -- only low word will be transmitted
                              dsan_out_int   <= NOT wbs_sel_i(1);
                              dsbn_out_int   <= NOT wbs_sel_i(0);
                              ma_byte_routing <= '1';
                           ELSE
                              vme_a1 <= '1';         -- only high word will be transmitted
                              dsan_out_int   <= NOT wbs_sel_i(3);
                              dsbn_out_int   <= NOT wbs_sel_i(2);
                              ma_byte_routing <= '0';
                           END IF;
                        ELSE                     -- second word of two
                           dsan_out_int   <= NOT wbs_sel_i(3);
                           dsbn_out_int   <= NOT wbs_sel_i(2);
                           ma_byte_routing <= '0';
                           vme_a1 <= '1';
                        END IF;
                        
            WHEN "10101" =>   --   A32 D32 blt
                      IF vme_acc_type(6) = '0' THEN              
                         vam_out <= "001011";-- x0b   A32 D32 blt non-privileged
                      ELSE
                         vam_out <= "001111";-- x0f   A32 D32 blt supervisory
                      END IF;
                      iackn_out <= '1';
                      IF vme_acc_type(5) = '1' THEN
                         ma_byte_routing <= '0';
                      ELSE
                         ma_byte_routing <= '1';
                      END IF;
                      mstr_cycle_int   <= '0';
                       dsan_out_int <= '0';
                      dsbn_out_int <= '0';
                      vme_a1 <= '0';
                        lwordn_mstr_int   <= '0';
                      ma_d64 <= '0';
                      
            WHEN "10100" =>   
               IF vme_acc_type(6) = '0' THEN               -- A24_MODE
                  vam_out <= "111011";-- x3b   A24 D32 blt non-privileged
               ELSE
                  vam_out <= "111111";-- x3f   A24 D32 blt supervisory
               END IF;
               iackn_out <= '1';
               IF vme_acc_type(5) = '1' THEN
                  ma_byte_routing <= '0';
               ELSE
                  ma_byte_routing <= '1';
               END IF;
               mstr_cycle_int    <= '0';
               dsan_out_int      <= '0';
               dsbn_out_int      <= '0';
               vme_a1            <= '0';
               lwordn_mstr_int   <= '0';
               ma_d64            <= '0';
               
            WHEN "11101" => --   A32 D64 MBLT
               IF vme_acc_type(6) = '0' THEN
                  vam_out <= "001000";-- x08   A32 D64 mblt non-privileged
               ELSE
                  vam_out <= "001100";-- x0c   A32 D32 mblt supervisory
               END IF;
                 lwordn_mstr_int <= '0';
               ma_byte_routing   <= '1';
               mstr_cycle_int    <= '1';   -- D64
               dsan_out_int      <= '0';
               dsbn_out_int      <= '0';
               vme_a1            <= '0';
               iackn_out         <= '1';
               ma_d64            <= '1';
            
            WHEN OTHERS => --   A32 D64 MBLT
               IF vme_acc_type(6) = '0' THEN
                  vam_out <= "001000";-- x08   A32 D64 mblt non-privileged
               ELSE
                  vam_out <= "001100";-- x0c   A32 D32 mblt supervisory
               END IF;
               ma_d64            <= '0';
               iackn_out         <= '1';
               lwordn_mstr_int   <= '0';
               ma_byte_routing   <= '0';
               mstr_cycle_int    <= '0';
               dsan_out_int      <= '1';
               dsbn_out_int      <= '1';
               vme_a1            <= '0';
         END CASE;
      END IF;
   END PROCESS vam_proc;
   
END vme_au_arch;
