--------------------------------------------------------------------------------
-- Title       : tx_ctrl
-- Project     : 16z091-01
--------------------------------------------------------------------------------
-- File        : tx_ctrl.vhd
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 09.12.2010
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6a / ModelSim AE 6.5e sp1
-- Synthesis   : 
--------------------------------------------------------------------------------
-- Description : 
-- this module controls all actions within the TxModule, including power 
-- messages and information given by the init module
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
-- *        tx_ctrl
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

library work;
use work.src_utils_pkg.all;

entity tx_ctrl is
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
      c_wrrd            : out std_logic;                                         -- =0: completion, =1: write or read
      completer_id      : out std_logic_vector(15 downto 0);
      own_id            : out std_logic_vector(15 downto 0);
      abort_compl       : out std_logic;
      send_len          : out std_logic_vector(9 downto 0);                      -- length of actual packet, stored to header
      send_addr         : out std_logic_vector(31 downto 0);                     -- address of actual packet, stored to header
      payload_loop      : out std_logic;                                         -- =0: no loop, =1: loop
      first_last_full   : out std_logic_vector(1 downto 0);                      -- 00: unused, 01: first packet of payload_loop, 01: last
                                                                                 -- packet of payload_loop, 11: all enabled

      -- tx_compl_timeout
      start             : out std_logic;
      start_tag_nbr     : out std_logic_vector(4 downto 0);
      
      -- error
      compl_abort       : out std_logic;
      
      -- init
      bus_dev_func      : in  std_logic_vector(15 downto 0);
      max_payload       : in  std_logic_vector(2 downto 0)
   );
end entity tx_ctrl;

-- ****************************************************************************

architecture tx_ctrl_arch of tx_ctrl is

-- FSM state encoding ---------------------------------------------------------
type fsm_state is (
   PREP_HEADER, IDLE, PREP_TRANS, START_TRANS, TRANSMIT, PME_OFF, TAG_START, ABORT, IO_WR
);
signal state : fsm_state;
-------------------------------------------------------------------------------

-- constants ------------------------------------------------------------------
constant ADDR_INCR : std_logic_vector(31 downto 0) := x"00000008"; 
-------------------------------------------------------------------------------

-- internal signals -----------------------------------------------------------
signal data_from_fifo   : std_logic_vector(10 downto 0);
signal desired_len      : std_logic_vector(10 downto 0);
signal data_to_ava      : std_logic_vector(11 downto 0);
signal ready_q          : std_logic;
signal wait_clk         : integer range 3 downto 0 := 0;
signal pme_off_int      : std_logic;
signal c_wr_int         : std_logic;
signal tag_nbr_cntr     : std_logic_vector(4 downto 0);
signal data_enable_int  : std_logic;
signal fifo_enable_int  : std_logic;
signal own_id_int       : std_logic_vector(15 downto 0);
signal abort_compl_int  : std_logic;
signal max_payload_len  : std_logic_vector(9 downto 0);
signal payload_loop_en  : std_logic;
signal addr_int         : std_logic_vector(31 downto 0);
signal addr_offset      : std_logic_vector(31 downto 0);
signal eop_int          : std_logic;
signal get_last_packet  : std_logic;
signal tx_st_valid0_int : std_logic;
signal send_len_int     : std_logic_vector(9 downto 0);
signal arbit_access     : std_logic_vector(1 downto 0);                          -- 00: invalid, 01: cpl, 10: wr/rd
-------------------------------------------------------------------------------

begin

   -- unused signal, set to zero
   tx_st_err0 <= '0';
   
   -- decode max_payload
   with max_payload select
      max_payload_len <=   "0001000000" when "001",
                           "0010000000" when "010",
                           "0100000000" when "011",
                           "1000000000" when "100",
                           "0000000000" when "101",
                           "0000100000" when others;
                           
   data_enable  <= data_enable_int;
   c_wrrd       <= c_wr_int;
   abort_compl  <= abort_compl_int;
   tx_st_valid0 <= tx_st_valid0_int;
   send_len     <= send_len_int;
