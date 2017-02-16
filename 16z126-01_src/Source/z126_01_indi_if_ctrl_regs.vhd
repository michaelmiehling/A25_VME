---------------------------------------------------------------
-- Title         : 16z126-01 Indirect Interface Control Registers
-- Project       : 16z126-01
---------------------------------------------------------------
-- File          : z126_01_indi_if_ctrl_regs.vhd
-- Author        : Andreas Geissler
-- Email         : Andreas.Geissler@men.de
-- Organization  : MEN Mikro Elektronik Nuremberg GmbH
-- Created       : 03/02/14
---------------------------------------------------------------
-- Simulator     : ModelSim-Altera PE 6.4c
-- Synthesis     : Quartus II 12.1 SP2
---------------------------------------------------------------
-- Description :
-- The state machine transforms an wishbone access from the
-- slave input to a wishbone master access to the master output.
-- The state machine consits of one address and one data
-- register in order to realize an indirect memory access.
-- The indirect memory access is initiated at the wishbone
-- slave input and is transformed to an wishbone master output
-- (in order to access an 16z100 Module)
--
---------------------------------------------------------------
-- Hierarchy:
-- z126_01_top
--    z126_01_indi_if_ctrl_regs
--
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
-- $Revision: 1.3 $
--
-- $Log: z126_01_indi_if_ctrl_regs.vhd,v $
-- Revision 1.3  2014/11/24 16:44:12  AGeissler
-- R1: Complex FSM for WBM to remote update controller and WBM to PASMI interface
-- M1: Simplified the FSM by reduced states
-- R2: Misleading signal name
-- M2: Renamed signal adr_reg to ctrl_reg
-- R3: Unused signal
-- M3: Removed ctrl_busy_q
-- R4: Code optimization
-- M4: Moved signal reconfig_int into write access condition of the wishbone bus
--     slave
--
-- Revision 1.2  2014/03/05 11:19:36  AGeissler
-- R: Missing reset for signal
-- M: Added reset
--
-- Revision 1.1  2014/03/03 17:49:41  AGeissler
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY z126_01_indi_if_ctrl_regs IS
   PORT (
      clk                   : IN  std_logic;                     -- Wishbone clock (66 MHz)
      rst                   : IN  std_logic;                     -- Reset
      
      -- wishbone signals master interface (ru_ctrl interface)
      wbm_ru_cyc             : OUT std_logic;
      wbm_ru_ack             : IN  std_logic;
      wbm_ru_we              : OUT std_logic;
      wbm_ru_sel             : OUT std_logic_vector(3 DOWNTO 0);
      wbm_ru_dat_o           : OUT std_logic_vector(31 DOWNTO 0);
      wbm_ru_dat_i           : IN  std_logic_vector(31 DOWNTO 0);
      
      reg_reconfig            : OUT std_logic;                       -- reconfiguration trigger from register interface
      reg_reconfig_cond       : IN  std_logic_vector(4 DOWNTO 0);    -- reconfiguration trigger condition of last reconfiguration
      reg_board_status        : IN  std_logic_vector(1 DOWNTO 0);    -- gives information whether the loading process was successful or not
      
      -- wishbone signals master interface (wb2pasmi interface)
      wbm_stb               : OUT std_logic;                     -- strobe
      wbm_adr               : OUT std_logic_vector(31 DOWNTO 0); -- address
      wbm_ack               : IN  std_logic;                     -- acknowledge
      wbm_dat_i             : IN  std_logic_vector(31 DOWNTO 0); -- data in
      wbm_cyc               : OUT std_logic;                     -- chip select
      
      -- wishbone signals slave interface (indirect interface)
      wbs_stb               : IN  std_logic;                     -- strobe
      wbs_ack               : OUT std_logic;                     -- acknowledge
      wbs_we                : IN  std_logic;                     -- write=1 read=0
      wbs_sel               : IN  std_logic_vector(3 DOWNTO 0);  -- byte enables
      wbs_cyc               : IN  std_logic;                     -- chip select
      wbs_dat_o             : OUT std_logic_vector(31 DOWNTO 0); -- data out
      wbs_dat_i             : IN  std_logic_vector(31 DOWNTO 0); -- data in
      wbs_adr               : IN  std_logic_vector(31 DOWNTO 0); -- address
      
      -- ctrl signals from registers
      ctrl_read_sid         : OUT std_logic;
      ctrl_sector_protect   : OUT std_logic;
      ctrl_write            : OUT std_logic;
      ctrl_read_status      : OUT std_logic;
      ctrl_sector_erase     : OUT std_logic;
      ctrl_bulk_erase       : OUT std_logic;
      ctrl_illegal_write    : IN  std_logic;
      ctrl_illegal_erase    : IN  std_logic;
      ctrl_busy             : IN  std_logic
   );
