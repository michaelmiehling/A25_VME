--------------------------------------------------------------------------------
-- Title         : Slave of DMA controller
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : vme_dma_slv.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 17/09/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- This module handles accesses to the dma registers and to the
-- buffer descriptor registers from pci-side.
--------------------------------------------------------------------------------
-- Hierarchy:
--
-- wbb2vme
--    vme_dma
--       vme_dma_fifo
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
-- $Revision: 1.1 $
--
-- $Log: vme_dma_slv.vhd,v $
-- Revision 1.1  2012/03/29 10:14:40  MMiehling
-- Initial Revision
--
-- Revision 1.2  2006/05/18 14:02:29  MMiehling
-- changed comment
--
-- Revision 1.1  2005/10/28 17:52:29  mmiehling
-- Initial Revision
--
-- Revision 1.1  2004/07/15 09:28:53  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY vme_dma_slv IS
PORT (
   rst         : IN std_logic;
   clk         : IN std_logic;
   
   stb_i         : IN std_logic;
   ack_o         : OUT std_logic;
   we_i         : IN std_logic;
   cyc_i         : IN std_logic;
   
   slv_req      : OUT std_logic;
   slv_ack      : IN std_logic

     );
END vme_dma_slv;

ARCHITECTURE vme_dma_slv_arch OF vme_dma_slv IS 
   SIGNAL slv_ack_reg   : std_logic;
   
BEGIN
   -- request for access to registers (only write, for read not needed)
   slv_req <= '1' WHEN stb_i = '1' AND we_i = '1' AND cyc_i = '1' ELSE '0'; 
   ack_o <= '1' WHEN stb_i = '1' AND cyc_i = '1' AND (slv_ack = '1' OR slv_ack_reg = '1') ELSE '0';
   
ack : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
        slv_ack_reg <= '0';
     ELSIF clk'EVENT AND clk = '1' THEN
      IF stb_i = '1' AND we_i = '0' AND cyc_i = '1' THEN
         slv_ack_reg <= '1';
      ELSE
         slv_ack_reg <= '0';
      END IF;
     END IF;
  END PROCESS ack;
END vme_dma_slv_arch;
