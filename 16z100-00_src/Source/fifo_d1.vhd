---------------------------------------------------------------
-- Title         : FIFO with depth one word
-- Project       : 
---------------------------------------------------------------
-- File          : fifo_d1.vhd
-- Author        : Michael Miehling
-- Email         : miehling@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 23/06/04
---------------------------------------------------------------
-- Simulator     : Modelsim PE 5.7g
-- Synthesis     : Quartus II 3.0
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
-- $Revision: 1.3 $
--
-- $Log: fifo_d1.vhd,v $
-- Revision 1.3  2015/09/08 17:22:58  AGeissler
-- R1: Missing reset for second clock domain
-- M1: Replaced rstn with rst_a and rst_b
--
-- Revision 1.2  2015/06/15 16:40:08  AGeissler
-- R1: Clearness
-- M1: Replaced tabs with spaces
--
-- Revision 1.1  2005/05/06 12:06:49  MMiehling
-- Initial Revision
--
-- Revision 1.2  2004/11/02 11:29:27  mmiehling
-- added regs for full/empty signals
--
-- Revision 1.1  2004/07/27 17:15:22  mmiehling
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fifo_d1 IS
   GENERIC (
      width    : IN integer:=8
   );
   PORT (
      
      rst_a    : IN std_logic;
      clk_a    : IN std_logic;
      wr_a     : IN std_logic;
      data_a   : IN std_logic_vector(width-1 DOWNTO 0);
      full_a   : OUT std_logic;
      
      rst_b    : IN std_logic;
      clk_b    : IN std_logic;
      rd_b     : IN std_logic;
      data_b   : OUT std_logic_vector(width-1 DOWNTO 0);
      full_b   : OUT std_logic
      
   );
END fifo_d1;

ARCHITECTURE fifo_d1_arch OF fifo_d1 IS
   
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
   
   proca : PROCESS (clk_a, rst_a)
   BEGIN
      IF rst_a = '1' THEN
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
   
   
   procb : PROCESS (clk_b, rst_b)
   BEGIN
      IF rst_b = '1' THEN
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
   
   
END fifo_d1_arch;
