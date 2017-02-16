--------------------------------------------------------------------------------
-- Title       : Utilities package
-- Project     : 
--------------------------------------------------------------------------------
-- File        : src_utils_pkg.vhd
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 02.06.2011
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6a / ModelSim AE 6.5e sp1
-- Synthesis   :
--------------------------------------------------------------------------------
-- Description :
-- utilities to foster source code programming
--------------------------------------------------------------------------------
-- Hierarchy   :
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
library ieee;
use ieee.std_logic_1164.all;

package src_utils_pkg is
   constant TYPE_IS_MEMORY : std_logic_vector(4 downto 0)  := "00000";
   constant TYPE_IS_IO     : std_logic_vector(4 downto 0)  := "00010";
   constant TYPE_IS_CPL    : std_logic_vector(4 downto 0)  := "01010";
   constant FMT_IS_READ    : std_logic_vector(2 downto 0)  := "000";
   constant FMT_IS_WRITE   : std_logic_vector(2 downto 0)  := "010";


   constant ZERO_02B       : std_logic_vector(1 downto 0)  := "00";
   constant ZERO_03B       : std_logic_vector(2 downto 0)  := "000";
   constant ZERO_04B       : std_logic_vector(3 downto 0)  := x"0";
   constant ZERO_10B       : std_logic_vector(9 downto 0)  := "0000000000";
   constant ZERO_11B       : std_logic_vector(10 downto 0) := "00000000000";
   constant ZERO_12B       : std_logic_vector(11 downto 0) := x"000";
   constant ZERO_20B       : std_logic_vector(19 downto 0) := x"00000";
   
   constant ONE_02B        : std_logic_vector(1 downto 0)  := "01";
   constant ONE_03B        : std_logic_vector(2 downto 0)  := "001";
   constant ONE_04B        : std_logic_vector(3 downto 0)  := x"1";
   constant ONE_05B        : std_logic_vector(4 downto 0)  := "00001";
   constant ONE_10B        : std_logic_vector(9 downto 0)  := "0000000001";
   constant ONE_11B        : std_logic_vector(10 downto 0) := "00000000001";
   constant ONE_12B        : std_logic_vector(11 downto 0) := x"001";
   
   constant TWO_02B        : std_logic_vector(1 downto 0)  := "10";
   constant TWO_03B        : std_logic_vector(2 downto 0)  := "010";
   constant TWO_04B        : std_logic_vector(3 downto 0)  := x"2";
   constant TWO_10B        : std_logic_vector(9 downto 0)  := "0000000010";
   constant TWO_11B        : std_logic_vector(10 downto 0) := "00000000010";
   constant TWO_12B        : std_logic_vector(11 downto 0) := x"002";
   
   constant THREE_02B      : std_logic_vector(1 downto 0)  := "11";
   constant THREE_03B      : std_logic_vector(2 downto 0)  := "011";
   constant THREE_04B      : std_logic_vector(3 downto 0)  := x"3";
   constant THREE_10B      : std_logic_vector(9 downto 0)  := "0000000011";
   constant THREE_12B      : std_logic_vector(11 downto 0) := x"003";
   
   constant FOUR_03B       : std_logic_vector(2 downto 0)  := "100";
   constant FOUR_04B       : std_logic_vector(3 downto 0)  := x"4";
   constant FOUR_12B       : std_logic_vector(11 downto 0) := x"004";
   constant FOUR_32B       : std_logic_vector(31 downto 0) := x"00000004";
   
   constant FIVE_12B       : std_logic_vector(11 downto 0) := x"005";
   
   constant SIX_04B        : std_logic_vector(3 downto 0)  := x"6";
   constant SIX_12B        : std_logic_vector(11 downto 0) := x"006";
   
   constant EIGHT_04B      : std_logic_vector(3 downto 0)  := x"8";
   constant EIGHT_32B      : std_logic_vector(31 downto 0) := x"00000008";
   
   constant C_04B          : std_logic_vector(3 downto 0)  := x"C";
   
   constant FULL_03B       : std_logic_vector(2 downto 0)  := "111";
   constant FULL_10B       : std_logic_vector(9 downto 0)  := "1111111111";
   
   constant X_400_11B      : std_logic_vector(10 downto 0) := "10000000000";
end src_utils_pkg;
