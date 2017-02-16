--------------------------------------------------------------------------------
-- Title       : internal Wishbone master module
-- Project     : 16z091-01
--------------------------------------------------------------------------------
-- File        : wb_master.vhd
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 16.11.2010
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6a / ModelSim AE 6.5e sp1
-- Synthesis   :
--------------------------------------------------------------------------------
-- Description :
-- handles Wishbone accesses, writes data from rx_module and returns read
-- data to tx_module
--------------------------------------------------------------------------------
-- Hierarchy   :
--    ip_16z091_01
--       rx_module
--          rx_ctrl
--          rx_get_data
--          rx_fifo
--          rx_len_cntr
-- *     wb_master
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.math_real.all;

library work;
use work.src_utils_pkg.all;


entity z091_01_wb_master is
   generic(
      NR_OF_WB_SLAVES       : natural range 63 DOWNTO 1     := 12;
      SUSPEND_FIFO_ACCESS   : std_logic_vector(9 downto 0) := "1111111011";      -- = 1019 DW
      RESUME_FIFO_ACCESS    : std_logic_vector(9 downto 0) := "1111110111"       -- = 1015 DW
   );
   port(
      wb_clk                : in  std_logic;
      wb_rst                : in  std_logic;
      
      -- Rx Module
      rx_fifo_wr_out        : in  std_logic_vector(31 downto 0);
      rx_fifo_wr_empty      : in  std_logic;
      rx_fifo_wr_rd_enable  : out std_logic;
      
      -- Tx Module
      tx_fifo_c_head_full   : in  std_logic;
      tx_fifo_c_data_full   : in  std_logic;
      tx_fifo_c_data_usedw  : in  std_logic_vector(9 downto 0);
      tx_fifo_c_head_enable : out std_logic;
      tx_fifo_c_data_enable : out std_logic;
      tx_fifo_c_head_in     : out std_logic_vector(31 downto 0);
      tx_fifo_c_data_in     : out std_logic_vector(31 downto 0);
      tx_fifo_c_data_clr    : out std_logic;
      tx_fifo_c_head_clr    : out std_logic;
      
      -- Wishbone
      wbm_ack               : in  std_logic;
      wbm_dat_i             : in  std_logic_vector(31 downto 0);
      wbm_stb               : out std_logic;
      --wbm_cyc               : out std_logic;
      wbm_cyc_o             : out std_logic_vector(NR_OF_WB_SLAVES - 1 downto 0);    --new
      wbm_we                : out std_logic;
      wbm_sel               : out std_logic_vector(3 downto 0);
      wbm_adr               : out std_logic_vector(31 downto 0);
      wbm_dat_o             : out std_logic_vector(31 downto 0);
      wbm_cti               : out std_logic_vector(2 downto 0);
      wbm_tga               : out std_logic;                                     -- wbm_tga(0)=1 if ECRC error occured
      --wb_bar_dec            : out std_logic_vector(6 downto 0);                -- decoded BAR for wb_adr_dec.vhd  mwawrik: no longer necessary
      
      -- error
      ecrc_err_in           : in  std_logic;                                     -- input from error module
      err_tag_id            : in  std_logic_vector(7 downto 0);
      ecrc_err_out          : out std_logic                                      -- output of 16z091-01
   );
end entity z091_01_wb_master;

-- ****************************************************************************   

architecture z091_01_wb_master_arch of z091_01_wb_master is

component z091_01_wb_adr_dec
   generic(
      NR_OF_WB_SLAVES : integer range 63 downto 1 := 1
   );
   port (
      pci_cyc_i       : in  std_logic_vector(6 downto 0);
      wbm_adr_o_q     : in  std_logic_vector(31 downto 2);

      wbm_cyc_o       : out std_logic_vector(NR_OF_WB_SLAVES -1 downto 0)
   );
end component;


-- FSM state encoding ---------------------------------------------------------
type fsm_state is (
   PREPARE_FIFO, IDLE, GET_HEADER_0, GET_HEADER_1, GET_HEADER_2, GET_WR_DATA, START_TRANS,
   TRANSMIT, WAIT_ON_FIFO, PUT_HEADER_0, PUT_HEADER_1, PUT_HEADER_2, GET_Z
);
signal state : fsm_state;
-------------------------------------------------------------------------------

-- constants ------------------------------------------------------------------
constant ADDR_INCR : std_logic_vector(13 downto 0)  := "00000000000100";         -- address increment for burst access
-------------------------------------------------------------------------------

