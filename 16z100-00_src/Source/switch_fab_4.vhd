---------------------------------------------------------------
-- Title         :
-- Project       : 
---------------------------------------------------------------
-- File          : switch_fab_4.vhd
-- Author        : Michael Miehling
-- Email         : miehling@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 25/02/04
---------------------------------------------------------------
-- Simulator     : Modelsim PE 5.7g
-- Synthesis     : Quartus II 3.0
---------------------------------------------------------------
-- Description :
--
-- 
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
-- $Revision: 1.6 $
--
-- $Log: switch_fab_4.vhd,v $
-- Revision 1.6  2015/06/15 16:39:59  AGeissler
-- R1: In 16z100- version 1.30 the bte signal was removed from the wb_pkg.vhd
-- M1: Adapted switch fabric
-- R2: Clearness
-- M2: Replaced tabs with spaces
--
-- Revision 1.5  2007/08/13 13:58:56  FWombacher
-- added intermediate for output wbi_slave_cyc
--
-- Revision 1.4  2007/08/13 10:14:24  MMiehling
-- added: master gets no ack if corresponding stb is not active
--
-- Revision 1.3  2005/02/09 14:29:20  mmiehling
-- sw_2 and sw_3 does not work correct
--
-- Revision 1.2  2005/01/18 15:17:29  mmiehling
-- changed muxes to process structure
--
-- Revision 1.1  2004/08/13 15:16:07  mmiehling
-- Initial Revision
--
-- Revision 1.1  2004/08/13 15:10:51  mmiehling
-- Initial Revision
--
-- Revision 1.1  2004/07/27 17:06:23  mmiehling
-- Initial Revision
--
-- Revision 1.1  2004/04/29 15:07:24  MMiehling
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.wb_pkg.all;

ENTITY switch_fab_4 IS
PORT (
   clk            : IN std_logic;
   rst            : IN std_logic;

   cyc_0          : IN std_logic;
   ack_0          : OUT std_logic;
   err_0          : OUT std_logic;
   wbo_0          : IN wbo_type;

   cyc_1          : IN std_logic;
   ack_1          : OUT std_logic;
   err_1          : OUT std_logic;
   wbo_1          : IN wbo_type;

   cyc_2          : IN std_logic;
   ack_2          : OUT std_logic;
   err_2          : OUT std_logic;
   wbo_2          : IN wbo_type;

   cyc_3          : IN std_logic;
   ack_3          : OUT std_logic;
   err_3          : OUT std_logic;
   wbo_3          : IN wbo_type;

   wbo_slave      : IN wbi_type;
   wbi_slave      : OUT wbo_type;
   wbi_slave_cyc  : OUT std_logic
     );
END switch_fab_4;

ARCHITECTURE switch_fab_4_arch OF switch_fab_4 IS 
   SUBTYPE sw_states IS std_logic_vector(2 DOWNTO 0);
   CONSTANT sw_0  : sw_states := "001";
   CONSTANT sw_1  : sw_states := "010";
   CONSTANT sw_2  : sw_states := "011";
   CONSTANT sw_3  : sw_states := "100";
   SIGNAL sw_state   : sw_states;
   SIGNAL sw_nxt_state  : sw_states;
   SIGNAL ack_0_int  : std_logic;
   SIGNAL ack_1_int  : std_logic;
   SIGNAL ack_2_int  : std_logic;
   SIGNAL ack_3_int  : std_logic;
   SIGNAL wbi_slave_stb : std_logic;
   SIGNAL wbi_slave_cyc_q : std_logic;
   
BEGIN
   
