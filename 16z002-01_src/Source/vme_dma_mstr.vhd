--------------------------------------------------------------------------------
-- Title         : DMA Master FSM
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : vme_dma_mstr.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 18/09/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- This module consists of the main fsm for the dma.
-- It handles all acti_intons which are required for dma 
-- transmissions.
--------------------------------------------------------------------------------
-- Hierarchy:
--
-- wbb2vme
--    vme_dma
--       vme_dma_fifo
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
-- History:
--------------------------------------------------------------------------------
-- $Revision: 1.4 $
--
-- $Log: vme_dma_mstr.vhd,v $
-- Revision 1.4  2013/01/24 12:47:16  MMiehling
-- bugfix: termination by clearing dma_en bit interrupted wbb access => now wait until next ack is set and then terminate dma access
--
-- Revision 1.3  2012/09/25 11:21:45  MMiehling
-- added wbm_err signal for error signalling from pcie to vme
--
-- Revision 1.2  2012/08/27 12:57:16  MMiehling
-- added prep_write2/3 states for correct fifo handling
--
-- Revision 1.1  2012/03/29 10:14:42  MMiehling
-- Initial Revision
--
-- Revision 1.5  2006/05/18 14:02:26  MMiehling
-- changed comment
--
-- Revision 1.1  2005/10/28 17:52:26  mmiehling
-- Initial Revision
--
-- Revision 1.4  2004/11/02 11:19:43  mmiehling
-- improved timing
--
-- Revision 1.3  2004/08/13 15:41:16  mmiehling
-- removed dma-slave and improved timing
--
-- Revision 1.2  2004/07/27 17:23:26  mmiehling
-- removed slave port
--
-- Revision 1.1  2004/07/15 09:28:52  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY vme_dma_mstr IS
PORT (
   rst                  : IN std_logic;
   clk                  : IN std_logic;
   
   -- wb_master_bus
   stb_o                : OUT std_logic;                 -- request for wb_mstr_bus
   ack_i                : IN std_logic;                  -- acknoledge from wb_mstr_bus
   err_i                : IN std_logic;                  -- error answer from slave
   cti                  : OUT std_logic_vector(2 DOWNTO 0);
   
   -- fifo
   fifo_empty           : IN std_logic;                  -- indicates that no more data is available
   fifo_almost_full     : IN std_logic;                  -- indicates that only one data can be stored in the fifo
   fifo_almost_empty    : IN std_logic;                  -- indicates that only one data is stored in the fifo
   fifo_wr              : OUT std_logic;                 -- if asserted, fifo will be filled with another data
   fifo_rd              : OUT std_logic;                 -- if asserted, data will be read out from fifo
   
   -- vme_dma_au
   sour_dest            : OUT std_logic;                 -- if set, source adress will be used, otherwise destination ad. for adr_o
   inc_adr              : OUT std_logic;                 -- flag indicates when adr should be incremented (depend on sour_dest and get_bd_int)
   get_bd               : OUT std_logic;                 -- if set, adress for next bd reading is switched to adr_o
   reached_size         : IN std_logic;                  -- if all data from one bd was read and stored in the fifo
   dma_act_bd           : IN std_logic_vector(7 DOWNTO 2);      -- [7:3] = acti_intve bd number
   load_cnt             : OUT std_logic;                 -- after new bd was stored in register, counters must be loaded with new values
   boundary             : IN std_logic;                  -- indicates 256 byte boundary if D16 or D32 burst
   we_o_int             : IN std_logic;
   
   -- vme_dma_du
   start_dma            : IN std_logic;                  -- flag starts dma-fsm and clears counters
   set_dma_err          : OUT std_logic;                 -- sets dma error bit if vme error
   clr_dma_en           : OUT std_logic;                 -- clears dma_en bit and dma_act_bd if dma_mstr has done
   dma_en               : IN std_logic;                  -- starts dma_mstr, if 0 => clears dma_act_bd counter
   dma_null             : IN std_logic;                  -- indicates the last bd   
   en_mstr_dat_i_reg    : OUT std_logic;                 -- enable for data in
   inc_sour             : IN std_logic;                  -- indicates if source adress should be incremented
   inc_dest             : IN std_logic;                  -- indicates if destination adress should be incremented
   
   -- arbiter      
   mstr_req             : OUT std_logic;                 -- request for internal register access
   mstr_ack             : IN std_logic                   -- acknoledge for internal register access
     );
