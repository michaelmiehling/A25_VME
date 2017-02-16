--------------------------------------------------------------------------------
-- Title         : Arbiter for DMA controller
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : vme_dma_arbiter.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 17/09/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- This module arbitrates the accesses from vme_dma_slv and vme_dma_mstr.
-- The request and acknoledge signals are like the whisbone
-- stb and ack signals. The arbitration result indicates the
-- signal arbit_slv. If set, the vme_dma_slv has access and vica
-- verse.
--------------------------------------------------------------------------------
-- Hierarchy:
--
-- wbb2vme
--    vme_dma
--       vme_dma_arbiter
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
-- $Log: vme_dma_arbiter.vhd,v $
-- Revision 1.1  2012/03/29 10:14:47  MMiehling
-- Initial Revision
--
-- Revision 1.3  2006/05/18 14:02:18  MMiehling
-- changed comment
--
-- Revision 1.1  2005/10/28 17:52:21  mmiehling
-- Initial Revision
--
-- Revision 1.2  2004/07/27 17:23:17  mmiehling
-- removed slave port
--
-- Revision 1.1  2004/07/15 09:28:47  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY vme_dma_arbiter IS
PORT (
   rst               : IN std_logic;
   clk               : IN std_logic;
   
   -- vme_dma_slv
   slv_req            : IN std_logic;
   slv_ack            : OUT std_logic;
   
   -- vme_dma_mstr
   mstr_req            : IN std_logic;
   mstr_ack            : OUT std_logic;
   
   -- result
   arbit_slv         : OUT std_logic      -- if set, vme_dma_slv has access and vica verse

     );
END vme_dma_arbiter;

ARCHITECTURE vme_dma_arbiter_arch OF vme_dma_arbiter IS 

BEGIN

        arbit_slv <= '0';
        slv_ack <= '0';

arb : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
--        arbit_slv <= '0';
--        slv_ack <= '0';
        mstr_ack <= '0';
     ELSIF clk'EVENT AND clk = '1' THEN
        mstr_ack <= mstr_req;
     
--        IF mstr_req = '1' THEN         -- vme_dma_mstr access is requested
--           mstr_ack <= '1';
--           slv_ack <= '0';
--           arbit_slv <= '0';
--        ELSIF slv_req = '1' THEN      -- vme_dma_slv access is requested
--           mstr_ack <= '0';
--           slv_ack <= '1';
--           arbit_slv <= '1';
--        ELSE                           -- no requests
--           mstr_ack <= '0';
--           slv_ack <= '0';
--           arbit_slv <= '0';
--        END IF;
   END IF;
  END PROCESS arb;
END vme_dma_arbiter_arch;
