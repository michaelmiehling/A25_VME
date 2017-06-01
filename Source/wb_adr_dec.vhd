
---------------------------------------------------------------
-- Title         : Adress decoder for whisbone bus
-- Project       : <A025-00>
---------------------------------------------------------------
-- File          : wb_adr_dec.vhd
-- Author        : Chameleon_V2.exe
-- Email         : michael.ernst@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 2017/6/1  -  12:2:21
---------------------------------------------------------------
-- Simulator     : 
-- Synthesis     : 
---------------------------------------------------------------
-- Description : Created with Chameleon_V2.exe  
--               v1.18 
--               2016-06-14
--
-- 
-- +-Module Name-------------------+-cyc-+---offset-+-----size-+-bar-+
-- |               Chameleon Table |   0 |        0 |      200 |   0 |
-- |               16Z126_SERFLASH |   1 |      200 |       10 |   0 |
-- |                 16z002-01 VME |   2 |    10000 |    10000 |   0 |
-- |          16z002-01 VME A16D16 |   3 |    20000 |    10000 |   0 |
-- |          16z002-01 VME A16D32 |   4 |    30000 |    10000 |   0 |
-- |            16z002-01 VME SRAM |   5 |        0 |   100000 |   1 |
-- |          16z002-01 VME A24D16 |   6 |        0 |  1000000 |   2 |
-- |          16z002-01 VME A24D32 |   7 |  1000000 |  1000000 |   2 |
-- |             16z002-01 VME A32 |   8 |        0 | 20000000 |   3 |
-- |          16z002-01 VME CR/CSR |   9 |        0 |  1000000 |   4 |
-- +-------------------------------+-----+----------+----------+-----+
--
--
---------------------------------------------------------------
-- Hierarchy:
--
-- 
---------------------------------------------------------------
-- Copyright (C) 2017, MEN Mikroelektronik Nuernberg GmbH
--
--   All rights reserved. Reproduction in whole or part is 
--      prohibited without the written permission of the 
--                    copyright owner.           
---------------------------------------------------------------
--                         History                                    
---------------------------------------------------------------
-- $Revision: $
--
-- $Log: $
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.all;

ENTITY wb_adr_dec IS
PORT (
   pci_cyc_i      : IN std_logic_vector(4 DOWNTO 0);
   wbm_adr_o_q    : IN std_logic_vector(31 DOWNTO 2);

   wbm_cyc_o      : OUT std_logic_vector(9 DOWNTO 0)

   );
END wb_adr_dec;

ARCHITECTURE wb_adr_dec_arch OF wb_adr_dec IS 
SIGNAL zero : std_logic_vector(4 DOWNTO 0);
BEGIN
   zero <= (OTHERS => '0');
   PROCESS(wbm_adr_o_q, pci_cyc_i)
      VARIABLE wbm_cyc_o_int : std_logic_vector(9 DOWNTO 0);
      BEGIN
         wbm_cyc_o_int := (OTHERS => '0');

			
         -- Chameleon Table - cycle 0 - offset 0 - size 200 --
         IF pci_cyc_i(0) = '1' AND wbm_adr_o_q(17 DOWNTO 9) = "000000000" THEN
            wbm_cyc_o_int(0) := '1';
         ELSE
            wbm_cyc_o_int(0) := '0';
         END IF;


         -- 16Z126_SERFLASH - cycle 1 - offset 200 - size 10 --
         IF pci_cyc_i(0) = '1' AND wbm_adr_o_q(17 DOWNTO 4) = "00000000100000" THEN
            wbm_cyc_o_int(1) := '1';
         ELSE
            wbm_cyc_o_int(1) := '0';
         END IF;


         -- 16z002-01 VME - cycle 2 - offset 10000 - size 10000 --
         IF pci_cyc_i(0) = '1' AND wbm_adr_o_q(17 DOWNTO 16) = "01" THEN
            wbm_cyc_o_int(2) := '1';
         ELSE
            wbm_cyc_o_int(2) := '0';
         END IF;


         -- 16z002-01 VME A16D16 - cycle 3 - offset 20000 - size 10000 --
         IF pci_cyc_i(0) = '1' AND wbm_adr_o_q(17 DOWNTO 16) = "10" THEN
            wbm_cyc_o_int(3) := '1';
         ELSE
            wbm_cyc_o_int(3) := '0';
         END IF;


         -- 16z002-01 VME A16D32 - cycle 4 - offset 30000 - size 10000 --
         IF pci_cyc_i(0) = '1' AND wbm_adr_o_q(17 DOWNTO 16) = "11" THEN
            wbm_cyc_o_int(4) := '1';
         ELSE
            wbm_cyc_o_int(4) := '0';
         END IF;


         -- 16z002-01 VME SRAM - cycle 5 - offset 0 - size 100000 --
         IF pci_cyc_i(1) = '1' THEN
            wbm_cyc_o_int(5) := '1';
         ELSE
            wbm_cyc_o_int(5) := '0';
         END IF;


         -- 16z002-01 VME A24D16 - cycle 6 - offset 0 - size 1000000 --
         IF pci_cyc_i(2) = '1' AND wbm_adr_o_q(24) = '0' THEN
            wbm_cyc_o_int(6) := '1';
         ELSE
            wbm_cyc_o_int(6) := '0';
         END IF;


         -- 16z002-01 VME A24D32 - cycle 7 - offset 1000000 - size 1000000 --
         IF pci_cyc_i(2) = '1' AND wbm_adr_o_q(24) = '1' THEN
            wbm_cyc_o_int(7) := '1';
         ELSE
            wbm_cyc_o_int(7) := '0';
         END IF;


         -- 16z002-01 VME A32 - cycle 8 - offset 0 - size 20000000 --
         IF pci_cyc_i(3) = '1' THEN
            wbm_cyc_o_int(8) := '1';
         ELSE
            wbm_cyc_o_int(8) := '0';
         END IF;


         -- 16z002-01 VME CR/CSR - cycle 9 - offset 0 - size 1000000 --
         IF pci_cyc_i(4) = '1' THEN
            wbm_cyc_o_int(9) := '1';
         ELSE
            wbm_cyc_o_int(9) := '0';
         END IF;

         IF pci_cyc_i /= zero AND wbm_cyc_o_int = "0000000000" THEN
            wbm_cyc_o_int(0) := '1';
         END IF;

  	
      wbm_cyc_o <= wbm_cyc_o_int;
	  	
	  	END PROCESS;
	  
END wb_adr_dec_arch;
 