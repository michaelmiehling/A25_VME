--------------------------------------------------------------------------------
-- Title         : Toplevel File of A25 FPGA
-- Project       : 1614_CERN_A25
--------------------------------------------------------------------------------
-- File          : A25_top.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 2016-06-03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
--------------------------------------------------------------------------------
-- Hierarchy:
--
-- A25_top
--    wbb2vme_top
--    sram
--    ip_16z091_01_top
--    iram_wb
--    pll_pcie
--    z126_01_top
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
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.wb_pkg.ALL;
USE work.fpga_pkg_2.ALL;
USE work.z126_01_pkg.ALL;
USE work.vme_pkg.ALL;

ENTITY A25_top IS
GENERIC (
   SIMULATION        : boolean                        := FALSE;
   FPGA_FAMILY       : family_type := CYCLONE4;
   sets              : std_logic_vector(3 DOWNTO 0) := "1110";
   timeout           : integer := 5000 );
PORT (
   clk_16mhz         : IN std_logic;
   led_green_n       : OUT std_logic;
   led_red_n         : OUT std_logic;                                                   
   hreset_n          : IN std_logic;                        -- reset
   v2p_rstn          : OUT std_logic;                       -- connected to hreset_req1_n
   fpga_test         : INOUT std_logic_vector(5 DOWNTO 1);

   -- pcie
   refclk            : IN std_logic;                        -- 100 MHz pcie clock
   pcie_rx           : IN    std_logic_vector(3 DOWNTO 0);                     -- PCIe receive line
   pcie_tx           : OUT   std_logic_vector(3 DOWNTO 0);                     -- PCIe transmit line

   -- sram
   sr_clk            : OUT std_logic;
   sr_a              : OUT std_logic_vector(18 DOWNTO 0);
   sr_d              : INOUT std_logic_vector(15 DOWNTO 0);
   sr_bwa_n          : OUT std_logic;
   sr_bwb_n          : OUT std_logic;
   sr_bw_n           : OUT std_logic;
   sr_cs1_n          : OUT std_logic;
   sr_adsc_n         : OUT std_logic;
   sr_oe_n           : OUT std_logic;
   
   -- vmebus
   vme_ga            : IN std_logic_vector(4 DOWNTO 0);     -- geographical addresses
   vme_gap           : IN std_logic;     -- geographical addresses
   vme_a             : INOUT std_logic_vector(31 DOWNTO 0);
   vme_a_dir         : OUT std_logic;
   vme_a_oe_n        : OUT std_logic; 
   vme_d             : INOUT std_logic_vector(31 DOWNTO 0);
   vme_d_dir         : OUT std_logic;
   vme_d_oe_n        : OUT std_logic;
   vme_am_dir        : OUT std_logic;
   vme_am            : INOUT std_logic_vector(5 DOWNTO 0);
   vme_am_oe_n       : OUT std_logic;
   vme_write_n       : INOUT std_logic;
   vme_iack_n        : INOUT std_logic;
   vme_irq_i_n       : IN std_logic_vector(7 DOWNTO 1);
   vme_irq_o         : OUT std_logic_vector(7 DOWNTO 1); -- high active on A25
   vme_as_i_n        : IN std_logic;
   vme_as_o_n        : OUT std_logic;
   vme_as_oe         : OUT std_logic;                    -- high active on A25
   vme_retry_o_n     : OUT std_logic;
   vme_retry_oe      : OUT std_logic;                    -- high active on A25
   vme_retry_i_n     : IN std_logic;
   vme_sysres_i_n    : IN std_logic;
   vme_sysres_o      : OUT std_logic;                    -- high active on A25
   vme_ds_i_n        : IN std_logic_vector(1 DOWNTO 0);
   vme_ds_o_n        : OUT std_logic_vector(1 DOWNTO 0);
   vme_ds_oe         : OUT std_logic;                    -- high active on A25
   vme_berr_i_n      : IN std_logic;
   vme_berr_o        : OUT std_logic;                    -- high active on A25
   vme_dtack_i_n     : IN std_logic;
   vme_dtack_o       : OUT std_logic;                    -- high active on A25
   vme_scon          : OUT std_logic;                    -- high active on A25
   vme_sysfail_i_n   : IN std_logic;
   vme_sysfail_o     : OUT std_logic;                    -- high active on A25
   vme_bbsy_i_n      : IN std_logic;
   vme_bbsy_o        : OUT std_logic;                    -- high active on A25
   vme_bclr_i_n      : IN std_logic;                           -- bus clear input
   vme_bclr_o_n      : OUT std_logic;                          -- bus clear output
   vme_br_i_n        : IN std_logic_vector(3 DOWNTO 0);
   vme_br_o          : OUT std_logic_vector(3 DOWNTO 0); -- high active on A25
   vme_iack_i_n      : IN std_logic;
   vme_iack_o_n      : OUT std_logic;
   vme_acfail_i_n    : IN std_logic;
   vme_sysclk        : OUT std_logic;
   vme_bg_i_n        : IN std_logic_vector(3 DOWNTO 0);
   vme_bg_o_n        : OUT std_logic_vector(3 DOWNTO 0)
   );
END A25_top;


ARCHITECTURE A25_top_arch OF A25_top IS 
   CONSTANT NR_OF_WB_SLAVES      : natural range 63 DOWNTO 1     := 10;
   
