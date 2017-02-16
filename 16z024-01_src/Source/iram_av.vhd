---------------------------------------------------------------
-- Title         : Internal RAM with Avalon I/F
-- Project       : 16z024-01
---------------------------------------------------------------
-- File          : iram_av.vhd
-- Author        : Ferdinand Lenhardt
-- Email         : Ferdinand.Lenhardt@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 30/05/05
---------------------------------------------------------------
-- Simulator     : ModelSim-Altera 5.8e
-- Synthesis     : Quartus II 4.2 SP1
---------------------------------------------------------------
-- Description :
--
-- This is a wrapper for "Internal RAM with Wishbone I/F".
-- For ACEX this module can be used only as a ROM.
---------------------------------------------------------------
-- Hierarchy:
--
-- iram_av
--    iram_wb
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
-- $Log: iram_av.vhd,v $
-- Revision 1.7  2009/01/27 14:30:15  FLenhardt
-- Added support for fpga_pkg_2
--
-- Revision 1.6  2007/11/21 13:46:03  FLenhardt
-- Added a commentary to generic USEDW_WIDTH
--
-- Revision 1.5  2006/02/27 16:49:41  TWickleder
-- Changed the handling of the generic read_only to use it in both interfaces
--
-- Revision 1.4  2005/10/19 14:24:18  flenhardt
-- Workaround for SOPC Builder bug regarding a generic of type BOOLEAN
--
-- Revision 1.3  2005/10/19 13:17:04  flenhardt
-- Added generic READ_ONLY
--
-- Revision 1.2  2005/06/28 09:13:47  flenhardt
-- Workaround for SOPC Builder bug regarding generics
--
-- Revision 1.1  2005/05/30 09:43:03  flenhardt
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY work;
USE work.fpga_pkg_2.ALL;

ENTITY iram_av IS
GENERIC
(
   fpga_family: family_type := CYCLONE; -- ACEX,CYCLONE,CYCLONE2,CYCLONE3,ARRIA_GX
   read_only: natural := 0; -- 0=R/W, 1=R/O
   usedw_width: positive := 6; -- 2**(usedw_width + 2) bytes
   location: string := "iram.hex" -- string shall be empty if no HEX file
);

PORT
(
   clk   : IN std_logic; -- Wishbone clock
   reset : IN std_logic; -- global async high active reset

   -- Avalon signals
   av_chipselect  : IN std_logic;                      -- chip select
   av_byteenable  : IN std_logic_vector(3 DOWNTO 0);   -- byte enable
   av_write       : IN std_logic;                      -- write enable
   av_writedata   : IN std_logic_vector(31 DOWNTO 0);  -- write data
   av_read        : IN std_logic;                      -- read enable
   av_readdata    : OUT std_logic_vector(31 DOWNTO 0); -- read data
   av_address     : IN std_logic_vector((usedw_width + 1) DOWNTO 2);
   av_waitrequest : OUT std_logic                      -- delay access
);
END iram_av;

ARCHITECTURE iram_av_arch OF iram_av IS

COMPONENT iram_wb
GENERIC
(
   FPGA_FAMILY: family_type;
   read_only: natural;
   USEDW_WIDTH: positive;
   LOCATION: string
);

PORT
(
   clk   : IN std_logic; -- Wishbone clock
   rst   : IN std_logic; -- global async high active reset

   -- Wishbone signals
   stb_i : IN std_logic;                       -- request
   cyc_i : IN std_logic;                       -- chip select
   ack_o : OUT std_logic;                      -- acknowledge
   we_i  : IN std_logic;                       -- write=1 read=0
   sel_i : IN std_logic_vector(3 DOWNTO 0);    -- byte enables
   adr_i : IN std_logic_vector((usedw_width + 1) DOWNTO 2);
   dat_i : IN std_logic_vector(31 DOWNTO 0);   -- data in
   dat_o : OUT std_logic_vector(31 DOWNTO 0)   -- data out
);
END COMPONENT;

   SIGNAL wb_stb_i         : std_logic;
   SIGNAL wb_we_i          : std_logic;
   SIGNAL wb_ack_o         : std_logic;
BEGIN

ram: iram_wb
GENERIC MAP
(
   FPGA_FAMILY => FPGA_FAMILY,
   read_only   => read_only,
   usedw_width => usedw_width,
   location    => location
)
PORT MAP
(
   clk   => clk,
   rst   => reset,
   stb_i => wb_stb_i,
   cyc_i => av_chipselect,
   ack_o => wb_ack_o,
   we_i  => wb_we_i,
   sel_i => av_byteenable,
   adr_i => av_address,
   dat_i => av_writedata,
   dat_o => av_readdata
);

wb_stb_i          <= av_write OR av_read;
wb_we_i           <= av_write;
-- wait request only when stb_i and cyc_i active and no ackowledge yet.
av_waitrequest    <= NOT(wb_ack_o) WHEN (av_chipselect='1' AND wb_stb_i='1') ELSE      
                     '1';

END iram_av_arch;
