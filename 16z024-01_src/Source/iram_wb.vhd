---------------------------------------------------------------
-- Title         : Internal RAM with Wishbone I/F
-- Project       : 16z024-01
---------------------------------------------------------------
-- File          : iram_wb.vhd
-- Author        : Ferdinand Lenhardt
-- Email         : Ferdinand.Lenhardt@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 25/05/05
---------------------------------------------------------------
-- Simulator     : ModelSim-Altera 5.8e
-- Synthesis     : Quartus II 4.2 SP1
---------------------------------------------------------------
-- Description :
--
-- This module includes an arbitrary number of FPGA block RAMs.
-- A HEX (Intel-Format) file can be used to initialize the RAM.
-- For ACEX this module can be used only as a ROM.
---------------------------------------------------------------
-- Hierarchy:
--
-- iram_wb
--    lpm_ram_dq
--    altsyncram
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
-- $Log: iram_wb.vhd,v $
-- Revision 1.8  2017/05/10 Greg Daniluk <grzegorz.daniluk@cern.ch>
-- Generalized to instantiate altsyncram (for Cyclone, Cyclone2, Cyclone3,
-- Cyclone4, Cyclone 5, Arria GX) and lpm_ram_dq (for Acex).
--
-- Revision 1.7  2014/11/20 14:45:22  AGeissler
-- R1: Missing Cyclone V support
-- M1: Added Cyclone V support
--
-- Revision 1.6  2010/12/17 17:04:48  FWombacher
-- Added Cyclone IV RAM instance
--
-- Revision 1.5  2009/01/27 14:30:13  FLenhardt
-- Added support for fpga_pkg_2 (ACEX,ARRIA_GX,CYCLONE2,CYCLONE3)
--
-- Revision 1.4  2007/11/21 13:46:01  FLenhardt
-- Added a commentary to generic USEDW_WIDTH
-- Added ERR output to Wishbone interface
--
-- Revision 1.3  2006/02/27 16:49:39  TWickleder
-- Added read_only as generic to disable the we signal
--
-- Revision 1.2  2005/11/28 15:05:45  mmiehling
-- bug fix: (stb_i AND cyc_i) = '1' => (stb_i = '1' AND cyc_i = '1')
--
-- Revision 1.1  2005/05/30 09:43:02  flenhardt
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY work;
USE work.fpga_pkg_2.ALL;

library lpm;
use lpm.all;
library altera_mf;
use altera_mf.altera_mf_components.all;

ENTITY iram_wb IS
GENERIC
(
   FPGA_FAMILY: family_type := CYCLONE; -- ACEX,CYCLONE,CYCLONE2,CYCLONE3,CYCLONE4,CYCLONE5,ARRIA_GX
   read_only: natural := 0; -- 0=R/W, 1=R/O
   USEDW_WIDTH: positive := 6; -- 2**(USEDW_WIDTH + 2) bytes
   LOCATION: string := "iram.hex" -- string shall be empty if no HEX file
);

PORT
(
   clk   : IN std_logic; -- Wishbone clock
   rst   : IN std_logic; -- global async high active reset

   -- Wishbone signals
   stb_i : IN std_logic;                       -- request
   cyc_i : IN std_logic;                       -- chip select
   ack_o : OUT std_logic;                      -- acknowledge
   err_o : OUT std_logic;                      -- error
   we_i  : IN std_logic;                       -- write=1 read=0
   sel_i : IN std_logic_vector(3 DOWNTO 0);    -- byte enables
   adr_i : IN std_logic_vector((USEDW_WIDTH + 1) DOWNTO 2);
   dat_i : IN std_logic_vector(31 DOWNTO 0);   -- data in
   dat_o : OUT std_logic_vector(31 DOWNTO 0)   -- data out
);
END iram_wb;

ARCHITECTURE iram_wb_arch OF iram_wb IS

CONSTANT SUPPORTED_DEVICES : supported_family_types := (ACEX,CYCLONE,CYCLONE2,CYCLONE3,CYCLONE4,CYCLONE5,ARRIA_GX);

	COMPONENT lpm_ram_dq
	GENERIC (
		lpm_address_control		: STRING;
		lpm_file		: STRING;
		lpm_indata		: STRING;
		lpm_outdata		: STRING;
		lpm_type		: STRING;
		lpm_width		: NATURAL;
		lpm_widthad		: NATURAL);
	PORT (
			address	: IN STD_LOGIC_VECTOR ((USEDW_WIDTH - 1) DOWNTO 0);
			inclock	: IN STD_LOGIC ;
			q	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			data	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			we	: IN STD_LOGIC);
	END COMPONENT;

SIGNAL ack_o_int: std_logic;
SIGNAL we_int: std_logic;
SIGNAL sel_int: std_logic_vector(3 DOWNTO 0);
SIGNAL dat_int: std_logic_vector(31 DOWNTO 0);