COMPONENT ip_16z091_01_top 
   GENERIC(
      SIMULATION           : std_logic                     := '0';              -- =1 simulation,=0 synthesis 
      FPGA_FAMILY          : family_type                   := NONE;
      IRQ_WIDTH            : integer range 32 downto 1     := 1;

      -- only use one of the following 3:
      -- 001 := 1 lane, 010 := 2 lanes, 100 := 4 lanes
      USE_LANES            : std_logic_vector(2 downto 0)  := "001";            
      
      NR_OF_WB_SLAVES      : natural range 63 DOWNTO 1     := 12;
      NR_OF_BARS_USED      : natural range 6 downto 1      := 5;
      
      VENDOR_ID            : natural                       := 16#1A88#;
      DEVICE_ID            : natural                       := 16#4D45#;
      REVISION_ID          : natural                       := 16#0#;
      CLASS_CODE           : natural                       := 16#068000#;
      SUBSYSTEM_VENDOR_ID  : natural                       := 16#9B#;
      SUBSYSTEM_DEVICE_ID  : natural                       := 16#5A91#;

      BAR_MASK_0           : std_logic_vector(31 downto 0) := x"FF000008";
      BAR_MASK_1           : std_logic_vector(31 downto 0) := x"FF000008";
      BAR_MASK_2           : std_logic_vector(31 downto 0) := x"FF000000";
      BAR_MASK_3           : std_logic_vector(31 downto 0) := x"FF000000";
      BAR_MASK_4           : std_logic_vector(31 downto 0) := x"FF000001";
      BAR_MASK_5           : std_logic_vector(31 downto 0) := x"FF000001";
      
      PCIE_REQUEST_LENGTH  : std_logic_vector(9 downto 0)  := "0000100000";    -- 32DW = 128Byte
      RX_LPM_WIDTHU        : integer range 10 DOWNTO 5     := 10;
      TX_HEADER_LPM_WIDTHU : integer range 10 DOWNTO 5     := 5;
      TX_DATA_LPM_WIDTHU   : integer range 10 DOWNTO 5     := 10
   );
   PORT(
   -- Hard IP ports:
      clk_50             : in  std_logic;                                        --  50 MHz clock for reconfig_clk and cal_blk_clk
      clk_125            : in  std_logic;                                        -- 125 MHz clock for fixed_clk
      ref_clk            : in  std_logic;                                        -- 100 MHz reference clock
      clk_500            : in  std_logic;                                        -- 500 Hz clock
      ext_rst_n          : in  std_logic;
      
      rx_0               : in  std_logic;
      rx_1               : in  std_logic;
      rx_2               : in  std_logic;
      rx_3               : in  std_logic;
      
      tx_0               : out std_logic;
      tx_1               : out std_logic;
      tx_2               : out std_logic;
      tx_3               : out std_logic;
      
   -- Wishbone ports:
      wb_clk             : in  std_logic;
      wb_rst             : in  std_logic;
      -- Wishbone master
      wbm_ack            : in  std_logic;
      wbm_dat_i          : in  std_logic_vector(31 downto 0);
      wbm_stb            : out std_logic;
      wbm_cyc_o          : out std_logic_vector(NR_OF_WB_SLAVES - 1 downto 0);
      wbm_we             : out std_logic;
      wbm_sel            : out std_logic_vector(3 downto 0);
      wbm_adr            : out std_logic_vector(31 downto 0);
      wbm_dat_o          : out std_logic_vector(31 downto 0);
      wbm_cti            : out std_logic_vector(2 downto 0);
      wbm_tga            : out std_logic;
      
      -- Wishbone slave
      wbs_cyc            : in  std_logic;
      wbs_stb            : in  std_logic;
      wbs_we             : in  std_logic;
      wbs_sel            : in  std_logic_vector(3 downto 0);
      wbs_adr            : in  std_logic_vector(31 downto 0);
      wbs_dat_i          : in  std_logic_vector(31 downto 0);
      wbs_cti            : in  std_logic_vector(2 downto 0);
      wbs_tga            : in  std_logic;                                    -- 0: memory, 1: I/O
      wbs_ack            : out std_logic;
      wbs_err            : out std_logic;
      wbs_dat_o          : out std_logic_vector(31 downto 0);
      
      -- interrupt
      irq_req_i          : in  std_logic_vector(IRQ_WIDTH -1 downto 0);
      
      -- error
      error_timeout      : out std_logic;
      error_cor_ext_rcv  : out std_logic_vector(1 downto 0);
      error_cor_ext_rpl  : out std_logic;
      error_rpl          : out std_logic;
      error_r2c0         : out std_logic;
      error_msi_num      : out std_logic;
      
      -- debug port
      link_train_active  : out std_logic
   );
END COMPONENT;


COMPONENT wb_bus 
   GENERIC (
      sets      : std_logic_vector(3 DOWNTO 0) := "1110";
      timeout   : integer := 5000 );
   PORT (
      clk           : IN std_logic;
      rst           : IN std_logic;
       -- Master Bus
      wbmo_0        : IN wbo_type;
      wbmi_0        : OUT wbi_type;
      wbmo_0_cyc    : IN std_logic_vector(3 DOWNTO 0);
      wbmo_1        : IN wbo_type;
      wbmi_1        : OUT wbi_type;
      wbmo_1_cyc    : IN std_logic_vector(1 DOWNTO 0);
      wbmo_2        : IN wbo_type;
      wbmi_2        : OUT wbi_type;
      wbmo_2_cyc    : IN std_logic_vector(2 DOWNTO 0);
      -- Slave Bus
      wbso_0        : IN wbi_type;
      wbsi_0        : OUT wbo_type;
      wbsi_0_cyc    : OUT std_logic;
      wbso_1        : IN wbi_type;
      wbsi_1        : OUT wbo_type;
      wbsi_1_cyc    : OUT std_logic;
      wbso_2        : IN wbi_type;
      wbsi_2        : OUT wbo_type;
      wbsi_2_cyc    : OUT std_logic;
      wbso_3        : IN wbi_type;
      wbsi_3        : OUT wbo_type;
      wbsi_3_cyc    : OUT std_logic;
      wbso_4        : IN wbi_type;
      wbsi_4        : OUT wbo_type;
      wbsi_4_cyc    : OUT std_logic
);
END COMPONENT;

COMPONENT pll_pcie
   PORT
   (
      areset      : IN STD_LOGIC  := '0';
      inclk0      : IN STD_LOGIC  := '0';
      c0      : OUT STD_LOGIC ;
      c1      : OUT STD_LOGIC ;
      c2      : OUT STD_LOGIC ;
      c3      : OUT STD_LOGIC ;
      c4      : OUT STD_LOGIC ;
      locked      : OUT STD_LOGIC 
   );
END COMPONENT;

COMPONENT iram_wb
GENERIC
(
   FPGA_FAMILY: family_type := CYCLONE; -- ACEX,CYCLONE,CYCLONE2,CYCLONE3,ARRIA_GX
   read_only: natural := 0; -- 0=R/W, 1=R/O
   USEDW_WIDTH: positive := 6; -- 2**(USEDW_WIDTH + 2) bytes
   LOCATION: string := "iram.hex" -- string shall be empty if no HEX file
);

PORT
(
   clk   : IN std_logic; -- Wishbone clock
   rst   : IN std_logic; -- global async high active reset

   -- Wishbone signals
   stb_i : IN std_logic;                       -- request
   cyc_i : IN std_logic;                       -- chip select
   ack_o : OUT std_logic;                      -- acknowledge
   err_o : OUT std_logic;                      -- error
   we_i  : IN std_logic;                       -- write=1 read=0
   sel_i : IN std_logic_vector(3 DOWNTO 0);    -- byte enables
   adr_i : IN std_logic_vector((USEDW_WIDTH + 1) DOWNTO 2);
   dat_i : IN std_logic_vector(31 DOWNTO 0);   -- data in
   dat_o : OUT std_logic_vector(31 DOWNTO 0)   -- data out
);
END COMPONENT;

