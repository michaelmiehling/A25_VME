--------------------------------------------------------------------------------
-- Title         : external SRAM Interface
-- Project       : A15
--------------------------------------------------------------------------------
-- File          : sram.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 24/01/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- Interface controller to asynchronous RAM with 1 MB.
-- Longword accesses will be performed by two SRAM accesses.
--------------------------------------------------------------------------------
-- Hierarchy:
--
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
-- History:
--------------------------------------------------------------------------------
-- $Revision: 1.1 $
--
-- $Log: sram.vhd,v $
-- Revision 1.1  2012/03/29 10:21:15  MMiehling
-- Initial Revision
--
-- Revision 1.4  2004/07/27 17:15:30  mmiehling
-- changed pci-core to 16z014
-- changed wishbone bus to wb_bus.vhd
-- added clk_trans_wb2wb.vhd
-- improved dma
--
-- Revision 1.3  2003/12/01 10:03:31  MMiehling
-- now whishbone bus
--
-- Revision 1.2  2003/06/24 13:46:54  MMiehling
-- removed burst
--
-- Revision 1.1  2003/04/01 13:04:31  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY sram IS
PORT (
   clk66          : IN std_logic;                        -- 66 MHz
   rst            : IN std_logic;                        -- global reset signal (asynch)
   -- local bus
   stb_i          : IN std_logic;
   ack_o          : OUT std_logic;
   we_i           : IN std_logic;                        -- high active write enable
   sel_i          : IN std_logic_vector(3 DOWNTO 0);     -- high active byte enables
   cyc_i          : IN std_logic;
   dat_o          : OUT std_logic_vector(31 DOWNTO 0);
   dat_i          : IN std_logic_vector(31 DOWNTO 0);
   adr_i          : IN std_logic_vector(19 DOWNTO 0);
   
   -- pins to sram
   bwn            : OUT   std_logic;                     -- global byte write enable: 
   bwan           : OUT   std_logic;                     -- byte a write enable:     
   bwbn           : OUT   std_logic;                     -- byte b write enable:     
   adscn          : OUT   std_logic;                     -- Synchronous Address Status Controller:   .
   roen           : OUT   std_logic;                     -- data output enable of sram data signals
   ra             : OUT   std_logic_vector(18 DOWNTO 0); -- address lines:       
   rd_in          : IN std_logic_vector(15 DOWNTO 0);    -- fpga data input vector      
   rd_out         : OUT std_logic_vector(15 DOWNTO 0);   -- fpga data output vector
   rd_oe          : OUT std_logic                        -- fpga data output enable (if '1', rd_out should be driven to sram)
   );
END sram;

ARCHITECTURE sram_arch OF sram IS 
   TYPE sram_states IS (sram_idle, sram_wait, sram_low, sram_high, sram_read_end);
   SIGNAL sram_state    : sram_states;
   SIGNAL ra_1         : std_logic;
   SIGNAL ra_int      : std_logic_vector(19 DOWNTO 2);
   SIGNAL roen_int      : std_logic;
   SIGNAL we_i_q      : std_logic;

BEGIN
   ra <= ra_int & ra_1;
   roen <= roen_int;  
   
--oe : PROCESS (rd_oe, rd_out, rd)
--  BEGIN
--     IF rd_oe = '1' THEN
--        rd <= rd_out AFTER 3 ns;
--        rd_in <= rd;
--     ELSE
--        rd <= (OTHERS => 'Z');
--        rd_in <= rd AFTER 3 ns;
--     END IF;
--  END PROCESS oe;

reg : PROCESS (clk66, rst)
  BEGIN
     IF rst = '1' THEN
        ra_int <= (OTHERS => '0');
        dat_o <= (OTHERS => '0');
        rd_out <= (OTHERS => '0');
        we_i_q <= '0';
     ELSIF clk66'EVENT AND clk66 = '1' THEN
        we_i_q <= we_i;
        
        IF ra_1 = '1' THEN                     -- low byte
           rd_out <= dat_i(15 DOWNTO 0);
        ELSE                              -- high byte
           rd_out <= dat_i(31 DOWNTO 16);
        END IF;
        IF ra_1 = '1' AND roen_int = '0' THEN                     -- low byte
           dat_o(15 DOWNTO 0) <= rd_in;   
        ELSIF ra_1 = '0' AND roen_int = '0' THEN                  -- high_byte
           dat_o(31 DOWNTO 16) <= rd_in;
        END IF;
        
      ra_int <= adr_i(19 DOWNTO 2);
              
     END IF;
  END PROCESS reg;
   
