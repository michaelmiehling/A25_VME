---------------------------------------------------------------
-- Title         : Adaption from clk a to clk b
-- Project       : A15
---------------------------------------------------------------
-- File          : clk_trans_wb2wb.vhd
-- Author        : Michael Miehling
-- Email         : miehling@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 25/02/03
---------------------------------------------------------------
-- Simulator     : Modelsim 5.6
-- Synthesis     : Leonardo/Quartus
---------------------------------------------------------------
-- Description :
--
-- This Module transforms the request and acknoledge signals to
-- connect to a a MHz internal bus. Also the data must be 
-- transformed in order to fit into the a MHz clk domain.
-- The module supports posted and delayed writes:
-- POSTED_WR=true => acknowledge write access immediately
-- POSTED_WR=false => acknowledge write if access has finished on side b
---------------------------------------------------------------
-- Hierarchy:
--
-- sys_unit
--    clk_trans_wb2wb
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
-- $Revision: 1.7 $
--
-- $Log: clk_trans_wb2wb.vhd,v $
-- Revision 1.7  2015/09/08 17:23:00  AGeissler
-- R1: Missing reset for second clock domain
-- M1: Replaced rstn with rst_a and rst_b
--
-- Revision 1.6  2015/06/15 16:40:10  AGeissler
-- R1: In 16z100- version 1.30 the bte signal was removed from the wb_pkg.vhd
-- M1: Removed bte signals from clock trans
-- R2: Clearness
-- M2: Replaced tabs with spaces
--
-- Revision 1.5  2012/09/07 09:59:14  MMiehling
-- added delayed write support by generic switch
--
-- Revision 1.4  2011/05/17 11:16:00  FLenhardt
-- R: Under certain conditions (e.g. when not all cycles of a Wishbone master
--    were connected to CLK_TRANS_WB2WB) a Wishbone access could happen to
--    stuck, because the clock transition was controlled only by the strobe
-- M: A Wishbone access is valid only when also at least one cycle is active
--
-- Revision 1.3  2010/03/12 13:00:27  mmiehling
-- added generic NBR_OF_CYC and NBR_OF_TGA in order to configure the bridge
--
-- Revision 1.2  2007/07/05 13:22:53  FLenhardt
-- Removed an unused signal (due to synthesis warnings)
--
-- Revision 1.1  2005/05/06 12:06:50  MMiehling
-- Initial Revision
--
-- Revision 1.2  2004/11/02 11:29:24  mmiehling
-- replaced full => full_a and full_b
--
-- Revision 1.1  2004/07/27 17:15:20  mmiehling
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY clk_trans_wb2wb IS
   GENERIC (
      POSTED_WR   : boolean := TRUE;
      NBR_OF_CYC  : integer range 1 TO 100 := 1;
      NBR_OF_TGA  : integer range 1 TO 100 := 6
   );
   PORT (
      
      -- a MHz domain
      rst_a       : IN std_logic;
      clk_a       : IN std_logic;
      cyc_a       : IN std_logic_vector(NBR_OF_CYC-1 DOWNTO 0);
      stb_a       : IN std_logic;                           -- request signal from a MHz side
      ack_a       : OUT std_logic;                          -- adopted acknoledge signal to b MHz
      err_a       : OUT std_logic;
      
      we_a        : IN std_logic;                           -- '1' = write, '0' = read
      tga_a       : IN std_logic_vector(NBR_OF_TGA-1 DOWNTO 0);   
      cti_a       : IN std_logic_vector(2 DOWNTO 0);        -- transfer type
      adr_a       : IN std_logic_vector(31 DOWNTO 0);       -- adr from a MHz side
      sel_a       : IN std_logic_vector(3 DOWNTO 0);        -- byte enables from a MHz side
      dat_i_a     : IN std_logic_vector(31 DOWNTO 0);       -- data from a MHz side
      dat_o_a     : OUT std_logic_vector(31 DOWNTO 0);      -- data from b MHz side to a MHz side
      
      -- b MHz domain
      rst_b       : IN std_logic;
      clk_b       : IN std_logic;
      cyc_b       : OUT std_logic_vector(NBR_OF_CYC-1 DOWNTO 0);
      stb_b       : OUT std_logic;                          -- request signal adopted to b MHz
      ack_b       : IN std_logic;                           -- acknoledge signal from internal bus
      err_b       : IN std_logic;
      
      we_b        : OUT std_logic;                          -- '1' = write, '0' = read
      tga_b       : OUT std_logic_vector(NBR_OF_TGA-1 DOWNTO 0);  
      cti_b       : OUT std_logic_vector(2 DOWNTO 0);       -- transfer type
      adr_b       : OUT std_logic_vector(31 DOWNTO 0);      -- adr from b MHz side
      sel_b       : OUT std_logic_vector(3 DOWNTO 0);       -- byte enables for b MHz side
      dat_i_b     : IN std_logic_vector(31 DOWNTO 0);       -- data from b MHz side
      dat_o_b     : OUT std_logic_vector(31 DOWNTO 0)       -- data from a MHz side to b MHz side
   );
