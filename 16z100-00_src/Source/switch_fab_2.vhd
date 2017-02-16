---------------------------------------------------------------
-- Title         :
-- Project       : 
---------------------------------------------------------------
-- File          : switch_fab_2.vhd
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
-- $Revision: 1.3 $
--
-- $Log: switch_fab_2.vhd,v $
-- Revision 1.3  2015/06/15 16:39:54  AGeissler
-- R1: In 16z100- version 1.30 the bte signal was removed from the wb_pkg.vhd
-- M1: Adapted switch fabric
-- R2: Clearness
-- M2: Replaced tabs with spaces
--
-- Revision 1.2  2007/08/13 10:14:19  MMiehling
-- added: master gets no ack if corresponding stb is not active
--
-- Revision 1.1  2004/08/13 15:16:05  mmiehling
-- Initial Revision
--
-- Revision 1.1  2004/08/13 15:10:48  mmiehling
-- Initial Revision
--
-- Revision 1.2  2004/07/27 17:06:19  mmiehling
-- multifunction added
--
-- Revision 1.1  2004/04/29 15:07:24  MMiehling
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.wb_pkg.all;

ENTITY switch_fab_2 IS
GENERIC (
   registered     : IN boolean );
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

   wbo_slave      : IN wbi_type;
   wbi_slave      : OUT wbo_type;
   wbi_slave_cyc  : OUT std_logic
     );
END switch_fab_2;

ARCHITECTURE switch_fab_2_arch OF switch_fab_2 IS 
   SUBTYPE sw_states IS std_logic_vector(1 DOWNTO 0);
   CONSTANT sw_0  : sw_states := "01";
   CONSTANT sw_1  : sw_states := "10";
-- TYPE sw_states IS (sw_0, sw_1);
   SIGNAL sw_state   : sw_states;
   SIGNAL sw_nxt_state  : sw_states;
   SIGNAL ack_0_int  : std_logic;
   SIGNAL ack_1_int  : std_logic;
   SIGNAL sel        : std_logic_vector(1 DOWNTO 0);
   SIGNAL wbi_slave_stb : std_logic;

BEGIN


