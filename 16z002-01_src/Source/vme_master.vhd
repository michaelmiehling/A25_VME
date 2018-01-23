--------------------------------------------------------------------------------
-- Title         : VME Master
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : vme_master.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 15/12/16
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- The WBB2VME core supports several access types to the VMEbus. Dependent on 
-- the type of backplane connection, the data width can be chosen between D8/D16 
-- (one VME connector) and D32 (two VME connectors). D64 transfers are supported 
-- by the DMA, when two VME connectors are used.
-- The VMEbus is separated into several address spaces which can be accessed 
-- from the WBB2VME core: A16, A24 and A32 each separated in supervisory and 
-- non-privileged data/program. All supported address modifiers are in the 
-- following table:
-- VME Master Address Modifiers
-- Hex  543210 Function	                                       How to use
-- 0x3F HHHHHH A24 supervisory block transfer (BLT)            DMA access, configured in buffer descriptor, bits DMA_VME_AM
-- 0x3E HHHHHL A24 supervisory program access	               direct access via VME A24D16 or VME A24D32 windows, configured in register MSTR: A24_MODE
-- 0x3D HHHHLH A24 supervisory data access	                  direct access via VME A24D16 or VME A24D32 windows, configured in register MSTR: A24_MODE
-- 0x3B HHHLHH A24 non privileged block transfer (BLT)         DMA access, configured in buffer descriptor, bits DMA_VME_AM
-- 0x3A HHHLHL A24 non privileged program access	            direct access via VME A24D16 or VME A24D32 windows, configured in register MSTR: A24_MODE
-- 0x39 HHHLLH A24 non privileged data access	               direct access via VME A24D16 or VME A24D32 windows, configured in register MSTR: A24_MODE
-- 0x2D HLHHLH A16 supervisory access	                        direct access via VME A24D16 or VME A24D32 window, configured in register MSTR: A16_MODE
-- 0x2F HLHHHH A24 CR/CSR access                               direct access via VME A24D16 or VME A24D32 window, configured in register MSTR: CR_CSR_MODE
-- 0x29 HLHLLH A16 non-privileged access	                     direct access via VME A24D16 or VME A24D32 window, configured in register MSTR: A16_MODE
-- 0x0F LLHHHH A32 supervisory block transfer (BLT)	         DMA access, configured in buffer descriptor, bits DMA_VME_AM
-- 0x0E LLHHHL A32 supervisory program access	               direct access via VME A32 window, configured in register MSTR: A32_MODE
-- 0x0D LLHHLH A32 supervisory data access	                  direct access via VME A32 window, configured in register MSTR: A32_MODE
-- 0x0C LLHHLL A32 supervisory 64-bit block transfer (MBLT)	   DMA access, configured in buffer descriptor, bits DMA_VME_AM
-- 0x0B LLHLHH A32 non privileged block transfer (BLT)	      DMA access, configured in buffer descriptor, bits DMA_VME_AM
-- 0x0A LLHLHL A32 non privileged program access	            direct access via VME A32 window, configured in register MSTR: A32_MODE
-- 0x09 LLHLLH A32 non privileged data access	               direct access via VME A32 window, configured in register MSTR: A32_MODE
-- 0x08 LLHLLL A32 non privileged 64-bit block transfer (MBLT)	DMA access, configured in buffer descriptor, bits DMA_VME_AM
--
-- IF one of the VME Master windows is accessed by a read or write, the VME bus 
-- access will be requested on level 3. If the bus was granted by activation of 
-- the arbitration daisy chain input (signal vme_bg_i_n[3]), the VME master will
-- perform the access. 
-- The bus requester schemes ‘Release when done’ and ‘Release on request’ can be
-- selected (VMEbus Release Mechanism). The access type “Read-Modify-Write” can 
-- be selected by setting the bit Read-Modify-Write enable before the access. If
-- then the Read access to one VME master window gets performed, the bus will be 
-- blocked until the Write access follows. No other VME transmission by any 
-- other master can be performed between these two accesses!
-- The access type “Address Only” can be selected by setting the bit ADO before 
-- a byte or word read access follows. During this access, no data will be 
-- transmitted, but VMEbus participants can monitor (e.g. by the Location 
-- Monitor) the bus and can detect this message. No other access types are 
-- allowed if the ADO bit is set. 
-- All write accesses to the VME bus are handled as posted write.
---------------------------------------------------------------
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
---------------------------------------------------------------
-- $Revision: 1.2 $
--
-- $Log: vme_master.vhd,v $
-- Revision 1.2  2014/04/17 07:35:22  MMiehling
-- removed unused signals
-- bugfix MAIN_PR001486: longword read acccess to D16 space fails
--
-- Revision 1.1  2012/03/29 10:14:36  MMiehling
-- Initial Revision
--
-- Revision 1.8  2006/05/18 14:29:07  MMiehling
-- correct detection of berrn
--
-- Revision 1.7  2004/11/02 11:30:01  mmiehling
-- improved timing
--
-- Revision 1.6  2003/12/17 15:51:50  MMiehling
-- now berr-bit will be set only when direct access from pci, not from dma
--
-- Revision 1.5  2003/12/01 10:03:58  MMiehling
-- added d64
--
-- Revision 1.4  2003/06/24 13:47:13  MMiehling
-- added rst_aonly; changed soen_int
--
-- Revision 1.3  2003/06/13 10:06:40  MMiehling
-- improved timing
--
-- Revision 1.2  2003/04/02 16:11:33  MMiehling
-- Der Master funktioniert bis auf Bursts, A16-Zugriffe und Zugriffe auf ungerade A32 Basisadressen (z.B. 0x10000000)
--
-- Revision 1.1  2003/04/01 13:04:44  MMiehling
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.vme_pkg.all;

