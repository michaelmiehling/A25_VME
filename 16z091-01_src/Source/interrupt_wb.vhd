--------------------------------------------------------------------------------
-- Title       : Module for interrupt generation, synchonized to wb_clk
-- Project     : 16z091-01
--------------------------------------------------------------------------------
-- File        : interrupt_wb.vhd
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
--       interrupt_core
-- *     interrupt_wb
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

entity interrupt_wb is
   port(
      wb_clk             : in  std_logic;
      wb_rst             : in  std_logic;
      
      -- interrupt_core
      inter_ack          : in  std_logic;
      num_allowed        : in  std_logic_vector(5 downto 0);
      wb_pwr_en          : out std_logic;
      wb_num_int         : out std_logic_vector(4 downto 0);
      wb_inter           : out std_logic;
      ack_ok             : out std_logic;
      
      
      -- Wishbone
      wb_int             : in  std_logic;
      wb_pwr_enable      : in  std_logic;                                        -- =1 if wb_int_num should be for power management, else
                                                                                 -- for normal interrupt
      wb_int_num         : in  std_logic_vector(4 downto 0);
      wb_int_ack         : out std_logic;
      wb_int_num_allowed : out std_logic_vector(5 downto 0)                     -- =0 if MSI not allowed, else: nbr. of allocated signals
   );
end entity interrupt_wb;

-- ****************************************************************************

architecture interrupt_wb_arch of interrupt_wb is

-- internal signals -----------------------------------------------------------
signal inter_ack_qqq : std_logic;

-- registers for synchronization:
signal inter_ack_q    : std_logic;
signal inter_ack_qq   : std_logic;
signal num_allowed_q  : std_logic_vector(5 downto 0);
signal num_allowed_qq : std_logic_vector(5 downto 0);
-------------------------------------------------------------------------------

begin
   
   set_val : process(wb_rst,wb_clk)
   
   begin
      if(wb_rst = '1') then
         inter_ack_q        <= '0';
         inter_ack_qq       <= '0';
         num_allowed_q      <= (others => '0');
         num_allowed_qq     <= (others => '0');
         wb_pwr_en          <= '0';
         wb_num_int         <= (others => '0');
         wb_inter           <= '0';
         wb_int_ack         <= '0';
         wb_int_num_allowed <= (others => '0');
         ack_ok             <= '0';
         inter_ack_qqq     <= '0';
      elsif(wb_clk'event and wb_clk = '1') then
         -- register all inputs that need to be registered on rising edge of wb_clk
         inter_ack_q        <= inter_ack;
         inter_ack_qq       <= inter_ack_q;
         inter_ack_qqq      <= inter_ack_qq;
         num_allowed_q      <= num_allowed;
         num_allowed_qq     <= num_allowed_q;
         wb_pwr_en          <= wb_pwr_enable;
         wb_num_int         <= wb_int_num;
         wb_inter           <= wb_int;
         wb_int_num_allowed <= num_allowed_qq;
         ack_ok             <= inter_ack_qq;
         
         -- assert interrupt acknowledge when rising_edge(inter_ack_qq) occured
         if(inter_ack_qq = '1' and inter_ack_qqq = '0') then
            wb_int_ack <= '1';
         else
            wb_int_ack <= '0';
         end if;
      end if;
   end process set_val;
-------------------------------------------------------------------------------
end architecture interrupt_wb_arch;