END vme_dma_mstr;

ARCHITECTURE vme_dma_mstr_arch OF vme_dma_mstr IS 
   TYPE   mstr_states IS (idle, read_bd, store_bd, prep_read, read_data, read_ws, prep_write, prep_write2, prep_write3, write_data, write_ws, prep_read_bd);
   SIGNAL mstr_state             : mstr_states;
   SIGNAL get_bd_int             : std_logic;
   SIGNAL load_cnt_int           : std_logic;
   SIGNAL en_mstr_dat_i_reg_int  : std_logic;
   SIGNAL clr_dma_en_int         : std_logic;         
   SIGNAL cti_int,cti_int_d0     : std_logic_vector(2 DOWNTO 0); 
BEGIN
              
   cti <= cti_int;
   load_cnt <= load_cnt_int;
   get_bd <= get_bd_int;
   
   en_mstr_dat_i_reg_int <= '1' WHEN get_bd_int = '1' AND ack_i = '1' ELSE '0';
   en_mstr_dat_i_reg <= en_mstr_dat_i_reg_int;
   clr_dma_en <= clr_dma_en_int;
   
   fifo_wr <= '1' WHEN we_o_int = '0' AND ack_i = '1' AND get_bd_int = '0' ELSE '0';
   
   set_dma_err <= '0' WHEN clr_dma_en_int = '1' AND fifo_empty = '1' AND reached_size = '1' AND dma_null = '1' ELSE clr_dma_en_int;

