--------------------------------------------------------------------------------
-- Title       : tx_put_data
-- Project     : 16z091-01
--------------------------------------------------------------------------------
-- File        : tx_put_data.vhd
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 07.12.2010
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6a / ModelSim AE 6.5e sp1
-- Synthesis   :
--------------------------------------------------------------------------------
-- Description :
-- data handling module for tx path, controlled by tx_ctrl.vhd;
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
-- *        tx_put_data
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

entity tx_put_data is
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
      completer_id    : in  std_logic_vector(15 downto 0);
      c_wrrd          : in  std_logic;                                           -- 0: completion, 1: write/read
      get_header      : in  std_logic;
      get_next_header : in  std_logic;
      make_header     : in  std_logic;
      abort_compl     : in  std_logic;
      send_len        : in  std_logic_vector(9 downto 0);                        -- length of actual packet, stored to header
      send_addr       : in  std_logic_vector(31 downto 0);                       -- address of actual packet, stored to header
      payload_loop    : in  std_logic;                                           -- =0: no loop, =1: loop -> keep most header info
      first_last_full : in  std_logic_vector(1 downto 0);                        -- 00: unused, 01: first packet of payload_loop, 01: last
                                                                                 -- packet of payload_loop, 11: all enabled
      data_length     : out std_logic_vector(9 downto 0);
      aligned         : out std_logic;
      wr_rd           : out std_logic;                                           -- 0: write, 1: read
      posted          : out std_logic;                                           -- 0: non-posted, 1: posted
      byte_count      : out std_logic_vector(11 downto 0);
      io_write        : out std_logic;                                           -- 0: no I/O write, 1: I/O write thus completion without data
      orig_addr       : out std_logic_vector(31 downto 0)
   );
end entity tx_put_data;

-- ****************************************************************************

architecture tx_put_data_arch of tx_put_data is

-- internal signals: ----------------------------------------------------------
signal aligned_int    : std_logic;
signal data_in_q      : std_logic_vector(63 downto 0);
signal data_q         : std_logic_vector(63 downto 0);
signal data_qq        : std_logic_vector(63 downto 0);
signal req_id_int     : std_logic_vector(15 downto 0);
signal tag_id_int     : std_logic_vector(7 downto 0);
signal lower_addr_int : std_logic_vector(6 downto 0);
signal first_DW_int   : std_logic_vector(3 downto 0);
signal last_DW_int    : std_logic_vector(3 downto 0);
signal wr_rd_int      : std_logic;                                               -- =0: wr, =1: rd
signal mem_io_int     : std_logic;                                               -- =0: mem, =1: I/O
signal io_write_int   : std_logic;
-------------------------------------------------------------------------------

