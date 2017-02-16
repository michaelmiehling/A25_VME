--------------------------------------------------------------------------------
-- Title       : Error Module
-- Project     : 16z091-01
--------------------------------------------------------------------------------
-- File        : error.vhd
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 03.12.2010
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6a / ModelSim AE 6.5e sp1
-- Synthesis   :
--------------------------------------------------------------------------------
-- Description :
-- errors on RxModule, TxModule or hard IP core are collected here and passed
-- to Wishbone modules through a FIFO
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
-- *     error
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

entity error is
   port(
      clk               : in  std_logic;
      rst               : in  std_logic;
      wb_clk            : in  std_logic;
      wb_rst            : in  std_logic;
      
      -- Rx Module
      rx_tag_id         : in  std_logic_vector(7 downto 0);
      rx_ecrc_err       : in  std_logic;
      rx_type_fmt_err   : in  std_logic_vector(1 downto 0);
      
      -- Tx Module
      tx_compl_abort    : in  std_logic;
      tx_timeout        : in  std_logic;
      
      -- Interrupt
      wb_num_err        : in  std_logic;
      
      -- Wishbone
      error_ecrc_err    : out std_logic;
      error_timeout     : out std_logic;
      error_tag_id      : out std_logic_vector(7 downto 0);
      error_cor_ext_rcv : out std_logic_vector(1 downto 0);
      error_cor_ext_rpl : out std_logic;
      error_rpl         : out std_logic;
      error_r2c0        : out std_logic;
      error_msi_num     : out std_logic;
      
      -- IP Core
      derr_cor_ext_rcv  : in  std_logic_vector(1 downto 0);
      derr_cor_ext_rpl  : in  std_logic;
      derr_rpl          : in  std_logic;
      r2c_err0          : in  std_logic;
      cpl_err           : out std_logic_vector(6 downto 0);
      cpl_pending       : out std_logic
   );
end entity error;

-- ****************************************************************************

architecture error_arch of error is

-- internal signals -----------------------------------------------------------
signal err_fifo_clr       : std_logic;
signal err_fifo_wr_enable : std_logic;
signal err_fifo_in        : std_logic_vector(15 downto 0);
-- uncomment next line when increasing FIFO depth
-- signal err_fifo_full      : std_logic;
signal err_fifo_rd_enable : std_logic;
signal err_fifo_out       : std_logic_vector(15 downto 0);
signal err_fifo_empty     : std_logic;
signal get_value          : std_logic;
signal wb_num_err_q       : std_logic;
signal wb_num_err_qq      : std_logic;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
signal ip_error_in   : std_logic_vector(14 downto 0);
signal ip_error_last : std_logic_vector(14 downto 0) := (others => '0');
-------------------------------------------------------------------------------

-- components -----------------------------------------------------------------
component err_fifo
   port(
      aclr    : in  std_logic;
      data    : in  std_logic_vector (15 downto 0);
      rdclk   : in  std_logic;
      rdreq   : in  std_logic;
      wrclk   : in  std_logic;
      wrreq   : in  std_logic;
      q       : out std_logic_vector (15 downto 0);
      rdempty : out std_logic;
      wrfull  : out std_logic 
   );
end component;
-------------------------------------------------------------------------------

begin
-- instanciate components -----------------------------------------------------
   err_fifo_comp : err_fifo
      port map(
         aclr    => err_fifo_clr,
         data    => err_fifo_in,
         rdclk   => wb_clk,
         rdreq   => err_fifo_rd_enable,
         wrclk   => clk,
         wrreq   => err_fifo_wr_enable,
         q       => err_fifo_out,
         rdempty => err_fifo_empty,
         -- change next line when increasing FIFO depth
         wrfull  => open                                                         -- err_fifo_full
      );

