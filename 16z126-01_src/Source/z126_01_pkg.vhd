---------------------------------------------------------------
-- Title         : Package for flash types
-- Project       : 
---------------------------------------------------------------
-- File          : z126_01_pkg.vhd
-- Author        : Andreas Geissler
-- Email         : Andreas.Geissler@men.de
-- Organization  : MEN Mikro Elektronik Nuremberg GmbH
-- Created       : 03/02/14
---------------------------------------------------------------
-- Simulator     : ModelSim-Altera PE 6.4c
-- Synthesis     : Quartus II 12.1 SP2
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
-- $Revision: 1.2 $
--
-- $Log: z126_01_pkg.vhd,v $
-- Revision 1.2  2014/11/24 16:44:14  AGeissler
-- R1: Magic numbers
-- M1: Added constants for used coded signals
--
-- Revision 1.1  2014/03/03 17:49:48  AGeissler
-- Initial Revision
--
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.fpga_pkg_2.ALL;

PACKAGE z126_01_pkg IS
   
   TYPE flash_type IS (NONE, M25P32, M25P64, M25P128);
   TYPE supported_flash_types IS array (natural range <>) OF flash_type; -- for mor than one supported devices
   SUBTYPE supported_flash_type IS flash_type; -- for exactly one supported device
   
   --------------------------------------------------------------------
   -- Remote update parameters
   --------------------------------------------------------------------
   -- CYCLONE V
   CONSTANT Z126_01_RU_RECONF_CON_PAR_CYC5   : std_logic_vector(2 DOWNTO 0) := "000";
   CONSTANT Z126_01_RU_WDOG_VAL_PAR_CYC5     : std_logic_vector(2 DOWNTO 0) := "010";
   CONSTANT Z126_01_RU_WDOG_EN_PAR_CYC5      : std_logic_vector(2 DOWNTO 0) := "011";
   CONSTANT Z126_01_RU_PAGE_SEL_PAR_CYC5     : std_logic_vector(2 DOWNTO 0) := "100";
   CONSTANT Z126_01_RU_CONF_MODE_PAR_CYC5    : std_logic_vector(2 DOWNTO 0) := "101";
   
   -- CYCLONE IV and CYCLONE III
   CONSTANT Z126_01_RU_STATE_MODE_PAR_CYC4   : std_logic_vector(2 DOWNTO 0) := "000";
   CONSTANT Z126_01_RU_CONF_DONE_PAR_CYC4    : std_logic_vector(2 DOWNTO 0) := "001";
   CONSTANT Z126_01_RU_WDOG_VAL_PAR_CYC4     : std_logic_vector(2 DOWNTO 0) := "010";
   CONSTANT Z126_01_RU_WDOG_EN_PAR_CYC4      : std_logic_vector(2 DOWNTO 0) := "011";
   CONSTANT Z126_01_RU_BOOT_ADR_PAR_CYC4     : std_logic_vector(2 DOWNTO 0) := "100";
   CONSTANT Z126_01_RU_INT_OSCI_PAR_CYC4     : std_logic_vector(2 DOWNTO 0) := "110";
   CONSTANT Z126_01_RU_RECONF_CON_PAR_CYC4   : std_logic_vector(2 DOWNTO 0) := "111";
   
   --------------------------------------------------------------------
   -- Remote update read source (only for cyclone III and cyclone IV   
   --------------------------------------------------------------------
   CONSTANT Z126_01_RU_RD_SRC_CURRENT     : std_logic_vector(1 DOWNTO 0) := "00";
   CONSTANT Z126_01_RU_RD_SRC_PREVIOUS_1  : std_logic_vector(1 DOWNTO 0) := "01";
   CONSTANT Z126_01_RU_RD_SRC_PREVIOUS_2  : std_logic_vector(1 DOWNTO 0) := "10";
   CONSTANT Z126_01_RU_RD_SRC_INPUT_REG   : std_logic_vector(1 DOWNTO 0) := "11";
   
   
   TYPE pasmi_out_type IS record
      addr              : std_logic_vector(23 DOWNTO 0);
      bulk_erase        : std_logic;
      data              : std_logic_vector(7 DOWNTO 0);
      fast_read         : std_logic;
      rden              : std_logic;
      read_sid          : std_logic;
      read_rdid         : std_logic;
      read_status       : std_logic;
      sector_erase      : std_logic;
      sector_protect    : std_logic;
      shift_bytes       : std_logic;
      wren              : std_logic;
      write             : std_logic;
      read              : std_logic;
   END record;
   
   TYPE pasmi_in_type IS record
      illegal_erase     : std_logic;
      illegal_write     : std_logic;
      epcs_id           : std_logic_vector(7 DOWNTO 0);
      rdid              : std_logic_vector(7 DOWNTO 0);
      status            : std_logic_vector(7 DOWNTO 0);
      busy              : std_logic;
      data_valid        : std_logic;
      data              : std_logic_vector(7 DOWNTO 0);
   END record;
   
   TYPE ctrl_wb2pasmi_out_type IS record
      read_sid         : std_logic;
      sector_protect   : std_logic;
      write            : std_logic;
      read_status      : std_logic;
      sector_erase     : std_logic;
      bulk_erase       : std_logic;
   END record;
   
   TYPE ctrl_wb2pasmi_in_type IS record
      illegal_write    : std_logic;
      illegal_erase    : std_logic;
      busy             : std_logic;
   END record;
   
   FUNCTION no_valid_device(  
      supported_devices : IN supported_flash_types;
      device            : IN flash_type ) 
   RETURN boolean;
   
   FUNCTION no_valid_device(  
      supported_device  : IN supported_flash_type;
      device            : IN flash_type ) 
   RETURN boolean;
   
END z126_01_pkg;

PACKAGE BODY z126_01_pkg IS 
   
   FUNCTION no_valid_device(  
      supported_devices : IN supported_flash_types;
      device            : IN flash_type ) 
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
      supported_device  : IN supported_flash_type;
      device            : IN flash_type ) 
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
   
END;
