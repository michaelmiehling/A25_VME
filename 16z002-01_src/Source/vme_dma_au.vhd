--------------------------------------------------------------------------------
-- Title         : DMA adress unit
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : vme_dma_au.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 17/09/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- This module provides the adresses and byte enables for the 
-- dma operation.
--------------------------------------------------------------------------------
-- Hierarchy:
--
-- wbb2vme
--    vme_dma
--       vme_dma_au
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
-- $Log: vme_dma_au.vhd,v $
-- Revision 1.3  2013/09/12 08:45:28  mmiehling
-- added bit 8 of tga for address modifier extension (supervisory, non-privileged data/program)
--
-- Revision 1.2  2012/08/27 12:57:18  MMiehling
-- removed dma_size_counter instance and implemented as common source code
-- adopted tga logic
--
-- Revision 1.1  2012/03/29 10:14:45  MMiehling
-- Initial Revision
--
-- Revision 1.5  2006/05/18 14:02:20  MMiehling
-- changed comment
--
-- Revision 1.1  2005/10/28 17:52:23  mmiehling
-- Initial Revision
--
-- Revision 1.4  2004/11/02 11:19:38  mmiehling
-- improved timing
-- fixed boundary errors
-- changed dma_size_cnt to lpm
--
-- Revision 1.3  2004/08/13 15:41:10  mmiehling
-- removed dma-slave and improved timing
--
-- Revision 1.2  2004/07/27 17:23:20  mmiehling
-- removed slave port
--
-- Revision 1.1  2004/07/15 09:28:48  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY vme_dma_au IS
PORT (
   rst               : IN std_logic;
   clk               : IN std_logic;
      
   -- wb_signals
   adr_o               : OUT std_logic_vector(31 DOWNTO 0);   -- adress for wb-bus
   sel_o               : OUT std_logic_vector(3 DOWNTO 0);      -- byte enables for wb_bus
   we_o               : OUT std_logic;                        -- write/read
   tga_o               : OUT std_logic_vector(8 DOWNTO 0);      -- type of dma
   cyc_o_sram         : OUT std_logic;                        -- chip select for sram
   cyc_o_pci         : OUT std_logic;                        -- chip select for pci
   cyc_o_vme         : OUT std_logic;                        -- chip select for vme
   stb_o               : IN std_logic;                        -- request signal for cyc switching
   
   -- vme_dma_mstr
   sour_dest         : IN std_logic;                        -- if set, source adress will be used, otherwise destination ad. for adr_o
   inc_adr            : IN std_logic;                        -- flag indicates when adr should be incremented (depend on sour_dest and get_bd)
   get_bd            : IN std_logic;                        -- if set, adress for next bd reading is switched to adr_o
   reached_size      : OUT std_logic;                        -- if all data from one bd was read and stored in the fifo
   load_cnt            : IN std_logic;                        -- after new bd was stored in register, counters must be loaded with new values
   boundary            : OUT std_logic;                        -- indicates 256 byte boundary if D16 or D32 burst
   clr_dma_act_bd      : IN std_logic;                        -- clears dma_act_bd if dma_mstr has done without error or
                                                            -- when dma_err will be cleared
   -- vme_dma_du
   start_dma         : IN std_logic;                        -- flag starts dma-fsm and clears counters
   dma_act_bd         : OUT std_logic_vector(7 DOWNTO 2);      -- [7:3] = active bd number
   dma_dest_adr      : IN std_logic_vector(31 DOWNTO 2);      -- active bd destination adress
   dma_sour_adr      : IN std_logic_vector(31 DOWNTO 2);      -- active bd source adress
   dma_sour_device   : IN std_logic_vector(2 DOWNTO 0);      -- selects the source device
   dma_dest_device   : IN std_logic_vector(2 DOWNTO 0);      -- selects the destination device
   dma_vme_am         : IN std_logic_vector(4 DOWNTO 0);      -- type of dma transmission
   inc_sour            : IN std_logic;                        -- indicates if source adress should be incremented
   inc_dest            : IN std_logic;                        -- indicates if destination adress should be incremented
   dma_size            : IN std_logic_vector(15 DOWNTO 0)      -- size of data package

     );