END z126_01_indi_if_ctrl_regs;

ARCHITECTURE z126_01_indi_if_ctrl_regs_arch OF z126_01_indi_if_ctrl_regs IS
   
   TYPE wb_states IS (IDLE, PER_REQ, ACKNOWLEDGE);
   
   SIGNAL ctrl_reg         : std_logic_vector(31 DOWNTO 0); -- control register
   SIGNAL flash_adr        : std_logic_vector(23 DOWNTO 0); -- flash adress register
   SIGNAL reconfig_int     : std_logic;
   SIGNAL wbs_ack_int      : std_logic;
   
   SIGNAL wbm_state        : wb_states := IDLE;
   SIGNAL wbm_start        : std_logic;
   SIGNAL wbm_done         : std_logic;
   SIGNAL wbm_cyc_int      : std_logic;
   
   SIGNAL wbm_ru_state     : wb_states := IDLE;
   SIGNAL wbm_ru_start     : std_logic;
   SIGNAL wbm_ru_done      : std_logic;
   
   SIGNAL ctrl_read_sid_q        : std_logic;
   SIGNAL ctrl_sector_protect_q  : std_logic;
   SIGNAL ctrl_sector_erase_q    : std_logic;
   SIGNAL ctrl_bulk_erase_q      : std_logic;
   SIGNAL ctrl_read_status_q     : std_logic;
   SIGNAL ctrl_illegal_write_q   : std_logic;
   SIGNAL ctrl_illegal_erase_q   : std_logic;
   
