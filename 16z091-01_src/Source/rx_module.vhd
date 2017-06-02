--------------------------------------------------------------------------------
-- Title       : RX module v2
-- Project     : 16z091-01
--------------------------------------------------------------------------------
-- File        : rx_module.vhd
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 2013-01-23
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6d / ModelSim AE 6.5e sp1
-- Synthesis   :
--------------------------------------------------------------------------------
-- Description :
-- combines modules rx_get_data.vhd, rx_ctrl.vhd and 2 FIFO's
-- to calculate valid values for RX_FIFO_DEPTH refer to ug_fifo.pdf page 9
--------------------------------------------------------------------------------
-- Hierarchy   :
--    ip_16z091_01
-- *     rx_module
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

entity rx_module is
   generic(
      DEVICE_FAMILY      : string := "unused";
      READY_LATENCY      : natural := 2;                                         -- only specify values between 0 and 2
      FIFO_MAX_USEDW     : std_logic_vector(9 downto 0) := "1111111001";         -- = 1017 DW;
                                                                                 -- set this value to "1111111111" - (READY_LATENCY + 1)
      RX_FIFO_DEPTH      : natural := 1024;                                      -- valid values are: 2^(RX_LPM_WIDTHU-1) < RX_FIFO_DEPTH <= 2^(RX_LPM_WIDTHU)
      RX_LPM_WIDTHU      : natural := 10
      
   );
   port(
      clk                  : in  std_logic;
      wb_clk               : in  std_logic;
      rst                  : in  std_logic;
                           
      -- IP Core           
      rx_st_data0          : in  std_logic_vector(63 downto 0);
      rx_st_err0           : in  std_logic;
      rx_st_valid0         : in  std_logic;
      rx_st_sop0           : in  std_logic;
      rx_st_eop0           : in  std_logic;
      rx_st_be0            : in  std_logic_vector(7 downto 0);
      rx_st_bardec0        : in  std_logic_vector(7 downto 0);
      rx_st_mask0          : out std_logic;
      rx_st_ready0         : out std_logic;
      
      -- FIFO
      rx_fifo_c_rd_enable  : in  std_logic;
      rx_fifo_wr_rd_enable : in  std_logic;
      rx_fifo_c_empty      : out std_logic;
      rx_fifo_wr_empty     : out std_logic;
      rx_fifo_c_out        : out std_logic_vector(31 downto 0);
      rx_fifo_wr_out       : out std_logic_vector(31 downto 0);
      
      -- Tx Module
      rx_tag_nbr           : out std_logic_vector(7 downto 0);
      rx_tag_rcvd          : out std_logic;
      
      -- error
      rx_type_fmt_err      : out std_logic_vector(1 downto 0);
      rx_ecrc_err          : out std_logic;
      
      -- debug port
      rx_debug_out         : out std_logic_vector(3 downto 0)
   );
end entity rx_module;

architecture rx_module_arch of rx_module is

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
component rx_ctrl
   port(
      clk_i               : in  std_logic;
      rst_i               : in  std_logic;
      
      -- IP Core
      rx_st_err0          : in  std_logic;
      rx_st_valid0        : in  std_logic;
      rx_st_sop0          : in  std_logic;
      rx_st_eop0          : in  std_logic;
      rx_st_be0           : in  std_logic_vector(7 downto 0);
      tlp_type_i          : in  std_logic_vector(4 downto 0);
      tlp_fmt_i           : in  std_logic_vector(2 downto 0);
      
      -- FIFO
      rx_fifo_c_enable_o  : out std_logic;
      rx_fifo_wr_enable_o : out std_logic;
      
      -- rx_sig_manage
      sop_q_i             : in  std_logic;
      fifo_action_done_o  : out std_logic;

      -- rx_get_data
      len_cntr_val_i      : in  std_logic_vector(9 downto 0)
   );
end component;

component rx_get_data
   port(
      clk_i          : in  std_logic;
      rst_i          : in  std_logic;
      
      -- IP Core
      rx_st_valid0   : in  std_logic;
      rx_st_data0    : in  std_logic_vector(63 downto 0);
      rx_st_bardec0  : in  std_logic_vector(7 downto 0);
      rx_st_sop0     : in  std_logic;
      
      -- FIFO
      rx_fifo_in_o   : out std_logic_vector(63 downto 0);

      -- tx_ctrl
      tag_nbr_o      : out std_logic_vector(7 downto 0);
      tag_rcvd_o     : out std_logic;
      
      -- rx_ctrl
      len_cntr_val_o : out std_logic_vector(9 downto 0);
    
      -- error
      type_fmt_err_o : out std_logic_vector(1 downto 0);

      -- rx_sig_manage
      sop_q_i        : in  std_logic
   );
end component;