END vme_dma_au;

ARCHITECTURE vme_dma_au_arch OF vme_dma_au IS 
   
   CONSTANT dma_size_cnt_val   : std_logic_vector(15 DOWNTO 0):= x"0001";
   SIGNAL dma_act_bd_int    : std_logic_vector(7 DOWNTO 2);
   SIGNAL inc_int            : std_logic;
   SIGNAL dma_size_int      : std_logic_vector(15 DOWNTO 0);
   SIGNAL dma_sour_adr_int   : std_logic_vector(31 DOWNTO 2);
   SIGNAL dma_dest_adr_int   : std_logic_vector(31 DOWNTO 2);
   SIGNAL cyc_o_sram_int   : std_logic;
   SIGNAL cyc_o_pci_int      : std_logic;
   SIGNAL cyc_o_vme_int      : std_logic;
   SIGNAL adr_o_int         : std_logic_vector(31 DOWNTO 0);
   SIGNAL reached_size_int   : std_logic;
   SIGNAL boundary_blt      : std_logic;
   SIGNAL boundary_mblt      : std_logic;
   SIGNAL dest_is_0         : std_logic;
   SIGNAL sour_is_0         : std_logic;
   SIGNAL dma_size_en      : std_logic;
   
BEGIN
   cyc_o_sram             <= cyc_o_sram_int WHEN stb_o = '1' ELSE '0';
   cyc_o_pci             <= cyc_o_pci_int WHEN stb_o = '1' ELSE '0';
   cyc_o_vme             <= cyc_o_vme_int WHEN stb_o = '1' ELSE '0';

   inc_int                <= inc_sour WHEN sour_dest = '1' ELSE inc_dest;
   dma_act_bd             <= dma_act_bd_int;
   
   reached_size_int <= '1' WHEN dma_size_int = dma_size ELSE '0';

   adr_o_int(31 DOWNTO 2) <= x"000f_f9" & dma_act_bd_int WHEN get_bd = '1' ELSE    -- switch iram adress [10:2] to adr_o
              dma_sour_adr_int WHEN sour_dest = '1' ELSE   -- switch source adress to adr_o & dma_access & swap
              dma_dest_adr_int ;                              -- switch destination adress to adr_o & dma_access & swap
     adr_o_int(1 DOWNTO 0) <= "00";
              

   dest_is_0 <= '1' WHEN dma_dest_adr_int(7 DOWNTO 2) = "000000" ELSE '0';
   sour_is_0 <= '1' WHEN dma_sour_adr_int(7 DOWNTO 2) = "000000" ELSE '0';
            
                                                  
   boundary <= boundary_blt OR boundary_mblt;   
      
   sel_o <= (OTHERS => '1');

      