ENTITY vme_master IS
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

END vme_master;

ARCHITECTURE vme_master_arch OF vme_master IS

   TYPE   mstr_states IS (mstr_idle, req_bus, got_bus, set_adr, set_as, wait_on_dtackn, set_ds, got_low_d64, got_dtackn, data_stored, rmw_wait);
   SIGNAL    mstr_state : mstr_states;
   SIGNAL dtackn               : std_logic;
   SIGNAL dtackn_reg               : std_logic;
   SIGNAL berrn              : std_logic;
   SIGNAL berrn_reg         : std_logic;
   SIGNAL cnt               : std_logic_vector(1 DOWNTO 0);
   SIGNAL cnt_start         : std_logic;
   SIGNAL cnt_end            : std_logic;
   SIGNAL asn_regd            : std_logic;
   
   SIGNAL second_word_int      : std_logic;
   SIGNAL vam_oe_int            : std_logic;
   SIGNAL asn_out_int         : std_logic;
   SIGNAL soen_int            : std_logic;
   SIGNAL brel_int            : std_logic;
   SIGNAL wb_dma_acc_q            : std_logic;
   SIGNAL rst_rmw_int         : std_logic;
BEGIN
   brel <= brel_int;
   asn_out <= asn_out_int;
   vam_oe <= vam_oe_int;
   second_word <= second_word_int;
   rst_rmw <= '1' WHEN rst_rmw_int = '1' AND wb_dma_acc_q = '0' ELSE '0';
   
   test_c <= '1' WHEN mstr_state = set_ds ELSE '0';
   
-- synchronize dtackn and berrn:
  regdinp : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      dtackn <= '1';
      berrn  <= '1';
      berrn_reg <= '1';
      asn_regd <= '1';
      set_berr <= '0';
      rst_aonly <= '0';
      dtackn_reg <= '1';
      wb_dma_acc_q <= '0';
    ELSIF clk'event AND clk = '1' THEN
       IF mstr_state = mstr_idle THEN         -- keep information "dma- or normal-access" as long as access is ongoing
          wb_dma_acc_q <= wb_dma_acc;
       END IF;
      dtackn_reg <= dtackn_in;
      dtackn <= dtackn_reg;
      
      berrn  <= berrn_in;
      berrn_reg  <= berrn;
      asn_regd <= asn_in;   --to_x01(asn_in);
      IF mstr_state = set_as AND wb_dma_acc_q = '0' THEN
         rst_aonly <= '1';
      ELSE
         rst_aonly <= '0';
      END IF;
      IF berrn = '0' AND berrn_reg = '1' THEN   -- falling edge
         set_berr <= '1';
      ELSE
         set_berr <= '0';
      END IF;
    END IF;
  END PROCESS regdinp;
  
   ma_io_ctrl.d_oe_n  <= '0';                       
--   ma_io_ctrl.am_oe_n <= '0';                       
   ma_io_ctrl.a_oe_n  <= '0';                       

-------------------------------------------------------------------------------
   
