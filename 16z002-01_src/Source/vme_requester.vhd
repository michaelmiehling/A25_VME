--------------------------------------------------------------------------------
-- Title         : VMEbus Requester
-- Project       : 16z002-
--------------------------------------------------------------------------------
-- File          : vme_requester.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 30/01/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus
--------------------------------------------------------------------------------
-- Description :
--
-- The requester is used to get the busownership before a vme master access can 
-- be performed. The vme_master indicates the request for bus access by 
-- assertion of dwb. The requester has the job to gain the busownership by 
-- assertion of bus request (brn). There are four bus request levels which can 
-- be used. If the bus request gets answered by the bus grant on the same level
-- (bg[x]), the bus can be used. The usage gets indicated by asserting bus busy 
-- signal until the master access gets started (AS is asserted). If the master 
-- access is ongoing, the bus busy gets released and the bus ownership can 
-- change to another bus participant.
--------------------------------------------------------------------------------
-- Hierarchy:
-- none
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
-- $Log: vme_requester.vhd,v $
-- Revision 1.1  2012/03/29 10:14:33  MMiehling
-- Initial Revision
--
-- Revision 1.6  2006/05/18 14:29:09  MMiehling
-- corrected deglitching of bbsyn
-- corrected behaviour in state pass: not possible to use granted bus
--
-- Revision 1.5  2005/02/04 13:44:19  mmiehling
-- added fair requester bit
--
-- Revision 1.4  2003/06/13 10:06:42  MMiehling
-- deglitched bbsyn; improved bus release mechanism (dwb)
--
-- Revision 1.3  2003/04/22 11:03:04  MMiehling
-- now fsm from Ecki
--
-- Revision 1.2  2003/04/02 16:11:35  MMiehling
-- Der Requester sollte funktionieren, ist aber noch nicht ausführlich getestet worden
--
-- Revision 1.1  2003/04/01 13:04:45  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY vme_requester IS

  PORT (
   clk         : IN  std_logic;          
   rst         : IN  std_logic;
-------------------------------------------------------------------------------
-- PINS:
   -- Requesters Pins:
   br_i_n      : IN  std_logic_vector(3 DOWNTO 0);            -- bus requests monitored (FAIR)
   br_o_n      : OUT std_logic_vector(3 DOWNTO 0);            -- bus request
   bg_o_n      : OUT std_logic_vector(3 DOWNTO 0);            -- passed in idle state
   
   bbsyn_in    : IN std_logic;
   bbsyn       : OUT std_logic;            -- bus busy signal
-------------------------------------------------------------------------------    
   -- connected with PowerPC Access
   dwb         : IN  std_logic;
   dgb         : OUT std_logic;
   
   FairReqEn   : IN std_logic;
   brl         : IN std_logic_vector(1 DOWNTO 0);              -- bus request level
   
   -- from Arbiter:
   bgintn      : IN  std_logic_vector(3 DOWNTO 0);       -- from internal Arbiter if in Slot 1,
                                                         -- else outside from VMEbus
   -- connected with master unit:
   req_bit     : IN  std_logic;                          -- '0'= release on request; '1'= release when done
   brel        : IN  std_logic                           -- indicates whether the bus arbitration can be released
   );
END vme_requester;

ARCHITECTURE vme_requester_arc OF vme_requester IS
--   CONSTANT   FairReqEn   : std_logic := '1';                                       --for customer CARTS this bit = '0'
   TYPE rstates IS (ridle, rpass, rreq, rgrant1, rgrant, rgntrel);
   SIGNAL rstate              : rstates;
   SIGNAL bbsyn_degl          : std_logic;
   SIGNAL br_i_n_q            : std_logic_vector(3 DOWNTO 0);
   SIGNAL bbsyn_q             : std_logic;
   SIGNAL bbsyn_qq            : std_logic;
   SIGNAL bbsyn_qqq           : std_logic;
   SIGNAL brl_q               : std_logic_vector(1 DOWNTO 0);
BEGIN
-- Synchronize asynchronous VMEbus inputs:
  sync : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      br_i_n_q <= (OTHERS => '1');
      bbsyn_degl  <= '1';
      bbsyn_q   <= '1';
      bbsyn_qq   <= '1';
      bbsyn_qqq   <= '1';
      brl_q <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      br_i_n_q <= br_i_n;
      bbsyn_q  <= bbsyn_in;
      bbsyn_qq <= bbsyn_q;
      bbsyn_qqq <= bbsyn_qq;
      
      -- deglitch registers
      IF bbsyn_q = '0' AND bbsyn_qq = '0' AND bbsyn_qqq = '0' THEN
         bbsyn_degl <= '0';
      ELSIF bbsyn_q = '1' AND bbsyn_qq = '1' AND bbsyn_qqq = '1' THEN
         bbsyn_degl <= '1';
      ELSE
         bbsyn_degl <= bbsyn_degl;
      END IF;

      IF dwb = '1' THEN      
         brl_q       <= brl;           -- store in order to prevent changes during request cycle
      END IF;

    END IF;
  END PROCESS sync;


