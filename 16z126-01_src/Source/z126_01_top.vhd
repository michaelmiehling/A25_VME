---------------------------------------------------------------
-- Title         : Wishbone to Serial Flash Interface
-- Project       : 16z126-01
---------------------------------------------------------------
-- File          : z126_01_top.vhd
-- Author        : Andreas Geissler
-- Email         : Andreas.Geissler@men.de
-- Organization  : MEN Mikro Elektronik Nuremberg GmbH
-- Created       : 03/02/14
---------------------------------------------------------------
-- Simulator     : ModelSim-Altera PE 6.4c
-- Synthesis     : Quartus II 12.1 SP2
---------------------------------------------------------------
-- Description :
-- 16z126-01 is a Wishbone to Serial Flash interface Altera EPCS
-- Devices. Derived from 16z126-.
---------------------------------------------------------------
-- Hierarchy:
-- z126_01_top
--    z126_01_ru_<FLASH>
--    z126_01_ru_ctrl
--    z126_01_indi_if_ctrl_regs
--    z126_01_clk_trans_indirect
--    z126_01_clk_trans_direct
--    z126_01_wb_if_arbiter
--    z126_01_wb2pasmi
--    z126_01_pasmi_<FAMILY>
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
-- $Log: z126_01_top.vhd,v $
-- Revision 1.6  2015/02/19 14:01:52  AGeissler
-- R1: Warning message from quartus because of unused signal
-- M1: Only describe this signal when direct interface is used
--
-- Revision 1.5  2014/11/24 16:44:20  AGeissler
-- R1:   New naming convention of FPGA images
-- M1.1: Renamed application image to FPGA Image
-- M1.2: Renamed factor image to FPGA Fallback Image
-- R2:   Missing Cyclone V support
-- M2.1: Added z126_01_ru_ctrl_cyc5
-- M2.2: Added z126_01_ru_cyclonev_m25p32
-- M2.3: Added z126_01_ru_cyclonev_m25p64
-- M2.4: Added z126_01_ru_cyclonev_m25p128
--
-- Revision 1.4  2014/07/11 09:58:16  AGeissler
-- R1: Components are needed even if they are not used
-- M1: Added components instead of entities
--
-- Revision 1.3  2014/06/18 17:06:07  AGeissler
-- R1: The z126_01_pasmi_sim_m25p32 was be added in the source fileset
-- M1: Added a component instead of using the entity directly
--
-- Revision 1.2  2014/03/05 11:19:41  AGeissler
-- R: Missing signal connection
-- M: Added
--
-- Revision 1.1  2014/03/03 17:49:54  AGeissler
-- Initial Revision
--
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.z126_01_wb_pkg.ALL;
USE work.z126_01_pkg.ALL;
USE work.fpga_pkg_2.ALL;

ENTITY z126_01_top IS
   GENERIC (
      SIMULATION              : boolean := FALSE;           -- true  => use the altasmi parallel of an older quartus version (11.1 SP2) the new one can not be simulated
                                                            --          (only the M25P32 is supported for simulation!!)
                                                            -- false => use the newest altasmi parallel (13.0)
      FPGA_FAMILY             : family_type := CYCLONE5;    -- see SUPPORTED_FPGA_FAMILIES for supported FPGA family types
      FLASH_TYPE              : flash_type  := M25P32;      -- see SUPPORTED_DEVICES for supported serial flash device types
      USE_DIRECT_INTERFACE    : boolean := TRUE;            -- true  => the direct interfaces is included and arbitrated with the indirect interface
                                                            -- false => only the indirect interface is available (reducing resource consumption)
      USE_REMOTE_UPDATE       : boolean := TRUE;            -- true  => the remote update controller is included and more than one FPGA image can be selected
                                                            -- false => only the FPGA Fallback Image can be used for FPGA configuration (reducing resource consumption)
      LOAD_FPGA_IMAGE         : boolean := TRUE;            -- true  => after configuration of the FPGA Fallback Image the FPGA Image is loaded immediately (can only be set when USE_REMOTE_UPDATE = TRUE)
                                                            -- false => after configuration the FPGA stays in the FPGA Fallback Image, FPGA Image must be loaded by software
      LOAD_FPGA_IMAGE_ADR     : std_logic_vector(23 DOWNTO 0) := (OTHERS=>'0')  -- if LOAD_FPGA_IMAGE = TRUE this address is the offset to the FPGA Image in the serial flash
   );
   PORT (
      clk_40mhz               : IN  std_logic;  -- serial flash clock (maximum 40 MHz)
      rst_clk_40mhz           : IN  std_logic;  -- this reset should be a power up reset to 
                                                -- reduce the reconfiguration (load FPGA Image) time when LOAD_FPGA_IMAGE = TRUE.
                                                -- this reset must be deasserted synchronous to the clk_40mhz
                                                                   
      clk_dir                 : IN  std_logic;  -- wishbone clock for direct interface
      rst_dir                 : IN  std_logic;  -- wishbone async high active reset
                                                -- this reset must be deasserted synchronous to the clk_dir
      
      clk_indi                : IN  std_logic;  -- wishbone clock for indirect interface
      rst_indi                : IN  std_logic;  -- wishbone async high active reset
                                                -- this reset must be deasserted synchronous to the clk_indi
      
      board_status            : OUT std_logic_vector(1 DOWNTO 0);
      
      -- wishbone signals slave interface 0 (direct addressing)
      wbs_stb_dir             : IN  std_logic;                     -- request
      wbs_ack_dir             : OUT std_logic;                     -- acknoledge
      wbs_we_dir              : IN  std_logic;                     -- write=1 read=0
      wbs_sel_dir             : IN  std_logic_vector(3 DOWNTO 0);  -- byte enables
      wbs_cyc_dir             : IN  std_logic;                     -- chip select
      wbs_dat_o_dir           : OUT std_logic_vector(31 DOWNTO 0); -- data out
      wbs_dat_i_dir           : IN  std_logic_vector(31 DOWNTO 0); -- data in
      wbs_adr_dir             : IN  std_logic_vector(31 DOWNTO 0); -- address
      wbs_err_dir             : OUT std_logic;                     -- error
      
      -- wishbone signals slave interface 1 (indirect addressing)
      wbs_stb_indi            : IN  std_logic;                     -- request
      wbs_ack_indi            : OUT std_logic;                     -- acknoledge
      wbs_we_indi             : IN  std_logic;                     -- write=1 read=0
      wbs_sel_indi            : IN  std_logic_vector(3 DOWNTO 0);  -- byte enables
      wbs_cyc_indi            : IN  std_logic;                     -- chip select
      wbs_dat_o_indi          : OUT std_logic_vector(31 DOWNTO 0); -- data out
      wbs_dat_i_indi          : IN  std_logic_vector(31 DOWNTO 0); -- data in
      wbs_adr_indi            : IN  std_logic_vector(31 DOWNTO 0); -- address
      wbs_err_indi            : OUT std_logic                      -- error
   );
END z126_01_top;