sw_fsm : PROCESS (clk, rst)
  BEGIN
   IF rst = '1' THEN
      wbi_slave_stb <= '0';
      sw_state <= sw_0;
   ELSIF clk'EVENT AND clk = '1' THEN
      sw_state <= sw_nxt_state;
      CASE sw_nxt_state IS
         WHEN sw_0 =>
            IF cyc_0 = '1' THEN
               IF wbo_slave.err = '1' THEN                              -- error
                  wbi_slave_stb <= '0';
               ELSIF wbo_slave.ack = '1' AND wbo_0.cti = "010" THEN  -- burst
                  wbi_slave_stb <= wbo_0.stb;
               ELSIF wbo_slave.ack = '1' AND wbo_0.cti /= "010" THEN -- single
                  wbi_slave_stb <= '0';
               ELSE
                  wbi_slave_stb <= wbo_0.stb;
               END IF;
            ELSIF cyc_1 = '1' THEN
               wbi_slave_stb <= wbo_1.stb;
            ELSIF cyc_2 = '1' THEN
               wbi_slave_stb <= wbo_2.stb;
            ELSIF cyc_3 = '1' THEN
               wbi_slave_stb <= wbo_3.stb;
            ELSE
               wbi_slave_stb <= '0';
            END IF;              

         WHEN sw_1 =>
            IF cyc_1 = '1' THEN
               IF wbo_slave.err = '1' THEN                              -- error
                  wbi_slave_stb <= '0';
               ELSIF wbo_slave.ack = '1' AND wbo_1.cti = "010" THEN  -- burst
                  wbi_slave_stb <= wbo_1.stb;
               ELSIF wbo_slave.ack = '1' AND wbo_1.cti /= "010" THEN -- single
                  wbi_slave_stb <= '0';
               ELSE
                  wbi_slave_stb <= wbo_1.stb;
               END IF;
            ELSIF cyc_2 = '1' THEN
               wbi_slave_stb <= wbo_2.stb;
            ELSIF cyc_3 = '1' THEN
               wbi_slave_stb <= wbo_3.stb;
            ELSIF cyc_0 = '1' THEN
               wbi_slave_stb <= wbo_0.stb;
            ELSE
               wbi_slave_stb <= '0';
            END IF;              

         WHEN sw_2 =>
            IF cyc_2 = '1' THEN
               IF wbo_slave.err = '1' THEN                              -- error
                  wbi_slave_stb <= '0';
               ELSIF wbo_slave.ack = '1' AND wbo_2.cti = "010" THEN  -- burst
                  wbi_slave_stb <= wbo_2.stb;
               ELSIF wbo_slave.ack = '1' AND wbo_2.cti /= "010" THEN -- single
                  wbi_slave_stb <= '0';
               ELSE
                  wbi_slave_stb <= wbo_2.stb;
               END IF;
            ELSIF cyc_3 = '1' THEN
               wbi_slave_stb <= wbo_3.stb;
            ELSIF cyc_0 = '1' THEN
               wbi_slave_stb <= wbo_0.stb;
            ELSIF cyc_1 = '1' THEN
               wbi_slave_stb <= wbo_1.stb;
            ELSE
               wbi_slave_stb <= '0';
            END IF;              

         WHEN sw_3 =>
            IF cyc_3 = '1' THEN
               IF wbo_slave.err = '1' THEN                              -- error
                  wbi_slave_stb <= '0';
               ELSIF wbo_slave.ack = '1' AND wbo_3.cti = "010" THEN  -- burst
                  wbi_slave_stb <= wbo_3.stb;
               ELSIF wbo_slave.ack = '1' AND wbo_3.cti /= "010" THEN -- single
                  wbi_slave_stb <= '0';
               ELSE
                  wbi_slave_stb <= wbo_3.stb;
               END IF;
            ELSIF cyc_0 = '1' THEN
               wbi_slave_stb <= wbo_0.stb;
            ELSIF cyc_1 = '1' THEN
               wbi_slave_stb <= wbo_1.stb;
            ELSIF cyc_2 = '1' THEN
               wbi_slave_stb <= wbo_2.stb;
            ELSE
               wbi_slave_stb <= '0';
            END IF;              

         WHEN OTHERS =>
            wbi_slave_stb <= '0';
      END CASE;
   END IF;
  END PROCESS sw_fsm;
  