END clk_trans_wb2wb;

ARCHITECTURE clk_trans_wb2wb_arch OF clk_trans_wb2wb IS 
   COMPONENT fifo_d1 
   GENERIC (
      width    : IN integer );
   PORT (
      
      rst_a    : IN std_logic;
      clk_a    : IN std_logic;
      wr_a     : IN std_logic;
      data_a   : IN std_logic_vector(width-1 DOWNTO 0);
      full_a   : OUT std_logic;
      
      rst_b    : IN std_logic;
      clk_b    : IN std_logic;
      rd_b     : IN std_logic;
      data_b   : OUT std_logic_vector(width-1 DOWNTO 0);
      full_b   : OUT std_logic
      
   );
   END COMPONENT;
   
   TYPE  ct_states IS (idle, waitstate, acknoledge);
   SIGNAL ct_state : ct_states;
   
   CONSTANT WR_FIFO_WIDTH  : integer:= 69 + NBR_OF_CYC + NBR_OF_TGA; -- cyc + dat + adr + sel + we = 32+32+4+1 = 69
   CONSTANT RD_FIFO_WIDTH  : integer:= 32;   -- dat = 32 
   SIGNAL ff1_rd     : std_logic;
   SIGNAL ff1_wr     : std_logic;
   SIGNAL ff1_full_a : std_logic;
   SIGNAL ff1_full_b : std_logic;
   SIGNAL ff2_rd     : std_logic;
   SIGNAL ff2_wr     : std_logic;
   SIGNAL ff2_full_b : std_logic;
   SIGNAL stb_b_int  : std_logic;
   SIGNAL ff1_dat_a  : std_logic_vector((WR_FIFO_WIDTH - 1) DOWNTO 0);
   SIGNAL ff1_dat_b  : std_logic_vector((WR_FIFO_WIDTH - 1) DOWNTO 0);
   SIGNAL ack_a_int  : std_logic;
   
