--------------------------------------------------------------------------------
-- Title       : RX control state machine
-- Project     : 16z091-01
--------------------------------------------------------------------------------
-- File        : rx_ctrl.vhd
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 2013-01-24
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6d / ModelSim AE 6.5e sp1
-- Synthesis   :
--------------------------------------------------------------------------------
-- Description :
-- RX path state machine for Avalon ST and FIFO control 
--------------------------------------------------------------------------------
-- Hierarchy   :
--    ip_16z091_01
--       rx_module
-- *        rx_ctrl
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

library work;
use work.src_utils_pkg.all;

entity rx_ctrl is
   port(
      clk_i               : in  std_logic;
      rst_i               : in  std_logic;

      -- Hard IP
      rx_st_err0          : in  std_logic;
      rx_st_valid0        : in  std_logic;
      rx_st_sop0          : in  std_logic;
      rx_st_eop0          : in  std_logic;
      rx_st_be0           : in  std_logic_vector(7 downto 0);
      tlp_type_i          : in  std_logic_vector(4 downto 0);
      tlp_fmt_i           : in  std_logic_vector(2 downto 0);

      -- RX FIFO
      rx_fifo_c_enable_o  : out std_logic;
      rx_fifo_wr_enable_o : out std_logic;
   
      -- rx_sig_manage
      sop_q_i             : in  std_logic;
      fifo_action_done_o  : out std_logic;

      -- rx_get_data
      len_cntr_val_i      : in  std_logic_vector(9 downto 0)
   );
end entity rx_ctrl;

architecture rx_ctrl_arch of rx_ctrl is
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
component rx_len_cntr
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
end component;


-- +----------------------------------------------------------------------------
-- | internal signals
-- +----------------------------------------------------------------------------
type fsm_state is (WAITING, IDLE, WRRD, CPL, ECRC_ERROR, LOAD_CNTR, FALSE_PACKET);
signal state   : fsm_state; 

signal int_fifo_c_en      : std_logic;
signal int_fifo_wr_en     : std_logic;
signal int_len2fifo_wr    : std_logic_vector(9 downto 0);
signal int_len2fifo_c     : std_logic_vector(9 downto 0);
signal int_enable_c_cntr  : std_logic;
signal int_enable_wr_cntr : std_logic;
signal int_load_c_cntr    : std_logic;
signal int_load_wr_cntr   : std_logic;

signal int_c_wr           : std_logic;
signal int_sop            : std_logic;
signal int_false_packet   : std_logic;

signal int_rxstvalid0_q   : std_logic;
signal int_rxstsop0_q     : std_logic;
signal int_rxsteop0_q     : std_logic;
signal int_rxsteop0_qq    : std_logic;

begin
-- +----------------------------------------------------------------------------
-- | concurrent section
-- +----------------------------------------------------------------------------
   rx_fifo_c_enable_o  <= int_fifo_c_en;
   rx_fifo_wr_enable_o <= int_fifo_wr_en;


