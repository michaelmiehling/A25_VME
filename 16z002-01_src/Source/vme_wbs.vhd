--------------------------------------------------------------------------------
-- Title         : Wishbone Slave Interface
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : vme_wbs.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 13/01/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- The receives wishbone read/write requests either to internal registers or to 
-- VME space. Depending on the signal wbs_tga, the corresponding space will be
-- accessed by forwarding the access to vme_master/wbs_du/wbs_au. The module 
-- vme_master is connected via handshake signals and performs the access to the 
-- vme space depending on the tga settings.
--
-- +-Module Name-----------------+----------vme_acc_type-------------+-----size-+
-- +-----------------------------+----tga-dma------+---tga-pci-------+----------+
-- +-----------------------------+ M D R S B D  A  | M D R S B D  A  +----------+
-- |16z002-01 VME                |                 | x 0 1 x x xx xx |   800000 |
-- |16z002-01 VME IACK           |                 | x 0 1 x x xx 11 |       10 |
-- |16z002-01 VME A16D16         |                 | x 0 0 0 0 00 10 |    10000 |
-- |16z002-01 VME A16D32         |                 | x 0 0 0 0 01 10 |    10000 |
-- |16z002-01 VME A24D16         | m 1 0 0 x 00 00 | x 0 0 0 0 00 00 |  1000000 |
-- |16z002-01 VME A24D32         | m 1 0 0 x 01 00 | x 0 0 0 0 01 00 |  1000000 |
-- |16z002-01 VME A32D32         | m 1 0 0 x 01 01 | x 0 0 0 0 01 01 | 20000000 |
-- |16z002-01 VME CR/CSR         |                 | x 0 0 0 0 10 00 |  1000000 |
-- |16z002-01 VME A32D64         | m 1 0 0 x 11 01 |                 |          |
-- |16z002-01 VME A16D16 swapped |                 | x 0 0 1 0 00 10 |    10000 |
-- |16z002-01 VME A16D32 swapped |                 | x 0 0 1 0 01 10 |    10000 |
-- |16z002-01 VME A24D16 swapped | m 1 0 1 x 00 00 | x 0 0 1 0 00 00 |  1000000 |
-- |16z002-01 VME A24D32 swapped | m 1 0 1 x 01 00 | x 0 0 1 0 01 00 |  1000000 |
-- |16z002-01 VME A32D32 swapped | m 1 0 1 x 01 01 | x 0 0 1 0 01 01 | 20000000 |
-- |16z002-01 VME A32D64 swapped | m 1 0 1 x 11 01 |                 |          |
-- +-----------------------------+-----------------+-----------------+----------+
-- D - DMA Access
-- R - Register Access
-- S - Swapped Access
-- B - Burst Access
-- D - Data Width (00=D16, 01=D32, 11=D64, 10=CR/CSR)
-- A - Address Width (10=A16, 00=A24, 01=A32, 11=IACK)
-- M - Address Space (0=non-privileged 1=supervisory data)

