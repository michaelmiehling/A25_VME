--------------------------------------------------------------------------------
-- Title         : Data Unit of VME-Bridge
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : vme_du.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 13/01/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- This unit handles the data path.
--------------------------------------------------------------------------------
-- Hierarchy:
--
-- vme_ctrl
--    vme_du
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
-- $Revision: 1.8 $
--
-- $Log: vme_du.vhd,v $
-- Revision 1.8  2015/09/16 09:20:05  mwawrik
-- Added generic USE_LONGADD
--
-- Revision 1.7  2014/04/17 07:35:25  MMiehling
-- added generic LONGADD_SIZE
--
-- Revision 1.6  2013/09/12 08:45:23  mmiehling
-- support of address modifier supervisory, non-privileged data/program for A16, A24 and A32
--
-- Revision 1.5  2012/11/15 09:43:53  MMiehling
-- connected each interrupt source to interface in order to support edge triggered msi
--
-- Revision 1.4  2012/11/12 08:13:10  MMiehling
-- bugfix locmon: improved handling of adr(4:3) for stable results
--
-- Revision 1.3  2012/09/25 11:21:43  MMiehling
-- added wbm_err signal for error signalling from pcie to vme
--
-- Revision 1.2  2012/08/27 12:57:13  MMiehling
-- general rework of d64 slave access handling
-- rework of reset handling
--
-- Revision 1.1  2012/03/29 10:14:39  MMiehling
-- Initial Revision
--
-- Revision 1.11  2006/06/02 15:48:59  MMiehling
-- changed default of arbitration => now not fair is default
--
-- Revision 1.10  2005/02/04 13:44:17  mmiehling
-- added combinations of addr3+4
--
-- Revision 1.9  2004/11/02 11:29:58  mmiehling
-- improved timing and area
-- moved dma_reg to vme_du
--
-- Revision 1.8  2004/07/27 17:15:42  mmiehling
-- changed pci-core to 16z014
-- changed wishbone bus to wb_bus.vhd
-- added clk_trans_wb2wb.vhd
-- improved dma
--
-- Revision 1.7  2003/12/17 15:51:48  MMiehling
-- byte swapping in "not swapped" mode was wrong
--
-- Revision 1.6  2003/12/01 10:03:55  MMiehling
-- added d64
--
-- Revision 1.5  2003/07/14 08:38:10  MMiehling
-- changed mail_irq; added lwordn
--
-- Revision 1.4  2003/06/24 13:47:10  MMiehling
-- added rst_aonly; changed vme_data_in_reg sampling (lwordn)
--
-- Revision 1.3  2003/06/13 10:06:38  MMiehling
-- added address bits 3+4 for locmon;  changed locsta register
--
-- Revision 1.2  2003/04/22 11:03:02  MMiehling
-- changed irq and address map for locmon
--
-- Revision 1.1  2003/04/01 13:04:43  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;          
USE ieee.std_logic_arith.ALL;

ENTITY vme_du IS
GENERIC (
   LONGADD_SIZE      : integer range 3 TO 8:=3;
   USE_LONGADD       : boolean := TRUE                          -- If FALSE, bits (7 DOWNTO 5) of SIGNAL longadd will be allocated to vme_adr_out(31 DOWNTO 29)
                                                                -- If TRUE, number of bits allocated to vme_adr_out depends on GENERIC LONGADD_SIZE
   );