-- +----------------------------------------------------------------------------
-- | process section
-- +----------------------------------------------------------------------------
   reg_proc : process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         int_c_wr         <= '0';
         int_sop          <= '0';
         int_false_packet <= '0';
         int_rxstvalid0_q <= '0';
         int_rxstsop0_q   <= '0';
         int_rxsteop0_q   <= '0';
         int_rxsteop0_qq  <= '0';

      elsif clk_i'event and clk_i = '1' then
         int_rxstvalid0_q <= rx_st_valid0;
         int_rxstsop0_q   <= rx_st_sop0;
         int_rxsteop0_q   <= rx_st_eop0;
         int_rxsteop0_qq  <= int_rxsteop0_q;

         if rx_st_valid0 = '1' and rx_st_sop0 = '1' then
            int_sop <= '1';
         elsif rx_st_valid0 = '1' and rx_st_eop0 = '1' then
            int_sop <= '0';
         else
            int_sop <= int_sop;
         end if;

         if rx_st_valid0 = '1' and rx_st_sop0 = '1' then
            if tlp_type_i = TYPE_IS_MEMORY or tlp_type_i = TYPE_IS_IO then
               int_c_wr <= '1';
            elsif tlp_type_i = TYPE_IS_CPL and tlp_fmt_i = FMT_IS_WRITE then
               int_c_wr <= '0';
            else
               int_c_wr <= '0';
            end if;
         else
            int_c_wr <= int_c_wr;
         end if;


         -----------------------------------------------------------
         -- if the transfer is invalid set int_false_packet to '1' 
         -- invalid = all packet types except I/O wr/rd,
         --           memory wr/rd or completion (not locked)
         -----------------------------------------------------------
         if rx_st_valid0 = '1' and rx_st_sop0 = '1' then
            if (tlp_fmt_i = FMT_IS_READ and tlp_type_i = TYPE_IS_MEMORY) or
               (tlp_fmt_i = FMT_IS_READ and tlp_type_i = TYPE_IS_IO) or
               (tlp_fmt_i = FMT_IS_WRITE and tlp_type_i = TYPE_IS_MEMORY) or
               (tlp_fmt_i = FMT_IS_WRITE and tlp_type_i = TYPE_IS_IO) or
               (tlp_fmt_i = FMT_IS_WRITE and tlp_type_i = TYPE_IS_CPL) then
               int_false_packet <= '0';
            else
               int_false_packet <= '1';
            end if;
         elsif rx_st_valid0 = '1' and rx_st_eop0 = '1' then
            int_false_packet <= '0';
         end if;

      end if;
   end process reg_proc;

   ------------------------------
   -- state machine transitions
   ------------------------------
   fsm_trans : process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         state <= IDLE;
      elsif clk_i'event and clk_i = '1' then
         case state is
            when IDLE =>
               ------------------------------------------------------
               -- go to LOAD_CNTR if a transfer after ECRC error is
               -- not finished yet or a new, valid transfer starts
               -- if the transfer is invalid go to FALSE_PACKET
               -- invalid => int_false_packet = '1'
               ------------------------------------------------------
               if int_rxstvalid0_q = '0' and int_sop = '1' then
                  state <= LOAD_CNTR;
               elsif int_rxstvalid0_q = '1' and int_rxstsop0_q = '1' then
                  if int_false_packet = '1' then
                     state <= FALSE_PACKET;
                  else
                     state <= LOAD_CNTR;
                  end if;
               else
                  state <= IDLE;
               end if;

            when LOAD_CNTR =>
               --------------------------------------------
               -- load counter values for length counters
               --------------------------------------------
               if int_rxstvalid0_q = '0' then
                  state <= WAITING;
               elsif int_c_wr = '0' then
                  state <= CPL;
               else
                  state <= WRRD;
               end if;

            when CPL =>
               ---------------------------------------------------------
               -- transfer completion data to the completion FIFO
               -- go to ECRC_ERROR if the transfer is terminated early
               -- go to WAITING if rx_st_valid0 is deasserted
               -- go to IDLE if all data is transferred
               ---------------------------------------------------------
               if int_rxsteop0_qq = '1' and int_len2fifo_c > ONE_10B then
                  state <= ECRC_ERROR;
               elsif int_len2fifo_c > ONE_10B and int_rxstvalid0_q = '0' then
                  state <= WAITING;
               elsif int_rxstvalid0_q = '1' and int_rxstsop0_q = '1' then
                  state <= LOAD_CNTR;
               elsif (int_len2fifo_c = ONE_10B and int_rxstvalid0_q = '0') or
                     (int_len2fifo_c = ZERO_10B and int_rxstvalid0_q = '0' and int_rxsteop0_qq = '1') then
                  state <= IDLE;
               else
                  state <= CPL;
               end if;

            when WRRD =>
               ---------------------------------------------------------
               -- transfer write or read data to the wr FIFO
               -- go to ECRC_ERROR if the transfer is terminated early
               -- go to WAITING if rx_st_valid0 is deasserted
               -- go to IDLE if all data is transferred
               ---------------------------------------------------------
               if int_rxsteop0_qq = '1' and int_len2fifo_wr > ONE_10B then
                  state <= ECRC_ERROR;
               elsif int_len2fifo_wr > ONE_10B and int_rxstvalid0_q = '0' then
                  state <= WAITING;
               elsif int_rxstvalid0_q = '1' and int_rxstsop0_q = '1' then
                  state <= LOAD_CNTR;
               elsif (int_len2fifo_wr = ONE_10B and int_rxstvalid0_q = '0') or
                     (int_len2fifo_wr = ZERO_10B and int_rxstvalid0_q = '0' and int_rxsteop0_qq = '1') then
                  state <= IDLE;
               else
                  state <= WRRD;
               end if;

            when WAITING =>
               -------------------------------------------------
               -- wait until hard IP is ready to transfer data
               -------------------------------------------------
               if int_rxstvalid0_q = '1' then
                  if int_c_wr = '1' then
                     state <= WRRD;
                  else
                     state <= CPL;
                  end if;
               else
                  state <= WAITING;
               end if;

            when ECRC_ERROR =>
               ----------------------------------------------------
               -- if an ECRC error occurs the transfer may be
               -- terminated early
               -- in that case store dummy data to the FIFO until
               -- the original transfer length is achieved
               -- then go to IDLE
               ----------------------------------------------------
               if int_c_wr = '0' and int_len2fifo_c = ONE_10B then
                  state <= IDLE;
               elsif int_c_wr = '1' and int_len2fifo_wr = ONE_10B then
                  state <= IDLE;
               else
                  state <= ECRC_ERROR;
               end if;

            when FALSE_PACKET =>
               ---------------------------------------------------------------
               -- some packet types, e.g. messages, are forwarded by the
               -- hard IP although the 16z091-01 core does not process them
               -- in this case acknowledge the transfer but don't store
               -- anything to the FIFO
               ---------------------------------------------------------------
               if int_rxstvalid0_q = '1' and int_rxsteop0_q = '1' then
                  state <= IDLE;
               else
                  state <= FALSE_PACKET;
               end if;

            when others =>
               state <= IDLE;
               assert false report "undecoded state in process fsm_trans in rx_ctrl.vhd" severity error;
         end case;
      end if;
   end process fsm_trans;

   --------------------------
   -- state machine outputs
   --------------------------
   fsm_out : process(state, int_c_wr, int_len2fifo_c, int_len2fifo_wr)
   begin
      case state is
         when IDLE =>
            fifo_action_done_o <= '0';
            int_fifo_c_en      <= '0';
            int_fifo_wr_en     <= '0';
            int_enable_c_cntr  <= '0';
            int_enable_wr_cntr <= '0';
            int_load_c_cntr    <= '0';
            int_load_wr_cntr   <= '0';

         when LOAD_CNTR =>
            fifo_action_done_o <= '0';

            if int_c_wr = '0' then
               int_load_c_cntr    <= '1';
               int_load_wr_cntr   <= '0';
               int_fifo_c_en      <= '1';
               int_fifo_wr_en     <= '0';
               int_enable_c_cntr  <= '1';
               int_enable_wr_cntr <= '0';
            else
               int_load_c_cntr    <= '0';
               int_load_wr_cntr   <= '1';
               int_fifo_c_en      <= '0';
               int_fifo_wr_en     <= '1';
               int_enable_c_cntr  <= '0';
               int_enable_wr_cntr <= '1';
            end if;

         when CPL =>
            int_fifo_c_en      <= '1';
            int_fifo_wr_en     <= '0';
            int_enable_c_cntr  <= '1';
            int_enable_wr_cntr <= '0';
            int_load_c_cntr    <= '0';
            int_load_wr_cntr   <= '0';
            
            if int_len2fifo_c = ONE_10B then
               fifo_action_done_o <= '1';
            else
               fifo_action_done_o <= '0';
            end if;

         when WRRD =>
            int_fifo_c_en      <= '0';
            int_fifo_wr_en     <= '1';
            int_enable_c_cntr  <= '0';
            int_enable_wr_cntr <= '1';
            int_load_c_cntr    <= '0';
            int_load_wr_cntr   <= '0';

            if int_len2fifo_wr = ONE_10B then
               fifo_action_done_o <= '1';
            else
               fifo_action_done_o <= '0';
            end if;

         when WAITING =>
            fifo_action_done_o <= '0';
            int_fifo_c_en      <= '0';
            int_fifo_wr_en     <= '0';
            int_enable_c_cntr  <= '0';
            int_enable_wr_cntr <= '0';
            int_load_c_cntr    <= '0';
            int_load_wr_cntr   <= '0';

         when ECRC_ERROR =>
            int_load_c_cntr    <= '0';
            int_load_wr_cntr   <= '0';

            if int_c_wr = '0' then
               int_fifo_c_en      <= '1';
               int_fifo_wr_en     <= '0';
               int_enable_c_cntr  <= '1';
               int_enable_wr_cntr <= '0';
            else
               int_fifo_c_en      <= '0';
               int_fifo_wr_en     <= '1';
               int_enable_c_cntr  <= '0';
               int_enable_wr_cntr <= '1';
            end if;

            if int_len2fifo_c = ONE_10B or int_len2fifo_wr = ONE_10B then
               fifo_action_done_o <= '1';
            else
               fifo_action_done_o <= '0';
            end if;

         when FALSE_PACKET =>
            ------------------------------------------
            -- a false packet should be acknowledged
            -- but not stored to the FIFO
            ------------------------------------------
            fifo_action_done_o <= '0';
            int_fifo_c_en      <= '0';
            int_fifo_wr_en     <= '0';
            int_enable_c_cntr  <= '0';
            int_enable_wr_cntr <= '0';
            int_load_c_cntr    <= '0';
            int_load_wr_cntr   <= '0';

         when others =>
            int_fifo_c_en      <= '0';
            int_fifo_wr_en     <= '0';
            int_enable_c_cntr  <= '0';
            int_enable_wr_cntr <= '0';
            int_load_c_cntr    <= '0';
            int_load_wr_cntr   <= '0';
            fifo_action_done_o <= '0';
            assert false report "undecoded state in process fsm_trans in rx_ctrl.vhd" severity error;
      end case;
   end process fsm_out;


-- +----------------------------------------------------------------------------
-- | component instantiation
-- +----------------------------------------------------------------------------
   c_len_cntr_comp : rx_len_cntr
      port map(
         clk_i           => clk_i,
         rst_i           => rst_i,

         -- rx_get_data
         load_cntr_val_i => len_cntr_val_i,

         -- rx_ctrl
         load_cntr_i     => int_load_c_cntr,
         enable_cntr_i   => int_enable_c_cntr,
         len2fifo_o      => int_len2fifo_c
      );

   wr_len_cntr_comp : rx_len_cntr
      port map(
         clk_i           => clk_i, 
         rst_i           => rst_i,

         -- rx_get_data
         load_cntr_val_i => len_cntr_val_i,

         -- rx_ctrl
         load_cntr_i     => int_load_wr_cntr,
         enable_cntr_i   => int_enable_wr_cntr,
         len2fifo_o      => int_len2fifo_wr
      );


-------------------------------------------------------------------------------
end architecture rx_ctrl_arch;