COMPONENT sram
   PORT (
      clk66          : IN std_logic;                        -- 66 MHz
      rst            : IN std_logic;                        -- global reset signal (asynch)
      -- local bus
      stb_i          : IN std_logic;
      ack_o          : OUT std_logic;
      we_i           : IN std_logic;                        -- high active write enable
      sel_i          : IN std_logic_vector(3 DOWNTO 0);     -- high active byte enables
      cyc_i          : IN std_logic;
      dat_o          : OUT std_logic_vector(31 DOWNTO 0);
      dat_i          : IN std_logic_vector(31 DOWNTO 0);
      adr_i          : IN std_logic_vector(19 DOWNTO 0);
      
      -- pins to sram
      bwn            : OUT   std_logic;                     -- global byte write enable: 
      bwan           : OUT   std_logic;                     -- byte a write enable:     
      bwbn           : OUT   std_logic;                     -- byte b write enable:     
      adscn          : OUT   std_logic;                     -- Synchronous Address Status Controller:   .
      roen           : OUT   std_logic;                     -- data port output enable:  .
      ra             : OUT   std_logic_vector(18 DOWNTO 0); -- address lines:       
      rd_in          : IN std_logic_vector(15 DOWNTO 0);  -- data lines:      
      rd_out         : OUT std_logic_vector(15 DOWNTO 0);  -- data lines:      
      rd_oe          : OUT std_logic    
      );
END COMPONENT;


COMPONENT z126_01_top 
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
END COMPONENT;
                           
COMPONENT wbb2vme_top 
GENERIC (
   A16_REG_MAPPING   : boolean := TRUE;                        -- if true, access to vme slave A16 space goes to vme runtime registers and above 0x800 to sram (compatible to old revisions)
                                                               -- if false, access to vme slave A16 space goes to sram
   LONGADD_SIZE      : integer range 3 TO 8:=3;
   USE_LONGADD       : boolean := TRUE                          -- If FALSE, bits (7 DOWNTO 5) of SIGNAL longadd will be allocated to vme_adr_out(31 DOWNTO 29)
   );
PORT (
   clk               : IN std_logic;                      -- 66 MHz
   rst               : IN std_logic;                      -- global reset signal (asynch)
   startup_rst       : IN std_logic;                      -- powerup reset
   postwr            : OUT std_logic;                     -- posted write
   vme_irq           : OUT std_logic_vector(7 DOWNTO 0);  -- interrupt request to pci-bus
   berr_irq          : OUT std_logic;                     -- signal berrn interrupt request
   locmon_irq        : OUT std_logic_vector(1 DOWNTO 0);  -- interrupt request location monitor to pci-bus
   mailbox_irq       : OUT std_logic_vector(1 DOWNTO 0);  -- interrupt request mailbox to pci-bus
   dma_irq           : OUT std_logic;                     -- interrupt request dma to pci-bus
   prevent_sysrst    : IN std_logic;                      -- if "1", sysrst_n_out will not be activated after powerup,
                                                          -- if "0", sysrst_n_out will be activated if in slot1 and system reset is active (sysc_bit or rst)
   test_vec          : OUT test_vec_type;

   -- vmectrl slave
   wbs_stb_i         : IN std_logic;
   wbs_ack_o         : OUT std_logic;
   wbs_err_o         : OUT std_logic;
   wbs_we_i          : IN std_logic;
   wbs_sel_i         : IN std_logic_vector(3 DOWNTO 0);
   wbs_cyc_i         : IN std_logic;
   wbs_adr_i         : IN std_logic_vector(31 DOWNTO 0);
   wbs_dat_o         : OUT std_logic_vector(31 DOWNTO 0);
   wbs_dat_i         : IN std_logic_vector(31 DOWNTO 0);
   wbs_tga_i         : IN std_logic_vector(8 DOWNTO 0);

   -- vmectrl master
   wbm_ctrl_stb_o    : OUT std_logic;
   wbm_ctrl_ack_i    : IN std_logic;
   wbm_ctrl_err_i    : IN std_logic;
   wbm_ctrl_we_o     : OUT std_logic;
   wbm_ctrl_sel_o    : OUT std_logic_vector(3 DOWNTO 0);
   wbm_ctrl_cyc_sram : OUT std_logic;
   wbm_ctrl_cyc_pci  : OUT std_logic;
   wbm_ctrl_adr_o    : OUT std_logic_vector(31 DOWNTO 0);
   wbm_ctrl_dat_o    : OUT std_logic_vector(31 DOWNTO 0);
   wbm_ctrl_dat_i    : IN std_logic_vector(31 DOWNTO 0);

   wbm_dma_stb_o    : OUT std_logic;
   wbm_dma_ack_i    : IN std_logic;
   wbm_dma_we_o     : OUT std_logic;
   wbm_dma_cti      : OUT std_logic_vector(2 DOWNTO 0);
   wbm_dma_tga_o    : OUT std_logic_vector(8 DOWNTO 0);
   wbm_dma_err_i    : IN std_logic;
   wbm_dma_sel_o    : OUT std_logic_vector(3 DOWNTO 0);
   wbm_dma_cyc_sram : OUT std_logic;
   wbm_dma_cyc_vme  : OUT std_logic;
   wbm_dma_cyc_pci  : OUT std_logic;
   wbm_dma_adr_o    : OUT std_logic_vector(31 DOWNTO 0);
   wbm_dma_dat_o    : OUT std_logic_vector(31 DOWNTO 0);
   wbm_dma_dat_i    : IN std_logic_vector(31 DOWNTO 0);

   -- vmebus
   va                : INOUT std_logic_vector(31 DOWNTO 0);    -- address   
   vd                : INOUT std_logic_vector(31 DOWNTO 0);    -- data   
   vam               : INOUT std_logic_vector(5 DOWNTO 0);     -- address modifier
   writen            : INOUT std_logic;                        -- write enable      
   iackn             : INOUT std_logic;                        -- Handler's output 
   irq_i_n           : IN std_logic_vector(7 DOWNTO 1);        -- interrupt request inputs
   irq_o_n           : OUT std_logic_vector(7 DOWNTO 1);       -- interrupt request outputs
   as_o_n            : OUT   std_logic;                        -- address strobe out  
   as_oe_n           : OUT   std_logic;                        -- address strobe output enable  
   as_i_n            : IN    std_logic;                        -- address strobe in
   sysresn           : OUT   std_logic;                        -- system reset out 
   sysresin          : IN    std_logic;                        -- system reset in
   ds_o_n            : OUT   std_logic_vector(1 DOWNTO 0);     -- data strobe outputs
   ds_i_n            : IN   std_logic_vector(1 DOWNTO 0);      -- data strobe inputs
   ds_oe_n           : OUT std_logic;                          -- data strobe output enable
   berrn             : OUT   std_logic;                        -- bus error out    
   berrin            : IN    std_logic;                        -- bus error in 
   dtackn            : OUT   std_logic;                        -- dtack out   
   dtackin           : IN    std_logic;                        -- dtack in
   slot01n           : OUT   std_logic;                        -- indicates whether controller has detected position in slot 1 (low active)
   sysfail_i_n       : IN   std_logic;                        -- system failure interrupt input
   sysfail_o_n       : OUT   std_logic;                        -- system failure interrupt output
   bbsyn             : OUT   std_logic;                        -- bus busy out    
   bbsyin            : IN    std_logic;                        -- bus busy in     
   bclr_i_n          : IN std_logic;                           -- bus clear input
   bclr_o_n          : OUT std_logic;                          -- bus clear output
   retry_i_n         : IN std_logic;                           -- bus retry input
   retry_o_n         : OUT std_logic;                          -- bus retry output
   retry_oe_n        : OUT std_logic;                          -- bus retry output enable
   br_i_n            : IN std_logic_vector(3 DOWNTO 0);        -- bus request inputs
   br_o_n            : OUT std_logic_vector(3 DOWNTO 0);       -- bus request outputs
   iackin            : IN    std_logic;                        -- Interrupter's input
   iackoutn          : OUT   std_logic;                        -- Interrupter's output
   acfailn           : IN    std_logic;                        -- from Power Supply
   bg_i_n            : IN  std_logic_vector(3 DOWNTO 0);       -- bus grant input
   bg_o_n            : OUT std_logic_vector(3 DOWNTO 0);       -- bus grant output
   ga                : IN std_logic_vector(4 DOWNTO 0);        -- geographical addresses
   gap               : IN std_logic;                           -- geographical addresses parity

   -- vme status signals
   vme_berr          : OUT std_logic;                          -- indicates vme bus error (=MSTR(2)), must be cleared by sw           
   vme_mstr_busy     : OUT std_logic;                          -- indicates vme bus master is active
        
   --data bus bus control signals for vmebus drivers
   d_dir             : OUT std_logic;                          -- external driver control data direction (1: drive to vmebus 0: drive to fpga)
   d_oe_n            : OUT std_logic;                          -- external driver control data output enable low active
   am_dir            : OUT std_logic;                          -- external driver control address modifier direction (1: drive to vmebus 0: drive to fpga)
   am_oe_n           : OUT std_logic;                          -- external driver control address modifier output enable low activ 
   a_dir             : OUT std_logic;                          -- external driver control address direction (1: drive to vmebus 0: drive to fpga)
   a_oe_n            : OUT std_logic;                          -- external driver control address output enable low activ
   
   v2p_rstn          : OUT   std_logic                         -- Reset from VMEbus to System on board
     );
