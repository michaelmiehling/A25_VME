---------------------------------------------------------------
-- Title         : system unit package
-- Project       : Embedded System Module
---------------------------------------------------------------
-- File          : wb_pkg.vhd
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
-- $Revision: 1.15 $
--
-- $Log: wb_pkg.vhd,v $
-- Revision 1.15  2015/06/15 16:40:01  AGeissler
-- R1: Clearness
-- M1: Replaced tabs with spaces
--
-- Revision 1.14  2014/03/11 13:51:10  AVieira
-- R: data_mux for 16 and 1-bit are not necessary; WB bte signal unused
-- M: data_mux for 16 and 1-bit removed; WB bte signal removed from wbi_type/wbo_type
--
-- Revision 1.13  2014/03/10 16:29:54  avieira
-- R: data muxes for unconstrained array data input not supported
-- M: added new data_mux implementations and unconstrained array times for 64/32/16 bits data
--
-- Revision 1.12  2014/02/28 10:27:01  avieira
-- R: 64-bit support missing
-- M: Added 64-bit types
--
-- Revision 1.11  2009/07/29 14:05:13  FLenhardt
-- Fixed bug in SWITCH_FAB (WB slave strobe had been activated without addressing)
--
-- Revision 1.10  2007/08/24 11:15:23  FLenhardt
-- Re-added procedure SWITCH_FAB for backward compatibility
--
-- Revision 1.9  2007/08/13 16:28:35  MMiehling
-- moved switch_fab to entity switch_fab_1
--
-- Revision 1.8  2007/08/13 13:58:58  FWombacher
-- fixed typos
--
-- Revision 1.7  2007/08/13 10:14:26  MMiehling
-- added: master gets no ack if corresponding stb is not active
--
-- Revision 1.6  2006/05/18 16:14:32  twickleder
-- added data_mux for 23 slaves
--
-- Revision 1.5  2006/05/09 11:57:29  twickleder
-- added data_mux for 21 and 22 slaves
--
-- Revision 1.4  2006/02/24 16:09:39  TWickleder
-- Added DATA_MUX procedure with 20 data inputs
--
-- Revision 1.3  2006/02/17 13:54:20  flenhardt
-- Added DATA_MUX procedure with 19 data inputs
--
-- Revision 1.2  2005/12/13 13:48:56  flenhardt
-- Added DATA_MUX procedure with 18 data inputs
--
-- Revision 1.1  2004/08/13 15:16:09  mmiehling
-- Initial Revision
--
-- Revision 1.1  2004/08/13 15:10:52  mmiehling
-- Initial Revision
--
-- Revision 1.6  2004/07/27 17:06:24  mmiehling
-- multifunction added
--
-- Revision 1.4  2004/05/13 14:21:25  MMiehling
-- multifunction device
--
-- Revision 1.3  2004/04/29 15:07:22  MMiehling
-- removed switch_fab from pkg, now new entity
--
-- Revision 1.2  2004/04/27 09:37:42  MMiehling
-- now correct signal names and wb-types
--
-- Revision 1.3  2004/04/14 16:54:50  MMiehling
-- now correct switch_fab io's
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE wb_pkg IS

   TYPE wbo_type IS record
      stb   : std_logic;
      sel   : std_logic_vector(3 DOWNTO 0);
      adr   : std_logic_vector(31 DOWNTO 0);
      we : std_logic;
      dat   : std_logic_vector(31 DOWNTO 0);
      tga   : std_logic_vector(5 DOWNTO 0);
      cti   : std_logic_vector(2 DOWNTO 0);
   END record;
   
   TYPE wbi_type IS record
      ack   : std_logic;
      err   : std_logic;
      dat   : std_logic_vector(31 DOWNTO 0);
   END record;
   
   TYPE wbo_type_64 IS record
      stb   : std_logic;
      sel   : std_logic_vector(7 DOWNTO 0);
      adr   : std_logic_vector(31 DOWNTO 0);
      we    : std_logic;
      dat   : std_logic_vector(63 DOWNTO 0);
      tga   : std_logic_vector(5 DOWNTO 0);
      cti   : std_logic_vector(2 DOWNTO 0);
   END record;

   TYPE wbi_type_64 IS record
      ack   : std_logic;
      err   : std_logic;
      dat   : std_logic_vector(63 DOWNTO 0);
   END record;
   
   
   TYPE slv64_arr    IS array (natural range <>) OF std_logic_vector(63 DOWNTO  0);
   TYPE slv32_arr    IS array (natural range <>) OF std_logic_vector(31 DOWNTO  0);

   PROCEDURE data_mux ( SIGNAL cyc            : IN std_logic_vector;
                        SIGNAL data_in : IN slv64_arr;
                        SIGNAL data_out   : OUT std_logic_vector(63 DOWNTO 0)
                     );
   PROCEDURE data_mux ( SIGNAL cyc            : IN std_logic_vector;
                        SIGNAL data_in : IN slv32_arr;
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     );
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(1 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(2 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(3 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(4 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(5 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(6 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(7 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(8 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(9 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(10 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(11 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(12 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(13 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(14 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(15 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_in_15 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(16 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_in_15 : IN std_logic_vector;
                        SIGNAL data_in_16 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(17 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_in_15 : IN std_logic_vector;
                        SIGNAL data_in_16 : IN std_logic_vector;
                        SIGNAL data_in_17 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(18 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_in_15 : IN std_logic_vector;
                        SIGNAL data_in_16 : IN std_logic_vector;
                        SIGNAL data_in_17 : IN std_logic_vector;
                        SIGNAL data_in_18 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );
                     
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(19 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_in_15 : IN std_logic_vector;
                        SIGNAL data_in_16 : IN std_logic_vector;
                        SIGNAL data_in_17 : IN std_logic_vector;
                        SIGNAL data_in_18 : IN std_logic_vector;
                        SIGNAL data_in_19 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(20 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_in_15 : IN std_logic_vector;
                        SIGNAL data_in_16 : IN std_logic_vector;
                        SIGNAL data_in_17 : IN std_logic_vector;
                        SIGNAL data_in_18 : IN std_logic_vector;
                        SIGNAL data_in_19 : IN std_logic_vector;
                        SIGNAL data_in_20 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(21 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_in_15 : IN std_logic_vector;
                        SIGNAL data_in_16 : IN std_logic_vector;
                        SIGNAL data_in_17 : IN std_logic_vector;
                        SIGNAL data_in_18 : IN std_logic_vector;
                        SIGNAL data_in_19 : IN std_logic_vector;
                        SIGNAL data_in_20 : IN std_logic_vector;
                        SIGNAL data_in_21 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     );

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(22 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_in_15 : IN std_logic_vector;
                        SIGNAL data_in_16 : IN std_logic_vector;
                        SIGNAL data_in_17 : IN std_logic_vector;
                        SIGNAL data_in_18 : IN std_logic_vector;
                        SIGNAL data_in_19 : IN std_logic_vector;
                        SIGNAL data_in_20 : IN std_logic_vector;
                        SIGNAL data_in_21 : IN std_logic_vector;
                        SIGNAL data_in_22 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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

END wb_pkg;

PACKAGE BODY wb_pkg IS


   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector;
                        SIGNAL data_in : IN slv64_arr;
                        SIGNAL data_out   : OUT std_logic_vector(63 DOWNTO 0)
                     ) IS
   BEGIN
      FOR i IN 0 TO cyc'HIGH LOOP
         IF cyc(i) = '1' THEN
           data_out <= data_in(i);
         END IF;
      END LOOP;
   END data_mux;
   
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector;
                        SIGNAL data_in : IN slv32_arr;
                        SIGNAL data_out   : OUT std_logic_vector(31 DOWNTO 0)
                     ) IS
   BEGIN
      FOR i IN 0 TO cyc'HIGH LOOP
         IF cyc(i) = '1' THEN
           data_out <= data_in(i);
         END IF;
      END LOOP;
   END data_mux;
   
   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(1 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
                     ) IS
   BEGIN
         CASE cyc IS
            WHEN "01" =>   data_out <= data_in_0;
            WHEN "10" =>   data_out <= data_in_1;
            WHEN OTHERS => data_out <= data_in_0;
         END CASE;
   END data_mux;

   PROCEDURE data_mux ( SIGNAL cyc        : IN std_logic_vector(2 DOWNTO 0);
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_in_15 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_in_15 : IN std_logic_vector;
                        SIGNAL data_in_16 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_in_15 : IN std_logic_vector;
                        SIGNAL data_in_16 : IN std_logic_vector;
                        SIGNAL data_in_17 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_in_15 : IN std_logic_vector;
                        SIGNAL data_in_16 : IN std_logic_vector;
                        SIGNAL data_in_17 : IN std_logic_vector;
                        SIGNAL data_in_18 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_in_15 : IN std_logic_vector;
                        SIGNAL data_in_16 : IN std_logic_vector;
                        SIGNAL data_in_17 : IN std_logic_vector;
                        SIGNAL data_in_18 : IN std_logic_vector;
                        SIGNAL data_in_19 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_in_15 : IN std_logic_vector;
                        SIGNAL data_in_16 : IN std_logic_vector;
                        SIGNAL data_in_17 : IN std_logic_vector;
                        SIGNAL data_in_18 : IN std_logic_vector;
                        SIGNAL data_in_19 : IN std_logic_vector;
                        SIGNAL data_in_20 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_in_15 : IN std_logic_vector;
                        SIGNAL data_in_16 : IN std_logic_vector;
                        SIGNAL data_in_17 : IN std_logic_vector;
                        SIGNAL data_in_18 : IN std_logic_vector;
                        SIGNAL data_in_19 : IN std_logic_vector;
                        SIGNAL data_in_20 : IN std_logic_vector;
                        SIGNAL data_in_21 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
                        SIGNAL data_in_0  : IN std_logic_vector;
                        SIGNAL data_in_1  : IN std_logic_vector;
                        SIGNAL data_in_2  : IN std_logic_vector;
                        SIGNAL data_in_3  : IN std_logic_vector;
                        SIGNAL data_in_4  : IN std_logic_vector;
                        SIGNAL data_in_5  : IN std_logic_vector;
                        SIGNAL data_in_6  : IN std_logic_vector;
                        SIGNAL data_in_7  : IN std_logic_vector;
                        SIGNAL data_in_8  : IN std_logic_vector;
                        SIGNAL data_in_9  : IN std_logic_vector;
                        SIGNAL data_in_10 : IN std_logic_vector;
                        SIGNAL data_in_11 : IN std_logic_vector;
                        SIGNAL data_in_12 : IN std_logic_vector;
                        SIGNAL data_in_13 : IN std_logic_vector;
                        SIGNAL data_in_14 : IN std_logic_vector;
                        SIGNAL data_in_15 : IN std_logic_vector;
                        SIGNAL data_in_16 : IN std_logic_vector;
                        SIGNAL data_in_17 : IN std_logic_vector;
                        SIGNAL data_in_18 : IN std_logic_vector;
                        SIGNAL data_in_19 : IN std_logic_vector;
                        SIGNAL data_in_20 : IN std_logic_vector;
                        SIGNAL data_in_21 : IN std_logic_vector;
                        SIGNAL data_in_22 : IN std_logic_vector;
                        SIGNAL data_out   : OUT std_logic_vector
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
      wbi_slave.tga  <= wbo_0.tga;

   END switch_fab;

END;

