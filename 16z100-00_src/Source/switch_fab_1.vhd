---------------------------------------------------------------------
-- Title         : 
-- Project       : 
---------------------------------------------------------------------
-- File          : switch_fab_1.vhd
-- Author        : Michael Miehling
-- Email         : miehling@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       :  13/08/07
---------------------------------------------------------------------
-- Simulator     : Modelsim PE 5.7g
-- Synthesis     : Quartus II 3.0
---------------------------------------------------------------------
-- Description :
--!\reqid
--!\upreqid
---------------------------------------------------------------------
--!\hierarchy
--!\endofhierarchy
---------------------------------------------------------------------
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
---------------------------------------------------------------------
--                         History                                    
---------------------------------------------------------------------
-- $Revision: 1.4 $
--
-- $Log: switch_fab_1.vhd,v $
-- Revision 1.4  2015/06/15 16:39:52  AGeissler
-- R1: In 16z100- version 1.30 the bte signal was removed from the wb_pkg.vhd
-- M1: Adapted switch fabric
-- R2: Clearness
-- M2: Replaced tabs with spaces
--
-- Revision 1.3  2009/07/29 14:05:11  FLenhardt
-- Fixed bug (WB slave strobe had been activated without addressing)
--
-- Revision 1.2  2007/08/13 17:04:22  FWombacher
-- fixed typos
--
-- Revision 1.1  2007/08/13 16:28:20  MMiehling
-- Initial Revision
--
--
---------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.wb_pkg.all;

ENTITY switch_fab_1 IS
   GENERIC (
      registered     : IN boolean
   );
   PORT (
      clk               : IN std_logic;
      rst               : IN std_logic;
      -- wb-bus #0
      cyc_0             : IN std_logic;
      ack_0             : OUT std_logic;
      err_0             : OUT std_logic;
      wbo_0             : IN wbo_type;
      -- wb-bus to slave
      wbo_slave         : IN wbi_type;
      wbi_slave         : OUT wbo_type;
      wbi_slave_cyc     : OUT std_logic
   );
END switch_fab_1;

ARCHITECTURE switch_fab_1_arch OF switch_fab_1 IS 
   SIGNAL wbi_slave_stb  : std_logic;
BEGIN
   
   wbi_slave_cyc <= cyc_0;
   wbi_slave.stb <= wbi_slave_stb;
   ack_0 <= wbo_slave.ack AND wbi_slave_stb;
   err_0 <= wbo_slave.err AND wbi_slave_stb;
   
   wbi_slave.dat  <= wbo_0.dat;
   wbi_slave.adr  <= wbo_0.adr;
   wbi_slave.sel  <= wbo_0.sel;
   wbi_slave.we   <= wbo_0.we;
   wbi_slave.cti  <= wbo_0.cti;
   wbi_slave.tga  <= wbo_0.tga;
   wbi_slave.bte  <= "00";
   
   PROCESS(clk, rst)
   BEGIN
      IF rst = '1' THEN
         wbi_slave_stb <= '0';
      ELSIF clk'EVENT AND clk = '1' THEN
         IF cyc_0 = '1' THEN
            IF wbo_slave.err = '1' THEN                           -- error
               wbi_slave_stb <= '0';
            ELSIF wbo_slave.ack = '1' AND wbo_0.cti = "010" THEN  -- burst
               wbi_slave_stb <= wbo_0.stb;
            ELSIF wbo_slave.ack = '1' AND wbo_0.cti /= "010" THEN -- single
               wbi_slave_stb <= '0';
            ELSE
               wbi_slave_stb <= wbo_0.stb;
            END IF;
         ELSE
            wbi_slave_stb <= '0';
         END IF;
      END IF;
   END PROCESS;
   
END switch_fab_1_arch;
