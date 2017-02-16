--------------------------------------------------------------------------------
-- Title         : 16z091-01 specific Wishbone bus
-- Project       : 
-------------------------------------------------------------------------------
-- File          : z091_01_wb_adr_dec.vhd
-- Author        : Susanne Reinfelder
-- Email         : susanne.reinfelder@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 2012-12-19
-------------------------------------------------------------------------------
-- Simulator     : 
-- Synthesis     : 
-------------------------------------------------------------------------------
-- Description   :
-- Special address decoder that can be used with configurations
-- to enable multiple instances of the 16z091-01 IP core
-- that can have their unique address decoder
-------------------------------------------------------------------------------
-- Hierarchy:
--    ip_16z091_01_top
--       ip_16z091_01
--       Hard_IP
-- *     z091_01_wb_adr_dec
-- 
-------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------
library ieee;
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
architecture sim_test_arch of z091_01_wb_adr_dec is 
signal zero : std_logic_vector(NR_OF_WB_SLAVES -1 downto 0);

begin
   zero <= (others => '0');
   process(wbm_adr_o_q, pci_cyc_i, zero)
      variable wbm_cyc_o_int : std_logic_vector(NR_OF_WB_SLAVES -1 downto 0);
   begin
      wbm_cyc_o_int := (others => '0');

      -- iram 1 - cycle 0 - offset 00000000 - size 1000 --
      if pci_cyc_i(0) = '1' then
         wbm_cyc_o_int(0) := '1';
      else
         wbm_cyc_o_int(0) := '0';
      end if;

      -- iram 2 - cycle 1 - offset 00000000 - size 2000 --
      if pci_cyc_i(1) = '1' then
         wbm_cyc_o_int(1) := '1';
      else
         wbm_cyc_o_int(1) := '0';
      end if;

      -- iram 2 - cycle 2 - offset 00000000 - size 1000 --
      if pci_cyc_i(2) = '1' then
         wbm_cyc_o_int(2) := '1';
      else
         wbm_cyc_o_int(2) := '0';
      end if;

      --if pci_cyc_i /= zero and wbm_cyc_o_int = "000" then
      if pci_cyc_i /= "0000000" and wbm_cyc_o_int = zero then
         wbm_cyc_o_int(0) := '1';
      end if;
     
      wbm_cyc_o <= wbm_cyc_o_int;
      
    end process;
     
end sim_test_arch;