-------------------------------------------------------------------------------
   
   fifo_wr : process(clk, rst)
   
   begin
      if(rst = '1') then
         err_fifo_wr_enable <= '0';
         err_fifo_in        <= (others => '0');
         err_fifo_clr       <= '1';
         ip_error_last      <= (others => '0');

      elsif(clk'event and clk = '1') then
         err_fifo_clr <= '0';
         
         -- store errors if new error occred
         if(ip_error_last /= ip_error_in) then
            err_fifo_wr_enable <= '1';
            err_fifo_in        <= '0' & ip_error_in;
            ip_error_last      <= ip_error_in;
         end if;
         
         -- reset signals
         if(err_fifo_wr_enable = '1') then
            err_fifo_wr_enable <= '0';
            err_fifo_in        <= (others => '0');
         end if;
      end if;
   end process fifo_wr;

-------------------------------------------------------------------------------
   fifo_rd : process(wb_clk, wb_rst)
   
   begin
      if(wb_rst = '1') then
         error_timeout     <= '0';
         error_r2c0        <= '0';
         error_rpl         <= '0';
         error_cor_ext_rpl <= '0';
         error_cor_ext_rcv <= (others => '0');
         error_ecrc_err    <= '0';
         error_tag_id      <= (others => '0');
         error_msi_num     <= '0';
         
         err_fifo_rd_enable <= '0';
         get_value          <= '0';
         wb_num_err_q       <= '0';
         wb_num_err_qq      <= '0';
      elsif(wb_clk'event and wb_clk = '1') then
         -- sample wb_num_err because this is synchronous to clk
         wb_num_err_q  <= wb_num_err;
         wb_num_err_qq <= wb_num_err_q;
         
         -- read values as soon as they appear
         if(err_fifo_empty = '0') then
            err_fifo_rd_enable <= '1';
         end if;
         
         -- reset enable an start analysis of value read from FIFO
         if(err_fifo_rd_enable = '1') then
            err_fifo_rd_enable <= '0';
            get_value          <= '1';
         end if;
         
         -- propagate error signals to outer environment
         if(get_value = '1') then
            get_value         <= '0';
            error_timeout     <= err_fifo_out(14);
            error_r2c0        <= err_fifo_out(13);
            error_rpl         <= err_fifo_out(12);
            error_cor_ext_rpl <= err_fifo_out(11);
            error_cor_ext_rcv <= err_fifo_out(10 downto 9);
            error_ecrc_err    <= err_fifo_out(8);
            error_tag_id      <= err_fifo_out(7 downto 0);
         else
            error_timeout     <= '0';
            error_r2c0        <= '0';
            error_rpl         <= '0';
            error_cor_ext_rpl <= '0';
            error_cor_ext_rcv <= (others => '0');
            error_ecrc_err    <= '0';
            error_tag_id      <= (others => '0');
         end if;
         
         -- propagate error signals to outer environment
         error_msi_num <= wb_num_err_qq;
      end if;
   end process fifo_rd;
-------------------------------------------------------------------------------
   -- capture occuring errors
   ip_error_in(14)          <= '1' when tx_timeout = '1' else '0';
   ip_error_in(13)          <= '1' when r2c_err0 = '1' else '0';
   ip_error_in(12)          <= '1' when derr_rpl = '1' else '0';
   ip_error_in(11)          <= '1' when derr_cor_ext_rpl = '1' else '0';
   ip_error_in(10 downto 9) <= derr_cor_ext_rcv when derr_cor_ext_rcv /= "00" else "00";
   ip_error_in(8)           <= '1' when rx_ecrc_err = '1' else '0';
   ip_error_in(7 downto 0)  <= rx_tag_id when rx_ecrc_err = '1' else (others => '0');
   
   cpl_err(6) <=  '0';
   cpl_err(5) <=  '0' when rst = '1' else
                  '1' when rx_type_fmt_err = "01" else
                  '0';
   cpl_err(4) <=  '0' when rst = '1' else
                  '1' when rx_type_fmt_err = "10" else
                  '0';
   cpl_err(3) <=  '0';
   cpl_err(2) <=  '0' when rst = '1' else
                  '1' when tx_compl_abort = '1' else
                  '0';
   cpl_err(1 downto 0) <= (others => '0');
   cpl_pending <= '0';
-------------------------------------------------------------------------------
end architecture error_arch;
