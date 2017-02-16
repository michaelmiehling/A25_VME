--------------------------------------------------------------------------------
-- Title       : 16z091-01 module
-- Project     : 16z091-01
--------------------------------------------------------------------------------
-- File        : rx_ctrl.vhd
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 22.11.2010
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6a / ModelSim AE 6.5e sp1
-- Synthesis   :
--------------------------------------------------------------------------------
-- Description :
-- combines modules to build the 16z091-01 module
--------------------------------------------------------------------------------
-- Hierarchy   :
-- *  ip_16z091_01
--       rx_module
--          rx_ctrl
--          rx_get_data
--          rx_fifo
--          rx_len_cntr
--       wb_master
--       wb_slave
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

library work;
use work.fpga_pkg_2.all;

entity ip_16z091_01 is
   generic(
      FPGA_FAMILY             : family_type := NONE;
      NR_OF_WB_SLAVES         : natural range 63 DOWNTO 1    := 12;
      READY_LATENCY           : natural := 2;                                    -- only specify values between 0 and 2
      FIFO_MAX_USEDW          : std_logic_vector(9 downto 0) := "1111111001";    -- = 1017 DW;
                                                                                 -- set this value to "1111111111" - (READY_LATENCY + 1)
      WBM_SUSPEND_FIFO_ACCESS : std_logic_vector(9 downto 0) := "1111111011";    -- = 1019 DW
      WBM_RESUME_FIFO_ACCESS  : std_logic_vector(9 downto 0) := "1111110111";    -- = 1015 DW
      WBS_SUSPEND_FIFO_ACCESS : std_logic_vector(9 downto 0) := "1111111100";    -- = 1020 DW, one place spare for put_stuffing
      WBS_RESUME_FIFO_ACCESS  : std_logic_vector(9 downto 0) := "1111110111";    -- = 1015 DW
      PCIE_REQUEST_LENGTH     : std_logic_vector(9 downto 0) := "0000100000";    -- 32DW = 128Byte
      RX_FIFO_DEPTH           : natural := 1024;                                 -- valid values are: 2^(RX_LPM_WIDTHU-1) < RX_FIFO_DEPTH <= 2^(RX_LPM_WIDTHU)
      RX_LPM_WIDTHU           : natural := 10;
      TX_HEADER_FIFO_DEPTH    : natural := 32;                                   -- valid values are: 2^(TX_HEADER_LPM_WIDTHU-1) < TX_HEADER_FIFO_DEPTH <= 2^(TX_HEADER_LPM_WIDTHU) 
      TX_HEADER_LPM_WIDTHU    : natural := 5;
      TX_DATA_FIFO_DEPTH      : natural := 1024;                                 -- valid values are: 2^(TX_DATA_LPM_WIDTHU-1) < TX_DATA_FIFO_DEPTH <= 2^(TX_DATA_LPM_WIDTHU) 
      TX_DATA_LPM_WIDTHU      : natural := 10
   );
   port(
      clk                : in  std_logic;
      wb_clk             : in  std_logic;
      clk_500            : in  std_logic;                                        -- 500 Hz clock
      rst                : in  std_logic;
      wb_rst             : in  std_logic;
                           
      -- IP Core           
      core_clk           : in  std_logic;
      rx_st_data0        : in  std_logic_vector(63 downto 0);
      rx_st_err0         : in  std_logic;
      rx_st_valid0       : in  std_logic;
      rx_st_sop0         : in  std_logic;
      rx_st_eop0         : in  std_logic;
      rx_st_be0          : in  std_logic_vector(7 downto 0);
      rx_st_bardec0      : in  std_logic_vector(7 downto 0);
      tx_st_ready0       : in  std_logic;
      tx_fifo_full0      : in  std_logic;
      tx_fifo_empty0     : in  std_logic;
      tx_fifo_rdptr0     : in  std_logic_vector(3 downto 0);
      tx_fifo_wrptr0     : in  std_logic_vector(3 downto 0);
      pme_to_sr          : in  std_logic;
      tl_cfg_add         : in  std_logic_vector(3 downto 0);
      tl_cfg_ctl         : in  std_logic_vector(31 downto 0);
      tl_cfg_ctl_wr      : in  std_logic;
      tl_cfg_sts         : in  std_logic_vector(52 downto 0);
      tl_cfg_sts_wr      : in  std_logic;
      app_int_ack        : in  std_logic;
      app_msi_ack        : in  std_logic;
      
      rx_st_mask0        : out std_logic;
      rx_st_ready0       : out std_logic;
      tx_st_err0         : out std_logic;
      tx_st_valid0       : out std_logic;
      tx_st_sop0         : out std_logic;
      tx_st_eop0         : out std_logic;
      tx_st_data0        : out std_logic_vector(63 downto 0);
      pme_to_cr          : out std_logic;
      app_int_sts        : out std_logic;
      app_msi_req        : out std_logic;
      app_msi_tc         : out std_logic_vector(2 downto 0);
      app_msi_num        : out std_logic_vector(4 downto 0);
      pex_msi_num        : out std_logic_vector(4 downto 0);
      
      derr_cor_ext_rcv   : in  std_logic_vector(1 downto 0);
      derr_cor_ext_rpl   : in  std_logic;
      derr_rpl           : in  std_logic;
      r2c_err0           : in  std_logic;
      cpl_err            : out std_logic_vector(6 downto 0);
      cpl_pending        : out std_logic;
      
      -- Wishbone master
      wbm_ack            : in  std_logic;
      wbm_dat_i          : in  std_logic_vector(31 downto 0);
      wbm_stb            : out std_logic;
      --wbm_cyc            : out std_logic;
      wbm_cyc_o          : out std_logic_vector(NR_OF_WB_SLAVES - 1 downto 0);    --new
      wbm_we             : out std_logic;
      wbm_sel            : out std_logic_vector(3 downto 0);
      wbm_adr            : out std_logic_vector(31 downto 0);
      wbm_dat_o          : out std_logic_vector(31 downto 0);
      wbm_cti            : out std_logic_vector(2 downto 0);
      wbm_tga            : out std_logic;
      --wb_bar_dec         : out std_logic_vector(6 downto 0);                  
      
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
      wb_int             : in  std_logic;
      wb_pwr_enable      : in  std_logic;
      wb_int_num         : in  std_logic_vector(4 downto 0);
      wb_int_ack         : out std_logic;
      wb_int_num_allowed : out std_logic_vector(5 downto 0);
      
      -- error
      error_timeout      : out std_logic;
      error_cor_ext_rcv  : out std_logic_vector(1 downto 0);
      error_cor_ext_rpl  : out std_logic;
      error_rpl          : out std_logic;
      error_r2c0         : out std_logic;
      error_msi_num      : out std_logic;
      
      -- debug port
      rx_debug_out       : out std_logic_vector(3 downto 0)
   );
