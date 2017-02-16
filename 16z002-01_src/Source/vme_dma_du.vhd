--------------------------------------------------------------------------------
-- Title         : Data unit of DMA controller
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : vme_dma_du.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 17/09/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- This module consists of the data switching for the dma.
--------------------------------------------------------------------------------
-- Hierarchy:
--
-- wbb2vme
--    vme_dma
--       vme_dma_du
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
-- $Log: vme_dma_du.vhd,v $
-- Revision 1.2  2013/09/12 08:45:25  mmiehling
-- added bit 8 of tga for address modifier extension (supervisory, non-privileged data/program)
--
-- Revision 1.1  2012/03/29 10:14:44  MMiehling
-- Initial Revision
--
-- Revision 1.4  2006/05/18 14:02:22  MMiehling
-- changed comment
--
-- Revision 1.1  2005/10/28 17:52:24  mmiehling
-- Initial Revision
--
-- Revision 1.3  2004/08/13 15:41:12  mmiehling
-- removed dma-slave and improved timing
--
-- Revision 1.2  2004/07/27 17:23:22  mmiehling
-- removed slave port
--
-- Revision 1.1  2004/07/15 09:28:50  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY vme_dma_du IS
PORT (
   rst               : IN std_logic;
   clk               : IN std_logic;
   
   dma_sta            : IN std_logic_vector(9 DOWNTO 0);
   irq_o               : OUT std_logic;      -- irq for cpu; asserted when done or error (if enabled)
   
   arbit_slv         : IN std_logic;      -- if set, dma_slv has access and vica verse
   slv_ack            : IN std_logic;      -- if set, write from slave side will be done
   mstr_ack            : IN std_logic;      -- if set, write from master side will be done
   
   -- slave signals
   adr_i               : IN std_logic_vector(6 DOWNTO 2);
   sel_i               : IN std_logic_vector(3 DOWNTO 0);
   slv_dat_i         : IN std_logic_vector(31 DOWNTO 0);
   slv_dat_o         : OUT std_logic_vector(31 DOWNTO 0);
   we_i               : IN std_logic;
   ack_o               : IN std_logic;
   
   -- wb_master singals
   adr_o               : IN std_logic_vector(6 DOWNTO 2);
   mstr_dat_i         : IN std_logic_vector(31 DOWNTO 0);
   
   -- vme_dma_au
   dma_act_bd         : IN std_logic_vector(7 DOWNTO 4);      -- active bd number
   dma_dest_adr      : OUT std_logic_vector(31 DOWNTO 2);   -- active bd destination adress
   dma_sour_adr      : OUT std_logic_vector(31 DOWNTO 2);   -- active bd source adress
   dma_sour_device   : OUT std_logic_vector(2 DOWNTO 0);      -- selects the source device
   dma_dest_device   : OUT std_logic_vector(2 DOWNTO 0);      -- selects the destination device
   dma_vme_am         : OUT std_logic_vector(4 DOWNTO 0);      -- type of dma transmission
   inc_sour            : OUT std_logic;                        -- indicates if source adress should be incremented
   inc_dest            : OUT std_logic;                        -- indicates if destination adress should be incremented
   dma_size            : OUT std_logic_vector(15 DOWNTO 0);   -- size of data package
   clr_dma_act_bd      : OUT std_logic;                        -- clears dma_act_bd if dma_mstr has done without error or
                                                            -- when dma_err will be cleared
   
   -- vme_dma_mstr
--   start_dma         : OUT std_logic;                        -- flag starts dma-fsm and clears counters
   set_dma_err         : IN std_logic;                        -- sets dma error bit if vme error
   clr_dma_en         : IN std_logic;                        -- clears dma en bit if dma_mstr has done
   dma_en            : OUT std_logic;                        -- starts dma_mstr, if 0 => clears dma_act_bd counter
   dma_null            : OUT std_logic;                        -- indicates the last bd   
   en_mstr_dat_i_reg   : IN std_logic                           -- enable for data in

     );
END vme_dma_du;

ARCHITECTURE vme_dma_du_arch OF vme_dma_du IS 

   SIGNAL dma_sta_int               : std_logic_vector(7 DOWNTO 0);
   SIGNAL act_bd_conf_int      : std_logic_vector(31 DOWNTO 0);
   SIGNAL int_data            : std_logic_vector(31 DOWNTO 0);
   SIGNAL int_adr               : std_logic_vector(6 DOWNTO 2);
--   SIGNAL int_sel               : std_logic_vector(3 DOWNTO 0);
   SIGNAL dma_err               : std_logic;
   SIGNAL dma_irq               : std_logic;
   SIGNAL dma_ien               : std_logic;
   SIGNAL dma_en_int            : std_logic;
--   SIGNAL write_flag_slv      : std_logic;
   SIGNAL write_flag_mstr      : std_logic;
   SIGNAL mstr_dat_i_reg      : std_logic_vector(31 DOWNTO 0);
   SIGNAL dma_dest_adr_int      : std_logic_vector(31 DOWNTO 0);
   SIGNAL dma_sour_adr_int      : std_logic_vector(31 DOWNTO 0);
   SIGNAL dma_size_reg         : std_logic_vector(15 DOWNTO 0);
