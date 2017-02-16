--------------------------------------------------------------------------------
-- Title         : Whisbone Bus Interconnection
-- Project       :                                             
--------------------------------------------------------------------------------
-- File          : wb_bus.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 
--------------------------------------------------------------------------------
-- Simulator     : Modelsim
-- Synthesis     : Quartus II
--------------------------------------------------------------------------------
-- Description :
-- Master #  0 1 2
-- Slave : 0 1 0 0
-- Slave : 1 1 0 0
-- Slave : 2 1 0 1
-- Slave : 3 1 1 1
-- Slave : 4 0 1 1
-- Master 0 = 4 connection(s)
-- Master 1 = 2 connection(s)
-- Master 2 = 3 connection(s)
-- Slave 0 = 1 connection(s)
-- Slave 1 = 1 connection(s)
-- Slave 2 = 2 connection(s)
-- Slave 3 = 3 connection(s)
-- Slave 4 = 2 connection(s)
-- 
--------------------------------------------------------------------------------
-- Hierarchy:
--
-- wb_pkg.vhd
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
-- Revision: 1.6 
--
--------------------------------------------------------------------------------

LIBRARY ieee, work;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.wb_pkg.ALL;

ENTITY wb_bus IS
   GENERIC (
      sets      : std_logic_vector(3 DOWNTO 0) := "1110";
      timeout   : integer := 5000 );
   PORT (
      clk           : IN std_logic;
      rst           : IN std_logic;
       -- Master Bus
      wbmo_0        : IN wbo_type;
      wbmi_0        : OUT wbi_type;
      wbmo_0_cyc    : IN std_logic_vector(3 DOWNTO 0);
      wbmo_1        : IN wbo_type;
      wbmi_1        : OUT wbi_type;
      wbmo_1_cyc    : IN std_logic_vector(1 DOWNTO 0);
      wbmo_2        : IN wbo_type;
      wbmi_2        : OUT wbi_type;
      wbmo_2_cyc    : IN std_logic_vector(2 DOWNTO 0);
      -- Slave Bus
      wbso_0        : IN wbi_type;
      wbsi_0        : OUT wbo_type;
      wbsi_0_cyc    : OUT std_logic;
      wbso_1        : IN wbi_type;
      wbsi_1        : OUT wbo_type;
      wbsi_1_cyc    : OUT std_logic;
      wbso_2        : IN wbi_type;
      wbsi_2        : OUT wbo_type;
      wbsi_2_cyc    : OUT std_logic;
      wbso_3        : IN wbi_type;
      wbsi_3        : OUT wbo_type;
      wbsi_3_cyc    : OUT std_logic;
      wbso_4        : IN wbi_type;
      wbsi_4        : OUT wbo_type;
      wbsi_4_cyc    : OUT std_logic
);
END wb_bus;

ARCHITECTURE wb_bus_arch OF wb_bus IS
 -- COMPONENT DECLARATIONS
   COMPONENT switch_fab_1
   GENERIC (
      registered     : IN boolean
   );
   PORT (
      clk            : IN std_logic;
      rst            : IN std_logic;
      cyc_0          : IN std_logic;
      ack_0          : OUT std_logic;
      err_0          : OUT std_logic;
      wbo_0          : IN wbo_type;
      wbo_slave      : IN wbi_type;
      wbi_slave      : OUT wbo_type;
      wbi_slave_cyc  : OUT std_logic
      );
   END COMPONENT;
   
   COMPONENT switch_fab_2
   GENERIC (
      registered     : IN boolean
   );
   PORT (
      clk            : IN std_logic;
      rst            : IN std_logic;
      cyc_0          : IN std_logic;
      ack_0          : OUT std_logic;
      err_0          : OUT std_logic;
      wbo_0          : IN wbo_type;
      cyc_1          : IN std_logic;
      ack_1          : OUT std_logic;
      err_1          : OUT std_logic;
      wbo_1          : IN wbo_type;
      wbo_slave      : IN wbi_type;
      wbi_slave      : OUT wbo_type;
      wbi_slave_cyc  : OUT std_logic
   );
   END COMPONENT;
   
   COMPONENT switch_fab_3
   GENERIC (
      registered     : IN boolean
   );
   PORT (
      clk            : IN std_logic;
      rst            : IN std_logic;
      cyc_0          : IN std_logic;
      ack_0          : OUT std_logic;
      err_0          : OUT std_logic;
      wbo_0          : IN wbo_type;
      cyc_1          : IN std_logic;
      ack_1          : OUT std_logic;
      err_1          : OUT std_logic;
      wbo_1          : IN wbo_type;
      cyc_2          : IN std_logic;
      ack_2          : OUT std_logic;
      err_2          : OUT std_logic;
      wbo_2          : IN wbo_type;
      wbo_slave      : IN wbi_type;
      wbi_slave      : OUT wbo_type;
      wbi_slave_cyc  : OUT std_logic
      );
   END COMPONENT;
   
