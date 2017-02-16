---------------------------------------------------------------
-- Title         : Package for FPGA family type
-- Project       : 
---------------------------------------------------------------
-- File          : fpga_pkg_2.vhd
-- Author        : Michael Miehling
-- Email         : miehling@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 24/10/06
---------------------------------------------------------------
-- Simulator     : 
-- Synthesis     : 
---------------------------------------------------------------
-- Description :
--! \desid
--! \archid
--! \desbody
---------------------------------------------------------------
--!\hierarchy
--!\endofhierarchy
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
-- $Revision: 1.8 $
--
-- $Log: fpga_pkg_2.vhd,v $
-- Revision 1.8  2014/11/19 10:10:34  FLenhardt
-- R: No support for device family "Cyclone V"
-- M: Added device family CYCLONE5 to family_type
--
-- Revision 1.7  2014/06/03 11:34:30  CSchwark
-- R: no support for device family SmartFusion2
-- M: added device family SF2 to family_type
--
-- Revision 1.6  2013/02/11 14:33:42  FLenhardt
-- * added CYCLONE4E
-- * added FUNCTION altera_device_family
--
-- Revision 1.5  2012/10/24 09:04:32  MMiehling
-- added ARRIA2_GX, ARRIA2_GZ
--
-- Revision 1.4  2010/12/22 14:22:27  TWickleder
-- added CYCLONE4
--
-- Revision 1.3  2010/05/05 10:27:55  TWickleder
-- added FUNCTION get_fsrev and conv_chr_to_int
--
-- Revision 1.2  2009/02/17 11:37:35  FWombacher
-- cosmetics due to rule checker
--
-- Revision 1.1  2008/11/21 15:16:54  FWombacher
-- Initial Revision
--
-- Revision 1.2  2008/10/24 16:39:53  FWombacher
-- added comments
--
-- Revision 1.1  2008/10/22 14:19:15  FWombacher
-- Initial Revision
--
-- Revision 1.2  2007/12/12 14:04:48  mernst
-- Added Cyclone III device to FPGA_PKG
--
-- Revision 1.1  2006/11/27 14:15:26  mmiehling
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

PACKAGE fpga_pkg_2 IS
   
   TYPE family_type IS (NONE, CYCLONE, CYCLONE2, CYCLONE3, CYCLONE4, CYCLONE4E, CYCLONE5, FLEX, ACEX, A3P, ARRIA_GX, ARRIA2_GX, ARRIA2_GZ, SF2);
   TYPE supported_family_types IS array (natural range <>) OF family_type; -- for more than one supported devices
   SUBTYPE supported_family_type IS family_type; -- for exactly one supported device

   FUNCTION altera_device_family(FPGA_FAMILY : IN family_type) RETURN string;

--   CONSTANT fpga_family : family_type := CYCLONE3;

   FUNCTION no_valid_device(  
      supported_devices : IN supported_family_types;
      device            : IN family_type ) 
   RETURN boolean;
   
   FUNCTION no_valid_device(  
      supported_device  : IN supported_family_type;
      device            : IN family_type ) 
   RETURN boolean;

   FUNCTION get_fsrev(fsrev_str : IN string) RETURN std_logic_vector;
   FUNCTION conv_chr_to_int(char : IN character) RETURN integer;
   
END fpga_pkg_2;