sram_fsm : PROCESS (clk66, rst)
  BEGIN
   IF rst = '1' THEN
      ack_o <= '0';
      sram_state <= sram_idle;
      bwn <= '1';
      bwan <= '1';
      bwbn <= '1';
      roen_int <= '1';
      adscn <= '1';
      ra_1 <= '0';
      rd_oe <= '0';
     ELSIF clk66'EVENT AND clk66 = '1' THEN
        CASE sram_state IS
           WHEN sram_idle =>
            ack_o <= '0';
            bwn <= '1';
            bwan <= '1';
            bwbn <= '1';
            roen_int <= '1';
            IF stb_i = '1' AND cyc_i = '1' THEN
               sram_state <= sram_wait;
               IF we_i = '1' THEN      -- write
                  adscn <= '1';
                  rd_oe <= '1';
               ELSE                  -- read
                  adscn <= '0';
                  rd_oe <= '0';
               END IF;
               ra_1 <= '1';
            ELSE
               sram_state <= sram_idle;
               adscn <= '1';
               ra_1 <= '0';
               rd_oe <= '0';
            END IF;
            
           WHEN sram_wait =>
            ra_1 <= '0';   
             IF stb_i = '1' AND cyc_i = '1' THEN
                 sram_state <= sram_low;
               adscn <= '0';
               IF we_i = '1' THEN      -- write
                    ack_o <= '1';
                  bwn <= '0';
                  bwan <= NOT sel_i(0);
                  bwbn <= NOT sel_i(1);
                  rd_oe <= '1';
                  roen_int <= '1';
               ELSE                  -- read
                    ack_o <= '0';
                  bwn <= '1';
                  bwan <= '1';
                  bwbn <= '1';
                  rd_oe <= '0';
                  roen_int <= '0';
               END IF;
            ELSE
               sram_state <= sram_idle;
               ack_o <= '0';
               adscn <= '1';
               bwn <= '1';
               bwan <= '1';
               bwbn <= '1';
               rd_oe <= '0';
               roen_int <= '1';
            END IF;
          
           WHEN sram_low =>
            sram_state <= sram_high;
            ra_1 <= '1';
            IF we_i = '1' THEN      -- write
               ack_o <= '0';
               bwn <= '0';
               bwan <= NOT sel_i(2);
               bwbn <= NOT sel_i(3);
               rd_oe <= '1';
               roen_int <= '1';
               adscn <= '0';
            ELSE                  -- read
               ack_o <= '0';
               bwn <= '1';
               bwan <= '1';
               bwbn <= '1';
               rd_oe <= '0';
               roen_int <= '0';
               adscn <= '1';
            END IF;
            
           WHEN sram_high =>
            sram_state <= sram_read_end;
            adscn <= '1';
            bwn <= '1';
            bwan <= '1';
            bwbn <= '1';
            ra_1 <= '0';
            IF we_i_q = '1' THEN      -- write
               ack_o <= '0';
               rd_oe <= '1';
               roen_int <= '1';
            ELSE                  -- read
               ack_o <= '1';
               rd_oe <= '0';
               roen_int <= '1';
            END IF;
              
           WHEN sram_read_end =>
            ack_o <= '0';
            bwn <= '1';
            bwan <= '1';
            bwbn <= '1';
            roen_int <= '1';
            sram_state <= sram_idle;
            ra_1 <= '0';
            adscn <= '1';
            rd_oe <= '0';
              
           WHEN OTHERS =>
            ack_o <= '0';
            sram_state <= sram_idle;           
            bwn <= '1';
            bwan <= '1';
            bwbn <= '1';
            roen_int <= '1';
            adscn <= '1';
            ra_1 <= '0';
            rd_oe <= '0';
        END CASE;
     END IF;
  END PROCESS sram_fsm;
  


END sram_arch;
