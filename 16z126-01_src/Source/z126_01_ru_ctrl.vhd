---------------------------------------------------------------
-- Title         : Remote Update Control
-- Project       : General IP-core
---------------------------------------------------------------
-- Author        : Andreas Geissler
-- Email         : Andreas.Geissler@men.de
-- Organization  : MEN Mikro Elektronik Nuremberg GmbH
-- Created       : 03/02/14
---------------------------------------------------------------
-- Simulator     : ModelSim-Altera PE 6.4c
-- Synthesis     : Quartus II 12.1 SP2
---------------------------------------------------------------
-- Description : The module is used to control the 
-- serial loading of the FPGA image using the
-- altera remote update block.
---------------------------------------------------------------
-- Hierarchy:
--    z126_01_ru_ctrl.vhd
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
-- $Revision: 1.6 $
--
-- $Log: z126_01_ru_ctrl.vhd,v $
-- Revision 1.6  2014/12/02 10:32:24  AGeissler
-- R1: The watchdog value is not correctly set, so that the user image could not
--     be loaded
-- M1: Changed param value from enable to value
--
-- Revision 1.5  2014/11/24 16:44:16  AGeissler
-- R1: Magic numbers
-- M1: Added constants for used coded signals
-- R2:   New naming convention of FPGA images
-- M2.1: Renamed application image to FPGA Image
-- M2.2: Renamed factor image to FPGA Fallback Image
--
-- Revision 1.4  2014/07/11 09:58:14  AGeissler
-- R1: If the 16z126-01 is used with a high freqency (wishbone clock) the
--     loading of a user image always failed. The reset_timer signal is not
--     long enough active. The reset must be active for at least 250ns at cyclone IV
--     devices (the altera device handbook).
-- M1: Added a clock divider to increase the active time of the reset_timer signal
--
-- Revision 1.3  2014/06/18 17:06:04  AGeissler
-- R1: MAIN_PR001588:
--     When nStatus is set instead of crc error when a user image is corrupt and generic USER_IMAGE is true the system will hang up completely.
-- M1: Added nStatus as an error in FSM condition
--
-- Revision 1.2  2014/03/05 11:19:39  AGeissler
-- R: Missing reset for signal
-- M: Added reset
--
-- Revision 1.1  2014/03/03 17:49:49  AGeissler
-- Initial Revision
--
--
--
---------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.fpga_pkg_2.all;
USE work.z126_01_pkg.all;

ENTITY z126_01_ru_ctrl IS
   GENERIC
   (
      FPGA_FAMILY             : family_type := CYCLONE4; -- see SUPPORTED_FPGA_FAMILIES for supported FPGA family types
      LOAD_FPGA_IMAGE         : boolean := TRUE;         -- true  => after configuration of the FPGA Fallback Image the FPGA Image is loaded immediately (can only be set when USE_REMOTE_UPDATE = TRUE)
                                                         -- false => after configuration the FPGA stays in the FPGA Fallback Image, FPGA Image must be loaded by software
      LOAD_FPGA_IMAGE_ADR     : std_logic_vector(23 DOWNTO 0) := (OTHERS=>'0')  -- if LOAD_FPGA_IMAGE = TRUE this address is the offset to the FPGA Image in the serial flash
   );
   PORT
   (
      clk                     : IN std_logic;                     -- system clock
      rst                     : IN std_logic;                     -- unit ru_ctrl_reset
      
      -- register interface
      wbs_reg_cyc             : IN  std_logic;
      wbs_reg_ack             : OUT std_logic;
      wbs_reg_we              : IN  std_logic;
      wbs_reg_sel             : IN  std_logic_vector(3 DOWNTO 0);
      wbs_reg_dat_o           : OUT std_logic_vector(31 DOWNTO 0);
      wbs_reg_dat_i           : IN  std_logic_vector(31 DOWNTO 0);
      
      reg_reconfig            : IN  std_logic;                       -- reconfiguration trigger from register interface
      reg_reconfig_cond       : OUT std_logic_vector(4 DOWNTO 0);    -- reconfiguration trigger condition of last reconfiguration
      reg_board_status        : OUT std_logic_vector(1 DOWNTO 0);    -- gives information whether the loading process was successful or not
      
      -- ALTREMOTE_UPDATE interface
      ru_ctrl_busy            : IN  std_logic;
      ru_ctrl_data_out        : IN  std_logic_vector(28 DOWNTO 0);   -- data from altera remote update module
      ru_ctrl_data_in         : OUT std_logic_vector(23 DOWNTO 0);   -- data to altera remote update module
      ru_ctrl_param           : OUT std_logic_vector(2 DOWNTO 0);
      ru_ctrl_read_param      : OUT std_logic;
      ru_ctrl_read_source     : OUT std_logic_vector(1 DOWNTO 0);
      ru_ctrl_reconfig        : OUT std_logic;
      ru_ctrl_reset_timer     : OUT std_logic;
      ru_ctrl_reset           : OUT std_logic;
      ru_ctrl_write_param     : OUT std_logic
   );
