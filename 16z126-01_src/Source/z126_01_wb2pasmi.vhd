---------------------------------------------------------------
-- Title         : Wishbone to PASMI
-- Project       : 16z126-01
---------------------------------------------------------------
-- File          : z126_01_wb2pasmi.vhd
-- Author        : Andreas Geissler
-- Email         : Andreas.Geissler@men.de
-- Organization  : MEN Mikro Elektronik Nuremberg GmbH
-- Created       : 03/02/14
---------------------------------------------------------------
-- Simulator     : ModelSim-Altera PE 6.4c
-- Synthesis     : Quartus II 12.1 SP2
---------------------------------------------------------------
-- Description :
-- wb2pasmi is a Wishbone to Parallel Active Serial Flash IF
---------------------------------------------------------------
-- Hierarchy:
-- z126_01_top
--    z126_01_wb2pasmi_i0
---------------------------------------------------------------
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
---------------------------------------------------------------
--                         History
---------------------------------------------------------------
-- $Revision: 1.4 $
--
-- $Log: z126_01_wb2pasmi.vhd,v $
-- Revision 1.4  2014/11/24 16:44:22  AGeissler
-- R1:   Clearness
-- M1.1: Changed spacing
-- M1.2: Changed comment
--
-- Revision 1.3  2014/04/02 09:28:04  AGeissler
-- R: Wrong data when reading with byte or word access
-- M: Changed conditions for read fsm b2lw_state
--
-- Revision 1.2  2014/03/05 11:19:43  AGeissler
-- R: Missing reset for signal
-- M: Added reset
--
-- Revision 1.1  2014/03/03 17:49:55  AGeissler
-- Initial Revision
--
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.z126_01_pkg.ALL;

ENTITY z126_01_wb2pasmi IS
   GENERIC (
      FLASH_TYPE            : flash_type := NONE
   );
   PORT (
      clk                 : IN  std_logic;                     -- flash clk 40 MHz
      rst                 : IN  std_logic;                     -- global async high active reset
      
      -- PASMI interface
      pasmi_addr              : OUT std_logic_vector(23 DOWNTO 0);
      pasmi_bulk_erase        : OUT std_logic;
      pasmi_busy              : IN  std_logic;
      pasmi_data_valid        : IN  std_logic;
      pasmi_datain            : IN  std_logic_vector(7 DOWNTO 0);       -- data from altera pasmi interface
      pasmi_dataout           : OUT std_logic_vector(7 DOWNTO 0);       -- data to altera pasmi 
      pasmi_epcs_id           : IN  std_logic_vector(7 DOWNTO 0);
      pasmi_rdid              : IN  std_logic_vector(7 DOWNTO 0);
      pasmi_fast_read         : OUT std_logic;
      pasmi_illegal_erase     : IN  std_logic;
      pasmi_illegal_write     : IN  std_logic;
      pasmi_rden              : OUT std_logic;
      pasmi_read_sid          : OUT std_logic;
      pasmi_read_rdid         : OUT std_logic;
      pasmi_read_status       : OUT std_logic;
      pasmi_sector_erase      : OUT std_logic;
      pasmi_sector_protect    : OUT std_logic;
      pasmi_shift_bytes       : OUT std_logic;
      pasmi_status_out        : IN  std_logic_vector(7 DOWNTO 0);
      pasmi_wren              : OUT std_logic;
      pasmi_write             : OUT std_logic;
      
      -- wishbone signals slave interface 0 (direct addressing)
      wbs_stb                 : IN  std_logic;                       -- request
      wbs_ack                 : OUT std_logic;                       -- acknoledge
      wbs_we                  : IN  std_logic;                       -- write=1 read=0
      wbs_sel                 : IN  std_logic_vector(3 DOWNTO 0);    -- byte enables
      wbs_cyc                 : IN  std_logic;                       -- chip select
      wbs_dat_o               : OUT std_logic_vector(31 DOWNTO 0);   -- data out
      wbs_dat_i               : IN  std_logic_vector(31 DOWNTO 0);   -- data in
      wbs_adr                 : IN  std_logic_vector(31 DOWNTO 0);   -- address
      wbs_tga                 : IN  std_logic_vector(5 DOWNTO 0);    -- address extension for address generation 0=dir/1=indir
      wbs_err                 : OUT std_logic;                       -- error
      
      -- control interface
      ctrl_read_sid           : IN  std_logic;
      ctrl_sector_protect     : IN  std_logic;
      ctrl_write              : IN  std_logic;
      ctrl_read_status        : IN  std_logic;
      ctrl_sector_erase       : IN  std_logic;
      ctrl_bulk_erase         : IN  std_logic;
      ctrl_busy               : OUT std_logic
   );