--------------------------------------------------------------------------------
-- Hierarchy:
--
-- wbb2vme
--    vme_ctrl
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
-- Revision 1.5  2017 07:00:00  mmiehling
-- changed vme_acc_type/tga setting for CR/CSR and D32 to be compliant to DMA configuration bits
--
-- Revision 1.4  2013/09/12 08:45:21  mmiehling
-- added bit 8 of tga for address modifier extension (supervisory, non-privileged data/program)
--
-- Revision 1.2  2012/08/27 12:57:02  MMiehling
-- wbb compliant: activate wbs_ack in case of vme buserror additional to wbs_err signal in order not to block the pci bus
--
-- Revision 1.1  2012/03/29 10:14:28  MMiehling
-- Initial Revision
--
-- Revision 1.8  2006/05/18 14:28:54  MMiehling
-- read and write accesses after a bus-error are wrong => bugfix
--
-- Revision 1.7  2004/11/02 11:29:42  mmiehling
-- changed dma-type signaling to tga
--
-- Revision 1.6  2004/07/27 17:15:28  mmiehling
-- changed pci-core to 16z014
-- changed wishbone bus to wb_bus.vhd
-- added clk_trans_wb2wb.vhd
-- improved dma
--
-- Revision 1.5  2003/12/01 10:03:29  MMiehling
-- changed all
--
-- Revision 1.4  2003/06/24 13:46:49  MMiehling
-- removed burst; changed comments
--
-- Revision 1.3  2003/06/13 10:06:18  MMiehling
-- improved timing
--
-- Revision 1.2  2003/04/02 16:11:27  MMiehling
-- verbessertes max. Frequenz
--
-- Revision 1.1  2003/04/01 13:04:28  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY vme_wbs IS
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
                              
   vme_acc_type               : OUT std_logic_vector(6 DOWNTO 0);   -- signal indicates the type of VME access
                              
   run_mstr                   : OUT std_logic;                     -- starts vme master
   mstr_ack                   : IN std_logic;         -- this pulse indicates the end of Master transaction
   mstr_busy                  : IN std_logic;                     -- if master is busy => 1
   burst                      : OUT std_logic;                     -- indicates a burst transfer from dma to vme
                              
   sel_loc_data_out           : OUT std_logic_vector(1 DOWNTO 0)   -- mux select signal for 0=reg, 1=vme data_out

     );
END vme_wbs;

ARCHITECTURE vme_wbs_arch OF vme_wbs IS 
   TYPE   mensb_states IS (mensb_idle, mensb_write_regs, mensb_read_regs, mensb_read_regs2, mensb_read_regs_perf, mensb_vme_req, mensb_vme, mensb_vme_d64, mensb_vme_end);
   SIGNAL    mensb_state : mensb_states;
   
   SIGNAL vme_acc_type_l   : std_logic_vector(8 DOWNTO 0);
   SIGNAL vme_acc_type_q   : std_logic_vector(8 DOWNTO 0);
   SIGNAL wbs_ack_o_int      : std_logic;
BEGIN
   vme_acc_type <= vme_acc_type_q(8) & vme_acc_type_q(5 DOWNTO 0);
   wbs_ack_o <= wbs_ack_o_int;
   wbs_sel_int <= wbs_sel_i;
   wb_dma_acc <= wbs_tga_i(7) AND wbs_cyc_i;
      
   vme_acc_type_l <= wbs_tga_i WHEN wbs_cyc_i = '1' ELSE (OTHERS => '0');
--   vme_acc_type_l <= wbs_tga_i(7 DOWNTO 6) & '1' & wbs_tga_i(4 DOWNTO 0) WHEN wbs_cyc_i = '1' ELSE (OTHERS => '0');
   
regs : PROCESS(clk, rst)
BEGIN
   IF rst = '1' THEN
      vme_acc_type_q <= (OTHERS => '0');
      sel_loc_data_out(0) <= '1';         
      burst <= '0'; 
   ELSIF clk'EVENT AND clk = '1' THEN
      vme_acc_type_q <= vme_acc_type_l;
      sel_loc_data_out(0) <= NOT vme_acc_type_l(6);
      IF wbs_cyc_i = '1' AND wbs_tga_i(4) = '1' THEN 
         burst <= '1';                 -- set if burst on vme is requested   
      ELSE
         burst <= '0';  
      END IF;
   END IF;
