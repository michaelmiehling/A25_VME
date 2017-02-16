--------------------------------------------------------------------------------
-- Title       : RX length counter
-- Project     : 16z091-01
--------------------------------------------------------------------------------
-- File        : rx_len_cntr.vhd
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 2013-01-23
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6d / ModelSim AE 6.5e sp1
-- Synthesis   :
--------------------------------------------------------------------------------
-- Description :
-- length counter to manage data stored to the RX FIFOs 
--------------------------------------------------------------------------------
-- Hierarchy   :
--    ip_16z091_01
--       rx_module
--          rx_ctrl
--          rx_get_data
--          rx_fifo
-- *        rx_len_cntr
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
use ieee.numeric_std.all;

library work;
use work.src_utils_pkg.all;

entity rx_len_cntr is
   port(
      clk_i           : in  std_logic;
      rst_i           : in  std_logic;

      -- rx_get_data
      load_cntr_val_i : in  std_logic_vector(9 downto 0);

      -- rx_ctrl
      load_cntr_i     : in  std_logic;
      enable_cntr_i   : in  std_logic;
      len2fifo_o      : out std_logic_vector(9 downto 0)
   );
end entity rx_len_cntr;

architecture rx_len_cntr_arch of rx_len_cntr is
-- +----------------------------------------------------------------------------
-- | functions or procedures
-- +----------------------------------------------------------------------------
   -- NONE

-- +----------------------------------------------------------------------------
-- | constants
-- +----------------------------------------------------------------------------
   -- NONE

-- +----------------------------------------------------------------------------
-- | components
-- +----------------------------------------------------------------------------
   -- NONE

-- +----------------------------------------------------------------------------
-- | internal signals
-- +----------------------------------------------------------------------------
signal int_cntr_val : std_logic_vector(9 downto 0);


begin
-- +----------------------------------------------------------------------------
-- | concurrent section
-- +----------------------------------------------------------------------------
   len2fifo_o <= int_cntr_val;


-- +----------------------------------------------------------------------------
-- | process section
-- +----------------------------------------------------------------------------
   cntr_proc : process(rst_i, clk_i)
   begin
      if rst_i = '1' then
        int_cntr_val <= (others => '0');

      elsif clk_i'event and clk_i = '1' then
        -----------------------------------------------
        -- load new value if load_cntr_i is asserted
        -- subtract one if counter is already enabled
        -----------------------------------------------
         if load_cntr_i = '1' then
            if enable_cntr_i = '0' then
              int_cntr_val <= load_cntr_val_i;
            else
              int_cntr_val <= std_logic_vector(unsigned(load_cntr_val_i) - to_unsigned(1,10));
            end if;

        -----------------------------------------------------------
        -- decrement counter as long as enable_cntr_i is set
        -- but stop decrementing as soon as int_cntr_val is zero
        -----------------------------------------------------------
         else
            if int_cntr_val > ZERO_10B and enable_cntr_i = '1' then
              int_cntr_val <= std_logic_vector(unsigned(int_cntr_val) - to_unsigned(1,10));
            elsif int_cntr_val > ZERO_10B and enable_cntr_i = '0' then
              int_cntr_val <= int_cntr_val;
            else
              int_cntr_val <= (others => '0');
            end if;
         end if;
      end if;
   end process cntr_proc; 


-- +----------------------------------------------------------------------------
-- | component instantiation
-- +----------------------------------------------------------------------------
   -- NONE
-------------------------------------------------------------------------------
end architecture rx_len_cntr_arch;