-------------------------------------------------------------------------------
   fsm_trans : process(rst, clk)
   
   begin
      if(rst = '1') then
         state <= IDLE;
      elsif(clk'event and clk = '1') then
         case state is
            when IDLE =>
               if(arbit_access /= "00") then
                  state <= PREP_TRANS;
               elsif(pme_off_int = '1') then
                  state <= PME_OFF;
               else
                  state <= IDLE;
               end if;
               
            when PREP_HEADER =>
               if(wait_clk = 3) then
                  state <= START_TRANS;
               else
                  state <= PREP_HEADER;
               end if;
               
            when PREP_TRANS =>
               if(wait_clk = 1 and c_wr_int = '1') then
                  state <= PREP_HEADER;
               elsif(wait_clk = 2 and c_wr_int = '0') then
                  state <= PREP_HEADER;
               else
                  state <= PREP_TRANS;
               end if;
            
            when START_TRANS =>
               if(ready_q = '1') then
                  state <= TRANSMIT;
               else
                  state <= START_TRANS;
               end if;
               
            when TRANSMIT =>
               if(io_write = '1') then
                  state <= IO_WR;
               elsif(data_to_ava <= TWO_12B and c_wr_int = '1' and wr_rd = '1') then
                  state <= TAG_START;
               elsif(data_to_ava <= TWO_12B and c_wr_int = '0' and abort_compl_int = '1') then
                  state <= ABORT;
               -- no loop on completion as read requests with length > max_payload_len are rejected
               -- if looped write is finished (payload_loop_en = 0) go to IDLE as well
               elsif(ready_q = '1' and (c_wr_int = '0' or (c_wr_int = '1' and wr_rd = '0' and payload_loop_en = '0')) and 
                    ((data_to_ava <= TWO_12B and ((aligned = '1' and send_len_int(0) = '0') or (aligned = '0' and send_len_int(0) = '1'))) or 
                       (data_to_ava <= ONE_12B and ((aligned = '1' and send_len_int(0) = '1') or (aligned = '0' and send_len_int(0) = '0')))) ) then
                  state <= IDLE;
               elsif(data_to_ava <= TWO_12B and c_wr_int = '1' and wr_rd = '0' and payload_loop_en = '1' and tx_st_valid0_int = '1') then
                  state <= PREP_HEADER;
               else
                  state <= TRANSMIT;
               end if;
               
            when PME_OFF =>
               state <= IDLE;
               
            when TAG_START =>
               -- transmission is done so process received power off request now
               if(pme_off_int = '1' or pme_to_sr = '1') then
                  state <= PME_OFF;
               elsif(payload_loop_en = '1') then
                  state <= PREP_HEADER;
               else
                  state <= IDLE;
               end if;
               
            when ABORT =>
               -- transmission is done so process received power off request now
               if(pme_off_int = '1' or pme_to_sr = '1') then
                  state <= PME_OFF;
               elsif(data_from_fifo <= TWO_11B) then
                  state <= IDLE;
               else
                  state <= ABORT;
               end if;
            
            when IO_WR =>
               -- transmission is done so process received power off request now
               if(pme_off_int = '1' or pme_to_sr = '1') then
                  state <= PME_OFF;
               else
                  state <= IDLE;
               end if;
            
            -- coverage off
            when others =>
               -- synthesis translate_off
               report "undecoded state in ctrl_fsm" severity error;
               -- synthesis translate_on
            -- coverage on
         end case;
      end if;
   end process fsm_trans;
-------------------------------------------------------------------------------
   fsm_out : process(rst, clk)
   begin
      if(rst = '1') then
         tx_st_valid0_int  <= '0';
         tx_st_sop0        <= '0';
         tx_st_eop0        <= '0';
         pme_to_cr         <= '0';
         tx_c_head_enable  <= '0';
         tx_wr_head_enable <= '0';
         tx_c_data_enable  <= '0';
         tx_wr_data_enable <= '0';
         tx_tag_nbr        <= (others => '0');
         get_header        <= '0';
         get_next_header   <= '0';
         make_header       <= '0';
         data_enable_int   <= '0';
         c_wr_int          <= '0';
         completer_id      <= (others => '0');
         own_id            <= (others => '0');
         abort_compl_int   <= '0';
         send_len_int      <= (others => '0');
         send_addr         <= (others => '0');
         payload_loop      <= '0';
         first_last_full   <= (others => '0');
         start             <= '0';
         start_tag_nbr     <= (others => '0');
         compl_abort       <= '0';
         data_from_fifo    <= (others => '0');
         desired_len       <= (others => '0');
         data_to_ava       <= (others => '0');
         ready_q           <= '0';
         wait_clk          <= 0;
         pme_off_int       <= '0';
         tag_nbr_cntr      <= (others => '0');
         fifo_enable_int   <= '0';
         own_id_int        <= (others => '0');
         payload_loop_en   <= '0';
         addr_int          <= (others => '0');
         addr_offset       <= (others => '0');
         eop_int           <= '0';
         get_last_packet   <= '0';
         arbit_access      <= (others => '0');
      
      elsif(clk'event and clk = '1') then
         if(state = IDLE and tx_c_head_empty = '0') then
            arbit_access <= "01";
         elsif(state = IDLE and tx_wr_head_empty = '0') then
            arbit_access <= "10";
         elsif(state /= IDLE) then
            arbit_access <= (others => '0');
         end if;
         
         if(state = TRANSMIT and tx_st_ready0 = '0' and data_from_fifo <= FOUR_12B and data_from_fifo > ZERO_12B and get_last_packet = '0') then
            get_last_packet <= '1';
         elsif(state = IDLE or (state = TRANSMIT and tx_st_ready0 = '1' and get_last_packet = '1')) then
            get_last_packet <= '0';
         end if;
         
         if(state = TRANSMIT and data_to_ava >= THREE_12B and ready_q = '0') then
            eop_int <= '1';
         elsif(state = IDLE or state = PREP_HEADER or state = ABORT or state = TAG_START or state = IO_WR 
              or (state = TRANSMIT and tx_st_ready0 = '1' and ready_q = '1') 
              ) then
            eop_int <= '0';
         end if;
         
         -- release transfer when there is no more data to send
         if(state = IDLE or state = PREP_HEADER or state = ABORT or state = IO_WR or state = TAG_START or 
           (state = TRANSMIT and ((data_to_ava <= TWO_12B and eop_int = '0')  or ready_q = '0')) or 
           (state = START_TRANS and ready_q = '0')) then
            tx_st_valid0_int <= '0';
         -- assert tx_st_valid0 after correct ReadyLatency, in this case ReadyLatency = 2
         elsif((state = START_TRANS and ready_q = '1') or (state = TRANSMIT and ready_q = '1')
         ) then
            tx_st_valid0_int <= '1';
         end if;
         
         -- assert tx_st_sop0 after correct ReadyLatency, in this case ReadyLatency = 2 
         if(state = START_TRANS and ready_q = '1') then
            tx_st_sop0 <= '1';
         elsif((state = START_TRANS and ready_q = '0') or state = TRANSMIT) then
            tx_st_sop0 <= '0';
         end if;
         
         if(state = IDLE or state = PREP_HEADER or state = TAG_START or state = ABORT or state = IO_WR or (state = TRANSMIT and 
           (data_to_ava > FOUR_12B or (data_to_ava <= TWO_12B and eop_int = '0')) and io_write = '0')) then
            tx_st_eop0 <= '0';
         -- set end of packet according to actual transfer length
         elsif(state = TRANSMIT and ready_q = '1' and ((wr_rd = '1' and data_to_ava = THREE_12B) or
              (data_to_ava = FOUR_12B and eop_int = '0' and ((aligned = '1' and send_len_int(0) = '0') or (aligned = '0' and send_len_int(0) = '1'))) or 
              (data_to_ava = THREE_12B and eop_int = '0' and ((aligned = '1' and send_len_int(0) = '1') or (aligned = '0' and send_len_int(0) = '0'))) or 
              io_write = '1' or (eop_int = '1' and data_to_ava <= TWO_12B) or (abort_compl_int = '1' and data_to_ava <= FOUR_12B))) then
            tx_st_eop0 <= '1';
         end if;
         
         -- enable FIFO for corresponding type of transaction chosen before
         if((state = IDLE and tx_c_head_empty = '0' and arbit_access = "01") or (state = PREP_TRANS and wait_clk = 1 and tx_c_head_empty = '0' and c_wr_int = '0')) then
            tx_c_head_enable <= '1';
         elsif(state = PREP_TRANS and (wait_clk /= 1 or tx_c_head_empty = '1' or c_wr_int = '1')) then
            tx_c_head_enable <= '0';
         end if;
         
         -- enable FIFO for corresponding type of transaction chosen before
         if(state = IDLE and tx_wr_head_empty = '0' and arbit_access = "10") then
            tx_wr_head_enable <= '1';
         -- enable correct header FIFO
         elsif(state = PREP_TRANS and (wait_clk /= 1 or tx_c_head_empty = '1' or c_wr_int = '1')) then
            tx_wr_head_enable <= '0';
         end if;
         
         -- enable appropriate FIFO
         if((state = PREP_HEADER and wait_clk = 0 and c_wr_int = '0' and abort_compl_int = '0') or
           (state = START_TRANS and tx_st_ready0 = '1' and c_wr_int = '0' and data_from_fifo > ZERO_11B and abort_compl_int = '0') or
           (state = ABORT and data_from_fifo > TWO_11B) or
           (state = TRANSMIT and tx_st_ready0 = '1' and c_wr_int = '0' and ((data_from_fifo > TWO_11B and data_to_ava > THREE_12B) or (get_last_packet = '1' and data_from_fifo > ZERO_12B)))
           ) then
            tx_c_data_enable <= '1';


         elsif((state = PREP_HEADER and wait_clk = 1 and c_wr_int = '0' and abort_compl_int = '0') or
              (state = START_TRANS and c_wr_int = '0' and ((tx_st_ready0 = '0' and data_from_fifo = ONE_11B) or 
                 (ready_q = '1'  and data_from_fifo <= ONE_11B))) or
              (state = TRANSMIT and ((data_from_fifo <= TWO_11B and c_wr_int = '0') or (tx_st_ready0 = '0'))) or -- reset FIFO enable when hard IP 
                                                                                                           -- core isn't able to receive data
              (state = ABORT and data_from_fifo <= TWO_11B)                      -- disble data retrieval from FIFO due to end of transmission
         ) then
            tx_c_data_enable <= '0';
         end if;
         
         if((state = PREP_HEADER and wait_clk = 1 and c_wr_int = '1' and wr_rd = '0') or
           (state = START_TRANS and tx_st_ready0 = '1' and c_wr_int = '1' and wr_rd = '0' and data_from_fifo > ZERO_11B and fifo_enable_int = '0') or
           (state = TRANSMIT and tx_st_ready0 = '1' and c_wr_int = '1' and wr_rd = '0' and ((data_from_fifo > TWO_11B and data_to_ava > THREE_12B) or (get_last_packet = '1' and data_from_fifo > ZERO_12B)))
           ) then
            tx_wr_data_enable <= '1';
         elsif((state = PREP_HEADER and wait_clk = 2 and c_wr_int = '1' and wr_rd = '0') or
              (state = START_TRANS and c_wr_int = '1' and ((fifo_enable_int = '1' and ((send_len_int(0) = '1' and data_from_fifo = ONE_11B) or 
                 (send_len_int(0) = '0' and data_from_fifo = TWO_11B))) or (tx_st_ready0 = '0' and data_from_fifo = ONE_11B))) or
              (state = TRANSMIT and ((data_from_fifo <= TWO_11B and c_wr_int = '1') or (tx_st_ready0 = '0'))) -- reset FIFO enable when hard IP 
                                                                                                        -- core isn't able to receive data
         ) then
            tx_wr_data_enable <= '0';
         end if;
         
         -- calculate tag ID
         if(state = PREP_HEADER and c_wr_int = '1' and (wr_rd = '1' or (wr_rd = '0' and posted = '0'))) then
            tx_tag_nbr <= "000" & tag_nbr_cntr;
         elsif(state = PREP_HEADER and c_wr_int = '1' and wr_rd = '0' and posted = '1') then
            tx_tag_nbr  <= "00100000";
         end if;
         
         -- tell tx_put_data module to process header information
         if(state = PREP_TRANS and wait_clk = 0) then
            get_header <= '1';
         elsif(state = PREP_HEADER or (state = PREP_TRANS and wait_clk = 1)) then
            get_header <= '0';
         end if;
         
         -- completion information is stored to the FIFO using more than one header packet, thus get next header too
         if(state = PREP_TRANS and wait_clk = 2 and c_wr_int = '0') then
            get_next_header <= '1';
         elsif(state = PREP_HEADER) then
            get_next_header <= '0';
         end if;
         
         -- advise tx_put_data module to process header information and to route that onto Avalon ST data bus
         if(state = PREP_HEADER and ((c_wr_int = '0' and wait_clk = 0) or (c_wr_int = '1' and wait_clk = 1))) then
            make_header <= '1';
         elsif(state = PREP_HEADER and ((c_wr_int = '0' and wait_clk = 1) or (c_wr_int = '1' and wait_clk = 2))) then
            make_header <= '0';
         end if;
         
         if((state = IDLE or state = ABORT or (state = START_TRANS and ready_q = '0')) or 
           (state = TRANSMIT and (ready_q = '0' or data_to_ava <= ZERO_12B)) or
           (state = PREP_HEADER and (wait_clk = 0 or (wait_clk = 2 and c_wr_int = '0') or (wait_clk = 3 and c_wr_int = '1')))
         ) then
            data_enable_int <= '0';  
         elsif((state = PREP_HEADER and ((wait_clk = 1 and c_wr_int = '0') or (wait_clk = 2 and c_wr_int = '1'))) or
              (state = START_TRANS and ready_q = '1') or                         -- enable data processing when hard IP is ready to process data
              (state = TRANSMIT and ready_q = '1' and data_to_ava > ZERO_12B)    -- enable data processing as long as the data length counter isn't 0
         ) then
            data_enable_int <= '1';
         end if;
         
         -- start transaction with priority on completions, don't change in any other state except IDLE
         if(state = IDLE and arbit_access = "01") then
            c_wr_int <= '0';
         elsif(state = IDLE and arbit_access = "10") then
            c_wr_int <= '1';
         end if;
         
         -- give actual own bus/dev/func number (=own_id_int) to tx_put_data module either for completion transmission
         if(state = PREP_TRANS and c_wr_int = '0') then
            completer_id <= own_id_int;
         end if;
         
         -- give actual own bus/dev/func number (=own_id_int) to tx_put_data module either for write/read transmission
         if(state = PREP_TRANS and c_wr_int = '1') then
            own_id <= own_id_int;
         end if;
         
         if(state = IDLE or state = ABORT) then
            abort_compl_int <= '0';
         -- if byte_count is greater than allowed (greater than max_payload) reject transmission, send completion without data
         -- with completer abort status and signal error to error module which will signal error to hard IP by asserting cpl_err(2)
         -- for 1 clock cycle
         elsif(state = PREP_TRANS and wait_clk = 2 and c_wr_int = '0' and tx_c_head_empty = '0' and ((data_len = ZERO_10B and 
               max_payload_len /= ZERO_10B) or (data_len /= ZERO_10B and data_len > max_payload_len))) then
            abort_compl_int <= '1';
         end if;
         
         if(state = IDLE) then
            send_len_int <= (others => '0');
         elsif((state = PREP_TRANS and wait_clk = 2 and c_wr_int = '0') or (state = PREP_HEADER and wait_clk = 1 and c_wr_int = '1' and 
                wr_rd = '1')) then
            send_len_int <= data_len;
         -- store transmission length
         elsif(state = PREP_HEADER and wait_clk = 1 and c_wr_int = '1' and wr_rd = '0') then
            send_len_int <= data_from_fifo(9 downto 0);
         end if;
         
         if(state = IDLE) then
            send_addr <= (others => '0');
         -- show right address to tx_put_data module
         elsif(state = PREP_HEADER and wait_clk = 1) then
            send_addr <= addr_int;
         end if;
         
         if(state = IDLE) then
            payload_loop <= '0';
         -- if packet length is greater than allowed payload size, set payload_loop_en = 1 and do internal loop until desired 
         -- packet length is sent using multiple TLPs; don't forget to adapt packet address after each loop
         elsif(state = PREP_HEADER and desired_len = ZERO_11B and c_wr_int = '1' and wr_rd = '0' and wait_clk = 0 and 
              ((data_len = ZERO_10B and data_len /= max_payload_len) or (data_len /= ZERO_10B and data_len > max_payload_len))) then
            payload_loop <= '1';
         end if;
         
         if(state = IDLE) then
            first_last_full <= (others => '0');
         -- advise tx_put_data module how to process first/last byte enables
         elsif(state = PREP_HEADER and desired_len = ZERO_11B and c_wr_int = '1' and wr_rd = '0' and wait_clk = 0 and
              ((data_len = ZERO_10B and data_len /= max_payload_len) or (data_len /= ZERO_10B and data_len > max_payload_len))) then
            first_last_full <= "01";
         elsif(state = PREP_HEADER and c_wr_int = '1' and wr_rd = '0' and wait_clk = 1 and desired_len <= data_from_fifo) then
            first_last_full <= "10";
         elsif(state = START_TRANS) then
            first_last_full <= "11";
         end if;
         
         if(state = IDLE or state = ABORT) then
            compl_abort <= '0';
         -- assert completion abort indicator
         elsif(state = TRANSMIT and data_to_ava <= TWO_12B and c_wr_int = '0' and abort_compl_int = '1') then
            compl_abort <= '1';
         end if;
         
         -- calculate length counter for data that has to be taken from appropriate FIFO
         if((state = PREP_TRANS and wait_clk = 2 and c_wr_int = '0' and data_len = ZERO_10B) or
           (state = PREP_HEADER and wait_clk = 0 and data_len = ZERO_10B and ((desired_len /= ZERO_11B and c_wr_int = '0') or (desired_len = ZERO_11B and
              (c_wr_int = '0' or (c_wr_int = '1' and data_len = max_payload_len)))))
         ) then
            data_from_fifo <= '1' & data_len;
         elsif((state = PREP_TRANS and wait_clk = 2 and c_wr_int = '0' and data_len > ZERO_10B) or
              (state = PREP_HEADER and wait_clk = 0 and data_len /= ZERO_10B and ((desired_len /= ZERO_11B and c_wr_int = '0') or (desired_len = ZERO_11B 
                 and (c_wr_int = '0' or (c_wr_int = '1' and (max_payload_len = ZERO_10B or data_len <= max_payload_len))))))
         ) then
            data_from_fifo <= '0' & data_len;
         elsif(state = PREP_HEADER and wait_clk = 0 and c_wr_int = '1' and ((desired_len = ZERO_11B and ((data_len = ZERO_10B and data_len /= max_payload_len) or 
              (data_len /= ZERO_10B and data_len > max_payload_len))) or (desired_len /= ZERO_11B and ((desired_len = X_400_11B and 
               desired_len(9 downto 0) /= max_payload_len) or (desired_len < X_400_11B and desired_len(9 downto 0) > max_payload_len))))
         )then
            data_from_fifo <= '0' & max_payload_len;
         elsif(state = PREP_HEADER and desired_len /= ZERO_11B and wait_clk = 0 and c_wr_int = '1'  and desired_len = X_400_11B and desired_len(9 downto 0) = max_payload_len) then
            data_from_fifo <= desired_len;
         elsif(state = PREP_HEADER and desired_len /= ZERO_11B and wait_clk = 0 and c_wr_int = '1'  and ((desired_len < X_400_11B and max_payload_len = ZERO_10B) or (desired_len < X_400_11B 
               and desired_len(9 downto 0) <= max_payload_len)))then
            data_from_fifo <= '0' & desired_len(9 downto 0);
         elsif((state = PREP_HEADER and ((wait_clk = 1 and c_wr_int = '0' and abort_compl_int = '0' and data_from_fifo > ONE_11B) or 
                 (wait_clk = 2 and c_wr_int = '1' and wr_rd = '0' and data_from_fifo > ONE_11B))) or
              (fifo_enable_int = '1' and ((state = TRANSMIT and data_from_fifo > ONE_11B and abort_compl_int = '0') or (state = ABORT and abort_compl_int = '0') or (state = START_TRANS and data_from_fifo > ONE_11B)))
         )then
            data_from_fifo <= data_from_fifo - TWO_11B;
         elsif((state = PREP_HEADER and data_from_fifo <= ONE_11B and ((wait_clk = 1 and c_wr_int = '0' and abort_compl_int = '0') or 
                 (wait_clk = 2 and c_wr_int = '1' and wr_rd = '0'))) or
              (state = START_TRANS and fifo_enable_int = '1' and data_from_fifo = ONE_11B) or
              (fifo_enable_int = '1' and state = TRANSMIT and data_from_fifo <= ONE_11B)
         )then
            data_from_fifo <= (others => '0');
         end if;
         
         -- as this is a loop, change desired_len only when entering this state for the very first time
         -- on other entry times only subtract data_from_fifo value
         -- new value for data_from_fifo is valid when wait_clk = 1
         if(state = PREP_HEADER and desired_len = ZERO_11B and c_wr_int = '1' and wr_rd = '0' and wait_clk = 0 and data_len = ZERO_10B) then
            desired_len <= '1' & data_len;
         elsif(state = PREP_HEADER and desired_len = ZERO_11B and c_wr_int = '1' and wr_rd = '0' and wait_clk = 0 and data_len /= ZERO_10B) then
            desired_len <= '0' & data_len;
         elsif(state = PREP_HEADER and c_wr_int = '1' and wr_rd = '0' and wait_clk = 1 and desired_len >= data_from_fifo) then
            desired_len <= desired_len - data_from_fifo;
         elsif(state = PREP_HEADER and c_wr_int = '1' and (wr_rd = '1' or (wr_rd = '0' and wait_clk = 1 and desired_len < data_from_fifo))) then
            desired_len <= (others => '0');
         end if;
         
         -- in actual design, completion data is returned using one completion only
         -- reads that request more data than max_payload_size (max_read ignored by PCIe requester) are rejected thus use original data length here
         -- check bit 2 for address alignment (=0: aligned, =1: not aligned) thus wait until addr_int is set (wait_clk = 1)
         -- decrement length counters for amount of data taken from FIFO and amount of data sent to hard IP core
         if((state = PREP_TRANS and wait_clk = 2 and ((c_wr_int = '0' and abort_compl_int = '1') or (c_wr_int = '1' and wr_rd = '1'))) or 
           (state = PREP_HEADER and ((c_wr_int = '1' and wait_clk = 1 and wr_rd = '1') or (abort_compl_int = '1' and wait_clk < 2)))) then
            data_to_ava <= THREE_12B;
         elsif((state = PREP_TRANS and wait_clk = 2 and c_wr_int = '0' and abort_compl_int = '0' and aligned = '1' and data_len = ZERO_10B) or
              (state = PREP_HEADER and c_wr_int = '0' and wait_clk = 0 and aligned = '1' and data_len = ZERO_10B)) then
            data_to_ava <= ("01" & data_len) + FOUR_12B;
         elsif((state = PREP_TRANS and wait_clk = 2 and c_wr_int = '0' and abort_compl_int = '0' and aligned = '0' and data_len = ZERO_10B) or
              (state = PREP_HEADER and c_wr_int = '0' and wait_clk = 0 and aligned = '0' and data_len = ZERO_10B)) then
            data_to_ava <= ("01" & data_len) + THREE_12B;
         elsif((state = PREP_TRANS and wait_clk = 2 and c_wr_int = '0' and abort_compl_int = '0' and aligned = '1' and data_len /= ZERO_10B) or
              (state = PREP_HEADER and c_wr_int = '0' and wait_clk = 0 and aligned = '1' and data_len /= ZERO_10B)) then
            data_to_ava <= ("00" & data_len) + FOUR_12B;
         elsif((state = PREP_TRANS and wait_clk = 2 and c_wr_int = '0' and abort_compl_int = '0' and aligned = '0' and data_len /= ZERO_10B) or
              (state = PREP_HEADER and c_wr_int = '0' and wait_clk = 0 and aligned = '0' and data_len /= ZERO_10B)) then
            data_to_ava <= ("00" & data_len) + THREE_12B;
         elsif(state = PREP_HEADER and c_wr_int = '1' and wait_clk = 1 and addr_int(2) = '0') then
            data_to_ava <= ('0' & data_from_fifo) + FOUR_12B;
         elsif(state = PREP_HEADER and c_wr_int = '1' and wait_clk = 1 and addr_int(2) = '1') then
            data_to_ava <= ('0' & data_from_fifo) + THREE_12B;
         elsif(state = TRANSMIT and data_to_ava > ONE_12B and tx_st_valid0_int = '1') then
            data_to_ava <= data_to_ava - "10";
         elsif((state = START_TRANS and data_enable_int = '1' and data_to_ava = 1) or (state = TRANSMIT and data_enable_int = '1' and data_to_ava <= ONE_12B)) then
            data_to_ava <= (others => '0');
         end if;
         
         if(state = IDLE or state = PREP_HEADER or (tx_st_ready0 = '0' and (state = TRANSMIT or state = START_TRANS))) then
            ready_q <= '0';
         elsif(tx_st_ready0 = '1' and (state = TRANSMIT or state = START_TRANS)) then
            ready_q <= '1';
         end if;
         
         -- use wait_clk to enable processing at the right point of time
         if(state = IDLE or (state = PREP_TRANS and ((wait_clk = 2 and c_wr_int = '0') or (wait_clk = 1 and c_wr_int = '1'))) or
           (state = PREP_HEADER and wait_clk = 3)) then
            wait_clk <= 0;
         elsif((state = PREP_TRANS and (c_wr_int = '1' or (c_wr_int = '0' and tx_c_head_empty = '0'))) or
              (state = PREP_HEADER and wait_clk /= 3)) then
            wait_clk <= wait_clk + 1;
         end if;
         
         -- if power off request occured, save it for later processing
         if(pme_to_sr = '1' and (state = IDLE or state = PREP_TRANS or state = PREP_HEADER or state = START_TRANS or state = TRANSMIT
            or state = TAG_START or state = ABORT)) then
            pme_off_int <= '1';
         elsif(state = PME_OFF or (state = IDLE and pme_to_sr = '0')) then
            pme_off_int <= '0';
         end if;
         
         -- disable or enable data retrieval from FIFO
         if(state = IDLE or
           (state = ABORT and data_from_fifo <= 2) or
           (state = PREP_HEADER and ((wait_clk = 1 and c_wr_int = '0' and abort_compl_int = '0') or (wait_clk = 2 and c_wr_int = '1' and 
              wr_rd = '0'))) or
           (state = START_TRANS and ((tx_st_ready0 = '0' and data_from_fifo = ONE_11B) or 
              (ready_q = '1' and c_wr_int = '0' and data_from_fifo <= 1) or 
           (c_wr_int = '1' and fifo_enable_int = '1' and ((data_len(0) = '1' and data_from_fifo = ONE_11B) or (data_len(0) = '0' and 
               data_from_fifo = TWO_11B))))) or
           (state = TRANSMIT and (tx_st_ready0 = '0' or (data_from_fifo <= TWO_11B and get_last_packet = '0')))) then
            fifo_enable_int <= '0';
         elsif((state = START_TRANS and tx_st_ready0 = '1' and data_from_fifo > ZERO_11B and (c_wr_int = '1' or (c_wr_int = '0' and 
               abort_compl_int = '0'))) or (state = ABORT and data_from_fifo > TWO_11B) or
              (state = PREP_HEADER and ((wait_clk = 0 and c_wr_int = '0' and abort_compl_int = '0') or (wait_clk = 1 and c_wr_int = '1' and
               wr_rd = '0'))) or
               (state = TRANSMIT and tx_st_ready0 = '1') ) then
            fifo_enable_int <= '1';
         end if;
         
         -- if packet length is greater than allowed payload size, set payload_loop_en = 1 and do internal loop until desired 
         -- packet length is sent using multiple TLPs
         -- don't forget to adapt packet address after each loop
         if(state = IDLE or 
           (state = PREP_HEADER and c_wr_int = '1' and wr_rd = '0' and desired_len > 0 and wait_clk = 1 and desired_len <= data_from_fifo)) then
            payload_loop_en <= '0';
         elsif(state = PREP_HEADER and desired_len = 0 and c_wr_int = '1' and wr_rd = '0' and wait_clk = 0 and 
              ((data_len = ZERO_10B and data_len /= max_payload_len) or (data_len /= ZERO_10B and data_len > max_payload_len))) then
            payload_loop_en <= '1';
         end if;
         
         if(state = IDLE) then
            addr_int <= (others => '0');
         -- calculate internal address used if transaction must be split into more parts
         elsif(state = PREP_HEADER and wait_clk = 0) then
            addr_int <= orig_addr + addr_offset;
         end if;
         
         -- calculate address offset for internal address calculation
         if(state = IDLE) then
            addr_offset <= (others => '0');
         elsif((state = PREP_HEADER and wait_clk = 2 and c_wr_int = '1' and wr_rd = '0') or
              (state = START_TRANS and fifo_enable_int = '1' and c_wr_int = '1') or
              (state = TRANSMIT and fifo_enable_int = '1' and c_wr_int = '1' and data_from_fifo > ZERO_12B)) then
            addr_offset <= addr_offset + ADDR_INCR;
         end if;

         case state is
            when IDLE =>
               pme_to_cr <= '0';
               start     <= '0';
               start_tag_nbr <= (others => '0');
               own_id_int    <= bus_dev_func;
            
            when PREP_HEADER =>
               pme_to_cr <= '0';
               start     <= '0';
               start_tag_nbr <= (others => '0');
            
            when PREP_TRANS =>
               pme_to_cr <= '0';
               start     <= '0';
               start_tag_nbr <= (others => '0');
            
            when START_TRANS =>
               pme_to_cr <= '0';
               start     <= '0';
               start_tag_nbr <= (others => '0');
            
            when TRANSMIT =>
               pme_to_cr <= '0';
               start     <= '0';
               start_tag_nbr <= (others => '0');
            
            when PME_OFF =>
               pme_to_cr <= '1';
               start     <= '0';
               start_tag_nbr <= (others => '0');
            
            when TAG_START =>
               pme_to_cr     <= '0';
               start         <= '1';
               start_tag_nbr <= tag_nbr_cntr;
               tag_nbr_cntr  <= tag_nbr_cntr + '1';
            
            when ABORT =>
               pme_to_cr <= '0';
               start     <= '0';
               start_tag_nbr <= (others => '0');
            
            when others =>
               pme_to_cr <= '0';
               start     <= '0';
               start_tag_nbr <= (others => '0');
         end case;
      end if;
   end process fsm_out;
-------------------------------------------------------------------------------
end architecture tx_ctrl_arch;   
