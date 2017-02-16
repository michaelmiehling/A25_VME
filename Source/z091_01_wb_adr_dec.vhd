--------------------------------------------------------------------------------
-- Title         : 16z091-01 specific Wishbone bus
-- Project       : 
-------------------------------------------------------------------------------
-- File          : z091_01_wb_adr_dec.vhd
-- Author        : Susanne Reinfelder
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 2012-12-19
-------------------------------------------------------------------------------
-- Simulator     : 
-- Synthesis     : 
-------------------------------------------------------------------------------
-- +-Module Name-------------------+-cyc-+---offset-+-----size-+-bar-+
-- |               Chameleon Table |   0 |        0 |      200 |   0 |
-- |               16Z126_SERFLASH |   1 |      200 |       20 |   0 |
-- |                 16z002-01 VME |   2 |    10000 |    10000 |   0 |
-- |          16z002-01 VME A16D16 |   3 |    20000 |    10000 |   0 |
-- |          16z002-01 VME A16D32 |   4 |    30000 |    10000 |   0 |
-- |            16z002-01 VME SRAM |   5 |        0 |   100000 |   1 |
-- |          16z002-01 VME A24D16 |   6 |        0 |  1000000 |   2 |
-- |          16z002-01 VME A24D32 |   7 |  1000000 |  1000000 |   2 |
-- |             16z002-01 VME A32 |   8 |        0 | 20000000 |   3 |
-- +-------------------------------+-----+----------+----------+-----+
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

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity z091_01_wb_adr_dec is
   generic(
      NR_OF_WB_SLAVES : integer range 63 downto 1 := 1
   );
   port(
      pci_cyc_i       : in  std_logic_vector(6 downto 0);
      wbm_adr_o_q     : in  std_logic_vector(31 downto 2);

      wbm_cyc_o       : out std_logic_vector(NR_OF_WB_SLAVES -1 downto 0)
   );
end z091_01_wb_adr_dec;

-------------------------------------------------------------------------
-- sim_test_arch implements a sample pcie address decoder to enable 
-- the simulation iram models
-------------------------------------------------------------------------
architecture a25_arch of z091_01_wb_adr_dec is 

begin
   
   PROCESS(wbm_adr_o_q, pci_cyc_i)
      VARIABLE wbm_cyc_o_int : std_logic_vector(8 DOWNTO 0);
      CONSTANT zero : std_logic_vector(NR_OF_WB_SLAVES -1 downto 0):=(OTHERS => '0');
      BEGIN
         wbm_cyc_o_int := (OTHERS => '0');

			
         -- Chameleon Table - cycle 0 - offset 0 - size 200 --
         IF pci_cyc_i(0) = '1' AND wbm_adr_o_q(17 DOWNTO 9) = "000000000" THEN
            wbm_cyc_o_int(0) := '1';
         ELSE
            wbm_cyc_o_int(0) := '0';
         END IF;


         -- 16Z126_SERFLASH - cycle 1 - offset 200 - size 20 --
         IF pci_cyc_i(0) = '1' AND wbm_adr_o_q(17 DOWNTO 5) = "0000000010000" THEN
            wbm_cyc_o_int(1) := '1';
         ELSE
            wbm_cyc_o_int(1) := '0';
         END IF;


         -- 16z002-01 VME - cycle 2 - offset 10000 - size 10000 --
         IF pci_cyc_i(0) = '1' AND wbm_adr_o_q(17 DOWNTO 16) = "01" THEN
            wbm_cyc_o_int(2) := '1';
         ELSE
            wbm_cyc_o_int(2) := '0';
         END IF;


         -- 16z002-01 VME A16D16 - cycle 3 - offset 20000 - size 10000 --
         IF pci_cyc_i(0) = '1' AND wbm_adr_o_q(17 DOWNTO 16) = "10" THEN
            wbm_cyc_o_int(3) := '1';
         ELSE
            wbm_cyc_o_int(3) := '0';
         END IF;


         -- 16z002-01 VME A16D32 - cycle 4 - offset 30000 - size 10000 --
         IF pci_cyc_i(0) = '1' AND wbm_adr_o_q(17 DOWNTO 16) = "11" THEN
            wbm_cyc_o_int(4) := '1';
         ELSE
            wbm_cyc_o_int(4) := '0';
         END IF;


         -- 16z002-01 VME SRAM - cycle 5 - offset 0 - size 100000 --
         IF pci_cyc_i(1) = '1' THEN
            wbm_cyc_o_int(5) := '1';
         ELSE
            wbm_cyc_o_int(5) := '0';
         END IF;


         -- 16z002-01 VME A24D16 - cycle 6 - offset 0 - size 1000000 --
         IF pci_cyc_i(2) = '1' AND wbm_adr_o_q(24) = '0' THEN
            wbm_cyc_o_int(6) := '1';
         ELSE
            wbm_cyc_o_int(6) := '0';
         END IF;


         -- 16z002-01 VME A24D32 - cycle 7 - offset 1000000 - size 1000000 --
         IF pci_cyc_i(2) = '1' AND wbm_adr_o_q(24) = '1' THEN
            wbm_cyc_o_int(7) := '1';
         ELSE
            wbm_cyc_o_int(7) := '0';
         END IF;


         -- 16z002-01 VME A32 - cycle 8 - offset 0 - size 20000000 --
         IF pci_cyc_i(3) = '1' THEN
            wbm_cyc_o_int(8) := '1';
         ELSE
            wbm_cyc_o_int(8) := '0';
         END IF;

         IF pci_cyc_i /= zero AND wbm_cyc_o_int = "000000000" THEN
            wbm_cyc_o_int(0) := '1';
         END IF;

  	
      wbm_cyc_o <= wbm_cyc_o_int;
	  	
	  	END PROCESS;
     
end a25_arch;

