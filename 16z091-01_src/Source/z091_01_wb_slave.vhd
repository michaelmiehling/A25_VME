--------------------------------------------------------------------------------
-- Title       : new Wishbone Slave
-- Project     : 16z091-01
--------------------------------------------------------------------------------
-- File        : wbs_new.vhd
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 2015-03-10
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6a / ModelSim AE 6.5e sp1
-- Synthesis   : 
--------------------------------------------------------------------------------
-- Description : 
-- Wishbone slave module to receive read and write requests from Wishbone 
-- master and to return read data via completion
-- Due to different FIFO data port widths (32bit for WB, 64bit for RX & TX)
-- storing or deleting dummy packets is necessary on the WB side.
-- 1. RX storing 64bit wide -> delete 1 dummy packet on WB side
-- 2. store 1 dummy packet on WB side so that TX can read 64bit (otherwise
--    fifo_empty will not indicate 32bit contents to TX side)
-- CPLD := completion with data
-- CDC  := clock domain crossing
--------------------------------------------------------------------------------
-- Hierarchy   : 
--    ip_16z091_01
--       rx_module
--          rx_ctrl
--          rx_get_data
--          rx_fifo
--          rx_len_cntr
--       wb_master
-- *     wb_slave
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

entity z091_01_wb_slave is
   generic(
      PCIE_REQUEST_LENGTH : std_logic_vector(9 downto 0) := "0000100000";      -- 32DW = 128Byte
      SUSPEND_FIFO_ACCESS : std_logic_vector(9 downto 0) := "1111111100";      -- = 1020 DW, one place spare for put_stuffing
      RESUME_FIFO_ACCESS  : std_logic_vector(9 downto 0) := "1111110111"       -- = 1015 DW
   );
   port(
      wb_clk                 : in  std_logic;
      wb_rst                 : in  std_logic;
      
      -- Wishbone
      wbs_cyc                : in  std_logic;
      wbs_stb                : in  std_logic;
      wbs_we                 : in  std_logic;
      wbs_sel                : in  std_logic_vector(3 downto 0);
      wbs_adr                : in  std_logic_vector(31 downto 0);
      wbs_dat_i              : in  std_logic_vector(31 downto 0);
      wbs_cti                : in  std_logic_vector(2 downto 0);
      wbs_tga                : in  std_logic;                                  -- 0: memory, 1: I/O
      wbs_ack                : out std_logic;
      wbs_err                : out std_logic;
      wbs_dat_o              : out std_logic_vector(31 downto 0);
      
      -- Rx Module
      rx_fifo_c_empty        : in  std_logic;
      rx_fifo_c_out          : in  std_logic_vector(31 downto 0);
      rx_fifo_c_rd_enable    : out std_logic;
      
      -- Tx Module
      tx_fifo_wr_head_full   : in  std_logic;
      tx_fifo_w_data_full    : in  std_logic;
      tx_fifo_w_data_usedw   : in  std_logic_vector(9 downto 0);
      tx_fifo_wr_head_usedw  : in  std_logic_vector(4 downto 0);
      tx_fifo_wr_head_clr    : out std_logic;
      tx_fifo_wr_head_enable : out std_logic;
      tx_fifo_wr_head_in     : out std_logic_vector(31 downto 0);
      tx_fifo_w_data_clr     : out std_logic;
      tx_fifo_w_data_enable  : out std_logic;
      tx_fifo_w_data_in      : out std_logic_vector(31 downto 0);
      
      max_read               : in  std_logic_vector(2 downto 0);
      
      -- error
      error_ecrc_err         : in  std_logic;
      error_timeout          : in  std_logic
   );
end entity z091_01_wb_slave;

architecture z091_01_wb_slave_arch of z091_01_wb_slave is

-- FSM state encoding ---------------------------------------------------------
type fsm_state is (
   WAIT_ON_FIFO, IDLE, HEADER_TO_FIFO, WR_TRANS, RD_TRANS, GET_RD_HEADER,
   DROP_DATA
);
signal state    : fsm_state;

-- internal signals -----------------------------------------------------------
signal tx_fifo_wr_head_en_int : std_logic;                                     -- internal enable
signal cnt_len                : std_logic_vector(9 downto 0);                  -- packet counter
signal cpl_return_len         : std_logic_vector(9 downto 0);                  -- count amount of CPL data
signal put_header             : std_logic;                                     -- valid signal for put_h0_h1
signal put_h0_h1              : std_logic;                                     -- qualify which kind of header to store
                                                                               -- 0: put h0, 1: put h1
signal get_header     : std_logic;                                             -- get header info from CPLD
signal wbs_adr_int    : std_logic_vector(31 downto 0);                         -- store wbs_adr
signal first_DW_int   : std_logic_vector(3 downto 0);                          -- store first_DW byte enable
signal last_DW_int    : std_logic_vector(3 downto 0);                          -- store last_DW byte enable
signal length_int     : std_logic_vector(9 downto 0);                          -- store length returned with CPLD
signal max_read_len   : std_logic_vector(9 downto 0);                          -- max read length for RD_TRANS

signal wr_req             : std_logic;                                         -- active while write request
signal rd_req             : std_logic;                                         -- active while read request
signal wr_burst           : std_logic;                                         -- active if burst write
signal rd_burst           : std_logic;                                         -- active if burst read
signal max_wr_len_reached : std_logic;                                         -- break if cnt_len will wrap thus 1024DW were written to FIFO
signal multi_cpl          : std_logic;                                         -- asserted if read returned in multiple cycles
signal rd_trans_done      : std_logic;                                         -- store if WB transaction is finished
signal len_is_1024DW      : std_logic;                                         -- if asserted length is 1024
                                                                               -- 1024DW is encoded as len=0 thus
                                                                               -- needed to distinguish from reset value
signal compare_to_4k_len : std_logic;                                          -- enable 4k honoring
signal to_4k_len         : std_logic_vector(9 downto 0);                       -- DW counter which holds amount of DWs until next 4k boundary
signal requested_len     : std_logic_vector(9 downto 0);                       -- save requested length for reads
signal act_read_size     : std_logic_vector(9 downto 0);                       -- actual read size composed in IDLE state

-- registered signals
signal max_read_q     : std_logic_vector(2 downto 0);                          -- used for CDC synchronization
signal max_read_qq    : std_logic_vector(2 downto 0);                          -- used for CDC synchronization
signal put_header_q   : std_logic;
signal get_header_q   : std_logic;                                             -- define 4 stages of header aquisition
signal get_header_qq  : std_logic;
signal get_header_qqq : std_logic;
signal first_rd_cycle : std_logic;                                             -- first cycle in RD_TRANS
signal wbs_tga_q      : std_logic;                                             -- registered copy of wbs_tga
-------------------------------------------------------------------------------

