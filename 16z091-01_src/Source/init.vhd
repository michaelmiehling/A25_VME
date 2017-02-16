--------------------------------------------------------------------------------
-- Title       : init module
-- Project     : 16z091-01
--------------------------------------------------------------------------------
-- File        : init.vhd
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 13.12.2010
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6a / ModelSim AE 6.5e sp1
-- Synthesis   : 
--------------------------------------------------------------------------------
-- Description : 
-- this module collects information from the config space provided by the hard
-- IP core and presents it to the 16z091-01 design
--------------------------------------------------------------------------------
-- Hierarchy   : 
--    ip_16z091_01
--       rx_module
--          rx_ctrl
--          rx_get_data
--          rx_fifo
--          rx_len_cntr
--       wb_master
--       wb_slave
--       tx_module
--          tx_ctrl
--          tx_put_data
--          tx_compl_timeout
--          tx_fifo_data
--          tx_fifo_header
--       error
--          err_fifo
-- *     init
--       interrupt_core
--       interrupt_wb
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
library ieee;
use ieee.std_logic_1164.all;

entity init is
   port(
      core_clk      : in  std_logic;                                             -- synchronous to core_clk from hard IP core
      clk           : in  std_logic;
      rst           : in  std_logic;
      
      -- IP core
      tl_cfg_add    : in  std_logic_vector(3 downto 0);
      tl_cfg_ctl    : in  std_logic_vector(31 downto 0);
      tl_cfg_ctl_wr : in  std_logic;
      tl_cfg_sts    : in  std_logic_vector(52 downto 0);
      tl_cfg_sts_wr : in  std_logic;
      
      -- interrupt module
      cfg_msicsr    : out std_logic_vector(15 downto 0);
      
      -- Tx Module
      bus_dev_func  : out std_logic_vector(15 downto 0);
      max_read      : out std_logic_vector(2 downto 0);
      max_payload   : out std_logic_vector(2 downto 0)
   );
end entity init;

-- ****************************************************************************

architecture init_arch of init is

-- internal signals -----------------------------------------------------------
signal data             : std_logic_vector(15 downto 0);
signal data_q           : std_logic_vector(15 downto 0);
signal data_qq          : std_logic_vector(15 downto 0);
signal ctl_max          : std_logic;
signal ctl_bus          : std_logic;
signal ctl_msi          : std_logic;
signal ctl_max_q        : std_logic;
signal ctl_max_qq       : std_logic;
signal ctl_max_qqq      : std_logic;
signal ctl_bus_q        : std_logic;
signal ctl_bus_qq       : std_logic;
signal ctl_bus_qqq      : std_logic;
signal ctl_msi_q        : std_logic;
signal ctl_msi_qq       : std_logic;
signal ctl_msi_qqq      : std_logic;
signal bus_dev_func_int : std_logic_vector(15 downto 0);
signal max_read_int     : std_logic_vector(2 downto 0);
signal max_payload_int  : std_logic_vector(2 downto 0);
signal cfg_msicsr_int   : std_logic_vector(15 downto 0);
signal sample           : std_logic;
signal get_sample       : std_logic;
signal tl_cfg_ctl_wr_q  : std_logic;
-------------------------------------------------------------------------------

begin
   cfg_get_info : process(rst, core_clk)
   
   begin
      if(rst = '1') then
         data  <= (others => '0');
         ctl_max <= '0';
         ctl_bus <= '0';
         sample  <= '0';
         tl_cfg_ctl_wr_q <= '0';
      elsif(core_clk'event and core_clk = '1') then
         tl_cfg_ctl_wr_q <= tl_cfg_ctl_wr;
         
         if(((tl_cfg_ctl_wr = '1' and tl_cfg_ctl_wr_q = '0') or (tl_cfg_ctl_wr = '0' and tl_cfg_ctl_wr_q = '1')) 
           and (tl_cfg_add = x"0" or tl_cfg_add = x"D" or tl_cfg_add = x"F") ) then
            sample <= '1';
         elsif(sample = '1') then
            sample <= '0';
         end if;
         -- store values due to appropriate tl_cfg cycle represented by tl_cfg_add
         -- if(tl_cfg_add = x"0") then
         if(tl_cfg_add = x"0" and sample = '1') then
            ctl_max <= '1';
            data <= tl_cfg_ctl(31 downto 16);
         elsif(tl_cfg_add /= x"0") then
            ctl_max <= '0';
         end if;
         
         -- if(tl_cfg_add = x"D") then
         if(tl_cfg_add = x"D" and sample = '1') then
            ctl_msi <= '1';
            data <= tl_cfg_ctl(15 downto 0);
         elsif(tl_cfg_add /= x"D") then
            ctl_msi <= '0';
         end if;
         
         -- if(tl_cfg_add = x"F") then
         if(tl_cfg_add = x"F" and sample = '1') then
            ctl_bus <= '1';
            data <= tl_cfg_ctl(15 downto 0);
         elsif(tl_cfg_add /= x"F") then
            ctl_bus <= '0';
         end if;
      end if;
      
   end process cfg_get_info;
-------------------------------------------------------------------------------
   
   cfg_put_info : process(rst, clk)
   
   begin
      if(rst = '1') then
         bus_dev_func    <= (others => '0');
         max_read        <= (others => '0');
         max_payload     <= (others => '0');
         cfg_msicsr      <= (others => '0');
         data_q          <= (others => '0');
         data_qq         <= (others => '0');
         ctl_max_q       <= '0';
         ctl_max_qq      <= '0';
         ctl_max_qqq     <= '0';
         ctl_bus_q       <= '0';
         ctl_bus_qq      <= '0';
         ctl_bus_qqq     <= '0';
         ctl_msi_q       <= '0';
         ctl_msi_qq      <= '0';
         ctl_msi_qqq     <= '0';
         get_sample      <= '0';
      elsif(clk'event and clk = '1') then
            data_q    <= data;
            data_qq   <= data_q;
            ctl_max_q  <= ctl_max;
            ctl_max_qq <= ctl_max_q;
            ctl_max_qqq <= ctl_max_qq;
            ctl_bus_q  <= ctl_bus;
            ctl_bus_qq <= ctl_bus_q;
            ctl_bus_qqq <= ctl_bus_qq;
            ctl_msi_q  <= ctl_msi;
            ctl_msi_qq <= ctl_msi_q;
            ctl_msi_qqq <= ctl_msi_qq;
            
            if((ctl_max_qq = '1' and ctl_max_qqq = '0') or (ctl_bus_qq = '1' and ctl_bus_qqq = '0') or (ctl_msi_qq = '1' and ctl_msi_qqq = '0')
              ) then
               get_sample <= '1';
            elsif(get_sample = '1') then
               get_sample <= '0';
            end if;
            
            -- propagate stored values to the other clock domain modules
            if(ctl_max_qq = '1' and get_sample = '1') then
               max_payload  <= data_qq(7 downto 5);
               max_read     <= data_qq(14 downto 12);
            end if;
            
            -- hard IP stores bus and device number but for PCIe packets, the function number must be included
            -- thus shift function number = 000 into signal
            if(ctl_bus_qq = '1' and get_sample = '1') then
               bus_dev_func <= data_qq(12 downto 0) & "000";
            end if;
            
            if(ctl_msi_qq = '1' and get_sample = '1') then
               cfg_msicsr <= data_qq(15 downto 0);
            end if;
      end if;
   end process cfg_put_info;
-------------------------------------------------------------------------------
end architecture init_arch;
