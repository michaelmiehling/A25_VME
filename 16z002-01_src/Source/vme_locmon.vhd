--------------------------------------------------------------------------------
-- Title         : Location Monitor
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : vme_locmon.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 08/04/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- The WBB2VME core supports two independent Location Monitors. Each can be used 
-- to monitor the VMEbus in order to notify the CPU about write/read accesses to 
-- a predefined VME address, even if the WBB2VME master or slave is not used for 
-- this transaction. If a hit is found, the notification is done by interrupt 
-- (signaled via locmon_irq to WBB).
--------------------------------------------------------------------------------
-- Hierarchy:
--
-- vme_ctrl
--    vme_locmon
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
-- $Revision: 1.2 $
--
-- $Log: vme_locmon.vhd,v $
-- Revision 1.2  2012/11/12 08:13:08  MMiehling
-- bugfix locmon: registered addresses before evaluation in order to get stable results
--
-- Revision 1.1  2012/03/29 10:14:38  MMiehling
-- Initial Revision
--
-- Revision 1.5  2005/02/04 13:44:07  mmiehling
-- added combinations of addr3+4; changed locmon_en timing
--
-- Revision 1.4  2004/11/02 11:29:20  mmiehling
-- improved timing and area
--
-- Revision 1.3  2003/12/01 10:03:06  MMiehling
-- adopted to changed vme_adr timing
--
-- Revision 1.2  2003/06/13 10:06:12  MMiehling
-- added address bits 3+4
--
-- Revision 1.1  2003/04/22 11:07:25  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY vme_locmon IS
PORT (
   clk                     : IN std_logic;                     -- 66 MHz
   rst                     : IN std_logic;                     -- global reset signal (asynch)

   en_vme_adr_in           : IN std_logic;                     -- samples adress and am after asn goes low
   ma_en_vme_data_out_reg  : IN std_logic;                     -- enable of vme_adr_out
   sl_writen_reg           : IN std_logic;                     -- vme write/read
   vme_adr_locmon          : IN std_logic_vector(31 DOWNTO 2); -- vme adress for location monitoring (registered with en_vme_adr_in)
   vam_reg                 : IN std_logic_vector(5 DOWNTO 0);  -- vme registered vam_in
   
   clr_locmon              : IN std_logic_vector(1 DOWNTO 0);  -- clear address combination bits when clear status bit
   loc_sel                 : OUT std_logic_vector(1 DOWNTO 0); -- these bits are loaded with combinations of address bits [4:3] if locmon hit address         
   loc_am_0                : IN std_logic_vector(1 DOWNTO 0);  -- loc-monitor #0 - adress modus "00"-A32, "10"-A16, "11"-A24
   loc_am_1                : IN std_logic_vector(1 DOWNTO 0);  -- loc-monitor #1 - adress modus "00"-A32, "10"-A16, "11"-A24
   loc_irq_0               : OUT std_logic;                    -- loc-monitor #0 - irq
   loc_irq_1               : OUT std_logic;                    -- loc-monitor #1 - irq
   loc_rw_0                : IN std_logic_vector(1 DOWNTO 0);  -- [0]: read; [1]: write
   loc_rw_1                : IN std_logic_vector(1 DOWNTO 0);  -- [0]: read; [1]: write
   loc_adr_0               : IN std_logic_vector(31 DOWNTO 0); -- location monitor #0 adress
   loc_adr_1               : IN std_logic_vector(31 DOWNTO 0)  -- location monitor #1 adress
   
     );
END vme_locmon;

ARCHITECTURE vme_locmon_arch OF vme_locmon IS 
   SIGNAL sl_writen_req_q   : std_logic;
   SIGNAL locmon_en           : std_logic;
   SIGNAL locmon_en_q         : std_logic;
   SIGNAL adr_0_equal         : std_logic_vector(2 DOWNTO 0);
   SIGNAL adr_1_equal         : std_logic_vector(2 DOWNTO 0);
   SIGNAL vam_0_equal         : std_logic;
   SIGNAL vam_1_equal         : std_logic;
   SIGNAL loc_hit_am_0        : std_logic_vector(2 DOWNTO 0);
   SIGNAL loc_hit_am_1        : std_logic_vector(2 DOWNTO 0);
   SIGNAL en_vme_adr_in_q     : std_logic;
   SIGNAL en_vme_adr_in_flag  : std_logic;
   SIGNAL vme_adr_locmon_q    : std_logic_vector(31 DOWNTO 2);
   SIGNAL vam_reg_q           : std_logic_vector(5 DOWNTO 4);
