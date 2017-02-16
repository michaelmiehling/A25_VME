--------------------------------------------------------------------------------
-- Title       : Tx Module
-- Project     : 16z091-01
--------------------------------------------------------------------------------
-- File        : tx_module.vhd
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 13.12.2010
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6a / ModelSim AE 6.5e sp1
-- Synthesis   : 
--------------------------------------------------------------------------------
-- Description : 
-- combines the modules tx_put_data, tx_compl_timeout and tx_ctrl
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
-- *     tx_module
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tx_module is
   generic(
      DEVICE_FAMILY        : string  := "unused";
      TX_HEADER_FIFO_DEPTH : natural := 32;                                      -- valid values are: 2^(TX_HEADER_LPM_WIDTHU-1) < TX_HEADER_FIFO_DEPTH <= 2^(TX_HEADER_LPM_WIDTHU) 
      TX_HEADER_LPM_WIDTHU : natural := 5;
      TX_DATA_FIFO_DEPTH   : natural := 1024;                                    -- valid values are: 2^(TX_DATA_LPM_WIDTHU-1) < TX_DATA_FIFO_DEPTH <= 2^(TX_DATA_LPM_WIDTHU) 
      TX_DATA_LPM_WIDTHU   : natural := 10
   );
   port(
      clk                    : in  std_logic;
      rst                    : in  std_logic;
      wb_clk                 : in  std_logic;
      wb_rst                 : in  std_logic;
      clk_500                : in  std_logic;                                    -- 500 Hz clock
      
      -- IP Core
      tx_st_ready0           : in  std_logic;
      tx_fifo_full0          : in  std_logic;
      tx_fifo_empty0         : in  std_logic;
      tx_fifo_rdptr0         : in  std_logic_vector(3 downto 0);
      tx_fifo_wrptr0         : in  std_logic_vector(3 downto 0);
      pme_to_sr              : in  std_logic;
      tx_st_err0             : out std_logic;
      tx_st_valid0           : out std_logic;
      tx_st_sop0             : out std_logic;
      tx_st_eop0             : out std_logic;
      tx_st_data0            : out std_logic_vector(63 downto 0);
      pme_to_cr              : out std_logic;
      
      -- Rx Module
      rx_tag_nbr             : in  std_logic_vector(7 downto 0);
      rx_tag_rcvd            : in  std_logic;
      
      -- Wishbone Master
      tx_fifo_c_data_clr     : in  std_logic;
      tx_fifo_c_head_clr     : in  std_logic;
      tx_fifo_c_head_enable  : in  std_logic;
      tx_fifo_c_data_enable  : in  std_logic;
      tx_fifo_c_head_in      : in  std_logic_vector(31 downto 0);
      tx_fifo_c_data_in      : in  std_logic_vector(31 downto 0);
      tx_fifo_c_head_full    : out std_logic;
      tx_fifo_c_data_full    : out std_logic;
      tx_fifo_c_data_usedw   : out std_logic_vector(9 downto 0);
      
      -- Wishbone Slave
      tx_fifo_wr_head_clr    : in  std_logic;
      tx_fifo_wr_head_enable : in  std_logic;
      tx_fifo_wr_head_in     : in  std_logic_vector(31 downto 0);
      tx_fifo_w_data_clr     : in  std_logic;
      tx_fifo_w_data_enable  : in  std_logic;
      tx_fifo_w_data_in      : in  std_logic_vector(31 downto 0);
      tx_fifo_wr_head_full   : out std_logic;
      tx_fifo_w_data_full    : out std_logic;
      tx_fifo_w_data_usedw   : out std_logic_vector(9 downto 0);
      tx_fifo_wr_head_usedw  : out std_logic_vector(4 downto 0);
      
      -- init
      bus_dev_func           : in  std_logic_vector(15 downto 0);
      max_payload            : in  std_logic_vector(2 downto 0);
      
      -- error
      tx_compl_abort         : out std_logic;
      tx_timeout             : out std_logic
   );
end entity tx_module;

-- ****************************************************************************

architecture tx_module_arch of tx_module is

