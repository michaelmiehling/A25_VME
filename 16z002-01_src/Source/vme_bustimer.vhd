--------------------------------------------------------------------------------
-- Title         : VME Bustimer
-- Project       : A15
--------------------------------------------------------------------------------
-- File          : vme_bustimer.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 10/02/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- This module handles the resets and the vme bus access time-out counting.
-- 
--------------------------------------------------------------------------------
-- Hierarchy:
-- wbb2vme
--    vme_ctrl
--       vme_bustimer
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
-- $Log: vme_bustimer.vhd,v $
-- Revision 1.3  2014/04/17 07:35:29  MMiehling
-- added signal prevent_sysrst
--
-- Revision 1.2  2012/08/27 12:57:22  MMiehling
-- changed minimum vme reset time to 1 ms
-- general rework of reset handling
--
-- Revision 1.1  2012/03/29 10:14:50  MMiehling
-- Initial Revision
--
-- Revision 1.13  2006/06/02 15:48:55  MMiehling
-- removed sysfailn_int from fsm to reduce logic (now active when startup_rstn active)
--
-- Revision 1.12  2006/05/18 14:29:03  MMiehling
-- arbitration failures when pci2vme is in slot1 => bugfix in deglitcher
-- corrected time-out counter description
-- changed reset release behaviour
--
-- Revision 1.11  2005/02/04 13:44:12  mmiehling
-- added generic simulation
--
-- Revision 1.10  2004/11/02 11:29:53  mmiehling
-- added registered rstn
--
-- Revision 1.9  2004/07/27 17:15:37  mmiehling
-- changed pci-core to 16z014
-- changed wishbone bus to wb_bus.vhd
-- added clk_trans_wb2wb.vhd
-- improved dma
--
-- Revision 1.8  2004/06/17 13:02:26  MMiehling
-- removed clr_hit and sl_acc_reg
--
-- Revision 1.7  2003/12/17 15:51:43  MMiehling
-- sysfailn must be 1 or 0 because external driver makes z
--
-- Revision 1.6  2003/12/01 10:03:51  MMiehling
-- v2p_rstn is open collector now
--
-- Revision 1.5  2003/07/14 08:38:06  MMiehling
-- added sysfailn_int; changed rst_counter
--
-- Revision 1.4  2003/06/24 13:47:06  MMiehling
-- changed vme and cpu reset
--
-- Revision 1.3  2003/06/13 10:06:33  MMiehling
-- changed rst_fsm and slot1 detection
--
-- Revision 1.2  2003/04/22 11:02:58  MMiehling
-- reset does not work
--
-- Revision 1.1  2003/04/01 13:04:41  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY vme_bustimer IS
  PORT (
   clk               : IN  std_logic;           -- global clock
   rst               : IN  std_logic;           -- global reset
   startup_rst       : IN std_logic;           -- powerup reset
   prevent_sysrst    : IN std_logic;            -- if "1", sysrst_n_out will not be activated after powerup,
                                                -- if "0", sysrst_n_out will be activated if in slot1 and system reset is active (sysc_bit or rst)
   
   set_sysc          : OUT std_logic;           -- if set sysc-bit will be set
   sysc_bit          : IN std_logic;            -- 1=slot1 0=slotx
   clr_sysr          : OUT std_logic;           -- if set sysr-bit will be cleared
   sysr_bit          : IN std_logic;            -- 1=system reset

   -- connected with Slave Unit
   dsain             : IN std_logic;            -- data strobe a in
   dsbin             : IN std_logic;            -- data strobe b in
   bgouten           : OUT std_logic;           -- enables SGL and bg3out signal
   -- bus grant daisy chain is driven through requester in Access VME:
   -----------------------------------------------------------------------
   -- PINs:
   sysfailn          : OUT   std_logic;         -- indicates when A15 is not ready or in reset
   sysrstn_in        : IN  std_logic;
   sysrstn_out       : OUT std_logic;
   v2p_rstn          : OUT std_logic;           -- Reset between VMEbus and PowerPC-bus
   bg3n_in           : IN  std_logic;           -- bus grant signal in (if not connected => slot01)
   slot01n           : OUT std_logic;           -- enables V_SYSCLK (16 MHz)
   berrn_out         : OUT std_logic            -- bus error 
    );
--
END vme_bustimer;

