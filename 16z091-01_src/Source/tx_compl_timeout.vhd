--------------------------------------------------------------------------------
-- Title       : tx_compl_timeout
-- Project     : 16z091-01
--------------------------------------------------------------------------------
-- File        : tx_compl_timeout.vhd
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 07.12.2010
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6a / ModelSim AE 6.5e sp1
-- Synthesis   :
--------------------------------------------------------------------------------
-- Description :
-- this module controls the tag ID timeout timer, the maximum number of tags
-- is limited to 32
-- at present counters are only started for read requests and reset when the
-- appropriate completion is received
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
-- *        tx_compl_timeout
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

entity tx_compl_timeout is
   generic(
      CLOCK_TIME   : time := 8 ns;                                               -- clock cycle time
      TIMEOUT_TIME : integer := 25                                               -- timeout for one tag ID
   );
   port(
      clk         : in  std_logic;
      clk_500     : in  std_logic;                                               -- 500 Hz clock
      rst         : in  std_logic;
      
      -- tx_ctrl
      tag_nbr_in  : in  std_logic_vector(4 downto 0);
      start       : in  std_logic;
      
      -- Rx Module
      rx_tag_nbr  : in  std_logic_vector(7 downto 0);
      rx_tag_rcvd : in  std_logic;
      
      -- error
      timeout     : out std_logic
   );
end entity tx_compl_timeout;

-- ****************************************************************************

architecture tx_compl_timeout_arch of tx_compl_timeout is

-- internal signals -----------------------------------------------------------
signal clk_500_q      : std_logic;
signal clk_500_qq     : std_logic;
signal clk_500_qqq    : std_logic;
signal rise           : std_logic;

signal timer_overview : std_logic_vector(31 downto 0);

-- initial values assigned due to Quartus II Synthesis critical warning
signal timer_0        : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_1        : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_2        : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_3        : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_4        : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_5        : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_6        : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_7        : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_8        : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_9        : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_10       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_11       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_12       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_13       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_14       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_15       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_16       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_17       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_18       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_19       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_20       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_21       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_22       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_23       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_24       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_25       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_26       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_27       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_28       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_29       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_30       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timer_31       : integer range 25 downto 0 := TIMEOUT_TIME;
signal timeout_int    : std_logic;
-------------------------------------------------------------------------------

begin
   -- sample clock that processes 50ms timeout counting
   clk_500_q   <= '0' when rst = '1' else
                  clk_500 when rising_edge(clk);
   clk_500_qq  <= '0' when rst = '1' else
                  clk_500_q when rising_edge(clk);
   clk_500_qqq <= '0' when rst = '1' else
                  clk_500_qq when rising_edge(clk);