mstr_fsm : PROCESS (clk, rst)
BEGIN
   IF rst = '1' THEN
      mstr_state <= idle;
      load_cnt_int <= '0';
      sour_dest <= '0';
      get_bd_int <= '1';
      clr_dma_en_int <= '0';
      cti_int_d0  <= "000";
   ELSIF clk'EVENT AND clk = '1' THEN
      load_cnt_int <= en_mstr_dat_i_reg_int;
      
      IF dma_act_bd(3 DOWNTO 2) = "11" AND ack_i = '1' THEN 
        get_bd_int <= '0';
      ELSIF clr_dma_en_int = '1' OR (ack_i = '1' AND fifo_empty = '1' AND reached_size = '1' AND mstr_state = write_data) THEN
        get_bd_int <= '1';
      END IF;

      cti_int_d0 <= cti_int;
      
      CASE mstr_state IS
         WHEN idle =>
            sour_dest      <= '0';
            clr_dma_en_int <= '0';
            IF start_dma = '1' THEN                     -- start of dma => read first bd
               mstr_state     <= read_bd;
            ELSE
               mstr_state     <= idle;
            END IF;
      
         WHEN read_bd =>                                -- part of bd requested from sram
            sour_dest      <= '0';
            IF err_i = '1' OR dma_en /= '1' THEN
               mstr_state     <= idle;                  -- error from sram => end of dma acti_inton
               clr_dma_en_int <= '1';
            ELSIF ack_i = '1' THEN
               mstr_state     <= store_bd;
               clr_dma_en_int <= '0';
            ELSE
               mstr_state     <= read_bd;               -- stay until acknoledge of sram
               clr_dma_en_int <= '0';
            END IF;
         
         WHEN store_bd =>                             -- part of bd will be stored in internal registers      
            clr_dma_en_int <= '0';
            IF dma_act_bd(3 DOWNTO 2) = "00" THEN   
               sour_dest      <= '1';
               mstr_state     <= prep_read;         -- hole bd was read => start reading data
            ELSE
               sour_dest      <= '0';
               mstr_state     <= read_bd;               -- read next part of bd
            END IF;
           
         WHEN prep_read =>
            clr_dma_en_int <= '0';
            sour_dest      <= '1';
            mstr_state     <= read_data;
              
         WHEN read_data =>                              -- request read from source address
            IF err_i = '1' OR (dma_en /= '1' AND ack_i = '1') THEN
               mstr_state   <= idle;                  -- error from source => end of dma acti_inton
               sour_dest <= '0';
               clr_dma_en_int <= '1';
            ELSIF ack_i = '1' AND fifo_almost_full /= '1' AND reached_size /= '1' AND inc_sour = '0' AND boundary /= '1' THEN         
               mstr_state     <= read_data;            -- got ack from source address => read next data
               sour_dest      <= '1';
               clr_dma_en_int <= '0';
            ELSIF ack_i = '1' AND fifo_almost_full /= '1' AND reached_size /= '1' AND (inc_sour = '1' OR boundary = '1') THEN         
               mstr_state     <= read_ws;               -- got ack from source address => waitstate, then new single cycle
               sour_dest      <= '1';
               clr_dma_en_int <= '0';
            ELSIF ack_i = '1' AND fifo_almost_full = '1' AND reached_size = '0' THEN
               mstr_state     <= prep_write;            -- block of data was read => write data to destination
               sour_dest      <= '0';
               clr_dma_en_int <= '0';
            ELSIF ack_i = '1' AND reached_size = '1' THEN
               mstr_state     <= prep_write;            -- block of data was read => write data to destination
               sour_dest      <= '0';
               clr_dma_en_int <= '0';
            ELSE 
               mstr_state     <= read_data;            -- wait on ack_i even if fifo_almost_full or reached_size
               sour_dest      <= '1';
               clr_dma_en_int <= '0';
            END IF;           
        
         WHEN read_ws =>
            sour_dest      <= '1';
            mstr_state     <= read_data;
            clr_dma_en_int <= '0';
           
         WHEN prep_write =>
            sour_dest      <= '0';
            mstr_state     <= prep_write2;
            clr_dma_en_int <= '0';
      
         WHEN prep_write2 =>
            sour_dest      <= '0';
            mstr_state     <= prep_write3;
            clr_dma_en_int <= '0';
      
         WHEN prep_write3 =>
            sour_dest      <= '0';
            mstr_state     <= write_data;
            clr_dma_en_int <= '0';
           
         WHEN write_data =>
            IF err_i = '1' OR (dma_en /= '1' AND ack_i = '1') THEN
               sour_dest      <= '0';
               mstr_state     <= idle;                  -- error from destination => end of dma acti_inton
               clr_dma_en_int <= '1';
            ELSIF ack_i = '1' AND fifo_empty /= '1' AND inc_dest = '0' AND boundary /= '1' THEN         
               sour_dest      <= '0';
               mstr_state     <= write_data;            -- got ack from destination address => write next data
               clr_dma_en_int <= '0';
            ELSIF ack_i = '1' AND fifo_empty /= '1' AND (inc_dest = '1' OR boundary = '1') THEN         
               sour_dest      <= '0';
               mstr_state     <= write_ws;            -- got ack from destination address => make waitstate
               clr_dma_en_int <= '0';
            ELSIF ack_i = '1' AND fifo_empty = '1' AND reached_size = '1' AND dma_null = '1' THEN
               sour_dest      <= '0';
               mstr_state     <= idle;                  -- data of bd was written and end of bd list => dma finished
               clr_dma_en_int <= '1';                  -- end of dma => clear dma_en bit
            ELSIF ack_i = '1' AND fifo_empty = '1' AND reached_size = '1' THEN
               sour_dest      <= '0';
               mstr_state     <= prep_read_bd;         -- data of bd was written => read next bd
               clr_dma_en_int <= '0';
            ELSIF ack_i = '1' AND fifo_empty = '1' AND reached_size = '0' THEN
               sour_dest      <= '1';
               mstr_state     <= prep_read;            -- part data of bd was written => read next part of same bd
               clr_dma_en_int <= '0';
            ELSE 
               sour_dest      <= '0';
               mstr_state     <= write_data;            -- wait on ack_i
               clr_dma_en_int <= '0';
            END IF;           
        
        WHEN write_ws =>
            sour_dest <= '0';
            mstr_state    <= write_data;
            clr_dma_en_int <= '0';
        
        WHEN prep_read_bd =>
            sour_dest <= '0';
            mstr_state    <= read_bd;
            clr_dma_en_int <= '0';
           
        WHEN OTHERS =>
            sour_dest <= '0';
            mstr_state    <= idle;
            clr_dma_en_int <= '0';
      END CASE;
   END IF;