ARCHITECTURE bustimer_arc OF vme_bustimer IS

   CONSTANT CONST_10US     : std_logic_vector(9 DOWNTO 0):= "1010011011";        -- =667 @ 66MHz => 10,005 us
   CONSTANT CONST_200MS    : std_logic_vector(14 DOWNTO 0):= "100111000010111";  -- = 19991 @ 10,005us => 
   -- counter value for vme rstn => 250ms
   
   SIGNAL btresn           : std_logic;   -- bus timer reset
   SIGNAL cnt              : std_logic_vector(12 DOWNTO 0); -- approximately 60 us
   SIGNAL sysrstn_out_int  : std_logic;
   SIGNAL v2p_rstn_int     : std_logic;

   TYPE rst_states IS (IDLE, WAIT_ON_RST, RST_VME, RST_VME2, WAIT_ON_VME, RST_CPU, WAIT_ON_CPU, STARTUP_END);
   SIGNAL rst_state        : rst_states;
   
   SIGNAL pre_cnt          : std_logic_vector(9 DOWNTO 0);
   SIGNAL pre_cnt_end      : std_logic;
   SIGNAL rst_pre_cnt      : std_logic;
   SIGNAL rst_main_cnt     : std_logic;
   SIGNAL main_cnt         : std_logic_vector(14 DOWNTO 0);
   SIGNAL main_cnt_max_sig : std_logic_vector(14 DOWNTO 0);
   SIGNAL main_cnt_end     : std_logic;
   SIGNAL sysrstn_q        : std_logic;
   SIGNAL sysrstn_qq       : std_logic;
   SIGNAL sysrstn_qqq      : std_logic;
   SIGNAL degl_sysrstn     : std_logic;
   SIGNAL rst_q            : std_logic;
   SIGNAL rst_qq           : std_logic;
   SIGNAL rst_qqq          : std_logic;
   SIGNAL degl_rst         : std_logic;
   SIGNAL dsain_q          : std_logic;
   SIGNAL dsbin_q          : std_logic;
   SIGNAL bg3n_in_q        : std_logic;
   SIGNAL bg3n_in_qq       : std_logic;
   SIGNAL pre_cnt_max_sig  : std_logic_vector(9 DOWNTO 0);
   SIGNAL set_sysc_int     : std_logic;
   
BEGIN

   slot01n <= NOT sysc_bit;
   sysrstn_out <= sysrstn_out_int;
   set_sysc <= set_sysc_int;
   
v2p : PROCESS(v2p_rstn_int)
  BEGIN
     IF v2p_rstn_int = '0' THEN
        v2p_rstn <= '0';
     ELSE
        v2p_rstn <= 'Z';
     END IF;
  END PROCESS v2p;
   
   sysfailn <= '0' WHEN startup_rst = '1' ELSE '1';

   
-------------------------------------------------------------------------------
-- Bus Timer. Works only when sysc_bit is set. Generates a bus error after 62 us
-- During normal operation, reset is triggered each
-- time both VMEbus Datastrobes are high.
-------------------------------------------------------------------------------

  btresn   <= '1' WHEN (dsain_q = '1' AND dsbin_q = '1') ELSE '0';

degl : PROCESS(clk, startup_rst)
  BEGIN
    IF startup_rst = '1' THEN
      sysrstn_q <= '1';
      sysrstn_qq <= '1';
      sysrstn_qqq <= '1';
      degl_sysrstn <= '1';
      rst_q <= '0';
      rst_qq <= '0';
      rst_qqq <= '0';
      degl_rst <= '0';
      bg3n_in_q <= '1';
      bg3n_in_qq <= '1';
    ELSIF clk'EVENT AND clk = '1' THEN
       bg3n_in_q <= bg3n_in;
       bg3n_in_qq <= bg3n_in_q;
       sysrstn_q <= sysrstn_in;
       sysrstn_qq <= sysrstn_q;
       sysrstn_qqq <= sysrstn_qq;
       IF sysrstn_q = '0' AND sysrstn_qq = '0' AND sysrstn_qqq = '0' THEN
          degl_sysrstn <= '0';
       ELSIF sysrstn_q = '1' AND sysrstn_qq = '1' AND sysrstn_qqq = '1' THEN
          degl_sysrstn <= '1';
       ELSE
          degl_sysrstn <= degl_sysrstn;
       END IF;
     
        rst_q <= rst;
        rst_qq <= rst_q;
        rst_qqq <= rst_qq;
        IF rst_q = '1' AND rst_qq = '1' AND rst_qqq = '1' THEN
           degl_rst <= '1';
        ELSIF rst_q = '0' AND rst_qq = '0' AND rst_qqq = '0' THEN
           degl_rst <= '0';
        END IF;
     END IF;
  END PROCESS degl;  
  
bustim : PROCESS (clk, rst)     
  BEGIN
    IF rst = '1' THEN
      cnt     <= (OTHERS => '0');
      berrn_out <= '1';
      dsain_q <= '1';
      dsbin_q <= '1';
    ELSIF clk'event AND clk = '1' THEN
      dsain_q <= dsain;
      dsbin_q <= dsbin;

      IF (btresn = '1') THEN
        cnt     <= (OTHERS => '0');
      ELSIF (dsain_q = '0' OR dsbin_q = '0') AND sysc_bit = '1' THEN         -- counter starts with DSA or DSB signal
        cnt   <= cnt + 1;
      END IF;

      IF cnt(12) = '1' THEN
         berrn_out <= '0';
      ELSIF btresn = '1' THEN
         berrn_out <= '1';
      END IF;
    END IF;
  END PROCESS bustim;
  
  
