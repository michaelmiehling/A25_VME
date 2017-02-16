---------------------------------------------------------------
-- Title         : Whisbone Bus Interconnection
-- Project       :                                             
---------------------------------------------------------------
-- File          : z126_01_wb_if_arbiter.vhd
-- Author        : ....
-- Email         : ....
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 
---------------------------------------------------------------
-- Simulator     : Modelsim
-- Synthesis     : Quartus II
---------------------------------------------------------------
-- Description :
-- Master #  0 1
-- Slave : 0 1 1
-- Master 0 = 1 connection(s)
-- Master 1 = 1 connection(s)
-- Slave  0 = 2 connection(s)
-- 
-- This module is derived from the 16z100-
-- It contaions an additional arbitration of control 
-- signals for the z126_01_wb2pasmi.vhd module in the 16z126-01
-- design.
---------------------------------------------------------------
-- Hierarchy:
--
-- z126_01_wb_pkg.vhd
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
-- $Log: z126_01_wb_if_arbiter.vhd,v $
-- Revision 1.1  2014/03/03 17:49:57  AGeissler
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee, work;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.z126_01_pkg.ALL;
USE work.z126_01_wb_pkg.ALL;

ENTITY z126_01_wb_if_arbiter IS
   GENERIC (
      sets           : std_logic_vector(3 DOWNTO 0) := "1110";
      timeout        : integer := 5000 
   );
   PORT (
      clk                     : IN std_logic;
      rst                     : IN std_logic;
      
      -- master 0 interface
      wbmo_0                  : IN wbo_type;
      wbmi_0                  : OUT wbi_type;
      wbmo_0_cyc              : IN std_logic;
      
      -- wb2pasmi master 0 control signals
      ctrlmo_0                : IN ctrl_wb2pasmi_out_type;
      ctrlmi_0                : OUT ctrl_wb2pasmi_in_type;
      
      -- master 1 interface
      wbmo_1                  : IN wbo_type;
      wbmi_1                  : OUT wbi_type;
      wbmo_1_cyc              : IN std_logic;
      
      -- wb2pasmi master 1 control signals
      ctrlmo_1                : IN ctrl_wb2pasmi_out_type;
      ctrlmi_1                : OUT ctrl_wb2pasmi_in_type;
      
      -- slave 0 interface
      wbso_0                  : IN wbi_type;
      wbsi_0                  : OUT wbo_type;
      wbsi_0_cyc              : OUT std_logic;
      
      -- wb2pasmi slave 0 control signals
      ctrlso_0                : IN ctrl_wb2pasmi_in_type;
      ctrlsi_0                : OUT ctrl_wb2pasmi_out_type
      
   );
END z126_01_wb_if_arbiter;

ARCHITECTURE z126_01_wb_if_arbiter_arch OF z126_01_wb_if_arbiter IS
 -- COMPONENT DECLARATIONS
   COMPONENT z126_01_switch_fab_2 IS
      PORT (
         clk            : IN std_logic;
         rst            : IN std_logic;
         cyc_0          : IN std_logic;
         ack_0          : OUT std_logic;
         err_0          : OUT std_logic;
         wbo_0          : IN wbo_type;
         ctrlmo_0       : IN ctrl_wb2pasmi_out_type;
         ctrlmi_0       : OUT ctrl_wb2pasmi_in_type;
         
         cyc_1          : IN std_logic;
         ack_1          : OUT std_logic;
         err_1          : OUT std_logic;
         wbo_1          : IN wbo_type;
         ctrlmo_1       : IN ctrl_wb2pasmi_out_type;
         ctrlmi_1       : OUT ctrl_wb2pasmi_in_type;
      
         wbo_slave      : IN wbi_type;
         wbi_slave      : OUT wbo_type;
         wbi_slave_cyc  : OUT std_logic;
         ctrlso_0       : IN ctrl_wb2pasmi_in_type;
         ctrlsi_0       : OUT ctrl_wb2pasmi_out_type
      );
   END COMPONENT;

-- synthesis translate_off
   COMPONENT z126_01_wbmon IS
      GENERIC (
         wbname         : string := "wbmon";
         sets           : std_logic_vector(3 DOWNTO 0) := "1110";
                        --   1110
                        --   ||||
                        --   |||+- write notes to Modelsim out
                        --   ||+-- write errors to Modelsim out
                        --   |+--- write notes to file out
                        --   +---- write errors to file out
         timeout        : integer := 100
      );
      PORT (
         clk            : IN std_logic;
         rst            : IN std_logic;
         adr            : IN std_logic_vector(31 DOWNTO 0);
         sldat_i        : IN std_logic_vector(31 DOWNTO 0);
         sldat_o        : IN std_logic_vector(31 DOWNTO 0);
         cti            : IN std_logic_vector(2 DOWNTO 0);
         bte            : IN std_logic_vector(1 DOWNTO 0);
         sel            : IN std_logic_vector(3 DOWNTO 0);
         cyc            : IN std_logic;
         stb            : IN std_logic;
         ack            : IN std_logic;
         err            : IN std_logic;
         we             : IN std_logic
      );
   END COMPONENT;
