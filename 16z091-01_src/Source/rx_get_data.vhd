--------------------------------------------------------------------------------
-- Title       : RX data path
-- Project     : 16z091-01
--------------------------------------------------------------------------------
-- File        : rx_get_data.vhd
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 2013-01-24
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6d / ModelSim AE 6.5e sp1
-- Synthesis   :
--------------------------------------------------------------------------------
-- Description :
-- manages RX data path and provides information contained in rx_st_data0
--------------------------------------------------------------------------------
-- Hierarchy   :
--    ip_16z091_01
--       rx_module
--          rx_ctrl
-- *        rx_get_data
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

entity rx_get_data is
   port(
      clk_i             : in  std_logic;
      rst_i             : in  std_logic;
   
      -- IP Core
      rx_st_valid0      : in  std_logic;
      rx_st_data0       : in  std_logic_vector(63 downto 0);
      rx_st_bardec0     : in  std_logic_vector(7 downto 0);
      rx_st_sop0        : in  std_logic;
      
      -- FIFO
      rx_fifo_in_o      : out std_logic_vector(63 downto 0);

      -- tx_ctrl
      tag_nbr_o         : out std_logic_vector(7 downto 0);
      tag_rcvd_o        : out std_logic;
      
      -- rx_ctrl
      len_cntr_val_o    : out std_logic_vector(9 downto 0);

      -- error
      type_fmt_err_o    : out std_logic_vector(1 downto 0);
      
      -- rx_sig_manage
      sop_q_i           : in  std_logic
   );
end entity rx_get_data;

architecture rx_get_data_arch of rx_get_data is

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
signal int_cntr_val_temp : std_logic_vector(9 downto 0);                        -- internal length counter
signal int_len_is_odd    : std_logic;                                           -- =1 if length is odd else 0
signal int_c_wr          : std_logic;                                           -- =0 cpl, =1 write/read
signal int_is_read       : std_logic;                                           -- =1 if transfer is a read, else 0
signal int_aligned       : std_logic;                                           -- =1 if data is QWORD aligned else 0
signal int_tag_rcvd      : std_logic;                                           -- =1 if tag number for last of multiple
                                                                                --    completions is received, else 0

-------------------------------------
-- signals to register port signals
-------------------------------------
signal int_rxstvalid0_q  : std_logic;
signal int_rxstdata0_q   : std_logic_vector(63 downto 0);
signal int_rxstsop0_q    : std_logic;
signal int_sopqi_q       : std_logic;

begin

-- +----------------------------------------------------------------------------
-- | concurrent section
-- +----------------------------------------------------------------------------
   len_cntr_val_o <= int_cntr_val_temp;


