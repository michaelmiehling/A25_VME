--------------------------------------------------------------------------------
-- Title         : VME Arbiter
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : vme_arbiter.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 10/02/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description : 
-- This Unit contains the Arbiter and the Bus Arbitration Timer. 
-- These Functions are
-- only enabled if the Bridge resides on a module in Slot 1 of a VMEbus system.
-- If this is the case, then after reset, the input pin 'bg3n_in' sets the
-- SYSCON bit in the SYSCTL-Register. If this bit is set wrong (external
-- Slot01-detection failed), it can be set/reset through the PowerPC-bus.
--
-- The WBB2VME core supports bus arbitration for all levels. If the location is 
-- detected in slot 1, the arbitration logic is enabled and handles all requests 
-- on signals vme_br[3..0] in a round-robin manner. 
-- If more than one master requests the bus on the same level, the daisy-chain 
-- architecture arbitrates the accesses. This results in: if a master is located 
-- near to slot 1, it has the higher priority than the one which is located far 
-- away from slot 1.
-- If more than one master request the bus on different levels, the arbitration 
-- scheme is round-robin, which results in an equal bus occupation of the 
-- masters.
-- The bus occupation is also depending on the requesters behavior and need to be 
-- considered for system arbitration concepts. There are two options: 
-- release-on-request and release-when-done.
--------------------------------------------------------------------------------
-- Hierarchy:
-- wbb2vme
--    vme_ctrl
--       vme_arbiter
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
-- $Revision: 1.3 $
--
-- $Log: vme_arbiter.vhd,v $
-- Revision 1.3  2012/11/12 08:13:15  MMiehling
-- changed comments
--
-- Revision 1.2  2012/08/27 12:57:27  MMiehling
-- changed comments
--
-- Revision 1.1  2012/03/29 10:14:53  MMiehling
-- Initial Revision
--
-- Revision 1.6  2006/05/18 14:28:59  MMiehling
-- changed fsm to moore-type
-- arbitration failures when pci2vme is in slot1 => bugfix in deglitcher
--
-- Revision 1.5  2004/11/02 11:29:48  mmiehling
-- removed cnt from severity list
--
-- Revision 1.4  2003/12/01 10:03:46  MMiehling
-- changed arbitres
--
-- Revision 1.3  2003/06/13 10:06:29  MMiehling
-- deglitched bbsyn
--
-- Revision 1.2  2003/04/22 11:02:54  MMiehling
-- improved fsm
--
-- Revision 1.1  2003/04/01 13:04:39  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY vme_arbiter IS
   PORT (
      clk               : IN  std_logic;     
      rst               : IN  std_logic;
   
      bgintn            : OUT std_logic_vector(3 DOWNTO 0); -- bus grant for all levels
       
      -- vme_du
      set_ato           : OUT std_logic;     -- if bit is set => ato bit will be set
      sysc_bit          : IN  std_logic;     -- '1' if board is in slot 1 => enables this vme arbiter
      bgouten           : IN  std_logic;     -- enables SGL and bg3out signal
       
      -- PINs:
      br_i_n            : IN std_logic_vector(3 DOWNTO 0);            -- bus requests monitored (FAIR)
      bg_i_n            : IN std_logic_vector(3 DOWNTO 0);            -- passed in idle state
      bbsyn_in          : IN  std_logic
   );
--
END vme_arbiter;

ARCHITECTURE vme_arbiter_arc OF vme_arbiter IS

--   TYPE arbit_states IS (idle, grant); -- SGL states
   TYPE arbit_states IS (grant_0, grant_0_idle, grant_1, grant_1_idle, grant_2, grant_2_idle, grant_3, grant_3_idle); -- Round-Robin states
   SIGNAL arbit_state : arbit_states;
  
   SIGNAL br_i_n_q   : std_logic_vector(3 DOWNTO 0);
   SIGNAL bbsyn_degl : std_logic;
   SIGNAL bg_i_n_q   : std_logic_vector(3 DOWNTO 0);
   SIGNAL atoresn    : std_logic;
   SIGNAL arbitres   : std_logic;
   SIGNAL ibgoutn    : std_logic_vector(3 DOWNTO 0);
   SIGNAL bbsyn_q    : std_logic;
   SIGNAL bbsyn_qq   : std_logic;
   SIGNAL bbsyn_qqq  : std_logic;
   SIGNAL cnt        : std_logic_vector(10 DOWNTO 0);
  
BEGIN

-------------------------------------------------------------------------------
-- Synchronizing asynchronous VMEbus inputs:
-------------------------------------------------------------------------------

  syncinp : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      br_i_n_q    <= (OTHERS => '1');
      bg_i_n_q    <= (OTHERS => '1');
      bbsyn_degl  <= '1';
      bbsyn_q     <= '1';
      bbsyn_qq    <= '1';
      bbsyn_qqq   <= '1';
    ELSIF clk'event AND clk = '1' THEN
      br_i_n_q    <= br_i_n;
      bg_i_n_q    <= bg_i_n;
      bbsyn_q     <= bbsyn_in;
      bbsyn_qq    <= bbsyn_q;
      bbsyn_qqq   <= bbsyn_qq;
      
      -- deglitching of bus busy signal
      IF bbsyn_q = '0' AND bbsyn_qq = '0' AND bbsyn_qqq = '0' THEN
         bbsyn_degl <= '0';
      ELSIF bbsyn_q = '1' AND bbsyn_qq = '1' AND bbsyn_qqq = '1' THEN
         bbsyn_degl <= '1';
      ELSE
         bbsyn_degl <= bbsyn_degl;
      END IF;
    END IF;
  END PROCESS syncinp;