-- internal signals -----------------------------------------------------------
signal aligned_int         : std_logic;
signal data_len_int        : std_logic_vector(9 downto 0);
signal wr_rd_int           : std_logic;                                          -- 0: write, 1: read
signal posted_int          : std_logic;                                          -- 0: non-posted, 1: posted
signal byte_count_int      : std_logic_vector(11 downto 0);
signal orig_addr_int       : std_logic_vector(31 downto 0);
signal tx_tag_nbr_int      : std_logic_vector(7 downto 0);
signal get_header_int      : std_logic;
signal make_header_int     : std_logic;
signal data_enable_int     : std_logic;
signal start_int           : std_logic;
signal start_tag_nbr_int   : std_logic_vector(4 downto 0);
signal c_wrrd_int          : std_logic;
signal completer_id_int    : std_logic_vector(15 downto 0);
signal own_id_int          : std_logic_vector(15 downto 0);
signal get_next_header_int : std_logic;
signal abort_compl_int     : std_logic;
signal send_len_int        : std_logic_vector(9 downto 0);
signal send_addr_int       : std_logic_vector(31 downto 0);
signal payload_loop_int    : std_logic;
signal first_last_full_int : std_logic_vector(1 downto 0);
signal io_write_int        : std_logic;

-- FIFO:
signal tx_fifo_c_head_empty_int   : std_logic;
signal tx_fifo_c_head_enable_int  : std_logic;
signal tx_fifo_c_head_out_int     : std_logic_vector(63 downto 0);
signal tx_fifo_c_data_empty_int   : std_logic;
signal tx_fifo_c_data_enable_int  : std_logic;
signal tx_fifo_c_data_out_int     : std_logic_vector(63 downto 0);
signal tx_fifo_wr_head_empty_int  : std_logic;
signal tx_fifo_wr_head_enable_int : std_logic;
signal tx_fifo_wr_head_out_int    : std_logic_vector(63 downto 0);
signal tx_fifo_w_data_enable_int  : std_logic;
signal tx_fifo_w_data_empty_int   : std_logic;
signal tx_fifo_w_data_out_int     : std_logic_vector(63 downto 0);

signal tx_wrusedw_c     : std_logic_vector (TX_DATA_LPM_WIDTHU-1 downto 0);
signal tx_wrusedw_w     : std_logic_vector (TX_DATA_LPM_WIDTHU-1 downto 0);
signal tx_wrusedw_c_out : std_logic_vector (9 downto 0);
signal tx_wrusedw_w_out : std_logic_vector (9 downto 0);
-------------------------------------------------------------------------------
-- components -----------------------------------------------------------------
component tx_ctrl
   port(
      clk               : in  std_logic;
      rst               : in  std_logic;
      
      -- IP core
      tx_st_ready0      : in  std_logic;
      tx_fifo_full0     : in  std_logic;
      tx_fifo_empty0    : in  std_logic;
      tx_fifo_rdptr0    : in  std_logic_vector(3 downto 0);
      tx_fifo_wrptr0    : in  std_logic_vector(3 downto 0);
      pme_to_sr         : in  std_logic;
      tx_st_err0        : out std_logic;
      tx_st_valid0      : out std_logic;
      tx_st_sop0        : out std_logic;
      tx_st_eop0        : out std_logic;
      pme_to_cr         : out std_logic;
      
      -- FIFO
      tx_c_head_empty   : in  std_logic;
      tx_wr_head_empty  : in  std_logic;
      tx_c_data_empty   : in  std_logic;
      tx_wr_data_empty  : in  std_logic;
      tx_c_head_enable  : out std_logic;
      tx_wr_head_enable : out std_logic;
      tx_c_data_enable  : out std_logic;
      tx_wr_data_enable : out std_logic;
      
      -- tx_put_data
      aligned           : in  std_logic;
      data_len          : in  std_logic_vector(9 downto 0);
      wr_rd             : in  std_logic;                                         -- 0: write, 1: read
      posted            : in  std_logic;                                         -- 0: non-posted, 1: posted
      byte_count        : in  std_logic_vector(11 downto 0);
      io_write          : in  std_logic;                                         -- 0: no I/O write, 1: I/O write thus completion without data
      orig_addr         : in  std_logic_vector(31 downto 0);
      tx_tag_nbr        : out std_logic_vector(7 downto 0);
      get_header        : out std_logic;
      get_next_header   : out std_logic;
      make_header       : out std_logic;
      data_enable       : out std_logic;
      c_wrrd            : out std_logic;
      completer_id      : out std_logic_vector(15 downto 0);
      own_id            : out std_logic_vector(15 downto 0);
      abort_compl       : out std_logic;
      send_len          : out std_logic_vector(9 downto 0);
      send_addr         : out std_logic_vector(31 downto 0);
      payload_loop      : out std_logic;
      first_last_full   : out std_logic_vector(1 downto 0);
      
      -- tx_compl_timeout
      start             : out std_logic;
      start_tag_nbr     : out std_logic_vector(4 downto 0);
      
      -- error
      compl_abort       : out std_logic;
      
      -- init
      bus_dev_func      : in  std_logic_vector(15 downto 0);
      max_payload       : in  std_logic_vector(2 downto 0)
   );