begin
-- +----------------------------------------------------------------------------
-- | concurrent section
-- +----------------------------------------------------------------------------
   ----------------------------------------
   -- assign static connections for ports
   ----------------------------------------
   wbs_err           <= error_ecrc_err or error_timeout;
   tx_fifo_w_data_in <= wbs_dat_i;
   wbs_dat_o         <= rx_fifo_c_out;

   -----------------------
   -- decode max_read_qq
   -----------------------
   with max_read_qq select
      max_read_len <=   "0001000000" when "001",
                        "0010000000" when "010",
                        "0100000000" when "011",
                        "1000000000" when "100",
                        "0000000000" when "101",
                        "0000100000" when others;
                        

-- +----------------------------------------------------------------------------
-- | process section
-- +----------------------------------------------------------------------------
   --------------------------------------------
   -- register different signals using wb_clk
   --------------------------------------------
   reg_proc : process(wb_rst, wb_clk)
   begin
      if wb_rst = '1' then
         tx_fifo_wr_head_enable <= '0';
         max_read_q             <= (others => '0');
         max_read_qq            <= (others => '0');
         put_header_q           <= '0';
         get_header_q           <= '0';
         get_header_qq          <= '0';
         get_header_qqq         <= '0';
         first_rd_cycle         <= '0';
         wbs_tga_q              <= '0';
      elsif wb_clk'event and wb_clk = '1' then
         tx_fifo_wr_head_enable <= tx_fifo_wr_head_en_int;
         max_read_q             <= max_read;
         max_read_qq            <= max_read_q;
         put_header_q           <= put_header;
         get_header_q           <= get_header;
         get_header_qq          <= get_header_q;
         get_header_qqq         <= get_header_qq;
         first_rd_cycle         <= get_header_qqq;
         if state = HEADER_TO_FIFO then
            wbs_tga_q           <= wbs_tga;
         end if;
      end if;
   end process reg_proc;


   ---------------------------
   -- manage FSM transitions
   ---------------------------
   fsm_transout : process(wb_rst, wb_clk)
   begin
      if wb_rst = '1' then
         -- ports
         tx_fifo_wr_head_clr    <= '1';
         tx_fifo_w_data_clr     <= '1';
         tx_fifo_wr_head_en_int <= '0';
         tx_fifo_w_data_enable  <= '0';
         rx_fifo_c_rd_enable    <= '0';
         wbs_ack                <= '0';

         -- internal signals
         wbs_adr_int        <= (others => '0');
         cnt_len            <= (others => '0');
         put_header         <= '0';
         put_h0_h1          <= '0';
         get_header         <= '0';
         wr_req             <= '0';
         rd_req             <= '0';
         wr_burst           <= '0';
         rd_burst           <= '0';
         max_wr_len_reached <= '0';
         multi_cpl          <= '0';
         first_DW_int       <= (others => '0');
         last_DW_int        <= (others => '0');
         cpl_return_len     <= (others => '0');
         rd_trans_done      <= '0';
         len_is_1024DW      <= '0';
         compare_to_4k_len  <= '0';
         to_4k_len          <= (others => '0');

         state <= IDLE;
      elsif wb_clk'event and wb_clk = '1' then
         case state is
            when IDLE =>
               -- ports
               tx_fifo_wr_head_clr    <= '0';
               tx_fifo_w_data_clr     <= '0';
               tx_fifo_wr_head_en_int <= '0';
               tx_fifo_w_data_enable  <= '0';
               rx_fifo_c_rd_enable    <= '0';
               wbs_ack                <= '0';

               -- internal signals
               cnt_len            <= (others => '0');
               put_header         <= '0';
               put_h0_h1          <= '0';
               get_header         <= '0';
               wr_req             <= '0';
               rd_req             <= '0';
               wr_burst           <= '0';
               rd_burst           <= '0';
               max_wr_len_reached <= '0';
               multi_cpl          <= '0';
               first_DW_int       <= (others => '0');
               last_DW_int        <= (others => '0');
               cpl_return_len     <= (others => '0');
               rd_trans_done      <= '0';
               len_is_1024DW      <= '0';

               ------------------------------
               -- wait until active request
               ------------------------------
               if wbs_cyc = '1' and wbs_stb = '1' then
                  wbs_adr_int  <= wbs_adr;
                  first_DW_int <= wbs_sel;

                  ----------------------------------------------------------------------------------------
                  -- calculate length to 4k boundary:
                  -- wbs_adr[12] denotes 4k boundary which is 0x1000
                  -- maximum transfer length is 1024DW = 1024 *4B = 4096B := 0x1000
                  -- => if wbs_adr[11:0] = 0b000 then all lenghts are ok
                  --    otherwise calculate length offset to next 4k boundary, use to_4k_len as DW counter
                  -- subtracting wbs_adr from the next 4k boundary results in a byte value
                  -- -> use 1024 instead of 4096 to calculated DW counter instead of byte counter
                  --    ! manage first_DW_be and last_DW_be accordingly
                  ----------------------------------------------------------------------------------------
                  if wbs_adr(11 downto 0) = x"000" then
                     compare_to_4k_len <= '0';
                     to_4k_len         <= (others => '0');
                  else
                     compare_to_4k_len <= '1';
                     to_4k_len         <= std_logic_vector(to_unsigned((1024 - to_integer(unsigned(wbs_adr(11 downto 2)))), 10));
                  end if;

                  if wbs_we = '0' and wbs_cti = "010" then
                     rd_burst <= '1';
                  else
                     rd_burst <= '0';
                  end if;

                  -----------------------------------------------------------------------------------
                  -- if write request and TX data FIFO full or
                  -- read request and TX header FIFO full then
                  -- wait until FIFO is empty again
                  -- for both read and write requests the header FIFO must have at least 2 DW space
                  -- (here 3 for easier checking)
                  -----------------------------------------------------------------------------------
                  if (wbs_we = '1' and (tx_fifo_w_data_full = '1' or tx_fifo_w_data_usedw > RESUME_FIFO_ACCESS or
                                        tx_fifo_wr_head_full = '1' or tx_fifo_wr_head_usedw(4 downto 2) = "111")) or 
                     (wbs_we = '0' and (tx_fifo_wr_head_full = '1' or tx_fifo_wr_head_usedw(4 downto 2) = "111")) then
                     state <= WAIT_ON_FIFO;
                  elsif wbs_we = '1' and tx_fifo_w_data_full = '0' then
                     tx_fifo_w_data_enable <= '1';
                     wbs_ack               <= '1';
                     wr_req                <= '1';
                     cnt_len               <= ONE_10B;
                     state                 <= WR_TRANS;
                  elsif wbs_we = '0' and tx_fifo_wr_head_full = '0' then
                     tx_fifo_wr_head_en_int <= '1';
                     rd_req                 <= '1';
                     put_header             <= '1';
                     state                  <= HEADER_TO_FIFO;
                  end if;
               else
                  compare_to_4k_len <= '0';
                  to_4k_len         <= (others => '0');
                  state             <= IDLE;
               end if;


            when HEADER_TO_FIFO =>
               tx_fifo_wr_head_clr    <= '0';
               tx_fifo_w_data_clr     <= '0';
               tx_fifo_wr_head_en_int <= '1';
               tx_fifo_w_data_enable  <= '0';
               rx_fifo_c_rd_enable    <= '0';
               wbs_ack                <= '0';

               wr_req            <= wr_req;
               rd_req            <= rd_req;
               wr_burst          <= '0';
               put_header        <= '1';
               put_h0_h1         <= '1';
               multi_cpl         <= '0';                                        -- new read startet thus reset
               first_DW_int      <= first_DW_int;
               last_DW_int       <= last_DW_int;
               cpl_return_len    <= (others => '0');                            -- requesting new packet thus clear cpl_return_len
               rd_trans_done     <= '0';
               len_is_1024DW     <= '0';
               compare_to_4k_len <= compare_to_4k_len;
               to_4k_len         <= to_4k_len;

               -- NOTE: this setting is not always true as this state can now be entered for wr_burst as
               --       well but it has no influence on write bursts so it will remain unchanged
               if wbs_cti = "010" then
                  rd_burst <= '1';
               else
                  rd_burst <= '0';
               end if;
               ----------------------------------------------------------

               -- update address information for reads because multiple
               -- read cycles without transition to IDLE are possible
               ----------------------------------------------------------
               if put_header = '1' and put_header_q = '0' and rd_req = '1' then
                  wbs_adr_int <= wbs_adr;
               else
                  wbs_adr_int <= wbs_adr_int;
               end if;

               ------------------------------------------------------------------------------------
               -- don't clear cnt_len for writes because this info must be stored to header first
               ------------------------------------------------------------------------------------
               if wr_req = '1' then
                  cnt_len <= cnt_len;
               else
                  -- cnt_len is not used for RD headers so it may be cleared here
                  cnt_len <= (others => '0');
               end if;

               if error_timeout = '1' then
                  tx_fifo_wr_head_en_int <= '0';
                  tx_fifo_w_data_enable  <= '0';
                  rx_fifo_c_rd_enable    <= '0';
                  wbs_ack                <= '0';

                  cnt_len            <= (others => '0');
                  put_header         <= '0';
                  put_h0_h1          <= '0';
                  get_header         <= '0';
                  wr_req             <= '0';
                  rd_req             <= '0';
                  wr_burst           <= '0';
                  rd_burst           <= '0';
                  max_wr_len_reached <= '0';
                  multi_cpl          <= '0';
                  first_DW_int       <= (others => '0');
                  last_DW_int        <= (others => '0');
                  cpl_return_len     <= (others => '0');
                  rd_trans_done      <= '0';
                  len_is_1024DW      <= '0';
                  state              <= IDLE;
               elsif put_h0_h1 = '1' then
                  tx_fifo_wr_head_en_int <= '0';
                  put_header             <= '0';
                  put_h0_h1              <= '0';

                  ----------------------------------------------------------------
                  -- 1. if max write length was reached split packet by writing
                  --    header and start new PCIe packet thus return to WR_TRANS
                  -- 2. for reads write request header first then go to RD_TRANS
                  --    for multiple returned CPLDs this state should not
                  --    be entered
                  -- 3. if neither write nor read request then FIFO was full
                  --    during start of WB transaction thus return to IDLE
                  ----------------------------------------------------------------
                  if rd_req = '1' then
                     max_wr_len_reached <= '0';
                     state              <= GET_RD_HEADER;
                  elsif wr_req = '1' and max_wr_len_reached = '1' then
                     max_wr_len_reached    <= '0';
                     tx_fifo_w_data_enable <= '1';
                     wbs_ack               <= '1';
                     first_DW_int          <= x"F";                            -- set value for next wr cycle
                     state                 <= WR_TRANS;
                  else
                     wr_req             <= '0';
                     rd_req             <= '0';
                     max_wr_len_reached <= '0';
                     multi_cpl          <= '0';
                     rd_trans_done      <= '0';
                     len_is_1024DW      <= '0';
                     cpl_return_len     <= (others => '0');
                     state              <= IDLE;
                  end if;
               else
                  state <= HEADER_TO_FIFO;
               end if;

            when RD_TRANS =>
               tx_fifo_wr_head_clr    <= '0';
               tx_fifo_w_data_clr     <= '0';
               tx_fifo_wr_head_en_int <= '0';
               tx_fifo_w_data_enable  <= '0';
               rx_fifo_c_rd_enable    <= '1';
               wbs_ack                <= '1';

               wbs_adr_int        <= wbs_adr_int;
               put_header         <= '0';
               put_h0_h1          <= '0';
               wr_req             <= '0';
               rd_burst           <= rd_burst;
               wr_burst           <= '0';
               max_wr_len_reached <= '0';
               first_DW_int       <= first_DW_int;                             -- unused for read requests
               last_DW_int        <= last_DW_int;                              -- unused for read requests
               cnt_len            <= std_logic_vector(unsigned(cnt_len) + to_unsigned(1,10));
               cpl_return_len     <= cpl_return_len;
               len_is_1024DW      <= len_is_1024DW;

               --------------------------------------------------------------------------------
               -- there are several possible transitions:
               -- 1. CPLD length is the same as PCIE_REQUEST_LENGTH
               -- 1a. aligned address and even length      => no action
               -- 1b. aligned address and odd length       => drop 1 dummy packet from RX FIFO
               -- 1c. not aligned address and even length  => drop 1 dummy packet from RX FIFO
               -- 1d. not aligned address and odd length   => no action
               -- 2. CPLD length is smaller than PCIE_REQUEST_LENGTH (multiple CPLDs)
               -- 2a. return to GET_RD_HEADER and wait for next packet
               -- 2b. don't write a new header to TX header FIFO
               -- 2c. manage address and length as described in 1.
               -- 3. WBM finishes transfer while more data packets are in RX FIFO
               -- 3a. drop data until PCIE_REQUEST_LENGTH is reached
               -- 3b. remember that every split completion has its own header info included
               --------------------------------------------------------------------------------
               if error_timeout = '1' then
                  tx_fifo_wr_head_en_int <= '0';
                  tx_fifo_w_data_enable  <= '0';
                  rx_fifo_c_rd_enable    <= '0';
                  wbs_ack                <= '0';

                  cnt_len            <= (others => '0');
                  put_header         <= '0';
                  put_h0_h1          <= '0';
                  get_header         <= '0';
                  wr_req             <= '0';
                  rd_req             <= '0';
                  wr_burst           <= '0';
                  rd_burst           <= '0';
                  max_wr_len_reached <= '0';
                  multi_cpl          <= '0';
                  first_DW_int       <= (others => '0');
                  last_DW_int        <= (others => '0');
                  cpl_return_len     <= (others => '0');
                  rd_trans_done      <= '0';
                  len_is_1024DW      <= '0';
                  state              <= IDLE;
               elsif rx_fifo_c_empty = '1' and cnt_len < length_int then
                  rx_fifo_c_rd_enable <= '0';
                  wbs_ack             <= '0';
                  state               <= WAIT_ON_FIFO;
               -------------------------
               -- single read requests
               -------------------------
               elsif wbs_cti = ZERO_03B or (wbs_cti = FULL_03B and rd_burst = '0') then
                  -------------------------------------------------------------
                  -- aligned single requests always include a dummy packet
                  -- not aligned single requests never include a dummy packet
                  -- I/O completions are always aligned
                  -------------------------------------------------------------
                  wbs_ack       <= '0';
                  rd_trans_done <= '1';
                  if wbs_tga_q = '0' and wbs_adr_int(2) = '1' then
                     rx_fifo_c_rd_enable <= '0';
                     state               <= IDLE;
                  else
                     rx_fifo_c_rd_enable <= '1';
                     state               <= DROP_DATA;
                  end if;

               -----------------
               -- end of burst
               -----------------
               elsif wbs_cti = FULL_03B and rd_burst = '1' then
                  wbs_ack       <= '0';
                  rd_trans_done <= '1';
                  -------------------------------------------------------------------
                  -- requested length is reached and data is transferred completely
                  -- drop dummy packet for aligned & odd or !aligned & even
                  -------------------------------------------------------------------
                  if cpl_return_len = requested_len and cnt_len = length_int then
                     if (wbs_adr_int(2) = '0' and length_int(0) = '0') or
                        (wbs_adr_int(2) = '1' and length_int(0) = '1') then
                        rx_fifo_c_rd_enable <= '0';
                        state               <= IDLE;
                     elsif (wbs_adr_int(2) = '0' and length_int(0) = '1') or
                           (wbs_adr_int(2) = '1' and length_int(0) = '0') then
                        state <= DROP_DATA;
                     end if;
                  ---------------------------------------------------------------------------
                  -- drop all outstanding CPLDs but capture header thus go to GET_RD_HEADER
                  -- from there we'll go to DROP_DATA again
                  ---------------------------------------------------------------------------
                  elsif cpl_return_len < requested_len and cnt_len = length_int then
                     rx_fifo_c_rd_enable <= '0';
                     state               <= GET_RD_HEADER;

                  ---------------------------------
                  -- drop all outstanding packets
                  ---------------------------------
                  else
                     state <= DROP_DATA;
                  end if;
               -----------------------
               -- burst still active
               -----------------------
               else
                  -----------------------------------------------------------------------------
                  -- when first_rd_cycle is asserted and cnt_len =0 this is a 1024DW transfer
                  -- -> remain in RD_TRANS
                  --    in case of PCIE_REQUEST_LENGTH = 1024 and full transfer then
                  --    cpl_return_len =0 and cpl_return_len = cnt_len would be true right
                  --    and we would transition to IDLE too early
                  -----------------------------------------------------------------------------
                  if first_rd_cycle = '1' and cnt_len = ZERO_10B then
                     state <= RD_TRANS;
                  elsif cnt_len = length_int and cpl_return_len = requested_len then
                     wbs_ack <= '0';
                     ------------------------------------------
                     -- check if dummy packet must be removed
                     ------------------------------------------
                     if (wbs_adr_int(2) = '0' and length_int(0) = '1') or
                        (wbs_adr_int(2) = '1' and length_int(0) = '0') then
                        state <= DROP_DATA;
                     else
                        ----------------------------------------------------------------------------------------
                        -- calculate length to 4k boundary:
                        -- wbs_adr[12] denotes 4k boundary which is 0x1000
                        -- maximum transfer length is 1024DW = 1024 *4B = 4096B := 0x1000
                        -- => if wbs_adr[11:0] = 0b000 then all lenghts are ok
                        --    otherwise calculate length offset to next 4k boundary, use to_4k_len as DW counter
                        -- subtracting wbs_adr from the next 4k boundary results in a byte value
                        -- -> use 1024 instead of 4096 to calculated DW counter instead of byte counter
                        --    ! manage first_DW_be and last_DW_be accordingly
                        -- wbs_adr is the last transferred address here so to_4k_len must be reduced by 4bytes
                        ----------------------------------------------------------------------------------------
                        --if wbs_adr(11 downto 0) = x"000" then
                        if (unsigned(wbs_adr(11 downto 0)) + to_unsigned(4,12)) = x"000" then
                           compare_to_4k_len <= '0';
                           to_4k_len         <= (others => '0');
                        else
                           compare_to_4k_len <= '1';
                           to_4k_len     <= std_logic_vector(to_unsigned((1024 - to_integer(unsigned(wbs_adr(11 downto 2))) -1), 10));
                        end if;

                        tx_fifo_wr_head_en_int <= '1';
                        rx_fifo_c_rd_enable    <= '0';
                        wbs_ack                <= '0';
                        put_header             <= '1';
                        state                  <= HEADER_TO_FIFO;
                     end if;
                  elsif cnt_len = length_int and cpl_return_len < requested_len then
                     wbs_ack <= '0';
                     if (wbs_adr_int(2) = '0' and length_int(0) = '1') or
                        (wbs_adr_int(2) = '1' and length_int(0) = '0') then
                        state <= DROP_DATA;
                     else
                        rx_fifo_c_rd_enable <= '0';
                        state               <= GET_RD_HEADER;
                     end if;
                  else
                     state <= RD_TRANS;
                  end if;
               end if;

            when WR_TRANS =>
               tx_fifo_wr_head_clr    <= '0';
               tx_fifo_w_data_clr     <= '0';
               tx_fifo_wr_head_en_int <= '0';
               tx_fifo_w_data_enable  <= '1';
               rx_fifo_c_rd_enable    <= '0';
               wbs_ack                <= '1';

               put_header        <= '0';
               put_h0_h1         <= '0';
               wr_req            <= '1';
               rd_req            <= '0';
               multi_cpl         <= '0';
               cnt_len           <= std_logic_vector(unsigned(cnt_len) + to_unsigned(1,10));
               cpl_return_len    <= (others => '0');
               rd_trans_done     <= '0';
               len_is_1024DW     <= '0';
               wbs_adr_int       <= wbs_adr_int;
               first_DW_int      <= first_DW_int;
               compare_to_4k_len <= compare_to_4k_len;
               to_4k_len         <= to_4k_len;

               if cnt_len = FULL_10B then
                  max_wr_len_reached <= '1';
               else
                  max_wr_len_reached <= '0';
               end if;

               -------------------------------------------------------------
               -- stop transfer upon error timeout
               -- if TX data FIFO is full suspend until space is available
               -- cti = "000" and cti = "111" signal end of transfer thus
               --   put header to FIFO
               -- cti = "010" states ongoing burst thus stay here
               -- if max wr length is reached put header to FIFO
               -------------------------------------------------------------
               if error_timeout = '1' then
                  tx_fifo_wr_head_en_int <= '0';
                  tx_fifo_w_data_enable  <= '0';
                  rx_fifo_c_rd_enable    <= '0';
                  wbs_ack                <= '0';

                  cnt_len            <= (others => '0');
                  put_header         <= '0';
                  put_h0_h1          <= '0';
                  get_header         <= '0';
                  wr_req             <= '0';
                  rd_req             <= '0';
                  wr_burst           <= '0';
                  rd_burst           <= '0';
                  max_wr_len_reached <= '0';
                  multi_cpl          <= '0';
                  first_DW_int       <= (others => '0');
                  last_DW_int        <= (others => '0');
                  cpl_return_len     <= (others => '0');
                  rd_trans_done      <= '0';
                  len_is_1024DW      <= '0';
                  state              <= IDLE;
               elsif tx_fifo_w_data_usedw >= SUSPEND_FIFO_ACCESS then
                  if cnt_len(0) = '1' then
                     tx_fifo_w_data_enable <= '1';
                  else
                     tx_fifo_w_data_enable <= '0';
                  end if;
                  tx_fifo_wr_head_en_int <= '1';
                  rx_fifo_c_rd_enable    <= '0';
                  wbs_ack                <= '0';
                  put_header             <= '1';

                  -- full FIFO and last packet of transfer could coincide and would not be covered here so use wbs_sel instead of 0xF
                  -- if cnt_len = 0x1 then last_DW_int must be 0x0 as single transfers only contain first_DW_int
                  if cnt_len = ONE_10B then
                     last_DW_int <= x"0";
                  else
                     last_DW_int <= wbs_sel;
                  end if;

                  state <= HEADER_TO_FIFO;
               elsif wbs_cti = "010" then
                  wr_burst <= '1';

                  if max_wr_len_reached = '1' or (compare_to_4k_len = '1' and cnt_len = to_4k_len) then
                     -- store dummy packet if to_4k_len is not even, max_wr_len_reached should result in even length
                     if cnt_len(0) = '1' then
                        tx_fifo_w_data_enable <= '1';
                     else
                        tx_fifo_w_data_enable  <= '0';
                     end if;

                     -- if cnt_len = 0x1 then last_DW_int must be 0x0 as single transfers only contain first_DW_int
                     if cnt_len = ONE_10B then
                        last_DW_int <= x"0";
                     else
                        last_DW_int <= x"F";
                     end if;

                     tx_fifo_wr_head_en_int <= '1';
                     rx_fifo_c_rd_enable    <= '0';
                     wbs_ack                <= '0';
                     put_header             <= '1';
                     state                  <= HEADER_TO_FIFO;
                  else
                     state <= WR_TRANS;
                  end if;
               else
                  wr_burst <= '0';
                  ---------------------------------------------------------
                  -- odd lengths need one dummy packet so that 64bit side
                  -- can take the data from the FIFO
                  ---------------------------------------------------------
                  if cnt_len(0) = '1' then
                     tx_fifo_w_data_enable <= '1';
                  else
                     tx_fifo_w_data_enable <= '0';
                  end if;

                  ----------------------------------------
                  -- for single writes last_DW must be 0
                  ----------------------------------------