BEGIN

gen_we: IF read_only = 0 GENERATE
   we_control: PROCESS(rst, clk)
   BEGIN
      IF(rst = '1') THEN
         we_int <= '0';
      ELSIF(clk'EVENT AND clk = '1') THEN
         IF((stb_i = '1' AND cyc_i = '1') AND ack_o_int = '0') THEN
            we_int <= we_i;
         ELSE
            we_int <= '0';
         END IF;
      END IF;
   END PROCESS we_control;

   sel_int <= sel_i;
   dat_int <= dat_i;
END GENERATE;

dis_we: IF read_only = 1 GENERATE
	we_int <= '0';
	dat_int <= (OTHERS => '0');
END GENERATE;

dis_sel: IF(read_only = 1 AND FPGA_FAMILY /= ACEX) GENERATE
	sel_int <= (OTHERS => '0');
END GENERATE dis_sel;

gen_acex: IF(FPGA_FAMILY = ACEX) GENERATE
gen_acex_rom: IF(read_only = 1) GENERATE

	lpm_ram_dq_component : lpm_ram_dq
	GENERIC MAP (
		lpm_address_control => "REGISTERED",
		lpm_file => LOCATION,
		lpm_indata => "REGISTERED",
		lpm_outdata => "UNREGISTERED",
		lpm_type => "LPM_RAM_DQ",
		lpm_width => 32,
		lpm_widthad => USEDW_WIDTH)
	PORT MAP (
		address => adr_i,
		inclock => clk,
		data    => dat_int,
		we      => we_int,
		q       => dat_o);

END GENERATE gen_acex_rom;

ASSERT(read_only = 1) REPORT "IRAM: Read only for ACEX!" SEVERITY failure;
END GENERATE gen_acex;

gen_cyc: IF(FPGA_FAMILY = CYCLONE) GENERATE

	altsyncram_component : altsyncram
	GENERIC MAP (
		intended_device_family => "Cyclone",
		width_a => 32,
		widthad_a => USEDW_WIDTH,
		numwords_a => 2**USEDW_WIDTH,
		operation_mode => "SINGLE_PORT",
		outdata_reg_a => "UNREGISTERED",
		indata_aclr_a => "NONE",
		wrcontrol_aclr_a => "NONE",
		address_aclr_a => "NONE",
		outdata_aclr_a => "NONE",
		width_byteena_a => 4,
		byte_size => 8,
		byteena_aclr_a => "NONE",
		init_file => LOCATION,
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram")
	PORT MAP (
		wren_a    => we_int,
		clock0    => clk,
		byteena_a => sel_int,
		address_a => adr_i,
		data_a    => dat_int,
		q_a       => dat_o);

END GENERATE gen_cyc;

gen_cyclones: if(FPGA_FAMILY=CYCLONE2 or FPGA_FAMILY=CYCLONE3 or
FPGA_FAMILY=CYCLONE4 or FPGA_FAMILY=CYCLONE5 or FPGA_FAMILY=ARRIA_GX) generate

	altsyncram_component : altsyncram
	GENERIC MAP (
		byte_size => 8,
		clock_enable_input_a  => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => LOCATION,
		intended_device_family => altera_device_family(FPGA_FAMILY),
		lpm_hint   => "ENABLE_RUNTIME_MOD=NO",
		lpm_type   => "altsyncram",
		numwords_a => 2**USEDW_WIDTH,
		operation_mode => "SINGLE_PORT",
		outdata_aclr_a => "NONE",
		outdata_reg_a  => "UNREGISTERED",
		power_up_uninitialized        => "FALSE",
		read_during_write_mode_port_a => "OLD_DATA",
		widthad_a => USEDW_WIDTH,
		width_a   => 32,
		width_byteena_a => 4
	)
	PORT MAP (
		wren_a    => we_int,
		clock0    => clk,
		byteena_a => sel_int,
		address_a => adr_i,
		data_a    => dat_int,
		q_a       => dat_o);

end generate;

ASSERT NOT NO_VALID_DEVICE(supported_devices => SUPPORTED_DEVICES, device => FPGA_FAMILY) REPORT "IRAM: No valid DEVICE!" SEVERITY failure; 

control_logic: PROCESS(rst, clk)
BEGIN
   IF(rst = '1') THEN
      ack_o_int <= '0';
   ELSIF(clk'EVENT AND clk = '1') THEN
      IF((stb_i = '1' AND cyc_i = '1') AND ack_o_int = '0') THEN
         ack_o_int <= '1';
      ELSE
         ack_o_int <= '0';
      END IF;
   END IF;
END PROCESS control_logic;

ack_o <= ack_o_int;
err_o <= '0';

END iram_wb_arch;