mstr_fsm : PROCESS (clk, rst)
BEGIN
   IF rst = '1' THEN
      mstr_state                 <= mstr_idle;
      mstr_ack                   <= '0';
      second_word_int            <= '0';
      mstr_busy                  <= '0';
      vme_req                    <= '0';
      dwb                        <= '0';
      asn_out_int                <= '1';
      dsn_ena                    <= '0';
      brel_int                   <= '1';
      soen_int                   <= '1';
      ma_en_vme_data_in_reg      <= '0';
      rst_rmw_int                <= '0';
      vam_oe_int                 <= '0';--
      ma_en_vme_data_in_reg_high <= '0';
      ma_oe_vd                   <= '0';
      ma_oe_va                   <= '0';
      ma_io_ctrl.am_dir          <= '0';
      ma_io_ctrl.am_oe_n         <= '1';     -- inactive in reset
      ma_io_ctrl.a_dir           <= '0';
      ma_io_ctrl.d_dir           <= '0';
   ELSIF clk'EVENT AND clk = '1' THEN
      CASE mstr_state IS
         WHEN mstr_idle =>
            second_word_int            <= '0';
            mstr_ack                   <= '0';
            mstr_busy                  <= '0';
            vme_req                    <= '0';
            ma_io_ctrl.am_dir          <= '0';
            ma_io_ctrl.am_oe_n         <= '0';
            IF run_mstr = '1' THEN     
               mstr_state              <= req_bus;
            ELSE                       
               mstr_state              <= mstr_idle;
            END IF;                    
            IF run_mstr = '1' THEN     
               dwb                     <= '1';
               brel_int                <= '0';
            ELSE                       
               dwb                     <= '0';
               brel_int                <= '1';
            END IF;                    
            asn_out_int                <= '1';
            dsn_ena                    <= '0';
            ma_io_ctrl.a_dir           <= '0';
            ma_io_ctrl.d_dir           <= '0';
            ma_oe_vd                   <= '0';
            ma_oe_va                   <= '0';
            soen_int                   <= '1';
            ma_en_vme_data_in_reg      <= '0';
            rst_rmw_int                <= '0';
            vam_oe_int                 <= '0';
            ma_en_vme_data_in_reg_high <= '0';
   
         WHEN req_bus =>
            second_word_int            <= second_word_int;
            mstr_ack                   <= '0';
            IF dgb = '1' AND asn_regd = '1' AND dtackn = '1' AND berrn = '1' THEN  -- wait until last access is done
               mstr_state              <= got_bus;
               ma_io_ctrl.a_dir        <= '1';
               ma_io_ctrl.am_dir       <= '1';
               ma_io_ctrl.am_oe_n      <= '1';     -- switch of for dir change
               mstr_busy               <= '1';
               vme_req                 <= '1';
            ELSE
               mstr_state              <= req_bus;
               ma_io_ctrl.a_dir        <= '0';
               ma_io_ctrl.am_dir       <= '0';
               ma_io_ctrl.am_oe_n      <= '0';
               mstr_busy               <= '0';
               vme_req                 <= '0';
            END IF;
            dwb                        <= '1';
            asn_out_int                <= asn_out_int;--'1'
            dsn_ena                    <= '0';
            ma_io_ctrl.d_dir           <= '0';
            brel_int                   <= '0';
            ma_oe_vd                   <= '0';
            ma_oe_va                   <= '0';
            soen_int                   <= soen_int;--'1';
            ma_en_vme_data_in_reg      <= '0';
            rst_rmw_int                <= '0';
            vam_oe_int                 <= '0';
            ma_en_vme_data_in_reg_high <= '0';
               
         WHEN got_bus =>                  -- here start second cycles
            mstr_ack                   <= '0';
            mstr_busy                  <= '1';
            vme_req                    <= '1';
            second_word_int            <= second_word_int;
            IF dtackn = '1' AND berrn = '1' THEN   -- 25.04.06
               mstr_state              <= set_adr;
            ELSE                       
               mstr_state              <= got_bus;
            END IF;
            dwb                        <= '0';
            asn_out_int                <= asn_out_int;--'1'
            dsn_ena                    <= '0';
            IF d64 = '1' AND second_word_int = '1' AND wbs_we_i = '0' THEN    -- d64 read burst => address lines should be used as read data
               ma_io_ctrl.a_dir        <= '0';
               ma_oe_va                <= '0';
            ELSIF wbs_we_i = '0' THEN                    -- read 32bit
               ma_io_ctrl.d_dir        <= '0';
               ma_oe_va                <= '1';           -- 25.03.2014
            ELSE                                         -- write
               ma_io_ctrl.d_dir        <= '1';
               ma_oe_va                <= '1';
            END IF;
            ma_io_ctrl.am_dir          <= '1';
            ma_io_ctrl.am_oe_n         <= '0';     -- activate after dir change
            brel_int                   <= '0';
            ma_oe_vd                   <= '0';
            soen_int                   <= soen_int;--'1';
            ma_en_vme_data_in_reg      <= '0';
            rst_rmw_int                <= '0';
            vam_oe_int                 <= '1';
            ma_en_vme_data_in_reg_high <= '0';
            
         WHEN set_adr =>
            mstr_busy                  <= '1';
            vme_req                    <= '1';
            mstr_ack                   <= '0';
            second_word_int            <= second_word_int;
            IF wbs_we_i = '0' THEN
               ma_oe_vd             <= '0';
            ELSE
               ma_oe_vd             <= '1';
            END IF;
            IF berrn = '0' THEN
               mstr_state              <= mstr_idle;   -- error
               ma_io_ctrl.d_dir        <= '0';
               soen_int                <= soen_int;--'1';
            ELSIF cnt_end = '1' THEN 
               mstr_state              <= set_as;      -- for D32 and D16 burst , no additional states are required
               soen_int                <= '0';
               IF wbs_we_i = '0' THEN
                  ma_io_ctrl.d_dir     <= '0';
               ELSE
                  ma_io_ctrl.d_dir     <= '1';
               END IF;
            ELSE
               mstr_state              <= set_adr;
               IF wbs_we_i = '0' THEN
                  ma_oe_vd             <= '0';
               ELSE
                  ma_oe_vd             <= '1';
               END IF;
               soen_int                <= soen_int;--'1';
            END IF;
            asn_out_int                <= asn_out_int;--'1'
            dwb                        <= '0';
            dsn_ena                    <= '0';
            IF d64 = '1' AND second_word_int = '1' AND wbs_we_i = '0' THEN    -- d64 read burst => address lines should be used as read data
               ma_io_ctrl.a_dir        <= '0';
               ma_oe_va                <= '0';
            ELSE
               ma_io_ctrl.a_dir        <= '1';
               ma_oe_va                <= '1';
            END IF;
            ma_io_ctrl.am_dir          <= '1';
            ma_io_ctrl.am_oe_n         <= '0';
            brel_int                   <= '0';
            ma_en_vme_data_in_reg      <= '0';
            rst_rmw_int                <= '0';
            vam_oe_int                 <= '1';
            ma_en_vme_data_in_reg_high <= '0';
            
         WHEN set_as =>
            mstr_ack                   <= '0';
            mstr_busy                  <= '1';
            vme_req                    <= '1';
            second_word_int            <= second_word_int;
            IF berrn = '0' THEN
               mstr_state              <= mstr_idle;   -- error
            ELSIF mstr_reg(5) = '1' AND wb_dma_acc_q = '0' AND cnt_end = '1' THEN      -- ado-cycle
               mstr_state              <= got_dtackn;
            ELSIF cnt_end = '1' THEN
               mstr_state              <= set_ds;
            ELSE
               mstr_state              <= set_as;
            END IF;
            dwb                        <= '0';
            asn_out_int                <= '0';
            dsn_ena                    <= '0';
            IF d64 = '1' AND second_word_int = '1' AND wbs_we_i = '0' THEN    -- d64 read burst => address lines should be used as read data
               ma_io_ctrl.a_dir        <= '0';
               ma_oe_va                <= '0';
            ELSE
               ma_io_ctrl.d_dir        <= '1';
               ma_oe_va                <= '1';
            END IF;
            IF wbs_we_i = '0' THEN
               ma_io_ctrl.d_dir        <= '0';
               ma_oe_vd                <= '0';
            ELSE
               ma_io_ctrl.d_dir        <= '1';
               ma_oe_vd                <= '1';
            END IF;
            ma_io_ctrl.am_dir          <= '1';
            ma_io_ctrl.am_oe_n         <= '0';
            IF (((mstr_reg(0) = '1' AND wb_dma_acc_q = '0') OR mstr_cycle = '1') AND second_word_int = '0') OR asn_regd = '1' THEN
               brel_int                <= '0';
            ELSE
               brel_int                <= '1';
            END IF;
            soen_int                   <= '0';
            ma_en_vme_data_in_reg      <= '0';
            rst_rmw_int                <= '0';
            vam_oe_int                 <= '1';
            ma_en_vme_data_in_reg_high <= '0';
            
         WHEN set_ds =>
            mstr_ack                   <= '0';
            mstr_busy                  <= '1';
            vme_req                    <= '1';
            second_word_int            <= second_word_int;
            IF berrn = '0' THEN
               mstr_state              <= mstr_idle;
               ma_io_ctrl.a_dir        <= '0';
               asn_out_int             <= '1';
               dsn_ena                 <= '0';
               vam_oe_int              <= '0';
               ma_io_ctrl.am_dir       <= '0';
               ma_io_ctrl.am_oe_n      <= '1';  -- disable for dir switch
               ma_io_ctrl.d_dir        <= '0';
               ma_oe_vd                <= '0';
               ma_oe_va                <= '0';
            ELSIF dtackn = '0' AND wbs_we_i = '0' AND d64 = '1' AND second_word_int = '1' THEN
               mstr_state              <= got_low_d64;
               ma_io_ctrl.a_dir        <= '0';  -- address lines used for read data
               asn_out_int             <= '0';
               dsn_ena                 <= '1';
               vam_oe_int              <= '1';
               ma_io_ctrl.am_dir       <= '1';
               ma_io_ctrl.am_oe_n      <= '0';
               ma_io_ctrl.d_dir        <= '0';
               ma_oe_vd                <= '0';
               ma_oe_va                <= '0';  -- address lines used for read data
            ELSIF dtackn = '0' THEN
               mstr_state              <= got_dtackn;
               dsn_ena                 <= '0';
               ma_io_ctrl.a_dir        <= '1';
               asn_out_int             <= '0';
               ma_io_ctrl.am_dir       <= '1';
               ma_io_ctrl.am_oe_n      <= '0';  
               IF (mstr_reg(0) = '1' AND wb_dma_acc_q = '0' AND second_word_int = '0') OR burst = '1' THEN   --rmw ?
                  vam_oe_int           <= '1';
               ELSE
                  vam_oe_int           <= '1';--'0'
               END IF;
               if burst = '1' then
                 ma_oe_va              <= '1';
               else
                 ma_oe_va              <= '0';
               end if;
               ma_io_ctrl.d_dir        <= wbs_we_i;
               ma_oe_vd                <= '0';
            ELSE
               mstr_state              <= set_ds;
               IF wbs_we_i = '0' AND d64 = '1' AND second_word_int = '1' THEN
                  ma_io_ctrl.a_dir     <= '0';
                  ma_oe_va             <= '0';
               ELSE
                  ma_io_ctrl.a_dir     <= '1';
                  ma_oe_va             <= '1';
               END IF;
               asn_out_int             <= '0';
               dsn_ena                 <= '1';
               vam_oe_int              <= '1';
               ma_io_ctrl.am_dir       <= '1';
               ma_io_ctrl.am_oe_n      <= '0';
               IF wbs_we_i = '0' THEN
                  ma_io_ctrl.d_dir     <= '0';
                  ma_oe_vd             <= '0';
               ELSE
                  ma_io_ctrl.d_dir     <= '1';
                  ma_oe_vd             <= '1';
               END IF;
            END IF;
            dwb                        <= '0';
            IF (((mstr_reg(0) = '1' AND wb_dma_acc_q = '0') OR mstr_cycle = '1') AND second_word_int = '0') OR asn_regd = '1' THEN
               brel_int                <= '0';
            ELSE
               brel_int                <= '1';
            END IF;
            soen_int                   <= '0';
            IF dtackn = '0' AND wbs_we_i = '0' THEN
               ma_en_vme_data_in_reg   <= '0';-- '1'   stop sampling when got dtack
            ELSE
               ma_en_vme_data_in_reg   <= '1';-- '0'
            END IF;
            rst_rmw_int                <= '0';
            ma_en_vme_data_in_reg_high <= '0';
         
         WHEN got_low_d64 =>
            IF cnt_end = '1' THEN
               mstr_state              <= got_dtackn;
               ma_en_vme_data_in_reg_high <= '0';-- '1'   stop sampling when got dtack
            ELSE   
               mstr_state              <= got_low_d64;
               ma_en_vme_data_in_reg_high <= '1';-- '0'
            END IF;
            mstr_ack                   <= '0';
            mstr_busy                  <= '1';
            vme_req                    <= '1';
            second_word_int            <= second_word_int;
            ma_io_ctrl.a_dir           <= '0';
            ma_io_ctrl.d_dir           <= '0';
            asn_out_int                <= '0';
            dsn_ena                    <= '1';
            vam_oe_int                 <= '1';
            ma_io_ctrl.am_dir          <= '1';
            ma_io_ctrl.am_oe_n         <= '0';
            ma_oe_vd                   <= '0';
            ma_oe_va                   <= '0';
            dwb                        <= '0';
            brel_int                   <= '0';
            soen_int                   <= '0';
            rst_rmw_int                <= '0';
            
         WHEN got_dtackn =>
            mstr_busy                  <= '1';
            vme_req                    <= '1';
            mstr_ack                   <= '0';
            IF berrn = '0' THEN
               mstr_state              <= mstr_idle;   -- error
               second_word_int         <= '0'; --NOT second_word_int;
            ELSE
               mstr_state              <= data_stored;
               second_word_int         <= second_word_int;
            END IF;
            dwb                        <= '0';
            IF mstr_reg(0) = '1' AND wb_dma_acc_q = '0' AND second_word_int = '0' THEN -- rmw first phase?
               soen_int                <= '0';
               ma_io_ctrl.a_dir        <= '0';
               asn_out_int             <= '0';
               ma_io_ctrl.am_dir       <= '1';
               ma_io_ctrl.am_oe_n      <= '0'; 
               vam_oe_int              <= '1';
            ELSIF burst = '1' THEN
               soen_int                <= '0';
               ma_io_ctrl.a_dir        <= '1';
               asn_out_int             <= '0';
               ma_io_ctrl.am_dir       <= '1';
               ma_io_ctrl.am_oe_n      <= '0';
               vam_oe_int              <= '1';
            ELSE 
               soen_int                <= '1';
               ma_io_ctrl.a_dir        <= '1';
               asn_out_int             <= '1';
               ma_io_ctrl.am_dir       <= '0';
               ma_io_ctrl.am_oe_n      <= '1';     -- disable for dir switch
               vam_oe_int              <= '0';
            END IF;
            dsn_ena                    <= '0';
            ma_io_ctrl.d_dir           <= '0';
            ma_oe_vd                   <= '0';
            if burst = '1' then
              ma_oe_va                 <= '1';
            else
              ma_oe_va                 <= '0';
            end if;
            IF (((mstr_reg(0) = '1' AND wb_dma_acc_q = '0') OR mstr_cycle = '1') AND second_word_int = '0') OR asn_regd = '1' THEN
               brel_int                <= '0';
            ELSE
               brel_int                <= '1';
            END IF;
            ma_en_vme_data_in_reg      <= '0';
            rst_rmw_int                <= '0';
            ma_en_vme_data_in_reg_high <= '0';

         WHEN wait_on_dtackn =>
            if dtackn = '1' then
               mstr_state           <= set_ds;
            else
               mstr_state           <= wait_on_dtackn;
            end if;
            IF d64 = '0' AND second_word_int = '1' AND mstr_cycle = '1' THEN
               second_word_int      <= '0';
            ELSE
               second_word_int      <= second_word_int;
            END IF;
            asn_out_int             <= '0';
            mstr_ack                <= '0';  
            mstr_busy               <= '1';         
            vme_req                 <= '1';         
            vam_oe_int              <= '1';
            rst_rmw_int             <= '0';
            soen_int                <= '0';
            dwb                        <= '0';
            IF (((mstr_reg(0) = '1' AND wb_dma_acc_q = '0') OR mstr_cycle = '1') AND second_word_int = '0') OR burst = '1' THEN
               ma_io_ctrl.am_dir          <= '1';
               ma_io_ctrl.am_oe_n         <= '0';
            ELSE
               ma_io_ctrl.am_dir          <= '0';
               ma_io_ctrl.am_oe_n         <= '0';
            END IF;
            dsn_ena                    <= '0';
            IF d64 = '1' AND second_word_int = '0' AND wbs_we_i = '0' THEN    -- d64 read burst => address lines should be used as read data
               ma_io_ctrl.a_dir        <= '0';
            ELSE
               ma_io_ctrl.a_dir        <= '1';
            END IF;
            ma_io_ctrl.d_dir           <= '0';
            ma_oe_vd                   <= '0';
            if burst = '1' then
              ma_oe_va                 <= '1';
            else
              ma_oe_va                 <= '0';
            end if;
            IF (((mstr_reg(0) = '1' AND wb_dma_acc_q = '0') OR mstr_cycle = '1') AND second_word_int = '0') OR asn_regd = '1' THEN
               brel_int                <= '0';
            ELSE
               brel_int                <= '1';
            END IF;
            ma_en_vme_data_in_reg      <= '0';
            ma_en_vme_data_in_reg_high <= '0';
               
               
         WHEN data_stored =>
            IF berrn = '0' THEN
               mstr_state              <= mstr_idle;
               asn_out_int             <= '1';
               mstr_ack                <= '1';
               mstr_busy               <= '0';         
               vme_req                 <= '0';         
               second_word_int         <= '0';
               vam_oe_int              <= '0';
               rst_rmw_int             <= '0';
               soen_int                <= '1';
            ELSIF burst = '1' AND run_mstr = '1' THEN
               IF wbs_we_i = '0' AND d64 = '1' and dtackn = '1' THEN
                  mstr_state           <= set_ds;
               ELSIF wbs_we_i = '0' AND d64 = '1' and dtackn = '0' THEN
                  mstr_state           <= wait_on_dtackn;
               ELSE
                  mstr_state           <= got_bus;
               END IF;
               IF d64 = '0' AND second_word_int = '1' AND mstr_cycle = '1' THEN
                  second_word_int      <= '0';
               ELSE
                  second_word_int      <= second_word_int;
               END IF;
               asn_out_int             <= '0';
               mstr_ack                <= '1';   -- ack imediately next data
               mstr_busy               <= '1';
               vme_req                 <= '1';         
               vam_oe_int              <= '1';
               rst_rmw_int             <= '0';
               soen_int                <= '0';
            ELSIF burst = '1' AND d64 = '1' AND second_word_int = '0' THEN      -- was this first cycle of D64?
               mstr_state              <= got_bus;   -- then transmit data of D64
               asn_out_int             <= '0';
               mstr_ack                <= '0';      -- no ack, because first D64 cycle transmits only addresses
               mstr_busy               <= '0';         
               vme_req                 <= '0';         
               second_word_int         <= '1';      -- now all data transfers
               vam_oe_int              <= '1';
               rst_rmw_int             <= '0';
               soen_int                <= '0';
            ELSIF burst = '1' AND d64 = '0' AND second_word_int = '0' AND mstr_cycle = '1' THEN      -- was this first cycle of D16?
               mstr_state              <= got_bus;   -- then transmit second word
               asn_out_int             <= '0';
               mstr_ack                <= '0';      -- no ack, because first D16 cycle transmits only low word
               mstr_busy               <= '0';
               vme_req                 <= '1';         
               second_word_int         <= '1';
               vam_oe_int              <= '1';
               rst_rmw_int             <= '0';
               soen_int                <= '0';
            ELSIF burst = '1' AND d64 = '0' AND second_word_int = '1' AND mstr_cycle = '1' THEN      -- was this second cycle of D16?
               mstr_state              <= data_stored;   -- wait for run-mstr
               asn_out_int             <= '0';
               mstr_ack                <= '1';      -- ack 4 byte
               mstr_busy               <= '0';
               vme_req                 <= '1';         
               second_word_int         <= '1';   
               vam_oe_int              <= '1';
               rst_rmw_int             <= '0';
               soen_int                <= '0';
            ELSIF burst = '1' THEN
               mstr_state              <= data_stored;
               asn_out_int             <= '0';
               mstr_ack                <= '1';
               mstr_busy               <= '0';
               if d64 = '1' then
                 vme_req               <= '0';
               else
                 vme_req               <= '1'; -- keep the bus for the whole BLT transfer
               end if;
               second_word_int         <= second_word_int;
               vam_oe_int              <= '1';
               rst_rmw_int             <= '0';
               soen_int                <= '0';
            ELSIF mstr_cycle = '1' AND second_word_int = '0' THEN      -- run second time for long on D16 transmission
               mstr_state              <= got_bus;
               asn_out_int             <= '1';
               mstr_ack                <= '0';
               mstr_busy               <= '1';         
               vme_req                 <= '1';         
               second_word_int         <= '1';
               vam_oe_int              <= '0';
               rst_rmw_int             <= '0';
               soen_int                <= '1';
            ELSIF mstr_reg(0) = '1' AND wb_dma_acc_q = '0' AND second_word_int = '0' THEN   -- rmw cycle ?
               mstr_state              <= rmw_wait;
               asn_out_int             <= '0';
               mstr_ack                <= '1';   -- ack read of rmw
               mstr_busy               <= '0';         
               vme_req                 <= '0';         
               second_word_int         <= '1';
               vam_oe_int              <= '1';
               rst_rmw_int             <= '0';
               soen_int                <= '0';
            ELSE
               mstr_state              <= mstr_idle;
               asn_out_int             <= '1';
               mstr_ack                <= '1';
               mstr_busy               <= '0';         
               vme_req                 <= '0';         
               second_word_int         <= '0';
               vam_oe_int              <= '0';
               rst_rmw_int             <= '1';
               soen_int                <= '1';
            END IF;
            dwb                        <= '0';
            IF (((mstr_reg(0) = '1' AND wb_dma_acc_q = '0') OR mstr_cycle = '1') AND second_word_int = '0') OR burst = '1' THEN
               ma_io_ctrl.am_dir          <= '1';
               ma_io_ctrl.am_oe_n         <= '0';
            ELSE
               ma_io_ctrl.am_dir          <= '0';
               ma_io_ctrl.am_oe_n         <= '0';
            END IF;
            dsn_ena                    <= '0';
            IF d64 = '1' AND second_word_int = '0' AND wbs_we_i = '0' THEN    -- d64 read burst => address lines should be used as read data
               ma_io_ctrl.a_dir        <= '0';
            ELSE
               ma_io_ctrl.a_dir        <= '1';
            END IF;
            ma_io_ctrl.d_dir           <= '0';
            ma_oe_vd                   <= '0';
            if burst = '1' then
              ma_oe_va                 <= '1';
            else
              ma_oe_va                 <= '0';
            end if;
            IF (((mstr_reg(0) = '1' AND wb_dma_acc_q = '0') OR mstr_cycle = '1') AND second_word_int = '0') OR asn_regd = '1' THEN
               brel_int                <= '0';
            ELSE
               brel_int                <= '1';
            END IF;
            ma_en_vme_data_in_reg      <= '0';
            ma_en_vme_data_in_reg_high <= '0';
            
         WHEN rmw_wait =>
            mstr_ack                   <= '0';
            mstr_busy                  <= '1';
            vme_req                    <= '1';
            second_word_int            <= second_word_int;
            IF berrn = '0' THEN
               mstr_state              <= mstr_idle;
            ELSIF run_mstr = '1' THEN
                 mstr_state            <= got_bus;
            ELSE
               mstr_state              <= rmw_wait;
            END IF;
            dwb                        <= '0';
            asn_out_int                <= '0';
            dsn_ena                    <= '0';
            ma_io_ctrl.a_dir           <= '0';
            ma_io_ctrl.d_dir           <= '0';
            ma_io_ctrl.am_dir          <= '1';
            ma_io_ctrl.am_oe_n         <= '0';
            brel_int                   <= '0';
            ma_oe_vd                   <= '0';
            ma_oe_va                   <= '0';
            soen_int                   <= '0';
            ma_en_vme_data_in_reg      <= '0';
            rst_rmw_int                <= '0';
            vam_oe_int                 <= '1';
            ma_en_vme_data_in_reg_high <= '0';
            
         WHEN OTHERS =>
            mstr_ack                   <= '0';
            mstr_busy                  <= '0';
            vme_req                    <= '0';
            second_word_int            <= '0';
            mstr_state                 <= mstr_idle;           
            dwb                        <= '0';
            asn_out_int                <= '1';
            dsn_ena                    <= '0';
            ma_io_ctrl.a_dir           <= '0';
            ma_io_ctrl.d_dir           <= '0';
            ma_io_ctrl.am_dir          <= '0';
            ma_io_ctrl.am_oe_n         <= '0';
            brel_int                   <= '1';
            ma_oe_vd                   <= '0';
            ma_oe_va                   <= '0';
            soen_int                   <= '1';
            ma_en_vme_data_in_reg      <= '0';
            rst_rmw_int                <= '0';
            vam_oe_int                 <= '0';
            ma_en_vme_data_in_reg_high <= '0';
      END CASE;
   END IF;