PORT (
   clk                     : IN std_logic;                      -- 66 MHz
   rst                     : IN std_logic;                      -- global reset signal (asynch)
   startup_rst             : IN std_logic;                      -- powerup reset
   vme_irq                 : OUT std_logic_vector(7 DOWNTO 0);  -- interrupt request to pci-bus
   berr_irq                : OUT std_logic;                     -- signal berrn interrupt request
   locmon_irq              : OUT std_logic_vector(1 DOWNTO 0);  -- interrupt request location monitor to pci-bus
   mailbox_irq             : OUT std_logic_vector(1 DOWNTO 0);  -- interrupt request mailbox to pci-bus

   -- dma
   dma_sta                 : OUT std_logic_vector(9 DOWNTO 0);
   clr_dma_en              : IN std_logic;
   set_dma_err             : IN std_logic;
   dma_act_bd              : IN std_logic_vector(7 DOWNTO 4);

   -- arbiter
   sel_reg_data_in         : IN std_logic;                     -- mux select signal for wbb/vme register access
   sel_loc_data_out        : IN std_logic_vector(1 DOWNTO 0);   -- mux select signal for 0=reg, 1=vme data_out
   en_wbm_dat_o            : IN std_logic;                     -- enable for wbm_dat_o
   
   -- requester
   brl                     : OUT std_logic_vector(1 DOWNTO 0);     -- bus request leve

   -- vme_au
   int_adr                 : IN std_logic_vector(18 DOWNTO 0);      -- internal adress for reg
   int_be                  : IN std_logic_vector(3 DOWNTO 0);      -- internal byte enables
   vme_adr_out             : IN std_logic_vector(31 DOWNTO 0);      -- vme adress lines
   byte_routing            : IN std_logic;                     -- mux select for byte routing
   vme_adr_in              : OUT std_logic_vector(31 DOWNTO 0);   -- vme adress input lines
   my_iack                 : IN std_logic;
   d64                     : IN std_logic;                        -- indicates d64 mblt

   -- sys_arbiter
   lwordn                  : IN std_logic;                        -- stored for vme slave access
   
   -- ctrl_mux
   write_flag              : IN std_logic;                     -- write flag for register write access
   
   -- master
   oe_vd                   : IN std_logic;                     -- output enable for vme data
   oe_va                   : IN std_logic;                     -- output enable for vme adress
   second_word             : IN std_logic;                     -- indicates data phase of d64
   
   -- slave
   sel_vme_data_out        : IN std_logic_vector(1 DOWNTO 0);  -- mux select for vme data out
   en_vme_data_out_reg     : IN std_logic;                     -- register enable for vme data out
   en_vme_data_out_reg_high: IN std_logic;                     -- register enable for vme data out high long
   en_vme_data_in_reg      : IN std_logic;                     -- register enable for vme data in
   en_vme_data_in_reg_high : IN std_logic;                     -- register enable for vme data in high long
   clr_intreq              : IN std_logic;                     -- clear interrupt request (intr(3) <= '0'
   
   -- wbb_slave
   wbs_dat_o               : OUT std_logic_vector(31 DOWNTO 0);
   wbs_dat_i               : IN std_logic_vector(31 DOWNTO 0);
   wbs_tga_i               : IN std_logic_vector(8 DOWNTO 0);   -- indicates dma(1) or normal(0) access
   swap                    : IN std_logic;                     -- swapps bytes when enabled

   -- wbb_master
   wbm_ack_i               : IN std_logic;
   wbm_err_i               : IN std_logic;
   wbm_dat_o               : OUT std_logic_vector(31 DOWNTO 0);
   wbm_dat_i               : IN std_logic_vector(31 DOWNTO 0);
   sel_wbm_dat_o           : IN std_logic;                        -- selects between low and high d32

   -- register out
   longadd                 : OUT std_logic_vector(7 DOWNTO 0);     -- upper 3 address bits for A32 mode or dependent on LONGADD_SIZE
   mstr_reg                : OUT std_logic_vector(13 DOWNTO 0);      -- master register (aonly, postwr, iberr, berr, req, rmw, A16_MODE, A24_MODE, A32_MODE)
   sysc_reg                : OUT std_logic_vector(2 DOWNTO 0);      -- system control register (ato, sysr, sysc)
   slv16_reg               : OUT std_logic_vector(4 DOWNTO 0);      -- slave A16 base address register
   slv24_reg               : OUT std_logic_vector(15 DOWNTO 0);   -- slave A24 base address register
   slv32_reg               : OUT std_logic_vector(23 DOWNTO 0);   -- slave A32 base address register
   slv24_pci_q             : OUT std_logic_vector(15 DOWNTO 0);   -- slave A24 base address register for PCI
   slv32_pci_q             : OUT std_logic_vector(23 DOWNTO 0);   -- slave A32 base address register for PCI
   intr_reg                : OUT std_logic_vector(3 DOWNTO 0);      -- interrupt request register
   pci_offset_q            : OUT std_logic_vector(31 DOWNTO 2);   -- pci offset address for vme to pci access
   
   -- register bits
   set_berr                : IN std_logic;                     -- if bit is set => berr bit will be set
   rst_rmw                 : IN std_logic;                     -- if bit is set => rmw bit will be cleared
   set_sysc                : IN std_logic;                     -- if bit is set => sysc bit will be set
   set_ato                 : IN std_logic;                     -- if bit is set => ato bit will be set
   clr_sysr                : IN std_logic;                     -- if bit is set => sysr bit will be cleared
   mail_irq                : IN std_logic_vector(7 DOWNTO 0);   -- mailbox interrupt flags
   loc_am_0                : OUT std_logic_vector(1 DOWNTO 0);   -- loc-monitor #0 - adress modus "00"-A32, "10"-A16, "11"-A24
   loc_am_1                : OUT std_logic_vector(1 DOWNTO 0);   -- loc-monitor #1 - adress modus "00"-A32, "10"-A16, "11"-A24
   loc_irq_0               : IN std_logic;                     -- loc-monitor #0 - irq
   loc_irq_1               : IN std_logic;                     -- loc-monitor #1 - irq
   loc_rw_0                : OUT std_logic_vector(1 DOWNTO 0);   -- [0]: read; [1]: write
   loc_rw_1                : OUT std_logic_vector(1 DOWNTO 0);   -- [0]: read; [1]: write
   loc_adr_0               : OUT std_logic_vector(31 DOWNTO 0);-- location monitor #0 adress
   loc_adr_1               : OUT std_logic_vector(31 DOWNTO 0);-- location monitor #1 adress
   loc_sel                 : IN std_logic_vector(1 DOWNTO 0);   -- these bits are loaded with combinations of address bits [4:3] if locmon hit address         
   rst_aonly               : IN std_logic;                     -- resets aonly bit
   clr_locmon              : OUT std_logic_vector(1 DOWNTO 0);   -- clear address combination bits when clear status bit
   
   -- irq pins
   irq_i_n                 : IN std_logic_vector(7 DOWNTO 1);
   irq_o_n                 : OUT std_logic_vector(7 DOWNTO 1);
   acfailn                 : IN  std_logic;       -- ACFAIL# input from Power Supply
   
   --vme
   ga                      : IN std_logic_vector(4 DOWNTO 0);        -- geographical addresses
   gap                     : IN std_logic;                           -- geographical addresses parity
   vd                      : INOUT std_logic_vector(31 DOWNTO 0);
   va                      : INOUT std_logic_vector(31 DOWNTO 0) 
   );
END vme_du;

ARCHITECTURE vme_du_arch OF vme_du IS 
   CONSTANT null_vec             : std_logic_vector(23 DOWNTO 0):="000000000000000000000000";

   SIGNAL reg_data_in            : std_logic_vector(31 DOWNTO 0);
   SIGNAL reg_data_out           : std_logic_vector(31 DOWNTO 0);
   SIGNAL vme_data_in_reg_mux    : std_logic_vector(31 DOWNTO 0);
   SIGNAL vme_data_in_reg        : std_logic_vector(63 DOWNTO 0);
   SIGNAL vme_data_out_reg       : std_logic_vector(63 DOWNTO 0);
   SIGNAL vd_in                  : std_logic_vector(31 DOWNTO 0);
   SIGNAL vd_in_reg              : std_logic_vector(31 DOWNTO 0);
   SIGNAL vd_in_reg_int          : std_logic_vector(31 DOWNTO 0);
   SIGNAL vd_out_reg             : std_logic_vector(31 DOWNTO 0);
   SIGNAL va_in                  : std_logic_vector(31 DOWNTO 0);
   SIGNAL va_in_reg              : std_logic_vector(31 DOWNTO 0);
   SIGNAL va_out_reg             : std_logic_vector(31 DOWNTO 0);
   SIGNAL wbs_dat_o_reg          : std_logic_vector(31 DOWNTO 0);
   SIGNAL mstr_int               : std_logic_vector(13 DOWNTO 0);
   SIGNAL longadd_int            : std_logic_vector(7 DOWNTO 0);
   SIGNAL intr_int               : std_logic_vector(3 DOWNTO 0);
   SIGNAL intid_int              : std_logic_vector(7 DOWNTO 0);
   SIGNAL istat                  : std_logic_vector(7 DOWNTO 0);
   SIGNAL imask                  : std_logic_vector(7 DOWNTO 0);
   SIGNAL sysc_reg_int           : std_logic_vector(2 DOWNTO 0);
   SIGNAL mail_irqe              : std_logic_vector(7 DOWNTO 0);
   SIGNAL mail_irq_reg           : std_logic_vector(7 DOWNTO 0);
   SIGNAL locsta_0               : std_logic_vector(5 DOWNTO 0);
   SIGNAL locsta_1               : std_logic_vector(5 DOWNTO 0);
   SIGNAL loc_adr_0_int          : std_logic_vector(31 DOWNTO 0);
   SIGNAL loc_adr_1_int          : std_logic_vector(31 DOWNTO 0);
   SIGNAL slv16_reg_int          : std_logic_vector(4 DOWNTO 0);
   SIGNAL slv24_reg_int          : std_logic_vector(15 DOWNTO 0);
   SIGNAL slv32_reg_int          : std_logic_vector(23 DOWNTO 0);
   SIGNAL slv24_pci_q_int        : std_logic_vector(15 DOWNTO 0);
   SIGNAL slv32_pci_q_int        : std_logic_vector(23 DOWNTO 0);
   SIGNAL pci_offset_int         : std_logic_vector(31 DOWNTO 12);
   SIGNAL acfailn_regd           : std_logic;
   SIGNAL irqregd                : std_logic_vector(7 DOWNTO 1);
   SIGNAL acfst                  : std_logic;
   SIGNAL wbm_dat_i_reg          : std_logic_vector(31 DOWNTO 0);
   SIGNAL dma_sta_int            : std_logic_vector(9 DOWNTO 0);
   SIGNAL test                   : std_logic_vector(20 DOWNTO 0):="000000000000000000000";
   SIGNAL swap_byte_routing      : std_logic_vector(1 DOWNTO 0);
   SIGNAL vad_sel                : std_logic_vector(2 DOWNTO 0);
   SIGNAL loc_irq_0_q            : std_logic;                     -- loc-monitor #0 - irq
   SIGNAL loc_irq_1_q            : std_logic;                     -- loc-monitor #1 - irq
   SIGNAL loc_sel_0_int          : std_logic_vector(1 DOWNTO 0);   
   SIGNAL loc_sel_1_int          : std_logic_vector(1 DOWNTO 0);   
   SIGNAL set_dma_err_q          : std_logic;
   SIGNAL ga_q                   : std_logic_vector(5 DOWNTO 0);        -- geographical addresses and parity
   SIGNAL slot_nr                : std_logic_vector(4 DOWNTO 0);        -- slot number
   SIGNAL brl_int                : std_logic_vector(1 DOWNTO 0);        -- bus request level
  
BEGIN
   vme_adr_in <= va_in_reg;
   longadd <= longadd_int WHEN USE_LONGADD ELSE longadd_int(2 DOWNTO 0)&"00000";
   pci_offset_q <= pci_offset_int & "0000000000";
   vme_irq <= istat;
   
vd_proc : PROCESS(vd_out_reg, vd, oe_vd)   
  BEGIN
     IF oe_vd = '1' THEN
        vd <= vd_out_reg;
        vd_in <= vd;
     ELSE
        vd <= (OTHERS => 'Z');
        vd_in <= vd;
     END IF;
  END PROCESS vd_proc;

va_proc : PROCESS(va_out_reg, va, oe_va)   
  BEGIN
     IF oe_va = '1' THEN
        va <= va_out_reg;
        va_in <= va;
     ELSE
        va <= (OTHERS => 'Z');
        va_in <= va;
     END IF;
  END PROCESS va_proc;

   -- swap = 1, byte_routing = 1      => 3210
   -- swap = 1, byte_routing = 0      => 1032
   -- byte_routing = 1                => 2301
   -- byte_routing = 0                => 0123

   swap_byte_routing <= swap & byte_routing;
   
PROCESS (vd_in_reg_int, swap_byte_routing)
   BEGIN
      CASE swap_byte_routing IS
         WHEN "01" => vme_data_in_reg_mux <= vd_in_reg_int(31 DOWNTO 0);
         WHEN "00" => vme_data_in_reg_mux <= vd_in_reg_int(15 DOWNTO 0) & vd_in_reg_int(31 DOWNTO 16);
         WHEN "11" => vme_data_in_reg_mux <= vd_in_reg_int(23 DOWNTO 16) & vd_in_reg_int(31 DOWNTO 24) & vd_in_reg_int(7 DOWNTO 0) & vd_in_reg_int(15 DOWNTO 8);
         WHEN "10" => vme_data_in_reg_mux <= vd_in_reg_int(7 DOWNTO 0) & vd_in_reg_int(15 DOWNTO 8) & vd_in_reg_int(23 DOWNTO 16) & vd_in_reg_int(31 DOWNTO 24);
         WHEN OTHERS => vme_data_in_reg_mux <= vd_in_reg_int(7 DOWNTO 0) & vd_in_reg_int(15 DOWNTO 8) & vd_in_reg_int(23 DOWNTO 16) & vd_in_reg_int(31 DOWNTO 24);
      END CASE;
   END PROCESS;                     
                     
   reg_data_in <= wbs_dat_i WHEN sel_reg_data_in = '1' ELSE vme_data_in_reg(31 DOWNTO 0);
   
   wbs_dat_o <= wbs_dat_o_reg;

   vd_in_reg_int <= va_in_reg WHEN d64 = '1' AND en_vme_data_in_reg_high = '1' ELSE vd_in_reg;
   
reg : PROCESS(clk, rst)
BEGIN
   IF rst = '1' THEN
      vd_in_reg <= (OTHERS => '0');
      vd_out_reg <= (OTHERS => '0');
      vme_data_in_reg <= (OTHERS => '0');
      vme_data_out_reg <= (OTHERS => '0');
      va_out_reg <= (OTHERS => '0');
      va_in_reg <= (OTHERS => '0');
      wbs_dat_o_reg <= (OTHERS => '0');
      wbm_dat_o <= (OTHERS => '0');
      wbm_dat_i_reg <= (OTHERS => '0');
      ga_q  <= (OTHERS => '0');
      slot_nr <= (OTHERS => '0');
   ELSIF clk'EVENT and clk = '1' THEN
      -- synchronization registers
      ga_q  <= gap & ga;
      CASE ga_q IS
         WHEN "111110" => slot_nr <= conv_std_logic_vector(1 ,5);
         WHEN "111101" => slot_nr <= conv_std_logic_vector(2 ,5);
         WHEN "011100" => slot_nr <= conv_std_logic_vector(3 ,5);
         WHEN "111011" => slot_nr <= conv_std_logic_vector(4 ,5);
         WHEN "011010" => slot_nr <= conv_std_logic_vector(5 ,5);
         WHEN "011001" => slot_nr <= conv_std_logic_vector(6 ,5);
         WHEN "111000" => slot_nr <= conv_std_logic_vector(7 ,5);
         WHEN "110111" => slot_nr <= conv_std_logic_vector(8 ,5);
         WHEN "010110" => slot_nr <= conv_std_logic_vector(9 ,5);
         WHEN "010101" => slot_nr <= conv_std_logic_vector(10,5);
         WHEN "110100" => slot_nr <= conv_std_logic_vector(11,5);
         WHEN "010011" => slot_nr <= conv_std_logic_vector(12,5);
         WHEN "110010" => slot_nr <= conv_std_logic_vector(13,5);
         WHEN "110001" => slot_nr <= conv_std_logic_vector(14,5);
         WHEN "010000" => slot_nr <= conv_std_logic_vector(15,5);
         WHEN "101111" => slot_nr <= conv_std_logic_vector(16,5);
         WHEN "001110" => slot_nr <= conv_std_logic_vector(17,5);
         WHEN "001101" => slot_nr <= conv_std_logic_vector(18,5);
         WHEN "101100" => slot_nr <= conv_std_logic_vector(19,5);
         WHEN "001011" => slot_nr <= conv_std_logic_vector(20,5);
         WHEN "101010" => slot_nr <= conv_std_logic_vector(21,5);
         WHEN OTHERS => slot_nr <= conv_std_logic_vector(30,5);   -- amnesia address
      END CASE;
      
      IF wbm_ack_i = '1' THEN
        wbm_dat_i_reg <= wbm_dat_i;
      ELSIF wbm_err_i = '1' THEN
        wbm_dat_i_reg <= x"eeee_eeee"; -- should indicate 'error'
      END IF;
      
      IF en_wbm_dat_o = '1' AND sel_wbm_dat_o = '0' THEN         -- low long
        wbm_dat_o <= vme_data_in_reg(31 DOWNTO 0);
      ELSIF en_wbm_dat_o = '1' AND sel_wbm_dat_o = '1' THEN      -- high long
        wbm_dat_o <= vme_data_in_reg(63 DOWNTO 32);
      END IF;
      
      vd_in_reg <= vd_in;
      
      IF swap = '1' AND d64 = '1' THEN
         -- swapping for d64: high and low 4 byte are swapped
         IF en_vme_data_in_reg_high = '1' THEN
            vme_data_in_reg(31 DOWNTO 0) <= va_in_reg(7 DOWNTO 0) & va_in_reg(15 DOWNTO 8) & va_in_reg(23 DOWNTO 16) & va_in_reg(31 DOWNTO 24);    
         END IF;
         IF en_vme_data_in_reg = '1' THEN
            vme_data_in_reg(63 DOWNTO 32) <= vd_in_reg(7 DOWNTO 0) & vd_in_reg(15 DOWNTO 8) & vd_in_reg(23 DOWNTO 16) & vd_in_reg(31 DOWNTO 24);  
         END IF;
      ELSE
         IF en_vme_data_in_reg = '1' AND (lwordn = '0' OR (lwordn = '1' AND byte_routing = '0')) THEN
            vme_data_in_reg(31 DOWNTO 16) <= vme_data_in_reg_mux(31 DOWNTO 16);   
         END IF;
         IF en_vme_data_in_reg = '1' AND (lwordn = '0' OR (lwordn = '1' AND byte_routing = '1')) THEN
            vme_data_in_reg(15 DOWNTO 0) <= vme_data_in_reg_mux(15 DOWNTO 0);   
         END IF;
         IF en_vme_data_in_reg_high = '1' THEN
            vme_data_in_reg(63 DOWNTO 32) <= vme_data_in_reg_mux(31 DOWNTO 0);
         END IF;
      END IF;        
      
      -- DATA output
      IF swap = '1' THEN
         IF d64 = '1' THEN                                 -- data phase for d64 mblt 7654
            vd_out_reg <=  vme_data_out_reg(39 DOWNTO 32) & vme_data_out_reg(47 DOWNTO 40) & vme_data_out_reg(55 DOWNTO 48) & vme_data_out_reg(63 DOWNTO 56);
         ELSIF byte_routing = '1' THEN                                           -- data phase with byte routing 0123
            vd_out_reg <= vme_data_out_reg(23 DOWNTO 16) & vme_data_out_reg(31 DOWNTO 24) & vme_data_out_reg(7 DOWNTO 0) & vme_data_out_reg(15 DOWNTO 8);
         ELSE                                                                    -- data phase with byte routing 2301
            vd_out_reg <= vme_data_out_reg(7 DOWNTO 0) & vme_data_out_reg(15 DOWNTO 8) & vme_data_out_reg(23 DOWNTO 16) & vme_data_out_reg(31 DOWNTO 24);
         END IF;
      ELSE
         IF byte_routing = '1' THEN                                 
            vd_out_reg <= vme_data_out_reg(31 DOWNTO 0);-- data phase with byte routing 3210
         ELSE                                                            
            vd_out_reg <= vme_data_out_reg(15 DOWNTO 0) & vme_data_out_reg(31 DOWNTO 16);-- data phase with byte routing 1032
         END IF;
      END IF;
      
      -- ADDRESS output
      IF swap = '1' THEN
         IF second_word = '1' AND d64 = '1' THEN                           -- master d64 data phases
            va_out_reg <= vme_data_out_reg(7 DOWNTO 0) & vme_data_out_reg(15 DOWNTO 8) & vme_data_out_reg(23 DOWNTO 16) & vme_data_out_reg(31 DOWNTO 24); 
         ELSE                                                              -- master address phase
            va_out_reg <= vme_adr_out;
         END IF;
      ELSE
         IF second_word = '1' AND d64 = '1' THEN                           -- master d64 data phases    
            va_out_reg <= vme_data_out_reg(63 DOWNTO 32);
         ELSE                                                              -- master address phase  
            va_out_reg <= vme_adr_out;
         END IF;
      END IF;
      
     va_in_reg <= va_in;
      
      IF en_vme_data_out_reg = '1' THEN
         IF my_iack = '1' THEN                                                                  -- vme slave iack read access
            vme_data_out_reg(31 DOWNTO 0) <= intid_int & intid_int & intid_int & intid_int;
         ELSIF sel_vme_data_out = "10" THEN                                                     -- vme slave read access from registers
            vme_data_out_reg(31 DOWNTO 0) <= reg_data_out;   
         ELSIF sel_vme_data_out = "01" THEN                                                     -- vme master write access
            vme_data_out_reg(31 DOWNTO 0) <= wbs_dat_i;
         ELSE                                                                                   -- vme slave read access
            vme_data_out_reg(31 DOWNTO 0) <= wbm_dat_i_reg;
         END IF;
      END IF;
      
      IF en_vme_data_out_reg_high = '1' THEN
         IF sel_vme_data_out = "01" THEN 
            vme_data_out_reg(63 DOWNTO 32) <= wbs_dat_i;                                        -- vme master 64-bit write access
         ELSE                                           
            vme_data_out_reg(63 DOWNTO 32) <= wbm_dat_i_reg;                                        -- vme slave 64-bit read access
         END IF;
      END IF;
           
      IF sel_loc_data_out(0) = '0' THEN
         wbs_dat_o_reg <= reg_data_out;
      ELSIF sel_loc_data_out(1) = '0' THEN
         wbs_dat_o_reg <= vme_data_in_reg(31 DOWNTO 0);
      ELSE
         wbs_dat_o_reg <= vme_data_in_reg(63 DOWNTO 32);
      END IF;
      
   END IF;
END PROCESS reg;   

  
----------------------------------------------------------------------------------------------
--                               Registers
----------------------------------------------------------------------------------------------

reg_out : PROCESS(clk, rst)
BEGIN
   IF rst = '1' THEN
      reg_data_out <= (OTHERS => '0');
   ELSIF clk'EVENT AND clk = '1' THEN
      CASE int_adr(6 DOWNTO 2) IS
         WHEN "00000" => reg_data_out <= x"000000" & "0000" & intr_int;                                                 -- 0x000
         WHEN "00001" => reg_data_out <= x"000000" & intid_int;                                                         -- 0x004
         WHEN "00010" => reg_data_out <= x"000000" & istat;                                                             -- 0x008
         WHEN "00011" => reg_data_out <= x"000000" & imask;                                                             -- 0x00c
         WHEN "00100" => reg_data_out <= x"0000" & "00" & mstr_int;                                                     -- 0x010
         WHEN "00101" => reg_data_out <= x"0000" & slv24_reg_int(15 DOWNTO 8) & "000" & slv24_reg_int(4 DOWNTO 0);      -- 0x014
         WHEN "00110" => reg_data_out <= x"000000" & "00000" & sysc_reg_int;                                            -- 0x018
         WHEN "00111" => reg_data_out <= x"000000" & longadd_int;                                                       -- 0x01c
         WHEN "01000" => reg_data_out <= x"000000" & mail_irqe;                                                         -- 0x020
         WHEN "01001" => reg_data_out <= x"000000" & mail_irq_reg;                                                      -- 0x024
         WHEN "01010" => reg_data_out <= pci_offset_int(31 DOWNTO 12) & x"000";                                         -- 0x028
         WHEN "01011" => reg_data_out <= x"000000" & dma_sta_int(7 DOWNTO 0);                                           -- 0x02c
         WHEN "01100" => reg_data_out <= x"000000" & "000" & slv16_reg_int;                                             -- 0x030
         WHEN "01101" => reg_data_out <= x"00" & slv32_reg_int(23 DOWNTO 8) & "000" & slv32_reg_int(4 DOWNTO 0);        -- 0x034
         WHEN "01110" => reg_data_out <= x"000000" & loc_sel_0_int & locsta_0;                                          -- 0x038
         WHEN "01111" => reg_data_out <= x"000000" & loc_sel_1_int & locsta_1;                                          -- 0x03c
         WHEN "10000" => reg_data_out <= loc_adr_0_int(31 DOWNTO 0);                                                    -- 0x040
         WHEN "10001" => reg_data_out <= loc_adr_1_int(31 DOWNTO 0);                                                    -- 0x044
         WHEN "10010" => reg_data_out <= x"0000" & slv24_pci_q_int(15 DOWNTO 8) & "000" & slv24_pci_q_int(4 DOWNTO 0);  -- 0x048
         WHEN "10011" => reg_data_out <= x"00" & slv32_pci_q_int(23 DOWNTO 8) & "000" & slv32_pci_q_int(4 DOWNTO 0);    -- 0x04c
         WHEN "10100" => reg_data_out <= x"0000" & "000" & slot_nr & "00" & ga_q;                                       -- 0x050
         WHEN "10101" => reg_data_out <= x"0000_000" & "00" & brl_int;                                                  -- 0x054 
         WHEN OTHERS => reg_data_out <= (OTHERS => '0');                     
      END CASE;
   END IF;
END PROCESS reg_out;
     
  
-------------------------------------------------------------------------------
-- dma_sta_int register 0x2c
sta :PROCESS(clk, rst)
BEGIN
   IF rst = '1' THEN
      dma_sta_int(3 DOWNTO 0) <= (OTHERS => '0');
      dma_sta_int(9 DOWNTO 8) <= (OTHERS => '0');
      set_dma_err_q <= '0';
   ELSIF clk'EVENT AND clk = '1' THEN
      set_dma_err_q <= set_dma_err;
      IF clr_dma_en = '1' THEN
         dma_sta_int(0) <= '0';
         dma_sta_int(8) <= '0';
      ELSIF write_flag = '1' AND int_be(0) = '1' AND int_adr(6 DOWNTO 2) = "01011" THEN 
         dma_sta_int(0) <= reg_data_in(0);
         dma_sta_int(8) <= reg_data_in(0);
      ELSE
         dma_sta_int(8) <= '0';
      END IF;
      
      IF write_flag = '1' AND int_be(0) = '1' AND int_adr(6 DOWNTO 2) = "01011" THEN 
         dma_sta_int(1) <= reg_data_in(1);
      END IF;
      
      IF clr_dma_en = '1' AND dma_sta_int(1) = '1' THEN
         dma_sta_int(2) <= '1';
      ELSIF write_flag = '1' AND int_be(0) = '1' AND int_adr(6 DOWNTO 2) = "01011" AND reg_data_in(2) = '1' THEN 
         dma_sta_int(2) <= '0';
      END IF;
      
      IF set_dma_err = '1' AND set_dma_err_q = '0' THEN
         dma_sta_int(3) <= '1';
         dma_sta_int(9) <= '0';
      ELSIF write_flag = '1' AND int_be(0) = '1' AND int_adr(6 DOWNTO 2) = "01011" AND reg_data_in(3) = '1' THEN 
         dma_sta_int(3) <= '0';
         dma_sta_int(9) <= '1';
      ELSE
         dma_sta_int(9) <= '0';
      END IF;
   END IF;
END PROCESS sta;   
  
   dma_sta_int(7 DOWNTO 4) <= dma_act_bd;
   dma_sta <= dma_sta_int;

-------------------------------------------------------------------------------

int_id : PROCESS(clk, rst)
BEGIN
   IF rst = '1' THEN
      intid_int <= (OTHERS => '0');
   ELSIF clk'EVENT AND clk = '1' THEN
      IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00001" AND int_be(0) = '1' THEN
         intid_int(7 DOWNTO 0) <= reg_data_in(7 DOWNTO 0);
      END IF;
   END IF;
END PROCESS int_id;   
  
  
-------------------------------------------------------------------------------
-- PCI-offset register
-------------------------------------------------------------------------------
pci_o : PROCESS(clk, rst)
BEGIN  
   IF rst = '1' THEN
      pci_offset_int <= (OTHERS => '0');
   ELSIF clk'EVENT AND clk = '1' THEN
      IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "01010" AND int_be(1) = '1' THEN
         pci_offset_int(15 DOWNTO 12) <= reg_data_in(15 DOWNTO 12);
      END IF;
      IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "01010" AND int_be(2) = '1' THEN
         pci_offset_int(23 DOWNTO 16) <= reg_data_in(23 DOWNTO 16);
      END IF;
      IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "01010" AND int_be(3) = '1' THEN
         pci_offset_int(31 DOWNTO 24) <= reg_data_in(31 DOWNTO 24);
      END IF;
   END IF;
END PROCESS pci_o;
  
-------------------------------------------------------------------------------
-- Slave A24 Base address for PCI
-------------------------------------------------------------------------------
sl24_pci : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
        slv24_pci_q_int <= (OTHERS => '0');
     ELSIF clk'EVENT AND clk = '1' THEN
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "10010" AND int_be(0) = '1' THEN
           slv24_pci_q_int(4 DOWNTO 0) <= reg_data_in(4 DOWNTO 0);
        END IF;
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "10010" AND int_be(1) = '1' THEN
           slv24_pci_q_int(15 DOWNTO 8) <= reg_data_in(15 DOWNTO 8);
        END IF;
        slv24_pci_q_int(7 DOWNTO 5) <= (OTHERS => '0');
   END IF;
  END PROCESS sl24_pci;
  
  slv24_pci_q <= slv24_pci_q_int(15 DOWNTO 8) & "000" & slv24_pci_q_int(4 DOWNTO 0) ;
    
-------------------------------------------------------------------------------
-- Slave A32 Base address for PCI
-------------------------------------------------------------------------------
sl32_pci : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
        slv32_pci_q_int <= (OTHERS => '0');
     ELSIF clk'EVENT AND clk = '1' THEN
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "10011" AND int_be(0) = '1' THEN
           slv32_pci_q_int(4 DOWNTO 0) <= reg_data_in(4 DOWNTO 0);
        END IF;
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "10011" AND int_be(1) = '1' THEN
           slv32_pci_q_int(15 DOWNTO 8) <= reg_data_in(15 DOWNTO 8);
        END IF;
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "10011" AND int_be(2) = '1' THEN
           slv32_pci_q_int(23 DOWNTO 16) <= reg_data_in(23 DOWNTO 16);
        END IF;
        slv32_pci_q_int(7 DOWNTO 5) <= (OTHERS => '0');
   END IF;
  END PROCESS sl32_pci;

  slv32_pci_q <= slv32_pci_q_int(23 DOWNTO 8) & "000" & slv32_pci_q_int(4 DOWNTO 0);
  
-------------------------------------------------------------------------------
-- Here is the Interrupt Request Register:
-- Consists of (INTEN, IL2-0)
-------------------------------------------------------------------------------
int_r : PROCESS(clk, rst)
BEGIN
   IF rst = '1' THEN
      intr_int <= (OTHERS => '0');
      irq_o_n <= "1111111";
   ELSIF clk'EVENT AND clk = '1' THEN
      IF clr_intreq = '1' THEN
        intr_int(3) <= '0';
        intr_int(2 DOWNTO 0) <= intr_int(2 DOWNTO 0);
      ELSIF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00000" AND int_be(0) = '1' THEN
         intr_int(3 DOWNTO 0) <= reg_data_in(3 DOWNTO 0);
      END IF;

      IF intr_int(3) = '1' THEN
         CASE intr_int(2 DOWNTO 0) IS
            WHEN "001" => irq_o_n <= "1111110";
            WHEN "010" => irq_o_n <= "1111101";
            WHEN "011" => irq_o_n <= "1111011";
            WHEN "100" => irq_o_n <= "1110111";
            WHEN "101" => irq_o_n <= "1101111";
            WHEN "110" => irq_o_n <= "1011111";
            WHEN "111" => irq_o_n <= "0111111";
            WHEN OTHERS => irq_o_n <= "1111111";
         END CASE;
      ELSE
         irq_o_n <= "1111111";
      END IF;
   END IF;
END PROCESS int_r;   

   intr_reg <= intr_int;

-------------------------------------------------------------------------------
-- The IMASK Register. '0' means interrupt is masked, '1' means it is enabled.
-------------------------------------------------------------------------------
i_mask : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
        imask <= (OTHERS => '0');
        istat <= (OTHERS => '0');
        berr_irq <= '0';
     ELSIF clk'EVENT AND clk = '1' THEN
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00011" AND int_be(0) = '1' THEN
           imask <= reg_data_in(7 DOWNTO 0);
        END IF;

        istat <= (irqregd & acfst) AND imask;
        
        IF mstr_int(3) = '1' AND mstr_int(2) = '1' THEN
            berr_irq <= '1';
        ELSE
            berr_irq <= '0';   
        END IF;
      
     END IF;
  END PROCESS i_mask;   


-------------------------------------------------------------------------------
-- Here is the Interrupt Status Register:
-- Consists of (IRQ7-1, ACFST )
-------------------------------------------------------------------------------
  regirq : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      irqregd <= (OTHERS => '0');
      acfailn_regd <= '1';
      acfst <= '0';
    ELSIF clk'event AND clk = '1' THEN
      irqregd <= NOT irq_i_n;
      acfailn_regd <= acfailn;

      IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00010" AND int_be(0) = '1' THEN
        acfst   <= '0';
      ELSIF (acfailn_regd = '0') THEN
        acfst <= '1';
      END IF;
    END IF;
  END PROCESS regirq;

  
-------------------------------------------------------------------------------
-- Here is the Master Register:
-- Consists of (AONLY-bit, POSTWR-bit, IBERR-bit, BERR-bit, REQ-bit, RMW-bit
-- A16_MODE, A24_MODE, A32_MODE)
-------------------------------------------------------------------------------
   mstr_int(7) <= '0'; -- unused
   
  -- RMW-bit:
rmwena : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      mstr_int(0)   <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00100" AND int_be(0) = '1' THEN
         mstr_int(0) <= reg_data_in(0);
      ELSIF rst_rmw = '1' THEN
        mstr_int(0)   <= '0';
      END IF;
    END IF;
  END PROCESS rmwena;

  -- REQ-bit:
rwdena : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      mstr_int(1)   <= '0';                 -- default is ROR
    ELSIF clk'event AND clk = '1' THEN
      IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00100" AND int_be(0) = '1' THEN
        mstr_int(1) <= reg_data_in(1);
      END IF;
    END IF;
  END PROCESS rwdena;


  -- BERR-bit:
berrena : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      mstr_int(2) <= '0';
    ELSIF (clk'event AND clk = '1') THEN
      IF set_berr = '1' AND wbs_tga_i(7) = '0' THEN   -- set berr-bit only if not dma access!
        mstr_int(2) <= '1';
      ELSIF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00100" AND reg_data_in(2) = '1' AND int_be(0) = '1' THEN
        mstr_int(2)   <= '0';
      END IF;
    END IF;
  END PROCESS berrena;

  -- IBERR-bit:
iberrena : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      mstr_int(3) <= '0';
    ELSIF (clk'event AND clk = '1') THEN
      IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00100" AND int_be(0) = '1' THEN
        mstr_int(3)   <= reg_data_in(3);
      END IF;
    END IF;
  END PROCESS iberrena;   
  
  -- POSTWR-bit:
postwrena : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      mstr_int(4) <= '0';
    ELSIF (clk'event AND clk = '1') THEN
      IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00100" AND int_be(0) = '1' THEN
        mstr_int(4)   <= reg_data_in(4);
      END IF;
    END IF;
  END PROCESS postwrena;   
  
  -- AONLY-bit:
aonlyena : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      mstr_int(5) <= '0';
    ELSIF (clk'event AND clk = '1') THEN
      IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00100" AND int_be(0) = '1' THEN
          mstr_int(5)   <= reg_data_in(5);
      ELSIF rst_aonly = '1' THEN
         mstr_int(5)   <= '0';
      END IF;
    END IF;
  END PROCESS aonlyena;   
  
  -- Fair_requester-bit:
fair : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      mstr_int(6) <= '0';  -- default not fair
    ELSIF (clk'event AND clk = '1') THEN
      IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00100" AND int_be(0) = '1' THEN
          mstr_int(6)   <= reg_data_in(6);
      END IF;
    END IF;
  END PROCESS fair;   

  -- A16_MODE-bit:
a16 : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      mstr_int(9 DOWNTO 8) <= "00";  -- default = non-privileged (AM=0x29)
    ELSIF (clk'event AND clk = '1') THEN
      IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00100" AND int_be(1) = '1' THEN
          mstr_int(9 DOWNTO 8)   <= reg_data_in(9 DOWNTO 8);
      END IF;
    END IF;
  END PROCESS a16;   
  
  -- A24_MODE-bit:
a24 : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      mstr_int(11 DOWNTO 10) <= "00";  -- default = non-privileged (AM=0x39)
    ELSIF (clk'event AND clk = '1') THEN
      IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00100" AND int_be(1) = '1' THEN
          mstr_int(11 DOWNTO 10)   <= reg_data_in(11 DOWNTO 10);
      END IF;
    END IF;
  END PROCESS a24;   
  
  -- A32_MODE-bit:
a32 : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      mstr_int(13 DOWNTO 12) <= "00";  -- default = non-privileged (AM=0x09)
    ELSIF (clk'event AND clk = '1') THEN
      IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00100" AND int_be(1) = '1' THEN
          mstr_int(13 DOWNTO 12)   <= reg_data_in(13 DOWNTO 12);
      END IF;
    END IF;
  END PROCESS a32;   
  
   mstr_reg <= mstr_int;
      

-------------------------------------------------------------------------------
-- Here is the System Control Register:
-- Consists of (ATO-bit, SYSR-bit, SYSC-bit)
-------------------------------------------------------------------------------
-- ato-bit
atoena : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      sysc_reg_int(2)   <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00110" AND reg_data_in(2) = '1'  AND int_be(0) = '1' THEN
         sysc_reg_int(2) <= '0';
      ELSIF set_ato = '1' THEN
         sysc_reg_int(2) <= '1';
      END IF;
    END IF;
  END PROCESS atoena;

-- sysr-bit
sysrena : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      sysc_reg_int(1)   <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00110"  AND int_be(0) = '1' THEN
         sysc_reg_int(1) <= reg_data_in(1);
      ELSIF clr_sysr = '1' THEN
         sysc_reg_int(1) <= '0';
      END IF;
    END IF;
  END PROCESS sysrena;

-- sysc-bit
syscena : PROCESS (clk, startup_rst)
  BEGIN
     IF startup_rst = '1' THEN
        sysc_reg_int(0) <= '0';
     ELSIF clk'EVENT AND clk = '1' THEN
      IF set_sysc = '1' THEN
        sysc_reg_int(0)   <= '1';
      ELSIF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00110" AND int_be(0) = '1' THEN
         sysc_reg_int(0) <= reg_data_in(0);
      END IF;
    END IF;
  END PROCESS syscena;

   sysc_reg <= sysc_reg_int;

---------------------------------------------------------------------------
-- slave base address register

slv24_r : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
        slv24_reg_int <= (OTHERS => '0');
     ELSIF clk'EVENT AND clk = '1' THEN
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00101" AND int_be(0) = '1' THEN
           slv24_reg_int(4 DOWNTO 0) <= reg_data_in(4 DOWNTO 0);
        END IF;
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00101" AND int_be(1) = '1' THEN
           slv24_reg_int(15 DOWNTO 8) <= reg_data_in(15 DOWNTO 8);
        END IF;
        slv24_reg_int(7 DOWNTO 5) <= (OTHERS => '0');
     END IF;
  END PROCESS slv24_r;   
  
  slv24_reg <= slv24_reg_int(15 DOWNTO 8) & "000" & slv24_reg_int(4 DOWNTO 0);

slv16_r : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
        slv16_reg_int <= (OTHERS => '0');
     ELSIF clk'EVENT AND clk = '1' THEN
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "01100" AND int_be(0) = '1' THEN
           slv16_reg_int <= reg_data_in(4 DOWNTO 0);
        END IF;
     
     END IF;
  END PROCESS slv16_r;   

  slv16_reg <= slv16_reg_int;

slv32_r : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
        slv32_reg_int <= (OTHERS => '0');
     ELSIF clk'EVENT AND clk = '1' THEN
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "01101" AND int_be(0) = '1' THEN
           slv32_reg_int(4 DOWNTO 0) <= reg_data_in(4 DOWNTO 0);
        END IF;
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "01101" AND int_be(1) = '1' THEN
           slv32_reg_int(15 DOWNTO 8) <= reg_data_in(15 DOWNTO 8);
        END IF;
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "01101" AND int_be(2) = '1' THEN
           slv32_reg_int(23 DOWNTO 16) <= reg_data_in(23 DOWNTO 16);
        END IF;
        slv32_reg_int(7 DOWNTO 5) <= (OTHERS => '0');
     END IF;
  END PROCESS slv32_r;   

  slv32_reg <= slv32_reg_int(23 DOWNTO 8) & "000" & slv32_reg_int(4 DOWNTO 0);



long_add : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
        longadd_int <= (OTHERS => '0');
     ELSIF clk'EVENT AND clk = '1' THEN
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "00111" AND int_be(0) = '1' THEN
           longadd_int <= reg_data_in(7 DOWNTO 0);
        END IF;
     
     END IF;
  END PROCESS long_add;   
  
mail_ie : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
        mail_irqe <= (OTHERS => '0');
     ELSIF clk'EVENT AND clk = '1' THEN
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "01000" AND int_be(0) = '1' THEN
           mail_irqe <= reg_data_in(7 DOWNTO 0);
        END IF;
     
     END IF;
  END PROCESS mail_ie;   
  
mail_ir : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
        mail_irq_reg <= (OTHERS => '0');
     ELSIF clk'EVENT AND clk = '1' THEN
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "01001" AND int_be(0) = '1' THEN
           IF reg_data_in(0) = '1' THEN
              mail_irq_reg(0) <= '0';
           END IF;
           IF reg_data_in(1) = '1' THEN
              mail_irq_reg(1) <= '0';
           END IF;
           IF reg_data_in(2) = '1' THEN
              mail_irq_reg(2) <= '0';
           END IF;
           IF reg_data_in(3) = '1' THEN
              mail_irq_reg(3) <= '0';
           END IF;
           IF reg_data_in(4) = '1' THEN
              mail_irq_reg(4) <= '0';
           END IF;
           IF reg_data_in(5) = '1' THEN
              mail_irq_reg(5) <= '0';
           END IF;
           IF reg_data_in(6) = '1' THEN
              mail_irq_reg(6) <= '0';
           END IF;
           IF reg_data_in(7) = '1' THEN
              mail_irq_reg(7) <= '0';
           END IF;
        ELSE
           IF mail_irqe(0)= '1' AND mail_irq(0)= '1' THEN
              mail_irq_reg(0) <= '1';
           END IF;
           IF mail_irqe(1)= '1' AND mail_irq(1)= '1' THEN
              mail_irq_reg(1) <= '1';
           END IF;
           IF mail_irqe(2)= '1' AND mail_irq(2)= '1' THEN
              mail_irq_reg(2) <= '1';
           END IF;
           IF mail_irqe(3)= '1' AND mail_irq(3)= '1' THEN
              mail_irq_reg(3) <= '1';
           END IF;
           IF mail_irqe(4)= '1' AND mail_irq(4)= '1' THEN
              mail_irq_reg(4) <= '1';
           END IF;
           IF mail_irqe(5)= '1' AND mail_irq(5)= '1' THEN
              mail_irq_reg(5) <= '1';
           END IF;
           IF mail_irqe(6)= '1' AND mail_irq(6)= '1' THEN
              mail_irq_reg(6) <= '1';
           END IF;
           IF mail_irqe(7)= '1' AND mail_irq(7)= '1' THEN
              mail_irq_reg(7) <= '1';
           END IF;
        END IF;
     
     END IF;
  END PROCESS mail_ir;   
  
  mailbox_irq(0) <= '1' WHEN mail_irq_reg(0) = '1' OR mail_irq_reg(1) = '1' OR mail_irq_reg(2) = '1' OR mail_irq_reg(3) = '1' ELSE '0';
  mailbox_irq(1) <= '1' WHEN mail_irq_reg(4) = '1' OR mail_irq_reg(5) = '1' OR mail_irq_reg(6) = '1' OR mail_irq_reg(7) = '1' ELSE '0';
  
  -- clear address combination bits when clear status bit
  clr_locmon(0) <= '1' WHEN write_flag = '1' AND int_adr(6 DOWNTO 2) = "01110" AND int_be(0) = '1' AND reg_data_in(3) = '1' ELSE '0';
  clr_locmon(1) <= '1' WHEN write_flag = '1' AND int_adr(6 DOWNTO 2) = "01111" AND int_be(0) = '1' AND reg_data_in(3) = '1' ELSE '0';
  
loc_sta0 : PROCESS(clk, rst)
   BEGIN
      IF rst = '1' THEN
         locsta_0 <= (OTHERS => '0');
         locmon_irq(0) <= '0';
         loc_irq_0_q <= '0';
         loc_sel_0_int <= (OTHERS => '0'); 
      ELSIF clk'EVENT AND clk = '1' THEN
         loc_irq_0_q <= loc_irq_0;
         IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "01110" AND int_be(0) = '1' THEN
            locsta_0(5 DOWNTO 4) <= reg_data_in(5 DOWNTO 4);
            locsta_0(2 DOWNTO 0) <= reg_data_in(2 DOWNTO 0);
         END IF;
         
         IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "01110" AND int_be(0) = '1' AND reg_data_in(3) = '1' THEN
            locsta_0(3) <= '0';
            loc_sel_0_int <= (OTHERS => '0');
         ELSIF loc_irq_0 = '1' AND loc_irq_0_q = '0' THEN
            locsta_0(3) <= '1';
            loc_sel_0_int <= loc_sel;
         END IF;
         
         IF locsta_0(0) = '1' AND locsta_0(3) = '1' THEN
            locmon_irq(0) <= '1';
         ELSE
            locmon_irq(0) <= '0';
         END IF;
      END IF;
   END PROCESS loc_sta0;   
  
   loc_rw_0 <= locsta_0(5 DOWNTO 4);
   loc_am_0 <= locsta_0(2 DOWNTO 1);

loc_sta1 : PROCESS(clk, rst)
   BEGIN
      IF rst = '1' THEN
         locsta_1 <= (OTHERS => '0');
         locmon_irq(1) <= '0';
         loc_irq_1_q <= '0';
         loc_sel_1_int <= (OTHERS => '0');
      ELSIF clk'EVENT AND clk = '1' THEN
         loc_irq_1_q <= loc_irq_1;
         IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "01111" AND int_be(0) = '1' THEN
            locsta_1(5 DOWNTO 4) <= reg_data_in(5 DOWNTO 4);
            locsta_1(2 DOWNTO 0) <= reg_data_in(2 DOWNTO 0);
         END IF;
         
         IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "01111" AND int_be(0) = '1' AND reg_data_in(3) = '1' THEN
            locsta_1(3) <= '0';
            loc_sel_1_int <= (OTHERS => '0');
         ELSIF loc_irq_1 = '1' AND loc_irq_1_q = '0' THEN
            locsta_1(3) <= '1';
            loc_sel_1_int <= loc_sel;
         END IF;
      
         IF locsta_1(0) = '1' AND locsta_1(3) = '1' THEN
            locmon_irq(1) <= '1';
         ELSE
            locmon_irq(1) <= '0';
         END IF;
      END IF;
   END PROCESS loc_sta1;   

  loc_rw_1 <= locsta_1(5 DOWNTO 4);
  loc_am_1 <= locsta_1(2 DOWNTO 1);
 
loc_adr0 : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
        loc_adr_0_int <= (OTHERS => '0');
     ELSIF clk'EVENT AND clk = '1' THEN
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "10000" THEN
           IF int_be(0) = '1' THEN
              loc_adr_0_int(7 DOWNTO 0) <= reg_data_in(7 DOWNTO 0);
           END IF;
           IF int_be(1) = '1' THEN
              loc_adr_0_int(15 DOWNTO 8) <= reg_data_in(15 DOWNTO 8);
           END IF;
           IF int_be(2) = '1' THEN
              loc_adr_0_int(23 DOWNTO 16) <= reg_data_in(23 DOWNTO 16);
           END IF;
           IF int_be(3) = '1' THEN
              loc_adr_0_int(31 DOWNTO 24) <= reg_data_in(31 DOWNTO 24);
           END IF;
        END IF;
     END IF;
  END PROCESS loc_adr0;   
 
--    loc_adr_0 <= loc_adr_0_int(7 DOWNTO 0) & loc_adr_0_int(15 DOWNTO 8) & loc_adr_0_int(23 DOWNTO 16) & loc_adr_0_int(31 DOWNTO 24);
   loc_adr_0 <= loc_adr_0_int;
 
loc_adr1 : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
        loc_adr_1_int <= (OTHERS => '0');
     ELSIF clk'EVENT AND clk = '1' THEN
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "10001" THEN
           IF int_be(0) = '1' THEN
              loc_adr_1_int(7 DOWNTO 0) <= reg_data_in(7 DOWNTO 0);
           END IF;
           IF int_be(1) = '1' THEN
              loc_adr_1_int(15 DOWNTO 8) <= reg_data_in(15 DOWNTO 8);
           END IF;
           IF int_be(2) = '1' THEN
              loc_adr_1_int(23 DOWNTO 16) <= reg_data_in(23 DOWNTO 16);
           END IF;
           IF int_be(3) = '1' THEN
              loc_adr_1_int(31 DOWNTO 24) <= reg_data_in(31 DOWNTO 24);
           END IF;
        END IF;
     END IF;
  END PROCESS loc_adr1;   

--    loc_adr_1 <= loc_adr_1_int(7 DOWNTO 0) & loc_adr_1_int(15 DOWNTO 8) & loc_adr_1_int(23 DOWNTO 16) & loc_adr_1_int(31 DOWNTO 24);
   loc_adr_1 <= loc_adr_1_int;


brl_pr : PROCESS(clk, rst)
   BEGIN
      IF rst = '1' THEN
         brl_int   <= (OTHERS => '1');       -- default request level is 3 to be compatible to old implementations
      ELSIF clk'EVENT AND clk = '1' THEN
        IF write_flag = '1' AND int_adr(6 DOWNTO 2) = "10101" THEN
            IF int_be(0) = '1' THEN
               brl_int <= reg_data_in(1 DOWNTO 0);
            END IF;
        END IF;
      END IF;
   END PROCESS brl_pr;
   
   brl <= brl_int;
   
END vme_du_arch;