BEGIN
   
   ack_a <= ack_a_int;
   stb_b <= stb_b_int;
   err_a <= '0';  -- errors will not reported: error-access will never end!
   
   ff1_dat_a <= tga_a & cyc_a & dat_i_a & adr_a & sel_a & we_a;
   
   tga_b    <= ff1_dat_b(68+NBR_OF_CYC+NBR_OF_TGA DOWNTO 69+NBR_OF_CYC);
   cyc_b    <= ff1_dat_b(68+NBR_OF_CYC DOWNTO 69) WHEN stb_b_int = '1' ELSE (OTHERS => '0');
   dat_o_b  <= ff1_dat_b(68 DOWNTO 37);
   adr_b    <= ff1_dat_b(36 DOWNTO 5);
   sel_b    <= ff1_dat_b(4 DOWNTO 1);
   we_b     <= ff1_dat_b(0);
   cti_b    <= (OTHERS => '0');
   
   ff1 : fifo_d1 
   GENERIC MAP (
      width    => WR_FIFO_WIDTH
   )
   PORT MAP (
      rst_a    => rst_a,
      clk_a    => clk_a,
      wr_a     => ff1_wr,
      data_a   => ff1_dat_a,
      full_a   => ff1_full_a,
      
      rst_b    => rst_b,
      clk_b    => clk_b,
      rd_b     => ff1_rd,
      data_b   => ff1_dat_b,
      full_b   => ff1_full_b
   );
   
   ff2 : fifo_d1 
   GENERIC MAP (
      width    => RD_FIFO_WIDTH
   )
   PORT MAP (
      rst_a    => rst_b,
      clk_a    => clk_b,
      wr_a     => ff2_wr,
      data_a   => dat_i_b,
      
      rst_b    => rst_a,
      clk_b    => clk_a,
      rd_b     => ff2_rd,
      data_b   => dat_o_a,
      full_b   => ff2_full_b
   );
   
   ff1_wr <= '1' WHEN (ct_state = idle AND stb_a = '1' AND unsigned(cyc_a) /= 0 AND ff1_full_a = '0') ELSE '0';
   
   ff2_rd <= '1' WHEN ff2_full_b = '1' ELSE '0';                                    -- read data from ff when available
   
   proca : PROCESS (clk_a, rst_a)
   BEGIN
      IF rst_a = '1' THEN
         ack_a_int <= '0';
         ct_state <= idle;
      ELSIF clk_a'EVENT AND clk_a = '1' THEN
         CASE ct_state IS
            WHEN idle =>
               IF (ff1_wr = '1' AND we_a = '1') AND POSTED_WR THEN      -- posted write
                  ct_state <= acknoledge;
                  ack_a_int <= '1';
               ELSIF (ff1_wr = '1' AND we_a = '1') AND NOT POSTED_WR THEN     -- delayed write
                  ct_state <= waitstate;
                  ack_a_int <= '0';
               ELSIF (ff1_wr = '1' AND we_a = '0') THEN  -- read
                  ct_state <= waitstate;
                  ack_a_int <= '0';
               ELSE
                  ct_state <= idle;
                  ack_a_int <= '0';
               END IF;
               
            WHEN waitstate =>
               IF ff2_full_b = '1' THEN
                  ct_state <= acknoledge;
                  ack_a_int <= '1';
               ELSE
                  ct_state <= waitstate;
                  ack_a_int <= '0';
               END IF;
               
            WHEN acknoledge =>
               ack_a_int <= '0';
               ct_state <= idle;
            
            WHEN OTHERS =>
               ct_state <= idle;
               ack_a_int <= '0';
               
         END CASE;
      END IF;
   END PROCESS proca;
   
   
   ------------------------------------------------------------------
   -- side b: stb_b is not dependent on we_a
   ------------------------------------------------------------------
   -- for read and write equal:
   ff1_rd <= '1' WHEN ((ack_b = '0' AND err_b = '0') AND ff1_full_b = '1' AND stb_b_int = '0') OR     -- first data phase
                     ((ack_b = '1' OR err_b = '1') AND ff1_full_b = '1' AND stb_b_int = '1')          -- within a burst (not the last)
                     ELSE '0';
   
   ff2_wr <= '1' WHEN stb_b_int = '1' AND (ack_b = '1' OR err_b = '1') AND (NOT POSTED_WR OR (ff1_dat_b(0) = '0' AND POSTED_WR)) ELSE '0';   -- store read-data
   
   
   -- ack_b stb_b ff1_full stb_b(+1)
   -- x     0     1        1
   -- x     1     1        1
   -- x     0     0        0
   -- 1     1     0        0
   -- 0     1     0        1
   procb : PROCESS (clk_b, rst_b)
   BEGIN
      IF rst_b = '1' THEN
         stb_b_int <= '0';
      ELSIF clk_b'EVENT AND clk_b = '1' THEN
         IF ff1_full_b = '1' THEN
            IF stb_b_int = '0' THEN
               stb_b_int <= '1';             -- start next data phase
               ELSE
                                             -- end of current data phase, start of next
               stb_b_int <= '1';             -- or no end of current data phase
            END IF;
         ELSE
            IF stb_b_int = '0' THEN          -- no current access and no next access
               stb_b_int <= '0';
            ELSE
               IF ack_b = '1' OR err_b = '1' THEN           -- end of current data phase, no next
                  stb_b_int <= '0';
               ELSE
                  stb_b_int <= '1';          -- no end of current data phase
               END IF;
            END IF;
         END IF;
         
      END IF;
   END PROCESS procb;
   
END clk_trans_wb2wb_arch;