END PROCESS regs;

     
mensb_fsm : PROCESS (clk, rst)
  BEGIN
   IF rst = '1' THEN
      mensb_state <= mensb_idle;
      loc_write_flag <= '0';
      run_mstr <= '0';
      wbs_ack_o_int <= '0';
      wbs_err_o <= '0';
      sel_loc_data_out(1) <= '0';
   
     ELSIF clk'EVENT AND clk = '1' THEN
        CASE mensb_state IS
           WHEN mensb_idle =>
               sel_loc_data_out(1) <= '0';
               IF wbs_stb_i = '1' AND vme_acc_type_l(6) = '1' AND wbs_we_i = '1' AND mensb_active = '1' THEN
                  wbs_ack_o_int <= '1';
                  wbs_err_o <= '0';
                  run_mstr <= '0';
                  loc_write_flag <= '1';
                  mensb_state <= mensb_vme_end;
               ELSIF wbs_stb_i = '1' AND vme_acc_type_l(6) = '1' AND wbs_we_i = '0' AND mensb_active = '1' THEN
                  wbs_ack_o_int <= '0';
                  wbs_err_o <= '0';
                  run_mstr <= '0';
                  loc_write_flag <= '0';
                  mensb_state <= mensb_read_regs;
               ELSIF wbs_stb_i = '1' AND vme_acc_type_q(6) = '0' AND mstr_busy = '0' THEN -- general vme access
                  wbs_ack_o_int <= '0';
                  wbs_err_o <= '0';
                  run_mstr <= '1';
                  loc_write_flag <= '0';
                  mensb_state <= mensb_vme_req;
               ELSIF wbs_stb_i = '1' AND vme_acc_type_q(6) = '0' AND mstr_busy = '1' THEN -- rmw or burst vme access
                  wbs_ack_o_int <= '0';
                  wbs_err_o <= '0';
                  run_mstr <= '1';
                  loc_write_flag <= '0';
                  mensb_state <= mensb_vme;
               ELSE
                  wbs_ack_o_int <= '0';
                  wbs_err_o <= '0';
                  run_mstr <= '0';
                  loc_write_flag <= '0';
                  mensb_state <= mensb_idle;
               END IF;
              
           WHEN mensb_read_regs =>
               sel_loc_data_out(1) <= '0';
               wbs_ack_o_int <= '0';
               wbs_err_o <= '0';
               run_mstr <= '0';
               loc_write_flag <= '0';
               mensb_state <= mensb_read_regs2; 
           
           WHEN mensb_read_regs2 =>
               sel_loc_data_out(1) <= '0';
               wbs_ack_o_int <= '1';
               wbs_err_o <= '0';
               run_mstr <= '0';
               loc_write_flag <= '0';
               mensb_state <= mensb_vme_end; 
           
            WHEN mensb_vme_req =>                     -- wait until master has got internal register control, then latch data
               sel_loc_data_out(1) <= '0';
               run_mstr <= '0';
               loc_write_flag <= '0';
               IF mstr_busy = '1' AND vme_acc_type_l(3 DOWNTO 2) = "11" AND wbs_we_i = '1' THEN
                  mensb_state <= mensb_vme;
                  wbs_ack_o_int <= '1';               -- acknoledge low d64 write
                  wbs_err_o <= '0';
               ELSIF mstr_busy = '1' THEN
                  mensb_state <= mensb_vme;
                  wbs_ack_o_int <= '0';
                  wbs_err_o <= '0';
               ELSE
                  mensb_state <= mensb_vme_req;
                  wbs_ack_o_int <= '0';
                  wbs_err_o <= '0';
               END IF;
              
            WHEN mensb_vme =>                           -- vme-mstr is working, wait for mstr_ack
               sel_loc_data_out(1) <= '0';
               run_mstr <= '0';
               loc_write_flag <= '0';
               IF set_berr = '1' THEN
                  mensb_state <= mensb_vme_end;
                  wbs_ack_o_int <= '1';                -- also ack for termination of wbb access
                  wbs_err_o <= '1';                     -- error
               ELSIF mstr_ack = '1' AND vme_acc_type_l(3 DOWNTO 2) = "11" AND wbs_we_i = '0' THEN
                  mensb_state <= mensb_vme_d64;
                  wbs_ack_o_int <= '1';
                  wbs_err_o <= '0';
               ELSIF mstr_ack = '1' THEN
                  mensb_state <= mensb_vme_end;
                  wbs_ack_o_int <= '1';
                  wbs_err_o <= '0';
               ELSE
                  mensb_state <= mensb_vme;
                  wbs_ack_o_int <= '0';
                  wbs_err_o <= '0';
               END IF;
              
            WHEN mensb_vme_d64 =>
               sel_loc_data_out(1) <= '1';
               run_mstr <= '0';
               loc_write_flag <= '0';
               IF wbs_stb_i = '1' AND wbs_ack_o_int = '0' THEN
                  wbs_ack_o_int <= '1';
                  wbs_err_o <= '0';
                  mensb_state <= mensb_vme_end;
               ELSE
                  wbs_ack_o_int <= '0';
                  wbs_err_o <= '0';
                  mensb_state <= mensb_vme_d64;
               END IF;
         
            WHEN mensb_vme_end =>                     -- wait on end of this wb-cycle
               sel_loc_data_out(1) <= '0';
               wbs_ack_o_int <= '0';
               wbs_err_o <= '0';
               run_mstr <= '0';
               loc_write_flag <= '0';
               mensb_state <= mensb_idle;

            WHEN OTHERS =>
               sel_loc_data_out(1) <= '0';
               wbs_ack_o_int <= '0';
               wbs_err_o <= '0';
               run_mstr <= '0';
               loc_write_flag <= '0';
               mensb_state <= mensb_idle;
        END CASE;
     END IF;
  END PROCESS mensb_fsm;
  