-- synthesis translate_on
   
   -- SIGNAL DEFINITIONS
   SIGNAL wbs_0_ack        : std_logic_vector(1 DOWNTO 0);
   SIGNAL wbs_0_err        : std_logic_vector(1 DOWNTO 0);
   
   SIGNAL wbsi_0_int       : wbo_type;
   SIGNAL wbsi_0_cyc_int   : std_logic;
   SIGNAL wbmi_0_int       : wbi_type;
   SIGNAL wbmo_0_cyc_s     : std_logic;
   SIGNAL wbmi_1_int       : wbi_type;
   SIGNAL wbmo_1_cyc_s     : std_logic;
BEGIN
   wbsi_0         <= wbsi_0_int;
   wbsi_0_cyc     <= wbsi_0_cyc_int;
   wbmi_0         <= wbmi_0_int;
   wbmi_1         <= wbmi_1_int;
   
   -- no data multiplexer for master #0 is needed, because of connection to one slave only
   wbmi_0_int.dat <= wbso_0.dat;
   
   wbmi_0_int.ack <= wbs_0_ack(0);
   wbmi_0_int.err <= wbs_0_err(0);
   
   -- no data multiplexer for master #1 is needed, because of connection to one slave only
   wbmi_1_int.dat <= wbso_0.dat;
   
   wbmi_1_int.ack <= wbs_0_ack(1);
   wbmi_1_int.err <= wbs_0_err(1);
   
   -- sf for slave #0:
   sf_0: z126_01_switch_fab_2
   PORT MAP (  
      clk            => clk,
      rst            => rst,
      -- master busses:
      wbo_0          => wbmo_0,
      cyc_0          => wbmo_0_cyc,
      ack_0          => wbs_0_ack(0),
      err_0          => wbs_0_err(0),
      wbo_1          => wbmo_1,
      cyc_1          => wbmo_1_cyc,
      ack_1          => wbs_0_ack(1),
      err_1          => wbs_0_err(1),
      -- slave bus:
      wbo_slave      => wbso_0,
      wbi_slave      => wbsi_0_int,
      wbi_slave_cyc  => wbsi_0_cyc_int,
      
      -- wb2pasmi control signals
      ctrlmo_0       => ctrlmo_0,
      ctrlmi_0       => ctrlmi_0,
      ctrlmo_1       => ctrlmo_1,
      ctrlmi_1       => ctrlmi_1,
      ctrlso_0       => ctrlso_0,
      ctrlsi_0       => ctrlsi_0
   );
   
-- synthesis translate_off
   wbmo_0_cyc_s <= '1' WHEN wbmo_0_cyc = '0' ELSE '1';
   wbm_0: z126_01_wbmon
   GENERIC MAP (
      wbname         => "wbm_0",
      sets           => sets,
      timeout        => timeout
   )
   PORT MAP (
      clk            => clk,
      rst            => rst,
      adr            => wbmo_0.adr,
      sldat_i        => wbmo_0.dat,
      sldat_o        => wbmi_0_int.dat,
      cti            => wbmo_0.cti,
      bte            => wbmo_0.bte,
      sel            => wbmo_0.sel,
      cyc            => wbmo_0_cyc_s,
      stb            => wbmo_0.stb,
      ack            => wbmi_0_int.ack,
      err            => wbmi_0_int.err,
      we             => wbmo_0.we
   );
   
   wbmo_1_cyc_s <= '1' WHEN wbmo_1_cyc = '0' ELSE '1';
   wbm_1: z126_01_wbmon
   GENERIC MAP (
      wbname         => "wbm_1",
      sets           => sets,
      timeout        => timeout
   )
   PORT MAP (
      clk            => clk,
      rst            => rst,
      adr            => wbmo_1.adr,
      sldat_i        => wbmo_1.dat,
      sldat_o        => wbmi_1_int.dat,
      cti            => wbmo_1.cti,
      bte            => wbmo_1.bte,
      sel            => wbmo_1.sel,
      cyc            => wbmo_1_cyc_s,
      stb            => wbmo_1.stb,
      ack            => wbmi_1_int.ack,
      err            => wbmi_1_int.err,
      we             => wbmo_1.we
   );
   
   wbs_0: z126_01_wbmon
   GENERIC MAP (
      wbname         => "wbs_0",
      sets           => sets,
      timeout        => timeout
   )
   PORT MAP (
      clk            => clk,
      rst            => rst,
      adr            => wbsi_0_int.adr,
      sldat_i        => wbsi_0_int.dat,
      sldat_o        => wbso_0.dat,
      cti            => wbsi_0_int.cti,
      bte            => wbsi_0_int.bte,
      sel            => wbsi_0_int.sel,
      cyc            => wbsi_0_cyc_int,
      stb            => wbsi_0_int.stb,
      ack            => wbso_0.ack,
      err            => wbso_0.err,
      we             => wbsi_0_int.we
   );
   
-- synthesis translate_on
END z126_01_wb_if_arbiter_arch;