-------------------------------------------------------------------------------
-- Arbiter drives bus grant daisy chain if in slot 1
-------------------------------------------------------------------------------

  -- depending on activation of internal Arbiter, the bus grant signal comes
  -- either from VMEbus or internal Arbiter. Selection with System Controller bit

  -- the slot1 detection takes longer than this, therefore the enable signal bgouten
  -- controls the startup until slot1-detection is done
  
   bgintn <=      ibgoutn  WHEN sysc_bit = '1' AND bgouten = '1' ELSE  -- if in slot1 => insert single level arbiter
                  bg_i_n_q WHEN sysc_bit = '0' AND bgouten = '1' ELSE  -- if not slot1 => feed through bus grant
                  "1111";                                              -- during powerup => drive with '1' for slot1 detection logic

 
---------------------------------------------------------------------------------
---- The Single Level Arbiter (SGL). sysc_bit must be set for it to work.
---------------------------------------------------------------------------------
--arbit_fsm : PROCESS (clk, rst)
--  BEGIN
--   IF rst = '1' THEN
--      arbit_state <= idle;
--      ibgoutn <= "1111";
--     ELSIF clk'EVENT AND clk = '1' THEN
--        CASE arbit_state IS
--           WHEN idle =>
--            IF br_i_n_q(3) = '0' AND bbsyn_degl = '1' AND sysc_bit = '1' THEN
--               arbit_state <= grant;
--               ibgoutn <= "0111";      -- grant on level 3
--            ELSE
--               arbit_state <= idle;
--               ibgoutn <= "1111";
--            END IF;
--           
--           WHEN grant => 
--            IF bbsyn_degl = '0' THEN
--               arbit_state <= idle;
--               ibgoutn <= "1111";
--            ELSE
--               arbit_state <= grant;
--               ibgoutn <= "0111";      -- grant on level 3
--            END IF;
--           
--           WHEN OTHERS =>
--              arbit_state <= idle;
--              ibgoutn <= "1111";
--        END CASE;
--     END IF;
--  END PROCESS arbit_fsm;
  