END z126_01_wb2pasmi;


ARCHITECTURE z126_01_wb2pasmi_arch OF z126_01_wb2pasmi IS
   
   TYPE sel_states IS (IDLE,SEL_0,SEL_1,SEL_2,SEL_3, END_ACCESS);
   SIGNAL b2lw_state : sel_states;
   SIGNAL lw2b_state : sel_states;
   
   SIGNAL pasmi_busy_q              : std_logic;
   SIGNAL pasmi_busy_qq             : std_logic;
   
   SIGNAL pasmi_data_write_fin      : std_logic;
   SIGNAL pasmi_data_read_fin       : std_logic;
   
   -- internal pasmi signals
   SIGNAL pasmi_rden_fsm_int        : std_logic;
   SIGNAL pasmi_wren_fsm_int        : std_logic;
   SIGNAL pasmi_shift_bytes_fsm_int : std_logic;
   SIGNAL pasmi_fast_read_fsm_int   : std_logic;
   
   SIGNAL pasmi_rden_int            : std_logic;
   SIGNAL pasmi_wren_int            : std_logic;
   SIGNAL pasmi_shift_bytes_int     : std_logic;
   SIGNAL pasmi_bulk_erase_int      : std_logic;
   SIGNAL pasmi_fast_read_int       : std_logic;
   SIGNAL pasmi_read_rdid_int       : std_logic;
   SIGNAL pasmi_read_status_int     : std_logic;
   SIGNAL pasmi_sector_erase_int    : std_logic;
   SIGNAL pasmi_write_int           : std_logic;
   SIGNAL pasmi_sector_protect_int  : std_logic;
   
   SIGNAL id_oe                     : std_logic;   -- select wishbone data out to serial flash id from altera component
   SIGNAL status_oe                 : std_logic;   -- select wishbone data out to status from altera component
   
   SIGNAL wbs_ack_int               : std_logic;
   SIGNAL dat_32_reg                : std_logic_vector(31 DOWNTO 0); -- internal register for shifting read data from pasmi interface
   SIGNAL dat_8_reg                 : std_logic_vector(7 DOWNTO 0);  -- internal register for writing data to pasmi interface
   
   SIGNAL pasmi_datain_swapped_int   : std_logic_vector(7 DOWNTO 0);  -- swapped pasmi data in (MSB <-> LSB)
   SIGNAL pasmi_dataout_swapped_int  : std_logic_vector(7 DOWNTO 0);  -- swapped pasmi data out (MSB <-> LSB)
