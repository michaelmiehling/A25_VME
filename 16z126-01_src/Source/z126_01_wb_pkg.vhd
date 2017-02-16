---------------------------------------------------------------
-- Title         : system unit package
-- Project       : Embedded System Module
---------------------------------------------------------------
-- File          : z126_01_wb_pkg.vhd
-- Author        : Michael Miehling
-- Email         : miehling@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 17/02/04
---------------------------------------------------------------
-- Simulator     : Modelsim PE 5.7g
-- Synthesis     : Quartus II 3.0
---------------------------------------------------------------
-- Description :   
-- 
-- Package for wishbone bus functions.
-- Consists of data mux for x chip selects.
-- Wishbone bus input and output type definition.
-- This package is used for wb_bus (busmaker).
--
-- Switch-fab naming convention is:
-- All signal names are based on the source of the signal
-- (wbo_slave = output singals of slave)
---------------------------------------------------------------
-- Hierarchy:
--
-- -
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
-- $Revision: 1.1 $
--
-- $Log: z126_01_wb_pkg.vhd,v $
-- Revision 1.1  2014/03/03 17:49:58  AGeissler
-- Initial Revision
--
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE z126_01_wb_pkg IS

   TYPE wbo_type IS record
      stb   : std_logic;
      sel   : std_logic_vector(3 DOWNTO 0);
      adr   : std_logic_vector(31 DOWNTO 0);
      we    : std_logic;
      dat   : std_logic_vector(31 DOWNTO 0);
      tga   : std_logic_vector(5 DOWNTO 0);
      cti   : std_logic_vector(2 DOWNTO 0);
      bte   : std_logic_vector(1 DOWNTO 0);
   END record;
   
   TYPE wbi_type IS record
      ack   : std_logic;
      err   : std_logic;
      dat   : std_logic_vector(31 DOWNTO 0);
   END record;
   

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(1 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(2 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(3 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(4 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(5 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(6 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(7 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(8 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(9 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(10 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(11 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(12 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(13 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(14 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(15 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_15 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(16 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_15 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_16 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(17 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_15 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_16 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_17 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(18 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_15 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_16 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_17 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_18 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(19 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_15 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_16 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_17 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_18 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_19 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(20 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_15 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_16 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_17 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_18 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_19 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_20 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(21 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_15 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_16 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_17 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_18 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_19 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_20 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_21 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(22 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_15 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_16 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_17 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_18 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_19 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_20 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_21 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_22 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
                     
   PROCEDURE switch_fab(SIGNAL clk              : IN std_logic;
                        SIGNAL rst              : IN std_logic;
                        -- wb-bus #0
                        SIGNAL cyc_0            : IN std_logic;
                        SIGNAL ack_0            : OUT std_logic;
                        SIGNAL err_0            : OUT std_logic;
                        SIGNAL wbo_0            : IN wbo_type;
                        -- wb-bus to slave
                        SIGNAL wbo_slave        : IN wbi_type;
                        SIGNAL wbi_slave        : OUT wbo_type;
                        SIGNAL wbi_slave_cyc    : OUT std_logic
                        ) ;

END z126_01_wb_pkg;

PACKAGE BODY z126_01_wb_pkg IS

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(1 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "01" =>   data_out <= data_in_0;
            WHEN "10" =>   data_out <= data_in_1;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(2 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "001" =>  data_out <= data_in_0;
            WHEN "010" =>  data_out <= data_in_1;
            WHEN "100" =>  data_out <= data_in_2;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(3 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "0001" => data_out <= data_in_0;
            WHEN "0010" => data_out <= data_in_1;
            WHEN "0100" => data_out <= data_in_2;
            WHEN "1000" => data_out <= data_in_3;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(4 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "00001" =>   data_out <= data_in_0;
            WHEN "00010" =>   data_out <= data_in_1;
            WHEN "00100" =>   data_out <= data_in_2;
            WHEN "01000" =>   data_out <= data_in_3;
            WHEN "10000" =>   data_out <= data_in_4;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(5 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "000001" =>  data_out <= data_in_0;
            WHEN "000010" =>  data_out <= data_in_1;
            WHEN "000100" =>  data_out <= data_in_2;
            WHEN "001000" =>  data_out <= data_in_3;
            WHEN "010000" =>  data_out <= data_in_4;
            WHEN "100000" =>  data_out <= data_in_5;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(6 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "0000001" => data_out <= data_in_0;
            WHEN "0000010" => data_out <= data_in_1;
            WHEN "0000100" => data_out <= data_in_2;
            WHEN "0001000" => data_out <= data_in_3;
            WHEN "0010000" => data_out <= data_in_4;
            WHEN "0100000" => data_out <= data_in_5;
            WHEN "1000000" => data_out <= data_in_6;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(7 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "00000001" =>   data_out <= data_in_0;
            WHEN "00000010" =>   data_out <= data_in_1;
            WHEN "00000100" =>   data_out <= data_in_2;
            WHEN "00001000" =>   data_out <= data_in_3;
            WHEN "00010000" =>   data_out <= data_in_4;
            WHEN "00100000" =>   data_out <= data_in_5;
            WHEN "01000000" =>   data_out <= data_in_6;
            WHEN "10000000" =>   data_out <= data_in_7;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(8 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "000000001" =>  data_out <= data_in_0;
            WHEN "000000010" =>  data_out <= data_in_1;
            WHEN "000000100" =>  data_out <= data_in_2;
            WHEN "000001000" =>  data_out <= data_in_3;
            WHEN "000010000" =>  data_out <= data_in_4;
            WHEN "000100000" =>  data_out <= data_in_5;
            WHEN "001000000" =>  data_out <= data_in_6;
            WHEN "010000000" =>  data_out <= data_in_7;
            WHEN "100000000" =>  data_out <= data_in_8;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(9 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "0000000001" => data_out <= data_in_0;
            WHEN "0000000010" => data_out <= data_in_1;
            WHEN "0000000100" => data_out <= data_in_2;
            WHEN "0000001000" => data_out <= data_in_3;
            WHEN "0000010000" => data_out <= data_in_4;
            WHEN "0000100000" => data_out <= data_in_5;
            WHEN "0001000000" => data_out <= data_in_6;
            WHEN "0010000000" => data_out <= data_in_7;
            WHEN "0100000000" => data_out <= data_in_8;
            WHEN "1000000000" => data_out <= data_in_9;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(10 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "00000000001" =>   data_out <= data_in_0;
            WHEN "00000000010" =>   data_out <= data_in_1;
            WHEN "00000000100" =>   data_out <= data_in_2;
            WHEN "00000001000" =>   data_out <= data_in_3;
            WHEN "00000010000" =>   data_out <= data_in_4;
            WHEN "00000100000" =>   data_out <= data_in_5;
            WHEN "00001000000" =>   data_out <= data_in_6;
            WHEN "00010000000" =>   data_out <= data_in_7;
            WHEN "00100000000" =>   data_out <= data_in_8;
            WHEN "01000000000" =>   data_out <= data_in_9;
            WHEN "10000000000" =>   data_out <= data_in_10;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(11 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "000000000001" =>  data_out <= data_in_0;
            WHEN "000000000010" =>  data_out <= data_in_1;
            WHEN "000000000100" =>  data_out <= data_in_2;
            WHEN "000000001000" =>  data_out <= data_in_3;
            WHEN "000000010000" =>  data_out <= data_in_4;
            WHEN "000000100000" =>  data_out <= data_in_5;
            WHEN "000001000000" =>  data_out <= data_in_6;
            WHEN "000010000000" =>  data_out <= data_in_7;
            WHEN "000100000000" =>  data_out <= data_in_8;
            WHEN "001000000000" =>  data_out <= data_in_9;
            WHEN "010000000000" =>  data_out <= data_in_10;
            WHEN "100000000000" =>  data_out <= data_in_11;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(12 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "0000000000001" => data_out <= data_in_0;
            WHEN "0000000000010" => data_out <= data_in_1;
            WHEN "0000000000100" => data_out <= data_in_2;
            WHEN "0000000001000" => data_out <= data_in_3;
            WHEN "0000000010000" => data_out <= data_in_4;
            WHEN "0000000100000" => data_out <= data_in_5;
            WHEN "0000001000000" => data_out <= data_in_6;
            WHEN "0000010000000" => data_out <= data_in_7;
            WHEN "0000100000000" => data_out <= data_in_8;
            WHEN "0001000000000" => data_out <= data_in_9;
            WHEN "0010000000000" => data_out <= data_in_10;
            WHEN "0100000000000" => data_out <= data_in_11;
            WHEN "1000000000000" => data_out <= data_in_12;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(13 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "00000000000001" =>   data_out <= data_in_0;
            WHEN "00000000000010" =>   data_out <= data_in_1;
            WHEN "00000000000100" =>   data_out <= data_in_2;
            WHEN "00000000001000" =>   data_out <= data_in_3;
            WHEN "00000000010000" =>   data_out <= data_in_4;
            WHEN "00000000100000" =>   data_out <= data_in_5;
            WHEN "00000001000000" =>   data_out <= data_in_6;
            WHEN "00000010000000" =>   data_out <= data_in_7;
            WHEN "00000100000000" =>   data_out <= data_in_8;
            WHEN "00001000000000" =>   data_out <= data_in_9;
            WHEN "00010000000000" =>   data_out <= data_in_10;
            WHEN "00100000000000" =>   data_out <= data_in_11;
            WHEN "01000000000000" =>   data_out <= data_in_12;
            WHEN "10000000000000" =>   data_out <= data_in_13;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(14 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "000000000000001" =>  data_out <= data_in_0;
            WHEN "000000000000010" =>  data_out <= data_in_1;
            WHEN "000000000000100" =>  data_out <= data_in_2;
            WHEN "000000000001000" =>  data_out <= data_in_3;
            WHEN "000000000010000" =>  data_out <= data_in_4;
            WHEN "000000000100000" =>  data_out <= data_in_5;
            WHEN "000000001000000" =>  data_out <= data_in_6;
            WHEN "000000010000000" =>  data_out <= data_in_7;
            WHEN "000000100000000" =>  data_out <= data_in_8;
            WHEN "000001000000000" =>  data_out <= data_in_9;
            WHEN "000010000000000" =>  data_out <= data_in_10;
            WHEN "000100000000000" =>  data_out <= data_in_11;
            WHEN "001000000000000" =>  data_out <= data_in_12;
            WHEN "010000000000000" =>  data_out <= data_in_13;
            WHEN "100000000000000" =>  data_out <= data_in_14;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(15 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_15 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "0000000000000001" => data_out <= data_in_0;
            WHEN "0000000000000010" => data_out <= data_in_1;
            WHEN "0000000000000100" => data_out <= data_in_2;
            WHEN "0000000000001000" => data_out <= data_in_3;
            WHEN "0000000000010000" => data_out <= data_in_4;
            WHEN "0000000000100000" => data_out <= data_in_5;
            WHEN "0000000001000000" => data_out <= data_in_6;
            WHEN "0000000010000000" => data_out <= data_in_7;
            WHEN "0000000100000000" => data_out <= data_in_8;
            WHEN "0000001000000000" => data_out <= data_in_9;
            WHEN "0000010000000000" => data_out <= data_in_10;
            WHEN "0000100000000000" => data_out <= data_in_11;
            WHEN "0001000000000000" => data_out <= data_in_12;
            WHEN "0010000000000000" => data_out <= data_in_13;
            WHEN "0100000000000000" => data_out <= data_in_14;
            WHEN "1000000000000000" => data_out <= data_in_15;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(16 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_15 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_16 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "00000000000000001" =>   data_out <= data_in_0;
            WHEN "00000000000000010" =>   data_out <= data_in_1;
            WHEN "00000000000000100" =>   data_out <= data_in_2;
            WHEN "00000000000001000" =>   data_out <= data_in_3;
            WHEN "00000000000010000" =>   data_out <= data_in_4;
            WHEN "00000000000100000" =>   data_out <= data_in_5;
            WHEN "00000000001000000" =>   data_out <= data_in_6;
            WHEN "00000000010000000" =>   data_out <= data_in_7;
            WHEN "00000000100000000" =>   data_out <= data_in_8;
            WHEN "00000001000000000" =>   data_out <= data_in_9;
            WHEN "00000010000000000" =>   data_out <= data_in_10;
            WHEN "00000100000000000" =>   data_out <= data_in_11;
            WHEN "00001000000000000" =>   data_out <= data_in_12;
            WHEN "00010000000000000" =>   data_out <= data_in_13;
            WHEN "00100000000000000" =>   data_out <= data_in_14;
            WHEN "01000000000000000" =>   data_out <= data_in_15;
            WHEN "10000000000000000" =>   data_out <= data_in_16;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(17 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_15 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_16 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_17 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "000000000000000001" =>  data_out <= data_in_0;
            WHEN "000000000000000010" =>  data_out <= data_in_1;
            WHEN "000000000000000100" =>  data_out <= data_in_2;
            WHEN "000000000000001000" =>  data_out <= data_in_3;
            WHEN "000000000000010000" =>  data_out <= data_in_4;
            WHEN "000000000000100000" =>  data_out <= data_in_5;
            WHEN "000000000001000000" =>  data_out <= data_in_6;
            WHEN "000000000010000000" =>  data_out <= data_in_7;
            WHEN "000000000100000000" =>  data_out <= data_in_8;
            WHEN "000000001000000000" =>  data_out <= data_in_9;
            WHEN "000000010000000000" =>  data_out <= data_in_10;
            WHEN "000000100000000000" =>  data_out <= data_in_11;
            WHEN "000001000000000000" =>  data_out <= data_in_12;
            WHEN "000010000000000000" =>  data_out <= data_in_13;
            WHEN "000100000000000000" =>  data_out <= data_in_14;
            WHEN "001000000000000000" =>  data_out <= data_in_15;
            WHEN "010000000000000000" =>  data_out <= data_in_16;
            WHEN "100000000000000000" =>  data_out <= data_in_17;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(18 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_15 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_16 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_17 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_18 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "0000000000000000001" => data_out <= data_in_0;
            WHEN "0000000000000000010" => data_out <= data_in_1;
            WHEN "0000000000000000100" => data_out <= data_in_2;
            WHEN "0000000000000001000" => data_out <= data_in_3;
            WHEN "0000000000000010000" => data_out <= data_in_4;
            WHEN "0000000000000100000" => data_out <= data_in_5;
            WHEN "0000000000001000000" => data_out <= data_in_6;
            WHEN "0000000000010000000" => data_out <= data_in_7;
            WHEN "0000000000100000000" => data_out <= data_in_8;
            WHEN "0000000001000000000" => data_out <= data_in_9;
            WHEN "0000000010000000000" => data_out <= data_in_10;
            WHEN "0000000100000000000" => data_out <= data_in_11;
            WHEN "0000001000000000000" => data_out <= data_in_12;
            WHEN "0000010000000000000" => data_out <= data_in_13;
            WHEN "0000100000000000000" => data_out <= data_in_14;
            WHEN "0001000000000000000" => data_out <= data_in_15;
            WHEN "0010000000000000000" => data_out <= data_in_16;
            WHEN "0100000000000000000" => data_out <= data_in_17;
            WHEN "1000000000000000000" => data_out <= data_in_18;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(19 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_15 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_16 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_17 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_18 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_19 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "00000000000000000001" =>   data_out <= data_in_0;
            WHEN "00000000000000000010" =>   data_out <= data_in_1;
            WHEN "00000000000000000100" =>   data_out <= data_in_2;
            WHEN "00000000000000001000" =>   data_out <= data_in_3;
            WHEN "00000000000000010000" =>   data_out <= data_in_4;
            WHEN "00000000000000100000" =>   data_out <= data_in_5;
            WHEN "00000000000001000000" =>   data_out <= data_in_6;
            WHEN "00000000000010000000" =>   data_out <= data_in_7;
            WHEN "00000000000100000000" =>   data_out <= data_in_8;
            WHEN "00000000001000000000" =>   data_out <= data_in_9;
            WHEN "00000000010000000000" =>   data_out <= data_in_10;
            WHEN "00000000100000000000" =>   data_out <= data_in_11;
            WHEN "00000001000000000000" =>   data_out <= data_in_12;
            WHEN "00000010000000000000" =>   data_out <= data_in_13;
            WHEN "00000100000000000000" =>   data_out <= data_in_14;
            WHEN "00001000000000000000" =>   data_out <= data_in_15;
            WHEN "00010000000000000000" =>   data_out <= data_in_16;
            WHEN "00100000000000000000" =>   data_out <= data_in_17;
            WHEN "01000000000000000000" =>   data_out <= data_in_18;
            WHEN "10000000000000000000" =>   data_out <= data_in_19;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(20 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_15 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_16 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_17 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_18 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_19 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_20 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "000000000000000000001" =>  data_out <= data_in_0;
            WHEN "000000000000000000010" =>  data_out <= data_in_1;
            WHEN "000000000000000000100" =>  data_out <= data_in_2;
            WHEN "000000000000000001000" =>  data_out <= data_in_3;
            WHEN "000000000000000010000" =>  data_out <= data_in_4;
            WHEN "000000000000000100000" =>  data_out <= data_in_5;
            WHEN "000000000000001000000" =>  data_out <= data_in_6;
            WHEN "000000000000010000000" =>  data_out <= data_in_7;
            WHEN "000000000000100000000" =>  data_out <= data_in_8;
            WHEN "000000000001000000000" =>  data_out <= data_in_9;
            WHEN "000000000010000000000" =>  data_out <= data_in_10;
            WHEN "000000000100000000000" =>  data_out <= data_in_11;
            WHEN "000000001000000000000" =>  data_out <= data_in_12;
            WHEN "000000010000000000000" =>  data_out <= data_in_13;
            WHEN "000000100000000000000" =>  data_out <= data_in_14;
            WHEN "000001000000000000000" =>  data_out <= data_in_15;
            WHEN "000010000000000000000" =>  data_out <= data_in_16;
            WHEN "000100000000000000000" =>  data_out <= data_in_17;
            WHEN "001000000000000000000" =>  data_out <= data_in_18;
            WHEN "010000000000000000000" =>  data_out <= data_in_19;
            WHEN "100000000000000000000" =>  data_out <= data_in_20;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(21 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_15 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_16 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_17 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_18 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_19 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_20 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_21 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "0000000000000000000001" => data_out <= data_in_0;
            WHEN "0000000000000000000010" => data_out <= data_in_1;
            WHEN "0000000000000000000100" => data_out <= data_in_2;
            WHEN "0000000000000000001000" => data_out <= data_in_3;
            WHEN "0000000000000000010000" => data_out <= data_in_4;
            WHEN "0000000000000000100000" => data_out <= data_in_5;
            WHEN "0000000000000001000000" => data_out <= data_in_6;
            WHEN "0000000000000010000000" => data_out <= data_in_7;
            WHEN "0000000000000100000000" => data_out <= data_in_8;
            WHEN "0000000000001000000000" => data_out <= data_in_9;
            WHEN "0000000000010000000000" => data_out <= data_in_10;
            WHEN "0000000000100000000000" => data_out <= data_in_11;
            WHEN "0000000001000000000000" => data_out <= data_in_12;
            WHEN "0000000010000000000000" => data_out <= data_in_13;
            WHEN "0000000100000000000000" => data_out <= data_in_14;
            WHEN "0000001000000000000000" => data_out <= data_in_15;
            WHEN "0000010000000000000000" => data_out <= data_in_16;
            WHEN "0000100000000000000000" => data_out <= data_in_17;
            WHEN "0001000000000000000000" => data_out <= data_in_18;
            WHEN "0010000000000000000000" => data_out <= data_in_19;
            WHEN "0100000000000000000000" => data_out <= data_in_20;
            WHEN "1000000000000000000000" => data_out <= data_in_21;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(22 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_1  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_2  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_3  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_4  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_5  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_6  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_7  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_8  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_9  : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_10 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_11 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_12 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_13 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_14 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_15 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_16 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_17 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_18 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_19 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_20 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_21 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_in_22 : IN std_logic_vector(31 DOWNTO 0);
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "00000000000000000000001" =>   data_out <= data_in_0;
            WHEN "00000000000000000000010" =>   data_out <= data_in_1;
            WHEN "00000000000000000000100" =>   data_out <= data_in_2;
            WHEN "00000000000000000001000" =>   data_out <= data_in_3;
            WHEN "00000000000000000010000" =>   data_out <= data_in_4;
            WHEN "00000000000000000100000" =>   data_out <= data_in_5;
            WHEN "00000000000000001000000" =>   data_out <= data_in_6;
            WHEN "00000000000000010000000" =>   data_out <= data_in_7;
            WHEN "00000000000000100000000" =>   data_out <= data_in_8;
            WHEN "00000000000001000000000" =>   data_out <= data_in_9;
            WHEN "00000000000010000000000" =>   data_out <= data_in_10;
            WHEN "00000000000100000000000" =>   data_out <= data_in_11;
            WHEN "00000000001000000000000" =>   data_out <= data_in_12;
            WHEN "00000000010000000000000" =>   data_out <= data_in_13;
            WHEN "00000000100000000000000" =>   data_out <= data_in_14;
            WHEN "00000001000000000000000" =>   data_out <= data_in_15;
            WHEN "00000010000000000000000" =>   data_out <= data_in_16;
            WHEN "00000100000000000000000" =>   data_out <= data_in_17;
            WHEN "00001000000000000000000" =>   data_out <= data_in_18;
            WHEN "00010000000000000000000" =>   data_out <= data_in_19;
            WHEN "00100000000000000000000" =>   data_out <= data_in_20;
            WHEN "01000000000000000000000" =>   data_out <= data_in_21;
            WHEN "10000000000000000000000" =>   data_out <= data_in_22;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE switch_fab(SIGNAL clk              : IN std_logic;
                        SIGNAL rst              : IN std_logic;
                        -- wb-bus #0
                        SIGNAL cyc_0            : IN std_logic;
                        SIGNAL ack_0            : OUT std_logic;
                        SIGNAL err_0            : OUT std_logic;
                        SIGNAL wbo_0            : IN wbo_type;
                        -- wb-bus to slave
                        SIGNAL wbo_slave        : IN wbi_type;
                        SIGNAL wbi_slave        : OUT wbo_type;
                        SIGNAL wbi_slave_cyc    : OUT std_logic
                        ) IS

   BEGIN

      IF rst = '1' THEN
         wbi_slave.stb <= '0';
      ELSIF clk'EVENT AND clk = '1' THEN
         IF cyc_0 = '1' THEN
         IF wbo_slave.err = '1' THEN                              -- error
            wbi_slave.stb <= '0';
         ELSIF wbo_slave.ack = '1' AND wbo_0.cti = "010" THEN  -- burst
            wbi_slave.stb <= wbo_0.stb;
         ELSIF wbo_slave.ack = '1' AND wbo_0.cti /= "010" THEN -- single
            wbi_slave.stb <= '0';
         ELSE
            wbi_slave.stb <= wbo_0.stb;
         END IF;
         ELSE
            wbi_slave.stb <= '0';
         END IF;
      END IF;

      wbi_slave_cyc <= cyc_0;

      ack_0 <= wbo_slave.ack;
      err_0 <= wbo_slave.err;

      wbi_slave.dat  <= wbo_0.dat;
      wbi_slave.adr  <= wbo_0.adr;
      wbi_slave.sel  <= wbo_0.sel;
      wbi_slave.we   <= wbo_0.we;
      wbi_slave.cti  <= wbo_0.cti;
      wbi_slave.bte  <= wbo_0.bte;
      wbi_slave.tga  <= wbo_0.tga;

   END switch_fab;

END;

