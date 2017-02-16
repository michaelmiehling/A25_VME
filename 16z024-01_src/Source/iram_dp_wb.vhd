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
COMPONENT iram_dp_2clk
	GENERIC
	(
	   USEDW_WIDTH	: positive := 6								-- width of address vector (6 = one M4K)
	);
	PORT
	(
		data_a		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren_a		: IN STD_LOGIC  := '1';
		address_a		: IN STD_LOGIC_VECTOR (USEDW_WIDTH-1 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (USEDW_WIDTH-1 DOWNTO 0);
		wren_b		: IN STD_LOGIC  := '1';
		byteena_a		: IN STD_LOGIC_VECTOR (3 DOWNTO 0) :=  (OTHERS => '1');
		byteena_b		: IN STD_LOGIC_VECTOR (3 DOWNTO 0) :=  (OTHERS => '1');
		clock_a		: IN STD_LOGIC ;
		clock_b		: IN STD_LOGIC ;
		q_a		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT iram_dp_1clk
	GENERIC
	(
	   USEDW_WIDTH	: positive := 6								-- width of address vector (6 = one M4K)
	);
	PORT
	(
		data_a		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren_a		: IN STD_LOGIC  := '1';
		address_a		: IN STD_LOGIC_VECTOR (USEDW_WIDTH-1 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (USEDW_WIDTH-1 DOWNTO 0);
		wren_b		: IN STD_LOGIC  := '1';
		byteena_a		: IN STD_LOGIC_VECTOR (3 DOWNTO 0) :=  (OTHERS => '1');
		byteena_b		: IN STD_LOGIC_VECTOR (3 DOWNTO 0) :=  (OTHERS => '1');
		clock		: IN STD_LOGIC ;
		q_a		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END COMPONENT;



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
	
	iram_2c: iram_dp_2clk
		GENERIC MAP
			(
		   USEDW_WIDTH		=> USEDW_WIDTH
			)
		PORT MAP 
		(
			data_a			=> sl0_dat_i,
			wren_a			=> sl0_write,
			address_a		=> sl0_adr(USEDW_WIDTH+1 DOWNTO 2),
			data_b			=> sl1_dat_i,
			address_b		=> sl1_adr(USEDW_WIDTH+1 DOWNTO 2),
			wren_b			=> sl1_write,
			byteena_a		=> sl0_loc_be,
			byteena_b		=> sl1_loc_be,
			clock_a			=> sl0_clk,
			clock_b			=> sl1_clk,
			q_a				=> sl0_dat_o,
			q_b				=> sl1_dat_o
		);
	END GENERATE gen_2clk;
	
gen_1clk: IF SAME_CLK GENERATE
	sl0_clk_int <= sl0_clk;
	sl1_clk_int <= sl0_clk;

	iram_1c: iram_dp_1clk
		GENERIC MAP
			(
		   USEDW_WIDTH		=> USEDW_WIDTH
			)
		PORT MAP 
		(                    
 			data_a			=> sl0_dat_i,  
			wren_a			=> sl0_write,     
			address_a		=> sl0_adr(USEDW_WIDTH+1 DOWNTO 2),    
			data_b			=> sl1_dat_i,  
			address_b		=> sl1_adr(USEDW_WIDTH+1 DOWNTO 2),    
			wren_b			=> sl1_write,     
			byteena_a		=> sl0_loc_be, 
			byteena_b		=> sl1_loc_be, 
			clock				=> sl0_clk,
			q_a				=> sl0_dat_o, 
			q_b				=> sl1_dat_o  
		);
	END GENERATE gen_1clk;

END iram_dp_wb_arch;