END COMPONENT;

   CONSTANT CONST_500HZ : integer := 66667; -- half 500Hz clock period counter value at 66MHz

   SIGNAL sys_clk       : std_logic;                        -- system clock 66 MHz
   SIGNAL sys_rst       : std_logic;                        -- system async reset                  
   SIGNAL rst_33        : std_logic;                        -- reset synchronized to clk_33
   SIGNAL clk_33        : std_logic;                        -- 33 MHz clock for 16z066
   SIGNAL clk_50        : std_logic;                        -- 50 MHz clock for reconfig_clk and cal_blk_clk
   SIGNAL clk_125       : std_logic;                        -- 125 MHz clock for fixed_clk
   SIGNAL clk_500       : std_logic;                        -- 500 Hz clock
   SIGNAL cnt_500hz     : integer;

   -- MASTER SIGNALS
   SIGNAL wbmo_0       : wbo_type;
   SIGNAL wbmi_0       : wbi_type;
   SIGNAL wbmo_0_cyc   : std_logic_vector(3 DOWNTO 0);
   SIGNAL wbmo_0_cyc_int   : std_logic_vector(9 DOWNTO 0);
   SIGNAL wbmo_1       : wbo_type;
   SIGNAL wbmi_1       : wbi_type;
   SIGNAL wbmo_1_cyc   : std_logic_vector(1 DOWNTO 0);
   SIGNAL wbmo_2       : wbo_type;
   SIGNAL wbmi_2       : wbi_type;
   SIGNAL wbmo_2_cyc   : std_logic_vector(2 DOWNTO 0);
   -- SLAVE SIGNALS
   SIGNAL wbso_0       : wbi_type;
   SIGNAL wbsi_0       : wbo_type;
   SIGNAL wbsi_0_cyc      : std_logic;
   SIGNAL wbso_1       : wbi_type;
   SIGNAL wbsi_1       : wbo_type;
   SIGNAL wbsi_1_cyc      : std_logic;
   SIGNAL wbso_2       : wbi_type;
   SIGNAL wbsi_2       : wbo_type;
   SIGNAL wbsi_2_cyc      : std_logic;
   SIGNAL wbso_3       : wbi_type;
   SIGNAL wbsi_3       : wbo_type;
   SIGNAL wbsi_3_cyc      : std_logic;
   SIGNAL wbso_4       : wbi_type;
   SIGNAL wbsi_4       : wbo_type;
   SIGNAL wbsi_4_cyc      : std_logic;
   
   SIGNAL pll_locked    : std_logic;

   SIGNAL sr_d_oe       : std_logic;
   SIGNAL board_status  : std_logic_vector(1 DOWNTO 0);
   SIGNAL sr_d_out      : std_logic_vector(15 DOWNTO 0);
   SIGNAL sr_d_in       : std_logic_vector(15 DOWNTO 0);
   
   
   SIGNAL vme_irq          : std_logic_vector(7 DOWNTO 0);  -- interrupt request to pci-bus
   SIGNAL berr_irq         : std_logic;                     -- signal berrn interrupt request
   SIGNAL locmon_irq       : std_logic_vector(1 DOWNTO 0);  -- interrupt request location monitor to pci-bus
   SIGNAL mailbox_irq      : std_logic_vector(1 DOWNTO 0);  -- interrupt request mailbox to pci-bus
   SIGNAL mailbox_irq_i    : std_logic;
   SIGNAL dma_irq          : std_logic;
   SIGNAL slot01n          : std_logic;      
   SIGNAL test_vec         : test_vec_type;
   SIGNAL pll_locked_inv   : std_logic;
   SIGNAL startup_rst      : std_logic:='1';
   SIGNAL porst            : std_logic;
   SIGNAL porst_n_q        : std_logic:='0';
   SIGNAL porst_n          : std_logic:='0';
   SIGNAL link_train_active   : std_logic;
   SIGNAL vme_berr         : std_logic;     
   SIGNAL vme_mstr_busy    : std_logic; 
   SIGNAL led_cnt          : std_logic_vector(17 DOWNTO 0);    -- 2^18 = 3.9 ms
   
   -- high active signals on A25
   SIGNAL vme_irq_o_n       : std_logic_vector(7 DOWNTO 1);
   SIGNAL vme_as_oe_n       : std_logic;
   SIGNAL vme_retry_oe_n    : std_logic;
   SIGNAL vme_sysres_o_n    : std_logic;
   SIGNAL vme_ds_oe_n       : std_logic;
   SIGNAL vme_scon_n        : std_logic;
   SIGNAL vme_sysfail_o_n   : std_logic;
   SIGNAL vme_bbsy_o_n      : std_logic;
   SIGNAL vme_dtack_o_n     : std_logic;
   SIGNAL vme_berr_o_n      : std_logic;
   SIGNAL vme_br_o_n        : std_logic_vector(3 DOWNTO 0);