end component;

component tx_put_data
   port(
      clk             : in  std_logic;
      rst             : in  std_logic;
      
      -- IP Core
      tx_st_data0     : out std_logic_vector(63 downto 0);
      
      -- FIFO
      tx_c_head_out   : in  std_logic_vector(63 downto 0);
      tx_c_data_out   : in  std_logic_vector(63 downto 0);
      tx_wr_head_out  : in  std_logic_vector(63 downto 0);
      tx_wr_data_out  : in  std_logic_vector(63 downto 0);
      
      -- tx_ctrl
      data_enable     : in  std_logic;
      tag_nbr         : in  std_logic_vector(7 downto 0);
      req_id          : in  std_logic_vector(15 downto 0);
      completer_id    : in std_logic_vector(15 downto 0);
      c_wrrd          : in  std_logic;                                           -- 0: completion, 1: write/read
      get_header      : in  std_logic;
      get_next_header : in  std_logic;
      make_header     : in  std_logic;
      abort_compl     : in  std_logic;
      send_len        : in  std_logic_vector(9 downto 0);                        -- length of actual packet, stored to header
      send_addr       : in  std_logic_vector(31 downto 0);                       -- address of actual packet, stored to header
      payload_loop    : in  std_logic;                                           -- =0: no loop, =1: loop -> keep most header info
      first_last_full : in  std_logic_vector(1 downto 0);
      data_length     : out std_logic_vector(9 downto 0);
      aligned         : out std_logic;
      wr_rd           : out std_logic;                                           -- 0: write, 1: read
      posted          : out std_logic;                                           -- 0: non-posted, 1: posted
      byte_count      : out std_logic_vector(11 downto 0);
      io_write        : out std_logic;                                           -- 0: no I/O write, 1: I/O write thus completion without data
      orig_addr       : out std_logic_vector(31 downto 0)
   );
end component;

component tx_compl_timeout
   generic(
      CLOCK_TIME   : time := 8 ns;                                               -- clock cycle time
      TIMEOUT_TIME : integer := 25
   );
   port(
      clk         : in  std_logic;
      clk_500     : in  std_logic;                                               -- 500 Hz clock
      rst         : in  std_logic;
      
      -- tx_ctrl
      tag_nbr_in  : in  std_logic_vector(4 downto 0);
      start       : in  std_logic;
      
      -- RxModule
      rx_tag_nbr  : in  std_logic_vector(7 downto 0);
      rx_tag_rcvd : in  std_logic;
      
      -- error
      timeout     : out std_logic
   );
end component;

component tx_header_fifo
   generic(
      DEVICE_FAMILY        : string  := "unused";
      TX_HEADER_FIFO_DEPTH : natural := 32;
      TX_HEADER_LPM_WIDTHU : natural := 5
   );
   port (
      aclr    : in  std_logic  := '0';
      data    : in  std_logic_vector (31 downto 0);
      rdclk   : in  std_logic ;
      rdreq   : in  std_logic ;
      wrclk   : in  std_logic ;
      wrreq   : in  std_logic ;
      q       : out std_logic_vector (63 downto 0);
      rdempty : out std_logic ;
      wrfull  : out std_logic ;
      wrusedw : out std_logic_vector(4 downto 0)
   );
end component;

component tx_data_fifo
   generic(
      DEVICE_FAMILY      : string  := "unused";
      TX_DATA_FIFO_DEPTH : natural := 1024;
      TX_DATA_LPM_WIDTHU : natural := 10
   );
   port(
      aclr    : in  std_logic  := '0';
      data    : in  std_logic_vector (31 downto 0);
      rdclk   : in  std_logic ;
      rdreq   : in  std_logic ;
      wrclk   : in  std_logic ;
      wrreq   : in  std_logic ;
      q       : out std_logic_vector (63 downto 0);
      rdempty : out std_logic ;
      wrfull  : out std_logic ;
      wrusedw : out std_logic_vector (TX_DATA_LPM_WIDTHU-1 downto 0)
   );
