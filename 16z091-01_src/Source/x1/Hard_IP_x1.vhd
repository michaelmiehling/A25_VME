-- megafunction wizard: %IP Compiler for PCI Express v11.0%
-- GENERATION: XML
-- ============================================================
-- Megafunction Name(s):
-- ============================================================

--Legal Notice: (C)2011 Altera Corporation. All rights reserved.  Your
--use of Altera Corporation's design tools, logic functions and other
--software and tools, and its AMPP partner logic functions, and any
--output files any of the foregoing (including device programming or
--simulation files), and any associated documentation or information are
--expressly subject to the terms and conditions of the Altera Program
--License Subscription Agreement or other applicable license agreement,
--including, without limitation, that your use is for the sole purpose
--of programming logic devices manufactured by Altera and sold by Altera
--or its authorized distributors.  Please refer to the applicable
--agreement for further details.


-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library altera_mf;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--$Revision: #1 
--Phy type: Cyclone IV GX Hard IP 
--Number of Lanes: 1
--Ref Clk Freq: 100Mhz
--Number of VCs: 1
entity hard_ip_x1 is 
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
end entity hard_ip_x1;


architecture europa of hard_ip_x1 is
  component hard_ip_x1_serdes is
PORT (
    signal rx_dataout : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal pll_locked : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal pipeelecidle : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal reconfig_fromgxb : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal pipedatavalid : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal pipestatus : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal rx_ctrldetect : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal tx_dataout : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal hip_tx_clkout : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal pipephydonestatus : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal rx_freqlocked : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal tx_forceelecidle : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal pipe8b10binvpolarity : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal tx_forcedispcompliance : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal tx_digitalreset : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal rx_digitalreset : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal fixedclk : IN STD_LOGIC;
        signal rx_elecidleinfersel : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal reconfig_togxb : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal cal_blk_clk : IN STD_LOGIC;
        signal rx_analogreset : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal powerdn : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal reconfig_clk : IN STD_LOGIC;
        signal tx_ctrlenable : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal gxb_powerdown : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal rx_datain : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal pll_inclk : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal tx_datain : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal pll_areset : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal tx_detectrxloop : IN STD_LOGIC_VECTOR (0 DOWNTO 0)
      );
  end component hard_ip_x1_serdes;
  component altpcie_rs_serdes is
PORT (
    signal rxanalogreset : OUT STD_LOGIC;
        signal txdigitalreset : OUT STD_LOGIC;
        signal rxdigitalreset : OUT STD_LOGIC;
        signal rx_pll_locked : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal pll_locked : IN STD_LOGIC;
        signal ltssm : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal npor : IN STD_LOGIC;
        signal use_c4gx_serdes : IN STD_LOGIC;
        signal rc_inclk_eq_125mhz : IN STD_LOGIC;
        signal rx_signaldetect : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal fifo_err : IN STD_LOGIC;
        signal detect_mask_rxdrst : IN STD_LOGIC;
        signal test_in : IN STD_LOGIC_VECTOR (39 DOWNTO 0);
        signal pld_clk : IN STD_LOGIC;
        signal busy_altgxb_reconfig : IN STD_LOGIC;
        signal rx_freqlocked : IN STD_LOGIC_VECTOR (7 DOWNTO 0)
      );
  end component altpcie_rs_serdes;
  component hard_ip_x1_core is
   generic(
      MEN_VENDOR_ID           : natural := 16#1A88#;
      MEN_DEVICE_ID           : natural := 16#4D45#;
      MEN_REVISION_ID         : natural := 16#0#;
      MEN_CLASS_CODE          : natural := 16#068000#;
      MEN_SUBSYSTEM_VENDOR_ID : natural := 16#9B#;
      MEN_SUBSYSTEM_DEVICE_ID : natural := 16#5A91#;

      MEN_IO_SPACE_BAR_0  : string  := "false";
      MEN_PREFETCH_BAR_0  : string  := "true";
      MEN_SIZE_MASK_BAR_0 : natural := 28;
      
      MEN_IO_SPACE_BAR_1  : string  := "false";
      MEN_PREFETCH_BAR_1  : string  := "true";
      MEN_SIZE_MASK_BAR_1 : natural := 18;
      
      MEN_IO_SPACE_BAR_2  : string  := "false";
      MEN_PREFETCH_BAR_2  : string  := "false";
      MEN_SIZE_MASK_BAR_2 : natural := 19;
      
      MEN_IO_SPACE_BAR_3  : string  := "false";
      MEN_PREFETCH_BAR_3  : string  := "false";
      MEN_SIZE_MASK_BAR_3 : natural := 7;
      
      MEN_IO_SPACE_BAR_4  : string  := "true";
      MEN_PREFETCH_BAR_4  : string  := "false";
      MEN_SIZE_MASK_BAR_4 : natural := 5;
      
      MEN_IO_SPACE_BAR_5  : string  := "true";
      MEN_PREFETCH_BAR_5  : string  := "false";
      MEN_SIZE_MASK_BAR_5 : natural := 6      
   );