component generic_dcfifo_mixedw
  generic (
    g_device_family : string  := "Cyclone IV GX";
    g_fifo_depth    : natural := 32;
    g_data_width    : natural := 32;
    g_data_widthu   : natural := 5;
    g_q_width       : natural := 64;
    g_q_widthu      : natural := 4;
    g_showahead     : string  := "OFF");
  port (
    aclr    : in  std_logic := '0';
    data    : in  std_logic_vector (g_data_width-1 downto 0);
    rdclk   : in  std_logic ;
    rdreq   : in  std_logic ;
    wrclk   : in  std_logic ;
    wrreq   : in  std_logic ;
    q       : out std_logic_vector (g_q_width-1 downto 0);
    rdempty : out std_logic ;
    wrfull  : out std_logic ;
    wrusedw : out std_logic_vector (g_data_widthu-1 downto 0));
end component;

-- +----------------------------------------------------------------------------
-- | internal signals
-- +----------------------------------------------------------------------------
-- rx_ctrl and rx_get_data connection signals
signal int_len_cntr_val       : std_logic_vector(9 downto 0);
signal int_fifo_action_done   : std_logic;

-- FIFO signals
signal int_c_wr_enable        : std_logic;
signal int_c_wr_full          : std_logic;
signal int_rx_wrusedw_c       : std_logic_vector(RX_LPM_WIDTHU-1 downto 0);
signal int_rx_wrusedw_c_temp  : std_logic_vector(9 downto 0);
signal int_rx_fifo_c_usedw    : std_logic_vector(9 downto 0);

signal int_wr_wr_enable       : std_logic;
signal int_wr_wr_full         : std_logic;
signal int_rx_wrusedw_wr      : std_logic_vector(RX_LPM_WIDTHU-1 downto 0);
signal int_rx_wrusedw_wr_temp : std_logic_vector(9 downto 0);
signal int_rx_fifo_wr_usedw   : std_logic_vector(9 downto 0);

signal int_rx_fifo_data       : std_logic_vector(63 downto 0);

-- signals for signal management process
signal int_ready : std_logic;
signal int_sop   : std_logic;
signal int_err   : std_logic;
signal int_sop_q : std_logic;
signal int_tlp_type : std_logic_vector(4 downto 0);
signal int_tlp_fmt  : std_logic_vector(2 downto 0);

-- define some aliases for easier handling
alias rx_data0_type is rx_st_data0(28 downto 24);
alias rx_data0_fmt  is rx_st_data0(31 downto 29);

-- debug signals: none


begin
-- +----------------------------------------------------------------------------
-- | concurrent section
-- +----------------------------------------------------------------------------
   rx_st_mask0  <= '0';
   rx_st_ready0 <= int_ready;

   int_rx_wrusedw_c_temp  <= std_logic_vector(to_unsigned(to_integer(unsigned(int_rx_wrusedw_c)),10));
   int_rx_wrusedw_wr_temp <= std_logic_vector(to_unsigned(to_integer(unsigned(int_rx_wrusedw_wr)),10));
   int_rx_fifo_c_usedw    <= int_rx_wrusedw_c_temp;
   int_rx_fifo_wr_usedw   <= int_rx_wrusedw_wr_temp;

-- +----------------------------------------------------------------------------
-- | process section
-- +----------------------------------------------------------------------------
   -- registers to remembe the type and fmt for the last received TLP
   process(rst, clk)
   begin
     if rising_edge(clk) then
       if rst = '1' then
         int_tlp_type <= (others=>'0');
       elsif (rx_st_valid0 = '1' and rx_st_sop0 = '1') then
         int_tlp_type <= rx_data0_type;
       end if;
     end if;
   end process;

   process(rst, clk)
   begin
     if rising_edge(clk) then
       if rst = '1' then
         int_tlp_fmt <= (others=>'0');
       elsif (rx_st_valid0 = '1' and rx_st_sop0 = '1') then
         int_tlp_fmt <= rx_data0_fmt;
       end if;
     end if;
   end process;


   rx_sig_manage : process(rst, clk)
   begin
      if rst = '1' then
         int_ready <= '0';
         int_sop   <= '0';
         int_err   <= '0';
         int_sop_q <= '0';

      elsif clk'event and clk = '1' then
         ------------------------------
         -- manage registered signals
         ------------------------------
         int_sop_q <= rx_st_sop0;

         --------------------------------------
         -- signal ECRC error to error module
         --------------------------------------
         if rx_st_err0 = '1' and int_err = '0' then
            rx_ecrc_err <= '1';
         else
            rx_ecrc_err <= '0';
         end if;

         -------------------------------------------------------
         -- if an error state occured reset ready signal 
         --    until rx_ctrl has finished processing the error
         -- if the FIFOs are not full assert ready
         -- else deassert it until the FIFOs are not full
         -------------------------------------------------------
         if ((int_err = '1' or rx_st_err0 = '1') and rx_st_eop0 = '1' and rx_st_valid0 = '1') or
            (int_tlp_type = TYPE_IS_CPL and int_rx_fifo_c_usedw >= FIFO_MAX_USEDW) or 
            (int_tlp_type /= TYPE_IS_CPL and int_rx_fifo_wr_usedw >= FIFO_MAX_USEDW) then

            int_ready <= '0';

         elsif int_err = '0' and (
            (int_tlp_type = TYPE_IS_CPL and int_rx_fifo_c_usedw < FIFO_MAX_USEDW and int_c_wr_full = '0') or
            (int_tlp_type /= TYPE_IS_CPL and int_rx_fifo_wr_usedw < FIFO_MAX_USEDW and int_wr_wr_full = '0') 
         ) then
            
            int_ready <= '1';
         end if;

         -----------------------------------------------------------------
         -- reset error flag if rx_ctrl has finished working on the fifo
         -- set error flag if error ocurs during transmission
         -- otherwise keep error flag value
         -----------------------------------------------------------------
         if int_fifo_action_done = '1' then
            int_err <= '0';
         elsif rx_st_err0 = '1' and rx_st_valid0 = '1' then
            int_err <= '1';
         else
            int_err <= int_err;
         end if;

         if rx_st_valid0 = '1' and rx_st_eop0 = '1' then
            int_sop      <= '0';
         elsif rx_st_valid0 = '1' and rx_st_sop0 = '1' then
            int_sop      <= '1';
         else
            int_sop      <= int_sop;
         end if;
      end if;
   end process rx_sig_manage;