end entity ip_16z091_01;

architecture ip_16z091_01_arch of ip_16z091_01 is

-- functions ------------------------------------------------------------------
function convert_family(
   fpga_family_in : family_type
) return string is
begin
   case fpga_family_in is
      when CYCLONE4  => return "Cyclone IV GX";
      when CYCLONE5  => return "Cyclone V";
      when ARRIA2_GX => return "Arria II GX";
      when others    => 
         assert false report "undefined family_type in function convert_family in rx_module.vhd" severity failure;
         return "none";
   end case;
end function convert_family;

-- constants ------------------------------------------------------------------
constant DEVICE_FAMILY_INT : string := convert_family(FPGA_FAMILY);

-- internal signals -----------------------------------------------------------
-- rx_module:
signal rx_fifo_wr_out_int         : std_logic_vector(31 downto 0);
signal rx_fifo_wr_empty_int       : std_logic;
signal rx_fifo_wr_rd_enable_int   : std_logic;
signal rx_fifo_c_rd_enable_int    : std_logic;
signal rx_fifo_c_empty_int        : std_logic;
signal rx_fifo_c_out_int          : std_logic_vector(31 downto 0);
signal tag_nbr_int                : std_logic_vector(7 downto 0);
signal rx_tag_rcvd_int            : std_logic;      
signal ecrc_err_int               : std_logic;
signal type_fmt_err_int           : std_logic_vector(1 downto 0);

-- tx_module:
signal tx_fifo_c_head_clr_int     : std_logic;
signal tx_fifo_c_data_clr_int     : std_logic;
signal tx_fifo_c_head_full_int    : std_logic;
signal tx_fifo_c_data_full_int    : std_logic;
signal tx_fifo_c_data_usedw_int   : std_logic_vector(9 downto 0);
signal tx_fifo_c_head_enable_int  : std_logic;
signal tx_fifo_c_data_enable_int  : std_logic;
signal tx_fifo_c_head_in_int      : std_logic_vector(31 downto 0);
signal tx_fifo_c_data_in_int      : std_logic_vector(31 downto 0);
signal bus_dev_func_int           : std_logic_vector(15 downto 0);
signal max_read_int               : std_logic_vector(2 downto 0);
signal max_payload_int            : std_logic_vector(2 downto 0);
signal tx_fifo_wr_head_clr_int    : std_logic;
signal tx_fifo_wr_head_enable_int : std_logic;
signal tx_fifo_wr_head_in_int     : std_logic_vector(31 downto 0);
signal tx_fifo_wr_head_full_int   : std_logic;
signal tx_fifo_w_data_clr_int     : std_logic;
signal tx_fifo_w_data_enable_int  : std_logic;
signal tx_fifo_w_data_in_int      : std_logic_vector(31 downto 0);
signal tx_fifo_w_data_full_int    : std_logic;
signal tx_fifo_w_data_usedw_int   : std_logic_vector(9 downto 0);
signal tx_fifo_wr_head_usedw_int  : std_logic_vector(4 downto 0);