PORT (
    signal tl_cfg_ctl_wr : OUT STD_LOGIC;
        signal l2_exit : OUT STD_LOGIC;
        signal app_msi_ack : OUT STD_LOGIC;
        signal rc_rx_digitalreset : OUT STD_LOGIC;
        signal CraWaitRequest_o : OUT STD_LOGIC;
        signal derr_rpl : OUT STD_LOGIC;
        signal txelecidle0_ext : OUT STD_LOGIC;
        signal rx_st_sop0_p1 : OUT STD_LOGIC;
        signal rx_fifo_empty0 : OUT STD_LOGIC;
        signal test_out : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
        signal suc_spd_neg : OUT STD_LOGIC;
        signal hip_extraclkout : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal derr_cor_ext_rcv0 : OUT STD_LOGIC;
        signal CraIrq_o : OUT STD_LOGIC;
        signal rx_st_eop0 : OUT STD_LOGIC;
        signal lane_act : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal derr_cor_ext_rpl : OUT STD_LOGIC;
        signal rx_st_be0 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal tx_st_ready0 : OUT STD_LOGIC;
        signal core_clk_out : OUT STD_LOGIC;
        signal hotrst_exit : OUT STD_LOGIC;
        signal txdata0_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal r2c_err0 : OUT STD_LOGIC;
        signal powerdown0_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal rx_st_data0 : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
        signal pme_to_sr : OUT STD_LOGIC;
        signal CraReadData_o : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal reset_status : OUT STD_LOGIC;
        signal txcompl0_ext : OUT STD_LOGIC;
        signal app_int_ack : OUT STD_LOGIC;
        signal RxmAddress_o : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal rc_tx_digitalreset : OUT STD_LOGIC;
        signal tx_deemph : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal RxmWrite_o : OUT STD_LOGIC;
        signal rc_gxb_powerdown : OUT STD_LOGIC;
        signal tx_fifo_full0 : OUT STD_LOGIC;
        signal TxsWaitRequest_o : OUT STD_LOGIC;
        signal tl_cfg_add : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal tl_cfg_sts_wr : OUT STD_LOGIC;
        signal tl_cfg_sts : OUT STD_LOGIC_VECTOR (52 DOWNTO 0);
        signal tx_margin : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
        signal rx_st_data0_p1 : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
        signal TxsReadDataValid_o : OUT STD_LOGIC;
        signal tl_cfg_ctl : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal rx_st_err0 : OUT STD_LOGIC;
        signal rc_rx_analogreset : OUT STD_LOGIC;
        signal rxpolarity0_ext : OUT STD_LOGIC;
        signal rx_fifo_full0 : OUT STD_LOGIC;
        signal lmi_ack : OUT STD_LOGIC;
        signal dl_ltssm : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal RxmRead_o : OUT STD_LOGIC;
        signal txdetectrx0_ext : OUT STD_LOGIC;
        signal rate_ext : OUT STD_LOGIC;
        signal rx_st_valid0 : OUT STD_LOGIC;
        signal rx_st_bardec0 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rx_st_eop0_p1 : OUT STD_LOGIC;
        signal tx_fifo_empty0 : OUT STD_LOGIC;
        signal eidle_infer_sel : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
        signal rx_st_sop0 : OUT STD_LOGIC;
        signal TxsReadData_o : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
        signal tx_fifo_rdptr0 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal RxmByteEnable_o : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal RxmWriteData_o : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
        signal RxmBurstCount_o : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
        signal dlup_exit : OUT STD_LOGIC;
        signal rx_st_be0_p1 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal txdatak0_ext : OUT STD_LOGIC;
        signal tx_cred0 : OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
        signal lmi_dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal tx_fifo_wrptr0 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal lmi_rden : IN STD_LOGIC;
        signal app_msi_tc : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal core_clk_in : IN STD_LOGIC;
        signal TxsChipSelect_i : IN STD_LOGIC;
        signal pclk_central : IN STD_LOGIC;
        signal tx_st_sop0_p1 : IN STD_LOGIC;
        signal rx_st_ready0 : IN STD_LOGIC;
        signal rxelecidle0_ext : IN STD_LOGIC;
        signal pld_clk : IN STD_LOGIC;
        signal pm_data : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
        signal rc_areset : IN STD_LOGIC;
        signal phystatus0_ext : IN STD_LOGIC;
        signal tx_st_data0_p1 : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        signal TxsRead_i : IN STD_LOGIC;
        signal rx_st_mask0 : IN STD_LOGIC;
        signal hpg_ctrler : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal crst : IN STD_LOGIC;
        signal RxmReadDataValid_i : IN STD_LOGIC;
        signal TxsWriteData_i : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        signal tx_st_eop0 : IN STD_LOGIC;
        signal RxmReadData_i : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        signal Rstn_i : IN STD_LOGIC;
        signal rxdata0_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal RxmWaitRequest_i : IN STD_LOGIC;
        signal tx_st_valid0 : IN STD_LOGIC;
        signal rc_pll_locked : IN STD_LOGIC;
        signal tx_st_eop0_p1 : IN STD_LOGIC;
        signal pm_auxpwr : IN STD_LOGIC;
        signal CraByteEnable_i : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal pll_fixed_clk : IN STD_LOGIC;
        signal rxvalid0_ext : IN STD_LOGIC;
        signal rc_rx_pll_locked_one : IN STD_LOGIC;
        signal cpl_pending : IN STD_LOGIC;
        signal CraWriteData_i : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal pex_msi_num : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal CraRead : IN STD_LOGIC;
        signal tx_st_sop0 : IN STD_LOGIC;
        signal pm_event : IN STD_LOGIC;
        signal rc_inclk_eq_125mhz : IN STD_LOGIC;
        signal pclk_ch0 : IN STD_LOGIC;
        signal RxmIrq_i : IN STD_LOGIC;
        signal app_msi_req : IN STD_LOGIC;
        signal app_msi_num : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal rxstatus0_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal TxsWrite_i : IN STD_LOGIC;
        signal rxdatak0_ext : IN STD_LOGIC;
        signal tx_st_data0 : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        signal CraAddress_i : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
        signal CraWrite : IN STD_LOGIC;
        signal RxmIrqNum_i : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
        signal TxsByteEnable_i : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal test_in : IN STD_LOGIC_VECTOR (39 DOWNTO 0);
        signal cpl_err : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
        signal aer_msi_num : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal TxsAddress_i : IN STD_LOGIC_VECTOR (16 DOWNTO 0);
        signal lmi_din : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal lmi_wren : IN STD_LOGIC;
        signal TxsBurstCount_i : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
        signal tx_st_err0 : IN STD_LOGIC;
        signal pme_to_cr : IN STD_LOGIC;
        signal AvlClk_i : IN STD_LOGIC;
        signal npor : IN STD_LOGIC;
        signal srst : IN STD_LOGIC;
        signal app_int_sts : IN STD_LOGIC;
        signal CraChipSelect_i : IN STD_LOGIC;
        signal lmi_addr : IN STD_LOGIC_VECTOR (11 DOWNTO 0)
      );
  end component hard_ip_x1_core;
--synthesis translate_off
  component altpcie_pll_100_250 is
PORT (
    signal c0 : OUT STD_LOGIC;
        signal areset : IN STD_LOGIC;
        signal inclk0 : IN STD_LOGIC
      );
  end component altpcie_pll_100_250;
  component altpcie_pll_125_250 is
PORT (
    signal c0 : OUT STD_LOGIC;
        signal areset : IN STD_LOGIC;
        signal inclk0 : IN STD_LOGIC
      );
  end component altpcie_pll_125_250;