BEGIN             
   vme_irq_o     <= NOT vme_irq_o_n    ;
   vme_as_oe     <= NOT vme_as_oe_n     ;
   vme_retry_oe  <= NOT vme_retry_oe_n ;
   vme_sysres_o  <= NOT vme_sysres_o_n ;
   vme_ds_oe     <= NOT vme_ds_oe_n    ;
   vme_scon      <= NOT vme_scon_n     ;
   vme_sysfail_o <= NOT vme_sysfail_o_n;
   vme_bbsy_o    <= NOT vme_bbsy_o_n   ;
   vme_br_o      <= NOT vme_br_o_n     ;
   vme_berr_o    <= NOT vme_berr_o_n;
   vme_dtack_o    <= NOT vme_dtack_o_n;
   
   led_red_n <= NOT vme_berr;
--   led_green_n <= slot01;
   vme_sysclk <= clk_16mhz;
   vme_scon_n <= slot01n;

   -- counter for extending vme master active pulses to at least 3 ms
   PROCESS(sys_clk, sys_rst)
   BEGIN
      IF sys_rst = '1' THEN
         led_cnt <= (OTHERS => '0');
         led_green_n <= '1';
      ELSIF sys_clk'event AND sys_clk = '1' THEN
         IF vme_mstr_busy = '1' THEN      -- if master is active, start counter to extend pulse for 3 ms
            led_cnt <= (OTHERS => '1');
            led_green_n <= '0';           -- switch on LED
         ELSIF led_cnt = 0 THEN           -- is 3 ms over?
            led_cnt <= (OTHERS => '0');
            led_green_n <= '1';           -- switch off LED
         ELSE
            led_cnt <= led_cnt - '1';     -- count for 3 ms
            led_green_n <= '0';
         END IF;
      END IF;
   END PROCESS;

   pll_locked_inv <= NOT pll_locked;
   startup_rst <= pll_locked_inv; 
   
   wbso_3.err <= '0';
   wbso_4.err <= '0';
   wbmo_0.bte <= "00";
   wbmo_1.bte <= "00";
   wbmo_2.bte <= "00";
   wbmo_1.cti <= "000";

   fpga_test(1) <= 'Z';
   fpga_test(2) <= 'Z';
   fpga_test(3) <= 'Z';
   fpga_test(4) <= 'Z';
   fpga_test(5) <= 'Z';
  
   -- generate power on reset in order to start application fpga load as early as possible
   PROCESS (clk_16mhz)
   BEGIN
      IF clk_16mhz'EVENT AND clk_16mhz = '1' THEN
         porst_n_q <= '1';
         porst_n <= porst_n_q;
      END IF;
   END PROCESS;
   
   porst <= NOT porst_n;

  -- synchronize reset to 33 MHz clock
   PROCESS(clk_33, hreset_n, pll_locked)
   BEGIN
      IF hreset_n = '0' OR pll_locked = '0' THEN
         rst_33 <= '1';
      ELSIF clk_33'EVENT AND clk_33 = '1' THEN
         rst_33 <= '0';
      END IF;
   END PROCESS;

   
   PROCESS(sys_clk, hreset_n, pll_locked)
   BEGIN
      IF hreset_n = '0' OR pll_locked = '0' THEN
         sys_rst <= '1';
      ELSIF sys_clk'EVENT AND sys_clk = '1' THEN
         sys_rst <= '0';
      END IF;
   END PROCESS;

   PROCESS(sys_clk, sys_rst)
   BEGIN
      IF sys_rst = '1' THEN
         cnt_500hz <= 0;
         clk_500 <= '0';
      ELSIF sys_clk'EVENT AND sys_clk = '1' THEN
         IF cnt_500hz = 0 THEN 
            cnt_500hz <= CONST_500HZ;
            clk_500 <= NOT clk_500;
         ELSE
            cnt_500hz <= cnt_500hz - 1;
         END IF;
      END IF;
   END PROCESS;
   