-- +----------------------------------------------------------------------------
-- | component instantiation
-- +----------------------------------------------------------------------------
   rx_ctrl_comp : rx_ctrl
      port map(
         clk_i               => clk,
         rst_i               => rst,
         
         -- Hard IP
         rx_st_err0          => rx_st_err0,
         rx_st_valid0        => rx_st_valid0,
         rx_st_sop0          => rx_st_sop0,
         rx_st_eop0          => rx_st_eop0,
         rx_st_be0           => rx_st_be0,
         tlp_type_i          => rx_data0_type,
         tlp_fmt_i           => rx_data0_fmt,
         
         -- FIFO
         rx_fifo_c_enable_o  => int_c_wr_enable,
         rx_fifo_wr_enable_o => int_wr_wr_enable,

         -- rx_sig_manage
         sop_q_i             => int_sop_q,
         fifo_action_done_o  => int_fifo_action_done,

         -- rx_get_data
         len_cntr_val_i      => int_len_cntr_val
      );
      
   rx_get_data_comp : rx_get_data
      port map(
         clk_i          => clk,
         rst_i          => rst,
         
         -- Hard IP
         rx_st_valid0   => rx_st_valid0,
         rx_st_data0    => rx_st_data0,
         rx_st_bardec0  => rx_st_bardec0,
         rx_st_sop0     => rx_st_sop0,
         
         -- FIFO
         rx_fifo_in_o   => int_rx_fifo_data,

         -- tx_ctrl
         tag_nbr_o      => rx_tag_nbr,
         tag_rcvd_o     => rx_tag_rcvd,
         
         -- rx_ctrl
         len_cntr_val_o => int_len_cntr_val,

         -- error
         type_fmt_err_o => rx_type_fmt_err,

         -- rx_sig_manage
         sop_q_i        => int_sop_q
 
      );
      
   c_fifo_comp : generic_dcfifo_mixedw
    generic map (
      g_device_family => DEVICE_FAMILY,
      g_fifo_depth    => RX_FIFO_DEPTH,
      g_data_width    => 64,
      g_data_widthu   => RX_LPM_WIDTHU,
      g_q_width       => 32,
      g_q_widthu      => RX_LPM_WIDTHU+1,
      g_showahead     => "ON")
    port map (
      aclr    => rst,
      data    => int_rx_fifo_data,
      rdclk   => wb_clk,
      rdreq   => rx_fifo_c_rd_enable,
      wrclk   => clk,
      wrreq   => int_c_wr_enable,
      q       => rx_fifo_c_out,
      rdempty => rx_fifo_c_empty,
      wrfull  => int_c_wr_full,
      wrusedw => int_rx_wrusedw_c);

   wr_fifo_comp : generic_dcfifo_mixedw
    generic map (
      g_device_family => DEVICE_FAMILY,
      g_fifo_depth    => RX_FIFO_DEPTH,
      g_data_width    => 64,
      g_data_widthu   => RX_LPM_WIDTHU,
      g_q_width       => 32,
      g_q_widthu      => RX_LPM_WIDTHU+1,
      g_showahead     => "OFF")
    port map (
      aclr    => rst,
      data    => int_rx_fifo_data,
      rdclk   => wb_clk,
      rdreq   => rx_fifo_wr_rd_enable,
      wrclk   => clk,
      wrreq   => int_wr_wr_enable,
      q       => rx_fifo_wr_out,
      rdempty => rx_fifo_wr_empty,
      wrfull  => int_wr_wr_full,
      wrusedw => int_rx_wrusedw_wr);
   
   -------------------------
   -- manage debug signals
   -------------------------
   rx_debug_out <= (others => '0');

-------------------------------------------------------------------------------
end architecture rx_module_arch;