--synthesis translate_on
                signal core_clk_in :  STD_LOGIC;
                signal detect_mask_rxdrst :  STD_LOGIC;
                signal eidle_infer_sel :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal fifo_err :  STD_LOGIC;
                signal gnd_AvlClk_i :  STD_LOGIC;
                signal gnd_CraAddress_i :  STD_LOGIC_VECTOR (11 DOWNTO 0);
                signal gnd_CraByteEnable_i :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal gnd_CraChipSelect_i :  STD_LOGIC;
                signal gnd_CraRead :  STD_LOGIC;
                signal gnd_CraWrite :  STD_LOGIC;
                signal gnd_CraWriteData_i :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal gnd_Rstn_i :  STD_LOGIC;
                signal gnd_RxmIrqNum_i :  STD_LOGIC_VECTOR (5 DOWNTO 0);
                signal gnd_RxmIrq_i :  STD_LOGIC;
                signal gnd_RxmReadDataValid_i :  STD_LOGIC;
                signal gnd_RxmReadData_i :  STD_LOGIC_VECTOR (63 DOWNTO 0);
                signal gnd_RxmWaitRequest_i :  STD_LOGIC;
                signal gnd_TxsAddress_i :  STD_LOGIC_VECTOR (16 DOWNTO 0);
                signal gnd_TxsBurstCount_i :  STD_LOGIC_VECTOR (9 DOWNTO 0);
                signal gnd_TxsByteEnable_i :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal gnd_TxsChipSelect_i :  STD_LOGIC;
                signal gnd_TxsRead_i :  STD_LOGIC;
                signal gnd_TxsWriteData_i :  STD_LOGIC_VECTOR (63 DOWNTO 0);
                signal gnd_TxsWrite_i :  STD_LOGIC;
                signal gxb_powerdown_int :  STD_LOGIC;
                signal hip_extraclkout :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_app_int_ack :  STD_LOGIC;
                signal internal_app_msi_ack :  STD_LOGIC;
                signal internal_clk250_out :  STD_LOGIC;
                signal internal_clk500_out :  STD_LOGIC;
                signal internal_core_clk_out :  STD_LOGIC;
                signal internal_derr_cor_ext_rcv0 :  STD_LOGIC;
                signal internal_derr_cor_ext_rpl :  STD_LOGIC;
                signal internal_derr_rpl :  STD_LOGIC;
                signal internal_dlup_exit :  STD_LOGIC;
                signal internal_hotrst_exit :  STD_LOGIC;
                signal internal_l2_exit :  STD_LOGIC;
                signal internal_lane_act :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal internal_lmi_ack :  STD_LOGIC;
                signal internal_lmi_dout :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_ltssm :  STD_LOGIC_VECTOR (4 DOWNTO 0);
                signal internal_pme_to_sr :  STD_LOGIC;
                signal internal_r2c_err0 :  STD_LOGIC;
                signal internal_rc_pll_locked :  STD_LOGIC;
                signal internal_rc_rx_digitalreset :  STD_LOGIC;
                signal internal_reconfig_fromgxb :  STD_LOGIC_VECTOR (4 DOWNTO 0);
                signal internal_reset_status :  STD_LOGIC;
                signal internal_rx_fifo_empty0 :  STD_LOGIC;
                signal internal_rx_fifo_full0 :  STD_LOGIC;
                signal internal_rx_st_bardec0 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal internal_rx_st_be0 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal internal_rx_st_data0 :  STD_LOGIC_VECTOR (63 DOWNTO 0);
                signal internal_rx_st_eop0 :  STD_LOGIC;
                signal internal_rx_st_err0 :  STD_LOGIC;
                signal internal_rx_st_sop0 :  STD_LOGIC;
                signal internal_rx_st_valid0 :  STD_LOGIC;
                signal internal_suc_spd_neg :  STD_LOGIC;
                signal internal_tl_cfg_add :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal internal_tl_cfg_ctl :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_tl_cfg_ctl_wr :  STD_LOGIC;
                signal internal_tl_cfg_sts :  STD_LOGIC_VECTOR (52 DOWNTO 0);
                signal internal_tl_cfg_sts_wr :  STD_LOGIC;
                signal internal_tx_cred0 :  STD_LOGIC_VECTOR (35 DOWNTO 0);
                signal internal_tx_fifo_empty0 :  STD_LOGIC;
                signal internal_tx_fifo_full0 :  STD_LOGIC;
                signal internal_tx_fifo_rdptr0 :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal internal_tx_fifo_wrptr0 :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal internal_tx_st_ready0 :  STD_LOGIC;
                signal open_CraIrq_o :  STD_LOGIC;
                signal open_CraReadData_o :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal open_CraWaitRequest_o :  STD_LOGIC;
                signal open_RxmAddress_o :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal open_RxmBurstCount_o :  STD_LOGIC_VECTOR (9 DOWNTO 0);
                signal open_RxmByteEnable_o :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal open_RxmRead_o :  STD_LOGIC;
                signal open_RxmWriteData_o :  STD_LOGIC_VECTOR (63 DOWNTO 0);
                signal open_RxmWrite_o :  STD_LOGIC;
                signal open_TxsReadDataValid_o :  STD_LOGIC;
                signal open_TxsReadData_o :  STD_LOGIC_VECTOR (63 DOWNTO 0);
                signal open_TxsWaitRequest_o :  STD_LOGIC;
                signal open_gxb_powerdown :  STD_LOGIC;
                signal open_rc_rx_analogreset :  STD_LOGIC;
                signal open_rc_tx_digitalreset :  STD_LOGIC;
                signal open_rx_st_be0_p1 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal open_rx_st_data0_p1 :  STD_LOGIC_VECTOR (63 DOWNTO 0);
                signal open_rx_st_eop0_p1 :  STD_LOGIC;
                signal open_rx_st_sop0_p1 :  STD_LOGIC;
                signal pclk_central :  STD_LOGIC;
                signal pclk_central_serdes :  STD_LOGIC;
                signal pclk_ch0 :  STD_LOGIC;
                signal pclk_ch0_serdes :  STD_LOGIC;
                signal phystatus :  STD_LOGIC;
                signal phystatus_pcs :  STD_LOGIC;
                signal pipe_mode_int :  STD_LOGIC;
                signal pll_fixed_clk :  STD_LOGIC;
                signal pll_fixed_clk_serdes :  STD_LOGIC;
                signal pll_locked :  STD_LOGIC;
                signal pll_powerdown_int :  STD_LOGIC;
                signal powerdown :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerdown0_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerdown0_int :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal rate_int :  STD_LOGIC;
                signal rateswitch :  STD_LOGIC;
                signal rateswitchbaseclock :  STD_LOGIC;
                signal rc_areset :  STD_LOGIC;
                signal rc_inclk_eq_125mhz :  STD_LOGIC;
                signal rc_rx_analogreset :  STD_LOGIC;
                signal rc_rx_pll_locked_one :  STD_LOGIC;
                signal rc_tx_digitalreset :  STD_LOGIC;
                signal rx_cruclk :  STD_LOGIC;
                signal rx_digitalreset_serdes :  STD_LOGIC;
                signal rx_freqlocked :  STD_LOGIC;
                signal rx_freqlocked_byte :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rx_in :  STD_LOGIC;
                signal rx_pll_locked :  STD_LOGIC;
                signal rx_pll_locked_byte :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rx_signaldetect_byte :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rxdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rxdata_pcs :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rxdatak :  STD_LOGIC;
                signal rxdatak_pcs :  STD_LOGIC;
                signal rxelecidle :  STD_LOGIC;
                signal rxelecidle_pcs :  STD_LOGIC;
                signal rxpolarity :  STD_LOGIC;
                signal rxpolarity0_int :  STD_LOGIC;
                signal rxstatus :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal rxstatus_pcs :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal rxvalid :  STD_LOGIC;
                signal rxvalid_pcs :  STD_LOGIC;
                signal test_out_int :  STD_LOGIC_VECTOR (63 DOWNTO 0);
                signal tx_deemph :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal tx_margin :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal tx_out :  STD_LOGIC;
                signal txcompl :  STD_LOGIC;
                signal txcompl0_int :  STD_LOGIC;
                signal txdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal txdata0_int :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal txdatak :  STD_LOGIC;
                signal txdatak0_int :  STD_LOGIC;
                signal txdetectrx :  STD_LOGIC;
                signal txdetectrx0_ext :  STD_LOGIC;
                signal txdetectrx0_int :  STD_LOGIC;
                signal txelecidle :  STD_LOGIC;
                signal txelecidle0_int :  STD_LOGIC;
                signal use_c4gx_serdes :  STD_LOGIC;

