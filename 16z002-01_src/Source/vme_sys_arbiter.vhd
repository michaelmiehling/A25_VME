--------------------------------------------------------------------------------
-- Title         : sys_arbiter for mensb or vme accesses
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : vme_sys_arbiter.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 13/01/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- This module arbitrates the wbb or vmebus accesses.
-- The modules vme_master or vme_slave can generate a request
-- signal. If there is no current transmission, the vme_sys_arbiter
-- activates the corresponding acknoledge signal. This signal
-- is active until the request is deasserted. If other requests
-- are asserted during this time, they have to wait until the 
-- ongoing one is finished.
--------------------------------------------------------------------------------
-- Hierarchy:
--
-- vme_ctrl
--   vme_sys_arbiter
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
-- $Revision: 1.3 $
--
-- $Log: vme_sys_arbiter.vhd,v $
-- Revision 1.3  2014/04/17 07:35:20  MMiehling
-- removed unused signals
--
-- Revision 1.2  2012/08/27 12:57:07  MMiehling
-- added second_word for d64 slave access
--
-- Revision 1.1  2012/03/29 10:14:31  MMiehling
-- Initial Revision
--
-- Revision 1.3  2003/12/01 10:03:40  MMiehling
-- added d64
--
-- Revision 1.2  2003/07/14 08:38:00  MMiehling
-- lword was missing
--
-- Revision 1.1  2003/04/01 13:04:35  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.vme_pkg.ALL;

ENTITY vme_sys_arbiter IS
PORT (
   clk                           : IN std_logic;                -- 66 MHz
   rst                           : IN std_logic;                -- global reset signal (asynch)
                                 
   io_ctrl                       : OUT io_ctrl_type;              
   ma_io_ctrl                    : IN io_ctrl_type;              
   sl_io_ctrl                    : IN io_ctrl_type;              
                                 
   mensb_req                     : IN std_logic;               -- request signal for mensb slave access
   slave_req                     : IN std_logic;               -- request signal for slave access
   mstr_busy                     : IN std_logic;               -- master busy
                                 
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
   
   ma_en_vme_data_out_reg        : IN std_logic;   
   sl_en_vme_data_out_reg        : IN std_logic;   
   reg_en_vme_data_out_reg       : IN std_logic;   
   en_vme_data_out_reg           : OUT std_logic;   
   
   ma_en_vme_data_out_reg_high   : IN std_logic;   
   sl_en_vme_data_out_reg_high   : IN std_logic;   
   en_vme_data_out_reg_high      : OUT std_logic;   

   swap                          : OUT std_logic;            -- swapping of data bytes on/off
   ma_swap                       : IN std_logic;
                                 
   sl_d64                        : IN std_logic;      
   ma_d64                        : IN std_logic;      
   d64                           : OUT std_logic;            -- indicates d64 master access
   
   ma_second_word                : IN std_logic;            -- differs between address and data phase in d64
   sl_second_word                : IN std_logic;            -- differs between address and data phase in d64
   second_word                   : OUT std_logic;           -- differs between address and data phase in d64

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
END vme_sys_arbiter;

ARCHITECTURE vme_sys_arbiter_arch OF vme_sys_arbiter IS 
   TYPE   arbit_states IS (arbit_mensb, arbit_vme);
   SIGNAL    arbit_state : arbit_states;
   SIGNAL mensb_active_int      : std_logic;
   SIGNAL en_vme_data_in_reg_int   : std_logic;
BEGIN
   io_ctrl                    <= ma_io_ctrl                    WHEN mstr_busy = '1' ELSE sl_io_ctrl;

   second_word                <= ma_second_word                WHEN mstr_busy = '1' ELSE sl_second_word;
   en_vme_data_out_reg        <= ma_en_vme_data_out_reg        WHEN mstr_busy = '1' ELSE sl_en_vme_data_out_reg OR reg_en_vme_data_out_reg;
   en_vme_data_in_reg         <= ma_en_vme_data_in_reg         WHEN mstr_busy = '1' ELSE sl_en_vme_data_in_reg;
   en_vme_data_in_reg_high    <= ma_en_vme_data_in_reg_high    WHEN mstr_busy = '1' ELSE sl_en_vme_data_in_reg_high;
   sel_vme_data_out           <= "01"                          WHEN mstr_busy = '1' ELSE sl_sel_vme_data_out;
   vme_adr_locmon             <= vme_adr_out                   WHEN mstr_busy = '1' ELSE vme_adr_in_reg;
   d64                        <= ma_d64                        WHEN mstr_busy = '1' ELSE sl_d64;
   en_vme_data_out_reg_high   <= ma_en_vme_data_out_reg_high   WHEN mstr_busy = '1' ELSE sl_en_vme_data_out_reg_high;
   byte_routing               <= ma_byte_routing               WHEN mstr_busy = '1' ELSE sl_byte_routing;
--   en_vme_data_in_reg <= en_vme_data_in_reg_int;

   mensb_active <= mensb_active_int;
   write_flag <= loc_write_flag WHEN mensb_active_int = '1' ELSE sl_write_flag;

reg : PROCESS(clk, rst)
BEGIN
   IF rst = '1' THEN
--      byte_routing <= '0';
      oe_vd <= '0';
      oe_va <= '0';
--      en_vme_data_in_reg_int <= '0';
      lwordn <= '0';
      swap <= '1';
   ELSIF clk'EVENT AND clk = '1' THEN
      IF mstr_busy = '1' THEN
         swap <= ma_swap;
--         byte_routing <= ma_byte_routing;
         oe_vd <= ma_oe_vd;
         oe_va <= ma_oe_va;
--         en_vme_data_in_reg_int <= ma_en_vme_data_in_reg;
--         en_vme_data_in_reg_high <= ma_en_vme_data_in_reg_high;
         lwordn <= lwordn_mstr;
      ELSE
         swap <= '1';   -- slave swapps always
--         byte_routing <= sl_byte_routing;
         oe_va <= sl_oe_va;
         oe_vd <= sl_oe_vd;
--         en_vme_data_in_reg_int <= sl_en_vme_data_in_reg;
--         en_vme_data_in_reg_high <= sl_en_vme_data_in_reg_high;
         lwordn <= lwordn_slv;
      END IF;
   END IF;
END PROCESS reg;   
   
arbit_fsm : PROCESS (clk, rst)
BEGIN
   IF rst = '1' THEN
      arbit_state <= arbit_mensb;
      mensb_active_int <= '1';
      slave_active <= '0';
   ELSIF clk'EVENT AND clk = '1' THEN
      CASE arbit_state IS
         WHEN arbit_mensb =>
            IF slave_req = '1' AND mensb_req = '0' THEN
               arbit_state <= arbit_vme;
               mensb_active_int <= '0';
               slave_active <= '1';
            ELSE
               arbit_state <= arbit_mensb;
               mensb_active_int <= '1';
               slave_active <= '0';
            END IF;
              
         WHEN arbit_vme =>
            IF slave_req = '0' THEN
               arbit_state <= arbit_mensb;
               mensb_active_int <= '1';
               slave_active <= '0';
            ELSE
               arbit_state <= arbit_vme;
               mensb_active_int <= '0';
               slave_active <= '1';
            END IF;
         WHEN OTHERS =>
            arbit_state <= arbit_mensb;           
      END CASE;
   END IF;
END PROCESS arbit_fsm;
END vme_sys_arbiter_arch;