BEGIN
   
   ctrl_busy      <= pasmi_busy_q;
   
   -- wishbone signals
   wbs_ack              <= wbs_ack_int;
   wbs_err              <= '0';
   
   -- if flash type M25P32 or M25P64 is used the driver expect the sid instead of the rdid
   -- this means to be backwards compatible the rdid is subtracted by 1
   -- M25P32 :  sid = 15; rdid = 16
   -- M25P64 :  sid = 16; rdid = 17
   -- M25P128:  rdid = 18 (there is no sid for the M25P128)
   z126_01_wb2pasmi_m25p32_gen: IF FLASH_TYPE = M25P32 GENERATE
      wbs_dat_o   <=    x"0000_00" & std_logic_vector((unsigned (pasmi_rdid)) - 1) WHEN id_oe = '1'       ELSE
                        x"0000_00" & pasmi_status_out WHEN status_oe = '1'   ELSE
                        dat_32_reg;
   END GENERATE;
   
   z126_01_wb2pasmi_m25p64_gen: IF FLASH_TYPE = M25P64 GENERATE
      wbs_dat_o   <=    x"0000_00" & std_logic_vector((unsigned (pasmi_rdid)) - 1) WHEN id_oe = '1'       ELSE
                        x"0000_00" & pasmi_status_out WHEN status_oe = '1'   ELSE
                        dat_32_reg;
   END GENERATE;
   
   z126_01_wb2pasmi_m25p128_gen: IF FLASH_TYPE = M25P128 GENERATE
      wbs_dat_o   <=    x"0000_00" & pasmi_rdid       WHEN id_oe = '1'       ELSE
                        x"0000_00" & pasmi_status_out WHEN status_oe = '1'   ELSE
                        dat_32_reg;
   END GENERATE;
   
   -- pasmi signals
   pasmi_read_sid       <= '0';  -- read sid is not used any longer (rdid is used instead)
   pasmi_read_rdid      <= pasmi_read_rdid_int;
   pasmi_fast_read      <= pasmi_fast_read_fsm_int;
   pasmi_write          <= pasmi_write_int;
   pasmi_read_status    <= pasmi_read_status_int;
   pasmi_sector_erase   <= pasmi_sector_erase_int;
   pasmi_bulk_erase     <= pasmi_bulk_erase_int;
   pasmi_rden           <= pasmi_rden_fsm_int;
   pasmi_dataout        <= pasmi_dataout_swapped_int;
   
   pasmi_wren           <= '1'   WHEN  pasmi_wren_fsm_int       = '1' OR
                                       pasmi_write_int          = '1' OR
                                       pasmi_sector_erase_int   = '1' OR
                                       pasmi_bulk_erase_int     = '1' ELSE
                                       '0';
                                       
   pasmi_shift_bytes    <= pasmi_shift_bytes_fsm_int;
   pasmi_sector_protect <= pasmi_sector_protect_int    WHEN pasmi_wren_fsm_int = '1' ELSE '0';
   
   pasmi_addr           <= wbs_adr(23 DOWNTO 0)        WHEN wbs_we     = '1'   ELSE --write access depends on adr_register
                           wbs_adr(23 DOWNTO 2) & "00" WHEN wbs_sel(0) = '1'   ELSE --read access depends on byte-sel
                           wbs_adr(23 DOWNTO 2) & "01" WHEN wbs_sel(1) = '1'   ELSE
                           wbs_adr(23 DOWNTO 2) & "10" WHEN wbs_sel(2) = '1'   ELSE
                           wbs_adr(23 DOWNTO 2) & "11" ;
   
   -- bit-swapping of data lines
   bit_swapping:  FOR i IN 0 TO 7 GENERATE
      pasmi_dataout_swapped_int(i)  <= dat_8_reg(7-i) WHEN pasmi_sector_protect_int = '0' ELSE
                                       dat_8_reg(i);
      pasmi_datain_swapped_int(i)   <= pasmi_datain(7-i);
   END GENERATE;
   
   ------------------------------
   -- Byte to long word (READ) --
   ------------------------------
   z126_01_pasmi_read_access_fsm : PROCESS (b2lw_state, rst, clk)
   BEGIN
      
      IF b2lw_state = END_ACCESS THEN
         pasmi_data_read_fin <= '1';
      ELSE
         pasmi_data_read_fin <= '0';
      END IF;
      
      IF rst = '1' THEN
         b2lw_state              <= IDLE;
         pasmi_rden_fsm_int      <= '0';
         pasmi_fast_read_fsm_int <= '0';
         dat_32_reg              <= (OTHERS=>'0');
         
      ELSIF falling_edge(clk) THEN
         CASE b2lw_state IS
            WHEN IDLE  =>
               dat_32_reg <= dat_32_reg;
               
               IF pasmi_fast_read_int = '1' THEN
                  pasmi_rden_fsm_int      <= '1';
                  pasmi_fast_read_fsm_int <= '1';
                  
                  IF   (wbs_sel(0) = '1') THEN
                     b2lw_state <= SEL_0;
                  ELSIF(wbs_sel(1) = '1') THEN
                     b2lw_state <= SEL_1;
                  ELSIF(wbs_sel(2) = '1') THEN
                     b2lw_state <= SEL_2;
                  ELSE
                     b2lw_state <= SEL_3;
                  END IF;
                  
               ELSE
                  pasmi_rden_fsm_int   <= '0';
                  b2lw_state           <= IDLE;
                  
               END IF;
               
            WHEN SEL_0 =>
               dat_32_reg(7 DOWNTO 0)  <= pasmi_datain_swapped_int;
               pasmi_fast_read_fsm_int <= '0';
               
               IF wbs_sel(1) = '0' AND pasmi_data_valid = '1' THEN
                  b2lw_state           <= END_ACCESS;
                  pasmi_rden_fsm_int   <= '0';
               ELSIF pasmi_data_valid = '1' THEN
                  b2lw_state           <= SEL_1;
                  pasmi_rden_fsm_int   <= '1';
               ELSE
                  pasmi_rden_fsm_int   <= '1';
               END IF;
                  
            WHEN SEL_1 =>
               dat_32_reg(15 DOWNTO 8) <= pasmi_datain_swapped_int;
               pasmi_fast_read_fsm_int <= '0';
               
               IF wbs_sel(2) = '0' AND pasmi_data_valid = '1' THEN
                  b2lw_state           <= END_ACCESS;
                  pasmi_rden_fsm_int   <= '0';
               ELSIF pasmi_data_valid = '1' THEN
                  b2lw_state           <= SEL_2;
                  pasmi_rden_fsm_int   <= '1';
               ELSE
                  pasmi_rden_fsm_int   <= '1';
               END IF;
                  
            WHEN SEL_2 =>
               dat_32_reg(23 DOWNTO 16)   <= pasmi_datain_swapped_int;
               pasmi_fast_read_fsm_int    <= '0';
               
               IF wbs_sel(3) = '0' AND pasmi_data_valid = '1' THEN
                  b2lw_state           <= END_ACCESS;
                  pasmi_rden_fsm_int   <= '0';
               ELSIF pasmi_data_valid = '1' THEN
                  b2lw_state           <= SEL_3;
                  pasmi_rden_fsm_int   <= '1';
               ELSE
                  pasmi_rden_fsm_int   <= '1';
               END IF;
                  
            WHEN SEL_3 =>
               dat_32_reg(31 DOWNTO 24)   <= pasmi_datain_swapped_int;
               pasmi_fast_read_fsm_int    <= '0';
               pasmi_rden_fsm_int         <= '0';
               
               IF pasmi_data_valid = '1'  THEN
                    b2lw_state <= END_ACCESS;
               END IF;
                  
            WHEN END_ACCESS =>
               dat_32_reg              <= dat_32_reg;
               pasmi_rden_fsm_int      <= '0';
               pasmi_fast_read_fsm_int <= '0';
               b2lw_state              <= IDLE;
               
   -- coverage off
            WHEN OTHERS =>
               b2lw_state              <= IDLE;
               dat_32_reg              <= dat_32_reg;
               pasmi_rden_fsm_int      <= '0';
               pasmi_fast_read_fsm_int <= '0';
               
               ASSERT FALSE REPORT "Undeocded State" SEVERITY WARNING;
   -- coverage on
         END CASE;
      END IF;
   END PROCESS z126_01_pasmi_read_access_fsm;
   
   -------------------------------
   -- Long word to Byte (WRITE) --
   -------------------------------
   z126_01_pasmi_write_access_fsm : PROCESS (lw2b_state, clk, rst)
   BEGIN
      
      IF lw2b_state = END_ACCESS THEN
         pasmi_data_write_fin <= '1';
      ELSE
         pasmi_data_write_fin <= '0';
      END IF;
      
      IF rst = '1' THEN
         pasmi_wren_fsm_int         <= '0';
         pasmi_shift_bytes_fsm_int  <= '0';
         lw2b_state                 <= IDLE;
         dat_8_reg                  <= (OTHERS=>'0');
      ELSIF falling_edge(clk) THEN
         CASE lw2b_state IS
            WHEN IDLE  =>
               IF pasmi_wren_int = '1' AND pasmi_shift_bytes_int = '1' THEN
                  pasmi_wren_fsm_int         <= '1';
                  pasmi_shift_bytes_fsm_int  <= pasmi_shift_bytes_int;
                  
                  IF(wbs_sel(0) = '1') THEN
                     lw2b_state  <= SEL_0;
                     dat_8_reg   <= wbs_dat_i(7 DOWNTO 0);
                  ELSIF(wbs_sel(1) = '1') THEN
                     lw2b_state  <= SEL_1;
                     dat_8_reg   <= wbs_dat_i(15 DOWNTO 8);
                  ELSIF(wbs_sel(2) = '1') THEN
                     lw2b_state  <= SEL_2;
                     dat_8_reg   <= wbs_dat_i(23 DOWNTO 16);
                  ELSE
                     lw2b_state  <= SEL_3;
                     dat_8_reg   <= wbs_dat_i(31 DOWNTO 24);
                  END IF;
                  
               ELSIF pasmi_wren_int = '1' AND pasmi_sector_protect_int = '1' THEN
                  lw2b_state                 <= IDLE;
                  dat_8_reg                  <= wbs_dat_i(7 DOWNTO 0);
                  pasmi_wren_fsm_int         <= '1';
                  pasmi_shift_bytes_fsm_int  <= '0';
                  
               ELSE
                  lw2b_state                 <= IDLE;
                  dat_8_reg                  <= dat_8_reg;
                  pasmi_wren_fsm_int         <= '0';
                  pasmi_shift_bytes_fsm_int  <= '0';
               END IF;
               
            WHEN SEL_0 =>
               IF(wbs_sel(1) = '1') THEN
                  lw2b_state                 <= SEL_1;
                  dat_8_reg                  <= wbs_dat_i(15 DOWNTO 8);
                  pasmi_wren_fsm_int         <= '1';
                  pasmi_shift_bytes_fsm_int  <= pasmi_shift_bytes_int;
               ELSE
                  lw2b_state                 <= END_ACCESS;
                  dat_8_reg                  <= dat_8_reg;
                  pasmi_wren_fsm_int         <= '0';
                  pasmi_shift_bytes_fsm_int  <= '0';
               END IF;
               
            WHEN SEL_1 =>
               IF(wbs_sel(2) = '1') THEN
                  lw2b_state                 <= SEL_2;
                  dat_8_reg                  <= wbs_dat_i(23 DOWNTO 16);
                  pasmi_wren_fsm_int         <= '1';
                  pasmi_shift_bytes_fsm_int  <= pasmi_shift_bytes_int;
               ELSE
                  lw2b_state                 <= END_ACCESS;
                  dat_8_reg                  <= dat_8_reg;
                  pasmi_wren_fsm_int         <= '0';
                  pasmi_shift_bytes_fsm_int  <= '0';
               END IF;
               
            WHEN SEL_2 =>
               IF(wbs_sel(3) = '1') THEN
                  lw2b_state                 <= SEL_3;
                  dat_8_reg                  <= wbs_dat_i(31 DOWNTO 24);
                  pasmi_wren_fsm_int         <= '1';
                  pasmi_shift_bytes_fsm_int  <= pasmi_shift_bytes_int;
               ELSE
                  lw2b_state                 <= END_ACCESS;
                  dat_8_reg                  <= dat_8_reg;
                  pasmi_wren_fsm_int         <= '0';
                  pasmi_shift_bytes_fsm_int  <= '0';
               END IF;
               
            WHEN SEL_3 =>
                  lw2b_state                 <= END_ACCESS;
                  dat_8_reg                  <= dat_8_reg;
                  pasmi_wren_fsm_int         <= '0';
                  pasmi_shift_bytes_fsm_int  <= '0';
                  
            WHEN END_ACCESS =>
                  lw2b_state                 <= IDLE;
                  dat_8_reg                  <= dat_8_reg;
                  pasmi_wren_fsm_int         <= '0';
                  pasmi_shift_bytes_fsm_int  <= '0';
                  
   -- coverage off
            WHEN OTHERS =>
               lw2b_state                 <= IDLE;
               dat_8_reg                  <= dat_8_reg;
               pasmi_wren_fsm_int         <= '0';
               pasmi_shift_bytes_fsm_int  <= '0';
               ASSERT FALSE REPORT "Undeocded State" SEVERITY WARNING;
   -- coverage on
         END CASE;
      END IF;
   END PROCESS z126_01_pasmi_write_access_fsm;
   
   ----------------------
   -- WBS to PASMI FSM --
   ----------------------
   z126_01_pasmi_fsm_proc : PROCESS (rst, clk)
   BEGIN
      IF rst = '1' THEN
         wbs_ack_int                <= '0';
         
         pasmi_busy_q               <= '0';
         pasmi_busy_qq              <= '0';
         pasmi_wren_int             <= '0';
         pasmi_rden_int             <= '0';
         pasmi_shift_bytes_int      <= '0';
         pasmi_read_rdid_int        <= '0';
         pasmi_sector_protect_int   <= '0';
         pasmi_fast_read_int        <= '0';
         pasmi_write_int            <= '0';
         pasmi_read_status_int      <= '0';
         pasmi_sector_erase_int     <= '0';
         pasmi_bulk_erase_int       <= '0';
         
         id_oe                      <= '0'; 
         status_oe                  <= '0'; 
         
      ELSIF rising_edge(clk) THEN
      
         pasmi_busy_q   <= pasmi_busy;
         pasmi_busy_qq  <= pasmi_busy_q;
         
         IF (     ctrl_sector_protect = '1' OR ctrl_sector_erase = '1' 
               OR ctrl_bulk_erase     = '1' OR ctrl_write        = '1') 
               AND wbs_cyc = '1' AND wbs_stb = '1' THEN
            -- control actions shall be acknowledged after start
            IF pasmi_busy_q = '0' AND pasmi_busy = '1' THEN -- if action is started
               wbs_ack_int <= '1';
            ELSE 
               wbs_ack_int <= '0';
            END IF;
            
         ELSIF       wbs_cyc = '1' AND wbs_stb = '1' 
                AND  pasmi_busy_q = '1' AND pasmi_busy = '0' THEN 
            -- read and write access shall be acknowledged when finnished
            wbs_ack_int <= '1';
         ELSIF       wbs_cyc = '1' AND wbs_stb = '1' 
                AND  pasmi_wren_int = '1' AND pasmi_shift_bytes_int = '1' AND pasmi_data_write_fin = '1' THEN 
            -- write access shall be acknowledged when byte shifting has finished (no busy signal from pasmi)
            wbs_ack_int <= '1';
         ELSE 
            wbs_ack_int <= '0';
         END IF;
      
      ELSIF falling_edge(clk) THEN    
      
         IF ctrl_write = '1' AND pasmi_busy = '0' THEN  
            -- for the page write command no wishbone access for ctrl_write is needed
            pasmi_wren_int  <= '1';
            pasmi_write_int <= '1';
            
         ELSIF pasmi_busy_q = '1' AND pasmi_busy = '0' THEN
            -- reset pasmi control signals at the same moment when wishbone access acknowledged
            pasmi_wren_int           <= '0';
            pasmi_write_int          <= '0';
            pasmi_shift_bytes_int    <= '0';
            pasmi_rden_int           <= '0';
            pasmi_read_rdid_int      <= '0';
            pasmi_sector_protect_int <= '0';
            pasmi_fast_read_int      <= '0';
            pasmi_read_status_int    <= '0';
            pasmi_sector_erase_int   <= '0';
            pasmi_bulk_erase_int     <= '0';
            
         ELSIF wbs_cyc = '1' AND wbs_stb = '1' AND wbs_ack_int = '0' THEN
            -- wishbone acces 
            IF pasmi_busy_qq = '0' AND pasmi_busy_q = '0' AND pasmi_busy = '0' THEN
               -- set control signals until they are recognized
               id_oe       <= '0';
               status_oe   <= '0';
              
               IF ctrl_read_sid           = '1' THEN  
                  pasmi_read_rdid_int        <= '1';
                  id_oe                      <= '1';
                   
               ELSIF ctrl_sector_protect  = '1' THEN
                  pasmi_wren_int             <= '1';
                  pasmi_sector_protect_int   <= '1';
                 
               ELSIF ctrl_read_status     = '1' THEN
                  pasmi_read_status_int      <= '1';
                  status_oe                  <= '1';
                 
               ELSIF ctrl_sector_erase    = '1' THEN
                  pasmi_wren_int             <= '1';
                  pasmi_sector_erase_int     <= '1';
                 
               ELSIF ctrl_bulk_erase      = '1' THEN
                  pasmi_wren_int             <= '1';
                  pasmi_bulk_erase_int       <= '1';
                 
               ELSIF wbs_we = '1' THEN 
                  -- programm page (fill buffer)
                  pasmi_wren_int             <= '1'; 
                  pasmi_shift_bytes_int      <= '1'; 
                 
               ELSE 
                  -- we = '0' (read)
                  pasmi_fast_read_int        <= '1';
                  pasmi_rden_int             <= '1';
               END IF;
            
            ELSE 
               -- the pasmi access is recognized, so the control signals can be cleared
               pasmi_wren_int           <= '0';
               pasmi_shift_bytes_int    <= '0';
               pasmi_read_rdid_int      <= '0';
               pasmi_sector_protect_int <= '0';
               pasmi_fast_read_int      <= '0';
               pasmi_write_int          <= '0';
               pasmi_read_status_int    <= '0';
               pasmi_sector_erase_int   <= '0';
               pasmi_bulk_erase_int     <= '0';
               
               -- continue read until wishbone access is finished
               IF pasmi_data_read_fin = '0' THEN
                  pasmi_rden_int    <= pasmi_rden_int;
               ELSE
                  pasmi_rden_int    <= '0';
               END IF;
               
               id_oe       <= id_oe;
               status_oe   <= status_oe;
            END IF;
              
         ELSE
            -- reset pasmi control signals after wishbone acknowledged
            pasmi_wren_int           <= '0';
            pasmi_write_int          <= '0';
            pasmi_shift_bytes_int    <= '0';
            pasmi_rden_int           <= '0';
            pasmi_read_rdid_int      <= '0';
            pasmi_sector_protect_int <= '0';
            pasmi_fast_read_int      <= '0';
            pasmi_read_status_int    <= '0';
            pasmi_sector_erase_int   <= '0';
            pasmi_bulk_erase_int     <= '0';
            
         END IF; -- wishbone acces 
            
      END IF; -- clk
   
   END PROCESS z126_01_pasmi_fsm_proc;
   
   
END z126_01_wb2pasmi_arch;