-------------------------------------------------------------------------------
-- The vme_requester (FAIR)
-------------------------------------------------------------------------------
-- (1) This Requester does NOT release BBSY# when:
--     (a) The REQ-bit is '0' (default), which means ROR, and no one is
--         requesting the bus.
--     (b) A doubleword from/to PCI is transfered. Requester does not remove
--         BBSY# before the second run of vmeacc-FSM, even if 'brel' from
--         Internal Master Unit is asserted, or an external Master requests
--         the bus. 
--
-- (2) Early busrelease is implemented (If master asserts AS# it issues 'brel',
-- then the requester removes BBSY# to allow bus-arbitration during the cycle).
-- Exceptions see (1).
-------------------------------------------------------------------------------  

req : PROCESS(clk, rst)
BEGIN
   IF (rst = '1') THEN
      rstate      <= ridle;
      br_o_n      <= (OTHERS => '1'); 
      bg_o_n      <= (OTHERS => '1'); 
      bbsyn       <= '1';
      dgb         <= '0';
   ELSIF (clk'event AND clk = '1') THEN
      CASE rstate IS
         -- wait for internal bus request; pass grants of other requests on daisy-chain
         WHEN ridle =>
            br_o_n      <= (OTHERS => '1');
            bbsyn       <= '1';
            dgb         <= '0';
            IF bgintn /= "1111" THEN                     -- is there any grant active which is not for me
               rstate <= rpass;
               bg_o_n <= bgintn;                       -- pass all grants because no request from here
            ELSIF dwb = '1' AND FairReqEn = '0' THEN              -- NO FAIR: request bus independent on other request on same level
               rstate <= rreq;
               bg_o_n <= (OTHERS => '1');                       -- pass no grant
            ELSIF dwb = '1' AND br_i_n_q(to_integer(unsigned(brl_q))) = '1' AND FairReqEn = '1' THEN   --FAIR: request bus if no other request is pending
               rstate <= rreq;
               bg_o_n <= (OTHERS => '1');                       -- pass no grant
            ELSE
               rstate <= ridle;
               bg_o_n <= (OTHERS => '1');                       -- pass no grant
            END IF;

         WHEN rpass =>
            br_o_n      <= (OTHERS => '1');
            bbsyn       <= '1';
            dgb         <= '0';
            IF bgintn /= "1111" THEN                     -- is there any grant active which is not for me
               rstate <= rpass;
               bg_o_n <= bgintn;                       -- pass all grants because no request from here
            ELSE
               rstate <= ridle;
               bg_o_n <= (OTHERS => '1');                -- deactivate bus grant signals
            END IF;
                  
         -- assert request and wait until grant gets received on daisy-chain
         WHEN rreq =>
            br_o_n(to_integer(unsigned(brl_q)))   <= '0';   -- assert request
            bbsyn       <= '1';
            dgb         <= '0';
            IF bgintn(to_integer(unsigned(brl_q))) = '0' AND bbsyn_degl = '1' THEN     -- is there a grant and last access finished?
               rstate <= rgrant1;
               bg_o_n <= (OTHERS => '1');                   -- if reqest was granted, do not pass grant to others
            ELSE
               rstate <= rreq;
               bg_o_n      <= bgintn;                       -- pass all grants because no request from here
            END IF;
           
         -- keep bus request and activate bus busy signal; wait until stable bus busy
         WHEN rgrant1 =>
            br_o_n(to_integer(unsigned(brl_q)))   <= '0';   -- assert request              
            bg_o_n      <= (OTHERS => '1');
            bbsyn       <= '0';                 -- assert bus busy
            dgb         <= '0';
            IF bbsyn_degl = '0' THEN            -- readback: is bus busy asserted on the bus?
               rstate <= rgrant;
            ELSE
               rstate <= rgrant1;
            END IF;
           
         -- remove request, keep bus busy and trigger master to do access
         WHEN rgrant =>
            br_o_n      <= (OTHERS => '1');        -- remove request now
            bg_o_n      <= (OTHERS => '1'); 
            bbsyn       <= '0';                    -- assert bus busy
            IF (brel = '1' AND req_bit = '1') OR                                          -- release when done; supports Early bus release feature 
               (brel  = '1' AND br_i_n_q /= "1111" AND req_bit = '0' AND dwb = '0') THEN   -- release on request; supports Early bus release feature
               rstate <= rgntrel;
               dgb         <= '0';                    -- indicate to master that bus is occupied
            ELSE
               rstate <= rgrant;
               dgb         <= '1';                    -- indicate to master that bus is ready for access
            END IF;

         -- master indicates 'access finished'; wait for removal of bus grant on daisy-chain before bus busy removal
         -- BBSY# MUST NOT be removed until bus grant from Arbiter is removed           
         WHEN rgntrel =>                 -- wait until arbiter removes grant
            br_o_n      <= (OTHERS => '1');
            bg_o_n      <= (OTHERS => '1');
            dgb         <= '0';
            IF bgintn(to_integer(unsigned(brl_q))) = '1' THEN
               rstate <= ridle;
               bbsyn  <= '1';               -- release bus busy
            ELSE
               rstate <= rgntrel;
               bbsyn  <= '0';               -- must be kept asserted til bg(x) is released!
            END IF;
            
         
         WHEN OTHERS =>
            br_o_n      <= (OTHERS => '1');
            bg_o_n      <= (OTHERS => '1');
            bbsyn       <= '1';
            dgb         <= '0';
            rstate <= ridle;
            ASSERT false REPORT "OOOPS Undecoded State .." SEVERITY warning;
      END CASE;
   END IF;
END PROCESS req;
END vme_requester_arc;