END z126_01_ru_ctrl;

ARCHITECTURE z126_01_ru_ctrl_arch OF z126_01_ru_ctrl IS

   TYPE ru_ctrl_states IS (IDLE,
                           READ_CURR_STATE,
                           READ_RECONFIG_COND,
                           CHECK_STATE,
                           WRITE_BOOT_ADDR,
                           WRITE_WATCHDOG_VALUE,
                           WRITE_WATCHDOG_ENABLE,
                           RECONFIGURE,
                           FPGA_IMAGE,
                           FALLBACK_IMAGE,
                           WRITE_BOOT_ADDR_WB_FALLBACK,
                           READ_BOOT_ADDR_WB_FALLBACK,
                           READ_BOOT_ADDR_WB_FGPA_IMAGE
                           );
   
   CONSTANT SUPPORTED_DEVICES : supported_family_types := (CYCLONE3, CYCLONE4);
   
   SIGNAL ru_ctrl_state          : ru_ctrl_states := IDLE;           -- remote update control block state signal
   
   -- registers
   SIGNAL reconfig_cond          : std_logic_vector(4 DOWNTO 0);     -- reconfiguration trigger condition of last reconfiguration
   SIGNAL curr_state             : std_logic_vector(1 DOWNTO 0);     -- current state of fpga
   SIGNAL boot_addr              : std_logic_vector(23 DOWNTO 0);    -- fpga boot addr (only write able in Factory Mode)
   SIGNAL board_status           : std_logic_vector(1 DOWNTO 0);     -- current state of fpga
   
   -- delayed busy signal
   SIGNAL ru_ctrl_busy_q         : std_logic := '0';                 -- used for edge detection
   SIGNAL ru_ctrl_busy_qq        : std_logic := '0';                 -- used for delayed edge detection (for generate wb ack)
   
   -- wishbone ack
   SIGNAL wbs_reg_ack_int        : std_logic := '0';                 -- wishbone acknowledge internal
   
   -- reset
   SIGNAL reset_timer_int        : std_logic := '0';                 -- reset watchdog timer (triggers on falling edge)
   SIGNAL reset_timer_cnt        : std_logic_vector(15 DOWNTO 0);    -- counter for reset watchdog timer (the watchdog reset must 
                                                                     -- be active for at least 250 ns!!)
