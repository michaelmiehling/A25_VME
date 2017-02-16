--------------------------------------------------------------------------------
-- Title       : top level module for 16z091-01 design
-- Project     : 16z091-01
--------------------------------------------------------------------------------
-- File        : ip_16z091_01_top
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 23.02.2011
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6a
-- Synthesis   : Quartus II 10.0
--------------------------------------------------------------------------------
-- Description : 
-- Toplevel module that combines the 16z091-01 IP core with the Altera hard 
-- makro PCIe IP core
--------------------------------------------------------------------------------
-- Hierarchy   : 
-- *  ip_16z091_01_top_core
--       ip_16z091_01
--       Hard_IP
--       z091_01_wb_adr_dec
--       pcie_msi
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

library work;
use work.fpga_pkg_2.all;

entity ip_16z091_01_top is
   generic(
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
      ROM_MASK             : std_logic_vector(31 downto 0) := x"FFFF0000";
      
      PCIE_REQUEST_LENGTH  : std_logic_vector(9 downto 0)  := "0000010000";    -- 16DW = 64Byte
      RX_LPM_WIDTHU        : integer range 10 DOWNTO 5     := 10;
      TX_HEADER_LPM_WIDTHU : integer range 10 DOWNTO 5     := 5;
      TX_DATA_LPM_WIDTHU   : integer range 10 DOWNTO 5     := 10;

      GP_DEBUG_PORT_WIDTH  : positive := 1
   );
   port(
   -- Hard IP ports:
      clk_50             : in  std_logic;                                        --  50 MHz clock for reconfig_clk and cal_blk_clk
      clk_125            : in  std_logic;                                        -- 125 MHz clock for fixed_clk, CycloneIV only
      ref_clk            : in  std_logic;                                        -- 100 MHz reference clock
      clk_500            : in  std_logic;                                        -- 500 Hz clock
      ext_rst_n          : in  std_logic;                                        -- for CycloneV this MUST be connected to
                                                                                 -- nPERSTL0 for top left HardIP
                                                                                 -- nPERSTL1 for bottom left Hard IP <- use this one first (recommended by Altera)
      
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
      gp_debug_port      : out std_logic_vector(GP_DEBUG_PORT_WIDTH -1 downto 0); -- general purpose debug port
      link_train_active  : out std_logic
   );
end entity ip_16z091_01_top;

-- ****************************************************************************

-- +----------------------------------------------------------------------------
-- | Architecture for Cyclone IV
-- +----------------------------------------------------------------------------
architecture ip_16z091_01_top_arch of ip_16z091_01_top is

constant MAX_ADDR_VAL : std_logic_vector(31 downto 0) := x"FFFFFFFF";                                   -- := 2^32 - 1

function conv_std_to_string(
   in_bit : std_logic
) return string is
begin
   if(in_bit = '0') then
      return "false";
   else
      return "true";
   end if;
end function conv_std_to_string;

function calc_mask_size(
   in_BAR_mask : std_logic_vector;
   BAR_No      : integer range 5 downto 0
) return integer is
variable in_val : std_logic_vector(31 downto 0) := (others => '0');
variable int_temp : integer := 0;
variable addr_line : integer range 32 downto 1 := 1;
begin
   if(BAR_No > NR_OF_BARS_USED - 1) then
      return 0;
   else
      ---------------------------------------------------------
      -- memory thus unmask I/O, type and prefetch bit values
      ---------------------------------------------------------
      if(in_BAR_mask(0) = '0') then
         in_val := in_BAR_mask(31 downto 4) & "0000";
      -----------------------------------------
      -- I/O thus unmask I/O and reserved bit
      -----------------------------------------
      else
         in_val := in_BAR_mask(31 downto 2) & "00";
      end if;
      
      in_val := MAX_ADDR_VAL - in_val;
      int_temp := conv_integer(unsigned(in_val));
      
      while int_temp >= 2 loop
         addr_line := addr_line + 1;
         int_temp  := int_temp / 2;
      end loop;
   
      return addr_line;
   end if;
end function calc_mask_size;

constant IO_SPACE_0  : string  := conv_std_to_string(BAR_MASK_0(0));
constant PREFETCH_0  : string  := conv_std_to_string(BAR_MASK_0(3));
constant SIZE_MASK_0 : integer := calc_mask_size(BAR_MASK_0, 0);
constant IO_SPACE_1  : string  := conv_std_to_string(BAR_MASK_1(0));
constant PREFETCH_1  : string  := conv_std_to_string(BAR_MASK_1(3));
constant SIZE_MASK_1 : integer := calc_mask_size(BAR_MASK_1, 1);
constant IO_SPACE_2  : string  := conv_std_to_string(BAR_MASK_2(0));
constant PREFETCH_2  : string  := conv_std_to_string(BAR_MASK_2(3));
constant SIZE_MASK_2 : integer := calc_mask_size(BAR_MASK_2, 2);
constant IO_SPACE_3  : string  := conv_std_to_string(BAR_MASK_3(0));
constant PREFETCH_3  : string  := conv_std_to_string(BAR_MASK_3(3));
constant SIZE_MASK_3 : integer := calc_mask_size(BAR_MASK_3, 3);
constant IO_SPACE_4  : string  := conv_std_to_string(BAR_MASK_4(0));
constant PREFETCH_4  : string  := conv_std_to_string(BAR_MASK_4(3));
constant SIZE_MASK_4 : integer := calc_mask_size(BAR_MASK_4, 4);
constant IO_SPACE_5  : string  := conv_std_to_string(BAR_MASK_5(0));
constant PREFETCH_5  : string  := conv_std_to_string(BAR_MASK_5(3));
constant SIZE_MASK_5 : integer := calc_mask_size(BAR_MASK_5, 5);
--TODO_ITEM FIX THIS!
--constant SIZE_MASK_ROM : integer := calc_mask_size(ROM_MASK, 6);
constant SIZE_MASK_ROM : integer := calc_mask_size(ROM_MASK, 5);

constant SUPPORTED_DEVICES : supported_family_types := (CYCLONE4, ARRIA2_GX);

-- internal signals -----------------------------------------------------------
signal rst_int                : std_logic;
signal core_clk_int           : std_logic;
signal crst_int               : std_logic;
signal srst_int               : std_logic;
signal npor_int               : std_logic;

signal rx_st_data0_int        : std_logic_vector(63 downto 0);
signal rx_st_err0_int         : std_logic;
signal rx_st_valid0_int       : std_logic;
signal rx_st_sop0_int         : std_logic;
signal rx_st_eop0_int         : std_logic;
signal rx_st_be0_int          : std_logic_vector(7 downto 0);
signal rx_st_bardec0_int      : std_logic_vector(7 downto 0);
signal tx_st_ready0_int       : std_logic;
signal tx_fifo_full0_int      : std_logic;
signal tx_fifo_empty0_int     : std_logic;
signal tx_fifo_rdptr0_int     : std_logic_vector(3 downto 0);
signal tx_fifo_wrptr0_int     : std_logic_vector(3 downto 0);
signal pme_to_sr_int          : std_logic;
signal tl_cfg_add_int         : std_logic_vector(3 downto 0);
signal tl_cfg_ctl_int         : std_logic_vector(31 downto 0);
signal tl_cfg_ctl_wr_int      : std_logic;
signal tl_cfg_sts_int         : std_logic_vector(52 downto 0);
signal tl_cfg_sts_wr_int      : std_logic;
signal app_int_ack_int        : std_logic;
signal app_msi_ack_int        : std_logic;

signal rx_st_mask0_int        : std_logic;
signal rx_st_ready0_int       : std_logic;
signal tx_st_err0_int         : std_logic;
signal tx_st_valid0_int       : std_logic;
signal tx_st_sop0_int         : std_logic;
signal tx_st_eop0_int         : std_logic;
signal tx_st_data0_int        : std_logic_vector(63 downto 0);
signal pme_to_cr_int          : std_logic;
signal app_int_sts_int        : std_logic;
signal app_msi_req_int        : std_logic;
signal app_msi_tc_int         : std_logic_vector(2 downto 0);
signal app_msi_num_int        : std_logic_vector(4 downto 0);
signal pex_msi_num_int        : std_logic_vector(4 downto 0);

signal derr_cor_ext_rcv_int   : std_logic_vector(1 downto 0) := "00";
signal derr_cor_ext_rpl_int   : std_logic;
signal derr_rpl_int           : std_logic;
signal r2c_err0_int           : std_logic;
signal cpl_err_int            : std_logic_vector(6 downto 0);
signal cpl_pending_int        : std_logic;

--signal int_bar_hit            : std_logic_vector(6 downto 0);   
--signal wbm_adr_int            : std_logic_vector(31 downto 0);


signal reconfig_fromgxb_int   : std_logic_vector (4 downto 0);
signal reconfig_togxb_int     : std_logic_vector (3 downto 0);
SIGNAL reconf_busy            : std_logic;
signal pll_powerdown_int      : std_logic;

signal l2_exit                : std_logic;
signal hotrst_exit            : std_logic;
signal dlup_exit              : std_logic;

signal rst_cwh                : std_logic;
signal rst_cwh_cnt            : std_logic_vector (1 downto 0);

--signal wbm_cyc_o_int          : std_logic_vector(NR_OF_WB_SLAVES -1 downto 0);
--signal wbm_cyc_o_int_d        : std_logic_vector(NR_OF_WB_SLAVES -1 downto 0); --mwawrik: delayed cycle causes problems

signal test_in_int            : std_logic_vector(39 downto 0);
signal pipe_mode_int          : std_logic;

-- signals to connect pcie_msi
signal int_wb_int             : std_logic;
signal int_wb_pwr_enable      : std_logic;
signal int_wb_int_num         : std_logic_vector(4 downto 0);
signal int_wb_int_ack         : std_logic;
signal int_wb_int_num_allowed : std_logic_vector(5 downto 0);

signal int_ltssm              : std_logic_vector(4 downto 0);

-------------------------------------------------------------------------------

-- components -----------------------------------------------------------------
component ip_16z091_01
   generic(
      FPGA_FAMILY             : family_type := NONE;
      NR_OF_WB_SLAVES         : natural range 63 DOWNTO 1    := 12;      
      READY_LATENCY           : natural := 2;
      FIFO_MAX_USEDW          : std_logic_vector(9 downto 0) := "1111111001";
      WBM_SUSPEND_FIFO_ACCESS : std_logic_vector(9 downto 0) := "1111111011";
      WBM_RESUME_FIFO_ACCESS  : std_logic_vector(9 downto 0) := "1111110111";
      WBS_SUSPEND_FIFO_ACCESS : std_logic_vector(9 downto 0) := "1111111100";
      WBS_RESUME_FIFO_ACCESS  : std_logic_vector(9 downto 0) := "1111110111";
      PCIE_REQUEST_LENGTH     : std_logic_vector(9 downto 0) := "0000100000";
      RX_FIFO_DEPTH           : natural := 1024; 
      RX_LPM_WIDTHU           : natural := 10;
      TX_HEADER_FIFO_DEPTH    : natural := 32;   
      TX_HEADER_LPM_WIDTHU    : natural := 5;
      TX_DATA_FIFO_DEPTH      : natural := 1024; 
      TX_DATA_LPM_WIDTHU      : natural := 10
   );
   port(
      clk                     : in  std_logic;
      wb_clk                  : in  std_logic;
      clk_500                 : in  std_logic;                                        -- 500 Hz clock
      rst                     : in  std_logic;
      wb_rst                  : in  std_logic;
                                
      -- IP Core                
      core_clk                : in  std_logic;
      rx_st_data0             : in  std_logic_vector(63 downto 0);
      rx_st_err0              : in  std_logic;
      rx_st_valid0            : in  std_logic;
      rx_st_sop0              : in  std_logic;
      rx_st_eop0              : in  std_logic;
      rx_st_be0               : in  std_logic_vector(7 downto 0);
      rx_st_bardec0           : in  std_logic_vector(7 downto 0);
      tx_st_ready0            : in  std_logic;
      tx_fifo_full0           : in  std_logic;
      tx_fifo_empty0          : in  std_logic;
      tx_fifo_rdptr0          : in  std_logic_vector(3 downto 0);
      tx_fifo_wrptr0          : in  std_logic_vector(3 downto 0);
      pme_to_sr               : in  std_logic;
      tl_cfg_add              : in  std_logic_vector(3 downto 0);
      tl_cfg_ctl              : in  std_logic_vector(31 downto 0);
      tl_cfg_ctl_wr           : in  std_logic;
      tl_cfg_sts              : in  std_logic_vector(52 downto 0);
      tl_cfg_sts_wr           : in  std_logic;
      app_int_ack             : in  std_logic;
      app_msi_ack             : in  std_logic;
      
      rx_st_mask0             : out std_logic;
      rx_st_ready0            : out std_logic;
      tx_st_err0              : out std_logic;
      tx_st_valid0            : out std_logic;
      tx_st_sop0              : out std_logic;
      tx_st_eop0              : out std_logic;
      tx_st_data0             : out std_logic_vector(63 downto 0);
      pme_to_cr               : out std_logic;
      app_int_sts             : out std_logic;
      app_msi_req             : out std_logic;
      app_msi_tc              : out std_logic_vector(2 downto 0);
      app_msi_num             : out std_logic_vector(4 downto 0);
      pex_msi_num             : out std_logic_vector(4 downto 0);
      
      derr_cor_ext_rcv        : in  std_logic_vector(1 downto 0);
      derr_cor_ext_rpl        : in  std_logic;
      derr_rpl                : in  std_logic;
      r2c_err0                : in  std_logic;
      cpl_err                 : out std_logic_vector(6 downto 0);
      cpl_pending             : out std_logic;
      
      -- Wishbone master
      wbm_ack                 : in  std_logic;
      wbm_dat_i               : in  std_logic_vector(31 downto 0);
      wbm_stb                 : out std_logic;
      --wbm_cyc                 : out std_logic;
      wbm_cyc_o               : out std_logic_vector(NR_OF_WB_SLAVES - 1 downto 0);    --new
      wbm_we                  : out std_logic;
      wbm_sel                 : out std_logic_vector(3 downto 0);
      wbm_adr                 : out std_logic_vector(31 downto 0);
      wbm_dat_o               : out std_logic_vector(31 downto 0);
      wbm_cti                 : out std_logic_vector(2 downto 0);
      wbm_tga                 : out std_logic;
      --wb_bar_dec              : out std_logic_vector(6 downto 0);    
      
      -- Wishbone slave
      wbs_cyc                 : in  std_logic;
      wbs_stb                 : in  std_logic;
      wbs_we                  : in  std_logic;
      wbs_sel                 : in  std_logic_vector(3 downto 0);
      wbs_adr                 : in  std_logic_vector(31 downto 0);
      wbs_dat_i               : in  std_logic_vector(31 downto 0);
      wbs_cti                 : in  std_logic_vector(2 downto 0);
      wbs_tga                 : in  std_logic;                                    -- 0: memory, 1: I/O
      wbs_ack                 : out std_logic;
      wbs_err                 : out std_logic;
      wbs_dat_o               : out std_logic_vector(31 downto 0);
      
      -- interrupt
      wb_int                  : in  std_logic;
      wb_pwr_enable           : in  std_logic;
      wb_int_num              : in  std_logic_vector(4 downto 0);
      wb_int_ack              : out std_logic;
      wb_int_num_allowed      : out std_logic_vector(5 downto 0);
      
      -- error
      error_timeout           : out std_logic;
      error_cor_ext_rcv       : out std_logic_vector(1 downto 0);
      error_cor_ext_rpl       : out std_logic;
      error_rpl               : out std_logic;
      error_r2c0              : out std_logic;
      error_msi_num           : out std_logic;
      
      -- debug port
      rx_debug_out            : out std_logic_vector(3 downto 0)
   );
end component;