END PROCESS mstr_fsm;
  
mstr_out : PROCESS (mstr_state, dtackn, mstr_cycle, wbs_we_i, d64, second_word_int)
  BEGIN
     CASE mstr_state IS
        WHEN mstr_idle =>
         cnt_start <= '0';

      WHEN req_bus =>
         cnt_start <= '0';

      WHEN got_bus =>
         cnt_start <= '1';

      WHEN set_adr =>
         cnt_start <= '1';

      WHEN set_as =>
         cnt_start <= '0';

      WHEN set_ds =>
         IF dtackn = '0' AND wbs_we_i = '0' AND d64 = '1' AND second_word_int = '1' THEN
            cnt_start <= '1';
         ELSE
            cnt_start <= '0';
         END IF;
      
      WHEN got_low_d64 =>
         cnt_start <= '0';

      WHEN got_dtackn =>
         cnt_start <= '0';

      WHEN data_stored =>
         cnt_start <= '0';

      WHEN rmw_wait =>
         cnt_start <= '0';

        WHEN OTHERS =>
          cnt_start <= '0';
     END CASE;
  END PROCESS mstr_out;


cnt_p : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
        cnt <= (OTHERS => '0');
     ELSIF clk'EVENT AND clk = '1' THEN
        IF cnt /= "00" THEN
           cnt <= cnt - 1;
        ELSIF cnt_start = '1' THEN
           cnt <= "10";
      END IF;
   END IF;
  END PROCESS cnt_p;

   cnt_end <= '1' WHEN cnt = "00" ELSE '0';

END vme_master_arch;