-- synthesis translate_off
   COMPONENT wbmon
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
   SIGNAL wbs_0_ack    : std_logic;
   SIGNAL wbs_0_err    : std_logic;
   
   SIGNAL wbs_1_ack    : std_logic;
   SIGNAL wbs_1_err    : std_logic;
   
   SIGNAL wbs_2_ack    : std_logic_vector(1 DOWNTO 0);
   SIGNAL wbs_2_err    : std_logic_vector(1 DOWNTO 0);
   
   SIGNAL wbs_3_ack    : std_logic_vector(2 DOWNTO 0);
   SIGNAL wbs_3_err    : std_logic_vector(2 DOWNTO 0);
   
   SIGNAL wbs_4_ack    : std_logic_vector(1 DOWNTO 0);
   SIGNAL wbs_4_err    : std_logic_vector(1 DOWNTO 0);
   
   SIGNAL wbsi_0_int      : wbo_type;
   SIGNAL wbsi_0_cyc_int  : std_logic;
   SIGNAL wbsi_1_int      : wbo_type;
   SIGNAL wbsi_1_cyc_int  : std_logic;
   SIGNAL wbsi_2_int      : wbo_type;
   SIGNAL wbsi_2_cyc_int  : std_logic;
   SIGNAL wbsi_3_int      : wbo_type;
   SIGNAL wbsi_3_cyc_int  : std_logic;
   SIGNAL wbsi_4_int      : wbo_type;
   SIGNAL wbsi_4_cyc_int  : std_logic;
   SIGNAL wbmi_0_int      : wbi_type;
   SIGNAL wbmo_0_cyc_s    : std_logic;
   SIGNAL wbmi_1_int      : wbi_type;
   SIGNAL wbmo_1_cyc_s    : std_logic;
   SIGNAL wbmi_2_int      : wbi_type;
   SIGNAL wbmo_2_cyc_s    : std_logic;