pll: pll_pcie
   PORT MAP (
      areset      => porst,
      inclk0      => clk_16mhz,     -- 16 MHz
      c0          => clk_125,       -- 125 MHz
      c1          => clk_50,        -- 50 MHz
      c2          => sys_clk,       -- 66 MHz
      c3          => sr_clk,        -- 66 MHz phase shifted to sys_clk
      c4          => clk_33,        -- 33 MHz
      locked      => pll_locked
   );

   wbmo_0_cyc <=                                      -- +-Module Name--------------+-cyc-+---offset-+-----size-+-bar-+ 
      "0001" WHEN wbmo_0_cyc_int(0) = '1' ELSE        -- |     Chameleon Table      |  0  |        0 |      200 |   0 | 
      "0010" WHEN wbmo_0_cyc_int(1) = '1' ELSE        -- |     16Z126_SERFLASH      |  1  |      200 |       20 |   0 |  
      "0100" WHEN wbmo_0_cyc_int(2) = '1' ELSE        -- |       16z002-01 VME      |  2  |    10000 |    10000 |   0 |
      "0100" WHEN wbmo_0_cyc_int(3) = '1' ELSE        -- |16z002-01 VME A16D16      |  3  |    20000 |    10000 |   0 |
      "0100" WHEN wbmo_0_cyc_int(4) = '1' ELSE        -- |16z002-01 VME A16D32      |  4  |    30000 |    10000 |   0 |
      "1000" WHEN wbmo_0_cyc_int(5) = '1' ELSE        -- |  16z002-01 VME SRAM      |  5  |        0 |   100000 |   1 | 
      "0100" WHEN wbmo_0_cyc_int(6) = '1' ELSE        -- |16z002-01 VME A24D16      |  6  |        0 |  1000000 |   2 |
      "0100" WHEN wbmo_0_cyc_int(7) = '1' ELSE        -- |16z002-01 VME A24D32      |  7  |  1000000 |  1000000 |   2 |
      "0100" WHEN wbmo_0_cyc_int(8) = '1' ELSE        -- |   16z002-01 VME A32      |  8  |        0 | 20000000 |   3 | 
      "0100" WHEN wbmo_0_cyc_int(9) = '1' ELSE        -- |16z002-01 VME CR/CSR      |  9  |        0 | 01000000 |   4 | 
      "0000";                                         -- +--------------------------+-----+----------+----------+-----+ 

   wbmo_1.tga <= (OTHERS => '0');

   wbmo_0.tga(7) <= '0'; -- indicate access from PCIE
   wbmo_0.tga(8) <= '0'; -- unused
   wbmo_0.tga(6 DOWNTO 0) <=                                   -- +-Module Name--------------+-cyc-+---offset-+-----size-+-bar-+
      CONST_VME_A24D16  WHEN wbmo_0_cyc_int(6) = '1' ELSE      -- |16z002-01 VME A24D16      |  6  |        0 |  1000000 |   2 | 
      CONST_VME_A16D16  WHEN wbmo_0_cyc_int(3) = '1' ELSE      -- |16z002-01 VME A16D16      |  3  |    20000 |    10000 |   0 |
      CONST_VME_A16D32  WHEN wbmo_0_cyc_int(4) = '1' ELSE      -- |16z002-01 VME A16D32      |  4  |    30000 |    10000 |   0 | 
      CONST_VME_IACK    WHEN wbmo_0_cyc_int(2) = '1'                                              
                            AND wbmo_0.adr(8) = '1' ELSE       -- |16z002-01 VME IACK        |  2  |    10100 |       10 |   0 |
      CONST_VME_REGS    WHEN wbmo_0_cyc_int(2) = '1' ELSE      -- |16z002-01 VME REGS        |  2  |    10000 |    10000 |   0 |
      CONST_VME_A32D32  WHEN wbmo_0_cyc_int(8) = '1' ELSE      -- |16z002-01 VME A32         |  8  |        0 | 20000000 |   3 |
      CONST_VME_A24D32  WHEN wbmo_0_cyc_int(7) = '1' ELSE      -- |16z002-01 VME A24D32      |  7  |  1000000 |  1000000 |   2 |
      CONST_VME_CRCSR   WHEN wbmo_0_cyc_int(9) = '1' ELSE      -- |16z002-01 VME CRCSR       |  9  |        0 |  1000000 |   4 |
      (OTHERS => '0');                                         -- +--------------------------+-----+----------+----------+-----+
                                                                                                                               
pcie: ip_16z091_01_top 
   GENERIC MAP (
      SIMULATION           => '1',
      FPGA_FAMILY          => CYCLONE4,
      IRQ_WIDTH            => 13,
--      USE_LANES            => "001",			-- x1 for simulation
      USE_LANES            => "100",		-- x4 for synthesis
      NR_OF_WB_SLAVES      => NR_OF_WB_SLAVES,
      NR_OF_BARS_USED      => 5,
      VENDOR_ID            => 16#1A88#,
      DEVICE_ID            => 16#4D45#,
      REVISION_ID          => 16#1#,
      CLASS_CODE           => 16#068000#,
      SUBSYSTEM_VENDOR_ID  => 16#D5#,
      SUBSYSTEM_DEVICE_ID  => 16#5A91#,
      BAR_MASK_0           => x"FFFC0000",   -- 256k
      BAR_MASK_1           => x"FFF00000",   -- 1M
      BAR_MASK_2           => x"FE000000",   -- 32M
      BAR_MASK_3           => x"E0000000",   -- 512M
      BAR_MASK_4           => x"FF000000",	 -- 16M
      BAR_MASK_5           => x"FFFFF000",
      PCIE_REQUEST_LENGTH  => "0000100000",    -- 32DW = 128Byte
      RX_LPM_WIDTHU        => 10,
      TX_HEADER_LPM_WIDTHU => 5,
      TX_DATA_LPM_WIDTHU   => 10
   )
   PORT MAP (
   -- Hard IP ports:
      clk_50             => clk_50,
      clk_125            => clk_125,
      ref_clk            => refclk,
      clk_500            => clk_500,
      ext_rst_n          => hreset_n,

      rx_0               => pcie_rx(0),
      rx_1               => pcie_rx(1),
      rx_2               => pcie_rx(2),
      rx_3               => pcie_rx(3),

      tx_0               => pcie_tx(0),
      tx_1               => pcie_tx(1),
      tx_2               => pcie_tx(2),
      tx_3               => pcie_tx(3),

      wb_clk             => sys_clk,
      wb_rst             => sys_rst,

      wbm_ack            => wbmi_0.ack,
      wbm_dat_i          => wbmi_0.dat,
      wbm_stb            => wbmo_0.stb,
      wbm_cyc_o          => wbmo_0_cyc_int,
      wbm_we             => wbmo_0.we ,
      wbm_sel            => wbmo_0.sel,
      wbm_adr            => wbmo_0.adr,
      wbm_dat_o          => wbmo_0.dat,
      wbm_cti            => wbmo_0.cti,
      wbm_tga            => open,

      wbs_cyc            => wbsi_4_cyc,
      wbs_stb            => wbsi_4.stb,
      wbs_we             => wbsi_4.we ,
      wbs_sel            => wbsi_4.sel,
      wbs_adr            => wbsi_4.adr,
      wbs_dat_i          => wbsi_4.dat,
      wbs_cti            => wbsi_4.cti,
      wbs_tga            => wbsi_4.tga(0),
      wbs_ack            => wbso_4.ack,
      wbs_err            => open,
      wbs_dat_o          => wbso_4.dat,
      
      irq_req_i(0)      => vme_irq(0)          ,
      irq_req_i(1)      => vme_irq(1)           ,
      irq_req_i(2)      => vme_irq(2)           ,
      irq_req_i(3)      => vme_irq(3)           ,
      irq_req_i(4)      => vme_irq(4)           ,
      irq_req_i(5)      => vme_irq(5)           ,
      irq_req_i(6)      => vme_irq(6)           ,
      irq_req_i(7)      => vme_irq(7)           ,
      irq_req_i(8)      => berr_irq             ,
      irq_req_i(9)      => dma_irq            ,
      irq_req_i(10)     => locmon_irq(0)     ,
      irq_req_i(11)     => locmon_irq(1)           ,
      irq_req_i(12)     => mailbox_irq_i         ,        

      error_timeout      => open,
      error_cor_ext_rcv  => open,
      error_cor_ext_rpl  => open,
      error_rpl          => open,
      error_r2c0         => open,
      error_msi_num      => open,

      link_train_active  => link_train_active
   );
      
 
   mailbox_irq_i <= mailbox_irq(0) OR mailbox_irq(1);
   
   cham: iram_wb
   GENERIC MAP (
      FPGA_FAMILY    => FPGA_FAMILY,
      read_only      => 1,
      USEDW_WIDTH    => 9, -- 0x200 = 512
      --LOCATION       => "../Source/chameleon.hex"
      LOCATION       => "../../16a025-00_src/Source/chameleon.hex"
   )
   PORT MAP (
      clk            => sys_clk,
      rst            => sys_rst,
      stb_i          => wbsi_0.stb,
      cyc_i          => wbsi_0_cyc,
      ack_o          => wbso_0.ack,
      err_o          => wbso_0.err,
      we_i           => wbsi_0.we,
      sel_i          => wbsi_0.sel,
      adr_i          => wbsi_0.adr(10 DOWNTO 2),
      dat_i          => wbsi_0.dat,
      dat_o          => wbso_0.dat
      );
      
   srami: sram
   PORT MAP (
      clk66          => sys_clk,
      rst            => sys_rst,
      stb_i          => wbsi_3.stb,
      ack_o          => wbso_3.ack,
      we_i           => wbsi_3.we,
      sel_i          => wbsi_3.sel,
      cyc_i          => wbsi_3_cyc,
      dat_o          => wbso_3.dat,
      dat_i          => wbsi_3.dat,
      adr_i          => wbsi_3.adr(19 DOWNTO 0),
      bwn            => sr_bw_n,
      bwan           => sr_bwa_n,
      bwbn           => sr_bwb_n,
      adscn          => sr_adsc_n,
      roen           => sr_oe_n,
      ra             => sr_a,
      rd_in          => sr_d_in,
      rd_out         => sr_d_out,
      rd_oe          => sr_d_oe
      );

   
   sr_cs1_n <= '0'; --sys_rst;      -- selected if FPGA reset is released

   srdat: PROCESS(sr_d_oe, sr_d_out, sr_d)
   BEGIN
      IF sr_d_oe = '1' THEN
         sr_d <= sr_d_out;
         sr_d_in <= sr_d;
      ELSE
         sr_d <= (OTHERS => 'Z');
         sr_d_in <= sr_d;
      END IF;   
   END PROCESS;