-- +----------------------------------------------------------------------------
-- | process section
-- +----------------------------------------------------------------------------
   ------------------------------------------ 
   -- process to register necessary signals
   ------------------------------------------ 
   reg_proc : process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         int_rxstvalid0_q <= '0'; 
         int_rxstdata0_q  <= (others => '0');
         int_rxstsop0_q   <= '0';
         int_sopqi_q      <= '0';
      elsif clk_i'event and clk_i = '1' then
         int_rxstvalid0_q <= rx_st_valid0;
         int_rxstsop0_q   <= rx_st_sop0;
         int_sopqi_q      <= sop_q_i;

         if rx_st_valid0 = '1' then
            int_rxstdata0_q  <= rx_st_data0;
         end if;
      end if;
   end process reg_proc;

   main : process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         rx_fifo_in_o   <= (others => '0');
         tag_nbr_o      <= (others => '0');
         tag_rcvd_o     <= '0';
         type_fmt_err_o <= (others => '0');

         int_c_wr       <= '0';
         int_is_read    <= '0';
         int_tag_rcvd   <= '0';

         int_cntr_val_temp <= (others => '0');
         int_len_is_odd    <= '0';
         int_aligned       <= '0';

      elsif clk_i'event and clk_i = '1' then
         ------------------------------------------------------
         -- tag_rcvd_o must be a registered version of
         -- int_tag_rcvd because the tag nbr for completions
         -- can be stored one clock cycle later than
         -- for memory writes/reads
         ------------------------------------------------------
         tag_rcvd_o <= int_tag_rcvd;

         if rx_st_valid0 = '1' then
            if rx_st_sop0 = '1' then
               int_len_is_odd <= rx_st_data0(0);
               int_aligned    <= int_aligned;

               if rx_st_data0(28 downto 24) = TYPE_IS_CPL then
                  int_c_wr <= '0';

                  -----------------------------------------
                  -- check if this is the last completion
                  -- byte count value must be the same or 
                  -- less than length value *4
                  -----------------------------------------
                  if rx_st_data0(43 downto 32) <= rx_st_data0(9 downto 0) & "00"  then
                     int_tag_rcvd <= '1';
                  else
                     int_tag_rcvd <= '0';
                  end if;
               elsif (rx_st_data0(28 downto 24) = TYPE_IS_MEMORY or rx_st_data0(28 downto 24) = TYPE_IS_IO) then
                  int_c_wr <= '1';
                  tag_nbr_o <= rx_st_data0(47 downto 40);
               end if;

               if rx_st_data0(31 downto 29) = FMT_IS_READ then
                  int_is_read <= '1';
               else
                  int_is_read <= '0';
               end if;

               ---------------------------------------------
               -- check if a type or format error occurred
               -- if I/O length is ok
               -- and if a completion error occurred
               ---------------------------------------------
               case rx_st_data0(31 downto 24) is
                  when "00000000" | "01000000" =>                                -- memory
                     type_fmt_err_o <= (others => '0');
                  when "00000010" | "01000010" =>                                -- I/O
                     if(rx_st_data0(9 downto 0) > "0000000001") then             -- I/O requests must have length = 1
                        type_fmt_err_o <= "01";
                     else
                        type_fmt_err_o <= (others => '0');
                     end if;
                  when "00001010" =>                                             -- completion, no data
                     type_fmt_err_o <= (others => '0');
                  when "01001010" =>                                             -- completion, data
                     type_fmt_err_o <= (others => '0');
                  when "00110000" | "00110001" | "00110010" | "00110011" |       -- message
                       "00110100" | "00110101" | "00110110" | "00110111" | 
                       "01110000" | "01110001" | "01110010" | "01110011" | 
                       "01110100" | "01110101" | "01110110" | "01110111" =>
                     type_fmt_err_o <= (others => '0');
                  when "00100000" | "00000001" | "00100001" | "01001100" |       -- non-posted 
                       "01101100" | "01001101" | "01101101" | "01001110" | 
                       "01101110" =>
                     type_fmt_err_o <= "01";
                  when "01100000" =>                                             --posted
                     type_fmt_err_o <= "10";
                  when others =>
                     type_fmt_err_o <= "11";                                       -- e.g. TLP prefix or TCfg
               end case;

               ------------------------------------------------------------------
               -- calculate the amount of 64bit packets that must be stored to
               -- the FIFO:
               -- -> read length is always 2
               -- -> 2 packets for the header information
               -- -> length value divided by 2 because it represents the amount
               --    of 32bit packets
               -- length = 0 represents 1024DW otherwise as specified by length
               ------------------------------------------------------------------
               if rx_st_data0(31 downto 29) = FMT_IS_READ then
                  int_cntr_val_temp <= std_logic_vector(to_unsigned(2,10));
               elsif rx_st_data0(9 downto 0) = ZERO_10B then
                  int_cntr_val_temp <= std_logic_vector(unsigned('1' & rx_st_data0(9 downto 1)) + to_unsigned(2,10));
               else
                  int_cntr_val_temp <= std_logic_vector(unsigned('0' & rx_st_data0(9 downto 1)) + to_unsigned(2,10));
               end if;
            elsif sop_q_i = '1' then
               -------------------------------------------
               -- reset int_tag_rcvd value one clock cycle
               -- after it was asserted
               -------------------------------------------
               int_tag_rcvd <= '0';

               if int_c_wr = '0' then
                  tag_nbr_o <= rx_st_data0(15 downto 8);
               end if;

               if int_rxstdata0_q(2) = '0' then
                  int_aligned <= '1';
               else
                  int_aligned <= '0';
               end if;

               ----------------------------------------------------------------
               -- set counter value to temp value +1 if length is odd and
               -- data is aligned
               -- otherwise set counter value to temp value
               -- don't change counter for read transactions
               ----------------------------------------------------------------
               if int_is_read = '0' and int_len_is_odd = '1' and rx_st_data0(2) = '0' then
                  int_cntr_val_temp <= std_logic_vector(unsigned(int_cntr_val_temp) + to_unsigned(1,10));
               else
                  int_cntr_val_temp <= int_cntr_val_temp;
               end if;
            else
               int_len_is_odd    <= int_len_is_odd;
               int_cntr_val_temp <= int_cntr_val_temp;
               int_aligned       <= int_aligned;
            end if;
         else
            int_len_is_odd <= int_len_is_odd;
            int_aligned    <= int_aligned;
         end if;

         if int_rxstvalid0_q = '1' and int_rxstsop0_q = '1' then
            int_aligned    <= '0';

            if int_rxstdata0_q(28 downto 24) = TYPE_IS_MEMORY or int_rxstdata0_q(28 downto 24) = TYPE_IS_IO then
               -------------------------------------------------------------------------
               -- data alignment in FIFO for writes or reads
               -- h : header information stored to FIFO
               -- d : data packet stored to FIFO
               -- x : data at this position is invalid (can differ from 0)
               --+---------+--------------+--------------+--------------+--------------+
               --|         | aligned      | aligned      | not aligned  | not aligned  |
               --|         | even length  | odd length   | even length  | odd length   |
               --+---------+--------------+--------------+--------------+--------------+
               --| RX FIFO |    |    |    |    |    |    |    |    |    |    |    |    |
               --|      63 |    |    |    |    |    |    |    |    |    |    |    |    |
               --|     ... | h1 |  x | d1 | h1 |  x |  x | h1 | d0 |  x | h1 | d0 | d2 |
               --|      32 |    |    |    |    |    |    |    |    |    |    |    |    |
               --|---------|----|----|----|----|----|----|----|----|----|----|----|----|
               --|      31 |    |    |    |    |    |    |    |    |    |    |    |    |
               --|     ... | h0 | h2 | d0 | h0 | h2 | d0 | h0 | h2 | d1 | h0 | h2 | d1 |
               --|       0 |    |    |    |    |    |    |    |    |    |    |    |    |
               --+---------+----+----+----+----+----+----+----+----+----+----+----+----+

               -------------------------------------------
               -- store header for write or read to FIFO
               -------------------------------------------
               rx_fifo_in_o(63 downto 54) <= (others => '0');                                       -- R
               rx_fifo_in_o(53 downto 51) <= int_rxstdata0_q(18) & int_rxstdata0_q(13 downto 12);   -- Attr
               rx_fifo_in_o(50 downto 48) <= int_rxstdata0_q(22 downto 20);                         -- TC
               rx_fifo_in_o(47 downto 32) <= int_rxstdata0_q(63 downto 48);                         -- requester ID
               rx_fifo_in_o(31)           <= int_rxstdata0_q(30);                                   -- write flag
               
               if int_rxstdata0_q(28 downto 24) = TYPE_IS_IO then
                  rx_fifo_in_o(30)        <= '1';                                                   -- I/O flag
               else
                  rx_fifo_in_o(30)        <= '0';
               end if;

               rx_fifo_in_o(29)           <= '0';                                                   -- R

               ---------------------------------------
               -- decode and store which BAR was hit
               ---------------------------------------
               case rx_st_bardec0 is
                  when "00000001" =>
                     rx_fifo_in_o(28 downto 26) <= "000";                       -- BAR0 hit
                  when "00000010" =>
                     rx_fifo_in_o(28 downto 26) <= "001";                       -- BAR1 hit
                  when "00000100" =>
                     rx_fifo_in_o(28 downto 26) <= "010";                       -- BAR2 hit
                  when "00001000" =>
                     rx_fifo_in_o(28 downto 26) <= "011";                       -- BAR3 hit
                  when "00010000" =>
                     rx_fifo_in_o(28 downto 26) <= "100";                       -- BAR4 hit
                  when "00100000" =>
                     rx_fifo_in_o(28 downto 26) <= "101";                       -- BAR5 hit
                  when "01000000" =>
                     rx_fifo_in_o(28 downto 26) <= "110";                       -- expansion ROM hit
                  when others =>
                     rx_fifo_in_o(28 downto 26) <= "111";                       -- no BAR hit / reserved
               end case;

               rx_fifo_in_o(25 downto 18) <= int_rxstdata0_q(47 downto 40);     -- tag ID
               rx_fifo_in_o(17 downto 14) <= int_rxstdata0_q(35 downto 32);     -- first DW BE
               rx_fifo_in_o(13 downto 10) <= int_rxstdata0_q(39 downto 36);     -- last DW BE
               rx_fifo_in_o(9 downto 0)   <= int_rxstdata0_q(9 downto 0);       -- length

            elsif int_rxstdata0_q(28 downto 24) = TYPE_IS_CPL then
               -------------------------------------------------------------------------
               -- data alignment in FIFO for completions
               -- h : header information stored to FIFO
               -- d : data packet stored to FIFO
               -- x : data at this position is invalid (can differ from 0)
               --+---------+--------------+--------------+--------------+--------------+
               --|         | aligned      | aligned      | not aligned  | not aligned  |
               --|         | even length  | odd length   | even length  | odd length   |
               --+---------+--------------+--------------+--------------+--------------+
               --| RX FIFO |    |    |    |    |    |    |    |    |    |    |    |    |
               --|      63 |    |    |    |    |    |    |    |    |    |    |    |    |
               --|     ... |  x |  x | d1 |  x |  x |  x |  x | d0 |  x |  x | d0 | d2 |
               --|      32 |    |    |    |    |    |    |    |    |    |    |    |    |
               --|---------|----|----|----|----|----|----|----|----|----|----|----|----|
               --|      31 |    |    |    |    |    |    |    |    |    |    |    |    |
               --|     ... | h0 |  x | d0 | h0 |  x | d0 | h0 |  x | d1 | h0 |  x | d1 |
               --|       0 |    |    |    |    |    |    |    |    |    |    |    |    |
               --+---------+----+----+----+----+----+----+----+----+----+----+----+----+

               ----------------------------------------
               -- store header for completion to FIFO
               ----------------------------------------
               rx_fifo_in_o(63 downto 22) <= (others => '0');                   -- R
               rx_fifo_in_o(21 downto 10) <= int_rxstdata0_q(43 downto 32);     -- byte count
               rx_fifo_in_o(9 downto 0) <= int_rxstdata0_q(9 downto 0);         -- length
            end if;

         elsif int_rxstvalid0_q = '1' and int_sopqi_q = '1' then
            rx_fifo_in_o <= int_rxstdata0_q;                                    -- address and D0 or R

         elsif int_rxstvalid0_q = '1' then
            rx_fifo_in_o   <= int_rxstdata0_q;
         end if;
      end if;
   end process main;


-- +----------------------------------------------------------------------------
-- | component instantiation
-- +----------------------------------------------------------------------------
   -- NONE

-------------------------------------------------------------------------------
end architecture rx_get_data_arch;
