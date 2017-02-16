--------------------------------------------------------------------------------
-- Title       : Module for interrupt generation, synchronized to clk
-- Project     : 16z091-01
--------------------------------------------------------------------------------
-- File        : interrupt_core.vhd
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 15.03.2011
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6a
-- Synthesis   : 
--------------------------------------------------------------------------------
-- Description : 
-- This module will generate both INTA and MSI messages. It will start in INTA
-- mode and then determine if it is allowed to send MSI interrupts by reading
-- the config space. If MSI are allowed, the corresponding number of allocated 
-- requests will be shown.
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
--       init
-- *     interrupt_core
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

entity interrupt_core is
   port(
      clk         : in  std_logic;
      rst         : in  std_logic;
      
      -- IP Core
      app_int_ack : in  std_logic;
      app_msi_ack : in  std_logic;
      app_int_sts : out std_logic;
      app_msi_req : out std_logic;
      app_msi_tc  : out std_logic_vector(2 downto 0);
      app_msi_num : out std_logic_vector(4 downto 0);
      pex_msi_num : out std_logic_vector(4 downto 0);
      
      -- interrupt_wb
      wb_pwr_en   : in  std_logic;
      wb_num_int  : in  std_logic_vector(4 downto 0);
      wb_inter    : in  std_logic;
      ack_ok      : in  std_logic;
      inter_ack   : out std_logic;
      num_allowed : out std_logic_vector(5 downto 0);
      
      -- init
      cfg_msicsr  : in  std_logic_vector(15 downto 0);
      
      -- error
      wb_num_err  : out std_logic
   );
end entity interrupt_core;

-- ****************************************************************************

architecture interrupt_core_arch of interrupt_core is

-- internal signals -----------------------------------------------------------
signal msi_allowed_int : std_logic;
signal msi_allowed_num : std_logic_vector(5 downto 0);
signal ack_int         : std_logic;

-- registers for synchronization:
signal cfg_msicsr_q  : std_logic_vector(15 downto 0);
signal cfg_msicsr_qq : std_logic_vector(15 downto 0);
signal wb_pwr_en_q   : std_logic;
signal wb_pwr_en_qq  : std_logic;
signal wb_num_int_q  : std_logic_vector(4 downto 0);
signal wb_num_int_qq : std_logic_vector(4 downto 0);
signal wb_inter_q    : std_logic;
signal wb_inter_qq   : std_logic;
signal wb_inter_qqq  : std_logic;
signal ack_ok_q      : std_logic;
signal ack_ok_qq     : std_logic;
-------------------------------------------------------------------------------