sflash: z126_01_top 
   GENERIC MAP (
      SIMULATION              => FALSE,
      FPGA_FAMILY             => CYCLONE4,
      FLASH_TYPE              => M25P32,
      USE_DIRECT_INTERFACE    => FALSE,
      USE_REMOTE_UPDATE       => TRUE,
      LOAD_FPGA_IMAGE         => TRUE,
      LOAD_FPGA_IMAGE_ADR     => X"200100"
   )
   PORT MAP (
      clk_40mhz               => clk_33,
      rst_clk_40mhz           => rst_33,                                                                   
      clk_dir                 => sys_clk,
      rst_dir                 => sys_rst,      
      clk_indi                => sys_clk, 
      rst_indi                => sys_rst, 
      board_status            => board_status,
      wbs_stb_dir             => '0',            
      wbs_ack_dir             => OPEN,           
      wbs_we_dir              => '0',            
      wbs_sel_dir             => (OTHERS => '0'),
      wbs_cyc_dir             => '0',            
      wbs_dat_o_dir           => OPEN,           
      wbs_dat_i_dir           => (OTHERS => '0'),
      wbs_adr_dir             => (OTHERS => '0'),
      wbs_err_dir             => OPEN,           
      
      -- wishbone signals slave interface 1 (indirect addressing)
      wbs_stb_indi            => wbsi_1.stb,
      wbs_ack_indi            => wbso_1.ack,
      wbs_we_indi             => wbsi_1.we, 
      wbs_sel_indi            => wbsi_1.sel,
      wbs_cyc_indi            => wbsi_1_cyc,
      wbs_dat_o_indi          => wbso_1.dat,
      wbs_dat_i_indi          => wbsi_1.dat,
      wbs_adr_indi            => wbsi_1.adr,
      wbs_err_indi            => wbso_1.err 
   );


vme: wbb2vme_top 
GENERIC MAP(
   A16_REG_MAPPING   => true,
   LONGADD_SIZE      => 3,
   USE_LONGADD       => TRUE                        
   )