component hard_ip_x1 
    generic(
      VENDOR_ID           : natural := 16#1A88#;
      DEVICE_ID           : natural := 16#4D45#;
      REVISION_ID         : natural := 16#0#;
      CLASS_CODE          : natural := 16#068000#;
      SUBSYSTEM_VENDOR_ID : natural := 16#9B#;
      SUBSYSTEM_DEVICE_ID : natural := 16#5A91#;

      IO_SPACE_BAR_0  : string  := "false";
      PREFETCH_BAR_0  : string  := "true";
      SIZE_MASK_BAR_0 : natural := 28;
      
      IO_SPACE_BAR_1  : string  := "false";
      PREFETCH_BAR_1  : string  := "true";
      SIZE_MASK_BAR_1 : natural := 18;
      
      IO_SPACE_BAR_2  : string  := "false";
      PREFETCH_BAR_2  : string  := "false";
      SIZE_MASK_BAR_2 : natural := 19;
      
      IO_SPACE_BAR_3  : string  := "false";
      PREFETCH_BAR_3  : string  := "false";
      SIZE_MASK_BAR_3 : natural := 7;
      
      IO_SPACE_BAR_4  : string  := "true";
      PREFETCH_BAR_4  : string  := "false";
      SIZE_MASK_BAR_4 : natural := 5;
      
      IO_SPACE_BAR_5  : string  := "true";
      PREFETCH_BAR_5  : string  := "false";
      SIZE_MASK_BAR_5 : natural := 6      
   );
   port (
      -- inputs:
      signal app_int_sts : IN STD_LOGIC;
      signal app_msi_num : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
      signal app_msi_req : IN STD_LOGIC;
      signal app_msi_tc : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      signal busy_altgxb_reconfig : IN STD_LOGIC;
      signal cal_blk_clk : IN STD_LOGIC;
      signal cpl_err : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
      signal cpl_pending : IN STD_LOGIC;
      signal crst : IN STD_LOGIC;
      signal fixedclk_serdes : IN STD_LOGIC;
      signal gxb_powerdown : IN STD_LOGIC;
      signal hpg_ctrler : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
      signal lmi_addr : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
      signal lmi_din : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      signal lmi_rden : IN STD_LOGIC;
      signal lmi_wren : IN STD_LOGIC;
      signal npor : IN STD_LOGIC;
      signal pclk_in : IN STD_LOGIC;
      signal pex_msi_num : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
      signal phystatus_ext : IN STD_LOGIC;
      signal pipe_mode : IN STD_LOGIC;
      signal pld_clk : IN STD_LOGIC;
      signal pll_powerdown : IN STD_LOGIC;
      signal pm_auxpwr : IN STD_LOGIC;
      signal pm_data : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
      signal pm_event : IN STD_LOGIC;
      signal pme_to_cr : IN STD_LOGIC;
      signal reconfig_clk : IN STD_LOGIC;
      signal reconfig_togxb : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      signal refclk : IN STD_LOGIC;
      signal rx_in0 : IN STD_LOGIC;
      signal rx_st_mask0 : IN STD_LOGIC;
      signal rx_st_ready0 : IN STD_LOGIC;
      signal rxdata0_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      signal rxdatak0_ext : IN STD_LOGIC;
      signal rxelecidle0_ext : IN STD_LOGIC;
      signal rxstatus0_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      signal rxvalid0_ext : IN STD_LOGIC;
      signal srst : IN STD_LOGIC;
      signal test_in : IN STD_LOGIC_VECTOR (39 DOWNTO 0);
      signal tx_st_data0 : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
      signal tx_st_eop0 : IN STD_LOGIC;
      signal tx_st_err0 : IN STD_LOGIC;
      signal tx_st_sop0 : IN STD_LOGIC;
      signal tx_st_valid0 : IN STD_LOGIC;

      -- outputs:
      signal app_clk : OUT STD_LOGIC;
      signal app_int_ack : OUT STD_LOGIC;
      signal app_msi_ack : OUT STD_LOGIC;
      signal clk250_out : OUT STD_LOGIC;
      signal clk500_out : OUT STD_LOGIC;
      signal core_clk_out : OUT STD_LOGIC;
      signal derr_cor_ext_rcv0 : OUT STD_LOGIC;
      signal derr_cor_ext_rpl : OUT STD_LOGIC;
      signal derr_rpl : OUT STD_LOGIC;
      signal dlup_exit : OUT STD_LOGIC;
      signal hotrst_exit : OUT STD_LOGIC;
      signal ko_cpl_spc_vc0 : OUT STD_LOGIC_VECTOR (19 DOWNTO 0);
      signal l2_exit : OUT STD_LOGIC;
      signal lane_act : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
      signal lmi_ack : OUT STD_LOGIC;
      signal lmi_dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
      signal ltssm : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
      signal pme_to_sr : OUT STD_LOGIC;
      signal powerdown_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
      signal r2c_err0 : OUT STD_LOGIC;
      signal rate_ext : OUT STD_LOGIC;
      signal rc_pll_locked : OUT STD_LOGIC;
      signal rc_rx_digitalreset : OUT STD_LOGIC;
      signal reconfig_fromgxb : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
      signal reset_status : OUT STD_LOGIC;
      signal rx_fifo_empty0 : OUT STD_LOGIC;
      signal rx_fifo_full0 : OUT STD_LOGIC;
      signal rx_st_bardec0 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      signal rx_st_be0 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      signal rx_st_data0 : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
      signal rx_st_eop0 : OUT STD_LOGIC;
      signal rx_st_err0 : OUT STD_LOGIC;
      signal rx_st_sop0 : OUT STD_LOGIC;
      signal rx_st_valid0 : OUT STD_LOGIC;
      signal rxpolarity0_ext : OUT STD_LOGIC;
      signal suc_spd_neg : OUT STD_LOGIC;
      signal test_out : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
      signal tl_cfg_add : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
      signal tl_cfg_ctl : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
      signal tl_cfg_ctl_wr : OUT STD_LOGIC;
      signal tl_cfg_sts : OUT STD_LOGIC_VECTOR (52 DOWNTO 0);
      signal tl_cfg_sts_wr : OUT STD_LOGIC;
      signal tx_cred0 : OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
      signal tx_fifo_empty0 : OUT STD_LOGIC;
      signal tx_fifo_full0 : OUT STD_LOGIC;
      signal tx_fifo_rdptr0 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
      signal tx_fifo_wrptr0 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
      signal tx_out0 : OUT STD_LOGIC;
      signal tx_st_ready0 : OUT STD_LOGIC;
      signal txcompl0_ext : OUT STD_LOGIC;
      signal txdata0_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      signal txdatak0_ext : OUT STD_LOGIC;
      signal txdetectrx_ext : OUT STD_LOGIC;
      signal txelecidle0_ext : OUT STD_LOGIC
   );
end component;
--component z091_01_wb_adr_dec
--   generic(
--      NR_OF_WB_SLAVES : integer range 63 downto 1 := 1
--   );
--   port (
--      pci_cyc_i       : in  std_logic_vector(6 downto 0);
--      wbm_adr_o_q     : in  std_logic_vector(31 downto 2);
--
--      wbm_cyc_o       : out std_logic_vector(NR_OF_WB_SLAVES -1 downto 0)
--   );
--end component;

component alt_reconf
   port(
      reconfig_clk     : in  std_logic;
      reconfig_fromgxb : in  std_logic_vector (4 downto 0);
      busy             : out std_logic;
      reconfig_togxb   : out std_logic_vector (3 downto 0)
   );
end component;

---------------------------------------
-- module to convert irq_req_i vector
-- to 16z091-01 irq behavior
---------------------------------------
component pcie_msi
   generic (
      WIDTH                : integer range 32 downto 1 
   );
   port (
      clk_i                : in  std_logic;
      rst_i                : in  std_logic;
     
      irq_req_i            : in  std_logic_vector(WIDTH -1 downto 0);
      
      wb_int_o             : out std_logic;
      wb_pwr_enable_o      : out std_logic;
      wb_int_num_o         : OUT std_logic_vector(4 downto 0);
      wb_int_ack_i         : in  std_logic;
      wb_int_num_allowed_i : in  std_logic_vector(5 downto 0)
   );
end component;
-------------------------------------------------------------------------------

begin
   -- coverage off
   assert not no_valid_device(supported_devices => SUPPORTED_DEVICES, device => FPGA_FAMILY) report "16z091-01: no valid FPGA device selected" severity failure;
   assert (USE_LANES = "001") report "Z91-01: no valid USE_LANES setting" severity failure; 
   -- coverage on

   --wbm_cyc_o         <= wbm_cyc_o_int;     
   npor_int          <= ext_rst_n and '1';
   pll_powerdown_int <= not npor_int;

   ----------------------------------
   -- assign debug port if ltssm is
   -- in link training mode
   ----------------------------------
   link_train_active <= '0' when int_ltssm = "01111" else
                        '1';
   -------------------------------------------------
   -- work around for Altera receiver detect issue
   -------------------------------------------------
   pipe_mode_int            <= '0';                                               -- use serial mode
   test_in_int(39 downto 4) <= (others => '0');
   test_in_int(3)           <= not pipe_mode_int;
   test_in_int(2 downto 1)  <= (others => '0');
   --------------------------------------------
   -- speed up initialization for simulation:
   --------------------------------------------
   test_in_int(0)           <= SIMULATION;
   
   -- instanciate components
   ip_16z091_01_comp : ip_16z091_01
      generic map(
         FPGA_FAMILY             => FPGA_FAMILY,
         NR_OF_WB_SLAVES         => NR_OF_WB_SLAVES,
         READY_LATENCY           => 2,
         FIFO_MAX_USEDW          => conv_std_logic_vector((2**RX_LPM_WIDTHU - 8),10),
         WBM_SUSPEND_FIFO_ACCESS => conv_std_logic_vector((2**TX_DATA_LPM_WIDTHU - 5),10),
         WBM_RESUME_FIFO_ACCESS  => conv_std_logic_vector((2**TX_DATA_LPM_WIDTHU - 9),10),
         WBS_SUSPEND_FIFO_ACCESS => conv_std_logic_vector((2**TX_DATA_LPM_WIDTHU - 4),10),
         WBS_RESUME_FIFO_ACCESS  => conv_std_logic_vector((2**TX_DATA_LPM_WIDTHU - 9),10),
         PCIE_REQUEST_LENGTH     => PCIE_REQUEST_LENGTH,
         RX_FIFO_DEPTH           => 2**RX_LPM_WIDTHU,
         RX_LPM_WIDTHU           => RX_LPM_WIDTHU,
         TX_HEADER_FIFO_DEPTH    => 2**TX_HEADER_LPM_WIDTHU,
         TX_HEADER_LPM_WIDTHU    => TX_HEADER_LPM_WIDTHU,
         TX_DATA_FIFO_DEPTH      => 2**TX_DATA_LPM_WIDTHU,
         TX_DATA_LPM_WIDTHU      => TX_DATA_LPM_WIDTHU
      )
      port map(
         clk                     => core_clk_int,
         rst                     => rst_int,
         clk_500                 => clk_500,
         wb_clk                  => wb_clk,
         wb_rst                  => wb_rst,
                                   
         -- IP Core                
         core_clk                => core_clk_int,
         rx_st_data0             => rx_st_data0_int,
         rx_st_err0              => rx_st_err0_int,
         rx_st_valid0            => rx_st_valid0_int,
         rx_st_sop0              => rx_st_sop0_int,
         rx_st_eop0              => rx_st_eop0_int,
         rx_st_be0               => rx_st_be0_int,
         rx_st_bardec0           => rx_st_bardec0_int,
         tx_st_ready0            => tx_st_ready0_int,
         tx_fifo_full0           => tx_fifo_full0_int,
         tx_fifo_empty0          => tx_fifo_empty0_int,
         tx_fifo_rdptr0          => tx_fifo_rdptr0_int,
         tx_fifo_wrptr0          => tx_fifo_wrptr0_int,
         pme_to_sr               => pme_to_sr_int,
         tl_cfg_add              => tl_cfg_add_int,
         tl_cfg_ctl              => tl_cfg_ctl_int,
         tl_cfg_ctl_wr           => tl_cfg_ctl_wr_int,
         tl_cfg_sts              => tl_cfg_sts_int,
         tl_cfg_sts_wr           => tl_cfg_sts_wr_int,
         app_int_ack             => app_int_ack_int,
         app_msi_ack             => app_msi_ack_int,
         
         rx_st_mask0             => rx_st_mask0_int,
         rx_st_ready0            => rx_st_ready0_int,
         tx_st_err0              => tx_st_err0_int,
         tx_st_valid0            => tx_st_valid0_int,
         tx_st_sop0              => tx_st_sop0_int,
         tx_st_eop0              => tx_st_eop0_int,
         tx_st_data0             => tx_st_data0_int,
         pme_to_cr               => pme_to_cr_int,
         app_int_sts             => app_int_sts_int,
         app_msi_req             => app_msi_req_int,
         app_msi_tc              => app_msi_tc_int,
         app_msi_num             => app_msi_num_int,
         pex_msi_num             => pex_msi_num_int,
         
         derr_cor_ext_rcv        => derr_cor_ext_rcv_int,
         derr_cor_ext_rpl        => derr_cor_ext_rpl_int,
         derr_rpl                => derr_rpl_int,
         r2c_err0                => r2c_err0_int,
         cpl_err                 => cpl_err_int,
         cpl_pending             => cpl_pending_int,
         
         -- Wishbone master
         wbm_ack                 => wbm_ack,
         wbm_dat_i               => wbm_dat_i,
         wbm_stb                 => wbm_stb,
         --wbm_cyc                 => OPEN,
         wbm_cyc_o               => wbm_cyc_o,
         wbm_we                  => wbm_we,
         wbm_sel                 => wbm_sel,
         wbm_adr                 => wbm_adr,
         wbm_dat_o               => wbm_dat_o,
         wbm_cti                 => wbm_cti,
         wbm_tga                 => wbm_tga,
         --wb_bar_dec              => int_bar_hit,   
         
         -- Wishbone slave
         wbs_cyc                 => wbs_cyc,
         wbs_stb                 => wbs_stb,
         wbs_we                  => wbs_we,
         wbs_sel                 => wbs_sel,
         wbs_adr                 => wbs_adr,
         wbs_dat_i               => wbs_dat_i,
         wbs_cti                 => wbs_cti,
         wbs_tga                 => wbs_tga,
         wbs_ack                 => wbs_ack,
         wbs_err                 => wbs_err,
         wbs_dat_o               => wbs_dat_o,
         
         -- interrupt
         wb_int                  => int_wb_int,
         wb_pwr_enable           => int_wb_pwr_enable,
         wb_int_num              => int_wb_int_num,
         wb_int_ack              => int_wb_int_ack,
         wb_int_num_allowed      => int_wb_int_num_allowed,
         
         -- error
         error_timeout           => error_timeout,
         error_cor_ext_rcv       => error_cor_ext_rcv,
         error_cor_ext_rpl       => error_cor_ext_rpl,
         error_rpl               => error_rpl,
         error_r2c0              => error_r2c0,
         error_msi_num           => error_msi_num,
         
         -- debug port
         rx_debug_out            => open
      );

   