end component;
-------------------------------------------------------------------------------

begin
-- instanciate components -----------------------------------------------------
   tx_ctrl_comp : tx_ctrl
      port map(
         clk               => clk,
         rst               => rst,
         
         -- IP core
         tx_st_ready0      => tx_st_ready0,
         tx_fifo_full0     => tx_fifo_full0,
         tx_fifo_empty0    => tx_fifo_empty0,
         tx_fifo_rdptr0    => tx_fifo_rdptr0,
         tx_fifo_wrptr0    => tx_fifo_wrptr0,
         pme_to_sr         => pme_to_sr,
         tx_st_err0        => tx_st_err0,
         tx_st_valid0      => tx_st_valid0,
         tx_st_sop0        => tx_st_sop0,
         tx_st_eop0        => tx_st_eop0,
         pme_to_cr         => pme_to_cr,
         
         -- FIFO
         tx_c_head_empty   => tx_fifo_c_head_empty_int,
         tx_wr_head_empty  => tx_fifo_wr_head_empty_int,
         tx_c_data_empty   => tx_fifo_c_data_empty_int,
         tx_wr_data_empty  => tx_fifo_w_data_empty_int,
         tx_c_head_enable  => tx_fifo_c_head_enable_int,
         tx_wr_head_enable => tx_fifo_wr_head_enable_int,
         tx_c_data_enable  => tx_fifo_c_data_enable_int,
         tx_wr_data_enable => tx_fifo_w_data_enable_int,
         
         -- tx_put_data
         aligned           => aligned_int,
         data_len          => data_len_int,
         wr_rd             => wr_rd_int,                                         -- 0: write, 1: read
         posted            => posted_int,                                        -- 0: non-posted, 1: posted
         byte_count        => byte_count_int,
         io_write          => io_write_int,
         orig_addr         => orig_addr_int,
         tx_tag_nbr        => tx_tag_nbr_int,
         get_header        => get_header_int,
         get_next_header   => get_next_header_int,
         make_header       => make_header_int,
         data_enable       => data_enable_int,
         c_wrrd            => c_wrrd_int,
         completer_id      => completer_id_int,
         own_id            => own_id_int,
         abort_compl       => abort_compl_int,
         send_len          => send_len_int,
         send_addr         => send_addr_int,
         payload_loop      => payload_loop_int,
         first_last_full   => first_last_full_int,
         
         -- tx_compl_timeout
         start             => start_int,
         start_tag_nbr     => start_tag_nbr_int,
         
         -- error
         compl_abort       => tx_compl_abort,
         
         -- init
         bus_dev_func      => bus_dev_func,
         max_payload       => max_payload
      );

    tx_put_data_comp : tx_put_data
      port map(
         clk             => clk,
         rst             => rst,
         
         -- IP Core
         tx_st_data0     => tx_st_data0,
         
         -- FIFO
         tx_c_head_out   => tx_fifo_c_head_out_int,
         tx_c_data_out   => tx_fifo_c_data_out_int,
         tx_wr_head_out  => tx_fifo_wr_head_out_int,
         tx_wr_data_out  => tx_fifo_w_data_out_int,
         
         -- tx_ctrl
         data_enable     => data_enable_int,
         tag_nbr         => tx_tag_nbr_int,
         req_id          => own_id_int,
         completer_id    => completer_id_int,
         c_wrrd          => c_wrrd_int,
         get_header      => get_header_int,
         get_next_header => get_next_header_int,
         make_header     => make_header_int,
         abort_compl     => abort_compl_int,
         send_len        => send_len_int,
         send_addr       => send_addr_int,
         payload_loop    => payload_loop_int,
         first_last_full => first_last_full_int,
         data_length     => data_len_int,
         aligned         => aligned_int,
         wr_rd           => wr_rd_int,
         posted          => posted_int,
         byte_count      => byte_count_int,
         io_write        => io_write_int,
         orig_addr       => orig_addr_int
      );

   tx_compl_timeout_comp : tx_compl_timeout
      generic map(
         CLOCK_TIME   => 8 ns,                                                   -- clock cycle time
         TIMEOUT_TIME => 25
      )
      port map(
         clk         => clk,
         clk_500     => clk_500,
         rst         => rst,
         
         -- tx_ctrl
         tag_nbr_in  => start_tag_nbr_int,
         start       => start_int,
         
         -- RxModule
         rx_tag_nbr  => rx_tag_nbr,
         rx_tag_rcvd => rx_tag_rcvd,
         
         -- error
         timeout     => tx_timeout
      );

   tx_c_header_fifo : tx_header_fifo
      generic map(
         DEVICE_FAMILY        => DEVICE_FAMILY,
         TX_HEADER_FIFO_DEPTH => TX_HEADER_FIFO_DEPTH,       -- 32 
         TX_HEADER_LPM_WIDTHU => TX_HEADER_LPM_WIDTHU
      )
      port map(
         aclr    => tx_fifo_c_head_clr,
         data    => tx_fifo_c_head_in,
         rdclk   => clk,
         rdreq   => tx_fifo_c_head_enable_int,
         wrclk   => wb_clk,
         wrreq   => tx_fifo_c_head_enable,
         q       => tx_fifo_c_head_out_int,
         rdempty => tx_fifo_c_head_empty_int,
         wrfull  => tx_fifo_c_head_full,
         wrusedw => open
      );

   tx_wr_header_fifo : tx_header_fifo
      generic map(
         DEVICE_FAMILY        => DEVICE_FAMILY,
         TX_HEADER_FIFO_DEPTH => TX_HEADER_FIFO_DEPTH,       -- 32
         TX_HEADER_LPM_WIDTHU => TX_HEADER_LPM_WIDTHU
      )
      port map(
         aclr    => tx_fifo_wr_head_clr,
         data    => tx_fifo_wr_head_in,
         rdclk   => clk,
         rdreq   => tx_fifo_wr_head_enable_int,
         wrclk   => wb_clk,
         wrreq   => tx_fifo_wr_head_enable,
         q       => tx_fifo_wr_head_out_int,
         rdempty => tx_fifo_wr_head_empty_int,
         wrfull  => tx_fifo_wr_head_full,
         wrusedw => tx_fifo_wr_head_usedw
      );

   tx_c_data_fifo : tx_data_fifo
      generic map(
         DEVICE_FAMILY      => DEVICE_FAMILY,
         TX_DATA_FIFO_DEPTH => TX_DATA_FIFO_DEPTH,           -- 1024
         TX_DATA_LPM_WIDTHU => TX_DATA_LPM_WIDTHU
      )
      port map(
         aclr    => tx_fifo_c_data_clr,
         data    => tx_fifo_c_data_in,
         rdclk   => clk,
         rdreq   => tx_fifo_c_data_enable_int,
         wrclk   => wb_clk,
         wrreq   => tx_fifo_c_data_enable,
         q       => tx_fifo_c_data_out_int,
         rdempty => tx_fifo_c_data_empty_int,
         wrfull  => tx_fifo_c_data_full,
         wrusedw => tx_wrusedw_c                            -- tx_fifo_c_data_usedw
      );
   
   tx_w_data_fifo : tx_data_fifo
      generic map(
         DEVICE_FAMILY      => DEVICE_FAMILY,
         TX_DATA_FIFO_DEPTH => TX_DATA_FIFO_DEPTH,           -- 1024
         TX_DATA_LPM_WIDTHU => TX_DATA_LPM_WIDTHU
      )
      port map(
         aclr    => tx_fifo_w_data_clr,
         data    => tx_fifo_w_data_in,
         rdclk   => clk,
         rdreq   => tx_fifo_w_data_enable_int,
         wrclk   => wb_clk,
         wrreq   => tx_fifo_w_data_enable,
         q       => tx_fifo_w_data_out_int,
         rdempty => tx_fifo_w_data_empty_int,
         wrfull  => tx_fifo_w_data_full,
         wrusedw => tx_wrusedw_w                            -- tx_fifo_w_data_usedw
      );
-------------------------------------------------------------------------------
   tx_wrusedw_c_out <= conv_std_logic_vector(conv_integer(tx_wrusedw_c),10);
   tx_wrusedw_w_out <= conv_std_logic_vector(conv_integer(tx_wrusedw_w),10);
   tx_fifo_c_data_usedw <= tx_wrusedw_c_out;
   tx_fifo_w_data_usedw <= tx_wrusedw_w_out;
-------------------------------------------------------------------------------
end architecture tx_module_arch;
