--------------------------------------------------------------------------------
-- Title         : FIFO for DMA
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : vme_dma_fifo.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 18/09/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- This module consists of a fifo 256 x 32bit with logic.
-- A almost full and almost empty bit are generated.
--------------------------------------------------------------------------------
-- Hierarchy:
--
-- wbb2vme
--    vme_dma
--       vme_dma_fifo
--          fifo_256x32bit
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
-- $Log: vme_dma_fifo.vhd,v $
-- Revision 1.1  2012/03/29 10:14:43  MMiehling
-- Initial Revision
--
-- Revision 1.5  2006/05/18 14:02:24  MMiehling
-- changed fifo depth from 16 to 64
--
-- Revision 1.1  2005/10/28 17:52:25  mmiehling
-- Initial Revision
--
-- Revision 1.4  2004/11/02 11:19:41  mmiehling
-- changed sclr to aclr
--
-- Revision 1.3  2004/08/13 15:41:14  mmiehling
-- removed dma-slave and improved timing
--
-- Revision 1.2  2004/07/27 17:23:24  mmiehling
-- removed slave port
--
-- Revision 1.1  2004/07/15 09:28:51  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

library altera_mf;
use altera_mf.altera_mf_components.all;

ENTITY vme_dma_fifo IS
PORT (
   rst               : IN std_logic;
   clk               : IN std_logic;

   fifo_clr            : IN std_logic;
   fifo_wr            : IN std_logic;
   fifo_rd            : IN std_logic;
   fifo_dat_i         : IN std_logic_vector(31 DOWNTO 0);
   fifo_dat_o         : OUT std_logic_vector(31 DOWNTO 0);
   fifo_almost_full   : OUT std_logic;
   fifo_almost_empty  : OUT std_logic;
   fifo_empty         : OUT std_logic
     );
END vme_dma_fifo;

ARCHITECTURE vme_dma_fifo_arch OF vme_dma_fifo IS 
   SIGNAL fifo_usedw    : std_logic_vector(7 DOWNTO 0);
   SIGNAL low_level     : std_logic:='0';
   SIGNAL dat_o         : std_logic_vector(31 DOWNTO 0);
BEGIN

PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
      fifo_almost_full <= '0';
      fifo_empty <= '1';     
      fifo_almost_empty <= '0';
      fifo_dat_o <= (OTHERS => '0');
     ELSIF clk'EVENT AND clk = '1' THEN
        IF fifo_usedw = "11111110" AND fifo_wr = '1' THEN
         fifo_almost_full <= '1';
      ELSIF fifo_rd = '1' THEN
         fifo_almost_full <= '0';
      END IF;
      IF fifo_usedw = "00000001" AND fifo_rd = '1' THEN
         fifo_empty <= '1';
      ELSIF fifo_wr = '1' THEN
         fifo_empty <= '0';
      END IF;
      IF fifo_usedw = "00000010" AND fifo_rd = '1' THEN
         fifo_almost_empty <= '1';
      ELSIF fifo_wr = '1' OR fifo_rd = '1' THEN
         fifo_almost_empty <= '0';
      END IF;
      
      -- register for convertion of look-ahead fifo to normal fifo behaviour
      IF fifo_clr = '1' THEN
         fifo_dat_o <= (OTHERS => '0');
      ELSIF fifo_rd = '1' THEN
         fifo_dat_o <= dat_o;
      END IF;
     
     END IF;
  END PROCESS;

	fifo: scfifo --256x32bit
	GENERIC MAP (
		add_ram_output_register => "ON",
		intended_device_family => "Cyclone IV GX",
		lpm_numwords => 256,
		lpm_showahead => "ON",
		lpm_type => "scfifo",
		lpm_width => 32,
		lpm_widthu => 8,
		overflow_checking => "ON",
		underflow_checking => "ON",
		use_eab => "ON")
	PORT MAP (
		aclr  => fifo_clr,
		clock => clk,
		data  => fifo_dat_i,
		rdreq => fifo_rd,
		wrreq => fifo_wr,
		usedw => fifo_usedw,
		q     => dat_o);

END vme_dma_fifo_arch;