--   gen_x4: if USE_LANES = "100" generate
--    Hard_IP_x4_comp : entity work.Hard_IP_x4
--      generic map(
--         VENDOR_ID           => VENDOR_ID,
--         DEVICE_ID           => DEVICE_ID,
--         REVISION_ID         => REVISION_ID,
--         CLASS_CODE          => CLASS_CODE,
--         SUBSYSTEM_VENDOR_ID => SUBSYSTEM_VENDOR_ID,
--         SUBSYSTEM_DEVICE_ID => SUBSYSTEM_DEVICE_ID,
--
--         IO_SPACE_BAR_0  => IO_SPACE_0,      -- IO_SPACE_BAR_0,
--         PREFETCH_BAR_0  => PREFETCH_0,      -- PREFETCH_BAR_0,
--         SIZE_MASK_BAR_0 => SIZE_MASK_0,     -- SIZE_MASK_BAR_0,
--         
--         IO_SPACE_BAR_1  => IO_SPACE_1,      -- IO_SPACE_BAR_1,
--         PREFETCH_BAR_1  => PREFETCH_1,      -- PREFETCH_BAR_1,
--         SIZE_MASK_BAR_1 => SIZE_MASK_1,     -- SIZE_MASK_BAR_1,
--         
--         IO_SPACE_BAR_2  => IO_SPACE_2,      -- IO_SPACE_BAR_2,
--         PREFETCH_BAR_2  => PREFETCH_2,      -- PREFETCH_BAR_2,
--         SIZE_MASK_BAR_2 => SIZE_MASK_2,     -- SIZE_MASK_BAR_2,
--         
--         IO_SPACE_BAR_3  => IO_SPACE_3,      -- IO_SPACE_BAR_3,
--         PREFETCH_BAR_3  => PREFETCH_3,      -- PREFETCH_BAR_3,
--         SIZE_MASK_BAR_3 => SIZE_MASK_3,     -- SIZE_MASK_BAR_3,
--         
--         IO_SPACE_BAR_4  => IO_SPACE_4,      -- IO_SPACE_BAR_4,
--         PREFETCH_BAR_4  => PREFETCH_4,      -- PREFETCH_BAR_4,
--         SIZE_MASK_BAR_4 => SIZE_MASK_4,     -- SIZE_MASK_BAR_4,
--         
--         IO_SPACE_BAR_5  => IO_SPACE_5,      -- IO_SPACE_BAR_5,
--         PREFETCH_BAR_5  => PREFETCH_5,      -- PREFETCH_BAR_5, 
--         SIZE_MASK_BAR_5 => SIZE_MASK_5      -- SIZE_MASK_BAR_5 
--      )
--
--      port map(
--         -- inputs:
--         app_int_sts     => app_int_sts_int,
--         app_msi_num     => app_msi_num_int,
--         app_msi_req     => app_msi_req_int,
--         app_msi_tc      => app_msi_tc_int,
--         cal_blk_clk     => clk_50,
--         cpl_err         => cpl_err_int,
--         cpl_pending     => cpl_pending_int,
--         crst            => crst_int,
--         gxb_powerdown   => '0',
--         hpg_ctrler      => (others => '0'),
--         lmi_addr        => (others => '0'),
--         lmi_din         => (others => '0'),
--         lmi_rden        => '0',
--         lmi_wren        => '0',
--         npor            => '1', --ext_rst_n, --'0',
--         pclk_in         => core_clk_int,
--         pex_msi_num     => pex_msi_num_int,
--         phystatus_ext   => '0',
--         pipe_mode       => '0',
--         pld_clk         => core_clk_int,
--         pll_powerdown   => '0',
--         pm_auxpwr       => '0',
--         pm_data         => (others => '0'),
--         pm_event        => '0',
--         pme_to_cr       => pme_to_cr_int,
--         reconfig_clk    => clk_50,
--         reconfig_togxb  => reconfig_togxb_int,
--         refclk          => ref_clk,
--         rx_in0          => rx_0,
--         rx_in1          => rx_1,
--         rx_in2          => rx_2,
--         rx_in3          => rx_3,
--         rx_st_mask0     => rx_st_mask0_int,
--         rx_st_ready0    => rx_st_ready0_int,
--         rxdata0_ext     => (others => '0'),
--         rxdata1_ext     => (others => '0'),
--         rxdata2_ext     => (others => '0'),
--         rxdata3_ext     => (others => '0'),
--         rxdatak0_ext    => '0',
--         rxdatak1_ext    => '0',
--         rxdatak2_ext    => '0',
--         rxdatak3_ext    => '0',
--         rxelecidle0_ext => '0',
--         rxelecidle1_ext => '0',
--         rxelecidle2_ext => '0',
--         rxelecidle3_ext => '0',
--         rxstatus0_ext   => (others => '0'),
--         rxstatus1_ext   => (others => '0'),
--         rxstatus2_ext   => (others => '0'),
--         rxstatus3_ext   => (others => '0'),
--         rxvalid0_ext    => '0',
--         rxvalid1_ext    => '0',
--         rxvalid2_ext    => '0',
--         rxvalid3_ext    => '0',
--         srst            => srst_int,
--         test_in         => (others => '0'),
--         tx_st_data0     => tx_st_data0_int,
--         tx_st_eop0      => tx_st_eop0_int,
--         tx_st_err0      => tx_st_err0_int,
--         tx_st_sop0      => tx_st_sop0_int,
--         tx_st_valid0    => tx_st_valid0_int,
--
--         -- outputs:
--         app_int_ack       => app_int_ack_int,
--         app_msi_ack       => app_msi_ack_int,
--         clk250_out        => open,
--         clk500_out        => open,
--         core_clk_out      => core_clk_int,
--         derr_cor_ext_rcv0 => derr_cor_ext_rcv_int(0),
--         derr_cor_ext_rpl  => derr_cor_ext_rpl_int,
--         derr_rpl          => derr_rpl_int,
--         dlup_exit         => open,
--         hotrst_exit       => open,
--         ko_cpl_spc_vc0    => open,
--         l2_exit           => open,
--         lane_act          => open,
--         lmi_ack           => open,
--         lmi_dout          => open,
--         ltssm             => open,
--         pme_to_sr         => pme_to_sr_int,
--         powerdown_ext     => open,
--         r2c_err0          => r2c_err0_int,
--         rate_ext          => open,
--         rc_pll_locked     => open,
--         reconfig_fromgxb  => reconfig_fromgxb_int,
--         reset_status      => open,
--         rx_fifo_empty0    => open,
--         rx_fifo_full0     => open,
--         rx_st_bardec0     => rx_st_bardec0_int,
--         rx_st_be0         => rx_st_be0_int,
--         rx_st_data0       => rx_st_data0_int,
--         rx_st_eop0        => rx_st_eop0_int,
--         rx_st_err0        => rx_st_err0_int,
--         rx_st_sop0        => rx_st_sop0_int,
--         rx_st_valid0      => rx_st_valid0_int,
--         rxpolarity0_ext   => open,
--         rxpolarity1_ext   => open,
--         rxpolarity2_ext   => open,
--         rxpolarity3_ext   => open,
--         suc_spd_neg       => open,
--         test_out          => open,
--         tl_cfg_add        => tl_cfg_add_int,
--         tl_cfg_ctl        => tl_cfg_ctl_int,
--         tl_cfg_ctl_wr     => tl_cfg_ctl_wr_int,
--         tl_cfg_sts        => tl_cfg_sts_int,
--         tl_cfg_sts_wr     => tl_cfg_sts_wr_int,
--         tx_cred0          => open,
--         tx_fifo_empty0    => tx_fifo_empty0_int,
--         tx_fifo_full0     => tx_fifo_full0_int,
--         tx_fifo_rdptr0    => tx_fifo_rdptr0_int,
--         tx_fifo_wrptr0    => tx_fifo_wrptr0_int,
--         tx_out0           => tx_0,
--         tx_out1           => tx_1,
--         tx_out2           => tx_2,
--         tx_out3           => tx_3,
--         tx_st_ready0      => tx_st_ready0_int,
--         txcompl0_ext      => open,
--         txcompl1_ext      => open,
--         txcompl2_ext      => open,
--         txcompl3_ext      => open,
--         txdata0_ext       => open,
--         txdata1_ext       => open,
--         txdata2_ext       => open,
--         txdata3_ext       => open,
--         txdatak0_ext      => open,
--         txdatak1_ext      => open,
--         txdatak2_ext      => open,
--         txdatak3_ext      => open,
--         txdetectrx_ext    => open,
--         txelecidle0_ext   => open,
--         txelecidle1_ext   => open,
--         txelecidle2_ext   => open,
--         txelecidle3_ext   => open
--      );
--   end generate gen_x4;
      