BEGIN
   
   -- wishbone connection to remote update controller
   wbm_ru_dat_o   <= wbs_dat_i;
   wbm_ru_sel     <= wbs_sel;
   wbm_ru_we      <= wbs_we;
   
   -- control signals to wb2pasmi module
   ctrl_read_sid        <= ctrl_read_sid_q;
   ctrl_sector_protect  <= ctrl_sector_protect_q;
   ctrl_read_status     <= ctrl_read_status_q;
   ctrl_sector_erase    <= ctrl_sector_erase_q;
   ctrl_bulk_erase      <= ctrl_bulk_erase_q;
   
   -- control register of indirect interface
   ctrl_reg  <= reconfig_int & ctrl_busy & ctrl_illegal_erase_q & ctrl_illegal_write_q & "0000" & flash_adr;
   
   wbm_cyc        <= wbm_cyc_int;
   wbm_stb        <= wbm_cyc_int;
   wbm_adr        <= x"00" & ctrl_reg(23 DOWNTO 0);
   wbs_ack        <= wbs_ack_int;
   reg_reconfig   <= reconfig_int;    -- reconfiguration is generated from bit 31 of ctrl_reg

   -- Process for register access
   z126_01_wbs_regs: PROCESS(clk, rst)
   BEGIN
      IF rst = '1' THEN
         
         flash_adr              <= (OTHERS => '0');
         ctrl_read_sid_q        <= '0';
         ctrl_sector_protect_q  <= '0';
         ctrl_read_status_q     <= '0';
         ctrl_sector_erase_q    <= '0';
         ctrl_bulk_erase_q      <= '0';
         ctrl_write             <= '0';
         ctrl_illegal_write_q   <= '0';
         ctrl_illegal_erase_q   <= '0';
         reconfig_int           <= '0';
         
         wbs_ack_int            <= '0';
         wbm_start              <= '0';
         wbm_ru_start           <= '0';
         wbs_dat_o              <= (OTHERS => '0');
         
      ELSIF clk'EVENT AND clk ='1' THEN
         
         ----------------------------------------
         -- write access to indirect interface --
         ----------------------------------------
         IF wbs_stb = '1' AND wbs_cyc = '1' AND wbs_ack_int = '0' AND wbs_we = '1' THEN
            IF wbs_adr(3 DOWNTO 2) = "00" THEN           -- Write to Address Register 0x00
               wbs_ack_int <= '1';                       -- Issue acknowledge immediately
               wbm_start   <= '0';                       -- Don't perform a wishbone master access
               
               IF wbs_sel(0) = '1' THEN
                  flash_adr(7 DOWNTO 0)   <= wbs_dat_i(7 DOWNTO 0);
               END IF;
               
               IF wbs_sel(1) = '1' THEN
                  flash_adr(15 DOWNTO 8)  <= wbs_dat_i(15 DOWNTO 8);
               END IF;
               
               IF wbs_sel(2) = '1' THEN
                  flash_adr(23 DOWNTO 16) <= wbs_dat_i(23 DOWNTO 16);
               END IF;
               
               IF wbs_sel(3) = '1' THEN
                  ctrl_read_sid_q         <= wbs_dat_i(25);
                  ctrl_sector_protect_q   <= wbs_dat_i(26);
                  ctrl_read_status_q      <= wbs_dat_i(27);
                  ctrl_sector_erase_q     <= wbs_dat_i(28);
                  ctrl_bulk_erase_q       <= wbs_dat_i(29);
                  ctrl_write              <= wbs_dat_i(30);
                  reconfig_int            <= wbs_dat_i(31);   -- Bit 31 indicates reconfiguration
                  
                  ctrl_illegal_write_q    <= '0';  -- reset status bits
                  ctrl_illegal_erase_q    <= '0';
                  
               END IF;
               
            ELSIF wbs_adr(3 DOWNTO 2) = "01" THEN     -- write to data register 0x04
               wbs_ack_int <= wbm_done;               -- issue acknowledge when wb access is done
               wbm_start   <= NOT wbm_done;           -- start wisbone master access when
                                                      -- no former access is in work
               flash_adr   <= flash_adr;
               
               ctrl_read_sid_q         <= '0';
               ctrl_sector_protect_q   <= ctrl_sector_protect_q;
               ctrl_read_status_q      <= '0';
               ctrl_sector_erase_q     <= ctrl_sector_erase_q;
               ctrl_bulk_erase_q       <= ctrl_bulk_erase_q;
               ctrl_write              <= '0';
               
               ctrl_illegal_write_q    <= ctrl_illegal_write_q;
               ctrl_illegal_erase_q    <= ctrl_illegal_erase_q;
               
            ELSIF wbs_adr(3 DOWNTO 2) = "10" THEN  -- board status register (read-only)
               wbs_ack_int <= '1';                 -- Issue acknowledge immediately
            
            ELSIF wbs_adr(3 DOWNTO 2) = "11" THEN  
               -- write boot address of remote update controller
               -- perform wishbone master access to ru_ctrl
               wbs_ack_int    <= wbm_ru_done;
               wbm_ru_start   <= NOT wbm_ru_done;
               
            END IF;
            
         ---------------------------------------
         -- read access to indirect interface --
         ---------------------------------------
         ELSIF wbs_stb = '1' AND wbs_cyc = '1' AND wbs_ack_int = '0' AND wbs_we = '0' THEN
            CASE wbs_adr(3 DOWNTO 2) IS
               WHEN "00" =>                        -- read 0x00 Control Register
                  wbm_start   <= '0';              -- Don't perform a wishbone master access
                  wbs_ack_int <= '1';              -- Issue acknowledge immediately
                  
                  flash_adr   <= flash_adr;
                  
                  ctrl_read_sid_q         <= '0';
                  ctrl_sector_protect_q   <= '0';
                  ctrl_read_status_q      <= '0';
                  ctrl_sector_erase_q     <= '0';
                  ctrl_bulk_erase_q       <= '0';
                  ctrl_write              <= '0';
                  
                  ctrl_illegal_write_q    <= ctrl_illegal_write_q;
                  ctrl_illegal_erase_q    <= ctrl_illegal_erase_q;
                  
               WHEN "01" =>                        -- read 0x04 Data Register
                  wbm_start   <= NOT wbm_done;
                  wbs_ack_int <= wbm_done;
                  
                  flash_adr   <= flash_adr;
                  
                  ctrl_read_sid_q         <= ctrl_read_sid_q;
                  ctrl_sector_protect_q   <= '0';
                  ctrl_write              <= '0';
                  ctrl_read_status_q      <= ctrl_read_status_q;
                  ctrl_sector_erase_q     <= '0';
                  ctrl_bulk_erase_q       <= '0';
                  
                  ctrl_illegal_write_q    <= ctrl_illegal_write_q;
                  ctrl_illegal_erase_q    <= ctrl_illegal_erase_q;
                  
               WHEN "10" =>                        -- read 0x08 board status register (read-only)
                  wbs_ack_int <= '1';  -- issue acknowledge immediately
                  
               WHEN "11" =>                        -- "11" = 0x0C
                  -- read boot address of remote update controller
                  -- perform wishbone master access to ru_ctrl
                  wbm_ru_start   <= NOT wbm_ru_done;
                  wbs_ack_int    <= wbm_ru_done;
                   
               WHEN OTHERS => 
                  wbs_ack_int <= '1';  -- issue acknowledge immediately
               
            END CASE;
         ELSE
            wbs_ack_int    <= '0';
            wbm_start      <= '0';
            wbm_ru_start   <= '0';
            
            flash_adr      <= flash_adr;
            
            ctrl_read_sid_q         <= ctrl_read_sid_q;
            ctrl_sector_protect_q   <= ctrl_sector_protect_q;
            ctrl_read_status_q      <= ctrl_read_status_q;
            ctrl_sector_erase_q     <= ctrl_sector_erase_q;
            ctrl_bulk_erase_q       <= ctrl_bulk_erase_q;
            ctrl_write              <= '0';
            
            IF ctrl_illegal_write = '1' THEN
               ctrl_illegal_write_q <= '1';
            ELSE
               ctrl_illegal_write_q <= ctrl_illegal_write_q;
            END IF;
            
            IF ctrl_illegal_erase = '1' THEN
               ctrl_illegal_erase_q <= '1';
            ELSE
               ctrl_illegal_erase_q <= ctrl_illegal_erase_q;
            END IF;
            
         END IF;
         
         -- wbs data out (read)
         IF wbs_adr(3 DOWNTO 2) = "00" THEN
            wbs_dat_o <= ctrl_reg;
         ELSIF wbs_adr(3 DOWNTO 2) = "01" THEN
            wbs_dat_o <= wbm_dat_i;
         ELSIF wbs_adr(3 DOWNTO 2) = "10" THEN
            wbs_dat_o <= x"000000" & "0" & reg_reconfig_cond & reg_board_status;
         ELSIF wbs_adr(3 DOWNTO 2) = "11" THEN
            wbs_dat_o <= wbm_ru_dat_i;
         END IF;
         
      END IF;
   END PROCESS z126_01_wbs_regs;
   
   
   -- generating wishbone master access for remote update unit
   z126_01_wbm_ru_fsm_proc: PROCESS(clk, rst)
   BEGIN
      IF rst ='1' THEN
         wbm_ru_done    <= '0';
         wbm_ru_state   <= IDLE;
         wbm_ru_cyc     <= '0';
         
      ELSIF clk'EVENT AND clk ='1' THEN
         CASE wbm_ru_state IS
            WHEN IDLE =>
               wbm_ru_done <= '0';
               
               IF wbm_ru_start = '1' THEN
                  wbm_ru_state   <= PER_REQ;
                  wbm_ru_cyc     <= '1';
               ELSE
                  wbm_ru_state   <= IDLE;
                  wbm_ru_cyc     <= '0';
               END IF;
               
            WHEN PER_REQ =>
               IF wbm_ru_ack = '1' THEN
                  wbm_ru_state   <= ACKNOWLEDGE;
                  wbm_ru_cyc     <= '0';
                  wbm_ru_done    <= '1';
                  
               ELSE
                  wbm_ru_state   <= PER_REQ;
                  wbm_ru_cyc     <= '1';
                  wbm_ru_done    <= '0';
                  
               END IF;
                
            WHEN ACKNOWLEDGE =>
                wbm_ru_state  <= IDLE;
                wbm_ru_cyc    <= '0';
                wbm_ru_done   <= '0';
               
