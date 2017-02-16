--------------------------------------------------------------------------------
-- Title         : Definitions and Constants for WBB2VME
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : vme_pkg.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 02/02/12
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
--
-- 
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
-- $Revision: 1.3 $
--
-- $Log: vme_pkg.vhd,v $
-- Revision 1.3  2014/02/07 17:00:14  MMiehling
-- bugfix: IACK addressing
--
-- Revision 1.2  2012/08/27 12:57:11  MMiehling
-- changed polarity of swapped bit in constants
--
-- Revision 1.1  2012/03/29 10:14:34  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE vme_pkg IS
   CONSTANT CONST_VME_REGS       : std_logic_vector(6 DOWNTO 0):="1000000";
   CONSTANT CONST_VME_IACK       : std_logic_vector(6 DOWNTO 0):="0100011";
   CONSTANT CONST_VME_A16D16     : std_logic_vector(6 DOWNTO 0):="0100010";
   CONSTANT CONST_VME_A16D32     : std_logic_vector(6 DOWNTO 0):="0100110";
   CONSTANT CONST_VME_A24D16     : std_logic_vector(6 DOWNTO 0):="0100000";
   CONSTANT CONST_VME_A24D32     : std_logic_vector(6 DOWNTO 0):="0100100";
   CONSTANT CONST_VME_A32D32     : std_logic_vector(6 DOWNTO 0):="0100101";
   CONSTANT CONST_VME_A16D16S    : std_logic_vector(6 DOWNTO 0):="0000010";
   CONSTANT CONST_VME_A16D32S    : std_logic_vector(6 DOWNTO 0):="0000110";
   CONSTANT CONST_VME_A24D16S    : std_logic_vector(6 DOWNTO 0):="0000000";
   CONSTANT CONST_VME_A24D32S    : std_logic_vector(6 DOWNTO 0):="0000100";
   CONSTANT CONST_VME_A32D32S    : std_logic_vector(6 DOWNTO 0):="0000101";
   CONSTANT CONST_VME_A24D16B    : std_logic_vector(6 DOWNTO 0):="0110000";
   CONSTANT CONST_VME_A24D32B    : std_logic_vector(6 DOWNTO 0):="0110100";
   CONSTANT CONST_VME_A32D32B    : std_logic_vector(6 DOWNTO 0):="0110101";
   CONSTANT CONST_VME_A32D64B    : std_logic_vector(6 DOWNTO 0):="0111001";
   CONSTANT CONST_VME_A24D16BS   : std_logic_vector(6 DOWNTO 0):="0010000";
   CONSTANT CONST_VME_A24D32BS   : std_logic_vector(6 DOWNTO 0):="0010100";
   CONSTANT CONST_VME_A32D32BS   : std_logic_vector(6 DOWNTO 0):="0010101";
   CONSTANT CONST_VME_A32D64BS   : std_logic_vector(6 DOWNTO 0):="0011001";

   TYPE io_ctrl_type   IS record 
      d_dir             : std_logic;   -- external driver control data direction (1: drive to vmebus 0: drive to fpga)
      d_oe_n            : std_logic;   -- external driver control data output enable low active
      am_dir            : std_logic;   -- external driver control address modifier direction (1: drive to vmebus 0: drive to fpga)
      am_oe_n           : std_logic;   -- external driver control address modifier output enable low activ 
      a_dir             : std_logic;   -- external driver control address direction (1: drive to vmebus 0: drive to fpga)
      a_oe_n            : std_logic;   -- external driver control address output enable low activ
   END record;      

   TYPE test_vec_type IS record
      ato   : std_logic;   -- arbitration time out
   END record;

END vme_pkg;

PACKAGE BODY vme_pkg IS 


END;