-- error:
signal ecrc_err_wb_int            : std_logic;
signal tag_id_wb_int              : std_logic_vector(7 downto 0);
signal tx_timeout_int             : std_logic;
signal timeout_wb_int             : std_logic;
signal wb_num_err_int             : std_logic;
signal tx_compl_abort_int         : std_logic;

-- interrupt
signal cfg_msicsr_int  : std_logic_vector(15 downto 0);
signal wb_pwr_en_int   : std_logic;
signal wb_num_int_int  : std_logic_vector(4 downto 0);
signal wb_inter_int    : std_logic;
signal inter_ack_int   : std_logic;
signal num_allowed_int : std_logic_vector(5 downto 0);
signal ack_ok_int      : std_logic;
-------------------------------------------------------------------------------

-- components -----------------------------------------------------------------
component rx_module
   generic(
      DEVICE_FAMILY  : string := "unused";
      READY_LATENCY  : natural := 2;                                             -- only specify values between 0 and 2
      FIFO_MAX_USEDW : std_logic_vector(9 downto 0) := "1111111001";             -- = 1017 DW;
                                                                                 -- set this value to "1111111111" - (READY_LATENCY + 1)
      RX_FIFO_DEPTH  : natural := 1024;                                          -- valid values are: 2^(RX_LPM_WIDTHU-1) < RX_FIFO_DEPTH <= 2^(RX_LPM_WIDTHU)
      RX_LPM_WIDTHU  : natural := 10
   );
   port(
      clk                  : in  std_logic;
      wb_clk               : in  std_logic;
      rst                  : in  std_logic;
                           
      -- IP Core           
      rx_st_data0          : in  std_logic_vector(63 downto 0);
      rx_st_err0           : in  std_logic;
      rx_st_valid0         : in  std_logic;
      rx_st_sop0           : in  std_logic;
      rx_st_eop0           : in  std_logic;
      rx_st_be0            : in  std_logic_vector(7 downto 0);
      rx_st_bardec0        : in  std_logic_vector(7 downto 0);
      rx_st_mask0          : out std_logic;
      rx_st_ready0         : out std_logic;
      
      -- FIFO
      rx_fifo_c_rd_enable  : in  std_logic;
      rx_fifo_wr_rd_enable : in  std_logic;
      rx_fifo_c_empty      : out std_logic;
      rx_fifo_wr_empty     : out std_logic;
      rx_fifo_c_out        : out std_logic_vector(31 downto 0);
      rx_fifo_wr_out       : out std_logic_vector(31 downto 0);
      
      -- Tx Module
      rx_tag_nbr           : out std_logic_vector(7 downto 0);
      rx_tag_rcvd          : out std_logic;
      
      -- error
      rx_type_fmt_err      : out std_logic_vector(1 downto 0);
      rx_ecrc_err          : out std_logic;
      
      -- debug port
      rx_debug_out         : out std_logic_vector(3 downto 0)
   );
end component;