PACKAGE BODY fpga_pkg_2 IS 

   FUNCTION altera_device_family(FPGA_FAMILY : IN family_type) RETURN string IS
   BEGIN
      IF FPGA_FAMILY = CYCLONE THEN
         RETURN "Cyclone";
      ELSIF FPGA_FAMILY = CYCLONE2 THEN
         RETURN "Cyclone II";
      ELSIF FPGA_FAMILY = CYCLONE3 THEN
         RETURN "Cyclone III";
      ELSIF FPGA_FAMILY = CYCLONE4E THEN
         RETURN "Cyclone IV E";
      ELSIF FPGA_FAMILY = CYCLONE4 THEN
         RETURN "Cyclone IV GX";
      ELSIF FPGA_FAMILY = CYCLONE5 THEN
         RETURN "Cyclone V";
      ELSIF FPGA_FAMILY = ARRIA_GX THEN
         RETURN "Arria GX";
      ELSIF FPGA_FAMILY = ARRIA2_GX  THEN
         RETURN "Arria II GX";
      ELSIF FPGA_FAMILY = ARRIA2_GZ THEN
         RETURN "Arria II GZ";
      --ELSIF FPGA_FAMILY =  THEN
      --   RETURN "";
      ELSE
         ASSERT FALSE REPORT "UNSUPPORTED ALTERA DEVICE" SEVERITY FAILURE;
         RETURN "";
      END IF;
   END altera_device_family;

   FUNCTION no_valid_device(  
      supported_devices : IN supported_family_types;
      device            : IN family_type ) 
   RETURN boolean IS 
      VARIABLE no_valid : boolean := TRUE; 
   BEGIN 
      FOR i IN supported_devices'range LOOP 
         IF(device = supported_devices(i)) THEN 
            no_valid := FALSE; 
         ELSE 
            no_valid := no_valid; 
         END IF; 
      END LOOP; 
      RETURN no_valid; 
   END no_valid_device; 

   FUNCTION no_valid_device(  
      supported_device  : IN supported_family_type;
      device            : IN family_type ) 
   RETURN boolean IS 
      VARIABLE no_valid : boolean := TRUE; 
   BEGIN 
      IF(device = supported_device) THEN 
         no_valid := FALSE; 
      ELSE 
         no_valid := TRUE; 
      END IF; 
      RETURN no_valid; 
   END no_valid_device; 

   FUNCTION get_fsrev(fsrev_str : IN string) RETURN std_logic_vector IS 
      VARIABLE minor_no    : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0'); 
      VARIABLE major_no    : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0'); 
      VARIABLE scan_str    : string(7 DOWNTO 1)           := "       ";
      VARIABLE maj_str     : string(3 DOWNTO 1)           := "   ";
      VARIABLE min_str     : string(3 DOWNTO 1)           := "   ";
      VARIABLE fsrev_found : boolean                      := FALSE; 
      VARIABLE next_is_rev : boolean                      := FALSE; 
      VARIABLE major_found : boolean                      := FALSE; 
      VARIABLE minor_found : boolean                      := FALSE; 
   BEGIN 
      FOR i IN fsrev_str'range LOOP
			scan_str := scan_str(6 DOWNTO 1) & fsrev_str(i); --shift string in
			IF(scan_str = "%FSREV ") THEN	fsrev_found := TRUE;	
			ELSIF(fsrev_found AND NOT next_is_rev) THEN 
				IF(scan_str(1) = ' ') THEN	next_is_rev := TRUE; END IF; 
			ELSIF(next_is_rev AND NOT major_found) THEN 
				IF(scan_str(1) = '.') THEN major_found := TRUE; ELSE maj_str := maj_str(2 DOWNTO 1) & scan_str(1); END IF;
			ELSIF(major_found AND NOT minor_found) THEN 
				IF(scan_str(1) = ' ') THEN minor_found := TRUE; ELSE min_str := min_str(2 DOWNTO 1) & scan_str(1); END IF;
			ELSIF(minor_found) THEN exit; 
			END IF;
		END LOOP;
		minor_no := conv_std_logic_vector(100*conv_chr_to_int(min_str(3))+10*conv_chr_to_int(min_str(2))+conv_chr_to_int(min_str(1)),8);
		major_no := conv_std_logic_vector(100*conv_chr_to_int(maj_str(3))+10*conv_chr_to_int(maj_str(2))+conv_chr_to_int(maj_str(1)),8);
      RETURN (major_no&minor_no); 
   END get_fsrev; 

   FUNCTION conv_chr_to_int(char : IN character) RETURN integer IS
      VARIABLE num : integer := 0; 
   BEGIN 
   	CASE char IS 
   		WHEN '0'    => num := 0;
   		WHEN '1'    => num := 1;
   		WHEN '2'    => num := 2;
   		WHEN '3'    => num := 3;
   		WHEN '4'    => num := 4;
   		WHEN '5'    => num := 5;
   		WHEN '6'    => num := 6;
   		WHEN '7'    => num := 7;
   		WHEN '8'    => num := 8;
   		WHEN '9'    => num := 9;
   		WHEN OTHERS => num := 0;
   	END CASE;
   	RETURN num;
   END conv_chr_to_int; 

END;
