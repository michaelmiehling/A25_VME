--------------------------------------------------------------------------------
-- Title         : Wishbone Master Interface
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : vme_wbm.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 11/02/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- The module handles the wishbone master accesses to PCI or SRAM space. If a
-- VME access to the slave gets received, the vme_slave will forward this to
-- vme_wbm. All wishbone accesses are single read/write. If there is a 
-- read-modify-write request, the cyc signal between the read and write access 
-- on the wishbone bus will be keept asserted to prevent access to the same 
-- location in between.
--------------------------------------------------------------------------------
-- Hierarchy:
--
-- vme_ctrl
--    vme_wbm
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
-- $Revision: 1.4 $
--
-- $Log: vme_wbm.vhd,v $
-- Revision 1.4  2012/11/12 08:13:04  MMiehling
-- changed comments
--
-- Revision 1.3  2012/09/25 11:21:39  MMiehling
-- added wbm_err signal for error signalling from pcie to vme
--
-- Revision 1.2  2012/08/27 12:57:04  MMiehling
-- added sl_en_vma_dat_out_reg_high for d64 access
--
-- Revision 1.1  2012/03/29 10:14:29  MMiehling
-- Initial Revision
--
-- Revision 1.8  2004/11/02 11:29:40  mmiehling
-- removed iram access
--
-- Revision 1.7  2004/07/27 17:15:25  mmiehling
-- changed pci-core to 16z014
-- changed wishbone bus to wb_bus.vhd
-- added clk_trans_wb2wb.vhd
-- improved dma
--
-- Revision 1.6  2003/12/17 15:51:35  MMiehling
-- optimized performance
--
-- Revision 1.5  2003/12/01 10:03:26  MMiehling
-- changed all
--
-- Revision 1.4  2003/06/24 13:46:47  MMiehling
-- removed burst; added loc_keep
--
-- Revision 1.3  2003/06/13 10:06:16  MMiehling
-- improved timing
--
-- Revision 1.2  2003/04/22 11:02:49  MMiehling
-- improved fsm
--
-- Revision 1.1  2003/04/01 13:04:27  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY vme_wbm IS
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
END vme_wbm;

ARCHITECTURE vme_wbm_arch OF vme_wbm IS 
   TYPE   loc_mstr_states IS (idle, req_bus, req_bus2, wait_on_end);
   SIGNAL    loc_mstr_state : loc_mstr_states;
   SIGNAL wbm_stb_o_int   : std_logic;
   SIGNAL inc_wbm_cnt : std_logic;
   SIGNAL mensb_mstr_ack_int : std_logic;
   SIGNAL d64_high : std_logic;     
   SIGNAL sl_en_vme_data_out_reg_int : std_logic;
BEGIN
   wbm_stb_o <= wbm_stb_o_int;
   inc_loc_adr_m_cnt <= inc_wbm_cnt;
   mensb_mstr_ack <= mensb_mstr_ack_int;
   
   -- the wb-bus arbitration will be released when a single vme-transaction is done (done when asn is deasserted)
   -- in case of a rmw-cycle the asn-signal will be asserted between the two transactions => the wb-bus cyc-signal 
   -- will also be asserted between these two transactions
   -- in case of a burst, the asn-signal is asserted all the time, but the wb-bus will be released after each 
   -- single transaction, in order to prevent bus errors on pci-bus
   
regs : PROCESS(clk, rst)
BEGIN
   IF rst = '1' THEN
      vme_cyc_sram <= '0';
      vme_cyc_pci <= '0';
      d64_high <= '0';
   ELSIF clk'EVENT AND clk = '1' then
      IF ((wbm_ack_i = '1' OR wbm_err_i = '1') AND (wbm_we_o = '1' OR sl_acc_wb(1) = '1' OR sl_acc_wb(0) = '1'))          -- burst or write
        OR (loc_keep = '1' AND wbm_we_o = '0') THEN -- read and not burst (read of rmw)
         vme_cyc_sram <= '0';
         vme_cyc_pci <= '0';
      ELSIF mensb_mstr_req = '1' AND mensb_mstr_ack_int = '0' THEN
         vme_cyc_sram <= sram_acc;
         vme_cyc_pci <= pci_acc;
      END IF;
      
      IF d64_high = '0' AND sl_en_vme_data_out_reg_int = '1' AND sl_acc_wb(0) = '1' AND wbm_we_o = '0' THEN
         d64_high <= '1';
      ELSIF sl_en_vme_data_out_reg_int = '1' THEN
         d64_high <= '0';
      END IF;
     
   END IF;
