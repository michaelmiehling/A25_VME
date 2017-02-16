--------------------------------------------------------------------------------
-- Title         : VME-Mailbox Control
-- Project       : A15b
--------------------------------------------------------------------------------
-- File          : vme_mailbox.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 08/04/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- In order to send messages on the VMEbus without using the slow interrupt 
-- daisy chain, the Mailbox feature can be used. By writing and/or reading one 
-- of the Mailbox Data Registers from VME-side, a local CPU interrupt can be 
-- generated (signaled via mailbox_irq to WBB). 
-- Due to the location of the data registers in the local SRAM (0x FF800..
-- 0x FF80c), normal A24/A32 accesses can be used in contrast to the slow daisy 
-- chain mechanism. 
-- Four independent 32 bit Mailbox Data Registers are supported, which can be 
-- configured to cause an interrupt request upon read or write or both.
--------------------------------------------------------------------------------
-- Hierarchy:
--
-- top_a15
--      vme_ctrl
--         vme_mailbox
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
-- $Log: vme_mailbox.vhd,v $
-- Revision 1.2  2012/11/12 08:13:06  MMiehling
-- bugfix mailbox: now evaluation of addresses only when access is active
--
-- Revision 1.1  2012/03/29 10:14:37  MMiehling
-- Initial Revision
--
-- Revision 1.5  2006/05/18 14:28:52  MMiehling
-- wrong decoding of mailbox address => spurious interrupts
--
-- Revision 1.1  2005/10/28 17:51:01  mmiehling
-- Initial Revision
--
-- Revision 1.4  2004/11/02 11:29:22  mmiehling
-- improved timing and area
--
-- Revision 1.3  2003/12/01 10:03:09  MMiehling
-- adopted to changed vme_adr timing
--
-- Revision 1.2  2003/06/13 10:06:14  MMiehling
-- corrected address mapping
--
-- Revision 1.1  2003/04/22 11:07:26  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY vme_mailbox IS
PORT (
   clk               : IN std_logic;                     -- 66 MHz
   rst               : IN std_logic;                     -- global reset signal (asynch)

   sl_acc            : IN std_logic_vector(4 DOWNTO 0);  -- slave access address type (sl16_hit, sl24_hit, sl32_hit, sl_blt32, sl_blt64)
   wbm_adr_o         : IN std_logic_vector(19 DOWNTO 2); -- mensb master adress lines
   wbm_we_o          : IN std_logic;                     -- mensb master read/write
   mensb_mstr_req    : IN std_logic;                     -- mensb master request
   ram_acc           : IN std_logic;                     -- external ram access
   mail_irq          : OUT std_logic_vector(7 DOWNTO 0)  -- mailbox interrupt requests (flags)
     );
END vme_mailbox;

ARCHITECTURE vme_mailbox_arch OF vme_mailbox IS 
   CONSTANT mail_0_adr : std_logic_vector(3 DOWNTO 2):="00";   -- 0x800
   CONSTANT mail_1_adr : std_logic_vector(3 DOWNTO 2):="01";   -- 0x804
   CONSTANT mail_2_adr : std_logic_vector(3 DOWNTO 2):="10";   -- 0x808
   CONSTANT mail_3_adr : std_logic_vector(3 DOWNTO 2):="11";   -- 0x80c
   CONSTANT mail_offset_adr : std_logic_vector(19 DOWNTO 4):=x"ff80";   -- 0xFF800
   
   -- mailbox is accessible from:
   -- PCI:          SRAM-offset + 0xFF800
   -- A24/A32:    0xFF800
   -- A16:         0x800

   SIGNAL equal   : std_logic_vector(5 DOWNTO 0);
   SIGNAL mail_hit   : std_logic_vector(3 DOWNTO 0);
   SIGNAL a24_a32_mode : std_logic;
   SIGNAL a16_mode : std_logic;