BEGIN
   
   -- wishbone data out
   wbs_reg_dat_o  <= x"00" & boot_addr;
   wbs_reg_ack    <= wbs_reg_ack_int;
   
   -- data to remote update controller
   ru_ctrl_dat_in_proc : PROCESS (ru_ctrl_state, boot_addr) IS
   BEGIN
      CASE ru_ctrl_state IS
         WHEN WRITE_BOOT_ADDR_WB_FALLBACK =>
            ru_ctrl_data_in <= boot_addr(23 DOWNTO 0);
         WHEN WRITE_BOOT_ADDR =>
            ru_ctrl_data_in <= LOAD_FPGA_IMAGE_ADR(23 DOWNTO 0);
         WHEN WRITE_WATCHDOG_ENABLE =>
            -- enable watchdog
            ru_ctrl_data_in <= x"000001";
         WHEN WRITE_WATCHDOG_VALUE =>
            -- the first 12 bit are the highest 12 bit (of 29 bit) in the watchdog timer value
            ru_ctrl_data_in <= x"000" & x"100";    -- => 33554432 clock cycle (2^25) => ~1 sec
         WHEN OTHERS =>
            ru_ctrl_data_in <= x"000000";
      END CASE;
   END PROCESS;
   
   -- reset remote update controller when reconfiguration from FPGA Image
   ru_ctrl_reset        <= rst;                                                  -- reset remote update controller
   ru_ctrl_reconfig     <= '1' WHEN ru_ctrl_state = RECONFIGURE ELSE '0';        -- start reconfiguration
   ru_ctrl_reset_timer  <= reset_timer_int;                                      -- reset watchdog timer
   
   -- register out
   reg_reconfig_cond  <= reconfig_cond;      -- reconfiguration trigger condition of last reconfiguration
   reg_board_status   <= board_status;       -- gives information whether the loading process was successful or not
   
   -- wishbone acknowledge and watchdog counter
   ru_ctrl_wb_ack_and_wdog_cnt_proc : PROCESS (clk, rst) IS
   BEGIN
      IF rst = '1' THEN
         wbs_reg_ack_int <= '0';
         reset_timer_cnt <= (OTHERS=>'0');
         
      ELSIF rising_edge(clk) THEN
         
         -- wishbone acknowledge
         IF wbs_reg_cyc = '1' AND wbs_reg_we = '1' AND wbs_reg_ack_int = '0' THEN
            wbs_reg_ack_int <= '1';
         ELSIF wbs_reg_cyc = '1' AND wbs_reg_we = '0' AND ru_ctrl_busy_qq = '1' AND ru_ctrl_busy_q = '0' THEN
            -- read acknowledge when busy falling edge delayed by 1 cycle (1 cycle needed to write the register)
            wbs_reg_ack_int <= '1';
         ELSE
            wbs_reg_ack_int <= '0';
         END IF;
         
         -- watchdog counter
         IF ru_ctrl_state = FPGA_IMAGE THEN
            reset_timer_cnt <= std_logic_vector(unsigned(reset_timer_cnt) + 1);
         ELSE
            reset_timer_cnt <= (OTHERS=>'0');
         END IF;
         
      END IF;
   END PROCESS;
   
   ru_ctrl_cyc3_cyc4_proc : PROCESS (clk, rst) IS
   BEGIN
      IF rst = '1' THEN
         ru_ctrl_state           <= IDLE;
         ru_ctrl_param           <= (OTHERS=>'0');
         ru_ctrl_read_param      <= '0';
         ru_ctrl_read_source     <= (OTHERS=>'0');
         ru_ctrl_write_param     <= '0';
         ru_ctrl_busy_q          <= '0';
         ru_ctrl_busy_qq         <= '0';
         
         reconfig_cond           <= (OTHERS=>'0');
         curr_state              <= (OTHERS=>'0');
         board_status            <= (OTHERS=>'0');
         boot_addr               <= (OTHERS=>'0');
         
         reset_timer_int         <= '0';
      ELSIF falling_edge(clk) THEN
         
         ru_ctrl_busy_q    <= ru_ctrl_busy;
         ru_ctrl_busy_qq   <= ru_ctrl_busy_q;
         
         -- board status register
         IF (ru_ctrl_state = CHECK_STATE 
            AND (    reconfig_cond(3) = '1' -- CRC-Error
                  OR reconfig_cond(2) = '1' -- nStatus triggered
                  OR reconfig_cond(1) = '1' -- watchdog timeout
                  ) ) THEN
            board_status   <= "10";    -- error while loading image (FPGA Fallback Image is loaded!)
         ELSIF curr_state /= "00" THEN
            board_status   <= "01";    -- FPGA Image loaded
         END IF;
         
         -- last reconfiguration condition register
         IF ru_ctrl_state = READ_RECONFIG_COND AND ru_ctrl_busy = '0' AND ru_ctrl_busy_q = '1' THEN
            reconfig_cond  <= ru_ctrl_data_out(4 DOWNTO 0);  -- get data from remote update block
         END IF;
         
         -- current state register
         IF ru_ctrl_state = READ_CURR_STATE AND ru_ctrl_busy = '0' AND ru_ctrl_busy_q = '1' THEN
            curr_state  <= ru_ctrl_data_out(1 DOWNTO 0);     -- get data from remote update block
         END IF;
         
         -- boot address register
         IF wbs_reg_cyc = '1' AND wbs_reg_we = '1' THEN
            IF wbs_reg_sel(0) = '1' THEN
               boot_addr(7 DOWNTO 2)   <= wbs_reg_dat_i(7 DOWNTO 2);
            END IF;
            IF wbs_reg_sel(1) = '1' THEN
               boot_addr(15 DOWNTO 8)   <= wbs_reg_dat_i(15 DOWNTO 8);
            END IF;
            IF wbs_reg_sel(2) = '1' THEN
               boot_addr(23 DOWNTO 16)   <= wbs_reg_dat_i(23 DOWNTO 16);
            END IF;
         ELSIF ru_ctrl_state = READ_BOOT_ADDR_WB_FALLBACK AND ru_ctrl_busy = '0' AND ru_ctrl_busy_q = '1' THEN
            -- read boot address from remote update controller at falling edge of busy signal
            -- on FPGA Fallback Image the boot address width is 22 bit
            boot_addr <= ru_ctrl_data_out(21 DOWNTO 0) & "00";
         ELSIF ru_ctrl_state = READ_BOOT_ADDR_WB_FGPA_IMAGE AND ru_ctrl_busy = '0' AND ru_ctrl_busy_q = '1' THEN
            -- read boot address from remote update controller at falling edge of busy signal
            -- on FPGA Image the boot address width is 22 bit
            boot_addr <= ru_ctrl_data_out(23 DOWNTO 0);
         END IF;
         
         CASE ru_ctrl_state IS
            
            WHEN IDLE =>
               -- read current state of remote update controller
               ru_ctrl_state        <= READ_CURR_STATE;
               ru_ctrl_param        <= Z126_01_RU_STATE_MODE_PAR_CYC4;  -- master StateMachineCurrent StateMode
               ru_ctrl_read_param   <= '0';
               ru_ctrl_read_source  <= (OTHERS=>'0');    -- read from current source
               ru_ctrl_write_param  <= '0';
               
            WHEN READ_CURR_STATE =>
               -- wait for falling edge of delayed busy signal (wait until curr_state is written)
               IF ru_ctrl_busy_q = '0' AND ru_ctrl_busy_qq = '1' AND curr_state = "00" THEN
                  -- read reconfiguration trigger condition source when in Factory Mode
                  ru_ctrl_state        <= READ_RECONFIG_COND;
                  ru_ctrl_param        <= Z126_01_RU_RECONF_CON_PAR_CYC4;  -- reconfiguration trigger condition source
                  ru_ctrl_read_param   <= '1';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_PREVIOUS_1;    -- read from past source
                  ru_ctrl_write_param  <= '0';
                  
               ELSIF ru_ctrl_busy_q = '0' AND ru_ctrl_busy_qq = '1' THEN
                  -- the FPGA Image is successfully loaded
                  -- the reconfiguration condition can only be read in Factory Mode!
                  ru_ctrl_state        <= FPGA_IMAGE;
                  ru_ctrl_param        <= "000";
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '0';
                  
               ELSIF ru_ctrl_busy = '0' AND ru_ctrl_busy_q = '1' THEN
                  -- wait one cycle longer to store data in curr_state register
                  -- disable remote update controller access
                  ru_ctrl_state        <= READ_CURR_STATE;
                  ru_ctrl_param        <= "000";
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '0';
                  
               ELSE
                  -- read current state of remote update controller
                  ru_ctrl_state        <= READ_CURR_STATE;
                  ru_ctrl_param        <= Z126_01_RU_STATE_MODE_PAR_CYC4;  -- master StateMachineCurrent StateMode
                  ru_ctrl_read_param   <= '1';        -- read access
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;       -- read from current source
                  ru_ctrl_write_param  <= '0';
                  
               END IF;
                  
            WHEN READ_RECONFIG_COND =>
               -- wait for falling edge of busy signal
               IF ru_ctrl_busy = '0' AND ru_ctrl_busy_q = '1' THEN
                  -- check in which state is the FPGA
                  ru_ctrl_state        <= CHECK_STATE;
                  ru_ctrl_param        <= "000";
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '0';
                  
               ELSE
                  -- read reconfiguration trigger condition source
                  ru_ctrl_state        <= READ_RECONFIG_COND;
                  ru_ctrl_param        <= Z126_01_RU_RECONF_CON_PAR_CYC4;  -- reconfiguration trigger condition source
                  ru_ctrl_read_param   <= '1';                             -- read access
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_PREVIOUS_1;    -- read from past source
                  ru_ctrl_write_param  <= '0';
                  
               END IF;
               
            WHEN CHECK_STATE =>
               IF LOAD_FPGA_IMAGE = TRUE AND reconfig_cond(3) = '0' AND reconfig_cond(2) = '0' AND reconfig_cond(1) = '0' THEN
                  -- we are still in the FPGA Fallback Image and no error
                  -- start loading the FPGA Image (enable watchdog)
                  -- write boot address
                  ru_ctrl_state        <= WRITE_BOOT_ADDR;
                  ru_ctrl_param        <= Z126_01_RU_BOOT_ADR_PAR_CYC4; -- boot address
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '1';                          -- write access
                  
               ELSE
                  -- the FPGA Fallback Image is loaded
                  ru_ctrl_state        <= FALLBACK_IMAGE;
                  ru_ctrl_param        <= "000";
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '0';
                  
               END IF;
               
            WHEN WRITE_WATCHDOG_VALUE  =>
               -- wait for falling edge of busy signal
               IF ru_ctrl_busy = '0' AND ru_ctrl_busy_q = '1' THEN
                  -- enable watchdog
                  ru_ctrl_state        <= WRITE_WATCHDOG_ENABLE;
                  ru_ctrl_param        <= Z126_01_RU_WDOG_EN_PAR_CYC4;  -- watchdog enable
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '1';                          -- write access
                  
               ELSE
                  -- write watchdog time out value
                  ru_ctrl_state        <= WRITE_WATCHDOG_VALUE;
                  ru_ctrl_param        <= Z126_01_RU_WDOG_VAL_PAR_CYC4; -- watchdog value
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '1';                          -- write access
                  
               END IF;
               
            WHEN WRITE_WATCHDOG_ENABLE =>
               -- wait for falling edge of busy signal
               IF ru_ctrl_busy = '0' AND ru_ctrl_busy_q = '1' THEN
                  -- reconfiguration
                  ru_ctrl_state        <= RECONFIGURE;
                  ru_ctrl_param        <= "000";
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '0';
                  
               ELSE
                  -- enable watchdog
                  ru_ctrl_state        <= WRITE_WATCHDOG_ENABLE;
                  ru_ctrl_param        <= Z126_01_RU_WDOG_EN_PAR_CYC4;  -- watchdog enable
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '1';                          -- write access
                  
               END IF;
               
            WHEN WRITE_BOOT_ADDR =>
               IF ru_ctrl_busy = '0' AND ru_ctrl_busy_q = '1' THEN
                  -- write watchdog time out value and start reconfiguration
                  ru_ctrl_state        <= WRITE_WATCHDOG_VALUE;
                  ru_ctrl_param        <= Z126_01_RU_WDOG_VAL_PAR_CYC4; -- watchdog value
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '1';                          -- write access
                  
               ELSE
                  -- write boot address
                  ru_ctrl_state        <= WRITE_BOOT_ADDR;
                  ru_ctrl_param        <= Z126_01_RU_BOOT_ADR_PAR_CYC4; -- boot address
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '1';                          -- write access
                  
               END IF;
               
            WHEN RECONFIGURE =>
               -- start reconfiguration
               ru_ctrl_param        <= "000";
               ru_ctrl_read_param   <= '0';
               ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
               ru_ctrl_write_param  <= '0';
               
               -- fpga should be reconfigurated so the fsm should stay in this state
               -- until the reconfiguration is finished
               ru_ctrl_state  <= RECONFIGURE;
               
            WHEN FPGA_IMAGE =>
               -- reset the watchdog timer if the FPGA Image is successfully loaded
               -- (the watchdog timer is reset on falling edge of reset_timer_int)
               -- if the watchdog expires the FPGA Fallback Image will be loaded again
               reset_timer_int <= reset_timer_cnt(reset_timer_cnt'high);
               
               IF wbs_reg_cyc = '1' AND wbs_reg_we = '0' THEN
                  -- indirecte interface register access read boot address
                  ru_ctrl_state        <= READ_BOOT_ADDR_WB_FGPA_IMAGE;
                  ru_ctrl_param        <= Z126_01_RU_BOOT_ADR_PAR_CYC4; -- boot address
                  ru_ctrl_read_param   <= '1';                          -- read access
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_PREVIOUS_2; -- current Application Mode boot address
                  ru_ctrl_write_param  <= '0';
                  
               ELSIF reg_reconfig = '1' THEN
                  -- start reconfiguration
                  ru_ctrl_state        <= RECONFIGURE;
                  ru_ctrl_param        <= "000";
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '0';
                  
               ELSE
                  -- stay in FPGA Image
                  ru_ctrl_state        <= FPGA_IMAGE;
                  ru_ctrl_param        <= "000";
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '0';
                  
               END IF;
               
            WHEN FALLBACK_IMAGE =>
               IF wbs_reg_cyc = '1' AND wbs_reg_we = '1' THEN
                  -- indirecte interface register access write boot address
                  ru_ctrl_state        <= WRITE_BOOT_ADDR_WB_FALLBACK;
                  ru_ctrl_param        <= Z126_01_RU_BOOT_ADR_PAR_CYC4;    -- boot address
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '1';                             -- write access
                  
               ELSIF wbs_reg_cyc = '1' AND wbs_reg_we = '0' THEN
                  -- indirecte interface register access read boot address
                  ru_ctrl_state        <= READ_BOOT_ADDR_WB_FALLBACK;
                  ru_ctrl_param        <= Z126_01_RU_BOOT_ADR_PAR_CYC4;    -- boot address
                  ru_ctrl_read_param   <= '1';                             -- read access
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_INPUT_REG;     -- read boot address from Factory Mode 
                                                                           -- (current contents is in input register)
                  ru_ctrl_write_param  <= '0';
                  
               ELSIF reg_reconfig = '1' THEN
                  -- enable watchdog and start reconfiguration
                  ru_ctrl_state        <= WRITE_WATCHDOG_VALUE;
                  ru_ctrl_param        <= Z126_01_RU_WDOG_VAL_PAR_CYC4; -- set watchdog value
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '1';                          -- write access
                  
               ELSE
                  -- stay in FPGA Fallback Image
                  ru_ctrl_state        <= FALLBACK_IMAGE;
                  ru_ctrl_param        <= "000";
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '0';
                  
               END IF;
               
            WHEN READ_BOOT_ADDR_WB_FALLBACK =>
               IF ru_ctrl_busy_q = '0' AND ru_ctrl_busy_qq = '1' THEN
                  -- wait one cycle longer to acknowledge the wishbone bus with the correct data
                  -- stay in FPGA Fallback Image
                  ru_ctrl_state        <= FALLBACK_IMAGE;
                  ru_ctrl_param        <= "000";
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '0';
                  
               ELSIF ru_ctrl_busy = '0' AND ru_ctrl_busy_q = '1' THEN
                  -- wait one cycle
                  ru_ctrl_state        <= READ_BOOT_ADDR_WB_FALLBACK;
                  ru_ctrl_param        <= "000";
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '0';
                  
               ELSE
                  -- read boot address
                  ru_ctrl_state        <= READ_BOOT_ADDR_WB_FALLBACK;
                  ru_ctrl_param        <= Z126_01_RU_BOOT_ADR_PAR_CYC4; -- boot address
                  ru_ctrl_read_param   <= '1';                          -- write access
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_INPUT_REG;  -- read boot address from Factory Mode 
                                                                        -- (current contents is in input register)
                  ru_ctrl_write_param  <= '0';
                  
               END IF;
               
            WHEN READ_BOOT_ADDR_WB_FGPA_IMAGE =>
               IF ru_ctrl_busy_q = '0' AND ru_ctrl_busy_qq = '1' THEN
                  -- wait one cycle longer to acknowledge the wishbone bus with the correct data
                  -- stay in FPGA Image
                  ru_ctrl_state        <= FPGA_IMAGE;
                  ru_ctrl_param        <= "000";
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '0';
                  
               ELSIF ru_ctrl_busy = '0' AND ru_ctrl_busy_q = '1' THEN
                  -- wait one cycle longer to acknowledge the wishbone bus with the correct data
                  -- disable remote update controller access
                  ru_ctrl_state        <= READ_BOOT_ADDR_WB_FGPA_IMAGE;
                  ru_ctrl_param        <= "000";
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '0';
                  
               ELSE
                  -- read boot address
                  ru_ctrl_state        <= READ_BOOT_ADDR_WB_FGPA_IMAGE;
                  ru_ctrl_param        <= Z126_01_RU_BOOT_ADR_PAR_CYC4; -- boot address
                  ru_ctrl_read_param   <= '1';                          -- write access
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_PREVIOUS_2; -- current Application Mode boot address
                  ru_ctrl_write_param  <= '0';
                  
               END IF;
               
            WHEN WRITE_BOOT_ADDR_WB_FALLBACK =>
               IF ru_ctrl_busy = '0' AND ru_ctrl_busy_q = '1' THEN
                  -- stay in FPGA Fallback Image
                  ru_ctrl_state        <= FALLBACK_IMAGE;
                  ru_ctrl_param        <= "000";
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '0';
                  
               ELSE
                  -- write boot address
                  ru_ctrl_state        <= WRITE_BOOT_ADDR_WB_FALLBACK;
                  ru_ctrl_param        <= Z126_01_RU_BOOT_ADR_PAR_CYC4; -- boot address
                  ru_ctrl_read_param   <= '0';
                  ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
                  ru_ctrl_write_param  <= '1';                          -- write access
                  
               END IF;
               
            -- coverage off
            WHEN OTHERS =>
               ru_ctrl_state        <= IDLE;
               ru_ctrl_param        <= "000";
               ru_ctrl_read_param   <= '0';
               ru_ctrl_read_source  <= Z126_01_RU_RD_SRC_CURRENT;
               ru_ctrl_write_param  <= '0';
            -- coverage on
            
         END CASE;
      END IF;
   END PROCESS;
   
END z126_01_ru_ctrl_arch;
