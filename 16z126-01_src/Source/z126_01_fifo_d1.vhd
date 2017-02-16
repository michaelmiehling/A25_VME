---------------------------------------------------------------
-- Title         : FIFO with depth one word
-- Project       : 
---------------------------------------------------------------
-- File          : z126_01_fifo_d1.vhd
-- Author        : Andreas Geissler
-- Email         : Andreas.Geissler@men.de
-- Organization  : MEN Mikro Elektronik Nuremberg GmbH
-- Created       : 03/02/14
---------------------------------------------------------------
-- Simulator     : ModelSim-Altera PE 6.4c
-- Synthesis     : Quartus II 12.1 SP2
---------------------------------------------------------------
-- Description :
--
-- This module describes a fifo with depth one word.
-- No EAB-Block is required, just registers.
---------------------------------------------------------------
-- Hierarchy:
--
-- 
---------------------------------------------------------------
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
---------------------------------------------------------------
--                         History                                    
---------------------------------------------------------------
-- $Revision: 1.1 $
--
-- $Log: z126_01_fifo_d1.vhd,v $
-- Revision 1.1  2014/03/03 17:49:40  AGeissler
-- Initial Revision
--
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY z126_01_fifo_d1 IS
   GENERIC (
      width    : IN integer:=8 );
   PORT (
      rstn     : IN std_logic;
         
      clk_a    : IN std_logic;
      wr_a     : IN std_logic;
      data_a   : IN std_logic_vector(width-1 DOWNTO 0);
      full_a   : OUT std_logic;
      
      clk_b    : IN std_logic;
      rd_b     : IN std_logic;
      data_b   : OUT std_logic_vector(width-1 DOWNTO 0);
      full_b   : OUT std_logic
   );
END z126_01_fifo_d1;

ARCHITECTURE z126_01_fifo_d1_arch OF z126_01_fifo_d1 IS 
   SIGNAL wr_ptr        : std_logic;
   SIGNAL rd_ptr        : std_logic;
   SIGNAL wr_ptr_b      : std_logic;
   SIGNAL rd_ptr_a      : std_logic;
   SIGNAL full_a_int    : std_logic;   
   SIGNAL full_b_int    : std_logic;   
   SIGNAL data_a_q      : std_logic_vector(width-1 DOWNTO 0);
BEGIN
   full_a_int <= '1' WHEN (wr_ptr = '1' AND rd_ptr_a = '0') OR (wr_ptr = '0' AND rd_ptr_a = '1') ELSE '0';
   full_a <= full_a_int;
   full_b_int <= '1' WHEN (wr_ptr_b = '1' AND rd_ptr = '0') OR (wr_ptr_b = '0' AND rd_ptr = '1') ELSE '0';
   full_b <= full_b_int;
   
   proca : PROCESS (clk_a, rstn)
   BEGIN
      IF rstn = '0' THEN
         data_a_q <= (OTHERS => '0');
         wr_ptr <= '0';
         rd_ptr_a <= '0';
      ELSIF clk_a'EVENT AND clk_a = '1' THEN
         rd_ptr_a <= rd_ptr;
         IF wr_a = '1' AND full_a_int = '0' THEN
            data_a_q <= data_a;
            wr_ptr <= NOT wr_ptr;
         END IF;
      END IF;
   END PROCESS proca;
   
   procb : PROCESS (clk_b, rstn)
   BEGIN
      IF rstn = '0' THEN
         data_b <= (OTHERS => '0');
         rd_ptr <= '0';
         wr_ptr_b <= '0';
      ELSIF clk_b'EVENT AND clk_b = '1' THEN
         wr_ptr_b <= wr_ptr;
         IF rd_b = '1' AND full_b_int = '1' THEN 
            data_b <= data_a_q;
            rd_ptr <= NOT rd_ptr;
         END IF;
      END IF;
   END PROCESS procb;
   
END z126_01_fifo_d1_arch;