-------------------------------------------------------------------------------
-- Round-Robin Arbiter: sysc_bit must be set for it to work.
-------------------------------------------------------------------------------
arbit_fsm : PROCESS (clk, rst)
  BEGIN
   IF rst = '1' THEN
      arbit_state <= grant_0_idle;
      ibgoutn <= "1111";
   ELSIF clk'EVENT AND clk = '1' THEN
      CASE arbit_state IS
         WHEN grant_0 => 
          IF bbsyn_degl = '0' THEN      -- master has occupied bus => remove grant
             arbit_state <= grant_0_idle;
             ibgoutn <= "1111";
          ELSIF br_i_n_q(0) /= '0' OR arbitres = '1' THEN -- request was removed before access started or arbitration timeout occured
             arbit_state <= grant_0_idle;
             ibgoutn <= "1111";
          ELSE
             arbit_state <= grant_0;
             ibgoutn <= "1110";      -- grant on level 0
          END IF;
      
         WHEN grant_0_idle =>
          IF br_i_n_q(1) = '0' AND bbsyn_degl = '1' AND sysc_bit = '1' THEN
             arbit_state <= grant_1;
             ibgoutn <= "1101";      -- grant on level 1
          ELSIF br_i_n_q(2) = '0' AND bbsyn_degl = '1' AND sysc_bit = '1' THEN
             arbit_state <= grant_2;
             ibgoutn <= "1011";      -- grant on level 2
          ELSIF br_i_n_q(3) = '0' AND bbsyn_degl = '1' AND sysc_bit = '1' THEN
             arbit_state <= grant_3;
             ibgoutn <= "0111";      -- grant on level 3
          ELSIF br_i_n_q(0) = '0' AND bbsyn_degl = '1' AND sysc_bit = '1' THEN
             arbit_state <= grant_0;
             ibgoutn <= "1110";      -- grant on level 0
          ELSE
             arbit_state <= grant_0_idle;
             ibgoutn <= "1111";
          END IF;
      
         WHEN grant_1 => 
          IF bbsyn_degl = '0' THEN
             arbit_state <= grant_1_idle;
             ibgoutn <= "1111";
          ELSIF br_i_n_q(1) /= '0' OR arbitres = '1' THEN -- request was removed before access started or arbitration timeout occured
             arbit_state <= grant_0_idle;
             ibgoutn <= "1111";
          ELSE
             arbit_state <= grant_1;
             ibgoutn <= "1101";      -- grant on level 1
          END IF;
      
         WHEN grant_1_idle =>
          IF br_i_n_q(2) = '0' AND bbsyn_degl = '1' AND sysc_bit = '1' THEN
             arbit_state <= grant_2;
             ibgoutn <= "1011";      -- grant on level 2
          ELSIF br_i_n_q(3) = '0' AND bbsyn_degl = '1' AND sysc_bit = '1' THEN
             arbit_state <= grant_3;
             ibgoutn <= "0111";      -- grant on level 3
          ELSIF br_i_n_q(0) = '0' AND bbsyn_degl = '1' AND sysc_bit = '1' THEN
             arbit_state <= grant_0;
             ibgoutn <= "1110";      -- grant on level 0
          ELSIF br_i_n_q(1) = '0' AND bbsyn_degl = '1' AND sysc_bit = '1' THEN
             arbit_state <= grant_1;
             ibgoutn <= "1101";      -- grant on level 1
          ELSE
             arbit_state <= grant_1_idle;
             ibgoutn <= "1111";
          END IF;
      
         WHEN grant_2 => 
          IF bbsyn_degl = '0' THEN
             arbit_state <= grant_2_idle;
             ibgoutn <= "1111";
          ELSIF br_i_n_q(2) /= '0' OR arbitres = '1' THEN -- request was removed before access started or arbitration timeout occured
             arbit_state <= grant_0_idle;
             ibgoutn <= "1111";
          ELSE
             arbit_state <= grant_2;
             ibgoutn <= "1011";      -- grant on level 2
          END IF;
      
         WHEN grant_2_idle =>
          IF br_i_n_q(3) = '0' AND bbsyn_degl = '1' AND sysc_bit = '1' THEN
             arbit_state <= grant_3;
             ibgoutn <= "0111";      -- grant on level 3
          ELSIF br_i_n_q(0) = '0' AND bbsyn_degl = '1' AND sysc_bit = '1' THEN
             arbit_state <= grant_0;
             ibgoutn <= "1110";      -- grant on level 0
          ELSIF br_i_n_q(1) = '0' AND bbsyn_degl = '1' AND sysc_bit = '1' THEN
             arbit_state <= grant_1;
             ibgoutn <= "1101";      -- grant on level 1
          ELSIF br_i_n_q(2) = '0' AND bbsyn_degl = '1' AND sysc_bit = '1' THEN
             arbit_state <= grant_2;
             ibgoutn <= "1011";      -- grant on level 2
          ELSE
             arbit_state <= grant_2_idle;
             ibgoutn <= "1111";
          END IF;
      
         WHEN grant_3 => 
          IF bbsyn_degl = '0' THEN
             arbit_state <= grant_3_idle;
             ibgoutn <= "1111";
          ELSIF br_i_n_q(3) /= '0' OR arbitres = '1' THEN -- request was removed before access started or arbitration timeout occured
             arbit_state <= grant_0_idle;
             ibgoutn <= "1111";
          ELSE
             arbit_state <= grant_3;
             ibgoutn <= "0111";      -- grant on level 3
          END IF;
         
         WHEN grant_3_idle =>
          IF br_i_n_q(0) = '0' AND bbsyn_degl = '1' AND sysc_bit = '1' THEN
             arbit_state <= grant_0;
             ibgoutn <= "1110";      -- grant on level 0
          ELSIF br_i_n_q(1) = '0' AND bbsyn_degl = '1' AND sysc_bit = '1' THEN
             arbit_state <= grant_1;
             ibgoutn <= "1101";      -- grant on level 1
          ELSIF br_i_n_q(2) = '0' AND bbsyn_degl = '1' AND sysc_bit = '1' THEN
             arbit_state <= grant_2;
             ibgoutn <= "1011";      -- grant on level 2
          ELSIF br_i_n_q(3) = '0' AND bbsyn_degl = '1' AND sysc_bit = '1' THEN
             arbit_state <= grant_3;
             ibgoutn <= "0111";      -- grant on level 3
          ELSE
             arbit_state <= grant_3_idle;
             ibgoutn <= "1111";
          END IF;
      
         WHEN OTHERS =>
            arbit_state <= grant_0_idle;
            ibgoutn <= "1111";
      END CASE;
   END IF;
END PROCESS arbit_fsm;
  

-------------------------------------------------------------------------------
-- The Counters (Timers)
-------------------------------------------------------------------------------  
-- Arbiter TimeOut. Works only when sysc_bit is set.

  atoresn <= '0' WHEN (rst = '1' OR bbsyn_degl = '0' OR sysc_bit = '0') ELSE '1';
             
arbit_to : PROCESS (clk, rst, cnt)  
   BEGIN
      IF rst = '1' THEN
         cnt <= (OTHERS => '0');
      ELSIF clk'event AND clk = '1' THEN
         IF atoresn = '0' THEN
            cnt    <= (OTHERS => '0');
         ELSIF ibgoutn /= "1111" THEN          -- each time bus is granted, counting
            cnt  <= cnt + '1';
         END IF;
      END IF;
      
      arbitres <= cnt(10);
   END PROCESS arbit_to;
   
   set_ato <= arbitres;
   
   
   
END vme_arbiter_arc;