END PROCESS mstr_fsm;
   
mstr_out : PROCESS (mstr_state, ack_i, err_i, fifo_empty, fifo_almost_full, reached_size, dma_act_bd, 
                     start_dma, dma_en, dma_null, mstr_ack, inc_sour, inc_dest, boundary, cti_int_d0)
BEGIN
   CASE mstr_state IS
      WHEN idle =>
         stb_o    <= '0';
         fifo_rd  <= '0';
         inc_adr  <= '0';
         mstr_req <= '0';
         cti_int  <= "000";

      WHEN read_bd =>                                -- part of bd requested from sram
         IF err_i = '1' OR (dma_en /= '1' AND ack_i = '1') THEN
            stb_o    <= '1';
            mstr_req <= '0';
            inc_adr  <= '0';
         ELSIF ack_i = '1' THEN
            stb_o    <= '1';                  -- request for sram
            mstr_req <= '1';                  -- request access to internal registers
            inc_adr  <= '1';                  -- increment bd adress for next bd
         ELSE
            stb_o    <= '1';                  -- request for sram
            mstr_req <= '0';
            inc_adr  <= '0';
         END IF;
         fifo_rd  <= '0';
         cti_int  <= "000";

      WHEN store_bd =>                             -- part of bd will be stored in internal registers      
         stb_o    <= '0';
         fifo_rd  <= '0';
         inc_adr  <= '0';
         mstr_req <= '0';
         cti_int  <= "000";
     
      WHEN prep_read =>
         stb_o    <= '0';
         fifo_rd  <= '0';
         inc_adr  <= '1';                     -- if not first read then inc because of reached size
         mstr_req <= '0';
         cti_int  <= "010";
           
      WHEN read_data =>                              -- request read from source address
         IF err_i = '1' OR (dma_en /= '1' AND ack_i = '1') THEN
            stb_o    <= '1';
            inc_adr  <= '0';
            cti_int  <= "111";
         ELSIF ack_i = '1' AND fifo_almost_full /= '1' AND reached_size /= '1' AND inc_sour = '0' AND boundary /= '1' THEN         
            stb_o    <= '1';                  -- request next data
            inc_adr  <= '1';                  -- increment source address
            cti_int  <= "010";
         ELSIF ack_i = '1' AND fifo_almost_full /= '1' AND reached_size /= '1' AND (inc_sour = '1' OR boundary = '1') THEN         
            stb_o    <= '1';                  -- keep for this cycle
            inc_adr  <= '1';                  -- increment source address
            cti_int  <= "111";
         ELSIF ack_i = '1' AND fifo_almost_full = '1' AND reached_size = '0' THEN
            stb_o    <= '1';                  -- keep request for this cycle
            inc_adr  <= '0';                  -- no further data should be read => no increment
            cti_int  <= "111";
         ELSIF ack_i = '1' AND reached_size = '1' THEN
            stb_o    <= '1';                  -- keep asserted for last cycle
            inc_adr  <= '0';                  -- no further data should be read => no increment
            cti_int  <= "111";
         ELSE 
            stb_o    <= '1';                  -- keep request
            inc_adr  <= '0';
            cti_int  <= cti_int_d0;
         END IF;           
         fifo_rd  <= '0';
         mstr_req <= '0';
        
      WHEN read_ws =>
         stb_o    <= '0';
         fifo_rd  <= '0';
         inc_adr  <= '0';
         mstr_req <= '0';
         cti_int  <= "000";
         
      WHEN prep_write =>
         stb_o    <= '0';
         fifo_rd  <= '0';
         inc_adr  <= '0';
         mstr_req <= '0';
         cti_int  <= "000";
           
      WHEN prep_write2 =>
         stb_o    <= '0';
         fifo_rd  <= '0';
         inc_adr  <= '0';
         mstr_req <= '0';
         cti_int  <= "000";
           
      WHEN prep_write3 =>
         stb_o    <= '0';
         fifo_rd  <= '1';                  -- prepare for first write
         inc_adr  <= '1';--++
         mstr_req <= '0';
         cti_int  <= "010";
           
      WHEN write_data =>
         IF err_i = '1' OR (dma_en /= '1' AND ack_i = '1') THEN
            stb_o    <= '1';
            fifo_rd  <= '0';
            inc_adr  <= '0';         
            cti_int  <= "111";
         ELSIF ack_i = '1' AND fifo_empty /= '1' AND inc_dest = '0' AND boundary /= '1' THEN         
            stb_o    <= '1';                  -- request write to destination
            fifo_rd  <= '1';                  -- get next data from fifo
            inc_adr  <= '1';                  -- read next data from fifo
            cti_int  <= "010";
         ELSIF ack_i = '1' AND fifo_empty /= '1' AND (inc_dest = '1' OR boundary = '1') THEN         
            stb_o    <= '1';                  -- request write to destination
            fifo_rd  <= '1';                  -- get next data from fifo
            inc_adr  <= '1';                  -- read next data from fifo
            cti_int  <= "111";
         ELSIF ack_i = '1' AND fifo_empty = '1' AND reached_size = '1' AND dma_null = '1' THEN
            stb_o    <= '1';                  -- keep asserted for this cycle
            fifo_rd  <= '0';                  -- no more data in fifo
            inc_adr  <= '0';                  -- no more increment
            cti_int  <= "111";
         ELSIF ack_i = '1' AND fifo_empty = '1' AND reached_size = '1' THEN
            stb_o    <= '1';                  -- keep asserted for this cycle
            fifo_rd  <= '0';                  -- no more data in fifo
            inc_adr  <= '1';                  -- increment dma_act_bd
            cti_int  <= "111";
         ELSIF ack_i = '1' AND fifo_empty = '1' AND reached_size = '0' THEN
            stb_o    <= '1';                  -- keep asserted for this cycle
            fifo_rd  <= '0';                  -- no more data in fifo
            inc_adr  <= '0';--++
            cti_int  <= "111";
         ELSE 
            stb_o    <= '1';                  -- keep stb_o asserted
            fifo_rd  <= '0';
            inc_adr  <= '0';
            cti_int  <= cti_int_d0;
         END IF;           
         mstr_req <= '0';
        
      WHEN write_ws =>
         stb_o    <= '0';
         fifo_rd  <= '0';
         inc_adr  <= '0';
         mstr_req <= '0';
         cti_int  <= "000";
        
      WHEN prep_read_bd =>
         stb_o    <= '0';
         fifo_rd  <= '0';
         inc_adr  <= '0';
         mstr_req <= '0';
         cti_int  <= "000";
        
      WHEN OTHERS =>
         stb_o    <= '0';
         fifo_rd  <= '0';
         inc_adr  <= '0';
         mstr_req <= '0';
         cti_int  <= "000";
   END CASE;
END PROCESS mstr_out;

END vme_dma_mstr_arch;