-- coverage off
            WHEN OTHERS =>
               wbm_ru_state   <= IDLE;
               wbm_ru_cyc     <= '0';
               wbm_ru_done    <= '0';
               
               ASSERT FALSE REPORT "Undecoded State" SEVERITY WARNING;
-- coverage on
         END CASE;
      END IF;
   END PROCESS z126_01_wbm_ru_fsm_proc;
   
   -- state machine for generating wishbone master access from a wishbone slave access
   z126_01_wbm_fsm_proc: PROCESS(clk, rst)
   BEGIN
      IF rst ='1' THEN
         wbm_cyc_int <= '0';
         wbm_done    <= '0';
         wbm_state   <= IDLE;
         
      ELSIF clk'EVENT AND clk ='1' THEN
         CASE wbm_state IS
            WHEN IDLE =>
               wbm_done    <= '0';
               
               IF wbm_start = '1' THEN
                  wbm_state   <= PER_REQ;
                  wbm_cyc_int <= '1';
               ELSE
                  wbm_state   <= IDLE;
                  wbm_cyc_int <= '0';
               END IF;
               
            WHEN PER_REQ =>
               IF wbm_ack = '1' THEN
                  wbm_state   <= ACKNOWLEDGE;
                  wbm_done    <= '1';
                  wbm_cyc_int <= '0';
               ELSE
                  wbm_state   <= PER_REQ;
                  wbm_done    <= '0';
                  wbm_cyc_int <= '1';
               END IF;
                
            WHEN ACKNOWLEDGE =>
                wbm_state     <= IDLE;
                wbm_done      <= '0';
                wbm_cyc_int   <= '0';
                
-- coverage off
            WHEN OTHERS =>
               wbm_state   <= IDLE;
               wbm_done    <= '0';
               wbm_cyc_int <= '0';
               ASSERT FALSE REPORT "Undecoded State" SEVERITY WARNING;
-- coverage on
         END CASE;
      END IF;
   END PROCESS z126_01_wbm_fsm_proc;

END z126_01_indi_if_ctrl_regs_arch;