component z091_01_wb_master
   generic(
      NR_OF_WB_SLAVES       : natural range 63 DOWNTO 1    := 12;
      SUSPEND_FIFO_ACCESS   : std_logic_vector(9 downto 0) := "1111111011";      -- = 1019 DW
      RESUME_FIFO_ACCESS    : std_logic_vector(9 downto 0) := "1111110111"       -- = 1015 DW
   );
   port(
      wb_clk                : in  std_logic;
      wb_rst                : in  std_logic;
      
      -- Rx Module
      rx_fifo_wr_out        : in  std_logic_vector(31 downto 0);
      rx_fifo_wr_empty      : in  std_logic;
      rx_fifo_wr_rd_enable  : out std_logic;
      
      -- Tx Module
      tx_fifo_c_head_full   : in  std_logic;
      tx_fifo_c_data_full   : in  std_logic;
      tx_fifo_c_data_usedw  : in  std_logic_vector(9 downto 0);
      tx_fifo_c_head_enable : out std_logic;
      tx_fifo_c_data_enable : out std_logic;
      tx_fifo_c_head_in     : out std_logic_vector(31 downto 0);
      tx_fifo_c_data_in     : out std_logic_vector(31 downto 0);
      tx_fifo_c_data_clr    : out std_logic;
      tx_fifo_c_head_clr    : out std_logic;
      
      -- Wishbone
      wbm_ack               : in  std_logic;
      wbm_dat_i             : in  std_logic_vector(31 downto 0);
      wbm_stb               : out std_logic;
      --wbm_cyc               : out std_logic;
      wbm_cyc_o             : out std_logic_vector(NR_OF_WB_SLAVES - 1 downto 0);    --new
      wbm_we                : out std_logic;
      wbm_sel               : out std_logic_vector(3 downto 0);
      wbm_adr               : out std_logic_vector(31 downto 0);
      wbm_dat_o             : out std_logic_vector(31 downto 0);
      wbm_cti               : out std_logic_vector(2 downto 0);
      wbm_tga               : out std_logic;
      --wb_bar_dec            : out std_logic_vector(6 downto 0);
      
      -- error
      ecrc_err_in           : in  std_logic;
      err_tag_id            : in  std_logic_vector(7 downto 0);
      ecrc_err_out          : out std_logic
   );
end component;

component error
   port(
      clk               : in  std_logic;
      rst               : in  std_logic;
      wb_clk            : in  std_logic;
      wb_rst            : in  std_logic;
      
      -- RxModule
      rx_tag_id         : in  std_logic_vector(7 downto 0);
      rx_ecrc_err       : in  std_logic;
      rx_type_fmt_err   : in  std_logic_vector(1 downto 0);
      
      -- TxModule
      tx_compl_abort    : in  std_logic;
      tx_timeout        : in  std_logic;
      
      -- Interrupt
      wb_num_err        : in  std_logic;
      
      -- Wishbone
      error_ecrc_err    : out std_logic;
      error_timeout     : out std_logic;
      error_tag_id      : out std_logic_vector(7 downto 0);
      error_cor_ext_rcv : out std_logic_vector(1 downto 0);
      error_cor_ext_rpl : out std_logic;
      error_rpl         : out std_logic;
      error_r2c0        : out std_logic;
      error_msi_num     : out std_logic;
      
      -- IP Core
      derr_cor_ext_rcv  : in  std_logic_vector(1 downto 0);
      derr_cor_ext_rpl  : in  std_logic;
      derr_rpl          : in  std_logic;
      r2c_err0          : in  std_logic;
      cpl_err           : out std_logic_vector(6 downto 0);
      cpl_pending       : out std_logic
   );
end component;

component tx_module
   generic(
      DEVICE_FAMILY        : string  := "unused";
      TX_HEADER_FIFO_DEPTH : natural := 32;                                      -- valid values are: 2^(TX_HEADER_LPM_WIDTHU-1) < TX_HEADER_FIFO_DEPTH <= 2^(TX_HEADER_LPM_WIDTHU) 
      TX_HEADER_LPM_WIDTHU : natural := 5;
      TX_DATA_FIFO_DEPTH   : natural := 1024;                                    -- valid values are: 2^(TX_DATA_LPM_WIDTHU-1) < TX_DATA_FIFO_DEPTH <= 2^(TX_DATA_LPM_WIDTHU) 
      TX_DATA_LPM_WIDTHU   : natural := 10
   );
   port(
      clk                    : in  std_logic;
      rst                    : in  std_logic;
      wb_clk                 : in  std_logic;
      wb_rst                 : in  std_logic;
      clk_500                : in  std_logic;                                        -- 500 Hz clock
      
      -- IP Core
      tx_st_ready0           : in  std_logic;
      tx_fifo_full0          : in  std_logic;
      tx_fifo_empty0         : in  std_logic;
      tx_fifo_rdptr0         : in  std_logic_vector(3 downto 0);
      tx_fifo_wrptr0         : in  std_logic_vector(3 downto 0);
      pme_to_sr              : in  std_logic;
      tx_st_err0             : out std_logic;
      tx_st_valid0           : out std_logic;
      tx_st_sop0             : out std_logic;
      tx_st_eop0             : out std_logic;
      tx_st_data0            : out std_logic_vector(63 downto 0);
      pme_to_cr              : out std_logic;
      
      -- Rx Module
      rx_tag_nbr             : in  std_logic_vector(7 downto 0);
      rx_tag_rcvd            : in  std_logic;
      
      -- Wishbone Master
      tx_fifo_c_data_clr     : in  std_logic;
      tx_fifo_c_head_clr     : in  std_logic;
      tx_fifo_c_head_enable  : in  std_logic;
      tx_fifo_c_data_enable  : in  std_logic;
      tx_fifo_c_head_in      : in  std_logic_vector(31 downto 0);
      tx_fifo_c_data_in      : in  std_logic_vector(31 downto 0);
      tx_fifo_c_head_full    : out std_logic;
      tx_fifo_c_data_full    : out std_logic;
      tx_fifo_c_data_usedw   : out std_logic_vector(9 downto 0);
      
      -- Wishbone Slave
      tx_fifo_wr_head_clr    : in  std_logic;
      tx_fifo_wr_head_enable : in  std_logic;
      tx_fifo_wr_head_in     : in  std_logic_vector(31 downto 0);
      tx_fifo_w_data_clr     : in  std_logic;
      tx_fifo_w_data_enable  : in  std_logic;
      tx_fifo_w_data_in      : in  std_logic_vector(31 downto 0);
      tx_fifo_wr_head_full   : out std_logic;
      tx_fifo_w_data_full    : out std_logic;
      tx_fifo_w_data_usedw   : out std_logic_vector(9 downto 0);
      tx_fifo_wr_head_usedw  : out std_logic_vector(4 downto 0);
      
      -- init
      bus_dev_func           : in  std_logic_vector(15 downto 0);
      max_payload            : in  std_logic_vector(2 downto 0);
      
      -- error
      tx_compl_abort         : out std_logic;
      tx_timeout             : out std_logic
   );