BEGIN
   wbsi_0        <= wbsi_0_int;
   wbsi_0_cyc    <= wbsi_0_cyc_int;
   wbsi_1        <= wbsi_1_int;
   wbsi_1_cyc    <= wbsi_1_cyc_int;
   wbsi_2        <= wbsi_2_int;
   wbsi_2_cyc    <= wbsi_2_cyc_int;
   wbsi_3        <= wbsi_3_int;
   wbsi_3_cyc    <= wbsi_3_cyc_int;
   wbsi_4        <= wbsi_4_int;
   wbsi_4_cyc    <= wbsi_4_cyc_int;
   wbmi_0        <= wbmi_0_int;
   wbmi_1        <= wbmi_1_int;
   wbmi_2        <= wbmi_2_int;
   
   -- data multiplexer for master #0
   data_mux (
      cyc       => wbmo_0_cyc,
      data_in_0  => wbso_0.dat,
      data_in_1  => wbso_1.dat,
      data_in_2  => wbso_2.dat,
      data_in_3  => wbso_3.dat,
      data_out    => wbmi_0_int.dat 
   );
   wbmi_0_int.ack <= wbs_0_ack OR wbs_1_ack OR wbs_2_ack(0) OR wbs_3_ack(0);
   wbmi_0_int.err <= wbs_0_err OR wbs_1_err OR wbs_2_err(0) OR wbs_3_err(0);
   
   -- data multiplexer for master #1
   data_mux (
      cyc       => wbmo_1_cyc,
      data_in_0  => wbso_3.dat,
      data_in_1  => wbso_4.dat,
      data_out    => wbmi_1_int.dat 
   );
   wbmi_1_int.ack <= wbs_3_ack(1) OR wbs_4_ack(0);
   wbmi_1_int.err <= wbs_3_err(1) OR wbs_4_err(0);
   
   -- data multiplexer for master #2
   data_mux (
      cyc       => wbmo_2_cyc,
      data_in_0  => wbso_2.dat,
      data_in_1  => wbso_3.dat,
      data_in_2  => wbso_4.dat,
      data_out    => wbmi_2_int.dat 
   );
   wbmi_2_int.ack <= wbs_2_ack(1) OR wbs_3_ack(2) OR wbs_4_ack(1);
   wbmi_2_int.err <= wbs_2_err(1) OR wbs_3_err(2) OR wbs_4_err(1);
   
   -- sf for slave #0:
   sf_0: switch_fab_1
   GENERIC MAP (
      registered => FALSE
   )
   PORT MAP (
      clk            => clk,
      rst            => rst,
      -- master busses:
      wbo_0          => wbmo_0,
      cyc_0          => wbmo_0_cyc(0),
      ack_0          => wbs_0_ack,
      err_0          => wbs_0_err,
      -- slave bus:
      wbo_slave      => wbso_0,
      wbi_slave      => wbsi_0_int,
      wbi_slave_cyc  => wbsi_0_cyc_int
   );
   
   -- sf for slave #1:
   sf_1: switch_fab_1
   GENERIC MAP (
      registered => FALSE
   )
   PORT MAP (
      clk            => clk,
      rst            => rst,
      -- master busses:
      wbo_0          => wbmo_0,
      cyc_0          => wbmo_0_cyc(1),
      ack_0          => wbs_1_ack,
      err_0          => wbs_1_err,
      -- slave bus:
      wbo_slave      => wbso_1,
      wbi_slave      => wbsi_1_int,
      wbi_slave_cyc  => wbsi_1_cyc_int
   );
   
   -- sf for slave #2:
   sf_2: switch_fab_2
   GENERIC MAP (
      registered => FALSE
   )
   PORT MAP (
      clk            => clk,
      rst            => rst,
      -- master busses:
      wbo_0          => wbmo_0,
      cyc_0          => wbmo_0_cyc(2),
      ack_0          => wbs_2_ack(0),
      err_0          => wbs_2_err(0),
      wbo_1          => wbmo_2,
      cyc_1          => wbmo_2_cyc(0),
      ack_1          => wbs_2_ack(1),
      err_1          => wbs_2_err(1),
      -- slave bus:
      wbo_slave      => wbso_2,
      wbi_slave      => wbsi_2_int,
      wbi_slave_cyc  => wbsi_2_cyc_int
   );
   
   -- sf for slave #3:
   sf_3: switch_fab_3
   GENERIC MAP (
      registered => FALSE
   )
   PORT MAP (
      clk            => clk,
      rst            => rst,
      -- master busses:
      wbo_0          => wbmo_0,
      cyc_0          => wbmo_0_cyc(3),
      ack_0          => wbs_3_ack(0),
      err_0          => wbs_3_err(0),
      wbo_1          => wbmo_1,
      cyc_1          => wbmo_1_cyc(0),
      ack_1          => wbs_3_ack(1),
      err_1          => wbs_3_err(1),
      wbo_2          => wbmo_2,
      cyc_2          => wbmo_2_cyc(1),
      ack_2          => wbs_3_ack(2),
      err_2          => wbs_3_err(2),
      -- slave bus:
      wbo_slave      => wbso_3,
      wbi_slave      => wbsi_3_int,
      wbi_slave_cyc  => wbsi_3_cyc_int
   );
   
   -- sf for slave #4:
   sf_4: switch_fab_2
   GENERIC MAP (
      registered => FALSE
   )
   PORT MAP (
      clk            => clk,
      rst            => rst,
      -- master busses:
      wbo_0          => wbmo_1,
      cyc_0          => wbmo_1_cyc(1),
      ack_0          => wbs_4_ack(0),
      err_0          => wbs_4_err(0),
      wbo_1          => wbmo_2,
      cyc_1          => wbmo_2_cyc(2),
      ack_1          => wbs_4_ack(1),
      err_1          => wbs_4_err(1),
      -- slave bus:
      wbo_slave      => wbso_4,
      wbi_slave      => wbsi_4_int,
      wbi_slave_cyc  => wbsi_4_cyc_int
   );
   