--   SIGNAL clr_dma_err         : std_logic;
   
BEGIN
--   clr_dma_act_bd      <= '1' WHEN (clr_dma_en = '1' AND set_dma_err = '0') OR clr_dma_err = '1' ELSE '0';
   clr_dma_act_bd      <= '1' WHEN (clr_dma_en = '1' AND set_dma_err = '0') OR dma_sta(9) = '1' ELSE '0';

--   dma_sta_int         <= dma_act_bd & dma_err & dma_irq & dma_ien & dma_en_int;
--   dma_sta             <= dma_sta_int;
--   dma_en            <= dma_en_int;
   dma_en            <= dma_sta(0);
--   irq_o               <= dma_irq;
   irq_o               <= dma_sta(2);
   
   
   dma_dest_adr      <= dma_dest_adr_int(31 DOWNTO 2);
   dma_sour_adr      <= dma_sour_adr_int(31 DOWNTO 2);
   dma_size            <= dma_size_reg;
   
   dma_sour_device    <= act_bd_conf_int(18 DOWNTO 16);
   dma_dest_device    <= act_bd_conf_int(14 DOWNTO 12);
   dma_vme_am          <= act_bd_conf_int(8 DOWNTO 4);
   inc_sour            <= act_bd_conf_int(2);
   inc_dest            <= act_bd_conf_int(1);
   dma_null            <= act_bd_conf_int(0);
   
--   int_data          <= slv_dat_i WHEN arbit_slv = '1' ELSE mstr_dat_i_reg;
--   int_adr             <= adr_i WHEN arbit_slv = '1' ELSE adr_o;
--   int_sel            <= sel_i WHEN arbit_slv = '1' ELSE "1111";
   int_data          <= mstr_dat_i_reg;
   int_adr             <= adr_o;
--   int_sel            <= "1111";
--   write_flag_slv      <= '1' WHEN ack_o = '1' AND we_i = '1' ELSE '0';
   write_flag_mstr   <= '1' WHEN mstr_ack = '1' ELSE '0';
   
   slv_dat_o <= (OTHERS => '0');

outdec : PROCESS(clk, rst)
  BEGIN
    IF rst = '1' THEN
--       slv_dat_o <= (OTHERS => '0');
       mstr_dat_i_reg <= (OTHERS => '0');
    ELSIF clk'EVENT AND clk = '1' THEN
       IF en_mstr_dat_i_reg = '1' THEN
          mstr_dat_i_reg <= mstr_dat_i;
       END IF;
--       CASE adr_i IS   -- only slave adress, because master does never read
--          WHEN "01011" => slv_dat_o <= "000000000000000000000000" & dma_sta_int;   -- 0x2c
--          WHEN "10010" => slv_dat_o <= dma_dest_adr_int(31 DOWNTO 2) & "00";   -- 0x48 
--          WHEN "10011" => slv_dat_o <= dma_sour_adr_int(31 DOWNTO 2) & "00";   -- 0x4c
--          WHEN "10100" => slv_dat_o <= "0000000000000000" & dma_size_reg;      -- 0x50
--          WHEN "10101" => slv_dat_o <= act_bd_conf_int;                        -- 0x54
--          WHEN OTHERS => slv_dat_o <= (OTHERS => '0');
--       END CASE;
    END IF;
  END PROCESS outdec;
   
---- dma_sta_int register 0x2c
--sta :PROCESS(clk, rst)
--  BEGIN
--     IF rst = '1' THEN
--        dma_en_int <= '0';
--        dma_ien <= '0';
--        dma_irq <= '0';
--        dma_err <= '0';
--      start_dma <= '0';
--      clr_dma_err <= '0';
--     ELSIF clk'EVENT AND clk = '1' THEN
--        IF clr_dma_en = '1' THEN
--           dma_en_int <= '0';
--           start_dma <= '0';
--        ELSIF write_flag_slv = '1' AND int_sel(0) = '1' AND int_adr = "01011" THEN 
--           dma_en_int <= int_data(0);
--           start_dma <= int_data(0);
--        ELSE
--           start_dma <= '0';
--        END IF;
--
--        IF write_flag_slv = '1' AND int_sel(0) = '1' AND int_adr = "01011" THEN 
--           dma_ien <= int_data(1);
--        END IF;
--
--        IF clr_dma_en = '1' AND dma_ien = '1' THEN
--           dma_irq <= '1';
--        ELSIF write_flag_slv = '1' AND int_sel(0) = '1' AND int_adr = "01011" AND int_data(2) = '1' THEN 
--           dma_irq <= '0';
--        END IF;
--
--        IF set_dma_err = '1' THEN
--           dma_err <= '1';
--           clr_dma_err <= '0';
--        ELSIF write_flag_slv = '1' AND int_sel(0) = '1' AND int_adr = "01011" AND int_data(3) = '1' THEN 
--           dma_err <= '0';
--           clr_dma_err <= '1';
--        ELSE
--           clr_dma_err <= '0';
--        END IF;
--     END IF;
--  END PROCESS sta;   