end component;

component init
   port(
      core_clk      : in  std_logic;                                             -- synchronous to core_clk from hard IP core
      clk           : in  std_logic;
      rst           : in  std_logic;
      
      -- IP core
      tl_cfg_add    : in  std_logic_vector(3 downto 0);
      tl_cfg_ctl    : in  std_logic_vector(31 downto 0);
      tl_cfg_ctl_wr : in  std_logic;
      tl_cfg_sts    : in  std_logic_vector(52 downto 0);
      tl_cfg_sts_wr : in  std_logic;
      
      -- interrupt module
      cfg_msicsr    : out std_logic_vector(15 downto 0);
      
      -- Tx Module
      bus_dev_func  : out std_logic_vector(15 downto 0);
      max_read      : out std_logic_vector(2 downto 0);
      max_payload   : out std_logic_vector(2 downto 0)
   );
end component;

component z091_01_wb_slave
   generic(
      PCIE_REQUEST_LENGTH   : std_logic_vector(9 downto 0) := "0000100000";      -- 32DW = 128Byte
      SUSPEND_FIFO_ACCESS   : std_logic_vector(9 downto 0) := "1111111100";      -- = 1020 DW, must be < or = (FIFO max size - 6)
      RESUME_FIFO_ACCESS    : std_logic_vector(9 downto 0) := "1111110111"       -- = 1015 DW
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
      wbs_tga                : in  std_logic;                                    -- 0: memory, 1: I/O
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
end component;

component interrupt_core
   port(
      clk         : in  std_logic;
      rst         : in  std_logic;
      
      -- IP Core
      app_int_ack : in  std_logic;
      app_msi_ack : in  std_logic;
      app_int_sts : out std_logic;
      app_msi_req : out std_logic;
      app_msi_tc  : out std_logic_vector(2 downto 0);
      app_msi_num : out std_logic_vector(4 downto 0);
      pex_msi_num : out std_logic_vector(4 downto 0);
      
      -- interrupt_wb
      wb_pwr_en   : in  std_logic;
      wb_num_int  : in  std_logic_vector(4 downto 0);
      wb_inter    : in  std_logic;
      ack_ok      : in  std_logic;
      inter_ack   : out std_logic;
      num_allowed : out std_logic_vector(5 downto 0);
      
      -- init
      cfg_msicsr         : in  std_logic_vector(15 downto 0);
      
      -- error
      wb_num_err         : out std_logic
   );
end component;

component interrupt_wb
   port(
      wb_clk             : in  std_logic;
      wb_rst             : in  std_logic;
      
      -- interrupt_core
      inter_ack          : in  std_logic;
      num_allowed        : in  std_logic_vector(5 downto 0);
      wb_pwr_en          : out std_logic;
      wb_num_int         : out std_logic_vector(4 downto 0);
      wb_inter           : out std_logic;
      ack_ok             : out std_logic;
      
      -- Wishbone
      wb_int             : in  std_logic;
      wb_pwr_enable      : in  std_logic;                                        -- =1 if wb_int_num should be for power management, else
                                                                                 -- for normal interrupt
      wb_int_num         : in  std_logic_vector(4 downto 0);
      wb_int_ack         : out std_logic;
      wb_int_num_allowed : out std_logic_vector(5 downto 0)                     -- =0 if MSI not allowed, else: nbr. of allocated signals
   );
end component;
-------------------------------------------------------------------------------

begin
   -- instanciate components --------------------------------------------------
   rx_module_comp : rx_module
      generic map( 
         DEVICE_FAMILY  => DEVICE_FAMILY_INT,
         READY_LATENCY  => READY_LATENCY,
         FIFO_MAX_USEDW => FIFO_MAX_USEDW,
         RX_FIFO_DEPTH  => RX_FIFO_DEPTH,
         RX_LPM_WIDTHU  => RX_LPM_WIDTHU
      )
      port map(
         clk                  => clk,
         wb_clk               => wb_clk,
         rst                  => rst,
                              
         -- IP Core           
         rx_st_data0          => rx_st_data0,
         rx_st_err0           => rx_st_err0,
         rx_st_valid0         => rx_st_valid0,
         rx_st_sop0           => rx_st_sop0,
         rx_st_eop0           => rx_st_eop0,
         rx_st_be0            => rx_st_be0,
         rx_st_bardec0        => rx_st_bardec0,
         rx_st_mask0          => rx_st_mask0,
         rx_st_ready0         => rx_st_ready0,
         
         -- FIFO
         rx_fifo_c_rd_enable  => rx_fifo_c_rd_enable_int,
         rx_fifo_wr_rd_enable => rx_fifo_wr_rd_enable_int,
         rx_fifo_c_empty      => rx_fifo_c_empty_int,
         rx_fifo_wr_empty     => rx_fifo_wr_empty_int,
         rx_fifo_c_out        => rx_fifo_c_out_int,
         rx_fifo_wr_out       => rx_fifo_wr_out_int,

         -- Tx Module
         rx_tag_nbr           => tag_nbr_int,
         rx_tag_rcvd          => rx_tag_rcvd_int,
         
         -- error
         rx_type_fmt_err      => type_fmt_err_int,
         rx_ecrc_err          => ecrc_err_int,
         
         -- debug port
         rx_debug_out         => rx_debug_out
      );
   
   wb_master_comp : z091_01_wb_master
      generic map(
         NR_OF_WB_SLAVES       => NR_OF_WB_SLAVES,
         SUSPEND_FIFO_ACCESS   => WBM_SUSPEND_FIFO_ACCESS,
         RESUME_FIFO_ACCESS    => WBM_RESUME_FIFO_ACCESS
      )
      port map(
         wb_clk                => wb_clk,
         wb_rst                => wb_rst,
         
         -- Rx Module
         rx_fifo_wr_out        => rx_fifo_wr_out_int,
         rx_fifo_wr_empty      => rx_fifo_wr_empty_int,
         rx_fifo_wr_rd_enable  => rx_fifo_wr_rd_enable_int,
         
         -- Tx Module
         tx_fifo_c_head_full   => tx_fifo_c_head_full_int,
         tx_fifo_c_data_full   => tx_fifo_c_data_full_int,
         tx_fifo_c_data_usedw  => tx_fifo_c_data_usedw_int,
         tx_fifo_c_head_enable => tx_fifo_c_head_enable_int,
         tx_fifo_c_data_enable => tx_fifo_c_data_enable_int,
         tx_fifo_c_head_in     => tx_fifo_c_head_in_int,
         tx_fifo_c_data_in     => tx_fifo_c_data_in_int,
         tx_fifo_c_data_clr    => tx_fifo_c_data_clr_int,
         tx_fifo_c_head_clr    => tx_fifo_c_head_clr_int,
         
         -- Wishbone
         wbm_ack               => wbm_ack,
         wbm_dat_i             => wbm_dat_i,
         wbm_stb               => wbm_stb,
         --wbm_cyc               => wbm_cyc,
         wbm_cyc_o             => wbm_cyc_o,
         wbm_we                => wbm_we,
         wbm_sel               => wbm_sel,
         wbm_adr               => wbm_adr,
         wbm_dat_o             => wbm_dat_o,
         wbm_cti               => wbm_cti,
         wbm_tga               => wbm_tga,
         --wb_bar_dec            => wb_bar_dec,
         
         -- error
         ecrc_err_in           => ecrc_err_wb_int,
         err_tag_id            => tag_id_wb_int,
         ecrc_err_out          => open
      );
   
   error_comp : error
      port map(
         clk              => clk,
         rst              => rst,
         wb_clk           => wb_clk,
         wb_rst           => wb_rst,

         -- RxModule
         rx_tag_id        => tag_nbr_int,
         rx_ecrc_err      => ecrc_err_int,
         rx_type_fmt_err  => type_fmt_err_int,

         -- TxModule
         tx_compl_abort   => tx_compl_abort_int,
         tx_timeout       => tx_timeout_int,
         
         -- Interrupt
         wb_num_err        => wb_num_err_int,
         
         -- Wishbone
         error_ecrc_err    => ecrc_err_wb_int,
         error_timeout     => timeout_wb_int,
         error_tag_id      => tag_id_wb_int,
         error_cor_ext_rcv => error_cor_ext_rcv,
         error_cor_ext_rpl => error_cor_ext_rpl,
         error_rpl         => error_rpl,
         error_r2c0        => error_r2c0,
         error_msi_num     => error_msi_num,

         -- IP Core
         derr_cor_ext_rcv => derr_cor_ext_rcv,
         derr_cor_ext_rpl => derr_cor_ext_rpl,
         derr_rpl         => derr_rpl,
         r2c_err0         => r2c_err0,
         cpl_err          => cpl_err,
         cpl_pending      => cpl_pending
      );
      
   tx_module_comp : tx_module
      generic map(
         DEVICE_FAMILY        => DEVICE_FAMILY_INT,
         TX_HEADER_FIFO_DEPTH => TX_HEADER_FIFO_DEPTH,
         TX_HEADER_LPM_WIDTHU => TX_HEADER_LPM_WIDTHU,
         TX_DATA_FIFO_DEPTH   => TX_DATA_FIFO_DEPTH,
         TX_DATA_LPM_WIDTHU   => TX_DATA_LPM_WIDTHU
      )
      port map(
         clk                    => clk,
         rst                    => rst,
         wb_clk                 => wb_clk,
         wb_rst                 => wb_rst,
         clk_500                => clk_500,
         
         -- IP Core
         tx_st_ready0           => tx_st_ready0,
         tx_fifo_full0          => tx_fifo_full0,
         tx_fifo_empty0         => tx_fifo_empty0,
         tx_fifo_rdptr0         => tx_fifo_rdptr0,
         tx_fifo_wrptr0         => tx_fifo_wrptr0,
         pme_to_sr              => pme_to_sr,
         tx_st_err0             => tx_st_err0,
         tx_st_valid0           => tx_st_valid0,
         tx_st_sop0             => tx_st_sop0,
         tx_st_eop0             => tx_st_eop0,
         tx_st_data0            => tx_st_data0,
         pme_to_cr              => pme_to_cr,
         
         -- Wishbone Master
         tx_fifo_c_data_clr     => tx_fifo_c_data_clr_int,
         tx_fifo_c_head_clr     => tx_fifo_c_head_clr_int,
         tx_fifo_c_head_enable  => tx_fifo_c_head_enable_int,
         tx_fifo_c_data_enable  => tx_fifo_c_data_enable_int,
         tx_fifo_c_head_in      => tx_fifo_c_head_in_int,
         tx_fifo_c_data_in      => tx_fifo_c_data_in_int,
         tx_fifo_c_head_full    => tx_fifo_c_head_full_int,
         tx_fifo_c_data_full    => tx_fifo_c_data_full_int,
         tx_fifo_c_data_usedw   => tx_fifo_c_data_usedw_int,
         
         -- Wishbone Slave
         tx_fifo_wr_head_clr    => tx_fifo_wr_head_clr_int,
         tx_fifo_wr_head_enable => tx_fifo_wr_head_enable_int,
         tx_fifo_wr_head_in     => tx_fifo_wr_head_in_int,
         tx_fifo_wr_head_full   => tx_fifo_wr_head_full_int,
         tx_fifo_w_data_clr     => tx_fifo_w_data_clr_int,
         tx_fifo_w_data_enable  => tx_fifo_w_data_enable_int,
         tx_fifo_w_data_in      => tx_fifo_w_data_in_int,
         tx_fifo_w_data_full    => tx_fifo_w_data_full_int,
         tx_fifo_w_data_usedw   => tx_fifo_w_data_usedw_int,
         tx_fifo_wr_head_usedw  => tx_fifo_wr_head_usedw_int,
         
         -- Rx Module
         rx_tag_nbr             => tag_nbr_int,
         rx_tag_rcvd            => rx_tag_rcvd_int,
         
         -- init
         bus_dev_func           => bus_dev_func_int,
         -- max_read               => max_read_int,
         max_payload            => max_payload_int,
         
         -- error
         tx_compl_abort         => tx_compl_abort_int,
         tx_timeout             => tx_timeout_int
      );
   
   init_comp : init
      port map(
         core_clk      => core_clk,                                              -- synchronous to core_clk from hard IP core
         clk           => clk,
         rst           => rst,
         
         -- IP core
         tl_cfg_add    => tl_cfg_add,
         tl_cfg_ctl    => tl_cfg_ctl,
         tl_cfg_ctl_wr => tl_cfg_ctl_wr,
         tl_cfg_sts    => tl_cfg_sts,
         tl_cfg_sts_wr => tl_cfg_sts_wr,
         
         -- interrupt module
         cfg_msicsr    => cfg_msicsr_int,
         
         -- Tx Module
         bus_dev_func  => bus_dev_func_int,
         max_read      => max_read_int,
         max_payload   => max_payload_int
      );
   
   wb_slave_comp : z091_01_wb_slave
      generic map(
         PCIE_REQUEST_LENGTH   => PCIE_REQUEST_LENGTH,                           -- 32DW = 128Byte
         SUSPEND_FIFO_ACCESS   => WBS_SUSPEND_FIFO_ACCESS,                       -- = 1020 DW, one place spare for put_stuffing
         RESUME_FIFO_ACCESS    => WBS_RESUME_FIFO_ACCESS                         -- = 1015 DW
      )
      port map(
         wb_clk                 => wb_clk,
         wb_rst                 => wb_rst,
         
         -- Wishbone
         wbs_cyc                => wbs_cyc,
         wbs_stb                => wbs_stb,
         wbs_we                 => wbs_we,
         wbs_sel                => wbs_sel,
         wbs_adr                => wbs_adr,
         wbs_dat_i              => wbs_dat_i,
         wbs_cti                => wbs_cti,
         wbs_tga                => wbs_tga,
         wbs_ack                => wbs_ack,
         wbs_err                => wbs_err,
         wbs_dat_o              => wbs_dat_o,
         
         -- Rx Module
         rx_fifo_c_empty        => rx_fifo_c_empty_int,
         rx_fifo_c_out          => rx_fifo_c_out_int,
         rx_fifo_c_rd_enable    => rx_fifo_c_rd_enable_int,
         
         -- Tx Module
         tx_fifo_wr_head_full   => tx_fifo_wr_head_full_int,
         tx_fifo_w_data_full    => tx_fifo_w_data_full_int,
         tx_fifo_w_data_usedw   => tx_fifo_w_data_usedw_int,
         tx_fifo_wr_head_usedw  => tx_fifo_wr_head_usedw_int,
         tx_fifo_wr_head_clr    => tx_fifo_wr_head_clr_int,
         tx_fifo_wr_head_enable => tx_fifo_wr_head_enable_int,
         tx_fifo_wr_head_in     => tx_fifo_wr_head_in_int,
         tx_fifo_w_data_clr     => tx_fifo_w_data_clr_int,
         tx_fifo_w_data_enable  => tx_fifo_w_data_enable_int,
         tx_fifo_w_data_in      => tx_fifo_w_data_in_int,
         
         max_read               => max_read_int,
         
         -- error
         error_ecrc_err         => ecrc_err_wb_int,
         error_timeout          => timeout_wb_int
      );
      
   interrupt_core_comp : interrupt_core
      port map(
         clk          => clk,
         rst          => rst,
         
         -- IP Core
         app_int_ack => app_int_ack,
         app_msi_ack => app_msi_ack,
         app_int_sts => app_int_sts,
         app_msi_req => app_msi_req,
         app_msi_tc  => app_msi_tc,
         app_msi_num => app_msi_num,
         pex_msi_num => pex_msi_num,
         
         -- interrupt_wb
         wb_pwr_en   => wb_pwr_en_int,
         wb_num_int  => wb_num_int_int,
         wb_inter    => wb_inter_int,
         ack_ok      => ack_ok_int,
         inter_ack   => inter_ack_int,
         num_allowed => num_allowed_int,
         
         -- init
         cfg_msicsr  => cfg_msicsr_int,
         
         -- error
         wb_num_err  => wb_num_err_int
      );

   interrupt_wb_comp : interrupt_wb
      port map(
         wb_clk             => wb_clk,
         wb_rst             => wb_rst,
         
         -- interrupt_core
         inter_ack          => inter_ack_int,
         num_allowed        => num_allowed_int,
         wb_pwr_en          => wb_pwr_en_int,
         wb_num_int         => wb_num_int_int,
         wb_inter           => wb_inter_int,
         ack_ok             => ack_ok_int,
         
         
         -- Wishbone
         wb_int             => wb_int,
         wb_pwr_enable      => wb_pwr_enable,
         wb_int_num         => wb_int_num,
         wb_int_ack         => wb_int_ack,
         wb_int_num_allowed => wb_int_num_allowed
      );
-------------------------------------------------------------------------------
   error_timeout <= timeout_wb_int;
-------------------------------------------------------------------------------
end architecture ip_16z091_01_arch;