-- synthesis translate_off
   wbmo_0_cyc_s <= '1' WHEN wbmo_0_cyc = 0 ELSE '1';
 wbm_0: wbmon
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
      sel            => wbmo_0.sel,
      cyc            => wbmo_0_cyc_s,
      stb            => wbmo_0.stb,
      ack            => wbmi_0_int.ack,
      err            => wbmi_0_int.err,
      we             => wbmo_0.we
   );
   
   wbmo_1_cyc_s <= '1' WHEN wbmo_1_cyc = 0 ELSE '1';
 wbm_1: wbmon
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
      sel            => wbmo_1.sel,
      cyc            => wbmo_1_cyc_s,
      stb            => wbmo_1.stb,
      ack            => wbmi_1_int.ack,
      err            => wbmi_1_int.err,
      we             => wbmo_1.we
   );
   
   wbmo_2_cyc_s <= '1' WHEN wbmo_2_cyc = 0 ELSE '1';
 wbm_2: wbmon
   GENERIC MAP (
      wbname         => "wbm_2",
      sets           => sets,
      timeout        => timeout
   )
   PORT MAP (
      clk            => clk,
      rst            => rst,
      adr            => wbmo_2.adr,
      sldat_i        => wbmo_2.dat,
      sldat_o        => wbmi_2_int.dat,
      cti            => wbmo_2.cti,
      sel            => wbmo_2.sel,
      cyc            => wbmo_2_cyc_s,
      stb            => wbmo_2.stb,
      ack            => wbmi_2_int.ack,
      err            => wbmi_2_int.err,
      we             => wbmo_2.we
   );
   
   wbs_0: wbmon
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
      sel            => wbsi_0_int.sel,
      cyc            => wbsi_0_cyc_int,
      stb            => wbsi_0_int.stb,
      ack            => wbso_0.ack,
      err            => wbso_0.err,
      we             => wbsi_0_int.we
   );
   
   wbs_1: wbmon
   GENERIC MAP (
      wbname         => "wbs_1",
      sets           => sets,
      timeout        => timeout
   )
   PORT MAP (
      clk            => clk,
      rst            => rst,
      adr            => wbsi_1_int.adr,
      sldat_i        => wbsi_1_int.dat,
      sldat_o        => wbso_1.dat,
      cti            => wbsi_1_int.cti,
      sel            => wbsi_1_int.sel,
      cyc            => wbsi_1_cyc_int,
      stb            => wbsi_1_int.stb,
      ack            => wbso_1.ack,
      err            => wbso_1.err,
      we             => wbsi_1_int.we
   );
   
   wbs_2: wbmon
   GENERIC MAP (
      wbname         => "wbs_2",
      sets           => sets,
      timeout        => timeout
   )
   PORT MAP (
      clk            => clk,
      rst            => rst,
      adr            => wbsi_2_int.adr,
      sldat_i        => wbsi_2_int.dat,
      sldat_o        => wbso_2.dat,
      cti            => wbsi_2_int.cti,
      sel            => wbsi_2_int.sel,
      cyc            => wbsi_2_cyc_int,
      stb            => wbsi_2_int.stb,
      ack            => wbso_2.ack,
      err            => wbso_2.err,
      we             => wbsi_2_int.we
   );
   
   wbs_3: wbmon
   GENERIC MAP (
      wbname         => "wbs_3",
      sets           => sets,
      timeout        => timeout
   )
   PORT MAP (
      clk            => clk,
      rst            => rst,
      adr            => wbsi_3_int.adr,
      sldat_i        => wbsi_3_int.dat,
      sldat_o        => wbso_3.dat,
      cti            => wbsi_3_int.cti,
      sel            => wbsi_3_int.sel,
      cyc            => wbsi_3_cyc_int,
      stb            => wbsi_3_int.stb,
      ack            => wbso_3.ack,
      err            => wbso_3.err,
      we             => wbsi_3_int.we
   );
   
   wbs_4: wbmon
   GENERIC MAP (
      wbname         => "wbs_4",
      sets           => sets,
      timeout        => timeout
   )
   PORT MAP (
      clk            => clk,
      rst            => rst,
      adr            => wbsi_4_int.adr,
      sldat_i        => wbsi_4_int.dat,
      sldat_o        => wbso_4.dat,
      cti            => wbsi_4_int.cti,
      sel            => wbsi_4_int.sel,
      cyc            => wbsi_4_cyc_int,
      stb            => wbsi_4_int.stb,
      ack            => wbso_4.ack,
      err            => wbso_4.err,
      we             => wbsi_4_int.we
   );
   
-- synthesis translate_on
END wb_bus_arch;