without_q : IF NOT registered GENERATE 
   
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
               ELSIF cyc_0 = '1' THEN
                  wbi_slave_stb <= wbo_0.stb;
               ELSE
                  wbi_slave_stb <= '0';
               END IF;              
   
            WHEN OTHERS =>
               wbi_slave_stb <= '0';
         END CASE;
      END IF;
     END PROCESS sw_fsm;
     
   sw_fsm_sel : PROCESS(sw_state, cyc_0, cyc_1)
     BEGIN
         CASE sw_state IS
            WHEN sw_0 =>
               IF cyc_0 = '1' THEN
                  sw_nxt_state <= sw_0;
               ELSIF cyc_1 = '1' THEN
                  sw_nxt_state <= sw_1;
               ELSE
                  sw_nxt_state <= sw_0;
               END IF;              
   
            WHEN sw_1 =>
               IF cyc_1 = '1' THEN
                  sw_nxt_state <= sw_1;
               ELSIF cyc_0 = '1' THEN
                  sw_nxt_state <= sw_0;
               ELSE
                  sw_nxt_state <= sw_1;
               END IF;              
   
            WHEN OTHERS =>
               sw_nxt_state <= sw_0;
            
         END CASE;
     END PROCESS sw_fsm_sel;
      
   PROCESS(sw_state, wbo_0.dat, wbo_1.dat)
      BEGIN
         CASE sw_state IS
            WHEN sw_0 => wbi_slave.dat <= wbo_0.dat;     
            WHEN sw_1 => wbi_slave.dat <= wbo_1.dat;     
            WHEN OTHERS => wbi_slave.dat <= wbo_0.dat;      
         END CASE;
      END PROCESS;
      
   PROCESS(sw_state, wbo_0.adr, wbo_1.adr)
      BEGIN
         CASE sw_state IS
            WHEN sw_0 => wbi_slave.adr <= wbo_0.adr;     
            WHEN sw_1 => wbi_slave.adr <= wbo_1.adr;     
            WHEN OTHERS => wbi_slave.adr <= wbo_0.adr;      
         END CASE;
      END PROCESS;
      
   PROCESS(sw_state, wbo_0.sel, wbo_1.sel)
      BEGIN
         CASE sw_state IS
            WHEN sw_0 => wbi_slave.sel <= wbo_0.sel;     
            WHEN sw_1 => wbi_slave.sel <= wbo_1.sel;     
            WHEN OTHERS => wbi_slave.sel <= wbo_0.sel;      
         END CASE;
      END PROCESS;
      
   PROCESS(sw_state, wbo_0.we, wbo_1.we)
      BEGIN
         CASE sw_state IS
            WHEN sw_0 => wbi_slave.we <= wbo_0.we;    
            WHEN sw_1 => wbi_slave.we <= wbo_1.we;    
            WHEN OTHERS => wbi_slave.we <= wbo_0.we;     
         END CASE;
      END PROCESS;
      
   PROCESS(sw_state, wbo_0.cti, wbo_1.cti)
      BEGIN
         CASE sw_state IS
            WHEN sw_0 => wbi_slave.cti <= wbo_0.cti;     
            WHEN sw_1 => wbi_slave.cti <= wbo_1.cti;     
            WHEN OTHERS => wbi_slave.cti <= wbo_0.cti;      
         END CASE;
      END PROCESS;
      
   PROCESS(sw_state, wbo_0.tga, wbo_1.tga)
      BEGIN
         CASE sw_state IS
            WHEN sw_0 => wbi_slave.tga <= wbo_0.tga;     
            WHEN sw_1 => wbi_slave.tga <= wbo_1.tga;     
            WHEN OTHERS => wbi_slave.tga <= wbo_0.tga;      
         END CASE;
      END PROCESS;
                  
      wbi_slave.stb <= wbi_slave_stb;                 
      wbi_slave_cyc <= '1' WHEN (sw_state = sw_0 AND cyc_0 = '1') OR (sw_state = sw_1 AND cyc_1 = '1') ELSE '0';
      
      ack_0 <= '1' WHEN sw_state = sw_0 AND wbo_slave.ack = '1' AND wbi_slave_stb = '1' ELSE '0';
      ack_1 <= '1' WHEN sw_state = sw_1 AND wbo_slave.ack = '1' AND wbi_slave_stb = '1' ELSE '0';
   
      err_0 <= '1' WHEN sw_state = sw_0 AND wbo_slave.err = '1' AND wbi_slave_stb = '1' ELSE '0';
      err_1 <= '1' WHEN sw_state = sw_1 AND wbo_slave.err = '1' AND wbi_slave_stb = '1' ELSE '0';

END GENERATE without_q; 
---------------------------------------------------------------------