--TODO ITEM cti=111 is a valid equivalent for cti=000 for single!
-- idea: use signal which is set if cti=010 and which remains active (e.g. registered) to qualify cti=111 as either
--       single (extra signal=0) or burst (extra signal=1)
                  if wbs_cti = FULL_03B and wr_burst = '1' then
                     last_DW_int <= wbs_sel;
                  else
                     last_DW_int <= (others => '0');
                  end if;

                  tx_fifo_wr_head_en_int <= '1';
                  rx_fifo_c_rd_enable    <= '0';
                  wbs_ack                <= '0';
                  put_header             <= '1';
                  state                  <= HEADER_TO_FIFO;
               end if;

            when WAIT_ON_FIFO =>
               tx_fifo_wr_head_clr    <= '0';
               tx_fifo_w_data_clr     <= '0';
               tx_fifo_wr_head_en_int <= '0';
               tx_fifo_w_data_enable  <= '0';
               rx_fifo_c_rd_enable    <= '0';
               wbs_ack                <= '0';

               wbs_adr_int        <= wbs_adr_int;
               put_header         <= '0';
               put_h0_h1          <= '0';
               wr_req             <= wr_req;
               rd_req             <= rd_req;
               wr_burst           <= wr_burst;
               max_wr_len_reached <= '0';
               multi_cpl          <= multi_cpl;
               first_DW_int       <= first_DW_int;
               cnt_len            <= cnt_len;
               cpl_return_len     <= cpl_return_len;
               rd_trans_done      <= rd_trans_done;
               len_is_1024DW      <= len_is_1024DW;
               compare_to_4k_len  <= compare_to_4k_len;
               to_4k_len          <= to_4k_len;

               ---------------------------------------------------------
               -- if wr_req and rd_req =0 then previous state was IDLE
               -- else return to RD_TRANS or WR_TRANS respectively
               ---------------------------------------------------------
               --------------------------------------------------------
               -- for writes several FIFO states occur:
               -- 1. from IDLE because TX data FIFO is full
               --    wr_req is still 0 as this is set during WR_TRANS
               -- 2. from WR_TRANS because data FIFO is full
               --    this is managed by SUSPEND_FIFO_ACCESS and
               --    RESUME_FIFO_ACCESS and wr_req = 1
               --------------------------------------------------------
               if error_timeout = '1' then
                  tx_fifo_wr_head_en_int <= '0';
                  tx_fifo_w_data_enable  <= '0';
                  rx_fifo_c_rd_enable    <= '0';
                  wbs_ack                <= '0';

                  cnt_len            <= (others => '0');
                  put_header         <= '0';
                  put_h0_h1          <= '0';
                  get_header         <= '0';
                  wr_req             <= '0';
                  rd_req             <= '0';
                  wr_burst           <= '0';
                  rd_burst           <= '0';
                  max_wr_len_reached <= '0';
                  multi_cpl          <= '0';
                  first_DW_int       <= (others => '0');
                  last_DW_int        <= (others => '0');
                  cpl_return_len     <= (others => '0');
                  rd_trans_done      <= '0';
                  len_is_1024DW      <= '0';
                  state              <= IDLE;
               elsif wr_req = '1' and tx_fifo_w_data_full = '0' and tx_fifo_w_data_usedw <= RESUME_FIFO_ACCESS then
                  tx_fifo_w_data_enable <= '1';
                  wbs_ack               <= '1';
                  state                 <= WR_TRANS;
               ------------------------------------------------------------------
               -- for reads several FIFO states occur:
               -- 1. from IDLE because TX header FIFO is full
               --    rd_req is still 0 as this is set during HEADER_TO_FIFO
               -- 2. from RD_TRANS because RX FIFO is empty
               --    rd_req = 1
               -- 2a. because PCIE_REQUEST_LENGTH is transferred
               --     multi_cpl= 0
               -- 2b. because root splits PCIE_REQUEST_LENGTH into several CPLD
               --     multi_cpl= 1
               -- 2c. because WBM requests more than PCIE_REQUEST_LENGTH
               --     cnt_len = PCIE_REQUEST_LENGTH and wbs_cti /= 111
               ------------------------------------------------------------------
               elsif rd_req = '1' and multi_cpl = '0' and tx_fifo_wr_head_full = '0' then
                  rx_fifo_c_rd_enable <= '1';
                  wbs_ack             <= '1';
                  state               <= RD_TRANS;
               elsif rd_req = '1' and multi_cpl = '1' and rx_fifo_c_empty = '0' then
                  state <= GET_RD_HEADER;
               elsif wr_req = '0' and rd_req = '0' and tx_fifo_w_data_full = '0' and tx_fifo_w_data_usedw <= RESUME_FIFO_ACCESS and tx_fifo_wr_head_full = '0' then
                  state <= IDLE;
               else
                  state <= WAIT_ON_FIFO;
               end if;

            when GET_RD_HEADER =>
               tx_fifo_wr_head_clr    <= '0';
               tx_fifo_w_data_clr     <= '0';
               tx_fifo_wr_head_en_int <= '0';
               tx_fifo_w_data_enable  <= '0';
               wbs_ack                <= '0';

               put_header         <= '0';
               put_h0_h1          <= '0';
               wr_req             <= '0';
               rd_req             <= '1';
               wr_burst           <= '0';
               max_wr_len_reached <= '0';
               first_DW_int       <= first_DW_int;
               cnt_len            <= ONE_10B;
               rd_trans_done      <= rd_trans_done;
               compare_to_4k_len  <= compare_to_4k_len;
               to_4k_len          <= to_4k_len;

               ------------------------------------------------------------------------
               -- update internal address for multiple CPLDs to manage FIFO correctly
               -- shifting length_int left by 2 is the same as *4
               -- update wbs_adr_int on last valid cycle of length_int which is
               -- before any header updates thus check for all get_headers=0
               ------------------------------------------------------------------------
               if multi_cpl = '1' and rx_fifo_c_empty = '0' and get_header = '0' and get_header_q = '0' and get_header_qq = '0' and get_header_qqq = '0' then
                  wbs_adr_int <= std_logic_vector(unsigned(wbs_adr_int) + unsigned(length_int(7 downto 0) & "00"));
               else
                  wbs_adr_int <= wbs_adr_int;
               end if;

               if rx_fifo_c_empty = '0' then
                  rx_fifo_c_rd_enable <= '1';
               else
                  rx_fifo_c_rd_enable <= '0';
               end if;

               -----------------------------------------------------------------------------------
               -- as multiple completions can occur add actual transfer length to cpl_return_len
               -----------------------------------------------------------------------------------
               if get_header = '1' then
                  cpl_return_len <= std_logic_vector(unsigned(cpl_return_len) + unsigned(length_int));
               end if;

               if get_header = '1' and get_header_q = '0' then
                  get_header <= '0';
               elsif rx_fifo_c_empty = '0' and get_header_q = '0' and get_header_qq = '0' and get_header_qqq = '0' then
                  get_header <= '1';
               end if;

               ------------------------------------------
               -- capture if multiple CPLD will be send
               -- relevant for bursts only
               ------------------------------------------
               --if get_header_q = '1' and rd_burst = '1' and cpl_return_len < requested_len then
               if get_header_q = '1' and rd_burst = '1' and (
                  (requested_len /= ZERO_10B and cpl_return_len < requested_len) or
                  (requested_len = ZERO_10B and cpl_return_len > requested_len)) then
                  multi_cpl <= '1';
               end if;

               --------------------------------------
               -- 1024DW is encoded as length_int=0
               -- decode to enable comparison with
               -- cnt_len in RD_TRANS as cnt_len
               -- has 0 as reset value
               --------------------------------------
               if get_header_q = '1' and length_int = ZERO_10B then
                  len_is_1024DW <= '1';
               elsif get_header_q = '1' and length_int > ZERO_10B then
                  len_is_1024DW <= '0';
               else
                  len_is_1024DW <= len_is_1024DW;
               end if;

               if error_timeout = '1' then
                  tx_fifo_wr_head_en_int <= '0';
                  tx_fifo_w_data_enable  <= '0';
                  rx_fifo_c_rd_enable    <= '0';
                  wbs_ack                <= '0';

                  cnt_len            <= (others => '0');
                  put_header         <= '0';
                  put_h0_h1          <= '0';
                  get_header         <= '0';
                  wr_req             <= '0';
                  rd_req             <= '0';
                  wr_burst           <= '0';
                  rd_burst           <= '0';
                  max_wr_len_reached <= '0';
                  multi_cpl          <= '0';
                  first_DW_int       <= (others => '0');
                  last_DW_int        <= (others => '0');
                  cpl_return_len     <= (others => '0');
                  rd_trans_done      <= '0';
                  len_is_1024DW      <= '0';
                  state              <= IDLE;
               ----------------------------------------------
               -- WB transaction done but outstanding CPLDs
               -- -> burst only
               ----------------------------------------------
               elsif multi_cpl = '1' and rd_trans_done = '1' and ((wbs_adr_int(2) = '0' and get_header_qqq = '1') or (wbs_adr_int(2) = '1' and get_header_qq = '1')) then
                  state <= DROP_DATA;
               ------------------------------------------------------------
               -- RX FIFO contains 4 header packets if address is aligned
               -- else 3 header packets
               -- I/O completions always return with lower address =0
               -- thus they are always aligned!
               ------------------------------------------------------------
               elsif (wbs_tga_q = '0' and ((wbs_adr_int(2) = '0' and get_header_qqq = '1') or (wbs_adr_int(2) = '1' and get_header_qq = '1'))) or
                     (wbs_tga_q = '1' and get_header_qqq = '1') then
                  rx_fifo_c_rd_enable <= '1';
                  wbs_ack             <= '1';
                  state <= RD_TRANS;
               else
                  state <= GET_RD_HEADER;
               end if;

            when DROP_DATA =>
               tx_fifo_wr_head_clr    <= '0';
               tx_fifo_w_data_clr     <= '0';
               tx_fifo_wr_head_en_int <= '0';
               tx_fifo_w_data_enable  <= '0';
               rx_fifo_c_rd_enable    <= '1';
               wbs_ack                <= '0';

               wbs_adr_int        <= wbs_adr_int;
               put_header         <= '0';
               put_h0_h1          <= '0';
               wr_req             <= wr_req;
               rd_req             <= rd_req;
               wr_burst           <= wr_burst;
               max_wr_len_reached <= '0';
               multi_cpl          <= multi_cpl;
               first_DW_int       <= first_DW_int;
               last_DW_int        <= last_DW_int;
               cpl_return_len     <= cpl_return_len;
               rd_trans_done      <= rd_trans_done;
               len_is_1024DW      <= len_is_1024DW;
               compare_to_4k_len  <= compare_to_4k_len;
               to_4k_len          <= to_4k_len;

               -----------------------------------------------------
               -- remain in DROP_DATA and don't go to WAIT ON FIFO
               -- if FIFO is not ready
               -----------------------------------------------------
               if rx_fifo_c_empty = '0' then
                  cnt_len <= std_logic_vector(unsigned(cnt_len) + to_unsigned(1,10));
               end if;

               -------------------------------------------------------------------------------------
               -- for I/O completions just drop one packet then go to IDLE
               -- for single transmission return to IDLE when all data packets are taken from FIFO
               -- for multiple CPLDs 
               -- 1. drop dummy data packet at the end of RD_TRANS before GET_RD_HEADER
               -- 2. drop data packets because WB transaction is done including possible
               --    dummy packet
               -- as cnt_len now starts with 1 cnt_len can have the value cnt_len +1 = length_int
               -- thus use >= for comparison
               -------------------------------------------------------------------------------------
               if error_timeout = '1' then
                  tx_fifo_wr_head_en_int <= '0';
                  tx_fifo_w_data_enable  <= '0';
                  rx_fifo_c_rd_enable    <= '0';
                  wbs_ack                <= '0';

                  cnt_len            <= (others => '0');
                  put_header         <= '0';
                  put_h0_h1          <= '0';
                  get_header         <= '0';
                  wr_req             <= '0';
                  rd_req             <= '0';
                  wr_burst           <= '0';
                  rd_burst           <= '0';
                  max_wr_len_reached <= '0';
                  multi_cpl          <= '0';
                  first_DW_int       <= (others => '0');
                  last_DW_int        <= (others => '0');
                  cpl_return_len     <= (others => '0');
                  rd_trans_done      <= '0';
                  len_is_1024DW      <= '0';
                  state              <= IDLE;
               elsif wbs_tga_q = '1' then
                  rx_fifo_c_rd_enable <= '0';
                  state               <= IDLE;
               ------------------------------
               -- no dummy packet to remove
               ------------------------------
               elsif cnt_len = length_int and (
                  (wbs_adr_int(2) = '0' and length_int(0) = '0') or
                  (wbs_adr_int(2) = '1' and length_int(0) = '1') ) then

                  if multi_cpl = '0' or (multi_cpl = '1' and cpl_return_len = requested_len) then
                     rx_fifo_c_rd_enable <= '0';
                     state               <= IDLE;
                  elsif multi_cpl = '1' and cpl_return_len < requested_len then
                     rx_fifo_c_rd_enable <= '0';
                     state               <= GET_RD_HEADER;
                  else
                     state <= DROP_DATA;
                  end if;
               ---------------------------
               -- dummy packet to remove
               ---------------------------
               elsif cnt_len > length_int and (
                  (wbs_adr_int(2) = '0' and length_int(0) = '1') or
                  (wbs_adr_int(2) = '1' and length_int(0) = '0') ) then

                  if multi_cpl = '0' or (multi_cpl = '1' and cpl_return_len = requested_len) then
                     rx_fifo_c_rd_enable <= '0';
                     state               <= IDLE;
                  elsif multi_cpl = '1' and cpl_return_len < requested_len then
                     rx_fifo_c_rd_enable <= '0';
                     state               <= GET_RD_HEADER;
                  else
                     state <= DROP_DATA;
                  end if;
               -------------------------------------
               -- length to remove not reached yet
               -------------------------------------
               else
                  state <= DROP_DATA;
               end if;

         -- coverage off
         when others =>
            -- synthesis translate_off
            wbs_ack           <= '0';
            compare_to_4k_len <= '0';
            to_4k_len         <= (others => '0');
            state             <= IDLE;
            report "wrong state encoding in process fsm_transout of z091_01_wb_slave.vhd" severity error;
            -- synthesis translate_on
         -- coverage on
         end case;
      end if;
   end process fsm_transout;