--   gen_x2: if USE_LANES = "010" generate
--    Hard_IP_x2_comp : entity work.Hard_IP_x2
--      generic map(
--         VENDOR_ID           => VENDOR_ID,
--         DEVICE_ID           => DEVICE_ID,
--         REVISION_ID         => REVISION_ID,
--         CLASS_CODE          => CLASS_CODE,
--         SUBSYSTEM_VENDOR_ID => SUBSYSTEM_VENDOR_ID,
--         SUBSYSTEM_DEVICE_ID => SUBSYSTEM_DEVICE_ID,
--
--         IO_SPACE_BAR_0  => IO_SPACE_0,      -- IO_SPACE_BAR_0,
--         PREFETCH_BAR_0  => PREFETCH_0,      -- PREFETCH_BAR_0,
--         SIZE_MASK_BAR_0 => SIZE_MASK_0,     -- SIZE_MASK_BAR_0,
--         
--         IO_SPACE_BAR_1  => IO_SPACE_1,      -- IO_SPACE_BAR_1,
--         PREFETCH_BAR_1  => PREFETCH_1,      -- PREFETCH_BAR_1,
--         SIZE_MASK_BAR_1 => SIZE_MASK_1,     -- SIZE_MASK_BAR_1,
--         
--         IO_SPACE_BAR_2  => IO_SPACE_2,      -- IO_SPACE_BAR_2,
--         PREFETCH_BAR_2  => PREFETCH_2,      -- PREFETCH_BAR_2,
--         SIZE_MASK_BAR_2 => SIZE_MASK_2,     -- SIZE_MASK_BAR_2,
--         
--         IO_SPACE_BAR_3  => IO_SPACE_3,      -- IO_SPACE_BAR_3,
--         PREFETCH_BAR_3  => PREFETCH_3,      -- PREFETCH_BAR_3,
--         SIZE_MASK_BAR_3 => SIZE_MASK_3,     -- SIZE_MASK_BAR_3,
--         
--         IO_SPACE_BAR_4  => IO_SPACE_4,      -- IO_SPACE_BAR_4,
--         PREFETCH_BAR_4  => PREFETCH_4,      -- PREFETCH_BAR_4,
--         SIZE_MASK_BAR_4 => SIZE_MASK_4,     -- SIZE_MASK_BAR_4,
--         
--         IO_SPACE_BAR_5  => IO_SPACE_5,      -- IO_SPACE_BAR_5,
--         PREFETCH_BAR_5  => PREFETCH_5,      -- PREFETCH_BAR_5,
--         SIZE_MASK_BAR_5 => SIZE_MASK_5      -- SIZE_MASK_BAR_5
--      )
--      port map(
--         -- inputs:
--         app_int_sts       => app_int_sts_int,
--         app_msi_num       => app_msi_num_int,
--         app_msi_req       => app_msi_req_int,
--         app_msi_tc        => app_msi_tc_int,
--         cal_blk_clk       => clk_50,
--         cpl_err           => cpl_err_int,
--         cpl_pending       => cpl_pending_int,
--         crst              => crst_int,
--         gxb_powerdown     => '0',
--         hpg_ctrler        => (others => '0'),
--         lmi_addr          => (others => '0'),
--         lmi_din           => (others => '0'),
--         lmi_rden          => '0',
--         lmi_wren          => '0',
--         npor              => '1', --ext_rst_n,   --'0',
--         pclk_in           => core_clk_int,
--         pex_msi_num       => pex_msi_num_int,
--         phystatus_ext     => '0',
--         pipe_mode         => '0',
--         pld_clk           => core_clk_int,
--         pll_powerdown     => '0',
--         pm_auxpwr         => '0',
--         pm_data           => (others => '0'),
--         pm_event          => '0',
--         pme_to_cr         => pme_to_cr_int,
--         reconfig_clk      => clk_50,
--         reconfig_togxb    => reconfig_togxb_int,
--         refclk            => ref_clk,
--         rx_in0            => rx_0,
--         rx_in1            => rx_1,
--         rx_st_mask0       => rx_st_mask0_int,
--         rx_st_ready0      => rx_st_ready0_int,
--         rxdata0_ext       => (others => '0'),
--         rxdata1_ext       => (others => '0'),
--         rxdatak0_ext      => '0',
--         rxdatak1_ext      => '0',
--         rxelecidle0_ext   => '0',
--         rxelecidle1_ext   => '0',
--         rxstatus0_ext     => (others => '0'),
--         rxstatus1_ext     => (others => '0'),
--         rxvalid0_ext      => '0',
--         rxvalid1_ext      => '0',
--         srst              => srst_int,
--         test_in           => (others => '0'),
--         tx_st_data0       => tx_st_data0_int,
--         tx_st_eop0        => tx_st_eop0_int,
--         tx_st_err0        => tx_st_err0_int,
--         tx_st_sop0        => tx_st_sop0_int,
--         tx_st_valid0      => tx_st_valid0_int,
--
--         -- outputs:
--         app_int_ack       => app_int_ack_int,
--         app_msi_ack       => app_msi_ack_int,
--         clk250_out        => open,
--         clk500_out        => open,
--         core_clk_out      => core_clk_int,
--         derr_cor_ext_rcv0 => derr_cor_ext_rcv_int(0),
--         derr_cor_ext_rpl  => derr_cor_ext_rpl_int,
--         derr_rpl          => derr_rpl_int,
--         dlup_exit         => open,
--         hotrst_exit       => open,
--         ko_cpl_spc_vc0    => open,
--         l2_exit           => open,
--         lane_act          => open,
--         lmi_ack           => open,
--         lmi_dout          => open,
--         ltssm             => open,
--         pme_to_sr         => pme_to_sr_int,
--         powerdown_ext     => open,
--         r2c_err0          => r2c_err0_int,
--         rate_ext          => open,
--         rc_pll_locked     => open,
--         reconfig_fromgxb  => reconfig_fromgxb_int,
--         reset_status      => open,
--         rx_fifo_empty0    => open,
--         rx_fifo_full0     => open,
--         rx_st_bardec0     => rx_st_bardec0_int,
--         rx_st_be0         => rx_st_be0_int,
--         rx_st_data0       => rx_st_data0_int,
--         rx_st_eop0        => rx_st_eop0_int,
--         rx_st_err0        => rx_st_err0_int,
--         rx_st_sop0        => rx_st_sop0_int,
--         rx_st_valid0      => rx_st_valid0_int,
--         rxpolarity0_ext   => open,
--         rxpolarity1_ext   => open,
--         suc_spd_neg       => open,
--         test_out          => open,
--         tl_cfg_add        => tl_cfg_add_int,
--         tl_cfg_ctl        => tl_cfg_ctl_int,
--         tl_cfg_ctl_wr     => tl_cfg_ctl_wr_int,
--         tl_cfg_sts        => tl_cfg_sts_int,
--         tl_cfg_sts_wr     => tl_cfg_sts_wr_int,
--         tx_cred0          => open,
--         tx_fifo_empty0    => tx_fifo_empty0_int,
--         tx_fifo_full0     => tx_fifo_full0_int,
--         tx_fifo_rdptr0    => tx_fifo_rdptr0_int,
--         tx_fifo_wrptr0    => tx_fifo_wrptr0_int,
--         tx_out0           => tx_0,
--         tx_out1           => tx_1,
--         tx_st_ready0      => tx_st_ready0_int,
--         txcompl0_ext      => open,
--         txcompl1_ext      => open,
--         txdata0_ext       => open,
--         txdata1_ext       => open,
--         txdatak0_ext      => open,
--         txdatak1_ext      => open,
--         txdetectrx_ext    => open,
--         txelecidle0_ext   => open,
--         txelecidle1_ext   => open
--      );
--   tx_2 <= '1';
--   tx_3 <= '1';
--   end generate gen_x2;
   
   gen_x1: if USE_LANES = "001" generate
      Hard_IP_x1_comp : Hard_IP_x1
      generic map(
         VENDOR_ID            => VENDOR_ID,
         DEVICE_ID            => DEVICE_ID,
         REVISION_ID          => REVISION_ID,
         CLASS_CODE           => CLASS_CODE,
         SUBSYSTEM_VENDOR_ID  => SUBSYSTEM_VENDOR_ID,
         SUBSYSTEM_DEVICE_ID  => SUBSYSTEM_DEVICE_ID,

         IO_SPACE_BAR_0       => IO_SPACE_0,
         PREFETCH_BAR_0       => PREFETCH_0,
         SIZE_MASK_BAR_0      => SIZE_MASK_0,
         
         IO_SPACE_BAR_1       => IO_SPACE_1,
         PREFETCH_BAR_1       => PREFETCH_1,
         SIZE_MASK_BAR_1      => SIZE_MASK_1,
         
         IO_SPACE_BAR_2       => IO_SPACE_2,
         PREFETCH_BAR_2       => PREFETCH_2,
         SIZE_MASK_BAR_2      => SIZE_MASK_2,
         
         IO_SPACE_BAR_3       => IO_SPACE_3,
         PREFETCH_BAR_3       => PREFETCH_3,
         SIZE_MASK_BAR_3      => SIZE_MASK_3,
         
         IO_SPACE_BAR_4       => IO_SPACE_4,
         PREFETCH_BAR_4       => PREFETCH_4,
         SIZE_MASK_BAR_4      => SIZE_MASK_4,
         
         IO_SPACE_BAR_5       => IO_SPACE_5,
         PREFETCH_BAR_5       => PREFETCH_5,
         SIZE_MASK_BAR_5      => SIZE_MASK_5
      )
      port map(
         app_int_sts          => app_int_sts_int,
         app_msi_num          => app_msi_num_int,
         app_msi_req          => app_msi_req_int,
         app_msi_tc           => app_msi_tc_int,
         busy_altgxb_reconfig => reconf_busy,
         cal_blk_clk          => clk_50,
         cpl_err              => cpl_err_int,
         cpl_pending          => cpl_pending_int,
         crst                 => crst_int,
         fixedclk_serdes      => clk_125,
         gxb_powerdown        => '0',
         hpg_ctrler           => (others => '0'),
         lmi_addr             => (others => '0'),
         lmi_din              => (others => '0'),
         lmi_rden             => '0',
         lmi_wren             => '0',
         npor                 => npor_int,
         pclk_in              => core_clk_int,
         pex_msi_num          => pex_msi_num_int,
         phystatus_ext        => '0',
         pipe_mode            => pipe_mode_int,
         pld_clk              => core_clk_int,
         pll_powerdown        => pll_powerdown_int,
         pm_auxpwr            => '0',
         pm_data              => (others => '0'),
         pm_event             => '0',
         pme_to_cr            => pme_to_cr_int,
         reconfig_clk         => clk_50,
         reconfig_togxb       => reconfig_togxb_int,
         refclk               => ref_clk,
         rx_in0               => rx_0,
         rx_st_mask0          => rx_st_mask0_int,
         rx_st_ready0         => rx_st_ready0_int,
         rxdata0_ext          => (others => '0'),
         rxdatak0_ext         => '0',
         rxelecidle0_ext      => '0',
         rxstatus0_ext        => (others => '0'),
         rxvalid0_ext         => '0',
         srst                 => srst_int,
         test_in              => test_in_int,
         tx_st_data0          => tx_st_data0_int,
         tx_st_eop0           => tx_st_eop0_int,
         tx_st_err0           => tx_st_err0_int,
         tx_st_sop0           => tx_st_sop0_int,
         tx_st_valid0         => tx_st_valid0_int,

         -- outputs:
         app_clk              => open,
         app_int_ack          => app_int_ack_int,
         app_msi_ack          => app_msi_ack_int,
         clk250_out           => open,
         clk500_out           => open,
         core_clk_out         => core_clk_int,
         derr_cor_ext_rcv0    => derr_cor_ext_rcv_int(0),
         derr_cor_ext_rpl     => derr_cor_ext_rpl_int,
         derr_rpl             => derr_rpl_int,
         dlup_exit            => dlup_exit,
         hotrst_exit          => hotrst_exit,
         ko_cpl_spc_vc0       => open,
         l2_exit              => l2_exit,
         lane_act             => open,
         lmi_ack              => open,
         lmi_dout             => open,
         ltssm                => int_ltssm,
         pme_to_sr            => pme_to_sr_int,
         powerdown_ext        => open,
         r2c_err0             => r2c_err0_int,
         rate_ext             => open,
         rc_pll_locked        => open,
         rc_rx_digitalreset   => open,
         reconfig_fromgxb     => reconfig_fromgxb_int,
         reset_status         => open,
         rx_fifo_empty0       => open,
         rx_fifo_full0        => open,
         rx_st_bardec0        => rx_st_bardec0_int,
         rx_st_be0            => rx_st_be0_int,
         rx_st_data0          => rx_st_data0_int,
         rx_st_eop0           => rx_st_eop0_int,
         rx_st_err0           => rx_st_err0_int,
         rx_st_sop0           => rx_st_sop0_int,
         rx_st_valid0         => rx_st_valid0_int,
         rxpolarity0_ext      => open,
         suc_spd_neg          => open,
         test_out             => open,
         tl_cfg_add           => tl_cfg_add_int,
         tl_cfg_ctl           => tl_cfg_ctl_int,
         tl_cfg_ctl_wr        => tl_cfg_ctl_wr_int,
         tl_cfg_sts           => tl_cfg_sts_int,
         tl_cfg_sts_wr        => tl_cfg_sts_wr_int,
         tx_cred0             => open,
         tx_fifo_empty0       => tx_fifo_empty0_int,
         tx_fifo_full0        => tx_fifo_full0_int,
         tx_fifo_rdptr0       => tx_fifo_rdptr0_int,
         tx_fifo_wrptr0       => tx_fifo_wrptr0_int,
         tx_out0              => tx_0,
         tx_st_ready0         => tx_st_ready0_int,
         txcompl0_ext         => open,
         txdata0_ext          => open,
         txdatak0_ext         => open,
         txdetectrx_ext       => open,
         txelecidle0_ext      => open
      );

      tx_1 <= '1';
      tx_2 <= '1';
      tx_3 <= '1';
   end generate gen_x1;
   
   --z091_01_wb_adr_dec_comp : z091_01_wb_adr_dec
   --   generic map(
   --      NR_OF_WB_SLAVES => NR_OF_WB_SLAVES
   --   )
   --   port map(
   --      pci_cyc_i       => int_bar_hit,
   --      wbm_adr_o_q     => wbm_adr_int(31 downto 2),
   --
   --      wbm_cyc_o       => wbm_cyc_o_int
   --   );
    
   --mwawrik: this process is responsible for the problem, that the cycle is longer active than acknowledge    
   --cyc_o : process(wb_rst, wb_clk)
   --begin
   --   if wb_rst = '1' then
   --      wbm_cyc_o_int_d <= (others => '0');
   --   elsif wb_clk'event and wb_clk = '1' then
   --      if wbm_ack = '1' then
   --         wbm_cyc_o_int_d <= (others=>'0');
   --      else
   --         wbm_cyc_o_int_d <= wbm_cyc_o_int;
   --      end if;
   --   end if;
   --end process cyc_o;
   ------------------------------------------------------------------------------   
   alt_reconf_comp : alt_reconf
      port map(
         reconfig_clk     => clk_50,
         reconfig_fromgxb => reconfig_fromgxb_int,
         busy             => reconf_busy,
         reconfig_togxb   => reconfig_togxb_int
      );
   
   gen_srst_crst_for_cold_warm_hot: process(rst_int,core_clk_int)
   begin
      if(rst_int = '1') then                                            -- deactivate rst_cwh during ext_rst
         rst_cwh     <= '0';
         rst_cwh_cnt <= (others => '0');
      elsif(core_clk_int'event and core_clk_int = '1') then 
         if(l2_exit = '0' or hotrst_exit = '0' or dlup_exit = '0') then -- start reset
            rst_cwh_cnt <= (others => '1');                
         elsif(rst_cwh_cnt > 0) then                                    -- count condition
            rst_cwh_cnt <= rst_cwh_cnt - 1;
         else                                                           -- stop condition
            rst_cwh_cnt <= (others => '0');                
         end if;
         if(rst_cwh_cnt = 0) then                                       -- reset if cnt > 0
            rst_cwh <= '0';
         else
            rst_cwh <= '1';
         end if;
      end if;
   end process;
   
   ---------------------------------------
   -- module to convert irq_req_i vector
   -- to 16z091-01 irq behavior
   ---------------------------------------
   pcie_msi_i0 : pcie_msi
      generic map(
         WIDTH                => IRQ_WIDTH
      )
      port map(
         clk_i                => wb_clk,
         rst_i                => wb_rst,
        
         irq_req_i            => irq_req_i,
         
         wb_int_o             => int_wb_int,
         wb_pwr_enable_o      => int_wb_pwr_enable,
         wb_int_num_o         => int_wb_int_num,
         wb_int_ack_i         => int_wb_int_ack,
         wb_int_num_allowed_i => int_wb_int_num_allowed
      );

-------------------------------------------------------------------------------     
   -- port assignement
   --wbm_adr <= wbm_adr_int;
   
   -- reset and clock logic
   rst_int  <= not ext_rst_n;
   crst_int <= rst_int or rst_cwh;
   srst_int <= rst_int or rst_cwh;
   
-------------------------------------------------------------------------------
end architecture ip_16z091_01_top_arch;




-- +----------------------------------------------------------------------------
-- | Architecture for Cyclone V
-- +----------------------------------------------------------------------------
architecture ip_16z091_01_top_cycv_arch of ip_16z091_01_top is

constant MAX_ADDR_VAL  : std_logic_vector(31 downto 0) := x"FFFFFFFF";                         -- := 2^32 - 1
constant MAX_RECONF_IF : positive range 5 downto 1 := 5;

----------------------------------------------
-- Altera changed string values for CycloneV
-- thus added Enabled/Disabled
----------------------------------------------
function conv_std_to_string(
   in_bit : std_logic
) return string is
begin
   if(in_bit = '0') then
      return "Disabled";
   else
      return "Enabled";
   end if;
end function conv_std_to_string;

function calc_mask_size(
   in_BAR_mask : std_logic_vector;
   BAR_No      : integer range 5 downto 0
) return integer is
variable in_val : std_logic_vector(31 downto 0) := (others => '0');
variable int_temp : integer := 0;
variable addr_line : integer range 32 downto 1 := 1;
begin
   if(BAR_No > NR_OF_BARS_USED - 1) then
      return 0;
   else
      ---------------------------------------------------------
      -- memory thus unmask I/O, type and prefetch bit values
      ---------------------------------------------------------
      if(in_BAR_mask(0) = '0') then
         in_val := in_BAR_mask(31 downto 4) & "0000";
      -----------------------------------------
      -- I/O thus unmask I/O and reserved bit
      -----------------------------------------
      else
         in_val := in_BAR_mask(31 downto 2) & "00";
      end if;
      
      in_val := MAX_ADDR_VAL - in_val;
      int_temp := conv_integer(unsigned(in_val));
      
      while int_temp >= 2 loop
         addr_line := addr_line + 1;
         int_temp  := int_temp / 2;
      end loop;
   
      return addr_line;
   end if;
end function calc_mask_size;

constant IO_SPACE_0  : string  := conv_std_to_string(BAR_MASK_0(0));
constant PREFETCH_0  : string  := conv_std_to_string(BAR_MASK_0(3));
constant SIZE_MASK_0 : integer := calc_mask_size(BAR_MASK_0, 0);
constant IO_SPACE_1  : string  := conv_std_to_string(BAR_MASK_1(0));
constant PREFETCH_1  : string  := conv_std_to_string(BAR_MASK_1(3));
constant SIZE_MASK_1 : integer := calc_mask_size(BAR_MASK_1, 1);
constant IO_SPACE_2  : string  := conv_std_to_string(BAR_MASK_2(0));
constant PREFETCH_2  : string  := conv_std_to_string(BAR_MASK_2(3));
constant SIZE_MASK_2 : integer := calc_mask_size(BAR_MASK_2, 2);
constant IO_SPACE_3  : string  := conv_std_to_string(BAR_MASK_3(0));
constant PREFETCH_3  : string  := conv_std_to_string(BAR_MASK_3(3));
constant SIZE_MASK_3 : integer := calc_mask_size(BAR_MASK_3, 3);
constant IO_SPACE_4  : string  := conv_std_to_string(BAR_MASK_4(0));
constant PREFETCH_4  : string  := conv_std_to_string(BAR_MASK_4(3));
constant SIZE_MASK_4 : integer := calc_mask_size(BAR_MASK_4, 4);
constant IO_SPACE_5  : string  := conv_std_to_string(BAR_MASK_5(0));
constant PREFETCH_5  : string  := conv_std_to_string(BAR_MASK_5(3));
constant SIZE_MASK_5 : integer := calc_mask_size(BAR_MASK_5, 5);
--TODO_ITEM FIX THIS!
--constant SIZE_MASK_ROM : integer := calc_mask_size(ROM_MASK, 6);
constant SIZE_MASK_ROM : integer := calc_mask_size(ROM_MASK, 5);

constant SUPPORTED_DEVICES : supported_family_type := (CYCLONE5);

-- internal signals -----------------------------------------------------------
signal rst_int                : std_logic;
--signal rst_int_n              : std_logic;
signal core_clk_int           : std_logic;
signal npor_int               : std_logic;
signal not_npor_int           : std_logic;
--signal pld_clk_inuse_int      : std_logic;
signal rst_cnt                : std_logic_vector(4 downto 0);
signal reset_status_int       : std_logic;

signal rx_st_data0_int        : std_logic_vector(63 downto 0);
signal rx_st_err0_int         : std_logic;
signal rx_st_valid0_int       : std_logic;
signal rx_st_sop0_int         : std_logic;
signal rx_st_eop0_int         : std_logic;
signal rx_st_be0_int          : std_logic_vector(7 downto 0);
signal rx_st_bardec0_int      : std_logic_vector(7 downto 0);
signal tx_st_ready0_int       : std_logic;
signal tx_fifo_full0_int      : std_logic := '0';
signal tx_fifo_empty0_int     : std_logic;
signal tx_fifo_rdptr0_int     : std_logic_vector(3 downto 0) := (others => '0');
signal tx_fifo_wrptr0_int     : std_logic_vector(3 downto 0) := (others => '0');
signal pme_to_sr_int          : std_logic;
signal tl_cfg_add_int         : std_logic_vector(3 downto 0);
signal tl_cfg_ctl_int         : std_logic_vector(31 downto 0);
signal tl_cfg_ctl_wr_int      : std_logic;
signal tl_cfg_sts_int         : std_logic_vector(52 downto 0);
signal tl_cfg_sts_wr_int      : std_logic;
signal app_int_ack_int        : std_logic;
signal app_msi_ack_int        : std_logic;

signal rx_st_mask0_int        : std_logic;
signal rx_st_ready0_int       : std_logic;
signal tx_st_err0_int         : std_logic;
signal tx_st_valid0_int       : std_logic;
signal tx_st_sop0_int         : std_logic;
signal tx_st_eop0_int         : std_logic;
signal tx_st_data0_int        : std_logic_vector(63 downto 0);
signal pme_to_cr_int          : std_logic;
signal app_int_sts_int        : std_logic;
signal app_msi_req_int        : std_logic;
signal app_msi_tc_int         : std_logic_vector(2 downto 0);
signal app_msi_num_int        : std_logic_vector(4 downto 0);
signal pex_msi_num_int        : std_logic_vector(4 downto 0);

signal derr_cor_ext_rcv_int   : std_logic_vector(1 downto 0) := "00";
signal derr_cor_ext_rpl_int   : std_logic;
signal derr_rpl_int           : std_logic;
signal r2c_err0_int           : std_logic;
signal cpl_err_int            : std_logic_vector(6 downto 0);
signal cpl_pending_int        : std_logic;

signal l2_exit                : std_logic;
signal hotrst_exit            : std_logic;
signal dlup_exit              : std_logic;
signal int_ltssm              : std_logic_vector(4 downto 0);
signal serdes_pll_locked_int : std_logic;

signal test_in_int            : std_logic_vector(31 downto 0);

-- signals to connect pcie_msi
signal int_wb_int             : std_logic;
signal int_wb_pwr_enable      : std_logic;
signal int_wb_int_num         : std_logic_vector(4 downto 0);
signal int_wb_int_ack         : std_logic;
signal int_wb_int_num_allowed : std_logic_vector(5 downto 0);


signal reconfig_to_xcvr_int   : std_logic_vector(MAX_RECONF_IF*70-1 downto 0);
signal reconfig_from_xcvr_int : std_logic_vector(MAX_RECONF_IF*46-1 downto 0);
signal reconfig_busy_int      : std_logic;

-- signals for app_int_ack emulation
-- app_int_ack is missing for CycloneV in Quartus 14.0.2
--TODO ITEM change if signal will be added in future versions
signal irq_app_int_ack : std_logic;
signal irq_int_sts_q   : std_logic;
signal irq_int_sts_qq  : std_logic;
-------------------------------------------------------------------------------

-- components -----------------------------------------------------------------
component ip_16z091_01
   generic(
      FPGA_FAMILY             : family_type := NONE;
      NR_OF_WB_SLAVES         : natural range 63 DOWNTO 1    := 12;      
      READY_LATENCY           : natural := 2;
      FIFO_MAX_USEDW          : std_logic_vector(9 downto 0) := "1111111001";
      WBM_SUSPEND_FIFO_ACCESS : std_logic_vector(9 downto 0) := "1111111011";
      WBM_RESUME_FIFO_ACCESS  : std_logic_vector(9 downto 0) := "1111110111";
      WBS_SUSPEND_FIFO_ACCESS : std_logic_vector(9 downto 0) := "1111111100";
      WBS_RESUME_FIFO_ACCESS  : std_logic_vector(9 downto 0) := "1111110111";
      PCIE_REQUEST_LENGTH     : std_logic_vector(9 downto 0) := "0000100000";
      RX_FIFO_DEPTH           : natural := 1024; 
      RX_LPM_WIDTHU           : natural := 10;
      TX_HEADER_FIFO_DEPTH    : natural := 32;   
      TX_HEADER_LPM_WIDTHU    : natural := 5;
      TX_DATA_FIFO_DEPTH      : natural := 1024; 
      TX_DATA_LPM_WIDTHU      : natural := 10
   );
   port(
      clk                     : in  std_logic;
      wb_clk                  : in  std_logic;
      clk_500                 : in  std_logic;                                        -- 500 Hz clock
      rst                     : in  std_logic;
      wb_rst                  : in  std_logic;
                                
      -- IP Core                
      core_clk                : in  std_logic;
      rx_st_data0             : in  std_logic_vector(63 downto 0);
      rx_st_err0              : in  std_logic;
      rx_st_valid0            : in  std_logic;
      rx_st_sop0              : in  std_logic;
      rx_st_eop0              : in  std_logic;
      rx_st_be0               : in  std_logic_vector(7 downto 0);
      rx_st_bardec0           : in  std_logic_vector(7 downto 0);
      tx_st_ready0            : in  std_logic;
      tx_fifo_full0           : in  std_logic;
      tx_fifo_empty0          : in  std_logic;
      tx_fifo_rdptr0          : in  std_logic_vector(3 downto 0);
      tx_fifo_wrptr0          : in  std_logic_vector(3 downto 0);
      pme_to_sr               : in  std_logic;
      tl_cfg_add              : in  std_logic_vector(3 downto 0);
      tl_cfg_ctl              : in  std_logic_vector(31 downto 0);
      tl_cfg_ctl_wr           : in  std_logic;
      tl_cfg_sts              : in  std_logic_vector(52 downto 0);
      tl_cfg_sts_wr           : in  std_logic;
      app_int_ack             : in  std_logic;
      app_msi_ack             : in  std_logic;
      
      rx_st_mask0             : out std_logic;
      rx_st_ready0            : out std_logic;
      tx_st_err0              : out std_logic;
      tx_st_valid0            : out std_logic;
      tx_st_sop0              : out std_logic;
      tx_st_eop0              : out std_logic;
      tx_st_data0             : out std_logic_vector(63 downto 0);
      pme_to_cr               : out std_logic;
      app_int_sts             : out std_logic;
      app_msi_req             : out std_logic;
      app_msi_tc              : out std_logic_vector(2 downto 0);
      app_msi_num             : out std_logic_vector(4 downto 0);
      pex_msi_num             : out std_logic_vector(4 downto 0);
      
      derr_cor_ext_rcv        : in  std_logic_vector(1 downto 0);
      derr_cor_ext_rpl        : in  std_logic;
      derr_rpl                : in  std_logic;
      r2c_err0                : in  std_logic;
      cpl_err                 : out std_logic_vector(6 downto 0);
      cpl_pending             : out std_logic;
      
      -- Wishbone master
      wbm_ack                 : in  std_logic;
      wbm_dat_i               : in  std_logic_vector(31 downto 0);
      wbm_stb                 : out std_logic;
      wbm_cyc_o               : out std_logic_vector(NR_OF_WB_SLAVES - 1 downto 0);    --new
      wbm_we                  : out std_logic;
      wbm_sel                 : out std_logic_vector(3 downto 0);
      wbm_adr                 : out std_logic_vector(31 downto 0);
      wbm_dat_o               : out std_logic_vector(31 downto 0);
      wbm_cti                 : out std_logic_vector(2 downto 0);
      wbm_tga                 : out std_logic;
      
      -- Wishbone slave
      wbs_cyc                 : in  std_logic;
      wbs_stb                 : in  std_logic;
      wbs_we                  : in  std_logic;
      wbs_sel                 : in  std_logic_vector(3 downto 0);
      wbs_adr                 : in  std_logic_vector(31 downto 0);
      wbs_dat_i               : in  std_logic_vector(31 downto 0);
      wbs_cti                 : in  std_logic_vector(2 downto 0);
      wbs_tga                 : in  std_logic;                                    -- 0: memory, 1: I/O
      wbs_ack                 : out std_logic;
      wbs_err                 : out std_logic;
      wbs_dat_o               : out std_logic_vector(31 downto 0);
      
      -- interrupt
      wb_int                  : in  std_logic;
      wb_pwr_enable           : in  std_logic;
      wb_int_num              : in  std_logic_vector(4 downto 0);
      wb_int_ack              : out std_logic;
      wb_int_num_allowed      : out std_logic_vector(5 downto 0);
      
      -- error
      error_timeout           : out std_logic;
      error_cor_ext_rcv       : out std_logic_vector(1 downto 0);
      error_cor_ext_rpl       : out std_logic;
      error_rpl               : out std_logic;
      error_r2c0              : out std_logic;
      error_msi_num           : out std_logic;
      
      -- debug port
      rx_debug_out            : out std_logic_vector(3 downto 0)
   );
end component;

component PCIeHardIPCycV
   generic(
      VENDOR_ID           : natural  := 16#1A88#;
      DEVICE_ID           : natural  := 16#4D45#;
      REVISION_ID         : natural  := 16#0#;
      CLASS_CODE          : natural  := 16#068000#;
      SUBSYSTEM_VENDOR_ID : natural  := 16#9B#;
      SUBSYSTEM_DEVICE_ID : natural  := 16#5A91#;
      USE_LANE            : string   := "x1";
      RECONFIG_INTERFACES : positive := 2;                                     -- number of lanes +1

      ---------------------------
      -- BAR settings for func0
      ---------------------------
      IO_SPACE_BAR_0  : string  := "Disabled";
      PREFETCH_BAR_0  : string  := "Disabled";
      SIZE_MASK_BAR_0 : natural := 28;
      IO_SPACE_BAR_1  : string  := "Disabled";
      PREFETCH_BAR_1  : string  := "Disabled";
      SIZE_MASK_BAR_1 : natural := 18;
      IO_SPACE_BAR_2  : string  := "Disabled";
      PREFETCH_BAR_2  : string  := "Disabled";
      SIZE_MASK_BAR_2 : natural := 19;
      IO_SPACE_BAR_3  : string  := "Disabled";
      PREFETCH_BAR_3  : string  := "Disabled";
      SIZE_MASK_BAR_3 : natural := 7;
      IO_SPACE_BAR_4  : string  := "Disabled";
      PREFETCH_BAR_4  : string  := "Disabled";
      SIZE_MASK_BAR_4 : natural := 5;
      IO_SPACE_BAR_5  : string  := "Disabled";
      PREFETCH_BAR_5  : string  := "Disabled";
      SIZE_MASK_BAR_5 : natural := 6;     
      ROM_SIZE_MASK   : natural := 12
   );
   port (
      busy_xcvr_reconfig : in  std_logic; -- added due to sim warnings
      npor               : in  std_logic                      := '0';             --               npor.npor
      pin_perst          : in  std_logic                      := '0';             --                   .pin_perst
      test_in            : in  std_logic_vector(31 downto 0)  := (others => '0'); --           hip_ctrl.test_in
      simu_mode_pipe     : in  std_logic                      := '0';             --                   .simu_mode_pipe
      pld_clk            : in  std_logic                      := '0';             --            pld_clk.clk
      coreclkout         : out std_logic;                                         --     coreclkout_hip.clk
      refclk             : in  std_logic                      := '0';             --             refclk.clk
      rx_in0             : in  std_logic                      := '0';             --         hip_serial.rx_in0
      rx_in1             : in  std_logic                      := '0';
      rx_in2             : in  std_logic                      := '0';
      rx_in3             : in  std_logic                      := '0';
      tx_out0            : out std_logic;                                         --                   .tx_out0
      tx_out1            : out std_logic;
      tx_out2            : out std_logic;
      tx_out3            : out std_logic;
      rx_st_valid        : out std_logic;                                         --              rx_st.valid
      rx_st_sop          : out std_logic;                                         --                   .startofpacket
      rx_st_eop          : out std_logic;                                         --                   .endofpacket
      rx_st_ready        : in  std_logic                      := '0';             --                   .ready
      rx_st_err          : out std_logic;                                         --                   .error
      rx_st_data         : out std_logic_vector(63 downto 0);                     --                   .data
      rx_st_bar          : out std_logic_vector(7 downto 0);                      --          rx_bar_be.rx_st_bar
      rx_st_be           : out std_logic_vector(7 downto 0);                      --                   .rx_st_be
      rx_st_mask         : in  std_logic                      := '0';             --                   .rx_st_mask
      tx_st_valid        : in  std_logic                      := '0';             --              tx_st.valid
      tx_st_sop          : in  std_logic                      := '0';             --                   .startofpacket
      tx_st_eop          : in  std_logic                      := '0';             --                   .endofpacket
      tx_st_ready        : out std_logic;                                         --                   .ready
      tx_st_err          : in  std_logic                      := '0';             --                   .error
      tx_st_data         : in  std_logic_vector(63 downto 0)  := (others => '0'); --                   .data
      tx_fifo_empty      : out std_logic;                                         --            tx_fifo.fifo_empty
      tx_cred_datafccp   : out std_logic_vector(11 downto 0);                     --            tx_cred.tx_cred_datafccp
      tx_cred_datafcnp   : out std_logic_vector(11 downto 0);                     --                   .tx_cred_datafcnp
      tx_cred_datafcp    : out std_logic_vector(11 downto 0);                     --                   .tx_cred_datafcp
      tx_cred_fchipcons  : out std_logic_vector(5 downto 0);                      --                   .tx_cred_fchipcons
      tx_cred_fcinfinite : out std_logic_vector(5 downto 0);                      --                   .tx_cred_fcinfinite
      tx_cred_hdrfccp    : out std_logic_vector(7 downto 0);                      --                   .tx_cred_hdrfccp
      tx_cred_hdrfcnp    : out std_logic_vector(7 downto 0);                      --                   .tx_cred_hdrfcnp
      tx_cred_hdrfcp     : out std_logic_vector(7 downto 0);                      --                   .tx_cred_hdrfcp
      sim_pipe_pclk_in   : in  std_logic                      := '0';             --           hip_pipe.sim_pipe_pclk_in
      sim_pipe_rate      : out std_logic_vector(1 downto 0);                      --                   .sim_pipe_rate
      sim_ltssmstate     : out std_logic_vector(4 downto 0);                      --                   .sim_ltssmstate
      eidleinfersel0     : out std_logic_vector(2 downto 0);                      --                   .eidleinfersel0
      eidleinfersel1     : out std_logic_vector(2 downto 0);
      eidleinfersel2     : out std_logic_vector(2 downto 0);
      eidleinfersel3     : out std_logic_vector(2 downto 0);
      powerdown0         : out std_logic_vector(1 downto 0);                      --                   .powerdown0
      powerdown1         : out std_logic_vector(1 downto 0);
      powerdown2         : out std_logic_vector(1 downto 0);
      powerdown3         : out std_logic_vector(1 downto 0);
      rxpolarity0        : out std_logic;                                         --                   .rxpolarity0
      rxpolarity1        : out std_logic;
      rxpolarity2        : out std_logic;
      rxpolarity3        : out std_logic;
      txcompl0           : out std_logic;                                         --                   .txcompl0
      txcompl1           : out std_logic;
      txcompl2           : out std_logic;
      txcompl3           : out std_logic;
      txdata0            : out std_logic_vector(7 downto 0);                      --                   .txdata0
      txdata1            : out std_logic_vector(7 downto 0);
      txdata2            : out std_logic_vector(7 downto 0);
      txdata3            : out std_logic_vector(7 downto 0);
      txdatak0           : out std_logic;                                         --                   .txdatak0
      txdatak1           : out std_logic;
      txdatak2           : out std_logic;
      txdatak3           : out std_logic;
      txdetectrx0        : out std_logic;                                         --                   .txdetectrx0
      txdetectrx1        : out std_logic;
      txdetectrx2        : out std_logic;
      txdetectrx3        : out std_logic;
      txelecidle0        : out std_logic;                                         --                   .txelecidle0
      txelecidle1        : out std_logic;
      txelecidle2        : out std_logic;
      txelecidle3        : out std_logic;
      txswing0           : out std_logic;                                         --                   .txswing0
      txswing1           : out std_logic;
      txswing2           : out std_logic;
      txswing3           : out std_logic;
      txmargin0          : out std_logic_vector(2 downto 0);                      --                   .txmargin0
      txmargin1          : out std_logic_vector(2 downto 0);
      txmargin2          : out std_logic_vector(2 downto 0);
      txmargin3          : out std_logic_vector(2 downto 0);
      txdeemph0          : out std_logic;                                         --                   .txdeemph0
      txdeemph1          : out std_logic;
      txdeemph2          : out std_logic;
      txdeemph3          : out std_logic;
      phystatus0         : in  std_logic                      := '0';             --                   .phystatus0
      phystatus1         : in  std_logic                      := '0';
      phystatus2         : in  std_logic                      := '0';
      phystatus3         : in  std_logic                      := '0';
      rxdata0            : in  std_logic_vector(7 downto 0)   := (others => '0'); --                   .rxdata0
      rxdata1            : in  std_logic_vector(7 downto 0)   := (others => '0');
      rxdata2            : in  std_logic_vector(7 downto 0)   := (others => '0');
      rxdata3            : in  std_logic_vector(7 downto 0)   := (others => '0');
      rxdatak0           : in  std_logic                      := '0';             --                   .rxdatak0
      rxdatak1           : in  std_logic                      := '0';
      rxdatak2           : in  std_logic                      := '0';
      rxdatak3           : in  std_logic                      := '0';
      rxelecidle0        : in  std_logic                      := '0';             --                   .rxelecidle0
      rxelecidle1        : in  std_logic                      := '0';
      rxelecidle2        : in  std_logic                      := '0';
      rxelecidle3        : in  std_logic                      := '0';
      rxstatus0          : in  std_logic_vector(2 downto 0)   := (others => '0'); --                   .rxstatus0
      rxstatus1          : in  std_logic_vector(2 downto 0)   := (others => '0');
      rxstatus2          : in  std_logic_vector(2 downto 0)   := (others => '0');
      rxstatus3          : in  std_logic_vector(2 downto 0)   := (others => '0');
      rxvalid0           : in  std_logic                      := '0';             --                   .rxvalid0
      rxvalid1           : in  std_logic                      := '0';
      rxvalid2           : in  std_logic                      := '0';
      rxvalid3           : in  std_logic                      := '0';
      reset_status       : out std_logic;                                         --            hip_rst.reset_status
      serdes_pll_locked  : out std_logic;                                         --                   .serdes_pll_locked
      pld_clk_inuse      : out std_logic;                                         --                   .pld_clk_inuse
      pld_core_ready     : in  std_logic                      := '0';             --                   .pld_core_ready
      testin_zero        : out std_logic;                                         --                   .testin_zero
      lmi_addr           : in  std_logic_vector(11 downto 0)  := (others => '0'); --                lmi.lmi_addr
      lmi_din            : in  std_logic_vector(31 downto 0)  := (others => '0'); --                   .lmi_din
      lmi_rden           : in  std_logic                      := '0';             --                   .lmi_rden
      lmi_wren           : in  std_logic                      := '0';             --                   .lmi_wren
      lmi_ack            : out std_logic;                                         --                   .lmi_ack
      lmi_dout           : out std_logic_vector(31 downto 0);                     --                   .lmi_dout
      pm_auxpwr          : in  std_logic                      := '0';             --         power_mngt.pm_auxpwr
      pm_data            : in  std_logic_vector(9 downto 0)   := (others => '0'); --                   .pm_data
      pme_to_cr          : in  std_logic                      := '0';             --                   .pme_to_cr
      pm_event           : in  std_logic                      := '0';             --                   .pm_event
      pme_to_sr          : out std_logic;                                         --                   .pme_to_sr
      --reconfig_to_xcvr   : in  std_logic_vector(139 downto 0) := (others => '0'); --   reconfig_to_xcvr.reconfig_to_xcvr
      reconfig_to_xcvr   : in  std_logic_vector(RECONFIG_INTERFACES*70-1 downto 0) := (others => '0'); --   reconfig_to_xcvr.reconfig_to_xcvr
      --reconfig_from_xcvr : out std_logic_vector(91 downto 0);                     -- reconfig_from_xcvr.reconfig_from_xcvr
      reconfig_from_xcvr : out std_logic_vector(RECONFIG_INTERFACES*46-1 downto 0);                     -- reconfig_from_xcvr.reconfig_from_xcvr
      app_msi_num        : in  std_logic_vector(4 downto 0)   := (others => '0'); --            int_msi.app_msi_num
      app_msi_req        : in  std_logic                      := '0';             --                   .app_msi_req
      app_msi_tc         : in  std_logic_vector(2 downto 0)   := (others => '0'); --                   .app_msi_tc
      app_msi_ack        : out std_logic;                                         --                   .app_msi_ack
      app_int_sts_vec    : in  std_logic                      := '0';             --                   .app_int_sts
      tl_hpg_ctrl_er     : in  std_logic_vector(4 downto 0)   := (others => '0'); --          config_tl.hpg_ctrler
      tl_cfg_ctl         : out std_logic_vector(31 downto 0);                     --                   .tl_cfg_ctl
      cpl_err            : in  std_logic_vector(6 downto 0)   := (others => '0'); --                   .cpl_err
      tl_cfg_add         : out std_logic_vector(3 downto 0);                      --                   .tl_cfg_add
      tl_cfg_ctl_wr      : out std_logic;                                         --                   .tl_cfg_ctl_wr
      tl_cfg_sts_wr      : out std_logic;                                         --                   .tl_cfg_sts_wr
      tl_cfg_sts         : out std_logic_vector(52 downto 0);                     --                   .tl_cfg_sts
      cpl_pending        : in  std_logic_vector(0 downto 0)   := (others => '0'); --                   .cpl_pending
      derr_cor_ext_rcv0  : out std_logic;                                         --         hip_status.derr_cor_ext_rcv
      derr_cor_ext_rpl   : out std_logic;                                         --                   .derr_cor_ext_rpl
      derr_rpl           : out std_logic;                                         --                   .derr_rpl
      dlup_exit          : out std_logic;                                         --                   .dlup_exit
      dl_ltssm           : out std_logic_vector(4 downto 0);                      --                   .ltssmstate
      ev128ns            : out std_logic;                                         --                   .ev128ns
      ev1us              : out std_logic;                                         --                   .ev1us
      hotrst_exit        : out std_logic;                                         --                   .hotrst_exit
      int_status         : out std_logic_vector(3 downto 0);                      --                   .int_status
      l2_exit            : out std_logic;                                         --                   .l2_exit
      lane_act           : out std_logic_vector(3 downto 0);                      --                   .lane_act
      ko_cpl_spc_header  : out std_logic_vector(7 downto 0);                      --                   .ko_cpl_spc_header
      ko_cpl_spc_data    : out std_logic_vector(11 downto 0);                     --                   .ko_cpl_spc_data
      dl_current_speed   : out std_logic_vector(1 downto 0)                       --   hip_currentspeed.currentspeed
   );
end component;

---------------------------------------
-- module to convert irq_req_i vector
-- to 16z091-01 irq behavior
---------------------------------------
component pcie_msi
   generic (
      WIDTH                : integer range 32 downto 1 
   );
   port (
      clk_i                : in  std_logic;
      rst_i                : in  std_logic;
     
      irq_req_i            : in  std_logic_vector(WIDTH -1 downto 0);
      
      wb_int_o             : out std_logic;
      wb_pwr_enable_o      : out std_logic;
      wb_int_num_o         : OUT std_logic_vector(4 downto 0);
      wb_int_ack_i         : in  std_logic;
      wb_int_num_allowed_i : in  std_logic_vector(5 downto 0)
   );
end component;


-------------------------------------------
-- Transceiver reconfiguration controller
-------------------------------------------
component CycVTransReconf
   generic(
      RECONFIG_INTERFACES : positive := 2                                     -- number of lanes +1
   );
   port(
      reconfig_busy             : out std_logic;
      mgmt_clk_clk              : in  std_logic                      := '0';
      mgmt_rst_reset            : in  std_logic                      := '0';
      reconfig_mgmt_address     : in  std_logic_vector(6 downto 0)   := (others => '0');
      reconfig_mgmt_read        : in  std_logic                      := '0';
      reconfig_mgmt_readdata    : out std_logic_vector(31 downto 0);
      reconfig_mgmt_waitrequest : out std_logic;
      reconfig_mgmt_write       : in  std_logic                      := '0';
      reconfig_mgmt_writedata   : in  std_logic_vector(31 downto 0)  := (others => '0');
      --reconfig_to_xcvr          : out std_logic_vector(349 downto 0);
      --reconfig_from_xcvr        : in  std_logic_vector(229 downto 0)  := (others => '0')
      reconfig_to_xcvr          : out std_logic_vector(RECONFIG_INTERFACES*70-1 downto 0);
      reconfig_from_xcvr        : in  std_logic_vector(RECONFIG_INTERFACES*46-1 downto 0) := (others => '0')
   );
end component;
-------------------------------------------------------------------------------

begin
-- +----------------------------------------------------------------------------
-- | concurrent section
-- +----------------------------------------------------------------------------
   -- coverage off
   assert not no_valid_device(supported_device => SUPPORTED_DEVICES, device => FPGA_FAMILY) report "16z091-01: no valid FPGA device selected" severity failure;
   --assert (USE_LANES = "001") report "16z91-01: no valid USE_LANES setting" severity failure; 
   assert (USE_LANES = "001" or USE_LANES = "010") report "16z91-01: no valid USE_LANES setting" severity failure; 
   -- coverage on

   gp_debug_port <= (others => '0');
   npor_int      <= ext_rst_n and '1';
   not_npor_int  <= not npor_int;

   ----------------------------------
   -- assign debug port if ltssm is
   -- in link training mode
   ----------------------------------
   link_train_active <= '0' when int_ltssm = "01111" else
                        '1';
   ------------------------------------------------------
   -- Definition of signal test_in changed for CycloneV
   -- set values as recommended in user guide page 4-51
   -- -> seems to be incorrect, all 0 seems to be ok
   ------------------------------------------------------
   --test_in_int(31 downto 12) <= (others => '1'); -- reserved
   --test_in_int(11 downto 8)  <= x"0";            -- set to "0011" to route PIPE interface signals to test_out
   --test_in_int(7) <= '0';                        -- reserved 
   --test_in_int(6) <= '0';                        -- force entry to compliance mode
   --test_in_int(5) <= '0';                        -- compliance test mode
   --test_in_int(4 downto 1)  <= "0100";           -- reserved
   test_in_int(31 downto 1) <= (others => '0');
   test_in_int(0) <= SIMULATION;                 -- =1 for simulation to accelerate initialization
   --test_in_int(31 downto 0) <= x"00000201"; --sets values as used in Altera test bench
   
   -----------------------------------------------------
   -- new HardIP ready signal for CycloneV
   -- reset 16z091-01 as long as pld_clk_inuse=0
   -- release rst_int 32x pld_clk after reset_status=0
   -----------------------------------------------------
   rst_int <= '1' when rst_cnt /= "00000" else '0';
   --rst_int_n <= not rst_int;


-- +----------------------------------------------------------------------------
-- | process section
-- +----------------------------------------------------------------------------
   --------------------------------------------------------------------
   -- release rst_int 32x pld_clk after reset_status=0
   -- assert rst_int for min. 32x pld_clk if hotrst_exit or dlup_exit
   -- or l2_exit are deasserted for 1 pld_clk cycle
   --------------------------------------------------------------------
   rst_seq : process(ext_rst_n, reset_status_int, core_clk_int)
   begin
      if ext_rst_n = '0' then
         rst_cnt <= (others => '1');
      elsif core_clk_int'event and core_clk_int = '1' then
         if reset_status_int = '1' then
            rst_cnt <= (others => '1');
         elsif dlup_exit = '0' or hotrst_exit = '0' or l2_exit = '0' then
            rst_cnt <= (others => '1');
         elsif rst_cnt > "00000" then
            rst_cnt <= rst_cnt - 1;
         end if;
      end if;
   end process rst_seq;
      
   ------------------------------------------------------------------------
   -- emulate app_int_ack behavior because signal is missing for CycloneV
   ------------------------------------------------------------------------
   int_ack_c5 : process(rst_int, core_clk_int)
   begin
      if rst_int = '1' then
         irq_app_int_ack <= '0';
         irq_int_sts_q   <= '0';
         irq_int_sts_qq  <= '0';
      elsif core_clk_int'event and core_clk_int = '1' then
         irq_int_sts_q  <= app_int_sts_int;
         irq_int_sts_qq <= irq_int_sts_q;

         if irq_int_sts_q = '1' and irq_int_sts_qq = '0' then
            ----------------------------
            -- acknowledge Assert_INTA
            ----------------------------
            irq_app_int_ack <= '1';
         elsif irq_int_sts_q = '0' and irq_int_sts_qq = '1' then
            ------------------------------
            -- acknowledge Deassert_INTA
            ------------------------------
            irq_app_int_ack <= '1';
         else
            irq_app_int_ack <= '0';
         end if;

      end if;
   end process int_ack_c5;

-- +----------------------------------------------------------------------------
-- | component instantiations
-- +----------------------------------------------------------------------------
   ip_16z091_01_comp : ip_16z091_01
      generic map(
         FPGA_FAMILY             => FPGA_FAMILY,
         NR_OF_WB_SLAVES         => NR_OF_WB_SLAVES,
         READY_LATENCY           => 2,
         FIFO_MAX_USEDW          => conv_std_logic_vector((2**RX_LPM_WIDTHU - 8),10),
         WBM_SUSPEND_FIFO_ACCESS => conv_std_logic_vector((2**TX_DATA_LPM_WIDTHU - 5),10),
         WBM_RESUME_FIFO_ACCESS  => conv_std_logic_vector((2**TX_DATA_LPM_WIDTHU - 9),10),
         WBS_SUSPEND_FIFO_ACCESS => conv_std_logic_vector((2**TX_DATA_LPM_WIDTHU - 4),10),
         WBS_RESUME_FIFO_ACCESS  => conv_std_logic_vector((2**TX_DATA_LPM_WIDTHU - 9),10),
         PCIE_REQUEST_LENGTH     => PCIE_REQUEST_LENGTH,
         RX_FIFO_DEPTH           => 2**RX_LPM_WIDTHU,
         RX_LPM_WIDTHU           => RX_LPM_WIDTHU,
         TX_HEADER_FIFO_DEPTH    => 2**TX_HEADER_LPM_WIDTHU,
         TX_HEADER_LPM_WIDTHU    => TX_HEADER_LPM_WIDTHU,
         TX_DATA_FIFO_DEPTH      => 2**TX_DATA_LPM_WIDTHU,
         TX_DATA_LPM_WIDTHU      => TX_DATA_LPM_WIDTHU
      )
      port map(
         clk                     => core_clk_int,
         rst                     => rst_int,
         clk_500                 => clk_500,
         wb_clk                  => wb_clk,
         wb_rst                  => wb_rst,
                                   
         -- IP Core                
         core_clk                => core_clk_int,
         rx_st_data0             => rx_st_data0_int,
         rx_st_err0              => rx_st_err0_int,
         rx_st_valid0            => rx_st_valid0_int,
         rx_st_sop0              => rx_st_sop0_int,
         rx_st_eop0              => rx_st_eop0_int,
         rx_st_be0               => rx_st_be0_int,
         rx_st_bardec0           => rx_st_bardec0_int,
         tx_st_ready0            => tx_st_ready0_int,
         tx_fifo_full0           => tx_fifo_full0_int,
         tx_fifo_empty0          => tx_fifo_empty0_int,
         tx_fifo_rdptr0          => tx_fifo_rdptr0_int,
         tx_fifo_wrptr0          => tx_fifo_wrptr0_int,
         pme_to_sr               => pme_to_sr_int,
         tl_cfg_add              => tl_cfg_add_int,
         tl_cfg_ctl              => tl_cfg_ctl_int,
         tl_cfg_ctl_wr           => tl_cfg_ctl_wr_int,
         tl_cfg_sts              => tl_cfg_sts_int,
         tl_cfg_sts_wr           => tl_cfg_sts_wr_int,
--TODO ITEM change next line when app_int_ack is added to CycloneV again by Altera
         app_int_ack             => irq_app_int_ack,        --app_int_ack_int,
         app_msi_ack             => app_msi_ack_int,
         
         rx_st_mask0             => rx_st_mask0_int,
         rx_st_ready0            => rx_st_ready0_int,
         tx_st_err0              => tx_st_err0_int,
         tx_st_valid0            => tx_st_valid0_int,
         tx_st_sop0              => tx_st_sop0_int,
         tx_st_eop0              => tx_st_eop0_int,
         tx_st_data0             => tx_st_data0_int,
         pme_to_cr               => pme_to_cr_int,
         app_int_sts             => app_int_sts_int,
         app_msi_req             => app_msi_req_int,
         app_msi_tc              => app_msi_tc_int,
         app_msi_num             => app_msi_num_int,
         pex_msi_num             => pex_msi_num_int,
         
         derr_cor_ext_rcv        => derr_cor_ext_rcv_int,
         derr_cor_ext_rpl        => derr_cor_ext_rpl_int,
         derr_rpl                => derr_rpl_int,
         r2c_err0                => r2c_err0_int,
         cpl_err                 => cpl_err_int,
         cpl_pending             => cpl_pending_int,
         
         -- Wishbone master
         wbm_ack                 => wbm_ack,
         wbm_dat_i               => wbm_dat_i,
         wbm_stb                 => wbm_stb,
         wbm_cyc_o               => wbm_cyc_o,
         wbm_we                  => wbm_we,
         wbm_sel                 => wbm_sel,
         wbm_adr                 => wbm_adr,
         wbm_dat_o               => wbm_dat_o,
         wbm_cti                 => wbm_cti,
         wbm_tga                 => wbm_tga,
         
         -- Wishbone slave
         wbs_cyc                 => wbs_cyc,
         wbs_stb                 => wbs_stb,
         wbs_we                  => wbs_we,
         wbs_sel                 => wbs_sel,
         wbs_adr                 => wbs_adr,
         wbs_dat_i               => wbs_dat_i,
         wbs_cti                 => wbs_cti,
         wbs_tga                 => wbs_tga,
         wbs_ack                 => wbs_ack,
         wbs_err                 => wbs_err,
         wbs_dat_o               => wbs_dat_o,
         
         -- interrupt
         wb_int                  => int_wb_int,
         wb_pwr_enable           => int_wb_pwr_enable,
         wb_int_num              => int_wb_int_num,
         wb_int_ack              => int_wb_int_ack,
         wb_int_num_allowed      => int_wb_int_num_allowed,
         
         -- error
         error_timeout           => error_timeout,
         error_cor_ext_rcv       => error_cor_ext_rcv,
         error_cor_ext_rpl       => error_cor_ext_rpl,
         error_rpl               => error_rpl,
         error_r2c0              => error_r2c0,
         error_msi_num           => error_msi_num,
         
         -- debug port
         rx_debug_out            => open
      );

   

   gen_cycv_x1: if USE_LANES = "001" generate
      PCIeHardIP_CycV_x1_comp : PCIeHardIPCycV
      generic map(
         VENDOR_ID           => VENDOR_ID,
         DEVICE_ID           => DEVICE_ID,
         REVISION_ID         => REVISION_ID,
         CLASS_CODE          => CLASS_CODE,
         SUBSYSTEM_VENDOR_ID => SUBSYSTEM_VENDOR_ID,
         SUBSYSTEM_DEVICE_ID => SUBSYSTEM_DEVICE_ID,
         USE_LANE            => "x1",
         RECONFIG_INTERFACES => 2,                               -- number of lanes +1

         ---------------------------
         -- BAR settings for func0
         ---------------------------
         IO_SPACE_BAR_0  => IO_SPACE_0,
         PREFETCH_BAR_0  => PREFETCH_0,
         SIZE_MASK_BAR_0 => SIZE_MASK_0,
         IO_SPACE_BAR_1  => IO_SPACE_1,
         PREFETCH_BAR_1  => PREFETCH_1,
         SIZE_MASK_BAR_1 => SIZE_MASK_1,
         IO_SPACE_BAR_2  => IO_SPACE_2,
         PREFETCH_BAR_2  => PREFETCH_2,
         SIZE_MASK_BAR_2 => SIZE_MASK_2,
         IO_SPACE_BAR_3  => IO_SPACE_3,
         PREFETCH_BAR_3  => PREFETCH_3,
         SIZE_MASK_BAR_3 => SIZE_MASK_3,
         IO_SPACE_BAR_4  => IO_SPACE_4,
         PREFETCH_BAR_4  => PREFETCH_4,
         SIZE_MASK_BAR_4 => SIZE_MASK_4,
         IO_SPACE_BAR_5  => IO_SPACE_5,
         PREFETCH_BAR_5  => PREFETCH_5,
         SIZE_MASK_BAR_5 => SIZE_MASK_5,
         ROM_SIZE_MASK   => SIZE_MASK_ROM
      )
      port map(
         -- inputs:
         busy_xcvr_reconfig => reconfig_busy_int,
         app_int_sts_vec    => app_int_sts_int,
         app_msi_num        => app_msi_num_int,
         app_msi_req        => app_msi_req_int,
         app_msi_tc         => app_msi_tc_int,
         cpl_err            => cpl_err_int,
         cpl_pending(0)     => cpl_pending_int,
         lmi_addr           => (others => '0'),
         lmi_din            => (others => '0'),
         lmi_rden           => '0',
         lmi_wren           => '0',
         npor               => npor_int, 
         phystatus0         => '0',                              -- if asserted LTSSM is stuck at x"00"
         phystatus1         => '0',                              -- if asserted LTSSM is stuck at x"00"
-- pin_perst must be connected to nPERST of correct location in device
-- nPERSTL0 for top left
-- nPERSTL1 for bottom left <-- use this one first (recommended by Altera)
         pin_perst          => ext_rst_n, --'0',
         pld_clk            => core_clk_int,
         pld_core_ready     => serdes_pll_locked_int,
         pm_auxpwr          => '0',
         pm_data            => (others => '0'),
         pm_event           => '0',
         pme_to_cr          => pme_to_cr_int,
         reconfig_to_xcvr   => reconfig_to_xcvr_int(2*70-1 downto 0),  -- 2 reconfig interfaces
         refclk             => ref_clk,
         rx_in0             => rx_0,
         rx_in1             => '0',
         rx_in2             => '0',
         rx_in3             => '0',
         rx_st_mask         => rx_st_mask0_int,
         rx_st_ready        => rx_st_ready0_int,
         rxdata0            => (others => '0'),
         rxdata1            => (others => '0'),
         rxdata2            => (others => '0'),
         rxdata3            => (others => '0'),
         rxdatak0           => '0',
         rxdatak1           => '0',
         rxdatak2           => '0',
         rxdatak3           => '0',
         rxelecidle0        => '0',
         rxelecidle1        => '0',
         rxelecidle2        => '0',
         rxelecidle3        => '0',
         rxstatus0          => (others => '0'),
         rxstatus1          => (others => '0'),
         rxstatus2          => (others => '0'),
         rxstatus3          => (others => '0'),
         rxvalid0           => '0',
         rxvalid1           => '0',
         rxvalid2           => '0',
         rxvalid3           => '0',
         sim_pipe_pclk_in   => core_clk_int,                     -- simulation only
         simu_mode_pipe     => SIMULATION,                       -- indicate simulation mode
         test_in            => test_in_int(31 downto 0),
         tl_hpg_ctrl_er     => (others => '0'),                  -- hardwire to 0 for endpoints
         tx_st_data         => tx_st_data0_int,
         tx_st_eop          => tx_st_eop0_int,
         tx_st_err          => tx_st_err0_int,
         tx_st_sop          => tx_st_sop0_int,
         tx_st_valid        => tx_st_valid0_int,

         -- outputs:
         app_msi_ack        => app_msi_ack_int,
         coreclkout         => core_clk_int,
         derr_cor_ext_rcv0  => derr_cor_ext_rcv_int(0),
         derr_cor_ext_rpl   => derr_cor_ext_rpl_int,
         derr_rpl           => derr_rpl_int,
         dl_current_speed   => open,                             -- indicate current speed of PCIe link
         dl_ltssm           => int_ltssm,
         dlup_exit          => dlup_exit,
         eidleinfersel0     => open,                             -- electrical idle entry inference mechanism
         eidleinfersel1     => open,                             -- electrical idle entry inference mechanism
         eidleinfersel2     => open,                             -- electrical idle entry inference mechanism
         eidleinfersel3     => open,                             -- electrical idle entry inference mechanism
         ev128ns            => open,                             -- asserted every 128ns
         ev1us              => open,                             -- asserted every 1us
         hotrst_exit        => hotrst_exit,
         int_status         => open,                             -- defined as root port signal which shows legacy irq,
                                                                 -- int_status[0] = A, int_status[3] = D
         ko_cpl_spc_data    => open,
         ko_cpl_spc_header  => open,
         l2_exit            => l2_exit,
         lane_act           => open,
         lmi_ack            => open,
         lmi_dout           => open,
         pld_clk_inuse      => open, --pld_clk_inuse_int,
         pme_to_sr          => pme_to_sr_int,
         powerdown0         => open,
         powerdown1         => open,
         powerdown2         => open,
         powerdown3         => open,
         reconfig_from_xcvr => reconfig_from_xcvr_int(2*46-1 downto 0), -- 2 reconfig interfaces
         reset_status       => reset_status_int,
         rx_st_bar          => rx_st_bardec0_int,
         rx_st_be           => rx_st_be0_int,
         rx_st_data         => rx_st_data0_int,
         rx_st_eop          => rx_st_eop0_int,
         rx_st_err          => rx_st_err0_int,
         rx_st_sop          => rx_st_sop0_int,
         rx_st_valid        => rx_st_valid0_int,
         rxpolarity0        => open,
         rxpolarity1        => open,
         rxpolarity2        => open,
         rxpolarity3        => open,
         serdes_pll_locked  => serdes_pll_locked_int,
         sim_ltssmstate     => open, --alt_bfm_sim_ltssm,                -- show LTSSM state
         sim_pipe_rate      => open, --alt_bfm_sim_pipe_rate,            -- show Gen1,2,3
         testin_zero        => open,
         tl_cfg_add         => tl_cfg_add_int,
         tl_cfg_ctl         => tl_cfg_ctl_int,
         tl_cfg_ctl_wr      => tl_cfg_ctl_wr_int,
         tl_cfg_sts         => tl_cfg_sts_int,
         tl_cfg_sts_wr      => tl_cfg_sts_wr_int,
         tx_cred_datafccp   => open,
         tx_cred_datafcnp   => open,
         tx_cred_datafcp    => open,
         tx_cred_fchipcons  => open,
         tx_cred_fcinfinite => open,
         tx_cred_hdrfccp    => open,
         tx_cred_hdrfcnp    => open,
         tx_cred_hdrfcp     => open,
         tx_fifo_empty      => tx_fifo_empty0_int,
         tx_out0            => tx_0,
         tx_out1            => open,
         tx_out2            => open,
         tx_out3            => open,
         tx_st_ready        => tx_st_ready0_int,
         txcompl0           => open,
         txcompl1           => open,
         txcompl2           => open,
         txcompl3           => open,
         txdata0            => open,
         txdata1            => open,
         txdata2            => open,
         txdata3            => open,
         txdatak0           => open,
         txdatak1           => open,
         txdatak2           => open,
         txdatak3           => open,
         txdeemph0          => open,
         txdeemph1          => open,
         txdeemph2          => open,
         txdeemph3          => open,
         txdetectrx0        => open,
         txdetectrx1        => open,
         txdetectrx2        => open,
         txdetectrx3        => open,
         txelecidle0        => open,
         txelecidle1        => open,
         txelecidle2        => open,
         txelecidle3        => open,
         txmargin0          => open,                             -- simulation only
         txmargin1          => open,                             -- simulation only
         txmargin2          => open,                             -- simulation only
         txmargin3          => open,                             -- simulation only
         txswing0           => open,                             -- =1: V_OD full swing, =0 half swing
         txswing1           => open,                             -- =1: V_OD full swing, =0 half swing
         txswing2           => open,                             -- =1: V_OD full swing, =0 half swing
         txswing3           => open                              -- =1: V_OD full swing, =0 half swing
      );

      ------------------------------------------------------
      -- set default values for signals which are not used
      ------------------------------------------------------
      derr_cor_ext_rcv_int(1)               <= '0';
      --reconfig_from_xcvr_int(229 downto 92) <= (others => '0');
      reconfig_from_xcvr_int(MAX_RECONF_IF*46-1 downto 2*46) <= (others => '0');
      tx_fifo_full0_int                     <= '0';
      tx_fifo_rdptr0_int                    <= (others => '0');
      tx_fifo_wrptr0_int                    <= (others => '0');
      pex_msi_num_int                       <= (others => '0');
      r2c_err0_int                          <= '0';

      ----------------------------------------
      -- set default values for unused ports
      ----------------------------------------
      tx_1 <= '1';
      tx_2 <= '1';
      tx_3 <= '1';

      --------------------------------
      -- manage CycloneV transceiver
      --------------------------------
      cycv_trans_reconf_i0 : CycVTransReconf
         generic map(
            RECONFIG_INTERFACES => 2                             -- number of lanes +1
         )
         port map(
            -- inputs
            mgmt_clk_clk              => ref_clk,                -- CycloneV: 75-100MHz
            mgmt_rst_reset            => not_npor_int,           -- high active
            reconfig_mgmt_address     => (others => '0'),
            reconfig_mgmt_read        => '0',
            reconfig_mgmt_write       => '0',
            reconfig_mgmt_writedata   => (others => '0'),
            reconfig_from_xcvr        => reconfig_from_xcvr_int(2*46-1 downto 0),
          
            -- outputs
            reconfig_busy             => reconfig_busy_int,
            reconfig_mgmt_readdata    => open,
            reconfig_mgmt_waitrequest => open,
            reconfig_to_xcvr          => reconfig_to_xcvr_int(2*70-1 downto 0)
         );
   end generate gen_cycv_x1;



   gen_cycv_x2: if USE_LANES = "010" generate
      PCIeHardIP_CycV_x1_comp : PCIeHardIPCycV
      generic map(
         VENDOR_ID           => VENDOR_ID,
         DEVICE_ID           => DEVICE_ID,
         REVISION_ID         => REVISION_ID,
         CLASS_CODE          => CLASS_CODE,
         SUBSYSTEM_VENDOR_ID => SUBSYSTEM_VENDOR_ID,
         SUBSYSTEM_DEVICE_ID => SUBSYSTEM_DEVICE_ID,
         USE_LANE            => "x2",
         RECONFIG_INTERFACES => 3,                               -- number of lanes +1

         ---------------------------
         -- BAR settings for func0
         ---------------------------
         IO_SPACE_BAR_0  => IO_SPACE_0,
         PREFETCH_BAR_0  => PREFETCH_0,
         SIZE_MASK_BAR_0 => SIZE_MASK_0,
         IO_SPACE_BAR_1  => IO_SPACE_1,
         PREFETCH_BAR_1  => PREFETCH_1,
         SIZE_MASK_BAR_1 => SIZE_MASK_1,
         IO_SPACE_BAR_2  => IO_SPACE_2,
         PREFETCH_BAR_2  => PREFETCH_2,
         SIZE_MASK_BAR_2 => SIZE_MASK_2,
         IO_SPACE_BAR_3  => IO_SPACE_3,
         PREFETCH_BAR_3  => PREFETCH_3,
         SIZE_MASK_BAR_3 => SIZE_MASK_3,
         IO_SPACE_BAR_4  => IO_SPACE_4,
         PREFETCH_BAR_4  => PREFETCH_4,
         SIZE_MASK_BAR_4 => SIZE_MASK_4,
         IO_SPACE_BAR_5  => IO_SPACE_5,
         PREFETCH_BAR_5  => PREFETCH_5,
         SIZE_MASK_BAR_5 => SIZE_MASK_5,
         ROM_SIZE_MASK   => SIZE_MASK_ROM
      )
      port map(
         -- inputs:
         busy_xcvr_reconfig => reconfig_busy_int,
         app_int_sts_vec    => app_int_sts_int,
         app_msi_num        => app_msi_num_int,
         app_msi_req        => app_msi_req_int,
         app_msi_tc         => app_msi_tc_int,
         cpl_err            => cpl_err_int,
         cpl_pending(0)     => cpl_pending_int,
         lmi_addr           => (others => '0'),
         lmi_din            => (others => '0'),
         lmi_rden           => '0',
         lmi_wren           => '0',
         npor               => npor_int, 
         phystatus0         => '0',                              -- if asserted LTSSM is stuck at x"00"
         phystatus1         => '0',                              -- if asserted LTSSM is stuck at x"00"
         phystatus2         => '0',                              -- if asserted LTSSM is stuck at x"00"
         phystatus3         => '0',                              -- if asserted LTSSM is stuck at x"00"
-- pin_perst must be connected to nPERST of correct location in device
-- nPERSTL0 for top left
-- nPERSTL1 for bottom left <-- use this one first (recommended by Altera)
         pin_perst          => ext_rst_n, --'0',
         pld_clk            => core_clk_int,
         pld_core_ready     => serdes_pll_locked_int,
         pm_auxpwr          => '0',
         pm_data            => (others => '0'),
         pm_event           => '0',
         pme_to_cr          => pme_to_cr_int,
         reconfig_to_xcvr   => reconfig_to_xcvr_int(3*70-1 downto 0),
         refclk             => ref_clk,
         rx_in0             => rx_0,
         rx_in1             => rx_1,
         rx_in2             => '0',
         rx_in3             => '0',
         rx_st_mask         => rx_st_mask0_int,
         rx_st_ready        => rx_st_ready0_int,
         rxdata0            => (others => '0'),
         rxdata1            => (others => '0'),
         rxdata2            => (others => '0'),
         rxdata3            => (others => '0'),
         rxdatak0           => '0',
         rxdatak1           => '0',
         rxdatak2           => '0',
         rxdatak3           => '0',
         rxelecidle0        => '0',
         rxelecidle1        => '0',
         rxelecidle2        => '0',
         rxelecidle3        => '0',
         rxstatus0          => (others => '0'),
         rxstatus1          => (others => '0'),
         rxstatus2          => (others => '0'),
         rxstatus3          => (others => '0'),
         rxvalid0           => '0',
         rxvalid1           => '0',
         rxvalid2           => '0',
         rxvalid3           => '0',
         sim_pipe_pclk_in   => core_clk_int,                     -- simulation only
         simu_mode_pipe     => SIMULATION,                       -- indicate simulation mode
         test_in            => test_in_int(31 downto 0),
         tl_hpg_ctrl_er     => (others => '0'),                  -- hardwire to 0 for endpoints
         tx_st_data         => tx_st_data0_int,
         tx_st_eop          => tx_st_eop0_int,
         tx_st_err          => tx_st_err0_int,
         tx_st_sop          => tx_st_sop0_int,
         tx_st_valid        => tx_st_valid0_int,

         -- outputs:
         app_msi_ack        => app_msi_ack_int,
         coreclkout         => core_clk_int,
         derr_cor_ext_rcv0  => derr_cor_ext_rcv_int(0),
         derr_cor_ext_rpl   => derr_cor_ext_rpl_int,
         derr_rpl           => derr_rpl_int,
         dl_current_speed   => open,                             -- indicate current speed of PCIe link
         dl_ltssm           => int_ltssm,
         dlup_exit          => dlup_exit,
         eidleinfersel0     => open,                             -- electrical idle entry inference mechanism
         eidleinfersel1     => open,                             -- electrical idle entry inference mechanism
         eidleinfersel2     => open,                             -- electrical idle entry inference mechanism
         eidleinfersel3     => open,                             -- electrical idle entry inference mechanism
         ev128ns            => open,                             -- asserted every 128ns
         ev1us              => open,                             -- asserted every 1us
         hotrst_exit        => hotrst_exit,
         int_status         => open,                             -- defined as root port signal which shows legacy irq,
                                                                 -- int_status[0] = A, int_status[3] = D
         ko_cpl_spc_data    => open,
         ko_cpl_spc_header  => open,
         l2_exit            => l2_exit,
         lane_act           => open,
         lmi_ack            => open,
         lmi_dout           => open,
         pld_clk_inuse      => open, --pld_clk_inuse_int,
         pme_to_sr          => pme_to_sr_int,
         powerdown0         => open,
         powerdown1         => open,
         powerdown2         => open,
         powerdown3         => open,
         reconfig_from_xcvr => reconfig_from_xcvr_int(3*46-1 downto 0),
         reset_status       => reset_status_int,
         rx_st_bar          => rx_st_bardec0_int,
         rx_st_be           => rx_st_be0_int,
         rx_st_data         => rx_st_data0_int,
         rx_st_eop          => rx_st_eop0_int,
         rx_st_err          => rx_st_err0_int,
         rx_st_sop          => rx_st_sop0_int,
         rx_st_valid        => rx_st_valid0_int,
         rxpolarity0        => open,
         rxpolarity1        => open,
         rxpolarity2        => open,
         rxpolarity3        => open,
         serdes_pll_locked  => serdes_pll_locked_int,
         sim_ltssmstate     => open, --alt_bfm_sim_ltssm,                -- show LTSSM state
         sim_pipe_rate      => open, --alt_bfm_sim_pipe_rate,            -- show Gen1,2,3
         testin_zero        => open,
         tl_cfg_add         => tl_cfg_add_int,
         tl_cfg_ctl         => tl_cfg_ctl_int,
         tl_cfg_ctl_wr      => tl_cfg_ctl_wr_int,
         tl_cfg_sts         => tl_cfg_sts_int,
         tl_cfg_sts_wr      => tl_cfg_sts_wr_int,
         tx_cred_datafccp   => open,
         tx_cred_datafcnp   => open,
         tx_cred_datafcp    => open,
         tx_cred_fchipcons  => open,
         tx_cred_fcinfinite => open,
         tx_cred_hdrfccp    => open,
         tx_cred_hdrfcnp    => open,
         tx_cred_hdrfcp     => open,
         tx_fifo_empty      => tx_fifo_empty0_int,
         tx_out0            => tx_0,
         tx_out1            => tx_1,
         tx_out2            => open,
         tx_out3            => open,
         tx_st_ready        => tx_st_ready0_int,
         txcompl0           => open,
         txcompl1           => open,
         txcompl2           => open,
         txcompl3           => open,
         txdata0            => open,
         txdata1            => open,
         txdata2            => open,
         txdata3            => open,
         txdatak0           => open,
         txdatak1           => open,
         txdatak2           => open,
         txdatak3           => open,
         txdeemph0          => open,
         txdeemph1          => open,
         txdeemph2          => open,
         txdeemph3          => open,
         txdetectrx0        => open,
         txdetectrx1        => open,
         txdetectrx2        => open,
         txdetectrx3        => open,
         txelecidle0        => open,
         txelecidle1        => open,
         txelecidle2        => open,
         txelecidle3        => open,
         txmargin0          => open,                             -- simulation only
         txmargin1          => open,                             -- simulation only
         txmargin2          => open,                             -- simulation only
         txmargin3          => open,                             -- simulation only
         txswing0           => open,                             -- =1: V_OD full swing, =0 half swing
         txswing1           => open,                             -- =1: V_OD full swing, =0 half swing
         txswing2           => open,                             -- =1: V_OD full swing, =0 half swing
         txswing3           => open                              -- =1: V_OD full swing, =0 half swing
      );

      ------------------------------------------------------
      -- set default values for signals which are not used
      ------------------------------------------------------
      derr_cor_ext_rcv_int(1)               <= '0';
      reconfig_from_xcvr_int(MAX_RECONF_IF*46-1 downto 3*46) <= (others => '0');
      tx_fifo_full0_int                     <= '0';
      tx_fifo_rdptr0_int                    <= (others => '0');
      tx_fifo_wrptr0_int                    <= (others => '0');
      pex_msi_num_int                       <= (others => '0');
      r2c_err0_int                          <= '0';

      ----------------------------------------
      -- set default values for unused ports
      ----------------------------------------
      tx_2 <= '1';
      tx_3 <= '1';

      --------------------------------
      -- manage CycloneV transceiver
      --------------------------------
      cycv_trans_reconf_i0 : CycVTransReconf
         generic map(
            RECONFIG_INTERFACES => 3                             -- number of lanes +1
         )
         port map(
            -- inputs
            mgmt_clk_clk              => ref_clk,                -- CycloneV: 75-100MHz
            mgmt_rst_reset            => not_npor_int,           -- high active
            reconfig_mgmt_address     => (others => '0'),
            reconfig_mgmt_read        => '0',
            reconfig_mgmt_write       => '0',
            reconfig_mgmt_writedata   => (others => '0'),
            reconfig_from_xcvr        => reconfig_from_xcvr_int(3*46-1 downto 0),
          
            -- outputs
            reconfig_busy             => reconfig_busy_int,
            reconfig_mgmt_readdata    => open,
            reconfig_mgmt_waitrequest => open,
            reconfig_to_xcvr          => reconfig_to_xcvr_int(3*70-1 downto 0)
         );
   end generate gen_cycv_x2;
   


   gen_cycv_x4: if USE_LANES = "100" generate
      PCIeHardIP_CycV_x1_comp : PCIeHardIPCycV
      generic map(
         VENDOR_ID           => VENDOR_ID,
         DEVICE_ID           => DEVICE_ID,
         REVISION_ID         => REVISION_ID,
         CLASS_CODE          => CLASS_CODE,
         SUBSYSTEM_VENDOR_ID => SUBSYSTEM_VENDOR_ID,
         SUBSYSTEM_DEVICE_ID => SUBSYSTEM_DEVICE_ID,
         USE_LANE            => "x4",
         RECONFIG_INTERFACES => 5,                               -- number of lanes +1

         ---------------------------
         -- BAR settings for func0
         ---------------------------
         IO_SPACE_BAR_0  => IO_SPACE_0,
         PREFETCH_BAR_0  => PREFETCH_0,
         SIZE_MASK_BAR_0 => SIZE_MASK_0,
         IO_SPACE_BAR_1  => IO_SPACE_1,
         PREFETCH_BAR_1  => PREFETCH_1,
         SIZE_MASK_BAR_1 => SIZE_MASK_1,
         IO_SPACE_BAR_2  => IO_SPACE_2,
         PREFETCH_BAR_2  => PREFETCH_2,
         SIZE_MASK_BAR_2 => SIZE_MASK_2,
         IO_SPACE_BAR_3  => IO_SPACE_3,
         PREFETCH_BAR_3  => PREFETCH_3,
         SIZE_MASK_BAR_3 => SIZE_MASK_3,
         IO_SPACE_BAR_4  => IO_SPACE_4,
         PREFETCH_BAR_4  => PREFETCH_4,
         SIZE_MASK_BAR_4 => SIZE_MASK_4,
         IO_SPACE_BAR_5  => IO_SPACE_5,
         PREFETCH_BAR_5  => PREFETCH_5,
         SIZE_MASK_BAR_5 => SIZE_MASK_5,
         ROM_SIZE_MASK   => SIZE_MASK_ROM
      )
      port map(
         -- inputs:
         busy_xcvr_reconfig => reconfig_busy_int,
         app_int_sts_vec    => app_int_sts_int,
         app_msi_num        => app_msi_num_int,
         app_msi_req        => app_msi_req_int,
         app_msi_tc         => app_msi_tc_int,
         cpl_err            => cpl_err_int,
         cpl_pending(0)     => cpl_pending_int,
         lmi_addr           => (others => '0'),
         lmi_din            => (others => '0'),
         lmi_rden           => '0',
         lmi_wren           => '0',
         npor               => npor_int, 
         phystatus0         => '0',                              -- if asserted LTSSM is stuck at x"00"
         phystatus1         => '0',                              -- if asserted LTSSM is stuck at x"00"
-- pin_perst must be connected to nPERST of correct location in device
-- nPERSTL0 for top left
-- nPERSTL1 for bottom left <-- use this one first (recommended by Altera)
         pin_perst          => ext_rst_n, --'0',
         pld_clk            => core_clk_int,
         pld_core_ready     => serdes_pll_locked_int,
         pm_auxpwr          => '0',
         pm_data            => (others => '0'),
         pm_event           => '0',
         pme_to_cr          => pme_to_cr_int,
         reconfig_to_xcvr   => reconfig_to_xcvr_int(3*70-1 downto 0),
         refclk             => ref_clk,
         rx_in0             => rx_0,
         rx_in1             => rx_1,
         rx_in2             => rx_2,
         rx_in3             => rx_3,
         rx_st_mask         => rx_st_mask0_int,
         rx_st_ready        => rx_st_ready0_int,
         rxdata0            => (others => '0'),
         rxdata1            => (others => '0'),
         rxdata2            => (others => '0'),
         rxdata3            => (others => '0'),
         rxdatak0           => '0',
         rxdatak1           => '0',
         rxdatak2           => '0',
         rxdatak3           => '0',
         rxelecidle0        => '0',
         rxelecidle1        => '0',
         rxelecidle2        => '0',
         rxelecidle3        => '0',
         rxstatus0          => (others => '0'),
         rxstatus1          => (others => '0'),
         rxstatus2          => (others => '0'),
         rxstatus3          => (others => '0'),
         rxvalid0           => '0',
         rxvalid1           => '0',
         rxvalid2           => '0',
         rxvalid3           => '0',
         sim_pipe_pclk_in   => core_clk_int,                     -- simulation only
         simu_mode_pipe     => SIMULATION,                       -- indicate simulation mode
         test_in            => test_in_int(31 downto 0),
         tl_hpg_ctrl_er     => (others => '0'),                  -- hardwire to 0 for endpoints
         tx_st_data         => tx_st_data0_int,
         tx_st_eop          => tx_st_eop0_int,
         tx_st_err          => tx_st_err0_int,
         tx_st_sop          => tx_st_sop0_int,
         tx_st_valid        => tx_st_valid0_int,

         -- outputs:
         app_msi_ack        => app_msi_ack_int,
         coreclkout         => core_clk_int,
         derr_cor_ext_rcv0  => derr_cor_ext_rcv_int(0),
         derr_cor_ext_rpl   => derr_cor_ext_rpl_int,
         derr_rpl           => derr_rpl_int,
         dl_current_speed   => open,                             -- indicate current speed of PCIe link
         dl_ltssm           => int_ltssm,
         dlup_exit          => dlup_exit,
         eidleinfersel0     => open,                             -- electrical idle entry inference mechanism
         eidleinfersel1     => open,                             -- electrical idle entry inference mechanism
         eidleinfersel2     => open,                             -- electrical idle entry inference mechanism
         eidleinfersel3     => open,                             -- electrical idle entry inference mechanism
         ev128ns            => open,                             -- asserted every 128ns
         ev1us              => open,                             -- asserted every 1us
         hotrst_exit        => hotrst_exit,
         int_status         => open,                             -- defined as root port signal which shows legacy irq,
                                                                 -- int_status[0] = A, int_status[3] = D
         ko_cpl_spc_data    => open,
         ko_cpl_spc_header  => open,
         l2_exit            => l2_exit,
         lane_act           => open,
         lmi_ack            => open,
         lmi_dout           => open,
         pld_clk_inuse      => open, --pld_clk_inuse_int,
         pme_to_sr          => pme_to_sr_int,
         powerdown0         => open,
         powerdown1         => open,
         powerdown2         => open,
         powerdown3         => open,
         reconfig_from_xcvr => reconfig_from_xcvr_int(3*46-1 downto 0),
         reset_status       => reset_status_int,
         rx_st_bar          => rx_st_bardec0_int,
         rx_st_be           => rx_st_be0_int,
         rx_st_data         => rx_st_data0_int,
         rx_st_eop          => rx_st_eop0_int,
         rx_st_err          => rx_st_err0_int,
         rx_st_sop          => rx_st_sop0_int,
         rx_st_valid        => rx_st_valid0_int,
         rxpolarity0        => open,
         rxpolarity1        => open,
         rxpolarity2        => open,
         rxpolarity3        => open,
         serdes_pll_locked  => serdes_pll_locked_int,
         sim_ltssmstate     => open, --alt_bfm_sim_ltssm,                -- show LTSSM state
         sim_pipe_rate      => open, --alt_bfm_sim_pipe_rate,            -- show Gen1,2,3
         testin_zero        => open,
         tl_cfg_add         => tl_cfg_add_int,
         tl_cfg_ctl         => tl_cfg_ctl_int,
         tl_cfg_ctl_wr      => tl_cfg_ctl_wr_int,
         tl_cfg_sts         => tl_cfg_sts_int,
         tl_cfg_sts_wr      => tl_cfg_sts_wr_int,
         tx_cred_datafccp   => open,
         tx_cred_datafcnp   => open,
         tx_cred_datafcp    => open,
         tx_cred_fchipcons  => open,
         tx_cred_fcinfinite => open,
         tx_cred_hdrfccp    => open,
         tx_cred_hdrfcnp    => open,
         tx_cred_hdrfcp     => open,
         tx_fifo_empty      => tx_fifo_empty0_int,
         tx_out0            => tx_0,
         tx_out1            => tx_1,
         tx_out2            => tx_2,
         tx_out3            => tx_3,
         tx_st_ready        => tx_st_ready0_int,
         txcompl0           => open,
         txcompl1           => open,
         txcompl2           => open,
         txcompl3           => open,
         txdata0            => open,
         txdata1            => open,
         txdata2            => open,
         txdata3            => open,
         txdatak0           => open,
         txdatak1           => open,
         txdatak2           => open,
         txdatak3           => open,
         txdeemph0          => open,
         txdeemph1          => open,
         txdeemph2          => open,
         txdeemph3          => open,
         txdetectrx0        => open,
         txdetectrx1        => open,
         txdetectrx2        => open,
         txdetectrx3        => open,
         txelecidle0        => open,
         txelecidle1        => open,
         txelecidle2        => open,
         txelecidle3        => open,
         txmargin0          => open,                             -- simulation only
         txmargin1          => open,                             -- simulation only
         txmargin2          => open,                             -- simulation only
         txmargin3          => open,                             -- simulation only
         txswing0           => open,                             -- =1: V_OD full swing, =0 half swing
         txswing1           => open,                             -- =1: V_OD full swing, =0 half swing
         txswing2           => open,                             -- =1: V_OD full swing, =0 half swing
         txswing3           => open                              -- =1: V_OD full swing, =0 half swing
      );

      ------------------------------------------------------
      -- set default values for signals which are not used
      ------------------------------------------------------
      derr_cor_ext_rcv_int(1)               <= '0';
      reconfig_from_xcvr_int(MAX_RECONF_IF*46-1 downto 3*46) <= (others => '0');
      tx_fifo_full0_int                     <= '0';
      tx_fifo_rdptr0_int                    <= (others => '0');
      tx_fifo_wrptr0_int                    <= (others => '0');
      pex_msi_num_int                       <= (others => '0');
      r2c_err0_int                          <= '0';


      --------------------------------
      -- manage CycloneV transceiver
      --------------------------------
      cycv_trans_reconf_i0 : CycVTransReconf
         generic map(
            RECONFIG_INTERFACES => 5                             -- number of lanes +1
         )
         port map(
            -- inputs
            mgmt_clk_clk              => ref_clk,                -- CycloneV: 75-100MHz
            mgmt_rst_reset            => not_npor_int,           -- high active
            reconfig_mgmt_address     => (others => '0'),
            reconfig_mgmt_read        => '0',
            reconfig_mgmt_write       => '0',
            reconfig_mgmt_writedata   => (others => '0'),
            reconfig_from_xcvr        => reconfig_from_xcvr_int(3*46-1 downto 0),
          
            -- outputs
            reconfig_busy             => reconfig_busy_int,
            reconfig_mgmt_readdata    => open,
            reconfig_mgmt_waitrequest => open,
            reconfig_to_xcvr          => reconfig_to_xcvr_int(3*70-1 downto 0)
         );
   end generate gen_cycv_x4;
   


   ---------------------------------------
   -- module to convert irq_req_i vector
   -- to 16z091-01 irq behavior
   ---------------------------------------
   pcie_msi_i0 : pcie_msi
      generic map(
         WIDTH                => IRQ_WIDTH
      )
      port map(
         clk_i                => wb_clk,
         rst_i                => wb_rst,
        
         irq_req_i            => irq_req_i,
         
         wb_int_o             => int_wb_int,
         wb_pwr_enable_o      => int_wb_pwr_enable,
         wb_int_num_o         => int_wb_int_num,
         wb_int_ack_i         => int_wb_int_ack,
         wb_int_num_allowed_i => int_wb_int_num_allowed
      );

-------------------------------------------------------------------------------
end architecture ip_16z091_01_top_cycv_arch;