PORT MAP (
   clk               => sys_clk,
   rst               => sys_rst,
   startup_rst       => startup_rst,
   postwr            => open,
   vme_irq           => vme_irq ,
   berr_irq          => berr_irq,
   locmon_irq        => locmon_irq ,
   mailbox_irq       => mailbox_irq,
   dma_irq           => dma_irq ,
	prevent_sysrst    => '0',
   test_vec          => test_vec,

   -- vmectrl slave
   wbs_stb_i         => wbsi_2.stb,
   wbs_ack_o         => wbso_2.ack,
   wbs_err_o         => wbso_2.err,
   wbs_we_i          => wbsi_2.we,
   wbs_sel_i         => wbsi_2.sel,
   wbs_cyc_i         => wbsi_2_cyc,
   wbs_adr_i         => wbsi_2.adr,
   wbs_dat_o         => wbso_2.dat,
   wbs_dat_i         => wbsi_2.dat,
   wbs_tga_i         => wbsi_2.tga,

   -- vmectrl master
   wbm_ctrl_stb_o    => wbmo_1.stb,
   wbm_ctrl_ack_i    => wbmi_1.ack,
   wbm_ctrl_err_i    => wbmi_1.err,
   wbm_ctrl_we_o     => wbmo_1.we,
   wbm_ctrl_sel_o    => wbmo_1.sel,
   wbm_ctrl_cyc_sram => wbmo_1_cyc(0),
   wbm_ctrl_cyc_pci  => wbmo_1_cyc(1),
   wbm_ctrl_adr_o    => wbmo_1.adr,
   wbm_ctrl_dat_o    => wbmo_1.dat,
   wbm_ctrl_dat_i    => wbmi_1.dat,

   wbm_dma_stb_o     => wbmo_2.stb,
   wbm_dma_ack_i     => wbmi_2.ack,
   wbm_dma_we_o      => wbmo_2.we,
   wbm_dma_cti       => wbmo_2.cti,
   wbm_dma_tga_o     => wbmo_2.tga,
   wbm_dma_err_i     => wbmi_2.err,
   wbm_dma_sel_o     => wbmo_2.sel,
   wbm_dma_cyc_vme   => wbmo_2_cyc(0),
   wbm_dma_cyc_sram  => wbmo_2_cyc(1),
   wbm_dma_cyc_pci   => wbmo_2_cyc(2),
   wbm_dma_adr_o     => wbmo_2.adr,
   wbm_dma_dat_o     => wbmo_2.dat,
   wbm_dma_dat_i     => wbmi_2.dat,

   va                => vme_a,
   vd                => vme_d,
   vam               => vme_am,
   writen            => vme_write_n,
   iackn             => vme_iack_n,
   irq_i_n           => vme_irq_i_n,
   irq_o_n           => vme_irq_o_n,
   as_o_n            => vme_as_o_n,
   as_oe_n           => vme_as_oe_n,
   as_i_n            => vme_as_i_n,
   sysresn           => vme_sysres_o_n,
   sysresin          => vme_sysres_i_n,
   ds_o_n            => vme_ds_o_n,
   ds_i_n            => vme_ds_i_n,
   ds_oe_n           => vme_ds_oe_n,
   berrn             => vme_berr_o_n,
   berrin            => vme_berr_i_n,
   dtackn            => vme_dtack_o_n,
   dtackin           => vme_dtack_i_n,
   slot01n           => slot01n,
   sysfail_i_n       => vme_sysfail_i_n,
   sysfail_o_n       => vme_sysfail_o_n,
   bbsyn             => vme_bbsy_o_n,
   bbsyin            => vme_bbsy_i_n,
   bclr_i_n          => vme_bclr_i_n,
   bclr_o_n          => vme_bclr_o_n,
   retry_i_n         => vme_retry_i_n  ,
   retry_o_n         => vme_retry_o_n  ,
   retry_oe_n        => vme_retry_oe_n ,
   br_i_n            => vme_br_i_n,
   br_o_n            => vme_br_o_n,
   iackin            => vme_iack_i_n,
   iackoutn          => vme_iack_o_n,
   acfailn           => vme_acfail_i_n,
   bg_i_n            => vme_bg_i_n,
   bg_o_n            => vme_bg_o_n,
   ga                => vme_ga,
   gap               => vme_gap,
   vme_berr          => vme_berr,         
   vme_mstr_busy     => vme_mstr_busy,
   d_dir             => vme_d_dir  ,
   d_oe_n            => vme_d_oe_n ,
   am_dir            => vme_am_dir ,
   am_oe_n           => vme_am_oe_n,
   a_dir             => vme_a_dir  ,
   a_oe_n            => vme_a_oe_n ,
   v2p_rstn          => v2p_rstn
   );
   
wbb : wb_bus
GENERIC MAP (
   sets           => sets,
   timeout        => timeout
)
PORT MAP (
   clk            => sys_clk,
   rst            => sys_rst,

   wbmo_0        => wbmo_0,
   wbmi_0        => wbmi_0,
   wbmo_0_cyc    => wbmo_0_cyc,
   wbmo_1        => wbmo_1,
   wbmi_1        => wbmi_1,
   wbmo_1_cyc    => wbmo_1_cyc,
   wbmo_2        => wbmo_2,
   wbmi_2        => wbmi_2,
   wbmo_2_cyc    => wbmo_2_cyc,
   wbso_0        => wbso_0,
   wbsi_0        => wbsi_0,
   wbsi_0_cyc    => wbsi_0_cyc,
   wbso_1        => wbso_1,
   wbsi_1        => wbsi_1,
   wbsi_1_cyc    => wbsi_1_cyc,
   wbso_2        => wbso_2,
   wbsi_2        => wbsi_2,
   wbsi_2_cyc    => wbsi_2_cyc,
   wbso_3        => wbso_3,
   wbsi_3        => wbsi_3,
   wbsi_3_cyc    => wbsi_3_cyc,
   wbso_4        => wbso_4,
   wbsi_4        => wbsi_4,
   wbsi_4_cyc    => wbsi_4_cyc
);
      

-------------------------------------------------------------------------------------------------------------      

END A25_top_arch;

--   CONFIGURATION wbm_cfg OF pcies_wbm_ctrl IS
--      FOR pcies_wbm_ctrl_arch
--         FOR wb_adr_dec_inst : pcies_wb_adr_dec
--            USE ENTITY work.pcies_wb_adr_dec(wb_adr_dec_arch);
--         END FOR;
--      END FOR;
--   END CONFIGURATION wbm_cfg;
--
--   CONFIGURATION pcies_wbm_cfg OF pcies_wbm IS
--      FOR pcies_wbm_arch
--         FOR wbm : pcies_wbm_ctrl
--            USE CONFIGURATION work.wbm_cfg;
--         END FOR;
--      END FOR;
--   END CONFIGURATION pcies_wbm_cfg;
--   
--   CONFIGURATION pcies2wbb_cfg OF pcies2wbb_top IS
--      FOR pcies2wbb_top_arch
--         FOR pcies_wbm_i : pcies_wbm
--            USE CONFIGURATION work.pcies_wbm_cfg;
--         END FOR;
--      END FOR;
--   END CONFIGURATION pcies2wbb_cfg;
--   
--   CONFIGURATION top_cfg of A25_top IS
--      FOR A25_top_arch
--         FOR pcie : pcies2wbb_top
--            USE CONFIGURATION work.pcies2wbb_cfg;          
--         END FOR;                                              
--      END FOR;
--   END CONFIGURATION top_cfg;


-- Configurations for 16z091-01 address decoder

   CONFIGURATION z091_01_wb_master_cfg OF z091_01_wb_master IS
     FOR z091_01_wb_master_arch
       FOR z091_01_wb_adr_dec_comp : z091_01_wb_adr_dec
         USE ENTITY work.z091_01_wb_adr_dec(a25_arch);      
       END FOR;
     END FOR;
   END CONFIGURATION z091_01_wb_master_cfg;
      
   CONFIGURATION ip_16z091_01_cfg OF ip_16z091_01 IS
     FOR ip_16z091_01_arch
       FOR wb_master_comp : z091_01_wb_master
         USE CONFIGURATION work.z091_01_wb_master_cfg;  
       END FOR;
     END FOR;
   END CONFIGURATION ip_16z091_01_cfg;
      
   CONFIGURATION ip_16z091_01_top_cfg OF ip_16z091_01_top IS
     FOR ip_16z091_01_top_arch
       FOR ip_16z091_01_comp : ip_16z091_01
         USE CONFIGURATION work.ip_16z091_01_cfg;  
       END FOR;
     END FOR;
   END CONFIGURATION ip_16z091_01_top_cfg; 
   
   CONFIGURATION top_cfg OF A25_top IS
     FOR A25_top_arch
       FOR pcie : ip_16z091_01_top          
         USE CONFIGURATION work.ip_16z091_01_top_cfg;        
       END FOR;                                                  
     END FOR;
   END CONFIGURATION top_cfg; 
 