-------------------------------------------------------------------------------

   wbs_data : process(wb_rst, wb_clk)
   begin
      if wb_rst = '1' then
         requested_len      <= (others => '0');
         tx_fifo_wr_head_in <= (others => '0');
         length_int         <= (others => '0');
         act_read_size      <= (others => '0');

      elsif wb_clk'event and wb_clk = '1' then
         -------------------------------------------------------------------------------------
         -- compose the actual maximum read size out of PCIE_REQUEST_LENGTH and max_read_len
         -- CAUTION: max_read_len may not change during an ongoing burst!
         -------------------------------------------------------------------------------------
         if max_read_len = "0000000000" then
            act_read_size <= PCIE_REQUEST_LENGTH;
         elsif PCIE_REQUEST_LENGTH > max_read_len or PCIE_REQUEST_LENGTH = "0000000000" then
            act_read_size <= max_read_len;
         else
            act_read_size <= PCIE_REQUEST_LENGTH;
         end if;

         -------------------------------------------------
         -- assemble write request specific header parts
         -------------------------------------------------
         if(put_header = '1' and put_h0_h1 = '0' and wr_req = '1') then
            requested_len          <= (others => '0');
            tx_fifo_wr_head_in(31) <= '1';

            --------------------------------------------------
            -- write request is done when header is composed
            -- thus use registered copy of tga
            --------------------------------------------------
            if(wbs_tga = '0') then                                            -- memory
               tx_fifo_wr_head_in(30) <= '1';
               tx_fifo_wr_head_in(29) <= '1';
            else                                                                -- I/O
               tx_fifo_wr_head_in(30) <= '0';
               tx_fifo_wr_head_in(29) <= '0';
            end if;
            tx_fifo_wr_head_in(28 downto 18) <= "00000000000";
            tx_fifo_wr_head_in(17 downto 14) <= first_DW_int;
            tx_fifo_wr_head_in(13 downto 10) <= last_DW_int;
            ---------------------------------------------------------------------------------
            -- cnt_len counts to one more while transitioning to next state thus subtract 1
            ---------------------------------------------------------------------------------
            tx_fifo_wr_head_in(9 downto 0) <= std_logic_vector(unsigned(cnt_len) - to_unsigned(1,10));
         ------------------------------------------------
         -- assemble read request specific header parts
         ------------------------------------------------
         elsif(put_header = '1' and put_h0_h1 = '0' and rd_req = '1') then
            tx_fifo_wr_head_in(31) <= '0';
            tx_fifo_wr_head_in(30) <= '0';
            if(wbs_tga              = '0') then                                 -- memory
               tx_fifo_wr_head_in(29) <= '1';
            else                                                                -- I/O
               tx_fifo_wr_head_in(29) <= '0';
            end if;
            tx_fifo_wr_head_in(28 downto 18) <= "00000000000";
            ---------------------------------------
            -- always request all bytes for reads
            -- WBM will chose later
            ---------------------------------------
            tx_fifo_wr_head_in(17 downto 14) <= x"F";                           -- first_DW

            ---------------------------------------------------------------------------------------------------------------------------
            -- if PCIE_REQUEST_LENGTH is max (=0), max_read_len is either =0 too then maximum size is allowed or max_read_len is /= 0
            -- then max_read_len must be used -> using max_read_len for both cases is always correct
            -- otherwise PCIE_REQUEST_LENGTH is only allowed if <= max_read_len
            -- all values may not exceed to_4k_len if it has to be obeyed which is denoted by compare_to_4k_len
            ---------------------------------------------------------------------------------------------------------------------------
            if wbs_cti = "000" or wbs_cti = "111" then
               requested_len                  <= "0000000001";
               tx_fifo_wr_head_in(9 downto 0) <= "0000000001";
               --------------------------------
               -- for single read last_DW =0!
               --------------------------------
               tx_fifo_wr_head_in(13 downto 10) <= x"0";                        -- last_DW
            else
               tx_fifo_wr_head_in(13 downto 10) <= x"F";                        -- last_DW

               
               if compare_to_4k_len = '1' then
                  if act_read_size <= to_4k_len then
                     tx_fifo_wr_head_in(9 downto 0) <= act_read_size;
                     requested_len                  <= act_read_size;
                  else
                     requested_len                  <= to_4k_len;
                     tx_fifo_wr_head_in(9 downto 0) <= to_4k_len;
                  end if;                     
               else
                  tx_fifo_wr_head_in(9 downto 0) <= act_read_size;
                  requested_len                  <= act_read_size;
               end if;
               --if compare_to_4k_len = '1' and to_4k_len /= "0000000000" then
               --   if PCIE_REQUEST_LENGTH <= max_read_len and PCIE_REQUEST_LENGTH <= to_4k_len then
               --      requested_len                    <= PCIE_REQUEST_LENGTH;
               --      tx_fifo_wr_head_in(9 downto 0)   <= PCIE_REQUEST_LENGTH;
               --   elsif PCIE_REQUEST_LENGTH <= max_read_len and PCIE_REQUEST_LENGTH > to_4k_len then
               --      requested_len                  <= to_4k_len;
               --      tx_fifo_wr_head_in(9 downto 0) <= to_4k_len;
               --   elsif PCIE_REQUEST_LENGTH > max_read_len and max_read_len > to_4k_len then
               --      requested_len                  <= to_4k_len;
               --      tx_fifo_wr_head_in(9 downto 0) <= to_4k_len;
               --   else
               --      requested_len                    <= max_read_len;
               --      tx_fifo_wr_head_in(9 downto 0)   <= max_read_len;
               --   end if;
               --else
               --   if(PCIE_REQUEST_LENGTH = "0000000000") then
               --      requested_len                  <= max_read_len;
               --      tx_fifo_wr_head_in(9 downto 0) <= max_read_len;
               --   elsif(PCIE_REQUEST_LENGTH <= max_read_len or max_read_len = "0000000000") then
               --      requested_len                  <= PCIE_REQUEST_LENGTH;
               --      tx_fifo_wr_head_in(9 downto 0) <= PCIE_REQUEST_LENGTH;
               --   else
               --      requested_len                  <= max_read_len;
               --      tx_fifo_wr_head_in(9 downto 0) <= max_read_len;
               --   end if;
               --end if;
               
            end if;
         ------------------------------------------------------------------------------
         -- length is for both read and write requests at the same position in header
         ------------------------------------------------------------------------------
         elsif(put_header = '1' and put_h0_h1 = '1') then
            requested_len      <= requested_len;
            tx_fifo_wr_head_in <= wbs_adr_int(31 downto 2) & "00";
         end if;
         
         -------------------------------------------
         -- store length of this completion packet
         -------------------------------------------
         if state = GET_RD_HEADER and rx_fifo_c_empty = '0' and get_header = '0' and get_header_q = '0' and get_header_qq = '0' and get_header_qqq = '0' then
            length_int <= rx_fifo_c_out(9 downto 0);
         end if;
      end if;
   
   end process wbs_data;
end architecture z091_01_wb_slave_arch;