begin

  test_out <= internal_lane_act & internal_ltssm;
  app_clk <= pld_clk;
  txdetectrx_ext <= txdetectrx0_ext;
  powerdown_ext <= powerdown0_ext;
  rxdata(7 DOWNTO 0) <= A_WE_StdLogicVector((std_logic'(pipe_mode_int) = '1'), rxdata0_ext, rxdata_pcs(7 DOWNTO 0));
  phystatus <= A_WE_StdLogic((std_logic'(pipe_mode_int) = '1'), phystatus_ext, phystatus_pcs);
  rxelecidle <= A_WE_StdLogic((std_logic'(pipe_mode_int) = '1'), rxelecidle0_ext, rxelecidle_pcs);
  rxvalid <= A_WE_StdLogic((std_logic'(pipe_mode_int) = '1'), rxvalid0_ext, rxvalid_pcs);
  txdata(7 DOWNTO 0) <= txdata0_int;
  rxdatak <= A_WE_StdLogic((std_logic'(pipe_mode_int) = '1'), rxdatak0_ext, rxdatak_pcs);
  rxstatus(2 DOWNTO 0) <= A_WE_StdLogicVector((std_logic'(pipe_mode_int) = '1'), rxstatus0_ext, rxstatus_pcs(2 DOWNTO 0));
  powerdown(1 DOWNTO 0) <= powerdown0_int;
  rxpolarity <= rxpolarity0_int;
  txcompl <= txcompl0_int;
  txdatak <= txdatak0_int;
  txdetectrx <= txdetectrx0_int;
  txelecidle <= txelecidle0_int;
  txdata0_ext <= A_EXT (A_WE_StdLogicVector((std_logic'(pipe_mode_int) = '1'), (std_logic_vector'("000000000000000000000000") & (txdata0_int)), std_logic_vector'("00000000000000000000000000000000")), 8);
  txdatak0_ext <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(pipe_mode_int) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(txdatak0_int))), std_logic_vector'("00000000000000000000000000000000")));
  txdetectrx0_ext <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(pipe_mode_int) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(txdetectrx0_int))), std_logic_vector'("00000000000000000000000000000000")));
  txelecidle0_ext <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(pipe_mode_int) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(txelecidle0_int))), std_logic_vector'("00000000000000000000000000000000")));
  txcompl0_ext <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(pipe_mode_int) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(txcompl0_int))), std_logic_vector'("00000000000000000000000000000000")));
  rxpolarity0_ext <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(pipe_mode_int) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(rxpolarity0_int))), std_logic_vector'("00000000000000000000000000000000")));
  powerdown0_ext <= A_EXT (A_WE_StdLogicVector((std_logic'(pipe_mode_int) = '1'), (std_logic_vector'("000000000000000000000000000000") & (powerdown0_int)), std_logic_vector'("00000000000000000000000000000000")), 2);
  ko_cpl_spc_vc0 <= std_logic_vector'("00000001000000000100");
  rx_in <= rx_in0;
  tx_out0 <= tx_out;
  rc_inclk_eq_125mhz <= std_logic'('1');
  pclk_central_serdes <= std_logic'('0');
  pll_fixed_clk_serdes <= rateswitchbaseclock;
  rateswitchbaseclock <= pclk_ch0_serdes;
  internal_rc_pll_locked <= A_WE_StdLogic(((std_logic'(pipe_mode_int) = std_logic'(std_logic'('1')))), std_logic'('1'), pll_locked);
  gxb_powerdown_int <= A_WE_StdLogic(((std_logic'(pipe_mode_int) = std_logic'(std_logic'('1')))), std_logic'('1'), gxb_powerdown);
  pll_powerdown_int <= A_WE_StdLogic(((std_logic'(pipe_mode_int) = std_logic'(std_logic'('1')))), std_logic'('1'), pll_powerdown);
  rx_pll_locked <= std_logic'('1');
  rx_cruclk <= refclk;
  rc_areset <= (pipe_mode_int OR NOT npor) OR busy_altgxb_reconfig;
  pclk_central <= A_WE_StdLogic(((std_logic'(pipe_mode_int) = std_logic'(std_logic'('1')))), pclk_in, pclk_central_serdes);
  pclk_ch0 <= A_WE_StdLogic(((std_logic'(pipe_mode_int) = std_logic'(std_logic'('1')))), pclk_in, pclk_ch0_serdes);
  rateswitch <= rate_int;
  rate_ext <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(pipe_mode_int) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(rate_int))), std_logic_vector'("00000000000000000000000000000000")));
  pll_fixed_clk <= A_WE_StdLogic(((std_logic'(pipe_mode_int) = std_logic'(std_logic'('1')))), internal_clk250_out, pll_fixed_clk_serdes);
  rc_rx_pll_locked_one <= rx_pll_locked OR rx_freqlocked;
  use_c4gx_serdes <= std_logic'('1');
  fifo_err <= std_logic'('0');
  rx_freqlocked_byte(0) <= rx_freqlocked;
  rx_freqlocked_byte(7 DOWNTO 1) <= std_logic_vector'("1111111");
  rx_pll_locked_byte(0) <= rx_pll_locked;
  rx_pll_locked_byte(7 DOWNTO 1) <= std_logic_vector'("1111111");
  rx_signaldetect_byte(7 DOWNTO 0) <= std_logic_vector'("11111111");
  detect_mask_rxdrst <= std_logic'('0');
  core_clk_in <= std_logic'('0');
  gnd_AvlClk_i <= std_logic'('0');
  gnd_Rstn_i <= std_logic'('0');
  gnd_TxsChipSelect_i <= std_logic'('0');
  gnd_TxsRead_i <= std_logic'('0');
  gnd_TxsWrite_i <= std_logic'('0');
  gnd_TxsWriteData_i <= std_logic_vector'("000000000000000000000000000000000000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(std_logic'('0')));
  gnd_TxsBurstCount_i <= std_logic_vector'("000000000") & (A_TOSTDLOGICVECTOR(std_logic'('0')));
  gnd_TxsAddress_i <= std_logic_vector'("0000000000000000") & (A_TOSTDLOGICVECTOR(std_logic'('0')));
  gnd_TxsByteEnable_i <= std_logic_vector'("0000000") & (A_TOSTDLOGICVECTOR(std_logic'('0')));
  gnd_RxmWaitRequest_i <= std_logic'('0');
  gnd_RxmReadData_i <= std_logic_vector'("000000000000000000000000000000000000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(std_logic'('0')));
  gnd_RxmReadDataValid_i <= std_logic'('0');
  gnd_RxmIrq_i <= std_logic'('0');
  gnd_RxmIrqNum_i <= std_logic_vector'("00000") & (A_TOSTDLOGICVECTOR(std_logic'('0')));
  gnd_CraChipSelect_i <= std_logic'('0');
  gnd_CraRead <= std_logic'('0');
  gnd_CraWrite <= std_logic'('0');
  gnd_CraWriteData_i <= std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(std_logic'('0')));
  gnd_CraAddress_i <= std_logic_vector'("00000000000") & (A_TOSTDLOGICVECTOR(std_logic'('0')));
  gnd_CraByteEnable_i <= std_logic_vector'("000") & (A_TOSTDLOGICVECTOR(std_logic'('0')));
  serdes : hard_ip_x1_serdes
    port map(
            cal_blk_clk => cal_blk_clk,
            fixedclk => fixedclk_serdes,
            gxb_powerdown => A_TOSTDLOGICVECTOR(gxb_powerdown_int),
            hip_tx_clkout(0) => pclk_ch0_serdes,
            pipe8b10binvpolarity => A_TOSTDLOGICVECTOR(rxpolarity),
            pipedatavalid(0) => rxvalid_pcs,
            pipeelecidle(0) => rxelecidle_pcs,
            pipephydonestatus(0) => phystatus_pcs,
            pipestatus => rxstatus_pcs,
            pll_areset => A_TOSTDLOGICVECTOR(pll_powerdown_int),
            pll_inclk => A_TOSTDLOGICVECTOR(refclk),
            pll_locked(0) => pll_locked,
            powerdn => powerdown,
            reconfig_clk => reconfig_clk,
            reconfig_fromgxb => internal_reconfig_fromgxb,
            reconfig_togxb => reconfig_togxb,
            rx_analogreset => A_TOSTDLOGICVECTOR(rc_rx_analogreset),
            rx_ctrldetect(0) => rxdatak_pcs,
            rx_datain => A_TOSTDLOGICVECTOR(rx_in),
            rx_dataout => rxdata_pcs,
            rx_digitalreset => A_TOSTDLOGICVECTOR(rx_digitalreset_serdes),
            rx_elecidleinfersel => eidle_infer_sel(2 DOWNTO 0),
            rx_freqlocked(0) => rx_freqlocked,
            tx_ctrlenable => A_TOSTDLOGICVECTOR(txdatak),
            tx_datain => txdata,
            tx_dataout(0) => tx_out,
            tx_detectrxloop => A_TOSTDLOGICVECTOR(txdetectrx),
            tx_digitalreset => A_TOSTDLOGICVECTOR(rc_tx_digitalreset),
            tx_forcedispcompliance => A_TOSTDLOGICVECTOR(txcompl),
            tx_forceelecidle => A_TOSTDLOGICVECTOR(txelecidle)
    );

  rs_serdes : altpcie_rs_serdes
    port map(
            busy_altgxb_reconfig => busy_altgxb_reconfig,
            detect_mask_rxdrst => detect_mask_rxdrst,
            fifo_err => fifo_err,
            ltssm => internal_ltssm,
            npor => npor,
            pld_clk => pld_clk,
            pll_locked => internal_rc_pll_locked,
            rc_inclk_eq_125mhz => rc_inclk_eq_125mhz,
            rx_freqlocked => rx_freqlocked_byte,
            rx_pll_locked => rx_pll_locked_byte,
            rx_signaldetect => rx_signaldetect_byte,
            rxanalogreset => rc_rx_analogreset,
            rxdigitalreset => rx_digitalreset_serdes,
            test_in => test_in,
            txdigitalreset => rc_tx_digitalreset,
            use_c4gx_serdes => use_c4gx_serdes
    );

  wrapper : hard_ip_x1_core
      generic map(
         MEN_VENDOR_ID           => VENDOR_ID,
         MEN_DEVICE_ID           => DEVICE_ID,
         MEN_REVISION_ID         => REVISION_ID,
         MEN_CLASS_CODE	         => CLASS_CODE,
         MEN_SUBSYSTEM_VENDOR_ID => SUBSYSTEM_VENDOR_ID,
         MEN_SUBSYSTEM_DEVICE_ID => SUBSYSTEM_DEVICE_ID,
         
         MEN_IO_SPACE_BAR_0  => IO_SPACE_BAR_0,
         MEN_PREFETCH_BAR_0  => PREFETCH_BAR_0,
         MEN_SIZE_MASK_BAR_0 => SIZE_MASK_BAR_0,
         
         MEN_IO_SPACE_BAR_1  => IO_SPACE_BAR_1,
         MEN_PREFETCH_BAR_1  => PREFETCH_BAR_1,
         MEN_SIZE_MASK_BAR_1 => SIZE_MASK_BAR_1,
         
         MEN_IO_SPACE_BAR_2  => IO_SPACE_BAR_2,
         MEN_PREFETCH_BAR_2  => PREFETCH_BAR_2,
         MEN_SIZE_MASK_BAR_2 => SIZE_MASK_BAR_2,
         
         MEN_IO_SPACE_BAR_3  => IO_SPACE_BAR_3,
         MEN_PREFETCH_BAR_3  => PREFETCH_BAR_3,
         MEN_SIZE_MASK_BAR_3 => SIZE_MASK_BAR_3,
         
         MEN_IO_SPACE_BAR_4  => IO_SPACE_BAR_4,
         MEN_PREFETCH_BAR_4  => PREFETCH_BAR_4,
         MEN_SIZE_MASK_BAR_4 => SIZE_MASK_BAR_4,
         
         MEN_IO_SPACE_BAR_5  => IO_SPACE_BAR_5,
         MEN_PREFETCH_BAR_5  => PREFETCH_BAR_5,
         MEN_SIZE_MASK_BAR_5 => SIZE_MASK_BAR_5
      )
    port map(
            AvlClk_i => gnd_AvlClk_i,
            CraAddress_i => gnd_CraAddress_i,
            CraByteEnable_i => gnd_CraByteEnable_i,
            CraChipSelect_i => gnd_CraChipSelect_i,
            CraIrq_o => open_CraIrq_o,
            CraRead => gnd_CraRead,
            CraReadData_o => open_CraReadData_o,
            CraWaitRequest_o => open_CraWaitRequest_o,
            CraWrite => gnd_CraWrite,
            CraWriteData_i => gnd_CraWriteData_i,
            Rstn_i => gnd_Rstn_i,
            RxmAddress_o => open_RxmAddress_o,
            RxmBurstCount_o => open_RxmBurstCount_o,
            RxmByteEnable_o => open_RxmByteEnable_o,
            RxmIrqNum_i => gnd_RxmIrqNum_i,
            RxmIrq_i => gnd_RxmIrq_i,
            RxmReadDataValid_i => gnd_RxmReadDataValid_i,
            RxmReadData_i => gnd_RxmReadData_i,
            RxmRead_o => open_RxmRead_o,
            RxmWaitRequest_i => gnd_RxmWaitRequest_i,
            RxmWriteData_o => open_RxmWriteData_o,
            RxmWrite_o => open_RxmWrite_o,
            TxsAddress_i => gnd_TxsAddress_i,
            TxsBurstCount_i => gnd_TxsBurstCount_i,
            TxsByteEnable_i => gnd_TxsByteEnable_i,
            TxsChipSelect_i => gnd_TxsChipSelect_i,
            TxsReadDataValid_o => open_TxsReadDataValid_o,
            TxsReadData_o => open_TxsReadData_o,
            TxsRead_i => gnd_TxsRead_i,
            TxsWaitRequest_o => open_TxsWaitRequest_o,
            TxsWriteData_i => gnd_TxsWriteData_i,
            TxsWrite_i => gnd_TxsWrite_i,
            aer_msi_num => std_logic_vector'("00000"),
            app_int_ack => internal_app_int_ack,
            app_int_sts => app_int_sts,
            app_msi_ack => internal_app_msi_ack,
            app_msi_num => app_msi_num,
            app_msi_req => app_msi_req,
            app_msi_tc => app_msi_tc,
            core_clk_in => core_clk_in,
            core_clk_out => internal_core_clk_out,
            cpl_err => cpl_err,
            cpl_pending => cpl_pending,
            crst => crst,
            derr_cor_ext_rcv0 => internal_derr_cor_ext_rcv0,
            derr_cor_ext_rpl => internal_derr_cor_ext_rpl,
            derr_rpl => internal_derr_rpl,
            dl_ltssm => internal_ltssm,
            dlup_exit => internal_dlup_exit,
            eidle_infer_sel => eidle_infer_sel,
            hip_extraclkout => hip_extraclkout,
            hotrst_exit => internal_hotrst_exit,
            hpg_ctrler => hpg_ctrler,
            l2_exit => internal_l2_exit,
            lane_act => internal_lane_act,
            lmi_ack => internal_lmi_ack,
            lmi_addr => lmi_addr,
            lmi_din => lmi_din,
            lmi_dout => internal_lmi_dout,
            lmi_rden => lmi_rden,
            lmi_wren => lmi_wren,
            npor => npor,
            pclk_central => pclk_central,
            pclk_ch0 => pclk_ch0,
            pex_msi_num => pex_msi_num,
            phystatus0_ext => phystatus,
            pld_clk => pld_clk,
            pll_fixed_clk => pll_fixed_clk,
            pm_auxpwr => pm_auxpwr,
            pm_data => pm_data,
            pm_event => pm_event,
            pme_to_cr => pme_to_cr,
            pme_to_sr => internal_pme_to_sr,
            powerdown0_ext => powerdown0_int,
            r2c_err0 => internal_r2c_err0,
            rate_ext => rate_int,
            rc_areset => rc_areset,
            rc_gxb_powerdown => open_gxb_powerdown,
            rc_inclk_eq_125mhz => rc_inclk_eq_125mhz,
            rc_pll_locked => internal_rc_pll_locked,
            rc_rx_analogreset => open_rc_rx_analogreset,
            rc_rx_digitalreset => internal_rc_rx_digitalreset,
            rc_rx_pll_locked_one => rc_rx_pll_locked_one,
            rc_tx_digitalreset => open_rc_tx_digitalreset,
            reset_status => internal_reset_status,
            rx_fifo_empty0 => internal_rx_fifo_empty0,
            rx_fifo_full0 => internal_rx_fifo_full0,
            rx_st_bardec0 => internal_rx_st_bardec0,
            rx_st_be0 => internal_rx_st_be0,
            rx_st_be0_p1 => open_rx_st_be0_p1,
            rx_st_data0 => internal_rx_st_data0,
            rx_st_data0_p1 => open_rx_st_data0_p1,
            rx_st_eop0 => internal_rx_st_eop0,
            rx_st_eop0_p1 => open_rx_st_eop0_p1,
            rx_st_err0 => internal_rx_st_err0,
            rx_st_mask0 => rx_st_mask0,
            rx_st_ready0 => rx_st_ready0,
            rx_st_sop0 => internal_rx_st_sop0,
            rx_st_sop0_p1 => open_rx_st_sop0_p1,
            rx_st_valid0 => internal_rx_st_valid0,
            rxdata0_ext => rxdata(7 DOWNTO 0),
            rxdatak0_ext => rxdatak,
            rxelecidle0_ext => rxelecidle,
            rxpolarity0_ext => rxpolarity0_int,
            rxstatus0_ext => rxstatus(2 DOWNTO 0),
            rxvalid0_ext => rxvalid,
            srst => srst,
            suc_spd_neg => internal_suc_spd_neg,
            test_in => test_in,
            test_out => test_out_int,
            tl_cfg_add => internal_tl_cfg_add,
            tl_cfg_ctl => internal_tl_cfg_ctl,
            tl_cfg_ctl_wr => internal_tl_cfg_ctl_wr,
            tl_cfg_sts => internal_tl_cfg_sts,
            tl_cfg_sts_wr => internal_tl_cfg_sts_wr,
            tx_cred0 => internal_tx_cred0,
            tx_deemph => tx_deemph,
            tx_fifo_empty0 => internal_tx_fifo_empty0,
            tx_fifo_full0 => internal_tx_fifo_full0,
            tx_fifo_rdptr0 => internal_tx_fifo_rdptr0,
            tx_fifo_wrptr0 => internal_tx_fifo_wrptr0,
            tx_margin => tx_margin,
            tx_st_data0 => tx_st_data0,
            tx_st_data0_p1 => std_logic_vector'("0000000000000000000000000000000000000000000000000000000000000000"),
            tx_st_eop0 => tx_st_eop0,
            tx_st_eop0_p1 => std_logic'('0'),
            tx_st_err0 => tx_st_err0,
            tx_st_ready0 => internal_tx_st_ready0,
            tx_st_sop0 => tx_st_sop0,
            tx_st_sop0_p1 => std_logic'('0'),
            tx_st_valid0 => tx_st_valid0,
            txcompl0_ext => txcompl0_int,
            txdata0_ext => txdata0_int,
            txdatak0_ext => txdatak0_int,
            txdetectrx0_ext => txdetectrx0_int,
            txelecidle0_ext => txelecidle0_int
    );

  --vhdl renameroo for output signals
  app_int_ack <= internal_app_int_ack;
  --vhdl renameroo for output signals
  app_msi_ack <= internal_app_msi_ack;
  --vhdl renameroo for output signals
  clk250_out <= internal_clk250_out;
  --vhdl renameroo for output signals
  clk500_out <= internal_clk500_out;
  --vhdl renameroo for output signals
  core_clk_out <= internal_core_clk_out;
  --vhdl renameroo for output signals
  derr_cor_ext_rcv0 <= internal_derr_cor_ext_rcv0;
  --vhdl renameroo for output signals
  derr_cor_ext_rpl <= internal_derr_cor_ext_rpl;
  --vhdl renameroo for output signals
  derr_rpl <= internal_derr_rpl;
  --vhdl renameroo for output signals
  dlup_exit <= internal_dlup_exit;
  --vhdl renameroo for output signals
  hotrst_exit <= internal_hotrst_exit;
  --vhdl renameroo for output signals
  l2_exit <= internal_l2_exit;
  --vhdl renameroo for output signals
  lane_act <= internal_lane_act;
  --vhdl renameroo for output signals
  lmi_ack <= internal_lmi_ack;
  --vhdl renameroo for output signals
  lmi_dout <= internal_lmi_dout;
  --vhdl renameroo for output signals
  ltssm <= internal_ltssm;
  --vhdl renameroo for output signals
  pme_to_sr <= internal_pme_to_sr;
  --vhdl renameroo for output signals
  r2c_err0 <= internal_r2c_err0;
  --vhdl renameroo for output signals
  rc_pll_locked <= internal_rc_pll_locked;
  --vhdl renameroo for output signals
  rc_rx_digitalreset <= internal_rc_rx_digitalreset;
  --vhdl renameroo for output signals
  reconfig_fromgxb <= internal_reconfig_fromgxb;
  --vhdl renameroo for output signals
  reset_status <= internal_reset_status;
  --vhdl renameroo for output signals
  rx_fifo_empty0 <= internal_rx_fifo_empty0;
  --vhdl renameroo for output signals
  rx_fifo_full0 <= internal_rx_fifo_full0;
  --vhdl renameroo for output signals
  rx_st_bardec0 <= internal_rx_st_bardec0;
  --vhdl renameroo for output signals
  rx_st_be0 <= internal_rx_st_be0;
  --vhdl renameroo for output signals
  rx_st_data0 <= internal_rx_st_data0;
  --vhdl renameroo for output signals
  rx_st_eop0 <= internal_rx_st_eop0;
  --vhdl renameroo for output signals
  rx_st_err0 <= internal_rx_st_err0;
  --vhdl renameroo for output signals
  rx_st_sop0 <= internal_rx_st_sop0;
  --vhdl renameroo for output signals
  rx_st_valid0 <= internal_rx_st_valid0;
  --vhdl renameroo for output signals
  suc_spd_neg <= internal_suc_spd_neg;
  --vhdl renameroo for output signals
  tl_cfg_add <= internal_tl_cfg_add;
  --vhdl renameroo for output signals
  tl_cfg_ctl <= internal_tl_cfg_ctl;
  --vhdl renameroo for output signals
  tl_cfg_ctl_wr <= internal_tl_cfg_ctl_wr;
  --vhdl renameroo for output signals
  tl_cfg_sts <= internal_tl_cfg_sts;
  --vhdl renameroo for output signals
  tl_cfg_sts_wr <= internal_tl_cfg_sts_wr;
  --vhdl renameroo for output signals
  tx_cred0 <= internal_tx_cred0;
  --vhdl renameroo for output signals
  tx_fifo_empty0 <= internal_tx_fifo_empty0;
  --vhdl renameroo for output signals
  tx_fifo_full0 <= internal_tx_fifo_full0;
  --vhdl renameroo for output signals
  tx_fifo_rdptr0 <= internal_tx_fifo_rdptr0;
  --vhdl renameroo for output signals
  tx_fifo_wrptr0 <= internal_tx_fifo_wrptr0;
  --vhdl renameroo for output signals
  tx_st_ready0 <= internal_tx_st_ready0;
--synthesis translate_off
    pipe_mode_int <= pipe_mode;
    refclk_to_250mhz : altpcie_pll_100_250
      port map(
                areset => std_logic'('0'),
                c0 => internal_clk250_out,
                inclk0 => refclk
      );

    pll_250mhz_to_500mhz : altpcie_pll_125_250
      port map(
                areset => std_logic'('0'),
                c0 => internal_clk500_out,
                inclk0 => internal_clk250_out
      );

--synthesis translate_on
--synthesis read_comments_as_HDL on
--    pipe_mode_int <= std_logic'('0');
--synthesis read_comments_as_HDL off

end europa;


-- =========================================================
-- IP Compiler for PCI Express Wizard Data
-- ===============================
-- DO NOT EDIT FOLLOWING DATA
-- @Altera, IP Toolbench@
-- Warning: If you modify this section, IP Compiler for PCI Express Wizard may not be able to reproduce your chosen configuration.
-- 
-- Retrieval info: <?xml version="1.0"?>
-- Retrieval info: <MEGACORE title="IP Compiler for PCI Express"  version="11.0"  build="208"  iptb_version="1.3.0 Build 208"  format_version="120" >
-- Retrieval info:  <NETLIST_SECTION class="altera.ipbu.flowbase.netlist.model.MVCModel"  active_core="altpcie_hip_pipen1b" >
-- Retrieval info:   <STATIC_SECTION>
-- Retrieval info:    <PRIVATES>
-- Retrieval info:     <NAMESPACE name = "parameterization">
-- Retrieval info:      <PRIVATE name = "p_pcie_phy" value="Cyclone IV GX"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_port_type" value="Legacy Endpoint"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_tag_supported" value="32"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_msi_message_requested" value="4"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_low_priority_virtual_channels" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_retry_fifo_depth" value="64"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nfts_common_clock" value="255"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nfts_separate_clock" value="255"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_exp_rom_bar_used" value="0"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_link_common_clock" value="1"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_advanced_error_reporting" value="1"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_ecrc_check" value="1"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_ecrc_generation" value="1"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_power_indicator" value="0"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_attention_indicator" value="0"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_attention_button" value="0"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_msi_message_64bits_address_capable" value="1"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_auto_configure_retry_buffer" value="1"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_implement_data_register" value="0"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_device_init_required" value="0"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_enable_L1_aspm" value="0"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_rate_match_fifo" value="1"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_enable_fast_recovery" value="1"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "SOPCSystemName" value="N/A"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "actualBAR0AvalonAddress" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "actualBAR0Size" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "actualBAR1AvalonAddress" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "actualBAR1Size" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "actualBAR2AvalonAddress" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "actualBAR2Size" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "actualBAR3AvalonAddress" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "actualBAR3Size" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "actualBAR4AvalonAddress" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "actualBAR4Size" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "actualBAR5AvalonAddress" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "actualBAR5Size" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "allowedDeviceFamilies" value="[Stratix III, Stratix II, HardCopy II, Stratix II GX, Stratix, Stratix GX, Cyclone III LS, Cyclone IV E, Cyclone IV GX, Cyclone III, Cyclone II, Cyclone, MAX II, MAX V, FLEX 10KE, Arria GX, Stratix IV, Stratix V, Arria II GX, HardCopy III, HardCopy IV, Arria II GZ, Unknown, None]"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "altgx_generated" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "clockSource" value="N/A"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "contextState" value="NativeContext"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "deviceFamily" value="Cyclone IV GX"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "ordering_code" value="IP-PCIE/4"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hardwired_address_map" value="true"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_00" value="0x0000000000000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_00_type" value="Memory32Bit"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_01" value="0x0000000000000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_01_type" value="Memory32Bit"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_02" value="0x0000000000000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_02_type" value="Memory32Bit"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_03" value="0x0000000000000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_03_type" value="Memory32Bit"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_04" value="0x0000000000000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_04_type" value="Memory32Bit"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_05" value="0x0000000000000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_05_type" value="Memory32Bit"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_06" value="0x0000000000000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_06_type" value="Memory32Bit"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_07" value="0x0000000000000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_07_type" value="Memory32Bit"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_08" value="0x0000000000000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_08_type" value="Memory32Bit"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_09" value="0x0000000000000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_09_type" value="Memory32Bit"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_10" value="0x0000000000000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_10_type" value="Memory32Bit"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_11" value="0x0000000000000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_11_type" value="Memory32Bit"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_12" value="0x0000000000000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_12_type" value="Memory32Bit"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_13" value="0x0000000000000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_13_type" value="Memory32Bit"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_14" value="0x0000000000000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_14_type" value="Memory32Bit"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_15" value="0x0000000000000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_hw_pci_address_15_type" value="Memory32Bit"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_pane_count" value="1"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_avalon_pane_size" value="20"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_enable_pcie_hip_dprio" value="Disable"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_64bit_bar" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_64bit_bus" value="true"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_66mhz" value="true"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_allow_param_readback" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_altera_arbiter" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_arbited_devices" value="2"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_arbiter" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_0_auto_avalon_address" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_0_auto_sized" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_0_avalon_address" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_0_hardwired" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_0_pci_address" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_0_prefetchable" value="true"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_1_auto_avalon_address" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_1_auto_sized" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_1_avalon_address" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_1_hardwired" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_1_pci_address" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_1_prefetchable" value="true"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_2_auto_avalon_address" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_2_auto_sized" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_2_avalon_address" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_2_hardwired" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_2_pci_address" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_2_prefetchable" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_3_auto_avalon_address" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_3_auto_sized" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_3_avalon_address" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_3_hardwired" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_3_pci_address" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_3_prefetchable" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_4_auto_avalon_address" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_4_auto_sized" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_4_avalon_address" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_4_hardwired" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_4_pci_address" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_4_prefetchable" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_5_auto_avalon_address" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_5_auto_sized" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_5_avalon_address" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_5_hardwired" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_5_pci_address" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bar_5_prefetchable" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_bus_access_address_width" value="18"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_global_reset" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_host_bridge" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_impl_cra_av_slave_port" value="true"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_master" value="true"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_master_bursts" value="true"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_master_concurrent_reads" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_master_data_width" value="64"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_maximum_burst_size" value="128"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_maximum_burst_size_a2p" value="128"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_maximum_pending_read_transactions_a2p" value="8"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_non_pref_av_master_port" value="true"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_not_target_only_port" value="true"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_pref_av_master_port" value="true"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_reqn_gntn_pins" value="true"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_single_clock" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_target_bursts" value="true"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_target_concurrent_reads" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pci_user_specified_bars" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_L1_exit_latency_common_clock" value="&gt;64 us"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_L1_exit_latency_separate_clock" value="&gt;64 us"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_advanced_error_int_num" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_alt2gxb" value="0"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_altgx_keyParameters_used" value="{p_pcie_enable_hip=1, p_pcie_number_of_lanes=x1, p_pcie_phy=Cyclone IV GX, p_pcie_rate=Gen1 (2.5 Gbps), p_pcie_txrx_clock=100 MHz}"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_app_signal_interface" value="AvalonST"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_avalon_mm_lite" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_size_bar_0" value="256 MBytes - 28 bits"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_size_bar_1" value="256 KBytes - 18 bits"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_size_bar_2" value="256 Bytes - 8 bits"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_size_bar_3" value="256 KBytes - 18 bits"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_size_bar_4" value="256 Bytes - 8 bits"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_size_bar_5" value="256 Bytes - 8 bits"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_type_bar_0" value="32-bit Prefetchable Memory"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_type_bar_1" value="32-bit Prefetchable Memory"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_type_bar_2" value="32-bit Non-Prefetchable Memory"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_type_bar_3" value="32-bit Non-Prefetchable Memory"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_type_bar_4" value="I/O Address Space"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_type_bar_5" value="I/O Address Space"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_used_bar_0" value="1"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_used_bar_1" value="1"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_used_bar_2" value="1"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_used_bar_3" value="1"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_used_bar_4" value="1"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_bar_used_bar_5" value="1"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_channel_number" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_chk_io" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_class_code" value="0xFF0000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_completion_data_credit_vc0" value="16"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_completion_data_credit_vc1" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_completion_data_credit_vc2" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_completion_data_credit_vc3" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_completion_data_used_space_vc0" value="256"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_completion_data_used_space_vc1" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_completion_data_used_space_vc2" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_completion_data_used_space_vc3" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_completion_header_credit_vc0" value="4"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_completion_header_credit_vc1" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_completion_header_credit_vc2" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_completion_header_credit_vc3" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_completion_header_used_space_vc0" value="64"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_completion_header_used_space_vc1" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_completion_header_used_space_vc2" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_completion_header_used_space_vc3" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_completion_timeout" value="NONE"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_custom_phy_x8" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_custom_rx_buffer_xml" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_device_id" value="0x0004"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_disable_L0s" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_dll_active_report_support" value="0"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_eie_b4_nfts_count" value="4"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_enable_completion_timeout_disable" value="1"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_enable_function_msix_support" value="0"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_enable_hip" value="1"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_enable_hip_core_clk" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_enable_pcie_gen2_x8_es" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_enable_pcie_gen2_x8_s5gx" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_enable_root_port_endpoint_mode" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_enable_simple_dma" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_enable_slot_capability" value="0"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_enable_tl_bypass_mode" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_endpoint_L0s_acceptable_latency" value="&lt;64 ns"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_endpoint_L1_acceptable_latency" value="&lt;1 us"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_exp_rom_bar_size" value="N/A"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_gen2_nfts_diff_clock" value="255"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_gen2_nfts_same_clock" value="255"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_initiator_performance_preset" value="Low"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_internal_clock" value="125 MHz"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_io_base_and_limit_register" value="IODisable"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_lanerev" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_link_port_number" value="0x01"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_max_payload_size" value="256 Bytes"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_mem_base_and_limit_register" value="MemDisable"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_msix_pba_bir" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_msix_pba_offset" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_msix_table_bir" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_msix_table_offset" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_msix_table_size" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nonposted_data_credit_vc0" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nonposted_data_credit_vc1" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nonposted_data_credit_vc2" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nonposted_data_credit_vc3" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nonposted_data_used_space_vc0" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nonposted_data_used_space_vc1" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nonposted_data_used_space_vc2" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nonposted_data_used_space_vc3" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nonposted_header_credit_vc0" value="32"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nonposted_header_credit_vc1" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nonposted_header_credit_vc2" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nonposted_header_credit_vc3" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nonposted_header_used_space_vc0" value="512"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nonposted_header_used_space_vc1" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nonposted_header_used_space_vc2" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_nonposted_header_used_space_vc3" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_number_of_lanes" value="x1"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_phy_interface" value="Serial"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_pme_pending" value="0"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_pme_reg_id" value="0x0000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_posted_data_credit_vc0" value="176"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_posted_data_credit_vc1" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_posted_data_credit_vc2" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_posted_data_credit_vc3" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_posted_data_used_space_vc0" value="2816"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_posted_data_used_space_vc1" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_posted_data_used_space_vc2" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_posted_data_used_space_vc3" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_posted_header_credit_vc0" value="28"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_posted_header_credit_vc1" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_posted_header_credit_vc2" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_posted_header_credit_vc3" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_posted_header_used_space_vc0" value="448"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_posted_header_used_space_vc1" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_posted_header_used_space_vc2" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_posted_header_used_space_vc3" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_rate" value="Gen1 (2.5 Gbps)"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_retry_buffer_size" value="16 KBytes"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_revision_id" value="0x01"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_rx_buffer_preset" value="Default"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_rx_buffer_size_string_vc0" value="4 KBytes"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_rx_buffer_size_string_vc1" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_rx_buffer_size_string_vc2" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_rx_buffer_size_string_vc3" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_rx_buffer_size_vc0" value="4096"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_rx_buffer_size_vc1" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_rx_buffer_size_vc2" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_rx_buffer_size_vc3" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_slot_capabilities" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_special_phy_gl" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_special_phy_px" value="1"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_subsystem_device_id" value="0x0004"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_subsystem_vendor_id" value="0x1172"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_surprise_down_error_support" value="0"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_target_performance_preset" value="Maximum"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_test_out_width" value="9 bits"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_threshold_for_L0s_entry" value="8192 ns"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_total_header_credit_vc0" value="64"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_total_header_credit_vc1" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_total_header_credit_vc2" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_total_header_credit_vc3" value="0"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_txrx_clock" value="100 MHz"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_underSOPCBuilder" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_use_crc_forwarding" value="0"  type="BOOLEAN"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_use_parity" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_variation_name" value="hard_ip_x1_core"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_vendor_id" value="0x1172"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_version" value="2.0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "p_pcie_virutal_channels" value="1"  type="INTEGER"  enable="1" />
-- Retrieval info:      <PRIVATE name = "pref_nonp_independent" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "translationTableSizeInfo" value="The bridge reserves a contiguous Avalon address range to access
-- Retrieval info: PCIe devices. This Avalon address range is segmented into one or
-- Retrieval info: more equal-sized pages that are individually mapped to PCIe
-- Retrieval info: addresses. Select the number and size of the address pages."  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWAddress0" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWAddress1" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWAddress10" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWAddress11" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWAddress12" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWAddress13" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWAddress14" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWAddress15" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWAddress2" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWAddress3" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWAddress4" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWAddress5" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWAddress6" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWAddress7" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWAddress8" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWAddress9" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWPCIAddress0" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWPCIAddress1" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWPCIAddress10" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWPCIAddress11" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWPCIAddress12" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWPCIAddress13" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWPCIAddress14" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWPCIAddress15" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWPCIAddress2" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWPCIAddress3" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWPCIAddress4" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWPCIAddress5" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWPCIAddress6" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWPCIAddress7" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWPCIAddress8" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonHWPCIAddress9" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiAvalonTranslationTable" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiBar0PCIAddress" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiBar0Prefetchable" value="true"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiBar1PCIAddress" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiBar1Prefetchable" value="true"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiBar2PCIAddress" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiBar2Prefetchable" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiBar3PCIAddress" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiBar3Prefetchable" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiBar4PCIAddress" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiBar4Prefetchable" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiBar5PCIAddress" value="0x00000000"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiBar5Prefetchable" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiCRAInfoPanel" value="other"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiExpROMType" value="Select to Enable"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiFixedTable" value="true"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiPCIBar0Type" value="32-bit Prefetchable Memory"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiPCIBar1Type" value="32-bit Prefetchable Memory"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiPCIBar2Type" value="32-bit Non-Prefetchable Memory"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiPCIBar3Type" value="32-bit Non-Prefetchable Memory"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiPCIBar4Type" value="I/O Address Space"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiPCIBar5Type" value="I/O Address Space"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiPCIBarTable" value="false"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiPCIBusArbiter" value="external"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiPCIDeviceMode" value="masterTarget"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiPCIMasterPerformance" value="burstSinglePending"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiPCITargetPerformance" value="burstSinglePending"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiPaneCount" value="1"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "uiPaneSize" value="20"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "ui_pcie_msix_pba_bir" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "ui_pcie_msix_table_bir" value="0"  type="STRING"  enable="1" />
-- Retrieval info:     </NAMESPACE>
-- Retrieval info:     <NAMESPACE name = "simgen_enable">
-- Retrieval info:      <PRIVATE name = "language" value="VHDL"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "enabled" value="0"  type="STRING"  enable="1" />
-- Retrieval info:     </NAMESPACE>
-- Retrieval info:     <NAMESPACE name = "greybox">
-- Retrieval info:      <PRIVATE name = "gb_enabled" value="0"  type="STRING"  enable="1" />
-- Retrieval info:      <PRIVATE name = "filename" value="hard_ip_x1_syn.v"  type="STRING"  enable="1" />
-- Retrieval info:     </NAMESPACE>
-- Retrieval info:     <NAMESPACE name = "testbench">
-- Retrieval info:      <PRIVATE name = "plugin_worker" value="1"  type="STRING"  enable="1" />
-- Retrieval info:     </NAMESPACE>
-- Retrieval info:     <NAMESPACE name = "simgen">
-- Retrieval info:      <PRIVATE name = "filename" value="hard_ip_x1_core.vhd"  type="STRING"  enable="1" />
-- Retrieval info:     </NAMESPACE>
-- Retrieval info:     <NAMESPACE name = "serializer"/>
-- Retrieval info:    </PRIVATES>
-- Retrieval info:    <FILES/>
-- Retrieval info:    <PORTS/>
-- Retrieval info:    <LIBRARIES/>
-- Retrieval info:   </STATIC_SECTION>
-- Retrieval info:  </NETLIST_SECTION>
-- Retrieval info: </MEGACORE>
-- =========================================================