begin
   io_write <= io_write_int;
   
   data_path : process(rst, clk)
   
   begin
      if(rst = '1') then
         -- ports:
         tx_st_data0    <= (others => '0');
         data_length    <= (others => '0');
         aligned        <= '0';
         wr_rd          <= '0';
         posted         <= '0';
         byte_count     <= (others => '0');
         orig_addr      <= (others => '0');
         
         -- signals:
         aligned_int    <= '0';
         data_in_q      <= (others => '0');
         data_q         <= (others => '0');
         data_qq        <= (others => '0');
         req_id_int     <= (others => '0');
         tag_id_int     <= (others => '0');
         lower_addr_int <= (others => '0');
         first_DW_int   <= (others => '0');
         last_DW_int    <= (others => '0');
         wr_rd_int      <= '0';
         mem_io_int     <= '0';
         io_write_int   <= '0';
         
      else
         if(clk'event and clk = '1') then
            -- capture data length from appropriate FIFO packet
            if(get_header = '1' and c_wrrd = '0') then
               data_length <= tx_c_head_out(9 downto 0);
            elsif(get_header = '1' and c_wrrd = '1') then
               data_length <= tx_wr_head_out(9 downto 0);
            end if;
            
            -- store alignment information for both completion and write/read transmissions
            if(get_header = '1' and c_wrrd = '0') then
               case tx_c_head_out(34) is
                  when '0' =>                                                  -- check bit 2 of address for alignment
                     aligned_int <= '1' ;
                     aligned     <= '1' ;
                  when others =>
                     aligned_int <= '0';
                     aligned     <= '0';
               end case;
            elsif(get_header = '1' and c_wrrd = '1') then
               case tx_wr_head_out(34) is
                  when '0' =>
                     aligned_int <= '1';
                     aligned     <= '1';
                  when others =>
                     aligned_int <= '0';
                     aligned     <= '0';
               end case;
            end if;
            
            -- capture information if transmission is write or read
            if(get_header = '1' and c_wrrd = '1') then
               if(tx_wr_head_out(31) = '1') then
                  wr_rd     <= '0';
                  wr_rd_int <= '0';
               else
                  wr_rd     <= '1';
                  wr_rd_int <= '1';
               end if;
         ----------------------------------------------------------------------------------------
         -- wr_rd is not reset if c_wrrd = 0 and if previous transfer is read it's stuck at '1'
         -- which causes errors during transfer
         -- thus added elsif
         ----------------------------------------------------------------------------------------
            elsif get_header = '1' and c_wrrd = '0' then
               wr_rd     <= '0';
               wr_rd_int <= '0';
            end if;
            
            -- define if transfer is posted or not
            if(get_header = '1' and c_wrrd = '1') then
               if(tx_wr_head_out(30) = '1') then                                 -- posted
                  posted <= '1';
               else                                                              -- non-posted
                  posted <= '0';
               end if;
            end if;
            
            -- define wether transfer is of type memory or I/O
            if(get_header = '1' and c_wrrd = '1') then
               if(tx_wr_head_out(29) = '1') then
                  mem_io_int <= '0';                                             -- memory 
               else
                  mem_io_int <= '1';                                             -- I/O
               end if;
            end if;
            
            -- store information on first/last byte enables
            if(get_header = '1' and c_wrrd = '1') then
               first_DW_int <= tx_wr_head_out(17 downto 14);                     -- first DW
               last_DW_int  <= tx_wr_head_out(13 downto 10);                     -- last DW
            end if;
            
            -- register header packet
            if(get_header = '1' and c_wrrd = '0') then
               data_in_q <= tx_c_head_out;
            end if;
            
            -- store requester ID
            if(get_next_header = '1' and c_wrrd = '0') then
               req_id_int <= tx_c_head_out(15 downto 0);
            end if;
            
            -- store tag ID
            if(get_header = '1' and c_wrrd = '0') then
               tag_id_int <= tx_c_head_out(25 downto 18);
            end if;
            
            -- store byte count
            if(get_next_header = '1' and c_wrrd = '0') then
               byte_count <= tx_c_head_out(27 downto 16);
            end if;
            
            -- store I/O write flag
            if(get_next_header = '1' and c_wrrd = '0') then
               io_write_int <= tx_c_head_out(28);
            elsif c_wrrd = '1' then
               io_write_int <= '0';
            end if;
            
            -- store original transfer address
            if(get_header = '1' and c_wrrd = '0') then
               orig_addr <= tx_c_head_out(63 downto 32);
            elsif(get_header = '1' and c_wrrd = '1') then
               orig_addr <= tx_wr_head_out(63 downto 32);
            end if;
            
            -- calculate lower address for completions
            if(get_header = '1' and c_wrrd = '0') then
               if(tx_c_head_out(17 downto 14) = "0000" or tx_c_head_out(14) = '1') then
                  lower_addr_int <= tx_c_head_out(38 downto 34) & "00";          -- calculate from first DW
               elsif(tx_c_head_out(15 downto 14) = "10") then
                  lower_addr_int <= tx_c_head_out(38 downto 34) & "01";
               elsif(tx_c_head_out(16 downto 14) = "100") then
                  lower_addr_int <= tx_c_head_out(38 downto 34) & "10";
               elsif(tx_c_head_out(17 downto 14) = "1000") then
                  lower_addr_int <= tx_c_head_out(38 downto 34) & "11";
               -- coverage off
               else
                  -- synthesis translate_off
                  report "wrong encoding of tx_c_head_out(17 downto 14)" severity error;
                  -- synthesis translate_on
               -- coverage on
               end if;
            end if;
            
            -- assebmle packets for transmission
            -- c_wrrd controls whether completion or write/read transfer is needed
            -- R := reserved according to PCIe base specification, thus set to '0' here
            if(make_header = '1' and c_wrrd = '0') then
               if(abort_compl = '1' or io_write_int = '1') then
                  data_qq(31 downto 24) <= "00001010";                           -- fmt & type -> completion without data
               else
                  data_qq(31 downto 24) <= "01001010";                           -- fmt & type -> completion with data
               end if;
               
               data_qq(23)           <= '0';                                     -- R
               data_qq(22 downto 20) <= data_in_q(28 downto 26);                 -- TC
               data_qq(19)           <= '0';                                     -- R
               data_qq(18)           <= data_in_q(31);                           -- Attr(2)
               data_qq(17 downto 14) <= '0' & '0' & '0' & '0';                   -- R & TH & TD & EP
               data_qq(13 downto 12) <= data_in_q(30 downto 29);                 -- Attr(1:0)
               data_qq(11 downto 10) <= "00";                                    -- AT
               data_qq(9 downto 0)   <= data_in_q(9 downto 0);                   -- length
               data_qq(63 downto 48) <= completer_id;
               
               if(abort_compl = '1') then
                  data_qq(47 downto 45) <= "100";                                -- completion status = completer abort
               else
                  data_qq(47 downto 45) <= "000";                                -- completion status = successful completion
               end if;
               
               data_qq(44)           <= '0';                                     -- bcm
               data_qq(43 downto 32) <= tx_c_head_out(27 downto 16);             -- byte count
               data_q(63 downto 32)  <= x"00000000";
               data_q(31 downto 16)  <= req_id_int;                              -- requester ID
               data_q(15 downto 8)   <= tag_id_int;                              -- tag ID
               data_q(7 downto 0)    <= '0' & lower_addr_int;                    -- R & lower address
            
            elsif(make_header = '1' and c_wrrd = '1') then
               if(mem_io_int = '0' and wr_rd_int = '0') then                     -- memory write
                  data_qq(31 downto 24) <= "01000000";
               elsif(mem_io_int = '1' and wr_rd_int = '0') then                  -- I/O write
                  data_qq(31 downto 24) <= "01000010";
               elsif(mem_io_int = '0' and wr_rd_int = '1') then                  -- memory read
                  data_qq(31 downto 24) <= "00000000";
               else                                                              -- I/O read
                  data_qq(31 downto 24) <= "00000010";
               end if;

               -- R & TC(2:0) & R & Attr(2) & R & TH & TD & EP & Attr(1:0) & AT
               data_qq(23 downto 10) <= '0' & "000" & '0' & '0' & '0' & '0' & '0' & '0' & "00" & "00";
               data_qq(9 downto 0)   <= send_len;                                -- length
               data_qq(63 downto 48) <= req_id;
               data_qq(47 downto 40) <= tag_nbr;
               data_q(63 downto 32)  <= x"00000000";
               data_q(31 downto 0)   <= send_addr;                               -- address

               -- do payload loop, that means: one request was transmitted from Wishbone but the length is too big
               -- thus split up in order to obey PCIe max_payload_size or max_read_size, which means
               -- to send several packets with the same header info except address and length
               -- CAUTION: 
               --    if the last packet to be sent has length =1 then last_DW must be =0
               --    and the original setting for last_DW must be inserted for first_DW
               if(payload_loop = '0') then
                  data_qq(39 downto 36) <= last_DW_int;                          -- last DW
                  data_qq(35 downto 32) <= first_DW_int;                         -- first DW
               elsif(payload_loop = '1' and first_last_full = "01") then
                  data_qq(39 downto 36) <= x"F";
                  data_qq(35 downto 32) <= first_DW_int;                         -- first DW
               elsif(payload_loop = '1' and first_last_full = "10") then
                  if send_len = "0000000001" then
                     data_qq(39 downto 36) <= x"0";
                     data_qq(35 downto 32) <= last_DW_int;
                  else
                     data_qq(39 downto 36) <= last_DW_int;                          -- last DW
                     data_qq(35 downto 32) <= x"F";
                  end if;
               elsif(payload_loop = '1' and first_last_full = "11") then
                  data_qq(39 downto 36) <= x"F";
                  data_qq(35 downto 32) <= x"F";
               end if;
            end if;
            
            -- manage registration of data retrieved from FIFO's
            if(data_enable = '1' and aligned_int = '0' and c_wrrd = '0') then
               data_q(31 downto 0) <= tx_c_data_out(63 downto 32);
               data_qq             <= tx_c_data_out(31 downto 0) & data_q(31 downto 0);
            elsif(data_enable = '1' and aligned_int = '0' and c_wrrd = '1') then
               data_q(31 downto 0) <= tx_wr_data_out(63 downto 32);
               data_qq             <= tx_wr_data_out(31 downto 0) & data_q(31 downto 0);
            elsif(data_enable = '1' and aligned_int = '1' and c_wrrd = '0') then
               data_q              <= tx_c_data_out;
               data_qq             <= data_q;
            elsif(data_enable = '1' and aligned_int = '1' and c_wrrd = '1') then
               data_q              <= tx_wr_data_out;
               data_qq             <= data_q;
            end if;
            
            -- output registered data to Avalon ST data bus
            if(data_enable = '1') then
               tx_st_data0 <= data_qq;
            end if;
         end if;
      end if;
   end process data_path;
   
-------------------------------------------------------------------------------   
end architecture tx_put_data_arch;
