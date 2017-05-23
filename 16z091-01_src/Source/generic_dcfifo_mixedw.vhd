--------------------------------------------------------------------------------
-- Title       : Generic Altera Fifo
-- Project     : PCIe-to-VME bridge
--------------------------------------------------------------------------------
-- File        : generic_dcfifo_mixedw.vhd
-- Author      : Grzegorz Daniluk
-- Email       : grzegorz.daniluk@cern.ch
-- Organization: CERN
-- Created     : 17/05/2017
--------------------------------------------------------------------------------
-- Description : 
-- Generic, parametrized mixed width fifo based on Altera dcfifo.
--------------------------------------------------------------------------------
-- Copyright (c) 2017, CERN
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

library altera_mf;
use altera_mf.altera_mf_components.all;

entity generic_dcfifo_mixedw is
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
end generic_dcfifo_mixedw;

architecture syn of generic_dcfifo_mixedw is
begin

  dcfifo_mixed_widths_component : dcfifo_mixed_widths
    generic map(
      intended_device_family => g_device_family,
      lpm_numwords           => g_fifo_depth,      -- value assigned must comply with this equation
                                                   -- 2^(LPM_WIDTHU -1) < LPM_NUMWORDS <= 2^(LPM_WIDTHU)
      lpm_showahead      => g_showahead,           -- off: normal mode, on: show ahead mode
      lpm_type           => "dcfifo_mixed_widths", -- DON'T CHANGE / FIFO type
      lpm_width          => g_data_width,          -- width for _data_ port
      lpm_widthu         => g_data_widthu,         -- size of write usedw
      lpm_width_r        => g_q_width,             -- width for _q_ port
      lpm_widthu_r       => g_q_widthu,            -- size of read usedw
      overflow_checking  => "ON",                  -- DON'T CHANGE / protection circuit for overflow checking
      rdsync_delaypipe   => 4,                     -- nbr of read synchronization stages, internally reduced by 2 => 2 stages
      read_aclr_synch    => "OFF",
      underflow_checking => "ON",                  -- DON'T CHANGE / protection circuit for underflow checking
      use_eab            => "ON",                  -- off: FIFO implemented in logic, on: FIFO implemented using RAM blocks
      write_aclr_synch   => "OFF",
      wrsync_delaypipe   => 4                      -- nbr of write synchronization stages, internally reduced by 2 => 2 stages
    )
    port map (
      aclr    => aclr,
      data    => data,
      rdclk   => rdclk,
      rdreq   => rdreq,
      wrclk   => wrclk,
      wrreq   => wrreq,
      q       => q,
      rdempty => rdempty,
      wrfull  => wrfull,
      wrusedw => wrusedw);

end syn;