adr_o_proc : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
        adr_o <= (OTHERS => '0');
        dma_sour_adr_int <= (OTHERS => '0');
        dma_dest_adr_int <= (OTHERS => '0');
        dma_act_bd_int <= (OTHERS => '0');
      cyc_o_sram_int <= '0';
      cyc_o_pci_int <= '0';
      cyc_o_vme_int <= '0';
      we_o <= '0';
      reached_size <= '0';
      tga_o <= (OTHERS => '0');
      boundary_blt <= '0';
      boundary_mblt <= '0';
     ELSIF clk'EVENT AND clk = '1' THEN
        -- rule of vmebus: do not cross 256 byte boundaries (0x100)
        IF dma_vme_am(3) = '0' AND ((dma_dest_device(1) = '1' AND dest_is_0 = '1' AND sour_dest = '0') OR
                                   (dma_sour_device(1) = '1' AND sour_is_0 = '1' AND sour_dest = '1')) THEN
           boundary_blt <= '1';
        ELSE
           boundary_blt <= '0';
        END IF;
        -- for mblt-d64: do not cross 2k byte boundaries (0x800)
        IF dma_vme_am(3) = '1' AND ((dma_dest_device(1) = '1' AND dest_is_0 = '1' AND dma_dest_adr_int(10 DOWNTO 8) = "000" AND sour_dest = '0') OR
                                   (dma_sour_device(1) = '1' AND sour_is_0 = '1' AND dma_sour_adr_int(10 DOWNTO 8) = "000" AND sour_dest = '1')) THEN
           boundary_mblt <= '1';
        ELSE
           boundary_mblt <= '0';
        END IF;
        
        IF inc_adr = '1' OR get_bd = '1' THEN
           adr_o <= adr_o_int;
        END IF;

        IF load_cnt = '1' THEN
           reached_size <= '0';
        ELSIF inc_adr = '1' AND sour_dest = '1' THEN
           reached_size <= reached_size_int;
        END IF;

      -- (0)   : A24(=0)
      -- (1)   : A32(=1)
      -- (3:2) : 00=D16, 01=D32, 10=D64
      -- (4)   : if increment enabled the burst else single
      -- (5)   : swapped(1) or non swapped (0)
      -- (6)   : =0 always VME bus access (no register access)
      -- (7)   : =1 indicates access to vme_ctrl by DMA
      -- (8)   : 0= non-privileged 1= supervisory
      tga_o <= dma_vme_am(4) & "10" & NOT  dma_vme_am(0) & NOT inc_int & dma_vme_am(3 DOWNTO 2) & '0' & dma_vme_am(1);
      
        IF get_bd = '1' THEN
         cyc_o_sram_int <= '1';
         cyc_o_pci_int <= '0';
         cyc_o_vme_int <= '0';
         we_o <= '0';                                    -- only reading from sram
        ELSIF sour_dest = '1' THEN                           -- SOURCE
         cyc_o_sram_int <= dma_sour_device(0);
         cyc_o_vme_int <= dma_sour_device(1);
         cyc_o_pci_int <= dma_sour_device(2);
         we_o <= '0';                                    -- read from source
        ELSE                                                -- DESTINATION
         cyc_o_sram_int <= dma_dest_device(0);
         cyc_o_vme_int <= dma_dest_device(1);
         cyc_o_pci_int <= dma_dest_device(2);
         we_o <= '1';                                    -- write to destination
        END IF;
        
        IF load_cnt = '1' THEN
           dma_sour_adr_int <= dma_sour_adr;
        ELSIF get_bd = '0' AND sour_dest = '1' AND inc_adr = '1' AND inc_sour = '0' THEN
           dma_sour_adr_int <= dma_sour_adr_int + 1;
        END IF;
     
        IF load_cnt = '1' THEN
           dma_dest_adr_int <= dma_dest_adr;
        ELSIF get_bd = '0' AND sour_dest = '0' AND inc_adr = '1' AND inc_dest = '0' THEN
           dma_dest_adr_int <= dma_dest_adr_int + 1;
        END IF;
        
        IF start_dma = '1' OR clr_dma_act_bd = '1' THEN
           dma_act_bd_int <= (OTHERS => '0');
        ELSIF get_bd = '1' AND inc_adr = '1' THEN
           dma_act_bd_int <= dma_act_bd_int + 1;
        END IF;
     END IF;
  END PROCESS adr_o_proc;
  
  dma_size_en <= '1' WHEN sour_dest = '1' AND inc_adr = '1' ELSE '0';
 
size_cnt: PROCESS (clk, rst)  
   BEGIN
      IF rst = '1' THEN
         dma_size_int <= (OTHERS => '0');
      ELSIF clk'event AND clk = '1' THEN
         IF load_cnt = '1' THEN
            dma_size_int <= (OTHERS => '0');
         ELSIF dma_size_en = '1' THEN
            dma_size_int <= dma_size_int + 1;
         END IF;
      END IF;
   END PROCESS size_cnt;
END vme_dma_au_arch;