BEGIN

   en_vme_adr_in_flag <= '1' WHEN en_vme_adr_in = '1' AND en_vme_adr_in_q = '0' ELSE '0';
   loc_sel <= vme_adr_locmon_q(4 DOWNTO 3);

   -- locmon_0
   adr_0_equal(0) <= '1' WHEN vme_adr_locmon_q(15 DOWNTO 10) = loc_adr_0(15 DOWNTO 10) ELSE '0';
   adr_0_equal(1) <= '1' WHEN vme_adr_locmon_q(23 DOWNTO 16) = loc_adr_0(23 DOWNTO 16) ELSE '0';
   adr_0_equal(2) <= '1' WHEN vme_adr_locmon_q(31 DOWNTO 24) = loc_adr_0(31 DOWNTO 24) ELSE '0';

   vam_0_equal <= '1' WHEN vam_reg_q = loc_am_0 ELSE '0';
   
   -- A32
   loc_hit_am_0(0) <= '1' WHEN loc_am_0 = "00" AND adr_0_equal(2 DOWNTO 0) = "111" AND vam_0_equal = '1' AND 
                  ((loc_rw_0(0) = '1' AND sl_writen_req_q = '1') OR (loc_rw_0(1) = '1' AND sl_writen_req_q = '0')) ELSE '0';
   -- A16
   loc_hit_am_0(1) <= '1' WHEN loc_am_0 = "10" AND adr_0_equal(0) = '1' AND vam_0_equal = '1' AND 
                  ((loc_rw_0(0) = '1' AND sl_writen_req_q = '1') OR (loc_rw_0(1) = '1' AND sl_writen_req_q = '0')) ELSE '0';
   -- A24      
   loc_hit_am_0(2) <= '1' WHEN loc_am_0 = "11" AND adr_0_equal(1 DOWNTO 0) = "11" AND vam_0_equal = '1' AND
                  ((loc_rw_0(0) = '1' AND sl_writen_req_q = '1') OR (loc_rw_0(1) = '1' AND sl_writen_req_q = '0')) ELSE '0';

   -- locmon_1
   adr_1_equal(0) <= '1' WHEN vme_adr_locmon_q(15 DOWNTO 10) = loc_adr_1(15 DOWNTO 10) ELSE '0';
   adr_1_equal(1) <= '1' WHEN vme_adr_locmon_q(23 DOWNTO 16) = loc_adr_1(23 DOWNTO 16) ELSE '0';
   adr_1_equal(2) <= '1' WHEN vme_adr_locmon_q(31 DOWNTO 24) = loc_adr_1(31 DOWNTO 24) ELSE '0';
   
   vam_1_equal <= '1' WHEN vam_reg_q = loc_am_1 ELSE '0';

   -- A32
   loc_hit_am_1(0) <= '1' WHEN loc_am_1 = "00" AND adr_1_equal(2 DOWNTO 0) = "111" AND vam_1_equal = '1' AND 
                  ((loc_rw_1(0) = '1' AND sl_writen_req_q = '1') OR (loc_rw_1(1) = '1' AND sl_writen_req_q = '0')) ELSE '0';
   -- A16
   loc_hit_am_1(1) <= '1' WHEN loc_am_1 = "10" AND adr_1_equal(0) = '1' AND vam_1_equal = '1' AND 
                  ((loc_rw_1(0) = '1' AND sl_writen_req_q = '1') OR (loc_rw_1(1) = '1' AND sl_writen_req_q = '0')) ELSE '0';
   -- A24         
   loc_hit_am_1(2) <= '1' WHEN loc_am_1 = "11" AND adr_1_equal(1 DOWNTO 0) = "11" AND vam_1_equal = '1' AND
                  ((loc_rw_1(0) = '1' AND sl_writen_req_q = '1') OR (loc_rw_1(1) = '1' AND sl_writen_req_q = '0')) ELSE '0';

loc : PROCESS(clk, rst)
   BEGIN
      IF rst = '1' THEN
         loc_irq_0 <= '0';
         loc_irq_1 <= '0';
         sl_writen_req_q <= '0';
         en_vme_adr_in_q <= '0';
         locmon_en_q <= '0';
         locmon_en <= '0';
         vme_adr_locmon_q <= (OTHERS => '0');
         vam_reg_q <= (OTHERS => '0');
      ELSIF clk'EVENT AND clk = '1' THEN
         en_vme_adr_in_q <= en_vme_adr_in;
         locmon_en <= en_vme_adr_in_flag;
         locmon_en_q <= locmon_en;

         IF locmon_en = '1' THEN    -- sample inputs for locmon at start of operation
            sl_writen_req_q <= sl_writen_reg;
            vme_adr_locmon_q <= vme_adr_locmon;
            vam_reg_q <= vam_reg(5 DOWNTO 4);
         END IF;
     
         IF clr_locmon(0) = '1' THEN
            loc_irq_0 <= '0';
         ELSIF (loc_hit_am_0(0) = '1' OR loc_hit_am_0(1) = '1' OR loc_hit_am_0(2) = '1') AND locmon_en_q = '1' THEN
            loc_irq_0 <= '1';
         ELSE
            loc_irq_0 <= '0';
         END IF;

         IF clr_locmon(1) = '1' THEN
            loc_irq_1 <= '0';
         ELSIF (loc_hit_am_0(0) = '1' OR loc_hit_am_1(1) = '1' OR loc_hit_am_1(2) = '1') AND locmon_en_q = '1' THEN
            loc_irq_1 <= '1';
         ELSE
            loc_irq_1 <= '0';
         END IF;
     END IF;
  END PROCESS loc;

   

END vme_locmon_arch;