-- internal signals -----------------------------------------------------------
signal get_data       : std_logic;
signal decode_header  : std_logic_vector(1 downto 0);                             -- 00 = idle, 01 = H0, 10 = H1, 11 = H3
signal data_to_wb     : std_logic;
signal data_to_fifo   : std_logic;
signal listen_to_ack  : std_logic;
signal write_header   : std_logic_vector(1 downto 0);                             -- 00 = idle, 01 = H0, 10 = H1, 11 = H3
signal wr_en_int      : std_logic;                                                -- write flag, 0 = read, 1 = write
signal attr_int       : std_logic_vector(2 downto 0);
signal tc_int         : std_logic_vector(2 downto 0);
signal req_id_int     : std_logic_vector(15 downto 0);
signal addr_int       : std_logic_vector(31 downto 0);
signal tag_id_int     : std_logic_vector(7 downto 0);
signal first_dw_int   : std_logic_vector(3 downto 0);
signal last_dw_int    : std_logic_vector(3 downto 0);
signal length_int     : std_logic_vector(9 downto 0);
signal data_q         : std_logic_vector(31 downto 0);
signal data_qq        : std_logic_vector(31 downto 0);
signal cnt_len_wb     : std_logic_vector(10 downto 0);                            -- count amount of data tranfered through wishbone
signal cnt_len_fifo   : std_logic_vector(10 downto 0);                            -- count amount of data taken from fifo
signal addr_offset    : std_logic_vector(13 downto 0);
signal wait_clk       : integer range 2 downto 0 := 0;
signal q_to_wbm       : std_logic_vector(1 downto 0);
signal wbm_ack_int    : std_logic;
signal err_tag_id_int : std_logic_vector(7 downto 0);
signal byte_count_int : std_logic_vector(11 downto 0);
signal suspend        : std_logic;
signal goto_start     : std_logic;
signal bar_dec_int    : std_logic_vector(6 downto 0);                            -- decode which BAR was hit, only one bit may be set at a time
signal aligned_int    : std_logic;
signal transmission   : std_logic;
signal io_wr_int      : std_logic;

signal wb_bar_dec_int   : std_logic_vector(6 downto 0); 
signal wb_bar_dec_int_d : std_logic_vector(6 downto 0); 

signal ecrc_err_int     : std_logic;

signal wbm_cyc_o_int    : std_logic_vector(NR_OF_WB_SLAVES -1 downto 0);
-------------------------------------------------------------------------------

begin

   z091_01_wb_adr_dec_comp : z091_01_wb_adr_dec 
      generic map(
         NR_OF_WB_SLAVES => NR_OF_WB_SLAVES
      )
      port map(
         pci_cyc_i       => wb_bar_dec_int,
         wbm_adr_o_q     => addr_int(31 downto 2),
   
         wbm_cyc_o       => wbm_cyc_o_int
      );




   wb_bar_dec_int <= bar_dec_int when (state = START_TRANS) or
                                      (state = WAIT_ON_FIFO and tx_fifo_c_data_usedw <= RESUME_FIFO_ACCESS and tx_fifo_c_data_usedw /= ZERO_10B 
                                          and tx_fifo_c_data_full = '0' and goto_start = '0') else 
                  (OTHERS => '0') when (state = IDLE) or 
                                       (state = START_TRANS and wbm_ack = '1' and wr_en_int = '1' and cnt_len_wb = ZERO_11B) or
                                       state = GET_Z or state = PUT_HEADER_0
                                          else
                  wb_bar_dec_int_d;
   
   --wb_bar_dec <= wb_bar_dec_int_d;    --mwawrik: no longer necessary because out-pin wb_bar_dec removed

   ecrc_err_int <= '0' when wb_rst = '1' else
                   '0' when state = TRANSMIT else
                   '1' when state /= TRANSMIT and ecrc_err_in = '1';
