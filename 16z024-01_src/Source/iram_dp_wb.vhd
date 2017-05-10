---------------------------------------------------------------
-- Title         : Dual Ported IRAM with Wishbone Interface
-- Project       : -
---------------------------------------------------------------
-- File          : iram_dp_wb.vhd
-- Author        : Michael Miehling
-- Email         : miehling@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 28/11/05
---------------------------------------------------------------
-- Simulator     : Modelsim PE 5.7g
-- Synthesis     : Quartus II 3.0
---------------------------------------------------------------
-- Description :
--
-- 
---------------------------------------------------------------
-- Hierarchy:
--
-- 
---------------------------------------------------------------
-- Copyright (C) 2001, MEN Mikroelektronik Nuernberg GmbH
--
--   All rights reserved. Reproduction in whole or part is 
--      prohibited without the written permission of the 
--                    copyright owner.           
---------------------------------------------------------------
--                         History                                    
---------------------------------------------------------------
-- $Revision: 1.3 $
--
-- $Log: iram_dp_wb.vhd,v $
-- Revision 1.3  2007/11/21 13:46:06  FLenhardt
-- Added ERR output to Wishbone interfaces
--
-- Revision 1.2  2006/01/04 15:57:18  mmiehling
-- added generic usedw_width
--
-- Revision 1.1  2005/12/15 15:38:42  mmiehling
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

library altera_mf;
use altera_mf.altera_mf_components.all;

ENTITY iram_dp_wb IS
GENERIC
(
   USEDW_WIDTH	: positive := 6;								-- width of address vector (6 = one M4K)
   SAME_CLK		: boolean:= TRUE								-- true: sl0_clk = sl1_clk; false: sl0_clk /= sl1_clk
);
PORT
(
   rst   		: IN std_logic; 								-- global async high active reset

   -- Wishbone Bus #0
   sl0_clk   	: IN std_logic; 								-- Wishbone Bus #0 Clock
   sl0_stb 		: IN std_logic;                       	-- request
   sl0_cyc 		: IN std_logic;                       	-- chip select
   sl0_ack 		: OUT std_logic;                      	-- acknowledge
   sl0_err 		: OUT std_logic;                      	-- error
   sl0_we  		: IN std_logic;                       	-- write=1 read=0
   sl0_sel 		: IN std_logic_vector(3 DOWNTO 0);    	-- byte enables
   sl0_adr 		: IN std_logic_vector(31 DOWNTO 0);
   sl0_dat_i 	: IN std_logic_vector(31 DOWNTO 0);   	-- data in
   sl0_dat_o 	: OUT std_logic_vector(31 DOWNTO 0);  	-- data out

   -- Wishbone Bus #0
   sl1_clk   	: IN std_logic; 								-- Wishbone Bus #0 Clock
   sl1_stb 		: IN std_logic;                       	-- request
   sl1_cyc 		: IN std_logic;                       	-- chip select
   sl1_ack 		: OUT std_logic;                      	-- acknowledge
   sl1_err 		: OUT std_logic;                      	-- error
   sl1_we  		: IN std_logic;                       	-- write=1 read=0
   sl1_sel 		: IN std_logic_vector(3 DOWNTO 0);    	-- byte enables
   sl1_adr 		: IN std_logic_vector(31 DOWNTO 0);
   sl1_dat_i 	: IN std_logic_vector(31 DOWNTO 0);   	-- data in
   sl1_dat_o 	: OUT std_logic_vector(31 DOWNTO 0)   	-- data out
);
END iram_dp_wb;

ARCHITECTURE iram_dp_wb_arch OF iram_dp_wb IS 

	SIGNAL sl0_loc_be			: std_logic_vector(3 DOWNTO 0);
	SIGNAL sl0_ack_o_int		: std_logic;
	SIGNAL sl0_clk_int		: std_logic;
	SIGNAL sl0_write			: std_logic;
	
	SIGNAL sl1_loc_be			: std_logic_vector(3 DOWNTO 0);
	SIGNAL sl1_ack_o_int		: std_logic;
	SIGNAL sl1_clk_int		: std_logic;
	SIGNAL sl1_write			: std_logic;

BEGIN
-------------------------------------------------------------------------------------------
-- WB #0 Interface

	sl0_ack <= sl0_ack_o_int;
	sl0_err <= '0';
	sl0_write <= '1' WHEN sl0_ack_o_int = '1' AND sl0_we = '1' ELSE '0';