ARCHITECTURE z126_01_top_arch OF z126_01_top IS
   
   --------------------------------------------------------
   -- components
   --------------------------------------------------------
   COMPONENT z126_01_pasmi_m25p32 IS
      PORT
      (
         addr           : IN std_logic_vector(23 DOWNTO 0);
         bulk_erase     : IN std_logic ;
         clkin          : IN std_logic ;
         datain         : IN std_logic_vector(7 DOWNTO 0);
         fast_read      : IN std_logic ;
         rden           : IN std_logic ;
         read_rdid      : IN std_logic ;
         read_status    : IN std_logic ;
		     reset		      : IN STD_LOGIC ;
         sector_erase   : IN std_logic ;
         sector_protect : IN std_logic ;
         shift_bytes    : IN std_logic ;
         wren           : IN std_logic ;
         write          : IN std_logic ;
         busy           : OUT std_logic ;
         data_valid     : OUT std_logic ;
         dataout        : OUT std_logic_vector (7 DOWNTO 0);
         illegal_erase  : OUT std_logic ;
         illegal_write  : OUT std_logic ;
         rdid_out       : OUT std_logic_vector(7 DOWNTO 0);
         status_out     : OUT std_logic_vector(7 DOWNTO 0)
      );
   END COMPONENT;
   
   COMPONENT z126_01_pasmi_sim_m25p32 IS
   PORT
      (
         addr           : IN std_logic_vector(23 DOWNTO 0);
         bulk_erase     : IN std_logic;
         clkin          : IN std_logic;
         datain         : IN std_logic_vector(7 DOWNTO 0);
         fast_read      : IN std_logic;
         rden           : IN std_logic;
         read_rdid      : IN std_logic;
         read_status    : IN std_logic;
         sector_erase   : IN std_logic;
         sector_protect : IN std_logic;
         shift_bytes    : IN std_logic;
         wren           : IN std_logic;
         write          : IN std_logic;
         busy           : OUT std_logic;
         data_valid     : OUT std_logic;
         dataout        : OUT std_logic_vector(7 DOWNTO 0);
         illegal_erase  : OUT std_logic ;
         illegal_write  : OUT std_logic ;
         rdid_out       : OUT std_logic_vector(7 DOWNTO 0);
         status_out     : OUT std_logic_vector(7 DOWNTO 0)
      );
   END COMPONENT;
   
   COMPONENT z126_01_pasmi_m25p64 IS
      PORT
      (
         addr           : IN std_logic_vector(23 DOWNTO 0);
         bulk_erase     : IN std_logic ;
         clkin          : IN std_logic ;
         datain         : IN std_logic_vector(7 DOWNTO 0);
         fast_read      : IN std_logic ;
         rden           : IN std_logic ;
         read_rdid      : IN std_logic ;
         read_status    : IN std_logic ;
         reset          : IN std_logic ;
         sector_erase   : IN std_logic ;
         sector_protect : IN std_logic ;
         shift_bytes    : IN std_logic ;
         wren           : IN std_logic ;
         write          : IN std_logic ;
         busy           : OUT std_logic ;
         data_valid     : OUT std_logic ;
         dataout        : OUT std_logic_vector (7 DOWNTO 0);
         illegal_erase  : OUT std_logic ;
         illegal_write  : OUT std_logic ;
         rdid_out       : OUT std_logic_vector(7 DOWNTO 0);
         status_out     : OUT std_logic_vector(7 DOWNTO 0)
      );
   END COMPONENT;
   
   COMPONENT z126_01_pasmi_m25p128 IS
      PORT
      (
         addr           : IN std_logic_vector(23 DOWNTO 0);
         bulk_erase     : IN std_logic ;
         clkin          : IN std_logic ;
         datain         : IN std_logic_vector(7 DOWNTO 0);
         fast_read      : IN std_logic ;
         rden           : IN std_logic ;
         read_rdid      : IN std_logic ;
         read_status    : IN std_logic ;
         reset          : IN std_logic ;
         sector_erase   : IN std_logic ;
         sector_protect : IN std_logic ;
         shift_bytes    : IN std_logic ;
         wren           : IN std_logic ;
         write          : IN std_logic ;
         busy           : OUT std_logic ;
         data_valid     : OUT std_logic ;
         dataout        : OUT std_logic_vector (7 DOWNTO 0);
         illegal_erase  : OUT std_logic ;
         illegal_write  : OUT std_logic ;
         rdid_out       : OUT std_logic_vector(7 DOWNTO 0);
         status_out     : OUT std_logic_vector(7 DOWNTO 0)
      );
   END COMPONENT;
   
   COMPONENT z126_01_ru_cycloneiii IS
      PORT
      (
         clock          : IN std_logic;
         data_in        : IN std_logic_vector(23 DOWNTO 0);
         param          : IN std_logic_vector(2 DOWNTO 0);
         read_param     : IN std_logic;
         read_source    : IN std_logic_vector(1 DOWNTO 0);
         reconfig       : IN std_logic;
         reset          : IN std_logic;
         reset_timer    : IN std_logic;
         write_param    : IN std_logic;
         busy           : OUT std_logic;
         data_out       : OUT std_logic_vector(28 DOWNTO 0)
      );
   END COMPONENT;
   
   COMPONENT z126_01_ru_cycloneiv IS
      PORT
      (
         clock          : IN std_logic;
         data_in        : IN std_logic_vector(23 DOWNTO 0);
         param          : IN std_logic_vector(2 DOWNTO 0);
         read_param     : IN std_logic;
         read_source    : IN std_logic_vector(1 DOWNTO 0);
         reconfig       : IN std_logic;
         reset          : IN std_logic;
         reset_timer    : IN std_logic;
         write_param    : IN std_logic;
         busy           : OUT std_logic;
         data_out       : OUT std_logic_vector(28 DOWNTO 0)
      );
   END COMPONENT;
   
   --COMPONENT z126_01_ru_cyclonev_m25p32 IS
   --   PORT
   --   (
   --      clock          : IN std_logic;
   --      data_in        : IN std_logic_vector(23 DOWNTO 0);
   --      param          : IN std_logic_vector(2 DOWNTO 0);
   --      read_param     : IN std_logic;
   --      reconfig       : IN std_logic;
   --      reset          : IN std_logic;
   --      reset_timer    : IN std_logic;
   --      write_param    : IN std_logic;
   --      busy           : OUT std_logic;
   --      data_out       : OUT std_logic_vector(23 DOWNTO 0)
   --   );
   --END COMPONENT;
   --
   --COMPONENT z126_01_ru_cyclonev_m25p64 IS
   --   PORT
   --   (
   --      clock          : IN std_logic;
   --      data_in        : IN std_logic_vector(23 DOWNTO 0);
   --      param          : IN std_logic_vector(2 DOWNTO 0);
   --      read_param     : IN std_logic;
   --      reconfig       : IN std_logic;
   --      reset          : IN std_logic;
   --      reset_timer    : IN std_logic;
   --      write_param    : IN std_logic;
   --      busy           : OUT std_logic;
   --      data_out       : OUT std_logic_vector(23 DOWNTO 0)
   --   );
   --END COMPONENT;
   --
   --COMPONENT z126_01_ru_cyclonev_m25p128 IS
   --   PORT
   --   (
   --      clock          : IN std_logic;
   --      data_in        : IN std_logic_vector(23 DOWNTO 0);
   --      param          : IN std_logic_vector(2 DOWNTO 0);
   --      read_param     : IN std_logic;
   --      reconfig       : IN std_logic;
   --      reset          : IN std_logic;
   --      reset_timer    : IN std_logic;
   --      write_param    : IN std_logic;
   --      busy           : OUT std_logic;
   --      data_out       : OUT std_logic_vector(23 DOWNTO 0)
   --   );
   --END COMPONENT;
   
   COMPONENT z126_01_clk_trans_wb2wb IS
      GENERIC (
         NBR_OF_CYC  : integer range 1 TO 100 := 1;
         NBR_OF_TGA  : integer range 1 TO 100 := 6
      );
      PORT (
         rstn        : IN std_logic;
         
         -- a MHz domain
         clk_a       : IN std_logic;
         cyc_a       : IN std_logic_vector(NBR_OF_CYC-1 DOWNTO 0);
         stb_a       : IN std_logic;                           -- request signal from a MHz side
         ack_a       : OUT std_logic;                          -- adopted acknoledge signal to b MHz
         err_a       : OUT std_logic;
         
         we_a        : IN std_logic;                           -- '1' = write, '0' = read
         tga_a       : IN std_logic_vector(NBR_OF_TGA-1 DOWNTO 0);   
         cti_a       : IN std_logic_vector(2 DOWNTO 0);        -- transfer type
         bte_a       : IN std_logic_vector(1 DOWNTO 0);        -- incremental burst
         adr_a       : IN std_logic_vector(31 DOWNTO 0);       -- adr from a MHz side
         sel_a       : IN std_logic_vector(3 DOWNTO 0);        -- byte enables from a MHz side
         dat_i_a     : IN std_logic_vector(31 DOWNTO 0);       -- data from a MHz side
         dat_o_a     : OUT std_logic_vector(31 DOWNTO 0);      -- data from b MHz side to a MHz side
         
         -- b MHz domain
         clk_b       : IN std_logic;
         cyc_b       : OUT std_logic_vector(NBR_OF_CYC-1 DOWNTO 0);
         stb_b       : OUT std_logic;                          -- request signal adopted to b MHz
         ack_b       : IN std_logic;                           -- acknoledge signal from internal bus
         err_b       : IN std_logic;
         
         we_b        : OUT std_logic;                          -- '1' = write, '0' = read
         tga_b       : OUT std_logic_vector(NBR_OF_TGA-1 DOWNTO 0);  
         cti_b       : OUT std_logic_vector(2 DOWNTO 0);       -- transfer type
         bte_b       : OUT std_logic_vector(1 DOWNTO 0);       -- incremental burst
         adr_b       : OUT std_logic_vector(31 DOWNTO 0);      -- adr from b MHz side
         sel_b       : OUT std_logic_vector(3 DOWNTO 0);       -- byte enables for b MHz side
         dat_i_b     : IN std_logic_vector(31 DOWNTO 0);       -- data from b MHz side
         dat_o_b     : OUT std_logic_vector(31 DOWNTO 0)       -- data from a MHz side to b MHz side 
      );
   END COMPONENT;
   
   COMPONENT z126_01_wb_if_arbiter IS
      GENERIC (
         sets           : std_logic_vector(3 DOWNTO 0) := "1110";
         timeout        : integer := 5000 
      );
      PORT (
         clk                     : IN std_logic;
         rst                     : IN std_logic;
         
         -- master 0 interface
         wbmo_0                  : IN wbo_type;
         wbmi_0                  : OUT wbi_type;
         wbmo_0_cyc              : IN std_logic;
         
         -- wb2pasmi master 0 control signals
         ctrlmo_0                : IN ctrl_wb2pasmi_out_type;
         ctrlmi_0                : OUT ctrl_wb2pasmi_in_type;
         
         -- master 1 interface
         wbmo_1                  : IN wbo_type;
         wbmi_1                  : OUT wbi_type;
         wbmo_1_cyc              : IN std_logic;
         
         -- wb2pasmi master 1 control signals
         ctrlmo_1                : IN ctrl_wb2pasmi_out_type;
         ctrlmi_1                : OUT ctrl_wb2pasmi_in_type;
         
         -- slave 0 interface
         wbso_0                  : IN wbi_type;
         wbsi_0                  : OUT wbo_type;
         wbsi_0_cyc              : OUT std_logic;
         
         -- wb2pasmi slave 0 control signals
         ctrlso_0                : IN ctrl_wb2pasmi_in_type;
         ctrlsi_0                : OUT ctrl_wb2pasmi_out_type
         
      );
   END COMPONENT;
   
   COMPONENT z126_01_indi_if_ctrl_regs IS
      PORT (
         clk                   : IN  std_logic;                     -- Wishbone clock (66 MHz)
         rst                   : IN  std_logic;                     -- Reset
         
         -- wishbone signals master interface (ru_ctrol interace)
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
   END COMPONENT;
   
   COMPONENT z126_01_ru_ctrl IS
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
   END COMPONENT;
   
   COMPONENT z126_01_ru_ctrl_cyc5 IS
      GENERIC
      (
         FPGA_FAMILY             : family_type := CYCLONE5;    -- see SUPPORTED_FPGA_FAMILIES for supported FPGA family types
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
         ru_ctrl_data_out        : IN  std_logic_vector(23 DOWNTO 0);   -- data from altera remote update module
         ru_ctrl_data_in         : OUT std_logic_vector(23 DOWNTO 0);   -- data to altera remote update module
         ru_ctrl_param           : OUT std_logic_vector(2 DOWNTO 0);
         ru_ctrl_read_param      : OUT std_logic;
         ru_ctrl_reconfig        : OUT std_logic;
         ru_ctrl_reset_timer     : OUT std_logic;
         ru_ctrl_reset           : OUT std_logic;
         ru_ctrl_write_param     : OUT std_logic
      );
   END COMPONENT;
   
   --------------------------------------------------------
   -- constants
   --------------------------------------------------------
   CONSTANT SUPPORTED_DEVICES       : supported_flash_types    := (M25P32, M25P64, M25P128);
   CONSTANT SUPPORTED_FPGA_FAMILIES : supported_family_types   := (CYCLONE3, CYCLONE4, CYCLONE5);
   
   --------------------------------------------------------
   -- signals
   --------------------------------------------------------
   -- reset signals
   SIGNAL rstn_indi           : std_logic;
   SIGNAL rstn_dir            : std_logic;
   
   -- MASTER SIGNALS
   SIGNAL wbmo_1              : wbo_type;
   SIGNAL wbmi_1              : wbi_type;
   SIGNAL wbmo_1_cyc          : std_logic;
   -- SLAVE SIGNALS
   SIGNAL wbso_0              : wbi_type;
   SIGNAL wbsi_0              : wbo_type;
   SIGNAL wbsi_0_cyc          : std_logic;
   
   -- synchronised wishbone slave signals from direct interface
   SIGNAL fc_stb_dir          : std_logic;
   SIGNAL fc_cyc_dir          : std_logic;
   SIGNAL fc_ack_dir          : std_logic;
   SIGNAL fc_err_dir          : std_logic;
   SIGNAL fc_we_dir           : std_logic;
   SIGNAL fc_adr_dir          : std_logic_vector(31 DOWNTO 0);
   SIGNAL fc_sel_dir          : std_logic_vector( 3 DOWNTO 0);
   SIGNAL fc_dat_i_dir        : std_logic_vector(31 DOWNTO 0);
   SIGNAL fc_dat_o_dir        : std_logic_vector(31 DOWNTO 0);

   -- synchronised wishbone slave signals from indirect interface
   SIGNAL fc_stb_indi         : std_logic;
   SIGNAL fc_cyc_indi         : std_logic;
   SIGNAL fc_ack_indi         : std_logic;
   SIGNAL fc_adr_indi         : std_logic_vector(31 DOWNTO 0);
   SIGNAL fc_dat_o_indi       : std_logic_vector(31 DOWNTO 0);
   
   -- pasmi master signals from/to wishbone to pasmi
   SIGNAL wb_pasmi_m_o     : pasmi_out_type;
   SIGNAL wb_pasmi_m_i     : pasmi_in_type;
   
   -- wb direct interface control master signals for wb2pasmi interface
   SIGNAL wb_dir_ctrlm_o   : ctrl_wb2pasmi_out_type;
      
   -- wb indirect interface control master signals for wb2pasmi interface
   SIGNAL wb_indi_ctrlm_o  : ctrl_wb2pasmi_out_type;
   SIGNAL wb_indi_ctrlm_i  : ctrl_wb2pasmi_in_type;
      
   -- control slave signals for wb2pasmi interface
   SIGNAL wb_ctrls_o       : ctrl_wb2pasmi_in_type;
   SIGNAL wb_ctrls_i       : ctrl_wb2pasmi_out_type;
   
   -- remote update control unit signals
   SIGNAL ru_ctrl_busy            : std_logic;
   SIGNAL ru_ctrl_data_out        : std_logic_vector(28 DOWNTO 0);
   SIGNAL ru_ctrl_data_in         : std_logic_vector(23 DOWNTO 0);
   SIGNAL ru_ctrl_param           : std_logic_vector(2 DOWNTO 0);
   SIGNAL ru_ctrl_read_param      : std_logic;
   SIGNAL ru_ctrl_read_source     : std_logic_vector(1 DOWNTO 0);
   SIGNAL ru_ctrl_reconfig        : std_logic;
   SIGNAL ru_ctrl_reset           : std_logic;
   SIGNAL ru_ctrl_reset_timer     : std_logic;
   SIGNAL ru_ctrl_write_param     : std_logic;
   
   -- wishbone master to remote update controler (read write boot address register)
   SIGNAL wbm_ru_cyc              : std_logic;
   SIGNAL wbm_ru_ack              : std_logic;
   SIGNAL wbm_ru_we               : std_logic;
   SIGNAL wbm_ru_sel              : std_logic_vector(3 DOWNTO 0);
   SIGNAL wbm_ru_dat_o            : std_logic_vector(31 DOWNTO 0);
   SIGNAL wbm_ru_dat_i            : std_logic_vector(31 DOWNTO 0);
   
   -- register from remote update controller
   SIGNAL reg_reconfig            : std_logic;                       -- reconfiguration trigger from register interface
   SIGNAL reg_reconfig_cond       : std_logic_vector(4 DOWNTO 0);    -- reconfiguration trigger condition of last reconfiguration
   SIGNAL reg_board_status        : std_logic_vector(1 DOWNTO 0);    -- gives information whether the loading process was successful or not
   
BEGIN
   
   rstn_indi      <= NOT rst_indi;
   board_status   <= reg_board_status;
   
-----------------------------------------------------------
-- Indirect interface clock bridge
-----------------------------------------------------------
   z126_01_clk_trans_indirect_i0 : z126_01_clk_trans_wb2wb
   GENERIC MAP (
      NBR_OF_CYC  => 1,
      NBR_OF_TGA  => 6
   )
   PORT MAP (
      rstn           => rstn_indi,
      -- a MHz domain
      clk_a          => clk_indi,
      stb_a          => wbs_stb_indi,        -- request signal from a MHz side
      cyc_a(0)       => wbs_cyc_indi,
      ack_a          => wbs_ack_indi,        -- adopted acknoledge signal to b MHz
      err_a          => wbs_err_indi,
      we_a           => wbs_we_indi,         -- '1' = write, '0' = read
      tga_a          => "000000",
      cti_a          => "000",               -- transfer type
      bte_a          => "00",                -- incremental burst
      adr_a          => wbs_adr_indi,        -- adr from a MHz side
      sel_a          => wbs_sel_indi,        -- byte enables from a MHz side
      dat_i_a        => wbs_dat_i_indi,      -- data from a MHz side
      dat_o_a        => wbs_dat_o_indi,      -- data from b MHz side to a MHz side
      -- b MHz domain
      clk_b          => clk_40mhz,
      stb_b          => fc_stb_indi,         -- request signal adopted to b MHz
      cyc_b(0)       => fc_cyc_indi,
      ack_b          => fc_ack_indi,         -- acknoledge signal from internal bus
      err_b          => '0',
      we_b           => wbmo_1.we,           -- '1' = write, '0' = read
      tga_b          => open,
      cti_b          => open,                -- transfer type
      bte_b          => open,                -- incremental burst
      adr_b          => fc_adr_indi,         -- adr from b MHz side
      sel_b          => wbmo_1.sel,          -- byte enables for b MHz side
      dat_i_b        => fc_dat_o_indi,       -- data from b MHz side
      dat_o_b        => wbmo_1.dat           -- data from a MHz side to b MHz side
   );
   
   wbmo_1.tga  <= "000000"; --tga=0 --> used for address generation
   wbmo_1.cti  <= "000";
   wbmo_1.bte  <= "00";
   
-----------------------------------------------------------
-- Direct interface clock bridge
-----------------------------------------------------------
   z126_01_use_direct_with_clk_bridge: IF USE_DIRECT_INTERFACE GENERATE
      rstn_dir       <= NOT rst_dir;
      z126_01_clk_trans_direct_i0 : z126_01_clk_trans_wb2wb
      PORT MAP (
         rstn           => rstn_dir,
         
         -- a MHz domain
         clk_a          => clk_dir,
         stb_a          => wbs_stb_dir,        -- request signal from a MHz side
         cyc_a(0)       => wbs_cyc_dir,
         ack_a          => wbs_ack_dir,        -- adopted acknoledge signal to b MHz
         err_a          => wbs_err_dir,
         we_a           => wbs_we_dir,         -- '1' = write, '0' = read
         tga_a          => "000000",
         cti_a          => "000",              -- transfer type
         bte_a          => "00",               -- incremental burst
         adr_a          => wbs_adr_dir,        -- adr from a MHz side
         sel_a          => wbs_sel_dir,        -- byte enables from a MHz side
         dat_i_a        => wbs_dat_i_dir,      -- data from a MHz side
         dat_o_a        => wbs_dat_o_dir,      -- data from b MHz side to a MHz side
         
         -- b MHz domain
         clk_b          => clk_40mhz,
         stb_b          => fc_stb_dir,         -- request signal adopted to b MHz
         cyc_b(0)       => fc_cyc_dir,
         ack_b          => fc_ack_dir,         -- acknoledge signal from internal bus
         err_b          => fc_err_dir,
         we_b           => fc_we_dir,          -- '1' = write, '0' = read
         tga_b          => open,
         cti_b          => open,               -- transfer type
         bte_b          => open,               -- incremental burst
         adr_b          => fc_adr_dir,         -- adr from b MHz side
         sel_b          => fc_sel_dir,         -- byte enables for b MHz side
         dat_i_b        => fc_dat_o_dir,       -- data from b MHz side
         dat_o_b        => fc_dat_i_dir        -- data from a MHz side to b MHz side
      );
   END GENERATE z126_01_use_direct_with_clk_bridge;
   
   -- set default values for direct interface when it is not used
   z126_01_not_use_direct: IF NOT USE_DIRECT_INTERFACE GENERATE
      wbs_ack_dir    <= '0';
      wbs_err_dir    <= '0';
      wbs_dat_o_dir  <= (OTHERS => '0');
      
      fc_stb_dir     <= '0';
      fc_cyc_dir     <= '0';
      fc_we_dir      <= '0';
      fc_adr_dir     <= (OTHERS => '0');
      fc_sel_dir     <= (OTHERS => '0');
      fc_dat_i_dir   <= (OTHERS => '0');
   END GENERATE z126_01_not_use_direct;
   
   -- always read operation for the direct interface
   wb_dir_ctrlm_o.read_sid         <= '0';
   wb_dir_ctrlm_o.sector_protect   <= '0';
   wb_dir_ctrlm_o.write            <= '0';
   wb_dir_ctrlm_o.read_status      <= '0';
   wb_dir_ctrlm_o.sector_erase     <= '0';
   wb_dir_ctrlm_o.bulk_erase       <= '0';
   
-----------------------------------------------------------
-- Arbiter between wishbone direct and indirect interface
-----------------------------------------------------------
   -- instantiation of 16z100 (renamed to wb_bus_16z045_01)
   z126_01_wb_if_arbiter_i0: z126_01_wb_if_arbiter
   GENERIC MAP (
      sets           => "0000",
      timeout        => 5000
   )
   PORT MAP (
      clk            => clk_40mhz,     -- wishbone clock
      rst            => rst_clk_40mhz,
      
      wbmo_0.stb     => fc_stb_dir,    -- Master Interface
      wbmo_0.sel     => fc_sel_dir,    -- for direct addressing interface
      wbmo_0.adr     => fc_adr_dir,
      wbmo_0.we      => fc_we_dir,
      wbmo_0.dat     => fc_dat_i_dir,
      wbmo_0.tga     => "000001",
      wbmo_0.cti     => "000",
      wbmo_0.bte     => "00",
      wbmi_0.ack     => fc_ack_dir,
      wbmi_0.err     => fc_err_dir,
      wbmi_0.dat     => fc_dat_o_dir,
      wbmo_0_cyc     => fc_cyc_dir,
      ctrlmo_0       => wb_dir_ctrlm_o,
      ctrlmi_0       => OPEN,
      
      wbmo_1         => wbmo_1,        -- Master Interface
      wbmi_1         => wbmi_1,        -- for indirect addressing Interface
      wbmo_1_cyc     => wbmo_1_cyc,
      ctrlmo_1       => wb_indi_ctrlm_o,
      ctrlmi_1       => wb_indi_ctrlm_i,
      
      wbso_0         => wbso_0,        -- Slave Interface
      wbsi_0         => wbsi_0,        -- for wb2pasmi Interface
      wbsi_0_cyc     => wbsi_0_cyc,
      ctrlso_0       => wb_ctrls_o,
      ctrlsi_0       => wb_ctrls_i
   );
   
----------------------------------------------------
-- Indirect interface registers
----------------------------------------------------
   -- instantiation of FSM which handles indirect access
   z126_01_indi_if_ctrl_regs_i0 : z126_01_indi_if_ctrl_regs
   PORT MAP (
      clk                  => clk_40mhz,           -- Wishbone clock (66 MHz)
      rst                  => rst_clk_40mhz,       -- Reset
      
      -- wishbone signals master interface (ru_ctrol interace)
      wbm_ru_cyc           => wbm_ru_cyc,
      wbm_ru_ack           => wbm_ru_ack,
      wbm_ru_we            => wbm_ru_we,
      wbm_ru_sel           => wbm_ru_sel,
      wbm_ru_dat_o         => wbm_ru_dat_o,
      wbm_ru_dat_i         => wbm_ru_dat_i,
      
      reg_reconfig         => reg_reconfig,        -- reconfiguration trigger from register interface
      reg_reconfig_cond    => reg_reconfig_cond,   -- reconfiguration trigger condition of last reconfiguration
      reg_board_status     => reg_board_status,    -- gives information whether the loading process was successful or not
      
      -- wishbone signals master interface
      wbm_stb              => wbmo_1.stb,          -- strobe
      wbm_adr              => wbmo_1.adr,          -- addrees
      wbm_ack              => wbmi_1.ack,          -- acknowledge
      wbm_dat_i            => wbmi_1.dat,          -- data in
      wbm_cyc              => wbmo_1_cyc,
      
      -- wishbone signals slave interface
      wbs_stb              => fc_stb_indi,         -- strobe
      wbs_ack              => fc_ack_indi,         -- acknowledge
      wbs_we               => wbmo_1.we,           -- write=1 read=0
      wbs_sel              => wbmo_1.sel,          -- byte enables
      wbs_cyc              => fc_cyc_indi,         -- chip select
      wbs_dat_o            => fc_dat_o_indi,       -- data out
      wbs_dat_i            => wbmo_1.dat,          -- data in
      wbs_adr              => fc_adr_indi,         -- address
      
      -- control signals for wb2pasmi
      ctrl_read_sid        => wb_indi_ctrlm_o.read_sid,
      ctrl_sector_protect  => wb_indi_ctrlm_o.sector_protect,
      ctrl_write           => wb_indi_ctrlm_o.write,
      ctrl_read_status     => wb_indi_ctrlm_o.read_status,
      ctrl_sector_erase    => wb_indi_ctrlm_o.sector_erase,
      ctrl_bulk_erase      => wb_indi_ctrlm_o.bulk_erase,
      ctrl_illegal_write   => wb_indi_ctrlm_i.illegal_write,
      ctrl_illegal_erase   => wb_indi_ctrlm_i.illegal_erase,
      ctrl_busy            => wb_indi_ctrlm_i.busy
   );
   
----------------------------------------------------
-- Wishbone to pasmi
----------------------------------------------------
   z126_01_wb2pasmi_i0: ENTITY work.z126_01_wb2pasmi
   GENERIC MAP (
      FLASH_TYPE            => FLASH_TYPE
   )
   PORT MAP (
      clk                  => clk_40mhz,           -- flash clk 40 Mhz
      rst                  => rst_clk_40mhz,       -- global async high active reset
      
      -- pasmi interface
      pasmi_addr           => wb_pasmi_m_o.addr,
      pasmi_bulk_erase     => wb_pasmi_m_o.bulk_erase,
      pasmi_busy           => wb_pasmi_m_i.busy,
      pasmi_data_valid     => wb_pasmi_m_i.data_valid,
      pasmi_datain         => wb_pasmi_m_i.data,
      pasmi_dataout        => wb_pasmi_m_o.data,
      pasmi_epcs_id        => wb_pasmi_m_i.epcs_id,
      pasmi_rdid           => wb_pasmi_m_i.rdid,
      pasmi_fast_read      => wb_pasmi_m_o.fast_read,
      pasmi_illegal_erase  => wb_pasmi_m_i.illegal_erase,
      pasmi_illegal_write  => wb_pasmi_m_i.illegal_write,
      pasmi_rden           => wb_pasmi_m_o.rden,
      pasmi_read_sid       => wb_pasmi_m_o.read_sid,
      pasmi_read_rdid      => wb_pasmi_m_o.read_rdid,
      pasmi_read_status    => wb_pasmi_m_o.read_status,
      pasmi_sector_erase   => wb_pasmi_m_o.sector_erase,
      pasmi_sector_protect => wb_pasmi_m_o.sector_protect,
      pasmi_shift_bytes    => wb_pasmi_m_o.shift_bytes,
      pasmi_status_out     => wb_pasmi_m_i.status,
      pasmi_wren           => wb_pasmi_m_o.wren,
      pasmi_write          => wb_pasmi_m_o.write,
      
      -- wishbone signals slave interface 0 (direct addressing)
      wbs_stb              => wbsi_0.stb,        -- request
      wbs_ack              => wbso_0.ack,        -- acknoledge
      wbs_we               => wbsi_0.we,         -- write=1 read=0
      wbs_sel              => wbsi_0.sel,        -- byte enables
      wbs_cyc              => wbsi_0_cyc,        -- chip select
      wbs_dat_o            => wbso_0.dat,        -- data out
      wbs_dat_i            => wbsi_0.dat,        -- data in
      wbs_adr              => wbsi_0.adr,        -- address
      wbs_tga              => wbsi_0.tga,        -- address extension dir=0/indir=1, used for address generation
      wbs_err              => wbso_0.err,        -- error
      
      -- control interface
      ctrl_read_sid        => wb_ctrls_i.read_sid,
      ctrl_sector_protect  => wb_ctrls_i.sector_protect,
      ctrl_write           => wb_ctrls_i.write,
      ctrl_read_status     => wb_ctrls_i.read_status,
      ctrl_sector_erase    => wb_ctrls_i.sector_erase,
      ctrl_bulk_erase      => wb_ctrls_i.bulk_erase,
      ctrl_busy            => wb_ctrls_o.busy
   );
   
   -- unsued pasmi master signals
   wb_pasmi_m_o.read      <= '0';
   
----------------------------------------------------
-- ALTASMI_PARALLEL
----------------------------------------------------
   -- pasmi instance for 32MBit serial flash
   z126_01_pasmi_m25p32_gen: IF (FLASH_TYPE = M25P32 AND SIMULATION = FALSE) GENERATE
      z126_01_pasmi_m25p32_i0 : z126_01_pasmi_m25p32
      PORT MAP (
         clkin          => clk_40mhz,
         reset          => rst_clk_40mhz,
         
         addr           => wb_pasmi_m_o.addr,
         bulk_erase     => wb_pasmi_m_o.bulk_erase,
         busy           => wb_pasmi_m_i.busy,
         data_valid     => wb_pasmi_m_i.data_valid,
         datain         => wb_pasmi_m_o.data,
         dataout        => wb_pasmi_m_i.data,
         rdid_out       => wb_pasmi_m_i.rdid,
         fast_read      => wb_pasmi_m_o.fast_read,
         illegal_erase  => wb_pasmi_m_i.illegal_erase,
         illegal_write  => wb_pasmi_m_i.illegal_write,
         rden           => wb_pasmi_m_o.rden,
         read_rdid      => wb_pasmi_m_o.read_rdid,
         read_status    => wb_pasmi_m_o.read_status,
         sector_erase   => wb_pasmi_m_o.sector_erase,
         sector_protect => wb_pasmi_m_o.sector_protect,
         shift_bytes    => wb_pasmi_m_o.shift_bytes,
         status_out     => wb_pasmi_m_i.status,
         wren           => wb_pasmi_m_o.wren,
         write          => wb_pasmi_m_o.write
      );
   END GENERATE;
   
   -- simulation altasmi parallel for 32MBit serial flash
   z126_01_pasmi_m25p32_sim_gen: IF (FLASH_TYPE = M25P32 AND SIMULATION = TRUE) GENERATE
      z126_01_pasmi_m25p32_sim_i0 : z126_01_pasmi_sim_m25p32
      PORT MAP (
         clkin          => clk_40mhz,
         -- reset       => rst_clk_40mhz, -- simulation device has no reset
         
         addr           => wb_pasmi_m_o.addr,
         bulk_erase     => wb_pasmi_m_o.bulk_erase,
         busy           => wb_pasmi_m_i.busy,
         data_valid     => wb_pasmi_m_i.data_valid,
         datain         => wb_pasmi_m_o.data,
         dataout        => wb_pasmi_m_i.data,
         rdid_out       => wb_pasmi_m_i.rdid,
         fast_read      => wb_pasmi_m_o.fast_read,
         illegal_erase  => wb_pasmi_m_i.illegal_erase,
         illegal_write  => wb_pasmi_m_i.illegal_write,
         rden           => wb_pasmi_m_o.rden,
         read_rdid      => wb_pasmi_m_o.read_rdid,
         read_status    => wb_pasmi_m_o.read_status,
         sector_erase   => wb_pasmi_m_o.sector_erase,
         sector_protect => wb_pasmi_m_o.sector_protect,
         shift_bytes    => wb_pasmi_m_o.shift_bytes,
         status_out     => wb_pasmi_m_i.status,
         wren           => wb_pasmi_m_o.wren,
         write          => wb_pasmi_m_o.write
      );
   END GENERATE;
   
   -- pasmi instance for 64MBit serial flash
   z126_01_pasmi_m25p64_gen : IF FLASH_TYPE = M25P64 GENERATE
      z126_01_the_pasmi_m25p64_i0 : z126_01_pasmi_m25p64
      PORT MAP (
         clkin          => clk_40mhz,
         reset          => rst_clk_40mhz,
         
         addr           => wb_pasmi_m_o.addr,
         bulk_erase     => wb_pasmi_m_o.bulk_erase,
         busy           => wb_pasmi_m_i.busy,
         data_valid     => wb_pasmi_m_i.data_valid,
         datain         => wb_pasmi_m_o.data,
         dataout        => wb_pasmi_m_i.data,
         rdid_out       => wb_pasmi_m_i.rdid,
         fast_read      => wb_pasmi_m_o.fast_read,
         illegal_erase  => wb_pasmi_m_i.illegal_erase,
         illegal_write  => wb_pasmi_m_i.illegal_write,
         rden           => wb_pasmi_m_o.rden,
         read_rdid      => wb_pasmi_m_o.read_rdid,
         read_status    => wb_pasmi_m_o.read_status,
         sector_erase   => wb_pasmi_m_o.sector_erase,
         sector_protect => wb_pasmi_m_o.sector_protect,
         shift_bytes    => wb_pasmi_m_o.shift_bytes,
         status_out     => wb_pasmi_m_i.status,
         wren           => wb_pasmi_m_o.wren,
         write          => wb_pasmi_m_o.write
      );
   END GENERATE;
   
   -- pasmi instance for 128MBit serial flash
   z126_01_pasmi_m25p128_gen : IF FLASH_TYPE = M25P128 GENERATE
      z126_01_the_pasmi_m25p128_i0 : z126_01_pasmi_m25p128
      PORT MAP (
         clkin          => clk_40mhz,
         reset          => rst_clk_40mhz,
         
         addr           => wb_pasmi_m_o.addr,
         bulk_erase     => wb_pasmi_m_o.bulk_erase,
         busy           => wb_pasmi_m_i.busy,
         data_valid     => wb_pasmi_m_i.data_valid,
         datain         => wb_pasmi_m_o.data,
         dataout        => wb_pasmi_m_i.data,
         rdid_out       => wb_pasmi_m_i.rdid,
         fast_read      => wb_pasmi_m_o.fast_read,
         illegal_erase  => wb_pasmi_m_i.illegal_erase,
         illegal_write  => wb_pasmi_m_i.illegal_write,
         rden           => wb_pasmi_m_o.rden,
         read_rdid      => wb_pasmi_m_o.read_rdid,
         read_status    => wb_pasmi_m_o.read_status,
         sector_erase   => wb_pasmi_m_o.sector_erase,
         sector_protect => wb_pasmi_m_o.sector_protect,
         shift_bytes    => wb_pasmi_m_o.shift_bytes,
         status_out     => wb_pasmi_m_i.status,
         wren           => wb_pasmi_m_o.wren,
         write          => wb_pasmi_m_o.write
      );
      
   END GENERATE;
   
   wb_pasmi_m_i.epcs_id       <= (OTHERS=>'0');
   wb_ctrls_o.illegal_erase   <= wb_pasmi_m_i.illegal_erase;
   wb_ctrls_o.illegal_write   <= wb_pasmi_m_i.illegal_write;
   
----------------------------------------------------
-- ALTREMOTE_UPDATE
----------------------------------------------------
   z126_01_ru_gen: IF USE_REMOTE_UPDATE = TRUE GENERATE
      -- remote update controller altera module for cyclone 3 device
      z126_01_ru_cycloneiii_gen: IF FPGA_FAMILY = CYCLONE3 GENERATE
         z126_01_ru_cycloneiii_i0 : z126_01_ru_cycloneiii
         PORT MAP (
            clock             => clk_40mhz,
            reset             => ru_ctrl_reset,
            
            param             => ru_ctrl_param,
            read_param        => ru_ctrl_read_param,
            read_source       => ru_ctrl_read_source,
            reconfig          => ru_ctrl_reconfig,
            reset_timer       => ru_ctrl_reset_timer,
            write_param       => ru_ctrl_write_param,
            data_in           => ru_ctrl_data_in,
            data_out          => ru_ctrl_data_out,
            busy              => ru_ctrl_busy
         );
      END GENERATE;
      
      -- remote update controller altera module for cyclone 4 device
      z126_01_ru_cycloneiv_gen: IF FPGA_FAMILY = CYCLONE4 GENERATE
         z126_01_ru_cycloneiv_i0 : z126_01_ru_cycloneiv
         PORT MAP (
            clock             => clk_40mhz,
            reset             => ru_ctrl_reset,
            
            param             => ru_ctrl_param,
            read_param        => ru_ctrl_read_param,
            read_source       => ru_ctrl_read_source,
            reconfig          => ru_ctrl_reconfig,
            reset_timer       => ru_ctrl_reset_timer,
            write_param       => ru_ctrl_write_param,
            data_in           => ru_ctrl_data_in,
            data_out          => ru_ctrl_data_out,
            busy              => ru_ctrl_busy
         );
      END GENERATE;
      
      -- remote update controller altera module for cyclone 5 device
      ASSERT NOT (FPGA_FAMILY = CYCLONE5) REPORT "Z126: for Cyclone V support, please first generate Altera Remote Update IP-core for your Flash" SEVERITY failure;
      --z126_01_ru_cyclonev_gen: IF FPGA_FAMILY = CYCLONE5 GENERATE
      --   z126_01_ru_cyclonev_m25p128_gen: IF FLASH_TYPE = M25P128 GENERATE
      --      
      --      z126_01_ru_cyclonev_i0 : z126_01_ru_cyclonev_m25p128
      --      PORT MAP (
      --         clock             => clk_40mhz,
      --         reset             => ru_ctrl_reset,
      --         
      --         param             => ru_ctrl_param,
      --         read_param        => ru_ctrl_read_param,
      --         reconfig          => ru_ctrl_reconfig,
      --         reset_timer       => ru_ctrl_reset_timer,
      --         write_param       => ru_ctrl_write_param,
      --         data_in           => ru_ctrl_data_in,
      --         data_out          => ru_ctrl_data_out(23 DOWNTO 0),
      --         busy              => ru_ctrl_busy
      --      );
      --   END GENERATE;
      --   
      --   z126_01_ru_cyclonev_m25p64_gen: IF FLASH_TYPE = M25P64 GENERATE
      --      z126_01_ru_cyclonev_i0 : z126_01_ru_cyclonev_m25p64
      --      PORT MAP (
      --         clock             => clk_40mhz,
      --         reset             => ru_ctrl_reset,
      --         
      --         param             => ru_ctrl_param,
      --         read_param        => ru_ctrl_read_param,
      --         reconfig          => ru_ctrl_reconfig,
      --         reset_timer       => ru_ctrl_reset_timer,
      --         write_param       => ru_ctrl_write_param,
      --         data_in           => ru_ctrl_data_in,
      --         data_out          => ru_ctrl_data_out(23 DOWNTO 0),
      --         busy              => ru_ctrl_busy
      --      );
      --   END GENERATE;
      --   
      --   z126_01_ru_cyclonev_m25p32_gen: IF FLASH_TYPE = M25P32 GENERATE
      --      z126_01_ru_cyclonev_i0 : z126_01_ru_cyclonev_m25p32
      --      PORT MAP (
      --         clock             => clk_40mhz,
      --         reset             => ru_ctrl_reset,
      --         
      --         param             => ru_ctrl_param,
      --         read_param        => ru_ctrl_read_param,
      --         reconfig          => ru_ctrl_reconfig,
      --         reset_timer       => ru_ctrl_reset_timer,
      --         write_param       => ru_ctrl_write_param,
      --         data_in           => ru_ctrl_data_in,
      --         data_out          => ru_ctrl_data_out(23 DOWNTO 0),
      --         busy              => ru_ctrl_busy
      --      );
      --   END GENERATE;
      --END GENERATE;
      
      -- remote update controller
      z126_01_ru_gen: IF FPGA_FAMILY /= CYCLONE5 GENERATE
         z126_01_ru_ctrl_i0 : z126_01_ru_ctrl
         GENERIC MAP (
            FPGA_FAMILY          => FPGA_FAMILY,         -- see SUPPORTED_FPGA_FAMILIES for supported FPGA family types
            LOAD_FPGA_IMAGE      => LOAD_FPGA_IMAGE,     -- true  => after configuration of the FPGA Fallback Image the FPGA Image is loaded immediately (can only be set when USE_REMOTE_UPDATE = TRUE)
                                                         -- false => after configuration the FPGA stays in the FPGA Fallback Image, FPGA Image must be loaded by software
            LOAD_FPGA_IMAGE_ADR  => LOAD_FPGA_IMAGE_ADR  -- if LOAD_FPGA_IMAGE = TRUE this address is the offset to the FPGA Image in the serial flash
         )
         PORT MAP (
            clk                     => clk_40mhz,     -- system clock
            rst                     => rst_clk_40mhz, -- unit reset
            
            -- register interface
            wbs_reg_cyc             => wbm_ru_cyc,
            wbs_reg_ack             => wbm_ru_ack,
            wbs_reg_we              => wbm_ru_we,
            wbs_reg_sel             => wbm_ru_sel,
            wbs_reg_dat_o           => wbm_ru_dat_i,
            wbs_reg_dat_i           => wbm_ru_dat_o,
            
            reg_reconfig            => reg_reconfig,        -- reconfiguration trigger from register interface
            reg_reconfig_cond       => reg_reconfig_cond,   -- reconfiguration trigger condition of last reconfiguration
            reg_board_status        => reg_board_status,    -- gives information whether the loading process was successful or not
            
            -- ALTREMOTE_UPDATE interface
            ru_ctrl_busy            => ru_ctrl_busy,
            ru_ctrl_data_out        => ru_ctrl_data_out,       -- data from altera remote update module
            ru_ctrl_data_in         => ru_ctrl_data_in,        -- data to altera remote update module
            ru_ctrl_param           => ru_ctrl_param,
            ru_ctrl_read_param      => ru_ctrl_read_param,
            ru_ctrl_read_source     => ru_ctrl_read_source,
            ru_ctrl_reconfig        => ru_ctrl_reconfig,
            ru_ctrl_reset_timer     => ru_ctrl_reset_timer,
            ru_ctrl_reset           => ru_ctrl_reset,
            ru_ctrl_write_param     => ru_ctrl_write_param
         );
      END GENERATE z126_01_ru_gen;
      
      z126_01_ru_ctrl_cyclonev_gen: IF FPGA_FAMILY = CYCLONE5 GENERATE
         z126_01_ru_ctrl_cyc5_i0 : z126_01_ru_ctrl_cyc5
         GENERIC MAP (
            FPGA_FAMILY          => FPGA_FAMILY,         -- see SUPPORTED_FPGA_FAMILIES for supported FPGA family types
            LOAD_FPGA_IMAGE      => LOAD_FPGA_IMAGE,     -- true  => after configuration of the FPGA Fallback Image the FPGA Image is loaded immediately (can only be set when USE_REMOTE_UPDATE = TRUE)
                                                         -- false => after configuration the FPGA stays in the FPGA Fallback Image, FPGA Image must be loaded by software
            LOAD_FPGA_IMAGE_ADR  => LOAD_FPGA_IMAGE_ADR  -- if LOAD_FPGA_IMAGE = TRUE this address is the offset to the FPGA Image in the serial flash
         )
         PORT MAP (
            clk                     => clk_40mhz,     -- system clock
            rst                     => rst_clk_40mhz, -- unit reset
            
            -- register interface
            wbs_reg_cyc             => wbm_ru_cyc,
            wbs_reg_ack             => wbm_ru_ack,
            wbs_reg_we              => wbm_ru_we,
            wbs_reg_sel             => wbm_ru_sel,
            wbs_reg_dat_o           => wbm_ru_dat_i,
            wbs_reg_dat_i           => wbm_ru_dat_o,
            
            reg_reconfig            => reg_reconfig,        -- reconfiguration trigger from register interface
            reg_reconfig_cond       => reg_reconfig_cond,   -- reconfiguration trigger condition of last reconfiguration
            reg_board_status        => reg_board_status,    -- gives information whether the loading process was successful or not
            
            -- ALTREMOTE_UPDATE interface
            ru_ctrl_busy            => ru_ctrl_busy,
            ru_ctrl_data_out        => ru_ctrl_data_out(23 DOWNTO 0),   -- data from altera remote update module
            ru_ctrl_data_in         => ru_ctrl_data_in,                 -- data to altera remote update module
            ru_ctrl_param           => ru_ctrl_param,
            ru_ctrl_read_param      => ru_ctrl_read_param,
            ru_ctrl_reconfig        => ru_ctrl_reconfig,
            ru_ctrl_reset_timer     => ru_ctrl_reset_timer,
            ru_ctrl_reset           => ru_ctrl_reset,
            ru_ctrl_write_param     => ru_ctrl_write_param
         );
         
         ru_ctrl_data_out(28 DOWNTO 24) <= (OTHERS=>'0');
         
      END GENERATE z126_01_ru_ctrl_cyclonev_gen;
      
   END GENERATE z126_01_ru_gen;
   
   z126_01_without_ru_gen: IF USE_REMOTE_UPDATE = FALSE GENERATE
      -- default values for unused signals when remote update controller is not included
      wbm_ru_ack        <= '1';
      wbm_ru_dat_i      <= (OTHERS=>'0');
      reg_reconfig_cond <= (OTHERS=>'0');
      reg_board_status  <= (OTHERS=>'0');
   END GENERATE;
   
   -- if a not supported device is selected, a FAILURE will be generated
   ASSERT NOT no_valid_device(supported_devices => SUPPORTED_DEVICES, device => FLASH_TYPE) REPORT "Z126: No valid Flash!" SEVERITY failure;
   
   -- if a not supported FPGA family is selected, a FAILURE will be generated
   ASSERT NOT no_valid_device(supported_devices => SUPPORTED_FPGA_FAMILIES, device => FPGA_FAMILY) REPORT "Z126: No valid FPGA family!" SEVERITY failure;
   
   --coverage on
   
END z126_01_top_arch;