-------------------------------------------------------------------------------
   count : process(clk, rst)
   
   begin
      if(rst = '1') then
         -- ports:
         timeout        <= '0';
         -- signals:
         timer_overview <= (others => '0');
         timer_0        <= TIMEOUT_TIME;
         timer_1        <= TIMEOUT_TIME;
         timer_2        <= TIMEOUT_TIME;
         timer_3        <= TIMEOUT_TIME;
         timer_4        <= TIMEOUT_TIME;
         timer_5        <= TIMEOUT_TIME;
         timer_6        <= TIMEOUT_TIME;
         timer_7        <= TIMEOUT_TIME;
         timer_8        <= TIMEOUT_TIME;
         timer_9        <= TIMEOUT_TIME;
         timer_10       <= TIMEOUT_TIME;
         timer_11       <= TIMEOUT_TIME;
         timer_12       <= TIMEOUT_TIME;
         timer_13       <= TIMEOUT_TIME;
         timer_14       <= TIMEOUT_TIME;
         timer_15       <= TIMEOUT_TIME;
         timer_16       <= TIMEOUT_TIME;
         timer_17       <= TIMEOUT_TIME;
         timer_18       <= TIMEOUT_TIME;
         timer_19       <= TIMEOUT_TIME;
         timer_20       <= TIMEOUT_TIME;
         timer_21       <= TIMEOUT_TIME;
         timer_22       <= TIMEOUT_TIME;
         timer_23       <= TIMEOUT_TIME;
         timer_24       <= TIMEOUT_TIME;
         timer_25       <= TIMEOUT_TIME;
         timer_26       <= TIMEOUT_TIME;
         timer_27       <= TIMEOUT_TIME;
         timer_28       <= TIMEOUT_TIME;
         timer_29       <= TIMEOUT_TIME;
         timer_30       <= TIMEOUT_TIME;
         timer_31       <= TIMEOUT_TIME;
         timeout_int    <= '0';
         rise           <= '0';
      elsif(clk'event and clk = '1') then
         -- when rising edge on clk_500 then enable counting
         if(clk_500_qq = '1' and clk_500_qqq = '0') then
            rise <= '1';
         else
            rise <= '0';
         end if;
         
         -- state of counters (running or not) is administered using the internal register timer_overview
         -- if a timer (diplayed by tag_nbr_in) is started, set equivalent bit in register
         if(start = '1') then                                                 -- start timers
            case tag_nbr_in is
               when "00000" =>
                  timer_overview(0)  <= '1';
               when "00001" =>
                  timer_overview(1)  <= '1';
               when "00010" =>
                  timer_overview(2)  <= '1';
               when "00011" =>
                  timer_overview(3)  <= '1';
               when "00100" =>
                  timer_overview(4)  <= '1';
               when "00101" =>
                  timer_overview(5)  <= '1';
               when "00110" =>
                  timer_overview(6)  <= '1';
               when "00111" =>
                  timer_overview(7)  <= '1';
               when "01000" =>
                  timer_overview(8)  <= '1';
               when "01001" =>
                  timer_overview(9)  <= '1';
               when "01010" =>
                  timer_overview(10) <= '1';
               when "01011" =>
                  timer_overview(11) <= '1';
               when "01100" =>
                  timer_overview(12) <= '1';
               when "01101" =>
                  timer_overview(13) <= '1';
               when "01110" =>
                  timer_overview(14) <= '1';
               when "01111" =>
                  timer_overview(15) <= '1';
               when "10000" =>
                  timer_overview(16) <= '1';
               when "10001" =>
                  timer_overview(17) <= '1';
               when "10010" =>
                  timer_overview(18) <= '1';
               when "10011" =>
                  timer_overview(19) <= '1';
               when "10100" =>
                  timer_overview(20) <= '1';
               when "10101" =>
                  timer_overview(21) <= '1';
               when "10110" =>
                  timer_overview(22) <= '1';
               when "10111" =>
                  timer_overview(23) <= '1';
               when "11000" =>
                  timer_overview(24) <= '1';
               when "11001" =>
                  timer_overview(25) <= '1';
               when "11010" =>
                  timer_overview(26) <= '1';
               when "11011" =>
                  timer_overview(27) <= '1';
               when "11100" =>
                  timer_overview(28) <= '1';
               when "11101" =>
                  timer_overview(29) <= '1';
               when "11110" =>
                  timer_overview(30) <= '1';
               when "11111" =>
                  timer_overview(31) <= '1';
               -- coverage off
               when others =>
                  -- synthesis translate_off
                  report "undecoded case in tag_nbr_in" severity error;
                  -- synthesis translate_on
               -- coverage on
            end case;
         end if;
         
         -- if a tag number is received from rx_module reset according bit in timer_overview register and thus deactivate
         -- the timer
         if(rx_tag_rcvd = '1') then                                           -- clear timers
            case rx_tag_nbr(4 downto 0) is
               when "00000" =>
                  timer_overview(0)  <= '0';
               when "00001" =>
                  timer_overview(1)  <= '0';
               when "00010" =>
                  timer_overview(2)  <= '0';
               when "00011" =>
                  timer_overview(3)  <= '0';
               when "00100" =>
                  timer_overview(4)  <= '0';
               when "00101" =>
                  timer_overview(5)  <= '0';
               when "00110" =>
                  timer_overview(6)  <= '0';
               when "00111" =>
                  timer_overview(7)  <= '0';
               when "01000" =>
                  timer_overview(8)  <= '0';
               when "01001" =>
                  timer_overview(9)  <= '0';
               when "01010" =>
                  timer_overview(10) <= '0';
               when "01011" =>
                  timer_overview(11) <= '0';
               when "01100" =>
                  timer_overview(12) <= '0';
               when "01101" =>
                  timer_overview(13) <= '0';
               when "01110" =>
                  timer_overview(14) <= '0';
               when "01111" =>
                  timer_overview(15) <= '0';
               when "10000" =>
                  timer_overview(16) <= '0';
               when "10001" =>
                  timer_overview(17) <= '0';
               when "10010" =>
                  timer_overview(18) <= '0';
               when "10011" =>
                  timer_overview(19) <= '0';
               when "10100" =>
                  timer_overview(20) <= '0';
               when "10101" =>
                  timer_overview(21) <= '0';
               when "10110" =>
                  timer_overview(22) <= '0';
               when "10111" =>
                  timer_overview(23) <= '0';
               when "11000" =>
                  timer_overview(24) <= '0';
               when "11001" =>
                  timer_overview(25) <= '0';
               when "11010" =>
                  timer_overview(26) <= '0';
               when "11011" =>
                  timer_overview(27) <= '0';
               when "11100" =>
                  timer_overview(28) <= '0';
               when "11101" =>
                  timer_overview(29) <= '0';
               when "11110" =>
                  timer_overview(30) <= '0';
               when "11111" =>
                  timer_overview(31) <= '0';
               -- coverage off
               when others =>
                  -- synthesis translate_off
                  report "undecoded case in rx_tag_nbr" severity warning;
                  -- synthesis translate_on
               -- coverage on
            end case;
         end if;
         
         -- if a timer is set and signal rise is asserted to propagate that enough time has passed
         -- then decrement all active counters
         -- if a counter has reached 0 assert signal timeout and reset timer_overview register
         if(timer_overview(0) = '1' and rise = '1') then
            if(timer_0 > 0) then
               timer_0           <= timer_0 - 1;
            else
               timeout           <= '1';
               timeout_int       <= '1';
               timer_overview(0) <= '0';
            end if;
         elsif(timer_overview(0) = '0') then
            timer_0              <= TIMEOUT_TIME;
         end if;
         if(timer_overview(1) = '1' and rise = '1') then
            if(timer_1 > 0) then
               timer_1           <= timer_1 - 1;
            else
               timeout           <= '1';
               timeout_int       <= '1';
               timer_overview(1) <= '0';
            end if;
         elsif(timer_overview(1) = '0') then
            timer_1        <= TIMEOUT_TIME;
         end if;
         if(timer_overview(2) = '1' and rise = '1') then
            if(timer_2 > 0) then
               timer_2           <= timer_2 - 1;
            else
               timeout           <= '1';
               timeout_int       <= '1';
               timer_overview(2) <= '0';
            end if;
         elsif(timer_overview(2) = '0') then
            timer_2        <= TIMEOUT_TIME;
         end if;
         if(timer_overview(3) = '1' and rise = '1') then
            if(timer_3 > 0) then
               timer_3           <= timer_3 - 1;
            else
               timeout           <= '1';
               timeout_int       <= '1';
               timer_overview(3) <= '0';
            end if;
         elsif(timer_overview(3) = '0') then
            timer_3        <= TIMEOUT_TIME;
         end if;
         if(timer_overview(4) = '1' and rise = '1') then
            if(timer_4 > 0) then
               timer_4           <= timer_4 - 1;
            else
               timeout           <= '1';
               timeout_int       <= '1';
               timer_overview(4) <= '0';
            end if;
         elsif(timer_overview(4) = '0') then
            timer_4        <= TIMEOUT_TIME;
         end if;
         if(timer_overview(5) = '1' and rise = '1') then
            if(timer_5 > 0) then
               timer_5           <= timer_5 - 1;
            else
               timeout           <= '1';
               timeout_int       <= '1';
               timer_overview(5) <= '0';
            end if;
         elsif(timer_overview(5) = '0') then
            timer_5        <= TIMEOUT_TIME;
         end if;
         if(timer_overview(6) = '1' and rise = '1') then
            if(timer_6 > 0) then
               timer_6           <= timer_6 - 1;
            else
               timeout           <= '1';
               timeout_int       <= '1';
               timer_overview(6) <= '0';
            end if;
         elsif(timer_overview(6) = '0') then
            timer_6        <= TIMEOUT_TIME;
         end if;
         if(timer_overview(7) = '1' and rise = '1') then
            if(timer_7 > 0) then
               timer_7           <= timer_7 - 1;
            else
               timeout           <= '1';
               timeout_int       <= '1';
               timer_overview(7) <= '0';
            end if;
         elsif(timer_overview(7) = '0') then
            timer_7        <= TIMEOUT_TIME;
         end if;
         if(timer_overview(8) = '1' and rise = '1') then
            if(timer_8 > 0) then
               timer_8           <= timer_8 - 1;
            else
               timeout           <= '1';
               timeout_int       <= '1';
               timer_overview(8) <= '0';
            end if;
         elsif(timer_overview(8) = '0') then
            timer_8        <= TIMEOUT_TIME;
         end if;
         if(timer_overview(9) = '1' and rise = '1') then
            if(timer_9 > 0) then
               timer_9           <= timer_9 - 1;
            else
               timeout           <= '1';
               timeout_int       <= '1';
               timer_overview(9) <= '0';
            end if;
         elsif(timer_overview(9) = '0') then
            timer_9        <= TIMEOUT_TIME;
         end if;
         if(timer_overview(10) = '1' and rise = '1') then
            if(timer_10 > 0) then
               timer_10           <= timer_10 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(10) <= '0';
            end if;
         elsif(timer_overview(10) = '0') then
            timer_10       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(11) = '1' and rise = '1') then
            if(timer_11 > 0) then
               timer_11           <= timer_11 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(11) <= '0';
            end if;
         elsif(timer_overview(11) = '0') then
            timer_11       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(12) = '1' and rise = '1') then
            if(timer_12 > 0) then
               timer_12           <= timer_12 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(12) <= '0';
            end if;
         elsif(timer_overview(12) = '0') then
            timer_12       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(13) = '1' and rise = '1') then
            if(timer_13 > 0) then
               timer_13           <= timer_13 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(13) <= '0';
            end if;
         elsif(timer_overview(13) = '0') then
            timer_13       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(14) = '1' and rise = '1') then
            if(timer_14 > 0) then
               timer_14           <= timer_14 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(14) <= '0';
            end if;
         elsif(timer_overview(14) = '0') then
            timer_14       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(15) = '1' and rise = '1') then
            if(timer_15 > 0) then
               timer_15           <= timer_15 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(15) <= '0';
            end if;
         elsif(timer_overview(15) = '0') then
            timer_15       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(16) = '1' and rise = '1') then
            if(timer_16 > 0) then
               timer_16           <= timer_16 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(16) <= '0';
            end if;
         elsif(timer_overview(16) = '0') then
            timer_16       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(17) = '1' and rise = '1') then
            if(timer_17 > 0) then
               timer_17           <= timer_17 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(17) <= '0';
            end if;
         elsif(timer_overview(17) = '0') then
            timer_17       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(18) = '1' and rise = '1') then
            if(timer_18 > 0) then
               timer_18           <= timer_18 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(18) <= '0';
            end if;
         elsif(timer_overview(18) = '0') then
            timer_18       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(19) = '1' and rise = '1') then
            if(timer_19 > 0) then
               timer_19           <= timer_19 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(19) <= '0';
            end if;
         elsif(timer_overview(19) = '0') then
            timer_19       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(20) = '1' and rise = '1') then
            if(timer_20 > 0) then
               timer_20           <= timer_20 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(20) <= '0';
            end if;
         elsif(timer_overview(20) = '0') then
            timer_20       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(21) = '1' and rise = '1') then
            if(timer_21 > 0) then
               timer_21           <= timer_21 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(21) <= '0';
            end if;
         elsif(timer_overview(21) = '0') then
            timer_21       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(22) = '1' and rise = '1') then
            if(timer_22 > 0) then
               timer_22           <= timer_22 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(22) <= '0';
            end if;
         elsif(timer_overview(22) = '0') then
            timer_22       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(23) = '1' and rise = '1') then
            if(timer_23 > 0) then
               timer_23           <= timer_23 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(23) <= '0';
            end if;
         elsif(timer_overview(23) = '0') then
            timer_23       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(24) = '1' and rise = '1') then
            if(timer_24 > 0) then
               timer_24           <= timer_24 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(24) <= '0';
            end if;
         elsif(timer_overview(24) = '0') then
            timer_24       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(25) = '1' and rise = '1') then
            if(timer_25 > 0) then
               timer_25           <= timer_25 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(25) <= '0';
            end if;
         elsif(timer_overview(25) = '0') then
            timer_25       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(26) = '1' and rise = '1') then
            if(timer_26 > 0) then
               timer_26           <= timer_26 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(26) <= '0';
            end if;
         elsif(timer_overview(26) = '0') then
            timer_26       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(27) = '1' and rise = '1') then
            if(timer_27 > 0) then
               timer_27           <= timer_27 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(27) <= '0';
            end if;
         elsif(timer_overview(27) = '0') then
            timer_27       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(28) = '1' and rise = '1') then
            if(timer_28 > 0) then
               timer_28           <= timer_28 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(28) <= '0';
            end if;
         elsif(timer_overview(28) = '0') then
            timer_28       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(29) = '1' and rise = '1') then
            if(timer_29 > 0) then
               timer_29           <= timer_29 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(29) <= '0';
            end if;
         elsif(timer_overview(29) = '0') then
            timer_29       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(30) = '1' and rise = '1') then
            if(timer_30 > 0) then
               timer_30           <= timer_30 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(30) <= '0';
            end if;
         elsif(timer_overview(30) = '0') then
            timer_30       <= TIMEOUT_TIME;
         end if;
         if(timer_overview(31) = '1' and rise = '1') then
            if(timer_31 > 0) then
               timer_31           <= timer_31 - 1;
            else
               timeout            <= '1';
               timeout_int        <= '1';
               timer_overview(31) <= '0';
            end if;
         elsif(timer_overview(31) = '0') then
            timer_31       <= TIMEOUT_TIME;
         end if;
         
         if(timeout_int = '1') then
            timeout     <= '0';
            timeout_int <= '0';
         end if;
      end if;
   end process count;
   
-------------------------------------------------------------------------------
end architecture tx_compl_timeout_arch;