sl0: PROCESS(rst, sl0_clk_int)
BEGIN
   IF(rst = '1') THEN
      sl0_loc_be <= (OTHERS => '0');
      sl0_ack_o_int <= '0';
   ELSIF(sl0_clk_int'EVENT AND sl0_clk_int = '1') THEN
      IF((sl0_stb = '1' AND sl0_cyc = '1') AND sl0_ack_o_int = '0') THEN
         IF(sl0_we = '1') THEN
            sl0_loc_be <= sl0_sel;
         ELSE
            sl0_loc_be <= (OTHERS => '0');
         END IF;

         sl0_ack_o_int <= '1';
      ELSE
         sl0_loc_be <= (OTHERS => '0');
         sl0_ack_o_int <= '0';
      END IF;
   END IF;
END PROCESS sl0;

-------------------------------------------------------------------------------------------
-- WB #1 Interface

	sl1_ack <= sl1_ack_o_int;
	sl1_err <= '0';
	sl1_write <= '1' WHEN sl1_ack_o_int = '1' AND sl1_we = '1' ELSE '0';

sl1: PROCESS(rst, sl1_clk_int)
BEGIN
   IF(rst = '1') THEN
      sl1_loc_be <= (OTHERS => '0');
      sl1_ack_o_int <= '0';
   ELSIF(sl1_clk_int'EVENT AND sl1_clk_int = '1') THEN
      IF((sl1_stb = '1' AND sl1_cyc = '1') AND sl1_ack_o_int = '0') THEN
         IF(sl1_we = '1') THEN
            sl1_loc_be <= sl1_sel;
         ELSE
            sl1_loc_be <= (OTHERS => '0');
         END IF;

         sl1_ack_o_int <= '1';
      ELSE
         sl1_loc_be <= (OTHERS => '0');
         sl1_ack_o_int <= '0';
      END IF;
   END IF;
END PROCESS sl1;

-------------------------------------------------------------------------------------------
gen_2clk: IF NOT SAME_CLK GENERATE
	sl0_clk_int <= sl0_clk;
	sl1_clk_int <= sl1_clk;

	altsyncram_component : altsyncram
	GENERIC MAP (
		intended_device_family => "Cyclone",
		operation_mode => "BIDIR_DUAL_PORT",
		width_a => 32,
		widthad_a => USEDW_WIDTH,
		numwords_a => 2**USEDW_WIDTH,
		width_b => 32,
		widthad_b => USEDW_WIDTH,
		numwords_b => 2**USEDW_WIDTH,
		lpm_type => "altsyncram",
		width_byteena_a => 4,
		width_byteena_b => 4,
		byte_size => 8,
		outdata_reg_a => "UNREGISTERED",
		outdata_aclr_a => "NONE",
		outdata_reg_b => "UNREGISTERED",
		indata_aclr_a => "NONE",
		wrcontrol_aclr_a => "NONE",
		address_aclr_a => "NONE",
		byteena_aclr_a => "NONE",
		indata_reg_b => "CLOCK1",
		address_reg_b => "CLOCK1",
		wrcontrol_wraddress_reg_b => "CLOCK1",
		indata_aclr_b => "NONE",
		wrcontrol_aclr_b => "NONE",
		address_aclr_b => "NONE",
		byteena_reg_b => "CLOCK1",
		byteena_aclr_b => "NONE",
		outdata_aclr_b => "NONE",
		power_up_uninitialized => "FALSE",
		init_file => "iram.hex"
	)
	PORT MAP (
		clock0    => sl0_clk,
		wren_a    => sl0_write,
		byteena_a => sl0_loc_be,
		address_a => sl0_adr(USEDW_WIDTH+1 DOWNTO 2),
		data_a    => sl0_dat_i,
		q_a       => sl0_dat_o,

		clock1    => sl1_clk,
		wren_b    => sl1_write,
		byteena_b => sl1_loc_be,
		address_b => sl1_adr(USEDW_WIDTH+1 DOWNTO 2),
		data_b    => sl1_dat_i,
		q_b       => sl1_dat_o);
	
END GENERATE gen_2clk;
	
gen_1clk: IF SAME_CLK GENERATE
	sl0_clk_int <= sl0_clk;
	sl1_clk_int <= sl0_clk;

	altsyncram_component : altsyncram
	GENERIC MAP (
		intended_device_family => "Cyclone",
		ram_block_type => "M4K",
		operation_mode => "BIDIR_DUAL_PORT",
		width_a => 32,
		widthad_a => USEDW_WIDTH,
		numwords_a => 2**USEDW_WIDTH,
		width_b => 32,
		widthad_b => USEDW_WIDTH,
		numwords_b => 2**USEDW_WIDTH,
		lpm_type => "altsyncram",
		width_byteena_a => 4,
		width_byteena_b => 4,
		byte_size => 8,
		outdata_reg_a => "UNREGISTERED",
		outdata_aclr_a => "NONE",
		outdata_reg_b => "UNREGISTERED",
		indata_aclr_a => "NONE",
		wrcontrol_aclr_a => "NONE",
		address_aclr_a => "NONE",
		byteena_aclr_a => "NONE",
		indata_reg_b => "CLOCK0",
		address_reg_b => "CLOCK0",
		wrcontrol_wraddress_reg_b => "CLOCK0",
		indata_aclr_b => "NONE",
		wrcontrol_aclr_b => "NONE",
		address_aclr_b => "NONE",
		byteena_reg_b => "CLOCK0",
		byteena_aclr_b => "NONE",
		outdata_aclr_b => "NONE",
		read_during_write_mode_mixed_ports => "OLD_DATA",
		power_up_uninitialized => "FALSE",
		init_file => "iram.hex")
	PORT MAP (
		clock0 => sl0_clk,

		wren_a    => sl0_write,
		byteena_a => sl0_loc_be,
		address_a => sl0_adr(USEDW_WIDTH+1 DOWNTO 2),
		data_a    => sl0_dat_i,
		q_a       => sl0_dat_o, 
		wren_b    => sl1_write,
		byteena_b => sl1_loc_be,
		address_b => sl1_adr(USEDW_WIDTH+1 DOWNTO 2),
		data_b    => sl1_dat_i,
		q_b       => sl1_dat_o);

END GENERATE gen_1clk;

END iram_dp_wb_arch;