pre_cnt_max_sig <= CONST_10US;
main_cnt_max_sig <= CONST_200MS;

rst_cnt : PROCESS(clk, startup_rst)
  BEGIN
     IF startup_rst = '1' THEN
        main_cnt <= (OTHERS => '0');
        pre_cnt <= (OTHERS => '0');
        main_cnt_end <= '0';
        pre_cnt_end <= '0';
     ELSIF clk'EVENT AND clk = '1' THEN
     -- pre counter for counting up to 10 us
      IF rst_pre_cnt = '1' THEN
         pre_cnt <= (OTHERS => '0');
         pre_cnt_end <= '0';
      ELSIF pre_cnt = pre_cnt_max_sig THEN
         pre_cnt <= (OTHERS => '0');
         pre_cnt_end <= '1';
      ELSE
         pre_cnt <= pre_cnt + 1;
         pre_cnt_end <= '0';
      END IF;
      
      -- main counter with base of 10 us counts up to 200 ms reset time
      IF rst_main_cnt = '1' THEN 
         main_cnt <= (OTHERS => '0');
         main_cnt_end <= '0';
      ELSIF main_cnt = main_cnt_max_sig AND pre_cnt_end = '1' THEN 
         main_cnt <= (OTHERS => '0');
         main_cnt_end <= '1';
      ELSIF pre_cnt_end = '1' THEN
         main_cnt <= main_cnt + 1;
         main_cnt_end <= '0';
      END IF;
   END IF;
  END PROCESS rst_cnt;
  
            