begin
   num_allowed <= msi_allowed_num;
   
   -- register all input signals
   reg_val : process(rst, clk)
   
   begin
      if(rst = '1') then
         cfg_msicsr_q  <= (others => '0');
         cfg_msicsr_qq <= (others => '0');
         wb_pwr_en_q   <= '0';
         wb_pwr_en_qq  <= '0';
         wb_num_int_q  <= (others => '0');
         wb_num_int_qq <= (others => '0');
         wb_inter_q    <= '0';
         wb_inter_qq   <= '0';
         wb_inter_qqq  <= '0';
         ack_ok_q      <= '0';
         ack_ok_qq     <= '0';
      elsif(clk'event and clk = '1') then
         cfg_msicsr_q  <= cfg_msicsr;
         cfg_msicsr_qq <= cfg_msicsr_q;
         wb_pwr_en_q   <= wb_pwr_en;
         wb_pwr_en_qq  <= wb_pwr_en_q;
         wb_num_int_q  <= wb_num_int;
         wb_num_int_qq <= wb_num_int_q;
         wb_inter_q    <= wb_inter;
         wb_inter_qq   <= wb_inter_q;
         wb_inter_qqq  <= wb_inter_qq;
         ack_ok_q      <= ack_ok;
         ack_ok_qq     <= ack_ok_q;
      end if;
   end process reg_val;
   
   -- fixed value for traffic class
   app_msi_tc <= (others => '0');
-------------------------------------------------------------------------------
   config : process(rst, cfg_msicsr_qq)
   
   begin
      if(rst = '1') then
         msi_allowed_num <= "000000";
         msi_allowed_int <= '0';
      else
         -- set number of allowed vectors according to cfg register settings
         if(cfg_msicsr_qq(0) = '0') then                                               -- MSI not allowed
            msi_allowed_num <= "000000";
            msi_allowed_int <= '0';
         else
            case cfg_msicsr_qq(6 downto 4) is
               when "000" =>
                  msi_allowed_num <= "000001";
                  msi_allowed_int <= '1';
               when "001" =>
                  msi_allowed_num <= "000010";
                  msi_allowed_int <= '1';
               when "010" =>
                  msi_allowed_num <= "000100";
                  msi_allowed_int <= '1';
               when "011" =>
                  msi_allowed_num <= "001000";
                  msi_allowed_int <= '1';
               when "100" =>
                  msi_allowed_num <= "010000";
                  msi_allowed_int <= '1';
               when "101" =>
                  msi_allowed_num <= "100000";
                  msi_allowed_int <= '1';

               -- the following two encodings are specified as reserved by the PCIe base specification and should not be used. Thus they
               -- should not be covered because these statements will never occur.
               -- coverage off
               when "110" =>
                  msi_allowed_num <= "000000";
                  msi_allowed_int <= '0';
               when "111" =>
                  msi_allowed_num <= "000000";
                  msi_allowed_int <= '0';
               when others =>
                  msi_allowed_num <= "000000";
                  msi_allowed_int <= '0';
               -- coverage on
            end case;
         end if;
      end if;
   end process config;
-------------------------------------------------------------------------------
   calc : process(rst, clk)
   
   begin
      if(rst = '1') then
         app_int_sts <= '0';
         app_msi_req <= '0';
         app_msi_num <= (others => '0');
         pex_msi_num <= (others => '0');
         inter_ack   <= '0';
         wb_num_err  <= '0';
         ack_int     <= '0';
      elsif(clk'event and clk = '1') then
         -- pass acknowledge to interrupt_wb module
         -- if app_int_ack is asserted on the next clock
         -- cycle after Deassert_INTA is set then this
         -- fails because ack_int is released too late
         if(app_int_ack = '1' or app_msi_ack = '1') then
            inter_ack <= '1';
            ack_int   <= '1';
         elsif(ack_ok_qq = '1') then
            inter_ack <= '0';
         elsif(wb_inter_qqq = '0') then
            ack_int   <= '0';
         end if;
         
         -- is MSI is acknowledged, reset requesting signals
         if(app_msi_ack = '1') then
            app_msi_num <= (others => '0');
            pex_msi_num <= (others => '0');
         end if;
         
         if(wb_inter_qqq = '1' and msi_allowed_int = '0') then
            app_int_sts <= '1';
         elsif(wb_inter_qqq = '0' and msi_allowed_int = '0') then
            app_int_sts <= '0';
         elsif(wb_inter_qqq = '1' and msi_allowed_int = '1' and app_msi_ack = '0' and ack_int = '0') then
            app_msi_req <= '1';
         elsif(wb_inter_qqq = '1' and msi_allowed_int = '1' and app_msi_ack = '1') then
            app_msi_req <= '0';
         end if;
         
         -- set vector number according to wb_pwr_en_qq
         if(wb_pwr_en_qq = '1' and msi_allowed_int = '1') then
            pex_msi_num <= wb_num_int_qq;
         elsif(wb_pwr_en_qq = '0' and msi_allowed_int = '1') then
            app_msi_num <= wb_num_int_qq;
         end if;
         
         -- set num_error if input vector number exceeds maximum allowed, if msi_allowed_num(5) = '1' then the maximum is allocated
         -- thus a check is not necessary
         if(wb_inter_qqq = '1' and msi_allowed_int = '1' and msi_allowed_num(5) = '0' and wb_num_int_qq >= msi_allowed_num(4 downto 0)) then
            wb_num_err  <= '1';
         else
            wb_num_err  <= '0';
         end if;
      end if;
   end process calc;
-------------------------------------------------------------------------------
end architecture interrupt_core_arch;