sw_fsm_sel : PROCESS(sw_state, cyc_0, cyc_1, cyc_2, cyc_3)
  BEGIN
      CASE sw_state IS
         WHEN sw_0 =>
            IF cyc_0 = '1' THEN
               sw_nxt_state <= sw_0;
            ELSIF cyc_1 = '1' THEN
               sw_nxt_state <= sw_1;
            ELSIF cyc_2 = '1' THEN
               sw_nxt_state <= sw_2;
            ELSIF cyc_3 = '1' THEN
               sw_nxt_state <= sw_3;
            ELSE
               sw_nxt_state <= sw_0;
            END IF;              

         WHEN sw_1 =>
            IF cyc_1 = '1' THEN
               sw_nxt_state <= sw_1;
            ELSIF cyc_2 = '1' THEN
               sw_nxt_state <= sw_2;
            ELSIF cyc_3 = '1' THEN
               sw_nxt_state <= sw_3;
            ELSIF cyc_0 = '1' THEN
               sw_nxt_state <= sw_0;
            ELSE
               sw_nxt_state <= sw_1;
            END IF;              

         WHEN sw_2 =>
            IF cyc_2 = '1' THEN
               sw_nxt_state <= sw_2;
            ELSIF cyc_3 = '1' THEN
               sw_nxt_state <= sw_3;
            ELSIF cyc_0 = '1' THEN
               sw_nxt_state <= sw_0;
            ELSIF cyc_1 = '1' THEN
               sw_nxt_state <= sw_1;
            ELSE
               sw_nxt_state <= sw_2;
            END IF;              

         WHEN sw_3 =>
            IF cyc_3 = '1' THEN
               sw_nxt_state <= sw_3;
            ELSIF cyc_0 = '1' THEN
               sw_nxt_state <= sw_0;
            ELSIF cyc_1 = '1' THEN
               sw_nxt_state <= sw_1;
            ELSIF cyc_2 = '1' THEN
               sw_nxt_state <= sw_2;
            ELSE
               sw_nxt_state <= sw_3;
            END IF;              

         WHEN OTHERS =>
            sw_nxt_state <= sw_0;
         
      END CASE;
  END PROCESS sw_fsm_sel;
   
   PROCESS(sw_state, wbo_0.dat, wbo_1.dat, wbo_2.dat, wbo_3.dat)
      BEGIN
         CASE sw_state IS
            WHEN sw_0 => wbi_slave.dat <= wbo_0.dat;     
            WHEN sw_1 => wbi_slave.dat <= wbo_1.dat;     
            WHEN sw_2 => wbi_slave.dat <= wbo_2.dat;     
            WHEN sw_3 => wbi_slave.dat <= wbo_3.dat;     
            WHEN OTHERS => wbi_slave.dat <= wbo_0.dat;      
         END CASE;
      END PROCESS;
      
   PROCESS(sw_state, wbo_0.adr, wbo_1.adr, wbo_2.adr, wbo_3.adr)
      BEGIN
         CASE sw_state IS
            WHEN sw_0 => wbi_slave.adr <= wbo_0.adr;     
            WHEN sw_1 => wbi_slave.adr <= wbo_1.adr;     
            WHEN sw_2 => wbi_slave.adr <= wbo_2.adr;     
            WHEN sw_3 => wbi_slave.adr <= wbo_3.adr;     
            WHEN OTHERS => wbi_slave.adr <= wbo_0.adr;      
         END CASE;
      END PROCESS;
      
   PROCESS(sw_state, wbo_0.sel, wbo_1.sel, wbo_2.sel, wbo_3.sel)
      BEGIN
         CASE sw_state IS
            WHEN sw_0 => wbi_slave.sel <= wbo_0.sel;     
            WHEN sw_1 => wbi_slave.sel <= wbo_1.sel;     
            WHEN sw_2 => wbi_slave.sel <= wbo_2.sel;     
            WHEN sw_3 => wbi_slave.sel <= wbo_3.sel;     
            WHEN OTHERS => wbi_slave.sel <= wbo_0.sel;      
         END CASE;
      END PROCESS;
      
   PROCESS(sw_state, wbo_0.we, wbo_1.we, wbo_2.we, wbo_3.we)
      BEGIN
         CASE sw_state IS
            WHEN sw_0 => wbi_slave.we <= wbo_0.we;    
            WHEN sw_1 => wbi_slave.we <= wbo_1.we;    
            WHEN sw_2 => wbi_slave.we <= wbo_2.we;    
            WHEN sw_3 => wbi_slave.we <= wbo_3.we;    
            WHEN OTHERS => wbi_slave.we <= wbo_0.we;     
         END CASE;
      END PROCESS;
      
   PROCESS(sw_state, wbo_0.cti, wbo_1.cti, wbo_2.cti, wbo_3.cti)
      BEGIN
         CASE sw_state IS
            WHEN sw_0 => wbi_slave.cti <= wbo_0.cti;     
            WHEN sw_1 => wbi_slave.cti <= wbo_1.cti;     
            WHEN sw_2 => wbi_slave.cti <= wbo_2.cti;     
            WHEN sw_3 => wbi_slave.cti <= wbo_3.cti;     
            WHEN OTHERS => wbi_slave.cti <= wbo_0.cti;      
         END CASE;
      END PROCESS;
      
   PROCESS(sw_state, wbo_0.tga, wbo_1.tga, wbo_2.tga, wbo_3.tga)
      BEGIN
         CASE sw_state IS
            WHEN sw_0 => wbi_slave.tga <= wbo_0.tga;     
            WHEN sw_1 => wbi_slave.tga <= wbo_1.tga;     
            WHEN sw_2 => wbi_slave.tga <= wbo_2.tga;     
            WHEN sw_3 => wbi_slave.tga <= wbo_3.tga;     
            WHEN OTHERS => wbi_slave.tga <= wbo_0.tga;      
         END CASE;
      END PROCESS;
      
   wbi_slave.stb <= wbi_slave_stb;           
   wbi_slave_cyc_q <= '1' WHEN (sw_state = sw_0 AND cyc_0 = '1') OR (sw_state = sw_1 AND cyc_1 = '1') OR (sw_state = sw_2 AND cyc_2 = '1') OR (sw_state = sw_3 AND cyc_3 = '1') ELSE '0';
   
   ack_0 <= '1' WHEN sw_state = sw_0 AND wbo_slave.ack = '1' AND wbi_slave_cyc_q = '1' ELSE '0';
   ack_1 <= '1' WHEN sw_state = sw_1 AND wbo_slave.ack = '1' AND wbi_slave_cyc_q = '1' ELSE '0';
   ack_2 <= '1' WHEN sw_state = sw_2 AND wbo_slave.ack = '1' AND wbi_slave_cyc_q = '1' ELSE '0';
   ack_3 <= '1' WHEN sw_state = sw_3 AND wbo_slave.ack = '1' AND wbi_slave_cyc_q = '1' ELSE '0';
                                                                              
   err_0 <= '1' WHEN sw_state = sw_0 AND wbo_slave.err = '1' AND wbi_slave_cyc_q = '1' ELSE '0';
   err_1 <= '1' WHEN sw_state = sw_1 AND wbo_slave.err = '1' AND wbi_slave_cyc_q = '1' ELSE '0';
   err_2 <= '1' WHEN sw_state = sw_2 AND wbo_slave.err = '1' AND wbi_slave_cyc_q = '1' ELSE '0';
   err_3 <= '1' WHEN sw_state = sw_3 AND wbo_slave.err = '1' AND wbi_slave_cyc_q = '1' ELSE '0'; 
      
   wbi_slave_cyc <= wbi_slave_cyc_q;

---------------------------------------------------------------------

END switch_fab_4_arch;