rst_fsm : PROCESS (clk, startup_rst)
BEGIN
   IF startup_rst = '1' THEN
      set_sysc_int            <= '0';
      bgouten                 <= '0';
      sysrstn_out_int         <= '0';
      v2p_rstn_int            <= '1';
      clr_sysr                <= '0';
      rst_state               <= IDLE;
      rst_pre_cnt             <= '0';
      rst_main_cnt            <= '0';
   ELSIF clk'EVENT AND clk = '1' THEN
      IF set_sysc_int = '1' AND sysc_bit = '1' THEN                                  -- if status reg has stored slot 1 location => clear request to set bit
         set_sysc_int <= '0';
      ELSIF bg3n_in_qq = '0' AND main_cnt_end = '1' AND rst_state = IDLE THEN    -- slot 1 was detected => keep in mind until stored in status reg
         set_sysc_int <= '1';
      END IF;
      CASE rst_state IS
         -- wait until powerup reset time has elapsed (16383 * system_clock_period = 250 us @ 66MHz)
         WHEN IDLE =>
            bgouten              <= '0';
            sysrstn_out_int      <= '0';              -- activate reset to vme-bus
            v2p_rstn_int         <= '1';              -- no reset to cpu
            clr_sysr             <= '0';
            IF main_cnt_end = '1' THEN
               rst_state         <= STARTUP_END;
               rst_pre_cnt       <= '0';
               rst_main_cnt            <= '0';
            ELSE
               rst_state         <= IDLE;
               rst_pre_cnt       <= '0';
               rst_main_cnt            <= '0';
            END IF;
         
         -- release vme reset and wait for deactivation of vme- and cpu-reset (minimum 16383 * system_clock_period = 250 us @ 66MHz)
         WHEN STARTUP_END =>
            bgouten              <= '0';
            sysrstn_out_int      <= '1';              -- no reset to vme-bus
            v2p_rstn_int         <= '1';              -- no reset to cpu
            clr_sysr             <= '0';
            IF main_cnt_end = '1' AND degl_rst = '0' AND degl_sysrstn = '1' THEN   -- wait until cpu and vme does not deliver active reset
               rst_state         <= WAIT_ON_RST;
               rst_pre_cnt       <= '0';
               rst_main_cnt            <= '0';
            ELSE
               rst_state         <= STARTUP_END;
               rst_pre_cnt       <= '0';
               rst_main_cnt            <= '0';
            END IF;

         -- normal operation: wait until either cpu-reset or vme-reset is active
         WHEN WAIT_ON_RST =>
            bgouten              <= '1';
            sysrstn_out_int      <= '1';              -- no reset to vme-bus
            clr_sysr             <= '0';           
            v2p_rstn_int         <= '1';              -- no reset to cpu
            IF (degl_rst = '1' OR sysr_bit = '1') AND sysc_bit = '1' THEN          -- in slot 1 and cpu or bit has active reset
               rst_state         <= RST_VME;
               rst_pre_cnt       <= '0';
               rst_main_cnt            <= '1';
            ELSIF degl_sysrstn = '0' THEN                       -- not in slot 1 and vme-bus has active reset
               rst_state         <= RST_CPU;
               rst_pre_cnt       <= '1';                                            -- clear counter in order to set cpu 10 us to reset
               rst_main_cnt            <= '0';
            ELSE
               rst_state         <= WAIT_ON_RST;
               rst_pre_cnt       <= '0';
               rst_main_cnt            <= '0';
            END IF;

         -- set cpu reset active
         WHEN RST_CPU =>
            bgouten              <= '1';
            sysrstn_out_int      <= '1';              -- no reset to vme-bus
            v2p_rstn_int         <= '0';              -- active reset to cpu 
            clr_sysr             <= '0';
            IF pre_cnt_end = '1' THEN         -- after 10 us, release cpu reset
               rst_state         <= WAIT_ON_CPU;
               rst_pre_cnt       <= '0';
               rst_main_cnt            <= '0';
            ELSE
               rst_state         <= RST_CPU;
               rst_pre_cnt       <= '0';
               rst_main_cnt            <= '0';
            END IF;
         
         -- wait until vme-reset has got deactivated
         WHEN WAIT_ON_CPU =>
            bgouten              <= '1';
            sysrstn_out_int      <= '1';              -- no reset to vme-bus
            v2p_rstn_int         <= degl_sysrstn;     
            clr_sysr             <= '0';
            IF degl_sysrstn = '1' AND degl_rst = '0' THEN     -- wait until vme-bus and cpu reset is inactive
               rst_state         <= WAIT_ON_RST;
               rst_pre_cnt       <= '0';
               rst_main_cnt            <= '0';
            ELSE
               rst_state         <= WAIT_ON_CPU;
               rst_pre_cnt       <= '0';
               rst_main_cnt            <= '0';
            END IF;
         
         -- activate vme reset for (16383 * system_clock_period = 250 us @ 66MHz)
         WHEN RST_VME =>
            bgouten              <= '1';
            IF prevent_sysrst = '1' THEN 
               sysrstn_out_int      <= '1';              -- no reset
            ELSE
               sysrstn_out_int      <= '0';              -- active reset to vme-bus
            END IF;
            v2p_rstn_int         <= '1';              -- no reset to cpu
            clr_sysr             <= '1';
            IF main_cnt_end = '1' THEN             -- keep vme-bus reset active for counter time
               rst_state         <= RST_VME2;
               rst_pre_cnt       <= '0';
               rst_main_cnt            <= '0';
            ELSE
               rst_state         <= RST_VME;
               rst_pre_cnt       <= '0';
               rst_main_cnt            <= '0';
            END IF;
      
         -- extend active vme reset time for (16383 * system_clock_period = 250 us @ 66MHz) till cpu reset has got deactivated
         WHEN RST_VME2 =>
            bgouten              <= '1';
            IF prevent_sysrst = '1' THEN 
               sysrstn_out_int      <= '1';              -- no reset
            ELSE
               sysrstn_out_int      <= '0';              -- active reset to vme-bus
            END IF;
            v2p_rstn_int         <= '1';           -- no reset to cpu
            clr_sysr             <= '1';
            IF main_cnt_end = '1' AND degl_rst = '0' THEN  -- wait until cpu-reset is inactive
               rst_state         <= WAIT_ON_VME;
               rst_pre_cnt       <= '0';
               rst_main_cnt            <= '0';
            ELSE
               rst_state         <= RST_VME2;
               rst_pre_cnt       <= '0';
               rst_main_cnt            <= '0';
            END IF;
      
         -- wait until vme reset has got deactivated
         WHEN WAIT_ON_VME =>
            bgouten              <= '1';
            sysrstn_out_int      <= '1';           -- no reset to vme-bus
            v2p_rstn_int         <= '1';           -- no reset to cpu
            clr_sysr             <= '0';
            IF degl_sysrstn = '1' THEN             -- wait until vme-bus reset is inactive
               rst_state         <= WAIT_ON_RST;
               rst_pre_cnt       <= '0';
               rst_main_cnt            <= '0';
            ELSE
               rst_state         <= WAIT_ON_VME;
               rst_pre_cnt       <= '0';
               rst_main_cnt            <= '0';
            END IF;
     
         WHEN OTHERS =>
            bgouten              <= '0';
            sysrstn_out_int      <= '1';
            v2p_rstn_int         <= '1';
            clr_sysr             <= '0';
            rst_state            <= WAIT_ON_RST;
            rst_pre_cnt          <= '0';
            rst_main_cnt            <= '0';
      END CASE;
   END IF;
END PROCESS rst_fsm;
  
 
END bustimer_arc;