END PROCESS regs;   
   
   sl_en_vme_data_out_reg <= sl_en_vme_data_out_reg_int WHEN d64_high = '0' ELSE '0';
   sl_en_vme_data_out_reg_high <= sl_en_vme_data_out_reg_int WHEN d64_high = '1' ELSE '0';
   
loc_mstr_fsm : PROCESS (clk, rst)
BEGIN
   IF rst = '1' THEN
      loc_mstr_state <= idle;
      wbm_stb_o_int <= '0';
      mensb_mstr_ack_int <= '0';
      en_wbm_dat_o <= '1';
      sel_wbm_dat_o <= '0';
      inc_wbm_cnt <= '0';
      sl_en_vme_data_out_reg_int <= '0';
   ELSIF clk'EVENT AND clk = '1' THEN
      CASE loc_mstr_state IS
         WHEN idle =>
            sl_en_vme_data_out_reg_int <= '0';
            inc_wbm_cnt <= '0';
            mensb_mstr_ack_int <= '0';
            sel_wbm_dat_o <= '0';
            IF mensb_mstr_req = '1' AND (sram_acc = '1' OR pci_acc = '1') THEN
               loc_mstr_state <= req_bus;
               wbm_stb_o_int <= '1';
               en_wbm_dat_o <= '0';    -- stop loading wbm_dat_o
            ELSE
               loc_mstr_state <= idle;
               wbm_stb_o_int <= '0';
               en_wbm_dat_o <= '1';    -- always enable
            END IF;
         
         WHEN req_bus =>
            IF ((wbm_ack_i = '1'  OR wbm_err_i = '1') AND sl_acc_wb(0) = '0') OR mensb_mstr_req = '0' THEN
               sl_en_vme_data_out_reg_int <= '1';
               loc_mstr_state <= wait_on_end;
               inc_wbm_cnt <= '0';
               mensb_mstr_ack_int <= '1';
               wbm_stb_o_int <= '0';
               en_wbm_dat_o <= '0';
               sel_wbm_dat_o <= '0';
            ELSIF ((wbm_ack_i = '1'  OR wbm_err_i = '1') AND sl_acc_wb(0) = '1') OR mensb_mstr_req = '0' THEN
               sl_en_vme_data_out_reg_int <= '1';
               inc_wbm_cnt <= '1';      -- increment wbm_cnt
               IF wbm_we_o = '1' THEN
                  mensb_mstr_ack_int <= '0';   -- not yet ack, because two cycles has to be done
                  loc_mstr_state <= req_bus2;
               ELSE
                  mensb_mstr_ack_int <= '1';   -- ack, because first d32 can be put to external driver
                  loc_mstr_state <= wait_on_end;
               END IF;
               wbm_stb_o_int <= '0';   -- one cycle break
               en_wbm_dat_o <= '1';      -- put high d32 in wbm_dat_o
               sel_wbm_dat_o <= '1';
            ELSE
               sl_en_vme_data_out_reg_int <= '0';
               loc_mstr_state <= req_bus;
               inc_wbm_cnt <= '0';
               mensb_mstr_ack_int <= '0';
               wbm_stb_o_int <= '1';
               en_wbm_dat_o <= '0';
               sel_wbm_dat_o <= '0';
            END IF;
         
         WHEN req_bus2 =>
            sl_en_vme_data_out_reg_int <= '0';
            inc_wbm_cnt <= '0';
            en_wbm_dat_o <= '0';
            sel_wbm_dat_o <= '1';
            IF (wbm_ack_i = '1'  OR wbm_err_i = '1') OR mensb_mstr_req = '0' THEN
               loc_mstr_state <= wait_on_end;
               mensb_mstr_ack_int <= '1';
               wbm_stb_o_int <= '0';
            ELSE
               loc_mstr_state <= req_bus2;
               mensb_mstr_ack_int <= '0';
               wbm_stb_o_int <= '1';
            END IF;
         
         WHEN wait_on_end =>
            sl_en_vme_data_out_reg_int <= '0';
            inc_wbm_cnt <= '0';
            en_wbm_dat_o <= '0';
            wbm_stb_o_int <= '0';
            loc_mstr_state <= idle;
            mensb_mstr_ack_int <= '0';
            sel_wbm_dat_o <= '0';
         
         WHEN OTHERS =>
            sl_en_vme_data_out_reg_int <= '0';
            inc_wbm_cnt <= '0';
            en_wbm_dat_o <= '0';
            loc_mstr_state <= idle;
            mensb_mstr_ack_int <= '0';
            wbm_stb_o_int <= '0';
            sel_wbm_dat_o <= '0';
      END CASE;
   END IF;
END PROCESS loc_mstr_fsm;
  
END vme_wbm_arch;