with_q : IF registered GENERATE

   ack_0 <= ack_0_int;
   ack_1 <= ack_1_int;
   wbi_slave.stb <= wbi_slave_stb;                 

   sw_fsm : PROCESS (clk, rst)
     BEGIN
      IF rst = '1' THEN
         sw_state <= sw_0;
         wbi_slave_stb <= '0';
      ELSIF clk'EVENT AND clk = '1' THEN
         CASE sw_state IS
            WHEN sw_0 =>
               IF cyc_0 = '1' THEN
                  sw_state <= sw_0;
                  IF wbo_slave.err = '1' THEN                              -- error
                     wbi_slave_stb <= '0';
                  ELSIF wbo_slave.ack = '1' AND wbo_0.cti = "010" THEN  -- burst
                     wbi_slave_stb <= wbo_0.stb;
                  ELSIF (wbo_slave.ack = '1' OR ack_0_int = '1') AND wbo_0.cti /= "010" THEN -- single
                     wbi_slave_stb <= '0';
                  ELSE
                     wbi_slave_stb <= wbo_0.stb;
                  END IF;
               ELSIF cyc_1 = '1' THEN
                  sw_state <= sw_1;
                  wbi_slave_stb  <= wbo_1.stb;
               ELSE
                  sw_state <= sw_0;
                  wbi_slave_stb  <= '0';
               END IF;              
            WHEN sw_1 =>
               IF cyc_1 = '1' THEN
                  sw_state <= sw_1;
                  IF wbo_slave.err = '1' THEN                                 -- error
                     wbi_slave_stb <= '0';
                  ELSIF wbo_slave.ack = '1' AND wbo_1.cti = "010" THEN     -- single
                     wbi_slave_stb <= wbo_1.stb;
                  ELSIF (wbo_slave.ack = '1' OR ack_1_int = '1') AND wbo_1.cti /= "010" THEN    -- burst
                     wbi_slave_stb <= '0';
                  ELSE
                     wbi_slave_stb <= wbo_1.stb;
                  END IF;
               ELSIF cyc_0 = '1' THEN
                  sw_state <= sw_0;
                  wbi_slave_stb  <= wbo_0.stb;
               ELSE
                  sw_state <= sw_1;
                  wbi_slave_stb  <= '0';
               END IF;              
            WHEN OTHERS =>
               sw_state <= sw_0;
               wbi_slave_stb <= '0';
         END CASE;
      END IF;
     END PROCESS sw_fsm;
     
   sw_fsm_sel : PROCESS(sw_state, cyc_0, cyc_1)
    BEGIN
      CASE sw_state IS
         WHEN sw_0 =>
            IF cyc_0 = '1' THEN     sel <= "01";
            ELSIF cyc_1 = '1' THEN  sel <= "10";
            ELSE                    sel <= "00";
            END IF;              
         WHEN sw_1 =>
            IF cyc_1 = '1' THEN     sel <= "10";
            ELSIF cyc_0 = '1' THEN  sel <= "01";
            ELSE                    sel <= "00";
            END IF;              
         WHEN OTHERS =>             sel <= "00";
      END CASE;
    END PROCESS sw_fsm_sel;

   data_sw : PROCESS( clk, rst)
    BEGIN
      IF rst = '1' THEN
         wbi_slave.dat <= (OTHERS => '0');
         wbi_slave.adr <= (OTHERS => '0');
         wbi_slave.sel <= (OTHERS => '0');
         wbi_slave.we <= '0';
         wbi_slave_cyc <= '0';
         ack_0_int <= '0';
         err_0 <= '0';
         ack_1_int <= '0';
         err_1 <= '0';
      ELSIF clk'EVENT AND clk = '1' THEN
         wbi_slave_cyc <= sel(0) OR sel(1);
         IF sw_state = sw_0 AND wbo_slave.ack = '1' AND wbi_slave_stb = '1' THEN
            ack_0_int <= '1';
         ELSE
            ack_0_int <= '0';
         END IF;
         IF sw_state = sw_0 AND wbo_slave.err = '1' AND wbi_slave_stb = '1' THEN
            err_0 <= '1';
         ELSE
            err_0 <= '0';
         END IF;
         IF sw_state = sw_1 AND wbo_slave.ack = '1' AND wbi_slave_stb = '1' THEN
            ack_1_int <= '1';
         ELSE
            ack_1_int <= '0';
         END IF;
         IF sw_state = sw_1 AND wbo_slave.err = '1' AND wbi_slave_stb = '1' THEN
            err_1 <= '1';
         ELSE
            err_1 <= '0';
         END IF;
         
         CASE sel IS
            WHEN "01" =>   wbi_slave.dat  <= wbo_0.dat;
                           wbi_slave.adr  <= wbo_0.adr;
                           wbi_slave.sel  <= wbo_0.sel;
                           wbi_slave.we   <= wbo_0.we;
                           wbi_slave.cti  <= wbo_0.cti;
                           wbi_slave.tga  <= wbo_0.tga;
            WHEN OTHERS => wbi_slave.dat  <= wbo_1.dat;
                           wbi_slave.adr  <= wbo_1.adr;
                           wbi_slave.sel  <= wbo_1.sel;
                           wbi_slave.we   <= wbo_1.we;
                           wbi_slave.cti  <= wbo_1.cti;
                           wbi_slave.tga  <= wbo_1.tga;                          
         END CASE;
      END IF;
   END PROCESS data_sw;
      
END GENERATE with_q;

END switch_fab_2_arch;