mensb_out : PROCESS (mensb_state, mensb_active, wbs_stb_i, vme_acc_type_q, mstr_busy, set_berr)
  BEGIN
     CASE mensb_state IS
        WHEN mensb_idle =>
         ma_en_vme_data_out_reg_high <= '0';
         IF wbs_stb_i = '1' AND vme_acc_type_q(6) = '1' AND mensb_active = '0' THEN -- register access
            mensb_req <= '1';
            ma_en_vme_data_out_reg <= '0';
         ELSIF wbs_stb_i = '1' AND vme_acc_type_q(6) = '0' AND mstr_busy = '1' THEN -- rmw vme access
            mensb_req <= '0';
            ma_en_vme_data_out_reg <= '1';
         ELSE
            mensb_req <= '0';
            ma_en_vme_data_out_reg <= '0';
         END IF;

      WHEN mensb_read_regs =>
         mensb_req <= '1';
         ma_en_vme_data_out_reg <= '0';
         ma_en_vme_data_out_reg_high <= '0';
      
      WHEN mensb_read_regs2 =>
         mensb_req <= '1';
         ma_en_vme_data_out_reg <= '0';
         ma_en_vme_data_out_reg_high <= '0';
      
      WHEN mensb_vme_req =>
         mensb_req <= '0';
         ma_en_vme_data_out_reg_high <= '0';
         IF mstr_busy = '1' OR set_berr = '1' THEN
            ma_en_vme_data_out_reg <= '1';
         ELSE
            ma_en_vme_data_out_reg <= '0';
         END IF;
      
      WHEN mensb_vme =>
         mensb_req <= '0';
         ma_en_vme_data_out_reg <= '0';
         ma_en_vme_data_out_reg_high <= '1';

      WHEN mensb_vme_d64 =>
         mensb_req <= '0';
         ma_en_vme_data_out_reg <= '0';
         ma_en_vme_data_out_reg_high <= '1';

      WHEN mensb_vme_end =>
         mensb_req <= '0';
         ma_en_vme_data_out_reg <= '0';
         ma_en_vme_data_out_reg_high <= '0';
         
        WHEN OTHERS =>
         mensb_req <= '0';
         ma_en_vme_data_out_reg <= '0';
         ma_en_vme_data_out_reg_high <= '0';
        
     END CASE;
  END PROCESS mensb_out;

END vme_wbs_arch;