BEGIN

   equal(5) <= '1' WHEN wbm_adr_o(19 DOWNTO 12) = mail_offset_adr(19 DOWNTO 12) ELSE '0';   -- offset is needed for A24 access
   equal(4) <= '1' WHEN wbm_adr_o(11 DOWNTO 4) = mail_offset_adr(11 DOWNTO 4) ELSE '0';   -- offset is not needed for A16 access
   equal(3) <= '1' WHEN wbm_adr_o(3 DOWNTO 2) = mail_3_adr ELSE '0';
   equal(2) <= '1' WHEN wbm_adr_o(3 DOWNTO 2) = mail_2_adr ELSE '0';
   equal(1) <= '1' WHEN wbm_adr_o(3 DOWNTO 2) = mail_1_adr ELSE '0';
   equal(0) <= '1' WHEN wbm_adr_o(3 DOWNTO 2) = mail_0_adr ELSE '0';
   
   a24_a32_mode <= sl_acc(3) OR sl_acc(2);
   a16_mode <= sl_acc(4);

mail : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
        mail_irq <= (OTHERS => '0');
        mail_hit <= (OTHERS => '0');
     ELSIF clk'EVENT AND clk = '1' THEN     
      IF mensb_mstr_req = '1' AND ram_acc = '1' THEN
         IF a24_a32_mode = '1' AND equal(3) = '1' AND equal(4) = '1' AND equal(5) = '1' THEN       -- A24 or A32
            mail_hit(3) <= '1';
         ELSIF a16_mode = '1' AND equal(3) = '1' AND equal(4) = '1' THEN                        -- A16
            mail_hit(3) <= '1';
         ELSE
            mail_hit(3) <= '0';
         END IF;
         
         IF a24_a32_mode = '1' AND equal(2) = '1' AND equal(4) = '1' AND equal(5) = '1' THEN       -- A24 or A32
            mail_hit(2) <= '1';
         ELSIF a16_mode = '1' AND equal(2) = '1' AND equal(4) = '1' THEN                        -- A16
            mail_hit(2) <= '1';
         ELSE
            mail_hit(2) <= '0';
         END IF;
         
         IF a24_a32_mode = '1' AND equal(1) = '1' AND equal(4) = '1' AND equal(5) = '1' THEN       -- A24 or A32
            mail_hit(1) <= '1';
         ELSIF a16_mode = '1' AND equal(1) = '1' AND equal(4) = '1' THEN                        -- A16
            mail_hit(1) <= '1';
         ELSE
            mail_hit(1) <= '0';
         END IF;
         
         IF a24_a32_mode = '1' AND equal(0) = '1' AND equal(4) = '1' AND equal(5) = '1' THEN       -- A24 or A32
            mail_hit(0) <= '1';
         ELSIF a16_mode = '1' AND equal(0) = '1' AND equal(4) = '1' THEN                        -- A16
            mail_hit(0) <= '1';
         ELSE
            mail_hit(0) <= '0';
         END IF;
      ELSE
         mail_hit <= (OTHERS => '0');
      END IF;
         
      IF mensb_mstr_req = '1' AND ram_acc = '1' THEN     
          IF mail_hit(0) = '1' THEN
            mail_irq(0) <= NOT wbm_we_o;
            mail_irq(1) <= wbm_we_o;
         ELSE
            mail_irq(0) <= '0';
            mail_irq(1) <= '0';
         END IF;      
          IF mail_hit(1) = '1' THEN
            mail_irq(2) <= NOT wbm_we_o;
            mail_irq(3) <= wbm_we_o;
         ELSE
            mail_irq(2) <= '0';
            mail_irq(3) <= '0';
         END IF;      
          IF mail_hit(2) = '1' THEN
            mail_irq(4) <= NOT wbm_we_o;
            mail_irq(5) <= wbm_we_o;
         ELSE
            mail_irq(4) <= '0';
            mail_irq(5) <= '0';
         END IF;      
          IF mail_hit(3) = '1' THEN
            mail_irq(6) <= NOT wbm_we_o;
            mail_irq(7) <= wbm_we_o;
         ELSE
            mail_irq(6) <= '0';
            mail_irq(7) <= '0';
         END IF;      
      ELSE
         mail_irq <= (OTHERS => '0');
      END IF;
   END IF;
  END PROCESS mail;
END vme_mailbox_arch;