-------------------------------------------------------------------------------
   fsm_trans : process(wb_rst, wb_clk)
   begin
      if(wb_rst = '1') then
         state <= IDLE;
      elsif(wb_clk'event and wb_clk = '1') then
         case state is
            when IDLE =>
               if(rx_fifo_wr_empty = '0') then
                  state <= PREPARE_FIFO;
               else
                  state <= IDLE;
               end if;
               
            when PREPARE_FIFO =>
               state <= GET_HEADER_0;
               
            when GET_HEADER_0 =>
               state <= GET_HEADER_1;
               
            when GET_HEADER_1 =>
               state <= GET_HEADER_2;
               
            when GET_HEADER_2 =>
               if((tx_fifo_c_data_usedw > SUSPEND_FIFO_ACCESS or tx_fifo_c_data_full = '1') and wr_en_int = '0') then
                  state <= WAIT_ON_FIFO;
               elsif(rx_fifo_wr_out(2) = '0') then
                  ------------------------
                  -- transfer is aligned
                  ------------------------
                  state <= GET_Z;
               elsif(rx_fifo_wr_out(2) = '1' and wr_en_int = '1') then
                  state <= GET_WR_DATA;
               elsif(rx_fifo_wr_out(2) = '1' and wr_en_int = '0') then
                  state <= START_TRANS;
               end if;
               
            when GET_WR_DATA =>
               if(length_int = ONE_10B or ((length_int > ONE_10B or length_int = ZERO_10B) and wait_clk = 1)) then
                  state <= START_TRANS;
               else
                  state <= GET_WR_DATA;
               end if;
               
            when START_TRANS =>
               if(cnt_len_wb > ZERO_11B) then
                  state    <= TRANSMIT;
               elsif(cnt_len_wb <= ZERO_11B and wbm_ack = '1' and wr_en_int = '1') then
                  state <= IDLE;
               elsif(cnt_len_wb <= ZERO_11B and (wbm_ack = '1' or wr_en_int = '0')) then               
                  state <= START_TRANS;
               end if;
               
            when TRANSMIT =>
               if(wbm_ack = '1' and (wr_en_int = '0' or (io_wr_int = '1' and aligned_int = '0')) and ((tx_fifo_c_data_usedw > SUSPEND_FIFO_ACCESS and cnt_len_wb /= ZERO_11B) or cnt_len_wb = ZERO_11B)) then
                  state <= PUT_HEADER_0;
               elsif(wbm_ack = '1' and cnt_len_wb = ZERO_11B and wr_en_int = '1' and ((addr_int(2) = '0' and length_int(0) = '0') or 
                       (addr_int(2) = '1' and length_int(0) = '1'))) then
                  state <= IDLE;
               elsif(wbm_ack = '1' and cnt_len_wb = ZERO_11B and wr_en_int = '1' and ((addr_int(2) = '0' and length_int(0) = '1') or 
                      (addr_int(2) = '1' and length_int(0) = '0') or (io_wr_int = '1' and aligned_int = '1'))) then
                  state <= GET_Z;
               else
                  state <= TRANSMIT;
               end if;
               
            when WAIT_ON_FIFO =>
               if(tx_fifo_c_data_usedw <= RESUME_FIFO_ACCESS and tx_fifo_c_data_usedw /= ZERO_10B and tx_fifo_c_data_full = '0' and goto_start = '1') then
                  state <= START_TRANS;
               elsif(tx_fifo_c_data_usedw <= RESUME_FIFO_ACCESS and tx_fifo_c_data_usedw /= ZERO_10B and tx_fifo_c_data_full = '0' and goto_start = '0') then
                  state <= TRANSMIT;
               else
                  state <= WAIT_ON_FIFO;
               end if;
               
            when PUT_HEADER_0 =>
               state <= PUT_HEADER_1;
               
            when PUT_HEADER_1 =>
               if(wr_en_int = '0' or io_wr_int = '1') then
                  state <= PUT_HEADER_2;
               else
                  state <= IDLE;
               end if;
               
            when PUT_HEADER_2 =>
               if(wait_clk = 1 and suspend = '0') then
                  state <= IDLE;
               elsif(suspend = '1') then
                  state <= WAIT_ON_FIFO;
               else
                  state <= PUT_HEADER_2;
               end if;
               
            when GET_Z =>
               if(io_wr_int = '1' and aligned_int = '1' and transmission = '0') then
                  state <= PUT_HEADER_0;
               elsif(transmission = '1' and wr_en_int = '1') then
                  state <= GET_WR_DATA;
               elsif(transmission = '1' and wr_en_int = '0') then
                  state <= START_TRANS;
               else
                  state <= IDLE;
               end if;
               
            -- coverage off
            when others =>
               -- synthesis translate_off
               report "reached unknown FSM state in process fsm_trans of z091_01_wb_master.vhd" severity error;
               -- synthesis translate_on
               state <= IDLE;
            -- coverage on
         end case;
      end if;
   end process fsm_trans;
-------------------------------------------------------------------------------
   fsm_out : process(wb_rst, wb_clk)
   begin
      if(wb_rst = '1') then
         rx_fifo_wr_rd_enable  <= '0'; 
         tx_fifo_c_head_enable <= '0';
         tx_fifo_c_data_enable <= '0';
         tx_fifo_c_data_clr    <= '1';
         tx_fifo_c_head_clr    <= '1';
         wbm_stb               <= '0';
         wbm_cyc_o             <= (others => '0');
         wbm_we                <= '0';
         wbm_sel               <= (others => '0');
         wbm_adr               <= (others => '0');
         wbm_cti               <= (others => '0');
         wbm_tga               <= '0';
         ecrc_err_out          <= '0';
         get_data              <= '0';
         decode_header         <= (others => '0');
         data_to_wb            <= '0';
         data_to_fifo          <= '0';
         listen_to_ack         <= '0';
         write_header          <= (others => '0');
         cnt_len_wb            <= (others => '0');
         cnt_len_fifo          <= (others => '0');
         addr_offset           <= (others => '0');
         wait_clk              <= 0;
         q_to_wbm              <= (others => '0');
         wbm_ack_int           <= '0';
         err_tag_id_int        <= x"FF";                                         -- init with a value greater than allowed 32 tags
         byte_count_int        <= (others => '0');
         suspend               <= '0';
         goto_start            <= '0';
         aligned_int           <= '0';
         transmission          <= '0';
         
      elsif(wb_clk'event and wb_clk = '1') then
         wb_bar_dec_int_d <= wb_bar_dec_int;
      
         if(state = PREPARE_FIFO) then
            transmission <= '1';
         elsif(state = TRANSMIT) then
            transmission <= '0';
         end if;
         
         -- determine data alignment which decides whether first packet after header2 is empty or contains first data packet
         if(state = GET_HEADER_2 and rx_fifo_wr_out(2) = '0') then
            aligned_int <= '1';
         elsif(state = IDLE) then
            aligned_int <= '0';
         end if;
         
         if((state = IDLE and rx_fifo_wr_empty = '1') or state = START_TRANS or state = WAIT_ON_FIFO or 
           (state = GET_Z and (transmission = '0' or wr_en_int = '0' or (wr_en_int = '1' and aligned_int = '1' and length_int = ONE_10B))) or
           (state = GET_HEADER_2 and (wr_en_int = '0' or (wr_en_int = '1' and length_int = ONE_10B and rx_fifo_wr_out(2) = '1'))) or
           (state = TRANSMIT and wbm_ack = '1' and cnt_len_fifo = ONE_11B) or
           (state = GET_WR_DATA and ((length_int = TWO_10B and wait_clk = 0) or (length_int = THREE_10B and wait_clk = 1))) or
           (state = TRANSMIT and wbm_ack = '0')
           
         ) then
            rx_fifo_wr_rd_enable <= '0';
         elsif((state = IDLE and rx_fifo_wr_empty = '0') or 
              (state = GET_Z and transmission = '1' and wr_en_int = '1') or
              (state = TRANSMIT and wbm_ack = '1' and wr_en_int = '1' and ((cnt_len_wb = ZERO_11B and ((addr_int(2) = '0' and length_int(0) = '1') or 
                      (addr_int(2) = '1' and length_int(0) = '0'))) or cnt_len_fifo > ONE_11B))) then
            rx_fifo_wr_rd_enable <= '1';
         end if;
         
         if(state = IDLE or state = GET_Z or (state = WAIT_ON_FIFO and wait_clk = 1)) then
            tx_fifo_c_head_enable <= '0';
         elsif(state = PUT_HEADER_0) then
            tx_fifo_c_head_enable <= '1';
         end if;
         
         if(state = IDLE or (state = PUT_HEADER_2 and length_int(0) = '1')) then
            tx_fifo_c_data_enable <= '0';
         elsif(state = TRANSMIT or state = PUT_HEADER_0 or (state = PUT_HEADER_1 and length_int(0) = '0') ) then
            tx_fifo_c_data_enable <= wbm_ack_int;
         end if;
         
         if(state = IDLE or (state = START_TRANS and wbm_ack = '1' and wr_en_int = '1' and cnt_len_wb = ZERO_11B) or
           (state = TRANSMIT and wbm_ack = '1' and (cnt_len_wb = ZERO_11B or (tx_fifo_c_data_usedw > SUSPEND_FIFO_ACCESS and 
              cnt_len_wb /= ZERO_11B and wr_en_int = '0'))) ) then
            wbm_stb <= '0';
         elsif(state = START_TRANS or 
              (state = WAIT_ON_FIFO and tx_fifo_c_data_usedw <= RESUME_FIFO_ACCESS and tx_fifo_c_data_usedw /= ZERO_10B and 
                 tx_fifo_c_data_full = '0' and goto_start = '0') ) then
            wbm_stb <= '1';
         end if;
         
         --wbm_cyc never used before and now it is removed
         --if(state = IDLE or (state = START_TRANS and wbm_ack = '1' and wr_en_int = '1' and cnt_len_wb = ZERO_11B) or
         --  (state = TRANSMIT and wbm_ack = '1' and (cnt_len_wb = ZERO_11B or (tx_fifo_c_data_usedw > SUSPEND_FIFO_ACCESS and 
         --     cnt_len_wb /= ZERO_11B and wr_en_int = '0'))) ) then
         --   wbm_cyc <= '0';
         --elsif(state = START_TRANS or 
         --     (state = WAIT_ON_FIFO and tx_fifo_c_data_usedw <= RESUME_FIFO_ACCESS and tx_fifo_c_data_usedw /= ZERO_10B and 
         --        tx_fifo_c_data_full = '0' and goto_start = '0') ) then
         --   wbm_cyc <= '1';
         --end if;
         
         if(state = IDLE or (cnt_len_wb = ZERO_11B and wbm_ack = '1' and (state = TRANSMIT or (state = START_TRANS and wr_en_int = '1')))) then
            wbm_we <= '0';
         elsif(state = START_TRANS and wr_en_int = '1') then
            wbm_we <= '1';
         end if;
         
         if(state = IDLE or (cnt_len_wb = ZERO_11B and wbm_ack = '1' and (state = TRANSMIT or (state = START_TRANS and wr_en_int = '1')))) then
            wbm_sel <= (others => '0');
         elsif(state = START_TRANS) then
            wbm_sel <= first_dw_int;
         elsif(state = TRANSMIT and wbm_ack = '1' and cnt_len_wb > ONE_11B) then
            wbm_sel <= x"F";
         elsif(state = TRANSMIT and wbm_ack = '1' and cnt_len_wb = ONE_11B) then
            wbm_sel <= last_dw_int;
         end if;
         
         ----------------------------------------
         -- manage Wishbone address
         -- add addr_offset during transmission
         ----------------------------------------
         if(state = START_TRANS or (state = TRANSMIT and wbm_ack = '1')) then
            wbm_adr <= addr_int + addr_offset;
         --else
            --wbm_adr <= addr_int;
         end if;
         
         -- calculate address offset
         if(state = IDLE) then
            addr_offset <= (others => '0');
         elsif(state = START_TRANS or (state = TRANSMIT and wbm_ack = '1')) then
            addr_offset <= addr_offset + ADDR_INCR;
         end if;
         
         -- add wbm_cyc_o to be registered
         if((state = START_TRANS and suspend = '0' and length_int /= ONE_10B) or
           (state = WAIT_ON_FIFO and tx_fifo_c_data_usedw <= RESUME_FIFO_ACCESS and tx_fifo_c_data_usedw /= ZERO_10B and 
              tx_fifo_c_data_full = '0' and goto_start = '0' and cnt_len_wb > ZERO_11B) ) then
            wbm_cti   <= "010"; 
            wbm_cyc_o <= wbm_cyc_o_int;
         elsif((state = START_TRANS and suspend = '0' and length_int = ONE_10B) or
              (state = TRANSMIT and wbm_ack = '1' and (cnt_len_wb = ONE_11B or (tx_fifo_c_data_usedw = SUSPEND_FIFO_ACCESS and 
                 wr_en_int = '0'))) or
              (state = WAIT_ON_FIFO and tx_fifo_c_data_usedw <= RESUME_FIFO_ACCESS and tx_fifo_c_data_usedw /= ZERO_10B and 
                 tx_fifo_c_data_full = '0' and goto_start = '0' and cnt_len_wb <= ZERO_11B) ) then
            wbm_cti    <= "111"; 
            wbm_cyc_o <= wbm_cyc_o_int;
         elsif(wbm_ack = '1' and cnt_len_wb = ZERO_11B and (state = TRANSMIT or (state = START_TRANS and wr_en_int = '1')) ) then
            wbm_cti   <= "000"; 
            wbm_cyc_o <= (OTHERS=>'0');
         end if;
         
         if(state = IDLE or (state = TRANSMIT and wbm_ack = '1' and cnt_len_wb = ZERO_11B)) then
            wbm_tga <= '0';
         elsif(state = START_TRANS and err_tag_id_int = tag_id_int) then
            wbm_tga <= '1';
         end if;
         
         if(state = IDLE or (state = TRANSMIT and wbm_ack = '1' and cnt_len_wb = ZERO_11B)) then
            ecrc_err_out <= '0';
         elsif(state = START_TRANS and ecrc_err_int = '1' and err_tag_id_int = tag_id_int) then
            ecrc_err_out <= '1';
         end if;
         
         if(state = IDLE or state = START_TRANS or (state = GET_HEADER_2 and wr_en_int = '0') or (state = GET_WR_DATA and length_int = ONE_10B) or
           (state = TRANSMIT and ((wbm_ack = '0' or wr_en_int = '0' or cnt_len_wb = ZERO_11B) or (wbm_ack = '1' and cnt_len_wb = ZERO_11B))) ) then
            get_data <= '0';
         elsif((state = GET_HEADER_2 and rx_fifo_wr_out(2) = '1' and wr_en_int = '1') or (state = GET_WR_DATA and length_int /= ONE_10B) or
              (state = TRANSMIT and wbm_ack = '1' and wr_en_int = '1' and cnt_len_wb > ZERO_11B) or
              (state = GET_Z and aligned_int = '1' and wr_en_int = '1')
              ) then     
            get_data <= '1';
         end if;
         
         if(state = IDLE or state = GET_WR_DATA or state = START_TRANS or state = GET_HEADER_2) then
            decode_header <= (others => '0');
         elsif(state = PREPARE_FIFO) then
            decode_header <= "01";
         elsif(state = GET_HEADER_0) then
            decode_header <= "10";
         elsif(state = GET_HEADER_1) then
            decode_header <= "11";
         end if;
         
         if(state = IDLE or state = START_TRANS or (state = TRANSMIT and wbm_ack = '1' and cnt_len_wb = ZERO_11B)) then
            data_to_wb <= '0';
         elsif(state = GET_WR_DATA and wr_en_int = '1' and (length_int = ONE_10B or wait_clk = 1)) then
            data_to_wb <= '1';
         end if;
         
         if(state = IDLE or (state = START_TRANS and wbm_ack = '1' and wr_en_int = '1' and cnt_len_wb = ZERO_11B)) then
            data_to_fifo <= '0';
         elsif(wr_en_int = '0' and (state = START_TRANS or state = TRANSMIT)) then
            data_to_fifo <= '1';
         end if;
         
         if(state = IDLE or 
           (wbm_ack = '1' and cnt_len_wb = ZERO_11B and ((state = START_TRANS and wr_en_int = '1') or state = TRANSMIT)) ) then
            listen_to_ack <= '0';
         elsif(state = START_TRANS and wr_en_int = '1') then
            listen_to_ack <= '1';
         end if;
         
         if(state = IDLE) then
            write_header <= (others => '0');
         elsif(state = TRANSMIT and wbm_ack = '1' and (wr_en_int = '0' or io_wr_int = '1') and (cnt_len_wb = ZERO_11B or 
              (tx_fifo_c_data_usedw > SUSPEND_FIFO_ACCESS and cnt_len_wb /= ZERO_11B)) ) then
            write_header <= "01";
         elsif(state = PUT_HEADER_0) then
            write_header <= "10";
         elsif(state = PUT_HEADER_1 and (wr_en_int = '0' or io_wr_int = '1')) then
            write_header <= "11";
         end if;
         
         -- calculate length counters for Wishbone transactions and decrement when necessary
         if(state = IDLE) then
            cnt_len_wb <= (others => '0');
         elsif(state = GET_HEADER_1 and length_int = ZERO_10B) then
            cnt_len_wb <= '1' & length_int;
         elsif(state = GET_HEADER_1 and length_int /= ZERO_10B) then
            cnt_len_wb <= '0' & length_int;
         elsif(cnt_len_wb > ZERO_11B and (state = START_TRANS or (state = TRANSMIT and wbm_ack = '1')) ) then
            cnt_len_wb <= cnt_len_wb - ONE_11B;
         end if;
         
         -- calculate length counters for FIFO transactions  and decrement when necessary
         if(state = IDLE) then
            cnt_len_fifo <= (others => '0');
         elsif(state = GET_HEADER_1 and length_int = ZERO_10B) then
            cnt_len_fifo <= '1' & length_int;
         elsif(state = GET_HEADER_1 and length_int /= ZERO_10B) then
            cnt_len_fifo <= '0' & length_int;
         elsif(wr_en_int = '1' and cnt_len_fifo > ZERO_11B and (state = GET_WR_DATA or state = START_TRANS or 
              (state = TRANSMIT and wbm_ack = '1')) ) then
            cnt_len_fifo <= cnt_len_fifo - ONE_11B;
         end if;
         
         if(state = IDLE or state = GET_HEADER_1 or state = PUT_HEADER_1 or (state = PUT_HEADER_2 and suspend = '1') or
           (state = WAIT_ON_FIFO and tx_fifo_c_data_usedw <= RESUME_FIFO_ACCESS and tx_fifo_c_data_usedw /= ZERO_10B and 
              tx_fifo_c_data_full = '0' and goto_start = '0') ) then
            wait_clk <= 0;
         elsif(state = GET_WR_DATA or (state = WAIT_ON_FIFO and wait_clk < 1) or (state = PUT_HEADER_2 and suspend = '0')) then
            wait_clk <= wait_clk + 1;
         end if;
         
         if(state = IDLE) then
            q_to_wbm <= (others => '0');
         elsif((state = GET_HEADER_1 and length_int = ONE_10B) or (state = TRANSMIT and wbm_ack = '1')) then
            q_to_wbm <= "01";
         elsif((state = GET_HEADER_1 and length_int /= ONE_10B) or (state = TRANSMIT and wbm_ack = '0')) then
            q_to_wbm <= "10";
         end if;
         
         if(state = IDLE or (wbm_ack = '0' and wr_en_int = '0' and (state = TRANSMIT or state = PUT_HEADER_0 or state = PUT_HEADER_1))) then
            wbm_ack_int <= '0';
         elsif(wbm_ack = '1' and wr_en_int = '0' and (state = TRANSMIT or state = PUT_HEADER_0 or state = PUT_HEADER_1)) then
            wbm_ack_int <= '1';
         end if;
         
         -- capture ecrc error
         if(state = IDLE and ecrc_err_in = '0') then
            err_tag_id_int <= (others => '0');
         elsif(ecrc_err_in = '1' and (state = IDLE or state = GET_HEADER_0 or state = GET_HEADER_1 or state = GET_HEADER_2 or 
               state = GET_WR_DATA)) then
            err_tag_id_int <= err_tag_id;
         end if;
         
         -- calculate byte count
         -- correct byte count value according to first_dw_int value as defined in PCIe base specification in state PUT_HEADER_0
         if(state = IDLE) then
            byte_count_int <= (others => '0');
         elsif(wbm_ack = '1' and (state = TRANSMIT or (state = START_TRANS and wr_en_int = '1' and cnt_len_wb = 0))) then
            byte_count_int <= byte_count_int + FOUR_12B;
         elsif(state = PUT_HEADER_0 and length_int = ONE_10B and (first_dw_int = ZERO_04B or first_dw_int = EIGHT_04B or first_dw_int = FOUR_04B or first_dw_int = TWO_04B or first_dw_int = ONE_04B)) then
            byte_count_int <= ONE_12B;
         elsif(state = PUT_HEADER_0 and length_int = ONE_10B and (first_dw_int = C_04B or first_dw_int = SIX_04B or first_dw_int = THREE_04B)) then
            byte_count_int <= TWO_12B;
         elsif(state = PUT_HEADER_0 and length_int = ONE_10B and ((first_dw_int(3) = '1' and first_dw_int(1 downto 0) = TWO_02B) or (first_dw_int(3 downto 2) = ONE_02B and first_dw_int(0) = '1'))) then
            byte_count_int <= THREE_12B;
         elsif(state = PUT_HEADER_0 and length_int = ONE_10B and first_dw_int(3) = '1' and first_dw_int(0) = '1') then
            byte_count_int <= FOUR_12B;
         elsif(state = PUT_HEADER_0 and length_int /= ONE_10B and ((first_dw_int(0) = '1' and last_dw_int(3 downto 2) = ONE_02B) or (first_dw_int(1 downto 0) = TWO_02B and last_dw_int(3) = '1'))) then
            byte_count_int <= byte_count_int - ONE_12B;
         elsif(state = PUT_HEADER_0 and length_int /= ONE_10B and ((first_dw_int(0) = '1' and last_dw_int(3 downto 1) = ONE_03B) or (first_dw_int(1 downto 0) = TWO_02B and last_dw_int(3 downto 2) = ONE_02B) or (first_dw_int(2 downto 0) = FOUR_03B and last_dw_int(3) = '1'))) then
            byte_count_int <= byte_count_int - TWO_12B;
         elsif(state = PUT_HEADER_0 and length_int /= ONE_10B and ((first_dw_int(0) = '1' and last_dw_int = ONE_04B) or (first_dw_int(1 downto 0) = ONE_02B and last_dw_int(3 downto 1) = ONE_03B) or (first_dw_int(2 downto 0) = FOUR_03B and last_dw_int(3 downto 2) = ONE_02B) or (first_dw_int = EIGHT_04B and last_dw_int(3) = '1'))) then
            byte_count_int <= byte_count_int - THREE_12B;
         elsif(state = PUT_HEADER_0 and length_int /= ONE_10B and ((first_dw_int(1 downto 0) = TWO_02B and last_dw_int = ONE_04B) or (first_dw_int(2 downto 0) = FOUR_03B and last_dw_int(3 downto 1) = ONE_03B) or (first_dw_int = EIGHT_04B and last_dw_int(3 downto 2) = ONE_02B))) then
            byte_count_int <= byte_count_int - FOUR_12B;
         elsif(state = PUT_HEADER_0 and length_int /= ONE_10B and ((first_dw_int = EIGHT_04B and last_dw_int(3 downto 1) = ONE_03B) or (first_dw_int(2 downto 0) = FOUR_03B and last_dw_int = ONE_04B))) then
            byte_count_int <= byte_count_int - FIVE_12B;
         elsif(state = PUT_HEADER_0 and length_int /= ONE_10B and first_dw_int = EIGHT_04B and last_dw_int = ONE_04B) then
            byte_count_int <= byte_count_int - SIX_12B;
         end if;
         
         -- suspend all actions when FIFO is full until there is space in FIFO again
         if(state = IDLE or
           (state = WAIT_ON_FIFO and tx_fifo_c_data_usedw <= RESUME_FIFO_ACCESS and tx_fifo_c_data_usedw /= ZERO_10B and 
              tx_fifo_c_data_full = '0')) then
            suspend <= '0';
         elsif((state = GET_HEADER_2 and (tx_fifo_c_data_usedw > SUSPEND_FIFO_ACCESS or tx_fifo_c_data_full = '1') and wr_en_int = '0') or
              (state = TRANSMIT and wbm_ack = '1' and tx_fifo_c_data_usedw > SUSPEND_FIFO_ACCESS and cnt_len_wb /= ZERO_11B and 
                 wr_en_int = '0')) then
            suspend <= '1';
         end if;
         
         if(state = IDLE or
           (state = WAIT_ON_FIFO and tx_fifo_c_data_usedw <= RESUME_FIFO_ACCESS and tx_fifo_c_data_usedw /= ZERO_10B and 
              tx_fifo_c_data_full = '0' and goto_start = '1')) then
            goto_start <= '0';
         elsif(state = GET_HEADER_2 and (tx_fifo_c_data_usedw > SUSPEND_FIFO_ACCESS or tx_fifo_c_data_full = '1')) then
            goto_start <= '1';
         end if;
         
         if(state = IDLE) then
            tx_fifo_c_data_clr <= '0';
            tx_fifo_c_head_clr <= '0';
         end if;
         
      end if;
   end process fsm_out;
-------------------------------------------------------------------------------
   data_path : process(wb_clk, wb_rst, wbm_ack)
   
   begin
      if(wb_rst = '1') then
         -- ports:
         tx_fifo_c_head_in <= (others => '0');
         tx_fifo_c_data_in <= (others => '0');
         wbm_dat_o         <= (others => '0');
         -- signals:
         data_q            <= (others => '0');
         data_qq           <= (others => '0');
         wr_en_int         <= '0';
         attr_int          <= (others => '0');
         tc_int            <= (others => '0');
         req_id_int        <= (others => '0');
         addr_int          <= (others => '0');
         tag_id_int        <= (others => '0');
         first_dw_int      <= (others => '0');
         last_dw_int       <= (others => '0');
         length_int        <= (others => '0');
         bar_dec_int       <= (others => '0');
         io_wr_int         <= '0';
         
      else
         if(wb_clk'event and wb_clk = '1') then
            if(decode_header = "01") then

               -- decode which BAR was hit
               case rx_fifo_wr_out(28 downto 26) is
                  when "000" =>
                     bar_dec_int(0)          <= '1';
                     bar_dec_int(6 downto 1) <= (others => '0');
                  when "001" =>
                     bar_dec_int(0)          <= '0';
                     bar_dec_int(1)          <= '1';
                     bar_dec_int(6 downto 2) <= (others => '0');
                  when "010" =>
                     bar_dec_int(1 downto 0) <= (others => '0');
                     bar_dec_int(2)          <= '1';
                     bar_dec_int(6 downto 3) <= (others => '0');
                  when "011" =>
                     bar_dec_int(2 downto 0) <= (others => '0');
                     bar_dec_int(3)          <= '1';
                     bar_dec_int(6 downto 4) <= (others => '0');
                  when "100" =>
                     bar_dec_int(3 downto 0) <= (others => '0');
                     bar_dec_int(4)          <= '1';
                     bar_dec_int(6 downto 5) <= (others => '0');
                  when "101" =>
                     bar_dec_int(4 downto 0) <= (others => '0');
                     bar_dec_int(5)          <= '1';
                     bar_dec_int(6)          <= '0';
                  when "110" =>
                     bar_dec_int(5 downto 0) <= (others => '0');
                     bar_dec_int(6)          <= '1';
                  
                  -- coverage off
                  when others =>
                     bar_dec_int <= (0 => '1', others => '0');
                     -- synthesis translate_off
                     report "Error while decoding BAR" severity error;
                     -- synthesis translate_on
                  -- coverage on   
               end case;
               
               -- split value of data bus into its components
               wr_en_int     <= rx_fifo_wr_out(31);
               io_wr_int     <= rx_fifo_wr_out(30) and rx_fifo_wr_out(31);
               first_dw_int  <= rx_fifo_wr_out(17 downto 14);
               last_dw_int   <= rx_fifo_wr_out(13 downto 10);
               length_int    <= rx_fifo_wr_out(9 downto 0);
               tag_id_int <= rx_fifo_wr_out(25 downto 18);
            elsif(decode_header = "10") then
               attr_int      <= rx_fifo_wr_out(21 downto 19);
               tc_int        <= rx_fifo_wr_out(18 downto 16);
               req_id_int    <= rx_fifo_wr_out(15 downto 0);
            elsif(decode_header = "11") then
               addr_int      <= rx_fifo_wr_out;
            end if;
            
            -- manage data registering pipeline
            if(get_data = '1' and wr_en_int = '1') then
               data_q   <= rx_fifo_wr_out;
               data_qq  <= data_q;
            elsif(get_data = '1' and wr_en_int = '0') then
               data_q  <= wbm_dat_i;
            end if;
            
            -- route registered data signals to output port
            if(listen_to_ack = '1' and wbm_ack = '1') then
               case q_to_wbm is
                  when "01" =>
                     wbm_dat_o <= data_q;
                  when "10" =>   
                     wbm_dat_o <= data_qq;
                  when "11" =>
                  
                  -- coverage off
                  when others =>
                     -- synthesis translate_off
                     report "Reached undecoded state of signal q_to_wbm" severity error;
                     -- synthesis translate_on
                  -- coverage on
               end case;
            elsif(data_to_wb = '1') then
               case q_to_wbm is
                  when "01" =>
                     wbm_dat_o <= data_q;
                  when "10" =>   
                     wbm_dat_o <= data_qq;
                  when "11" =>
                     
                  -- coverage off
                  when others =>
                     -- synthesis translate_off
                     report "Reached undecoded state of signal q_to_wbm" severity error;
                     -- synthesis translate_on
                  -- coverage on
               end case;
            elsif(data_to_fifo = '1') then
               data_q            <= wbm_dat_i;
               tx_fifo_c_data_in <= data_q;
            end if;
            
            -- asseble tx data packet
            if(write_header = "01") then
               tx_fifo_c_head_in(31 downto 29) <= attr_int;
               tx_fifo_c_head_in(28 downto 26) <= tc_int;
               tx_fifo_c_head_in(25 downto 18) <= tag_id_int;
               tx_fifo_c_head_in(17 downto 14) <= first_dw_int;
               tx_fifo_c_head_in(13 downto 10) <= last_dw_int;
               tx_fifo_c_head_in(9 downto 0)   <= length_int;
            elsif(write_header = "10") then
               tx_fifo_c_head_in               <= addr_int;
            elsif(write_header = "11") then
               tx_fifo_c_head_in(31 downto 29) <= (others => '0');
               tx_fifo_c_head_in(28) <= io_wr_int;
               if(io_wr_int = '1') then
                  tx_fifo_c_head_in(27 downto 16) <= "000000000100";
               else
                  tx_fifo_c_head_in(27 downto 16) <= byte_count_int;
               end if;
               
               tx_fifo_c_head_in(15 downto 0)  <= req_id_int;
            else
               tx_fifo_c_head_in               <= (others => '0');
            end if;
         end if;
      end if;
   end process data_path;
-------------------------------------------------------------------------------
end architecture z091_01_wb_master_arch;
