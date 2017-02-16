--------------------------------------------------------------------------------
-- Title         : VME Slave
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : vme_slave.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 11/02/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- The WBB2VME core supports 5 independent VME slave windows. These windows are 
-- disabled per default and can be enabled via register bits SLENx. 
-- If a slave window is enabled, the base address must be set to an appropriate 
-- value.  The window defined by base address and size must be unique on the 
-- VMEbus in order to prevent VMEbus signals driven by more than one slave!
-- Three slave windows (SLV16, SLV24 and SLV32) are capable to access the local 
-- SRAM (VME slave base address = 0x0 of local SRAM). The local SRAM can be 
-- accessed from CPU, DMA, Mailbox and VME slave, which must be well organized 
-- in order to prevent data mismatch!
-- Two slave windows (SLV24_PCI and SLV32_PCI) are capable to access the PCI 
-- address space at an offset address defined in register PCI_OFFSET.  The 
-- offset will be added to the VME address during each access to the PCI space.
-- The address modifiers for these VME slave windows cannot be configured, but 
-- all common types are supported:
-- Hex  543210	Function
-- 0x3F HHHHHH A24 supervisory block transfer (BLT)
-- 0x3E HHHHHL A24 supervisory program transfer
-- 0x3D HHHHLH A24 supervisory data transfer
-- 0x3C HHHHLL A24 supervisory 64-bit block transfer (MBLT)
-- 0x3B HHHLHH A24 non privileged block transfer (BLT)
-- 0x3A HHHLHL A24 non privileged program transfer
-- 0x39 HHHLLH A24 non privileged data transfer
-- 0x38 HHHLLL A24 non privileged 64-bit block transfer (MBLT)
-- 0x2D HLHHLH A16 supervisory transfer
-- 0x29 HLHLLH A16 non-privileged transfer
-- 0x0F LLHHHH A32 supervisory block transfer (BLT)
-- 0x0E LLHHHL A32 supervisory program transfer
-- 0x0D LLHHLH A32 supervisory data transfer
-- 0x0C LLHHLL A32 supervisory 64-bit block transfer (MBLT)
-- 0x0B LLHLHH A32 non privileged block transfer (BLT)
-- 0x0A LLHLHL A32 non privileged program transfer
-- 0x09 LLHLLH A32 non privileged data transfer
-- 0x08 LLHLLL A32 non privileged 64-bit block transfer (MBLT)

--------------------------------------------------------------------------------
-- Hierarchy:
--
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
-- $Revision: 1.5 $
--
-- $Log: vme_slave.vhd,v $
-- Revision 1.5  2015/04/07 14:30:11  AGeissler
-- R1:   MAIN_PR002233
-- M1.1: Added signal sl_acc_valid, which shows that the sl_acc is
--       stable and can be used
-- M1.2: Added signal asn_in_sl_reg, which is the synchronized asn
--       PIN signal with one register
-- M1.3: Wait until sl_acc is stable, before switching to sl_vme_req
-- R2: Clearness
-- M2: Removed unused comments and signals
--
-- Revision 1.4  2015/03/30 15:23:01  AGeissler
-- R1: If there is a write request from the master to one of a VME slave card and than another write
--     access to a different VME slave card is directly followed, the previous VME slave card acknowledge the write
--     access again even if it is not selected. This cause a VME bus error on the VME master. (MAIN_PR002233)
-- M1: The ld_loc_adr signal shall be generated directly from the conditional signals and not stored in a register,
--     that a new incomming address by the VME bus when address strob is active is stored and evaluated before
--     a new access to the old address is performed.
--
-- Revision 1.3  2012/09/25 11:21:41  MMiehling
-- removed unused signals
--
-- Revision 1.2  2012/08/27 12:57:09  MMiehling
-- general rework of d64 access handling
--
-- Revision 1.1  2012/03/29 10:14:32  MMiehling
-- Initial Revision
--
-- Revision 1.8  2004/07/27 17:15:44  mmiehling
-- changed pci-core to 16z014
-- changed wishbone bus to wb_bus.vhd
-- added clk_trans_wb2wb.vhd
-- improved dma
--
-- Revision 1.7  2004/06/17 13:02:31  MMiehling
-- removed clr_hit and sl_acc_reg
--
-- Revision 1.6  2003/12/17 15:51:52  MMiehling
-- improved performance
--
-- Revision 1.5  2003/12/01 10:04:00  MMiehling
-- added d64
--
-- Revision 1.4  2003/06/24 13:47:15  MMiehling
-- added loc_keep
--
-- Revision 1.3  2003/06/13 10:06:44  MMiehling
-- improved timing
--
-- Revision 1.2  2003/04/22 11:03:06  MMiehling
-- improved request - acknowledge
--
-- Revision 1.1  2003/04/01 13:04:47  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.vme_pkg.ALL;