-- dma_dest_adr_int 0x48
dest : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
      dma_dest_adr_int <= (OTHERS => '0');
     ELSIF clk'EVENT AND clk = '1' THEN
       IF (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "00") THEN 
         dma_dest_adr_int(31 DOWNTO 0) <= int_data(31 DOWNTO 0);
      END IF;
--       IF (write_flag_slv = '1' AND int_sel(0) = '1' AND int_adr = "10010") OR (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "00") THEN 
--         dma_dest_adr_int(7 DOWNTO 0) <= int_data(7 DOWNTO 0);
--      END IF;
--      IF (write_flag_slv = '1' AND int_sel(1) = '1' AND int_adr = "10010") OR (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "00") THEN 
--         dma_dest_adr_int(15 DOWNTO 8) <= int_data(15 DOWNTO 8);
--      END IF;
--      IF (write_flag_slv = '1' AND int_sel(2) = '1' AND int_adr = "10010") OR (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "00") THEN 
--         dma_dest_adr_int(23 DOWNTO 16) <= int_data(23 DOWNTO 16);
--      END IF;
--      IF (write_flag_slv = '1' AND int_sel(3) = '1' AND int_adr = "10010") OR (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "00") THEN 
--         dma_dest_adr_int(31 DOWNTO 24) <= int_data(31 DOWNTO 24);
--      END IF;
   END IF;
  END PROCESS dest;

-- dma_sour_adr_int 0x4c
sour: PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
      dma_sour_adr_int <= (OTHERS => '0');
     ELSIF clk'EVENT AND clk = '1' THEN
       IF (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "01") THEN 
         dma_sour_adr_int(31 DOWNTO 0) <= int_data(31 DOWNTO 0);
      END IF;
--       IF (write_flag_slv = '1' AND int_sel(0) = '1' AND int_adr = "10011") OR (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "01") THEN 
--         dma_sour_adr_int(7 DOWNTO 0) <= int_data(7 DOWNTO 0);
--      END IF;
--      IF (write_flag_slv = '1' AND int_sel(1) = '1' AND int_adr = "10011") OR (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "01") THEN 
--         dma_sour_adr_int(15 DOWNTO 8) <= int_data(15 DOWNTO 8);
--      END IF;
--       IF (write_flag_slv = '1' AND int_sel(2) = '1' AND int_adr = "10011") OR (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "01") THEN 
--         dma_sour_adr_int(23 DOWNTO 16) <= int_data(23 DOWNTO 16);
--      END IF;
--       IF (write_flag_slv = '1' AND int_sel(3) = '1' AND int_adr = "10011") OR (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "01") THEN 
--         dma_sour_adr_int(31 DOWNTO 24) <= int_data(31 DOWNTO 24);
--      END IF;
   END IF;
  END PROCESS sour;
   
-- dma_size 0x50   
siz : PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
      dma_size_reg <= (OTHERS => '0');
     ELSIF clk'EVENT AND clk = '1' THEN
       IF (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "10") THEN 
         dma_size_reg(15 DOWNTO 0) <= int_data(15 DOWNTO 0);
      END IF;
--       IF (write_flag_slv = '1' AND int_sel(0) = '1' AND int_adr = "10100") OR (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "10") THEN 
--         dma_size_reg(7 DOWNTO 0) <= int_data(7 DOWNTO 0);
--      END IF;
--       IF (write_flag_slv = '1' AND int_sel(1) = '1' AND int_adr = "10100") OR (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "10") THEN 
--         dma_size_reg(15 DOWNTO 8) <= int_data(15 DOWNTO 8);
--      END IF;
   END IF;
  END PROCESS siz;

-- act_bd_conf_int 0x54
conf: PROCESS(clk, rst)
  BEGIN
     IF rst = '1' THEN
      act_bd_conf_int <= (OTHERS => '0');
     ELSIF clk'EVENT AND clk = '1' THEN
       IF (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "11") THEN 
         act_bd_conf_int(31 DOWNTO 0) <= int_data(31 DOWNTO 0);
      END IF;
--       IF (write_flag_slv = '1' AND int_sel(0) = '1' AND int_adr = "10101") OR (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "11") THEN 
--         act_bd_conf_int(7 DOWNTO 0) <= int_data(7 DOWNTO 0);
--      END IF;
--       IF (write_flag_slv = '1' AND int_sel(1) = '1' AND int_adr = "10101") OR (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "11") THEN 
--         act_bd_conf_int(15 DOWNTO 8) <= int_data(15 DOWNTO 8);
--      END IF;
--       IF (write_flag_slv = '1' AND int_sel(2) = '1' AND int_adr = "10101") OR (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "11") THEN 
--         act_bd_conf_int(23 DOWNTO 16) <= int_data(23 DOWNTO 16);
--      END IF;
--       IF (write_flag_slv = '1' AND int_sel(3) = '1' AND int_adr = "10101") OR (write_flag_mstr = '1' AND int_adr(3 DOWNTO 2) = "11") THEN 
--         act_bd_conf_int(31 DOWNTO 24) <= int_data(31 DOWNTO 24);
--      END IF;
   END IF;
  END PROCESS conf;

END vme_dma_du_arch;