ENTITY vme_slave IS
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
END vme_slave;

ARCHITECTURE vme_slave_arch OF vme_slave IS 
   TYPE   sl_states IS (sl_idle, sl_vme_req, sl_vme_req2, sl_vme_ack, sl_wait_1, sl_wait_ondata, sl_wait_on_dsn, sl_got_dsn);
   SIGNAL    sl_state : sl_states;
   TYPE req_states IS(idle, req);
   SIGNAL req_state, req_nxtstate : req_states;
   SIGNAL dsan_in_reg         : std_logic;
   SIGNAL dsbn_in_reg         : std_logic;
   SIGNAL asn_in_reg          : std_logic;
   SIGNAL request             : std_logic;
   SIGNAL acknowledge         : std_logic;
   SIGNAL sl_end              : std_logic;
   SIGNAL dtackn_out_reg      : std_logic;
   SIGNAL ld_loc_adr          : std_logic;
   SIGNAL slave_req_int       : std_logic;
   SIGNAL slave_active_reg    : std_logic;
   SIGNAL first_cycle         : std_logic;
   SIGNAL asn_in_reg2         : std_logic;
   SIGNAL mstr_busy_q         : std_logic;
   
BEGIN
   asn_in_sl_reg     <= asn_in_reg;
   slave_req         <= slave_req_int;
   ld_loc_adr_m_cnt  <= ld_loc_adr;
   sl_second_word    <= NOT first_cycle;
   
   reg_en_vme_data_out_reg <= '1' WHEN slave_active = '1' AND (reg_acc = '1' OR my_iack = '1') ELSE '0';
   
   loc_keep <= '1' WHEN asn_in_reg = '1' AND asn_in_reg2 = '0' ELSE '0';
   
   sl_inc_loc_adr_m_cnt <= '1' WHEN (mensb_mstr_ack = '1' AND wbm_we_o = '1') ELSE                 -- write access
                           '1' WHEN (sl_end = '1' AND wbm_we_o = '0' AND NOT sl_acc(0) = '1') ELSE -- read access
                           '0';
   
   en_vme_adr_in <= '1' WHEN asn_in_reg = '0' AND asn_in_reg2 = '1' ELSE '0';    -- detect falling edge
   
   req_sta : PROCESS (clk, rst)
   BEGIN
      IF rst = '1' THEN
         req_state            <= idle;
         slave_active_reg     <= '0';
         mstr_busy_q          <= '0';
      ELSIF clk'EVENT AND clk = '1' THEN
         req_state            <= req_nxtstate;
         slave_active_reg     <= slave_active;
         mstr_busy_q          <= mstr_busy;
      END IF;
   END PROCESS req_sta;
   
   req_fsm : PROCESS (req_state, request, reg_acc, my_iack, slave_active_reg, mensb_mstr_ack)
   BEGIN
      CASE req_state IS
         WHEN idle =>
            IF my_iack = '0' AND reg_acc = '0' AND request = '1' THEN
               req_nxtstate         <= req;
               mensb_mstr_req       <= '1';
               acknowledge          <= '0';
               slave_req_int        <= '0';
            ELSIF (my_iack = '1' OR reg_acc = '1') AND request = '1' THEN
               req_nxtstate         <= req;
               mensb_mstr_req       <= '0';
               acknowledge          <= '0';
               slave_req_int        <= '1';
            ELSE
               req_nxtstate         <= idle;
               mensb_mstr_req       <= '0';
               acknowledge          <= '1';
               slave_req_int        <= '0';
            END IF;
         WHEN req =>
            IF my_iack = '0' AND reg_acc = '0' THEN
               IF mensb_mstr_ack = '1' THEN
                  req_nxtstate      <= idle;
                  mensb_mstr_req    <= '1';      -- keep for this cycle
                  acknowledge       <= '1';
                  slave_req_int     <= '0';
               ELSE
                  req_nxtstate      <= req;
                  mensb_mstr_req    <= '1';      -- wait for acknowledge
                  acknowledge       <= '0';
                  slave_req_int     <= '0';
               END IF;
            ELSE
               IF slave_active_reg = '1' THEN
                  req_nxtstate      <= idle;
                  mensb_mstr_req    <= '0';
                  acknowledge       <= '1';      -- keep for this cycle
                  slave_req_int     <= '1';
               ELSE
                  req_nxtstate      <= req;
                  mensb_mstr_req    <= '0';
                  acknowledge       <= '0';
                  slave_req_int     <= '1';      -- wait for acknowledge
               END IF;
            END IF;
         WHEN OTHERS =>
                  req_nxtstate      <= idle;
                  mensb_mstr_req    <= '0';
                  acknowledge       <= '1';
                  slave_req_int     <= '0';
      END CASE;
   END PROCESS  req_fsm;
   
   
   reg : PROCESS(clk, rst)
   BEGIN
      IF rst = '1' THEN
         asn_in_reg     <= '1';
         asn_in_reg2    <= '1';
         dsan_in_reg    <= '1';
         dsbn_in_reg    <= '1';
         clr_intreq     <= '0';
         dtackn_out     <= '1';
         sl_write_flag  <= '0';
         
      ELSIF clk'EVENT AND clk = '1' THEN
         IF reg_acc = '1' AND slave_active_reg = '0' AND slave_active = '1' AND wbm_we_o = '1' THEN
            sl_write_flag <= '1';
         ELSE
            sl_write_flag <= '0';
         END IF;
         dtackn_out  <= dtackn_out_reg;
         asn_in_reg  <= asn_in;
         asn_in_reg2 <= asn_in_reg;
         dsan_in_reg <= dsan_in;
         dsbn_in_reg <= dsbn_in;
         
       IF my_iack = '1' AND sl_end = '1' THEN
          clr_intreq <= '1';
       ELSE
          clr_intreq <= '0';
       END IF;
       
      END IF;
   END PROCESS reg;
   
   ld_loc_adr <= '1' WHEN  asn_in_reg = '0' AND (dsan_in_reg = '0' OR  dsbn_in_reg = '0')    AND acknowledge = '1' AND 
                           mstr_busy  = '0' AND  mstr_busy_q = '0' AND sl_state    = sl_idle AND sl_acc_valid = '1' AND
                           (sl_acc(4) = '1' OR   sl_acc(3)   = '1' OR  sl_acc(2)   = '1'     OR  my_iack = '1') ELSE '0';
   
   sl_fsm : PROCESS (clk, rst)
   BEGIN
      IF rst = '1' THEN
         sl_state             <= sl_idle;
         dtackn_out_reg       <= '1';
         request              <= '0';
         sl_en_vme_data_in_reg<= '0';
         sl_oe_va             <= '0';
         sl_oe_vd             <= '0';
         sl_end               <= '0';
         first_cycle          <= '0';
         sl_en_vme_data_in_reg_high <= '0';
         sl_io_ctrl.d_dir     <= '0';
         sl_io_ctrl.d_oe_n    <= '1';
         sl_io_ctrl.am_dir    <= '0';
         sl_io_ctrl.am_oe_n   <= '0';
         sl_io_ctrl.a_dir     <= '0';
         sl_io_ctrl.a_oe_n    <= '0';
         
      ELSIF clk'EVENT AND clk = '1' THEN
         CASE sl_state IS
            WHEN sl_idle =>
               IF ld_loc_adr = '1' THEN 
                  sl_state                   <= sl_vme_req; -- if vme bus requests a transmission
                  sl_io_ctrl.a_dir           <= '0';
                  sl_io_ctrl.a_oe_n          <= '0';
                  first_cycle                <= '1';        -- indicates adress cycle for d64 bursts
                  IF sl_writen_reg = '1' THEN               -- read
                     sl_io_ctrl.d_dir        <= '1';
                     sl_io_ctrl.d_oe_n       <= '0';
                  ELSE                                      -- write
                     sl_io_ctrl.d_dir        <= '0';
                     sl_io_ctrl.d_oe_n       <= '0';
                  END IF;
               ELSE
                  sl_state                   <= sl_idle;         -- actions on vme bus are not for this slave
                  sl_io_ctrl.a_dir           <= '0';
                  sl_io_ctrl.a_oe_n          <= '0';
                  sl_io_ctrl.d_dir           <= '0';
                  sl_io_ctrl.d_oe_n          <= '1';
                  first_cycle                <= '0';
               END IF;
               dtackn_out_reg                <= '1';
               request                       <= '0';
               sl_en_vme_data_in_reg         <= '0';
               sl_en_vme_data_in_reg_high    <= '0';
               sl_oe_vd                      <= '0';
               sl_oe_va                      <= '0';
               sl_end                        <= '0';
               sl_io_ctrl.am_dir             <= '0';
               sl_io_ctrl.am_oe_n            <= '0';
               
            WHEN sl_vme_req =>
               IF request = '0' AND acknowledge = '0' THEN                                            -- wait until prior access is finished
                  sl_state                   <= sl_vme_req;
                  IF wbm_we_o = '0' AND sl_acc(0) = '0' THEN                                          -- no d64
                     request                 <= '1';                                                  -- set master request for read actions
                  ELSIF wbm_we_o = '0' AND sl_acc(0) = '1' AND first_cycle = '0' THEN
                     request                 <= '1';                                                  -- set master request for read actions
                  ELSE
                     request                 <= '0';
                  END IF;
               ELSIF wbm_we_o = '1' THEN                                                              -- if write access, then go on
                  sl_state                   <= sl_vme_ack;
                  request                    <= '0';
               ELSIF wbm_we_o = '0' AND acknowledge = '1' AND request = '1' AND sl_acc(0) = '1' THEN  -- read: requested data is available => go on
                  sl_state                   <= sl_vme_req2;
                  request                    <= '1';                                                  -- req for second d32
               ELSIF wbm_we_o = '0' AND acknowledge = '1' AND request = '1' THEN                      -- read: requested data is available => go on
                  sl_state                   <= sl_vme_ack;
                  request                    <= '0';
               ELSIF wbm_we_o = '0' AND sl_acc(0) = '1' AND first_cycle = '1' THEN
                  sl_state                   <= sl_vme_ack;                                           -- first d64 read cycle is only adress => no req
                  request                    <= '0';                  
               ELSE -- wbm_we_o = '0' AND acknowledge = '1' AND request = '0' THEN                    -- if read access, then request internal data
                  sl_state                   <= sl_vme_req;
                  IF wbm_we_o = '0' THEN 
                     request                 <= '1';                                                  -- set master request for read actions
                  ELSE
                     request                 <= '0';
                  END IF;
               END IF;
               dtackn_out_reg                <= '1';
               sl_en_vme_data_in_reg         <= '1';
               sl_en_vme_data_in_reg_high    <= '0';
               IF wbm_we_o = '0' THEN 
                  sl_oe_vd                   <= '1';
                  sl_io_ctrl.d_dir           <= '1';
                  sl_io_ctrl.d_oe_n          <= '0';
               ELSE                               
                  sl_oe_vd                   <= '0';
                  sl_io_ctrl.d_dir           <= '0';
                  sl_io_ctrl.d_oe_n          <= '0';
               END IF;
               sl_end                        <= '0';
               first_cycle                   <= first_cycle;
               IF wbm_we_o = '0' AND first_cycle = '0' AND sl_acc(0) = '1' THEN      -- d64 read
                  sl_oe_va                   <= '1';
                  sl_io_ctrl.a_dir           <= '1';
                  sl_io_ctrl.a_oe_n          <= '0';
               ELSE                                                                   -- d64 write or non-d64
                  sl_oe_va                   <= '0';
                  sl_io_ctrl.a_dir           <= '0';
                  sl_io_ctrl.a_oe_n          <= '0';
               END IF;
               sl_io_ctrl.am_dir    <= '0';
               sl_io_ctrl.am_oe_n   <= '0';
               
            WHEN sl_vme_req2 =>                           -- wait on second d32 for d64 read access
               IF acknowledge = '1' THEN
                  sl_state                   <= sl_vme_ack;
                  request                    <= '0';
               ELSE
                  sl_state                   <= sl_vme_req2;
                  request                    <= '1';
               END IF;
               dtackn_out_reg                <= '1';
               sl_en_vme_data_in_reg         <= '0';
               sl_en_vme_data_in_reg_high    <= '0';
               sl_oe_vd                      <= '1';
               sl_oe_va                      <= '1';
               sl_io_ctrl.d_dir              <= '1';
               sl_io_ctrl.d_oe_n             <= '0';
               sl_io_ctrl.a_dir              <= '1';
               sl_io_ctrl.a_oe_n             <= '0';
               sl_end                        <= '0';
               first_cycle                   <= first_cycle;
               sl_io_ctrl.am_dir             <= '0';
               sl_io_ctrl.am_oe_n            <= '0';
               
            WHEN sl_vme_ack =>
               sl_state <= sl_wait_1;
               dtackn_out_reg                <= '1';
               IF wbm_we_o = '0' THEN 
                  sl_en_vme_data_in_reg      <= '0';
                  sl_en_vme_data_in_reg_high <= '0';
                  sl_oe_vd                   <= '1';
                  sl_io_ctrl.d_dir           <= '1';
                  sl_io_ctrl.d_oe_n          <= '0';
               ELSE
                  IF sl_acc(0) = '1' THEN                   -- if sl_blt64
                     sl_en_vme_data_in_reg      <= '0';
                     sl_en_vme_data_in_reg_high <= '1';     -- if d64 then latch high d32
                  ELSE
                     sl_en_vme_data_in_reg      <= '1';     -- if d32 then latch low d32
                     sl_en_vme_data_in_reg_high <= '0';
                  END IF;
                  sl_oe_vd                   <= '0';
                  sl_io_ctrl.d_dir           <= '0';
                  sl_io_ctrl.d_oe_n          <= '0';
               END IF;
               request                       <= '0';
               sl_end                        <= '0';
               first_cycle                   <= first_cycle;
               IF wbm_we_o = '0' AND first_cycle = '0' AND sl_acc(0) = '1' THEN      -- d64 read
                  sl_oe_va                   <= '1';
                  sl_io_ctrl.a_dir           <= '1';
                  sl_io_ctrl.a_oe_n          <= '0';
               ELSE                                                                   -- d64 write or non-d64
                  sl_oe_va                   <= '0';
                  sl_io_ctrl.a_dir           <= '0';
                  sl_io_ctrl.a_oe_n          <= '0';
               END IF;
               sl_io_ctrl.am_dir          <= '0';
               sl_io_ctrl.am_oe_n         <= '0';
               
            WHEN sl_wait_1 =>
               IF wbm_we_o = '0' THEN 
                  sl_state                   <= sl_wait_ondata;            -- if read access, another wait state is required
                  dtackn_out_reg             <= '1';
                  request                    <= '0';
                  sl_oe_vd                   <= '1';
                  sl_io_ctrl.d_dir           <= '1';
                  sl_io_ctrl.d_oe_n          <= '0';
               ELSE                               
                  IF sl_acc(0) = '1' AND first_cycle = '1' THEN
                     request                 <= '0';         -- no request when adress cycle of d64 burst
                  ELSE
                     request                 <= '1';      -- master request for write action now, because data on mensb is valid
                  END IF;
                  sl_state                   <= sl_wait_on_dsn;
                  dtackn_out_reg             <= '0';
                  sl_oe_vd                   <= '0';
                  sl_io_ctrl.d_dir           <= '0';
                  sl_io_ctrl.d_oe_n          <= '0';
               END IF;
               sl_en_vme_data_in_reg         <= '0';
               sl_en_vme_data_in_reg_high    <= '0';
               sl_end                        <= '0';
               first_cycle                   <= first_cycle;
               IF wbm_we_o = '0' AND first_cycle = '0' AND sl_acc(0) = '1' THEN      -- d64 read
                  sl_oe_va                   <= '1';
                  sl_io_ctrl.a_dir           <= '1';
                  sl_io_ctrl.a_oe_n          <= '0';
               ELSE                                                                   -- d64 write or non-d64
                  sl_oe_va                   <= '0';
                  sl_io_ctrl.a_dir           <= '0';
                  sl_io_ctrl.a_oe_n          <= '0';
               END IF;
               sl_io_ctrl.am_dir             <= '0';
               sl_io_ctrl.am_oe_n            <= '0';
               
            WHEN sl_wait_ondata =>
               IF acknowledge = '1' THEN
                  sl_state <= sl_wait_on_dsn;
               ELSE
                  sl_state <= sl_wait_ondata;
               END IF;
               dtackn_out_reg                <= '1';
               sl_en_vme_data_in_reg         <= '0';
               sl_en_vme_data_in_reg_high    <= '0';
               request                       <= '0';
               sl_oe_vd                      <= '1';
               sl_io_ctrl.d_dir              <= '1';
               sl_io_ctrl.d_oe_n             <= '0';
               sl_end                        <= '0';
               first_cycle                   <= first_cycle;
               IF wbm_we_o = '0' AND first_cycle = '0' AND sl_acc(0) = '1' THEN      -- d64 read
                  sl_oe_va                   <= '1';
                  sl_io_ctrl.a_dir           <= '1';
                  sl_io_ctrl.a_oe_n          <= '0';
               ELSE                                                                   -- d64 write or non-d64
                  sl_oe_va                   <= '0';
                  sl_io_ctrl.a_dir           <= '0';
                  sl_io_ctrl.a_oe_n          <= '0';
               END IF;
               sl_io_ctrl.am_dir             <= '0';
               sl_io_ctrl.am_oe_n            <= '0';
               
            WHEN sl_wait_on_dsn =>
               IF dsan_in_reg = '1' AND dsbn_in_reg = '1' THEN
                  sl_state <= sl_got_dsn;
               ELSE
                  sl_state <= sl_wait_on_dsn;
               END IF;
               IF wbm_we_o = '0' THEN 
                  sl_oe_vd                <= '1';
                  sl_io_ctrl.d_dir        <= '1';
                  sl_io_ctrl.d_oe_n       <= '0';
               ELSE
                  sl_oe_vd                <= '0';
                  sl_io_ctrl.d_dir        <= '0';
                  sl_io_ctrl.d_oe_n       <= '0';
               END IF;
               dtackn_out_reg                <= '0';
               sl_en_vme_data_in_reg         <= '0';
               sl_en_vme_data_in_reg_high    <= '0';
               request                       <= '0';
               sl_end                        <= '0';
               first_cycle                   <= first_cycle;
               IF wbm_we_o = '0' AND first_cycle = '0' AND sl_acc(0) = '1' THEN      -- d64 read
                  sl_oe_va                   <= '1';
                  sl_io_ctrl.a_dir           <= '1';
                  sl_io_ctrl.a_oe_n          <= '0';
               ELSE                                                                   -- d64 write or non-d64
                  sl_oe_va                   <= '0';
                  sl_io_ctrl.a_dir           <= '0';
                  sl_io_ctrl.a_oe_n          <= '0';
               END IF;
               sl_io_ctrl.am_dir             <= '0';
               sl_io_ctrl.am_oe_n            <= '0';
               
            WHEN sl_got_dsn =>
               IF sl_acc(1) = '1' AND asn_in_reg = '0' THEN      -- d32 burst access
                  sl_oe_va                   <= '0';
                  sl_io_ctrl.a_dir           <= '0';
                  sl_io_ctrl.a_oe_n          <= '1';
                  IF wbm_we_o = '0' THEN 
                     sl_oe_vd                <= '1';
                     sl_io_ctrl.d_dir        <= '1';
                     sl_io_ctrl.d_oe_n       <= '0';
                  ELSE
                     sl_oe_vd                <= '0';
                     sl_io_ctrl.d_dir        <= '0';
                     sl_io_ctrl.d_oe_n       <= '0';
                  END IF;
                  IF (dsan_in_reg = '0' OR dsbn_in_reg = '0') THEN   -- wait on new dsn for next burst transmission
                     sl_state                <= sl_vme_req;
                     sl_end                  <= '1';               -- used for incrementing adress
                  ELSE
                     sl_state                <= sl_got_dsn;
                     sl_end                  <= '0';
                  END IF;
                  request                    <= '0';
                  sl_en_vme_data_in_reg         <= '0';
                  sl_en_vme_data_in_reg_high    <= '0';
               ELSIF sl_acc(0) = '1' AND asn_in_reg = '0' THEN      -- d64 burst access
                  IF (dsan_in_reg = '0' OR dsbn_in_reg = '0') AND acknowledge = '1' THEN   -- wait on new dsn for next burst transmission
                     sl_state                   <= sl_vme_req;
                     sl_en_vme_data_in_reg      <= '1';               -- latch  next low d32
                     sl_en_vme_data_in_reg_high <= '0';
                     IF first_cycle = '1' THEN
                        sl_end               <= '0';               -- no increment, because first d64 is address cycle
                     ELSE
                        sl_end               <= '1';               -- used for incrementing adress
                     END IF;
                     IF wbm_we_o = '0' THEN 
                        sl_oe_vd             <= '1';
                        sl_oe_va             <= '1';
                        sl_io_ctrl.d_dir     <= '1';
                        sl_io_ctrl.d_oe_n    <= '0';
                        sl_io_ctrl.a_dir     <= '1';
                        sl_io_ctrl.a_oe_n    <= '0';           -- activate address lines for d64 read 
                     ELSE
                        sl_oe_vd             <= '0';
                        sl_oe_va             <= '0';
                        sl_io_ctrl.d_dir     <= '0';
                        sl_io_ctrl.d_oe_n    <= '0';
                        sl_io_ctrl.a_dir     <= '0';                                                   
                        sl_io_ctrl.a_oe_n    <= '0';           -- activate address lines for d64 write 
                     END IF;
                  ELSE
                     sl_state                <= sl_got_dsn;
                     sl_end                  <= '0';
                     IF wbm_we_o = '0' THEN 
                        sl_oe_vd             <= '1';
                        sl_oe_va             <= '1';
                        sl_io_ctrl.d_dir     <= '1';
                        sl_io_ctrl.d_oe_n    <= '0';
                        sl_io_ctrl.a_dir     <= '1';
                        sl_io_ctrl.a_oe_n    <= '0';           -- activate address lines for d64 read
                     ELSE
                        sl_oe_vd             <= '0';
                        sl_oe_va             <= '0';
                        sl_io_ctrl.d_dir     <= '0';
                        sl_io_ctrl.d_oe_n    <= '0';
                        sl_io_ctrl.a_dir     <= '0';
                        sl_io_ctrl.a_oe_n    <= '0';           -- activate address lines for d64 write
                     END IF;
                  END IF;
                  request                    <= '0';
               ELSE
                  sl_state                   <= sl_idle;
                  sl_end                     <= '1';
                  sl_io_ctrl.a_dir           <= '0';
                  sl_io_ctrl.a_oe_n          <= '0';
                  sl_oe_vd                   <= '0';
                  sl_oe_va                   <= '0';
                  sl_io_ctrl.d_dir           <= '0';
                  sl_io_ctrl.d_oe_n          <= '1';
                  request                    <= '0';
                  sl_en_vme_data_in_reg      <= '0';
                  sl_en_vme_data_in_reg_high <= '0';
               END IF;
               dtackn_out_reg                <= '1';
               first_cycle                   <= '0';
               sl_io_ctrl.am_dir             <= '0';
               sl_io_ctrl.am_oe_n            <= '0';
               
            WHEN OTHERS =>
               sl_state <= sl_idle;
               dtackn_out_reg                <= '1';
               request                       <= '0';
               sl_en_vme_data_in_reg         <= '0';
               sl_en_vme_data_in_reg_high    <= '0';
               sl_oe_vd                      <= '0';
               sl_oe_va                      <= '0';
               sl_io_ctrl.a_dir              <= '0';
               sl_io_ctrl.a_oe_n             <= '0';
               sl_io_ctrl.d_dir              <= '1';
               sl_io_ctrl.d_oe_n             <= '1';
               sl_end                        <= '0';
               first_cycle                   <= first_cycle;
               sl_io_ctrl.am_dir             <= '0';
               sl_io_ctrl.am_oe_n            <= '0';
              
         END CASE;
      END IF;
   END PROCESS sl_fsm;
   
END vme_slave_arch;
