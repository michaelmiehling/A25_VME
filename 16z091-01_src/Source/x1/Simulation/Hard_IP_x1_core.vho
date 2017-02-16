--IP Functional Simulation Model
--VERSION_BEGIN 11.0SP1 cbx_mgl 2011:07:03:21:10:12:SJ cbx_simgen 2011:07:03:21:07:09:SJ  VERSION_END


-- Copyright (C) 1991-2011 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- You may only use these simulation model output files for simulation
-- purposes and expressly not for synthesis or any other purposes (in which
-- event Altera disclaims all warranties of any kind).


--synopsys translate_off

 LIBRARY altera_mf;
 USE altera_mf.altera_mf_components.all;

 LIBRARY cycloneiv_pcie_hip;
 USE cycloneiv_pcie_hip.cycloneiv_pcie_hip_components.all;

 LIBRARY sgate;
 USE sgate.sgate_pack.all;

--synthesis_resources = altsyncram 1 cycloneiv_hssi_pcie_hip 1 lut 78 mux21 88 oper_add 6 oper_less_than 6 
 LIBRARY ieee;
 USE ieee.std_logic_1164.all;

 ENTITY  Hard_IP_x1_core IS
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
	 PORT 
	 ( 
		 aer_msi_num	:	IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
		 app_int_ack	:	OUT  STD_LOGIC;
		 app_int_sts	:	IN  STD_LOGIC;
		 app_msi_ack	:	OUT  STD_LOGIC;
		 app_msi_num	:	IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
		 app_msi_req	:	IN  STD_LOGIC;
		 app_msi_tc	:	IN  STD_LOGIC_VECTOR (2 DOWNTO 0);
		 AvlClk_i	:	IN  STD_LOGIC;
		 avs_pcie_reconfig_readdata	:	OUT  STD_LOGIC_VECTOR (15 DOWNTO 0);
		 avs_pcie_reconfig_readdatavalid	:	OUT  STD_LOGIC;
		 avs_pcie_reconfig_waitrequest	:	OUT  STD_LOGIC;
		 core_clk_in	:	IN  STD_LOGIC;
		 core_clk_out	:	OUT  STD_LOGIC;
		 cpl_err	:	IN  STD_LOGIC_VECTOR (6 DOWNTO 0);
		 cpl_pending	:	IN  STD_LOGIC;
		 CraAddress_i	:	IN  STD_LOGIC_VECTOR (11 DOWNTO 0);
		 CraByteEnable_i	:	IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
		 CraChipSelect_i	:	IN  STD_LOGIC;
		 CraIrq_o	:	OUT  STD_LOGIC;
		 CraRead	:	IN  STD_LOGIC;
		 CraReadData_o	:	OUT  STD_LOGIC_VECTOR (31 DOWNTO 0);
		 CraWaitRequest_o	:	OUT  STD_LOGIC;
		 CraWrite	:	IN  STD_LOGIC;
		 CraWriteData_i	:	IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
		 crst	:	IN  STD_LOGIC;
		 derr_cor_ext_rcv0	:	OUT  STD_LOGIC;
		 derr_cor_ext_rpl	:	OUT  STD_LOGIC;
		 derr_rpl	:	OUT  STD_LOGIC;
		 dl_ltssm	:	OUT  STD_LOGIC_VECTOR (4 DOWNTO 0);
		 dlup_exit	:	OUT  STD_LOGIC;
		 eidle_infer_sel	:	OUT  STD_LOGIC_VECTOR (23 DOWNTO 0);
		 ev_128ns	:	OUT  STD_LOGIC;
		 ev_1us	:	OUT  STD_LOGIC;
		 hip_extraclkout	:	OUT  STD_LOGIC_VECTOR (1 DOWNTO 0);
		 hotrst_exit	:	OUT  STD_LOGIC;
		 hpg_ctrler	:	IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
		 int_status	:	OUT  STD_LOGIC_VECTOR (3 DOWNTO 0);
		 l2_exit	:	OUT  STD_LOGIC;
		 lane_act	:	OUT  STD_LOGIC_VECTOR (3 DOWNTO 0);
		 lmi_ack	:	OUT  STD_LOGIC;
		 lmi_addr	:	IN  STD_LOGIC_VECTOR (11 DOWNTO 0);
		 lmi_din	:	IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
		 lmi_dout	:	OUT  STD_LOGIC_VECTOR (31 DOWNTO 0);
		 lmi_rden	:	IN  STD_LOGIC;
		 lmi_wren	:	IN  STD_LOGIC;
		 npd_alloc_1cred_vc0	:	OUT  STD_LOGIC;
		 npd_cred_vio_vc0	:	OUT  STD_LOGIC;
		 nph_alloc_1cred_vc0	:	OUT  STD_LOGIC;
		 nph_cred_vio_vc0	:	OUT  STD_LOGIC;
		 npor	:	IN  STD_LOGIC;
		 pclk_central	:	IN  STD_LOGIC;
		 pclk_ch0	:	IN  STD_LOGIC;
		 pex_msi_num	:	IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
		 phystatus0_ext	:	IN  STD_LOGIC;
		 pld_clk	:	IN  STD_LOGIC;
		 pll_fixed_clk	:	IN  STD_LOGIC;
		 pm_auxpwr	:	IN  STD_LOGIC;
		 pm_data	:	IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
		 pm_event	:	IN  STD_LOGIC;
		 pme_to_cr	:	IN  STD_LOGIC;
		 pme_to_sr	:	OUT  STD_LOGIC;
		 powerdown0_ext	:	OUT  STD_LOGIC_VECTOR (1 DOWNTO 0);
		 r2c_err0	:	OUT  STD_LOGIC;
		 rate_ext	:	OUT  STD_LOGIC;
		 rc_areset	:	IN  STD_LOGIC;
		 rc_gxb_powerdown	:	OUT  STD_LOGIC;
		 rc_inclk_eq_125mhz	:	IN  STD_LOGIC;
		 rc_pll_locked	:	IN  STD_LOGIC;
		 rc_rx_analogreset	:	OUT  STD_LOGIC;
		 rc_rx_digitalreset	:	OUT  STD_LOGIC;
		 rc_rx_pll_locked_one	:	IN  STD_LOGIC;
		 rc_tx_digitalreset	:	OUT  STD_LOGIC;
		 reset_status	:	OUT  STD_LOGIC;
		 Rstn_i	:	IN  STD_LOGIC;
		 rx_fifo_empty0	:	OUT  STD_LOGIC;
		 rx_fifo_full0	:	OUT  STD_LOGIC;
		 rx_st_bardec0	:	OUT  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 rx_st_be0	:	OUT  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 rx_st_be0_p1	:	OUT  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 rx_st_data0	:	OUT  STD_LOGIC_VECTOR (63 DOWNTO 0);
		 rx_st_data0_p1	:	OUT  STD_LOGIC_VECTOR (63 DOWNTO 0);
		 rx_st_eop0	:	OUT  STD_LOGIC;
		 rx_st_eop0_p1	:	OUT  STD_LOGIC;
		 rx_st_err0	:	OUT  STD_LOGIC;
		 rx_st_mask0	:	IN  STD_LOGIC;
		 rx_st_ready0	:	IN  STD_LOGIC;
		 rx_st_sop0	:	OUT  STD_LOGIC;
		 rx_st_sop0_p1	:	OUT  STD_LOGIC;
		 rx_st_valid0	:	OUT  STD_LOGIC;
		 rxdata0_ext	:	IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 rxdatak0_ext	:	IN  STD_LOGIC;
		 rxelecidle0_ext	:	IN  STD_LOGIC;
		 RxmAddress_o	:	OUT  STD_LOGIC_VECTOR (31 DOWNTO 0);
		 RxmBurstCount_o	:	OUT  STD_LOGIC_VECTOR (9 DOWNTO 0);
		 RxmByteEnable_o	:	OUT  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 RxmIrq_i	:	IN  STD_LOGIC;
		 RxmIrqNum_i	:	IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
		 RxmRead_o	:	OUT  STD_LOGIC;
		 RxmReadData_i	:	IN  STD_LOGIC_VECTOR (63 DOWNTO 0);
		 RxmReadDataValid_i	:	IN  STD_LOGIC;
		 RxmWaitRequest_i	:	IN  STD_LOGIC;
		 RxmWrite_o	:	OUT  STD_LOGIC;
		 RxmWriteData_o	:	OUT  STD_LOGIC_VECTOR (63 DOWNTO 0);
		 rxpolarity0_ext	:	OUT  STD_LOGIC;
		 rxstatus0_ext	:	IN  STD_LOGIC_VECTOR (2 DOWNTO 0);
		 rxvalid0_ext	:	IN  STD_LOGIC;
		 serr_out	:	OUT  STD_LOGIC;
		 srst	:	IN  STD_LOGIC;
		 suc_spd_neg	:	OUT  STD_LOGIC;
		 swdn_wake	:	OUT  STD_LOGIC;
		 swup_hotrst	:	OUT  STD_LOGIC;
		 test_in	:	IN  STD_LOGIC_VECTOR (39 DOWNTO 0);
		 test_out	:	OUT  STD_LOGIC_VECTOR (63 DOWNTO 0);
		 tl_cfg_add	:	OUT  STD_LOGIC_VECTOR (3 DOWNTO 0);
		 tl_cfg_ctl	:	OUT  STD_LOGIC_VECTOR (31 DOWNTO 0);
		 tl_cfg_ctl_wr	:	OUT  STD_LOGIC;
		 tl_cfg_sts	:	OUT  STD_LOGIC_VECTOR (52 DOWNTO 0);
		 tl_cfg_sts_wr	:	OUT  STD_LOGIC;
		 tx_cred0	:	OUT  STD_LOGIC_VECTOR (35 DOWNTO 0);
		 tx_deemph	:	OUT  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 tx_fifo_empty0	:	OUT  STD_LOGIC;
		 tx_fifo_full0	:	OUT  STD_LOGIC;
		 tx_fifo_rdptr0	:	OUT  STD_LOGIC_VECTOR (3 DOWNTO 0);
		 tx_fifo_wrptr0	:	OUT  STD_LOGIC_VECTOR (3 DOWNTO 0);
		 tx_margin	:	OUT  STD_LOGIC_VECTOR (23 DOWNTO 0);
		 tx_st_data0	:	IN  STD_LOGIC_VECTOR (63 DOWNTO 0);
		 tx_st_data0_p1	:	IN  STD_LOGIC_VECTOR (63 DOWNTO 0);
		 tx_st_eop0	:	IN  STD_LOGIC;
		 tx_st_eop0_p1	:	IN  STD_LOGIC;
		 tx_st_err0	:	IN  STD_LOGIC;
		 tx_st_ready0	:	OUT  STD_LOGIC;
		 tx_st_sop0	:	IN  STD_LOGIC;
		 tx_st_sop0_p1	:	IN  STD_LOGIC;
		 tx_st_valid0	:	IN  STD_LOGIC;
		 txcompl0_ext	:	OUT  STD_LOGIC;
		 txdata0_ext	:	OUT  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 txdatak0_ext	:	OUT  STD_LOGIC;
		 txdetectrx0_ext	:	OUT  STD_LOGIC;
		 txelecidle0_ext	:	OUT  STD_LOGIC;
		 TxsAddress_i	:	IN  STD_LOGIC_VECTOR (16 DOWNTO 0);
		 TxsBurstCount_i	:	IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
		 TxsByteEnable_i	:	IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 TxsChipSelect_i	:	IN  STD_LOGIC;
		 TxsRead_i	:	IN  STD_LOGIC;
		 TxsReadData_o	:	OUT  STD_LOGIC_VECTOR (63 DOWNTO 0);
		 TxsReadDataValid_o	:	OUT  STD_LOGIC;
		 TxsWaitRequest_o	:	OUT  STD_LOGIC;
		 TxsWrite_i	:	IN  STD_LOGIC;
		 TxsWriteData_i	:	IN  STD_LOGIC_VECTOR (63 DOWNTO 0);
		 use_pcie_reconfig	:	OUT  STD_LOGIC;
		 wake_oen	:	OUT  STD_LOGIC
	 ); 
 END Hard_IP_x1_core;

 ARCHITECTURE RTL OF Hard_IP_x1_core IS

	 ATTRIBUTE synthesis_clearbox : natural;
	 ATTRIBUTE synthesis_clearbox OF RTL : ARCHITECTURE IS 1;
	 SIGNAL  wire_gnd	:	STD_LOGIC;
	 SIGNAL  wire_n01Oil_address_a	:	STD_LOGIC_VECTOR (14 DOWNTO 0);
	 SIGNAL  wire_n01Oil_address_b	:	STD_LOGIC_VECTOR (14 DOWNTO 0);
	 SIGNAL  wire_n01Oil_byteena_a	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n01Oil_byteena_b	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_vcc	:	STD_LOGIC;
	 SIGNAL  wire_n01Oil_data_a	:	STD_LOGIC_VECTOR (254 DOWNTO 0);
	 SIGNAL  wire_n01Oil_data_b	:	STD_LOGIC_VECTOR (254 DOWNTO 0);
	 SIGNAL  wire_n0l1il_w_lg_w_txcredvc0_range1635w3427w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n0l1il_w_lg_w_txcredvc0_range1644w3447w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n0l1il_w_lg_w_txcredvc0_range1638w3426w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n0l1il_w_lg_w_txcredvc0_range1647w3446w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n0l1il_coreclkout	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_corepor	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_corerst	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_cplerr	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_n0l1il_dbgpipex1rx	:	STD_LOGIC_VECTOR (14 DOWNTO 0);
	 SIGNAL  wire_n0l1il_derrcorextrcv0	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_derrcorextrpl	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_derrrpl	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_dlctrllink2	:	STD_LOGIC_VECTOR (12 DOWNTO 0);
	 SIGNAL  wire_n0l1il_dldataupfc	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n0l1il_dlhdrupfc	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0l1il_dlltssm	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n0l1il_dlmaxploaddcr	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n0l1il_dlreqphycfg	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n0l1il_dlreqphypm	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n0l1il_dltxtyppm	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n0l1il_dltypupfc	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n0l1il_dlupexit	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_dlvcctrl	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0l1il_dlvcidmap	:	STD_LOGIC_VECTOR (23 DOWNTO 0);
	 SIGNAL  wire_n0l1il_dlvcidupfc	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n0l1il_eidleinfersel	:	STD_LOGIC_VECTOR (23 DOWNTO 0);
	 SIGNAL  wire_n0l1il_ev128ns	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_ev1us	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_extraclkout	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n0l1il_extraout	:	STD_LOGIC_VECTOR (14 DOWNTO 0);
	 SIGNAL  wire_n0l1il_gen2rate	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_hotrstexit	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_intstatus	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n0l1il_l2exit	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_laneact	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n0l1il_lmiack	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_lmiaddr	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n0l1il_lmidin	:	STD_LOGIC_VECTOR (31 DOWNTO 0);
	 SIGNAL  wire_n0l1il_lmidout	:	STD_LOGIC_VECTOR (31 DOWNTO 0);
	 SIGNAL  wire_n0l1il_mode	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n0l1il_phyrst	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_phystatus	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0l1il_pldrst	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_powerdown	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	 SIGNAL  wire_n0l1il_resetstatus	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_rxbardecvc0	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0l1il_rxbevc00	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0l1il_rxbevc01	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0l1il_rxdata	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n0l1il_rxdatak	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0l1il_rxdatavc00	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n0l1il_rxdatavc01	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n0l1il_rxelecidle	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0l1il_rxeopvc00	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_rxeopvc01	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_rxerrvc0	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_rxfifoemptyvc0	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_rxfifofullvc0	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_rxpolarity	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0l1il_rxsopvc00	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_rxsopvc01	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_rxstatus	:	STD_LOGIC_VECTOR (23 DOWNTO 0);
	 SIGNAL  wire_n0l1il_rxvalid	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0l1il_rxvalidvc0	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_serrout	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_swdnin	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n0l1il_swdnwake	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_swuphotrst	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_swupin	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_n0l1il_testin	:	STD_LOGIC_VECTOR (39 DOWNTO 0);
	 SIGNAL  wire_n0l1il_testout	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n0l1il_tlaermsinum	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n0l1il_tlappintaack	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_tlappmsiack	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_tlappmsinum	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n0l1il_tlappmsitc	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n0l1il_tlcfgadd	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n0l1il_tlcfgctl	:	STD_LOGIC_VECTOR (31 DOWNTO 0);
	 SIGNAL  wire_n0l1il_tlcfgctlwr	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_tlcfgsts	:	STD_LOGIC_VECTOR (52 DOWNTO 0);
	 SIGNAL  wire_n0l1il_tlcfgstswr	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_tlhpgctrler	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n0l1il_tlpexmsinum	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n0l1il_tlpmdata	:	STD_LOGIC_VECTOR (9 DOWNTO 0);
	 SIGNAL  wire_n0l1il_tlpmetosr	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_txcompl	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0l1il_txcredvc0	:	STD_LOGIC_VECTOR (35 DOWNTO 0);
	 SIGNAL  wire_n0l1il_txdata	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n0l1il_txdatak	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0l1il_txdatavc00	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n0l1il_txdatavc01	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n0l1il_txdatavc10	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n0l1il_txdatavc11	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n0l1il_txdeemph	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0l1il_txdetectrx	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0l1il_txelecidle	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0l1il_txfifoemptyvc0	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_txfifofullvc0	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_txfifordpvc0	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n0l1il_txfifowrpvc0	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n0l1il_txmargin	:	STD_LOGIC_VECTOR (23 DOWNTO 0);
	 SIGNAL  wire_n0l1il_txreadyvc0	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_wakeoen	:	STD_LOGIC;
	 SIGNAL  wire_n0l1il_w_txcredvc0_range1635w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n0l1il_w_txcredvc0_range1638w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n0l1il_w_txcredvc0_range1644w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n0l1il_w_txcredvc0_range1647w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n010ii45	:	STD_LOGIC := '0';
	 SIGNAL	 n010ii46	:	STD_LOGIC := '0';
	 SIGNAL  wire_n010ii46_w_lg_w_lg_q3582w3583w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n010ii46_w_lg_q3582w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n010il43	:	STD_LOGIC := '0';
	 SIGNAL	 n010il44	:	STD_LOGIC := '0';
	 SIGNAL  wire_n010il44_w_lg_w_lg_q3577w3578w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n010il44_w_lg_q3577w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n010iO41	:	STD_LOGIC := '0';
	 SIGNAL	 n010iO42	:	STD_LOGIC := '0';
	 SIGNAL  wire_n010iO42_w_lg_w_lg_q3574w3575w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n010iO42_w_lg_q3574w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n010li39	:	STD_LOGIC := '0';
	 SIGNAL	 n010li40	:	STD_LOGIC := '0';
	 SIGNAL	 n010ll37	:	STD_LOGIC := '0';
	 SIGNAL	 n010ll38	:	STD_LOGIC := '0';
	 SIGNAL	 n010lO35	:	STD_LOGIC := '0';
	 SIGNAL	 n010lO36	:	STD_LOGIC := '0';
	 SIGNAL	 n010OO33	:	STD_LOGIC := '0';
	 SIGNAL	 n010OO34	:	STD_LOGIC := '0';
	 SIGNAL	 n01i0l29	:	STD_LOGIC := '0';
	 SIGNAL	 n01i0l30	:	STD_LOGIC := '0';
	 SIGNAL  wire_n01i0l30_w_lg_w_lg_q3491w3492w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n01i0l30_w_lg_q3491w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n01i0O27	:	STD_LOGIC := '0';
	 SIGNAL	 n01i0O28	:	STD_LOGIC := '0';
	 SIGNAL  wire_n01i0O28_w_lg_w_lg_q3456w3457w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n01i0O28_w_lg_q3456w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n01i1l31	:	STD_LOGIC := '0';
	 SIGNAL	 n01i1l32	:	STD_LOGIC := '0';
	 SIGNAL  wire_n01i1l32_w_lg_q3540w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n01iii25	:	STD_LOGIC := '0';
	 SIGNAL	 n01iii26	:	STD_LOGIC := '0';
	 SIGNAL  wire_n01iii26_w_lg_w_lg_q3441w3442w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n01iii26_w_lg_q3441w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n01iil23	:	STD_LOGIC := '0';
	 SIGNAL	 n01iil24	:	STD_LOGIC := '0';
	 SIGNAL  wire_n01iil24_w_lg_w_lg_q3437w3438w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n01iil24_w_lg_q3437w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n01iiO21	:	STD_LOGIC := '0';
	 SIGNAL	 n01iiO22	:	STD_LOGIC := '0';
	 SIGNAL  wire_n01iiO22_w_lg_w_lg_q3421w3422w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n01iiO22_w_lg_q3421w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n01ill19	:	STD_LOGIC := '0';
	 SIGNAL	 n01ill20	:	STD_LOGIC := '0';
	 SIGNAL	 n01iOl17	:	STD_LOGIC := '0';
	 SIGNAL	 n01iOl18	:	STD_LOGIC := '0';
	 SIGNAL	 n01l0O11	:	STD_LOGIC := '0';
	 SIGNAL	 n01l0O12	:	STD_LOGIC := '0';
	 SIGNAL	 n01l1i15	:	STD_LOGIC := '0';
	 SIGNAL	 n01l1i16	:	STD_LOGIC := '0';
	 SIGNAL  wire_n01l1i16_w_lg_w_lg_q3399w3400w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n01l1i16_w_lg_q3399w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n01l1O13	:	STD_LOGIC := '0';
	 SIGNAL	 n01l1O14	:	STD_LOGIC := '0';
	 SIGNAL  wire_n01l1O14_w_lg_w_lg_q3394w3395w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n01l1O14_w_lg_q3394w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n01liO10	:	STD_LOGIC := '0';
	 SIGNAL	 n01liO9	:	STD_LOGIC := '0';
	 SIGNAL	 n01llO7	:	STD_LOGIC := '0';
	 SIGNAL	 n01llO8	:	STD_LOGIC := '0';
	 SIGNAL	 n01lOl5	:	STD_LOGIC := '0';
	 SIGNAL	 n01lOl6	:	STD_LOGIC := '0';
	 SIGNAL  wire_n01lOl6_w_lg_q3374w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n01O1i3	:	STD_LOGIC := '0';
	 SIGNAL	 n01O1i4	:	STD_LOGIC := '0';
	 SIGNAL  wire_n01O1i4_w_lg_q3364w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n01O1O1	:	STD_LOGIC := '0';
	 SIGNAL	 n01O1O2	:	STD_LOGIC := '0';
	 SIGNAL	n00l0l	:	STD_LOGIC := '0';
	 SIGNAL	n00l1O	:	STD_LOGIC := '0';
	 SIGNAL	wire_n00l0i_CLRN	:	STD_LOGIC;
	 SIGNAL	n00ilO	:	STD_LOGIC := '0';
	 SIGNAL	n00iOi	:	STD_LOGIC := '0';
	 SIGNAL	n00iOl	:	STD_LOGIC := '0';
	 SIGNAL	n00iOO	:	STD_LOGIC := '0';
	 SIGNAL	n00l0O	:	STD_LOGIC := '0';
	 SIGNAL	n00l1i	:	STD_LOGIC := '0';
	 SIGNAL	n00l1l	:	STD_LOGIC := '0';
	 SIGNAL	n00lii	:	STD_LOGIC := '0';
	 SIGNAL	n00lil	:	STD_LOGIC := '0';
	 SIGNAL	n00liO	:	STD_LOGIC := '0';
	 SIGNAL	n00lli	:	STD_LOGIC := '0';
	 SIGNAL	n00lll	:	STD_LOGIC := '0';
	 SIGNAL	n00llO	:	STD_LOGIC := '0';
	 SIGNAL	n00lOi	:	STD_LOGIC := '0';
	 SIGNAL	n00lOl	:	STD_LOGIC := '0';
	 SIGNAL	n00lOO	:	STD_LOGIC := '0';
	 SIGNAL	n00O0i	:	STD_LOGIC := '0';
	 SIGNAL	n00O0l	:	STD_LOGIC := '0';
	 SIGNAL	n00O0O	:	STD_LOGIC := '0';
	 SIGNAL	n00O1i	:	STD_LOGIC := '0';
	 SIGNAL	n00O1l	:	STD_LOGIC := '0';
	 SIGNAL	n00O1O	:	STD_LOGIC := '0';
	 SIGNAL	n00Oii	:	STD_LOGIC := '0';
	 SIGNAL	n00Oil	:	STD_LOGIC := '0';
	 SIGNAL	n00OiO	:	STD_LOGIC := '0';
	 SIGNAL	n00Oli	:	STD_LOGIC := '0';
	 SIGNAL	n00Oll	:	STD_LOGIC := '0';
	 SIGNAL	n00OOi	:	STD_LOGIC := '0';
	 SIGNAL	wire_n00OlO_CLRN	:	STD_LOGIC;
	 SIGNAL  wire_n00OlO_w_lg_n00l0O3714w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00lii3717w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00lil3719w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00liO3721w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00lli3723w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00lll3725w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00llO3727w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00lOi3729w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00lOl3731w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00lOO3733w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00O0i3629w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00O0l3632w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00O0O3634w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00O1i3735w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00O1l3737w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00Oii3636w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00Oil3638w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00OiO3640w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00Oli3642w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00OlO_w_lg_n00Oll3644w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	n00OOl	:	STD_LOGIC := '0';
	 SIGNAL	n0iOiO	:	STD_LOGIC := '0';
	 SIGNAL	wire_n0iOil_CLRN	:	STD_LOGIC;
	 SIGNAL	wire_n0000i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0001i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0001l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0001O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n000iO_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n000iO_w_lg_dataout3835w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n000li_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n000li_w_lg_dataout3833w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n000ll_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n000ll_w_lg_dataout3831w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n000lO_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n000lO_w_lg_dataout3829w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n000Oi_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n000Oi_w_lg_dataout3827w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n000Ol_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n000Ol_w_lg_dataout3825w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n000OO_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n000OO_w_lg_dataout3823w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n0010i_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n0010i_w_lg_dataout3858w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n0010l_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n0010l_w_lg_dataout3856w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n0010O_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n0010O_w_lg_dataout3854w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n001ii_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n001ii_w_lg_dataout3852w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n001il_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n001il_w_lg_dataout3850w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n001iO_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n001iO_w_lg_dataout3848w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n001li_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n001li_w_lg_dataout3846w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n001ll_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n001ll_w_lg_dataout3844w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n001lO_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n001lO_w_lg_dataout3842w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n001Oi_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n001Oi_w_lg_dataout3840w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n001Ol_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n001Ol_w_lg_dataout3838w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n001OO_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n001OO_w_lg_dataout3837w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n00i0i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00i0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00i1i_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n00i1i_w_lg_dataout3822w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n00i1l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00i1O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00OOO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i00i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i00l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i00O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i01i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i01l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i01O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i0ii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i0il_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i0iO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i0li_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i0ll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i0lO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i0Oi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i0Ol_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i10i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i10l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i10O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i11i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i11l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i11O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i1ii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i1il_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i1iO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i1li_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i1ll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i1lO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i1Oi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i1Ol_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i1OO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0ii0i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0ii0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0ii0O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0iiii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0iiil_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0iiiO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0iili_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0iill_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0iilO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0iiOi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0iiOl_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0iiOO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0il0i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0il0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0il0O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0il1l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0il1O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0ilii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0ilil_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0iliO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0illl_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0illO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0ilOl_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0ilOO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0iO0i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0iO0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0iO1l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0iO1O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0iOli_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0iOll_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n0iOll_w_lg_w_lg_dataout3538w3541w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n0iOll_w_lg_dataout3538w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n0iOll_w_lg_w_lg_w_lg_dataout3538w3541w3542w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n0000l_a	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n0000l_b	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n0000l_o	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n000ii_a	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n000ii_b	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n000ii_o	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n00i0O_a	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n00i0O_b	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n00i0O_o	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n00iil_a	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00iil_b	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00iil_o	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0il1i_a	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n0il1i_b	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n0il1i_o	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n0illi_a	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0illi_b	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0illi_o	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n0000O_a	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n0000O_b	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n0000O_o	:	STD_LOGIC;
	 SIGNAL  wire_n00iii_a	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n00iii_b	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n00iii_o	:	STD_LOGIC;
	 SIGNAL  wire_n00ili_a	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n00ili_b	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n00ili_o	:	STD_LOGIC;
	 SIGNAL  wire_n00ill_a	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00ill_b	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00ill_o	:	STD_LOGIC;
	 SIGNAL  wire_n0ilOi_w_lg_o3445w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n0ilOi_a	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n0ilOi_b	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n0ilOi_o	:	STD_LOGIC;
	 SIGNAL  wire_n0iO1i_w_lg_o3425w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n0iO1i_a	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n0iO1i_b	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n0iO1i_o	:	STD_LOGIC;
	 SIGNAL  wire_w_lg_w_lg_w_lg_w3365w3372w3375w3376w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_lg_w3365w3372w3375w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w3365w3372w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w3370w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w3365w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_lg_w_tx_st_data0_range2080w3366w3368w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_lg_w_tx_st_data0_range2095w3361w3362w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_lg_w_tx_st_data0_range2098w3356w3357w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_tx_st_valid03402w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w3370w3371w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_n01lll3382w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_npor1853w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_tx_st_err03391w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_tx_st_data0_range2080w3366w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_tx_st_data0_range2083w3367w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_tx_st_data0_range2086w3369w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_tx_st_data0_range2095w3361w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_tx_st_data0_range2098w3356w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_lg_tx_st_eop03397w3401w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_tx_st_eop03397w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_lg_tx_st_eop03392w3396w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_tx_st_eop03392w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  n0100l :	STD_LOGIC;
	 SIGNAL  n0100O :	STD_LOGIC;
	 SIGNAL  n010Ol :	STD_LOGIC;
	 SIGNAL  n01i0i :	STD_LOGIC;
	 SIGNAL  n01ili :	STD_LOGIC;
	 SIGNAL  n01ilO :	STD_LOGIC;
	 SIGNAL  n01iOi :	STD_LOGIC;
	 SIGNAL  n01l0l :	STD_LOGIC;
	 SIGNAL  n01lil :	STD_LOGIC;
	 SIGNAL  n01lll :	STD_LOGIC;
	 SIGNAL  n01Oii :	STD_LOGIC;
	 SIGNAL  wire_w_tx_st_data0_range2080w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_tx_st_data0_range2083w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_tx_st_data0_range2086w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_tx_st_data0_range2095w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_tx_st_data0_range2098w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
 BEGIN

	wire_gnd <= '0';
	wire_vcc <= '1';
	wire_w_lg_w_lg_w_lg_w3365w3372w3375w3376w(0) <= wire_w_lg_w_lg_w3365w3372w3375w(0) AND n01Oii;
	wire_w_lg_w_lg_w3365w3372w3375w(0) <= wire_w_lg_w3365w3372w(0) AND wire_n01lOl6_w_lg_q3374w(0);
	wire_w_lg_w3365w3372w(0) <= wire_w3365w(0) AND wire_w_lg_w3370w3371w(0);
	wire_w3370w(0) <= wire_w_lg_w_lg_w_tx_st_data0_range2080w3366w3368w(0) AND wire_w_lg_w_tx_st_data0_range2086w3369w(0);
	wire_w3365w(0) <= wire_w_lg_w_lg_w_tx_st_data0_range2095w3361w3362w(0) AND wire_n01O1i4_w_lg_q3364w(0);
	wire_w_lg_w_lg_w_tx_st_data0_range2080w3366w3368w(0) <= wire_w_lg_w_tx_st_data0_range2080w3366w(0) AND wire_w_lg_w_tx_st_data0_range2083w3367w(0);
	wire_w_lg_w_lg_w_tx_st_data0_range2095w3361w3362w(0) <= wire_w_lg_w_tx_st_data0_range2095w3361w(0) AND wire_w_tx_st_data0_range2098w(0);
	wire_w_lg_w_lg_w_tx_st_data0_range2098w3356w3357w(0) <= wire_w_lg_w_tx_st_data0_range2098w3356w(0) AND n01Oii;
	wire_w_lg_tx_st_valid03402w(0) <= tx_st_valid0 AND wire_w_lg_w_lg_tx_st_eop03397w3401w(0);
	wire_w_lg_w3370w3371w(0) <= NOT wire_w3370w(0);
	wire_w_lg_n01lll3382w(0) <= NOT n01lll;
	wire_w_lg_npor1853w(0) <= NOT npor;
	wire_w_lg_tx_st_err03391w(0) <= NOT tx_st_err0;
	wire_w_lg_w_tx_st_data0_range2080w3366w(0) <= NOT wire_w_tx_st_data0_range2080w(0);
	wire_w_lg_w_tx_st_data0_range2083w3367w(0) <= NOT wire_w_tx_st_data0_range2083w(0);
	wire_w_lg_w_tx_st_data0_range2086w3369w(0) <= NOT wire_w_tx_st_data0_range2086w(0);
	wire_w_lg_w_tx_st_data0_range2095w3361w(0) <= NOT wire_w_tx_st_data0_range2095w(0);
	wire_w_lg_w_tx_st_data0_range2098w3356w(0) <= NOT wire_w_tx_st_data0_range2098w(0);
	wire_w_lg_w_lg_tx_st_eop03397w3401w(0) <= wire_w_lg_tx_st_eop03397w(0) OR wire_n01l1i16_w_lg_w_lg_q3399w3400w(0);
	wire_w_lg_tx_st_eop03397w(0) <= tx_st_eop0 OR wire_w_lg_w_lg_tx_st_eop03392w3396w(0);
	wire_w_lg_w_lg_tx_st_eop03392w3396w(0) <= wire_w_lg_tx_st_eop03392w(0) XOR wire_n01l1O14_w_lg_w_lg_q3394w3395w(0);
	wire_w_lg_tx_st_eop03392w(0) <= tx_st_eop0 XOR tx_st_eop0_p1;
	app_int_ack <= wire_n0l1il_tlappintaack;
	app_msi_ack <= wire_n0l1il_tlappmsiack;
	avs_pcie_reconfig_readdata <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	avs_pcie_reconfig_readdatavalid <= '0';
	avs_pcie_reconfig_waitrequest <= '1';
	core_clk_out <= wire_n0l1il_coreclkout;
	CraIrq_o <= '0';
	CraReadData_o <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	CraWaitRequest_o <= '0';
	derr_cor_ext_rcv0 <= wire_n0l1il_derrcorextrcv0;
	derr_cor_ext_rpl <= wire_n0l1il_derrcorextrpl;
	derr_rpl <= wire_n0l1il_derrrpl;
	dl_ltssm <= ( wire_n0l1il_dlltssm(4 DOWNTO 0));
	dlup_exit <= wire_n0l1il_dlupexit;
	eidle_infer_sel <= ( wire_n0l1il_eidleinfersel(23 DOWNTO 0));
	ev_128ns <= wire_n0l1il_ev128ns;
	ev_1us <= wire_n0l1il_ev1us;
	hip_extraclkout <= ( wire_n0l1il_extraclkout(1 DOWNTO 0));
	hotrst_exit <= wire_n0l1il_hotrstexit;
	int_status <= ( wire_n0l1il_intstatus(3 DOWNTO 0));
	l2_exit <= wire_n0l1il_l2exit;
	lane_act <= ( wire_n0l1il_laneact(3 DOWNTO 0));
	lmi_ack <= wire_n0l1il_lmiack;
	lmi_dout <= ( wire_n0l1il_lmidout(31 DOWNTO 0));
	n0100l <= (wire_n00ili_o AND (((NOT wire_n0l1il_txcredvc0(18)) AND wire_n0l1il_w_lg_w_txcredvc0_range1647w3446w(0)) AND (NOT wire_n0l1il_txcredvc0(20))));
	n0100O <= (wire_n00ill_o AND (((NOT wire_n0l1il_txcredvc0(15)) AND wire_n0l1il_w_lg_w_txcredvc0_range1638w3426w(0)) AND (NOT wire_n0l1il_txcredvc0(17))));
	n010Ol <= (((((((((((wire_n001OO_w_lg_dataout3837w(0) AND wire_n001Ol_w_lg_dataout3838w(0)) AND wire_n001Oi_w_lg_dataout3840w(0)) AND wire_n001lO_w_lg_dataout3842w(0)) AND wire_n001ll_w_lg_dataout3844w(0)) AND wire_n001li_w_lg_dataout3846w(0)) AND wire_n001iO_w_lg_dataout3848w(0)) AND wire_n001il_w_lg_dataout3850w(0)) AND wire_n001ii_w_lg_dataout3852w(0)) AND wire_n0010O_w_lg_dataout3854w(0)) AND wire_n0010l_w_lg_dataout3856w(0)) AND wire_n0010i_w_lg_dataout3858w(0));
	n01i0i <= (((((((wire_n00i1i_w_lg_dataout3822w(0) AND wire_n000OO_w_lg_dataout3823w(0)) AND wire_n000Ol_w_lg_dataout3825w(0)) AND wire_n000Oi_w_lg_dataout3827w(0)) AND wire_n000lO_w_lg_dataout3829w(0)) AND wire_n000ll_w_lg_dataout3831w(0)) AND wire_n000li_w_lg_dataout3833w(0)) AND wire_n000iO_w_lg_dataout3835w(0));
	n01ili <= (tx_st_err0 AND tx_st_valid0);
	n01ilO <= '1';
	n01iOi <= ((wire_w_lg_tx_st_err03391w(0) AND wire_w_lg_tx_st_valid03402w(0)) AND (n01iOl18 XOR n01iOl17));
	n01l0l <= ((tx_st_sop0 AND tx_st_valid0) AND (n01l0O12 XOR n01l0O11));
	n01lil <= (((((wire_w_lg_w_lg_w_tx_st_data0_range2098w3356w3357w(0) AND (n01O1O2 XOR n01O1O1)) OR wire_w_lg_w_lg_w_lg_w3365w3372w3375w3376w(0)) OR (NOT (n01llO8 XOR n01llO7))) AND wire_w_lg_n01lll3382w(0)) AND (n01liO10 XOR n01liO9));
	n01lll <= ((((wire_w_lg_w_lg_w_tx_st_data0_range2080w3366w3368w(0) AND tx_st_data0(26)) AND (NOT tx_st_data0(27))) AND (NOT tx_st_data0(28))) AND wire_w_lg_w_tx_st_data0_range2095w3361w(0));
	n01Oii <= ((NOT tx_st_data0(27)) AND (NOT tx_st_data0(28)));
	npd_alloc_1cred_vc0 <= n00l1i;
	npd_cred_vio_vc0 <= n00iOi;
	nph_alloc_1cred_vc0 <= n00l1l;
	nph_cred_vio_vc0 <= n00iOO;
	pme_to_sr <= wire_n0l1il_tlpmetosr;
	powerdown0_ext <= ( wire_n0l1il_powerdown(1 DOWNTO 0));
	r2c_err0 <= wire_n0l1il_extraout(1);
	rate_ext <= wire_n0l1il_gen2rate;
	rc_gxb_powerdown <= '0';
	rc_rx_analogreset <= '0';
	rc_rx_digitalreset <= '0';
	rc_tx_digitalreset <= '0';
	reset_status <= wire_n0l1il_resetstatus;
	rx_fifo_empty0 <= wire_n0l1il_rxfifoemptyvc0;
	rx_fifo_full0 <= wire_n0l1il_rxfifofullvc0;
	rx_st_bardec0 <= ( wire_n0l1il_rxbardecvc0(7 DOWNTO 0));
	rx_st_be0 <= ( wire_n0l1il_rxbevc00(7 DOWNTO 0));
	rx_st_be0_p1 <= ( wire_n0l1il_rxbevc01(7 DOWNTO 0));
	rx_st_data0 <= ( wire_n0l1il_rxdatavc00(63 DOWNTO 0));
	rx_st_data0_p1 <= ( wire_n0l1il_rxdatavc01(63 DOWNTO 0));
	rx_st_eop0 <= wire_n0l1il_rxeopvc00;
	rx_st_eop0_p1 <= wire_n0l1il_rxeopvc01;
	rx_st_err0 <= wire_n0l1il_rxerrvc0;
	rx_st_sop0 <= wire_n0l1il_rxsopvc00;
	rx_st_sop0_p1 <= wire_n0l1il_rxsopvc01;
	rx_st_valid0 <= wire_n0l1il_rxvalidvc0;
	RxmAddress_o <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	RxmBurstCount_o <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	RxmByteEnable_o <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	RxmRead_o <= '0';
	RxmWrite_o <= '0';
	RxmWriteData_o <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	rxpolarity0_ext <= wire_n0l1il_rxpolarity(0);
	serr_out <= wire_n0l1il_serrout;
	suc_spd_neg <= wire_n0l1il_extraout(0);
	swdn_wake <= wire_n0l1il_swdnwake;
	swup_hotrst <= wire_n0l1il_swuphotrst;
	test_out <= ( wire_n0l1il_testout(63 DOWNTO 0));
	tl_cfg_add <= ( wire_n0l1il_tlcfgadd(3 DOWNTO 0));
	tl_cfg_ctl <= ( wire_n0l1il_tlcfgctl(31 DOWNTO 0));
	tl_cfg_ctl_wr <= wire_n0l1il_tlcfgctlwr;
	tl_cfg_sts <= ( wire_n0l1il_tlcfgsts(52 DOWNTO 0));
	tl_cfg_sts_wr <= wire_n0l1il_tlcfgstswr;
	tx_cred0 <= ( wire_n0l1il_txcredvc0(35 DOWNTO 0));
	tx_deemph <= ( wire_n0l1il_txdeemph(7 DOWNTO 0));
	tx_fifo_empty0 <= wire_n0l1il_txfifoemptyvc0;
	tx_fifo_full0 <= wire_n0l1il_txfifofullvc0;
	tx_fifo_rdptr0 <= ( wire_n0l1il_txfifordpvc0(3 DOWNTO 0));
	tx_fifo_wrptr0 <= ( wire_n0l1il_txfifowrpvc0(3 DOWNTO 0));
	tx_margin <= ( wire_n0l1il_txmargin(23 DOWNTO 0));
	tx_st_ready0 <= wire_n0l1il_txreadyvc0;
	txcompl0_ext <= wire_n0l1il_txcompl(0);
	txdata0_ext <= ( wire_n0l1il_txdata(7 DOWNTO 0));
	txdatak0_ext <= wire_n0l1il_txdatak(0);
	txdetectrx0_ext <= wire_n0l1il_txdetectrx(0);
	txelecidle0_ext <= wire_n0l1il_txelecidle(0);
	TxsReadData_o <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	TxsReadDataValid_o <= '0';
	TxsWaitRequest_o <= '0';
	use_pcie_reconfig <= '0';
	wake_oen <= wire_n0l1il_wakeoen;
	wire_w_tx_st_data0_range2080w(0) <= tx_st_data0(24);
	wire_w_tx_st_data0_range2083w(0) <= tx_st_data0(25);
	wire_w_tx_st_data0_range2086w(0) <= tx_st_data0(26);
	wire_w_tx_st_data0_range2095w(0) <= tx_st_data0(29);
	wire_w_tx_st_data0_range2098w(0) <= tx_st_data0(30);
	wire_n01Oil_address_a <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n01Oil_address_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n01Oil_byteena_a <= ( "1");
	wire_n01Oil_byteena_b <= ( "1");
	wire_n01Oil_data_a <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n01Oil_data_b <= ( "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1");
	n01Oil :  altsyncram
	  GENERIC MAP (
		ADDRESS_ACLR_A => "NONE",
		ADDRESS_ACLR_B => "NONE",
		ADDRESS_REG_B => "CLOCK1",
		BYTE_SIZE => 8,
		BYTEENA_ACLR_A => "NONE",
		BYTEENA_ACLR_B => "NONE",
		BYTEENA_REG_B => "CLOCK1",
		CLOCK_ENABLE_CORE_A => "USE_INPUT_CLKEN",
		CLOCK_ENABLE_CORE_B => "USE_INPUT_CLKEN",
		CLOCK_ENABLE_INPUT_A => "NORMAL",
		CLOCK_ENABLE_INPUT_B => "NORMAL",
		CLOCK_ENABLE_OUTPUT_A => "NORMAL",
		CLOCK_ENABLE_OUTPUT_B => "NORMAL",
		ENABLE_ECC => "FALSE",
		INDATA_ACLR_A => "NONE",
		INDATA_ACLR_B => "NONE",
		INDATA_REG_B => "CLOCK1",
		INIT_FILE_LAYOUT => "PORT_A",
		INTENDED_DEVICE_FAMILY => "Cyclone IV GX",
		NUMWORDS_A => 32768,
		NUMWORDS_B => 32768,
		OPERATION_MODE => "DUAL_PORT",
		OUTDATA_ACLR_A => "NONE",
		OUTDATA_ACLR_B => "NONE",
		OUTDATA_REG_A => "UNREGISTERED",
		OUTDATA_REG_B => "UNREGISTERED",
		RAM_BLOCK_TYPE => "AUTO",
		RDCONTROL_ACLR_B => "NONE",
		RDCONTROL_REG_B => "CLOCK1",
		READ_DURING_WRITE_MODE_MIXED_PORTS => "DONT_CARE",
		READ_DURING_WRITE_MODE_PORT_A => "NEW_DATA_NO_NBE_READ",
		READ_DURING_WRITE_MODE_PORT_B => "NEW_DATA_NO_NBE_READ",
		WIDTH_A => 255,
		WIDTH_B => 255,
		WIDTH_BYTEENA_A => 1,
		WIDTH_BYTEENA_B => 1,
		WIDTH_ECCSTATUS => 3,
		WIDTHAD_A => 15,
		WIDTHAD_B => 15,
		WRCONTROL_ACLR_A => "NONE",
		WRCONTROL_ACLR_B => "NONE",
		WRCONTROL_WRADDRESS_REG_B => "CLOCK1",
		lpm_hint => "WIDTH_BYTEENA=1"
	  )
	  PORT MAP ( 
		aclr0 => wire_gnd,
		aclr1 => wire_gnd,
		address_a => wire_n01Oil_address_a,
		address_b => wire_n01Oil_address_b,
		addressstall_a => wire_gnd,
		addressstall_b => wire_gnd,
		byteena_a => wire_n01Oil_byteena_a,
		byteena_b => wire_n01Oil_byteena_b,
		clock0 => wire_gnd,
		clock1 => wire_gnd,
		clocken0 => wire_vcc,
		clocken1 => wire_vcc,
		data_a => wire_n01Oil_data_a,
		data_b => wire_n01Oil_data_b,
		rden_b => wire_vcc,
		wren_a => wire_gnd,
		wren_b => wire_gnd
	  );
	wire_n0l1il_w_lg_w_txcredvc0_range1635w3427w(0) <= wire_n0l1il_w_txcredvc0_range1635w(0) AND wire_n0l1il_w_lg_w_txcredvc0_range1638w3426w(0);
	wire_n0l1il_w_lg_w_txcredvc0_range1644w3447w(0) <= wire_n0l1il_w_txcredvc0_range1644w(0) AND wire_n0l1il_w_lg_w_txcredvc0_range1647w3446w(0);
	wire_n0l1il_w_lg_w_txcredvc0_range1638w3426w(0) <= NOT wire_n0l1il_w_txcredvc0_range1638w(0);
	wire_n0l1il_w_lg_w_txcredvc0_range1647w3446w(0) <= NOT wire_n0l1il_w_txcredvc0_range1647w(0);
	wire_n0l1il_corepor <= wire_w_lg_npor1853w(0);
	wire_n0l1il_corerst <= wire_w_lg_npor1853w(0);
	wire_n0l1il_cplerr <= ( cpl_err(6 DOWNTO 0));
	wire_n0l1il_dbgpipex1rx <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n0l1il_dlctrllink2 <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n0l1il_dldataupfc <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n0l1il_dlhdrupfc <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n0l1il_dlmaxploaddcr <= ( "0" & "0" & "0");
	wire_n0l1il_dlreqphycfg <= ( "0" & "0" & "0" & "0");
	wire_n0l1il_dlreqphypm <= ( "0" & "0" & "0" & "0");
	wire_n0l1il_dltxtyppm <= ( "0" & "0" & "0");
	wire_n0l1il_dltypupfc <= ( "0" & "0");
	wire_n0l1il_dlvcctrl <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n0l1il_dlvcidmap <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n0l1il_dlvcidupfc <= ( "0" & "0" & "0");
	wire_n0l1il_lmiaddr <= ( lmi_addr(11 DOWNTO 0));
	wire_n0l1il_lmidin <= ( lmi_din(31 DOWNTO 0));
	wire_n0l1il_mode <= ( "0" & "1");
	wire_n0l1il_phyrst <= wire_w_lg_npor1853w(0);
	wire_n0l1il_phystatus <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & phystatus0_ext);
	wire_n0l1il_pldrst <= wire_w_lg_npor1853w(0);
	wire_n0l1il_rxdata <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & rxdata0_ext(7 DOWNTO 0));
	wire_n0l1il_rxdatak <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & rxdatak0_ext);
	wire_n0l1il_rxelecidle <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & rxelecidle0_ext);
	wire_n0l1il_rxstatus <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & rxstatus0_ext(2 DOWNTO 0));
	wire_n0l1il_rxvalid <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & rxvalid0_ext);
	wire_n0l1il_swdnin <= ( "0" & "0" & "0");
	wire_n0l1il_swupin <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n0l1il_testin <= ( test_in(39 DOWNTO 0));
	wire_n0l1il_tlaermsinum <= ( aer_msi_num(4 DOWNTO 0));
	wire_n0l1il_tlappmsinum <= ( app_msi_num(4 DOWNTO 0));
	wire_n0l1il_tlappmsitc <= ( app_msi_tc(2 DOWNTO 0));
	wire_n0l1il_tlhpgctrler <= ( hpg_ctrler(4 DOWNTO 0));
	wire_n0l1il_tlpexmsinum <= ( pex_msi_num(4 DOWNTO 0));
	wire_n0l1il_tlpmdata <= ( pm_data(9 DOWNTO 0));
	wire_n0l1il_txdatavc00 <= ( tx_st_data0(63 DOWNTO 0));
	wire_n0l1il_txdatavc01 <= ( tx_st_data0_p1(63 DOWNTO 0));
	wire_n0l1il_txdatavc10 <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n0l1il_txdatavc11 <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n0l1il_w_txcredvc0_range1635w(0) <= wire_n0l1il_txcredvc0(15);
	wire_n0l1il_w_txcredvc0_range1638w(0) <= wire_n0l1il_txcredvc0(16);
	wire_n0l1il_w_txcredvc0_range1644w(0) <= wire_n0l1il_txcredvc0(18);
	wire_n0l1il_w_txcredvc0_range1647w(0) <= wire_n0l1il_txcredvc0(19);
	n0l1il :  cycloneiv_hssi_pcie_hip
	  GENERIC MAP (
		advanced_errors => "true",
		
		bar0_64bit_mem_space    => "false",
		bar0_io_space           => MEN_IO_SPACE_BAR_0,  --"false",
		bar0_prefetchable       => MEN_PREFETCH_BAR_0,  --"true",
		bar0_size_mask          => MEN_SIZE_MASK_BAR_0, --28,
		bar1_64bit_mem_space    => "false",
		bar1_io_space           => MEN_IO_SPACE_BAR_1,  --"false",
		bar1_prefetchable       => MEN_PREFETCH_BAR_1,  --"true",
		bar1_size_mask          => MEN_SIZE_MASK_BAR_1, --18,
		bar2_64bit_mem_space    => "false",
		bar2_io_space           => MEN_IO_SPACE_BAR_2,  --"false",
		bar2_prefetchable       => MEN_PREFETCH_BAR_2,  --"false",
		bar2_size_mask          => MEN_SIZE_MASK_BAR_2, --8,
		bar3_64bit_mem_space    => "false",
		bar3_io_space           => MEN_IO_SPACE_BAR_3,  --"false",
		bar3_prefetchable       => MEN_PREFETCH_BAR_3,  --"false",
		bar3_size_mask          => MEN_SIZE_MASK_BAR_3, --18,
		bar4_64bit_mem_space    => "false",
		bar4_io_space           => MEN_IO_SPACE_BAR_4,  --"true",
		bar4_prefetchable       => MEN_PREFETCH_BAR_4,  --"false",
		bar4_size_mask          => MEN_SIZE_MASK_BAR_4, --8,
		bar5_64bit_mem_space    => "false",
		bar5_io_space           => MEN_IO_SPACE_BAR_5,  --"true",
		bar5_prefetchable       => MEN_PREFETCH_BAR_5,  --"false",
		bar5_size_mask          => MEN_SIZE_MASK_BAR_5, --8,
		
		bar_io_window_size => "32BIT",
		bar_prefetchable => 32,
		bridge_port_ssid_support => "false",
		bridge_port_vga_enable => "false",
		bypass_cdc => "false",
		bypass_tl => "false",
		
		class_code => MEN_CLASS_CODE,                   --16711680,
		
		completion_timeout => "NONE",
		core_clk_divider => 2,
		core_clk_source => "pclk",
		credit_buffer_allocation_aux => "BALANCED",
		deemphasis_enable => "false",
		
		device_id => MEN_DEVICE_ID,                     --4,
		
		device_number => 0,
		diffclock_nfts_count => 255,
		disable_cdc_clk_ppm => "false",
		disable_link_x2_support => "false",
		disable_snoop_packet => "00000000",
		dll_active_report_support => "false",
		ei_delay_powerdown_count => 10,
		eie_before_nfts_count => 4,
		enable_adapter_half_rate_mode => "false",
		enable_ch0_pclk_out => "true",
		enable_completion_timeout_disable => "true",
		enable_coreclk_out_half_rate => "false",
		enable_ecrc_check => "true",
		enable_ecrc_gen => "true",
		enable_function_msi_support => "true",
		enable_function_msix_support => "false",
		enable_gen2_core => "true",
		enable_hip_x1_loopback => "false",
		enable_l1_aspm => "false",
		
		enable_msi_64bit_addressing => "false",         --"true",
		
		enable_msi_masking => "false",
		enable_retrybuf_ecc => "true",
		enable_retrybuf_x8_clk_stealing => 0,
		enable_rx0buf_ecc => "true",
		enable_rx0buf_x8_clk_stealing => 0,
		enable_rx1buf_ecc => "true",
		enable_rx1buf_x8_clk_stealing => 0,
		enable_rx_buffer_checking => "true",
		enable_rx_reordering => "true",
		enable_slot_register => "false",
		endpoint_l0_latency => 0,
		endpoint_l1_latency => 0,
		expansion_base_address_register => 0,
		extend_tag_field => "false",
		fc_init_timer => 1024,
		flow_control_timeout_count => 200,
		flow_control_update_count => 30,
		gen2_diffclock_nfts_count => 255,
		gen2_lane_rate_mode => "false",
		gen2_sameclock_nfts_count => 255,
		hot_plug_support => "0000000",
		indicator => 0,
		l01_entry_latency => 31,
		l0_exit_latency_diffclock => 7,
		l0_exit_latency_sameclock => 7,
		l1_exit_latency_diffclock => 7,
		l1_exit_latency_sameclock => 7,
		lane_mask => "11111110",
		low_priority_vc => 0,
		lpm_type => "stratixiv_hssi_pcie_hip",
		max_link_width => 1,
		max_payload_size => 1,
		maximum_current => 0,
		millisecond_cycle_count => 125000,
		msi_function_count => 2,
		msix_pba_bir => 0,
		msix_pba_offset => 0,
		msix_table_bir => 0,
		msix_table_offset => 0,
		msix_table_size => 0,
		no_command_completed => "true",
		no_soft_reset => "true",
		pcie_mode => "SHARED_MODE",
		pme_state_enable => "00000",
		port_link_number => 1,
		register_pipe_signals => "false",
		retry_buffer_last_active_address => 255,
		retry_buffer_memory_settings => 0,
		
		revision_id => MEN_REVISION_ID,                 --1,
		
		rx_ptr0_nonposted_dpram_max => 0,
		rx_ptr0_nonposted_dpram_min => 0,
		rx_ptr0_posted_dpram_max => 0,
		rx_ptr0_posted_dpram_min => 0,
		rx_ptr1_nonposted_dpram_max => 0,
		rx_ptr1_nonposted_dpram_min => 0,
		rx_ptr1_posted_dpram_max => 0,
		rx_ptr1_posted_dpram_min => 0,
		sameclock_nfts_count => 255,
		single_rx_detect => 1,
		skp_os_schedule_count => 0,
		slot_number => 0,
		slot_power_limit => 0,
		slot_power_scale => 0,
		ssid => 0,
		ssvid => 0,
		
		subsystem_device_id => MEN_SUBSYSTEM_DEVICE_ID, --4,
		subsystem_vendor_id => MEN_SUBSYSTEM_VENDOR_ID, --4466,
		
		surprise_down_error_support => "false",
		use_crc_forwarding => "false",
		vc0_clk_enable => "true",
		vc0_rx_buffer_memory_settings => 0,
		vc0_rx_flow_ctrl_compl_data => 448,
		vc0_rx_flow_ctrl_compl_header => 112,
		vc0_rx_flow_ctrl_nonposted_data => 0,
		vc0_rx_flow_ctrl_nonposted_header => 54,
		vc0_rx_flow_ctrl_posted_data => 360,
		vc0_rx_flow_ctrl_posted_header => 50,
		vc1_clk_enable => "false",
		vc1_rx_buffer_memory_settings => 0,
		vc1_rx_flow_ctrl_compl_data => 448,
		vc1_rx_flow_ctrl_compl_header => 112,
		vc1_rx_flow_ctrl_nonposted_data => 0,
		vc1_rx_flow_ctrl_nonposted_header => 54,
		vc1_rx_flow_ctrl_posted_data => 360,
		vc1_rx_flow_ctrl_posted_header => 50,
		vc_arbitration => 0,
		vc_enable => "0000000",
		
		vendor_id => MEN_VENDOR_ID                      --4466
	  )
	  PORT MAP ( 
		bistenrcv0 => wire_gnd,
		bistenrcv1 => wire_gnd,
		bistenrpl => wire_gnd,
		bistscanen => wire_gnd,
		bistscanin => wire_gnd,
		bisttesten => wire_gnd,
		coreclkin => core_clk_in,
		coreclkout => wire_n0l1il_coreclkout,
		corecrst => crst,
		corepor => wire_n0l1il_corepor,
		corerst => wire_n0l1il_corerst,
		coresrst => srst,
		cplerr => wire_n0l1il_cplerr,
		cplpending => cpl_pending,
		dbgpipex1rx => wire_n0l1il_dbgpipex1rx,
		derrcorextrcv0 => wire_n0l1il_derrcorextrcv0,
		derrcorextrpl => wire_n0l1il_derrcorextrpl,
		derrrpl => wire_n0l1il_derrrpl,
		dlaspmcr0 => wire_gnd,
		dlcomclkreg => wire_gnd,
		dlctrllink2 => wire_n0l1il_dlctrllink2,
		dldataupfc => wire_n0l1il_dldataupfc,
		dlhdrupfc => wire_n0l1il_dlhdrupfc,
		dlinhdllp => wire_gnd,
		dlltssm => wire_n0l1il_dlltssm,
		dlmaxploaddcr => wire_n0l1il_dlmaxploaddcr,
		dlreqphycfg => wire_n0l1il_dlreqphycfg,
		dlreqphypm => wire_n0l1il_dlreqphypm,
		dlrequpfc => wire_gnd,
		dlreqwake => wire_gnd,
		dlrxecrcchk => wire_gnd,
		dlsndupfc => wire_gnd,
		dltxcfgextsy => wire_gnd,
		dltxreqpm => wire_gnd,
		dltxtyppm => wire_n0l1il_dltxtyppm,
		dltypupfc => wire_n0l1il_dltypupfc,
		dlupexit => wire_n0l1il_dlupexit,
		dlvcctrl => wire_n0l1il_dlvcctrl,
		dlvcidmap => wire_n0l1il_dlvcidmap,
		dlvcidupfc => wire_n0l1il_dlvcidupfc,
		dpclk => wire_gnd,
		dpriodisable => wire_vcc,
		dprioin => wire_gnd,
		dprioload => wire_gnd,
		eidleinfersel => wire_n0l1il_eidleinfersel,
		ev128ns => wire_n0l1il_ev128ns,
		ev1us => wire_n0l1il_ev1us,
		extraclkout => wire_n0l1il_extraclkout,
		extraout => wire_n0l1il_extraout,
		gen2rate => wire_n0l1il_gen2rate,
		hotrstexit => wire_n0l1il_hotrstexit,
		intstatus => wire_n0l1il_intstatus,
		l2exit => wire_n0l1il_l2exit,
		laneact => wire_n0l1il_laneact,
		lmiack => wire_n0l1il_lmiack,
		lmiaddr => wire_n0l1il_lmiaddr,
		lmidin => wire_n0l1il_lmidin,
		lmidout => wire_n0l1il_lmidout,
		lmirden => lmi_rden,
		lmiwren => lmi_wren,
		mode => wire_n0l1il_mode,
		mramhiptestenable => wire_gnd,
		mramregscanen => wire_gnd,
		mramregscanin => wire_gnd,
		pclkcentral => pclk_central,
		pclkch0 => pclk_ch0,
		phyrst => wire_n0l1il_phyrst,
		physrst => srst,
		phystatus => wire_n0l1il_phystatus,
		pldclk => pld_clk,
		pldrst => wire_n0l1il_pldrst,
		pldsrst => srst,
		pllfixedclk => pll_fixed_clk,
		powerdown => wire_n0l1il_powerdown,
		resetstatus => wire_n0l1il_resetstatus,
		rxbardecvc0 => wire_n0l1il_rxbardecvc0,
		rxbevc00 => wire_n0l1il_rxbevc00,
		rxbevc01 => wire_n0l1il_rxbevc01,
		rxdata => wire_n0l1il_rxdata,
		rxdatak => wire_n0l1il_rxdatak,
		rxdatavc00 => wire_n0l1il_rxdatavc00,
		rxdatavc01 => wire_n0l1il_rxdatavc01,
		rxelecidle => wire_n0l1il_rxelecidle,
		rxeopvc00 => wire_n0l1il_rxeopvc00,
		rxeopvc01 => wire_n0l1il_rxeopvc01,
		rxerrvc0 => wire_n0l1il_rxerrvc0,
		rxfifoemptyvc0 => wire_n0l1il_rxfifoemptyvc0,
		rxfifofullvc0 => wire_n0l1il_rxfifofullvc0,
		rxmaskvc0 => rx_st_mask0,
		rxmaskvc1 => wire_gnd,
		rxpolarity => wire_n0l1il_rxpolarity,
		rxreadyvc0 => rx_st_ready0,
		rxreadyvc1 => wire_gnd,
		rxsopvc00 => wire_n0l1il_rxsopvc00,
		rxsopvc01 => wire_n0l1il_rxsopvc01,
		rxstatus => wire_n0l1il_rxstatus,
		rxvalid => wire_n0l1il_rxvalid,
		rxvalidvc0 => wire_n0l1il_rxvalidvc0,
		scanen => wire_gnd,
		scanmoden => wire_vcc,
		serrout => wire_n0l1il_serrout,
		swdnin => wire_n0l1il_swdnin,
		swdnwake => wire_n0l1il_swdnwake,
		swuphotrst => wire_n0l1il_swuphotrst,
		swupin => wire_n0l1il_swupin,
		testin => wire_n0l1il_testin,
		testout => wire_n0l1il_testout,
		tlaermsinum => wire_n0l1il_tlaermsinum,
		tlappintaack => wire_n0l1il_tlappintaack,
		tlappintasts => app_int_sts,
		tlappmsiack => wire_n0l1il_tlappmsiack,
		tlappmsinum => wire_n0l1il_tlappmsinum,
		tlappmsireq => app_msi_req,
		tlappmsitc => wire_n0l1il_tlappmsitc,
		tlcfgadd => wire_n0l1il_tlcfgadd,
		tlcfgctl => wire_n0l1il_tlcfgctl,
		tlcfgctlwr => wire_n0l1il_tlcfgctlwr,
		tlcfgsts => wire_n0l1il_tlcfgsts,
		tlcfgstswr => wire_n0l1il_tlcfgstswr,
		tlhpgctrler => wire_n0l1il_tlhpgctrler,
		tlpexmsinum => wire_n0l1il_tlpexmsinum,
		tlpmauxpwr => pm_auxpwr,
		tlpmdata => wire_n0l1il_tlpmdata,
		tlpmetocr => pme_to_cr,
		tlpmetosr => wire_n0l1il_tlpmetosr,
		tlpmevent => pm_event,
		tlslotclkcfg => wire_vcc,
		txcompl => wire_n0l1il_txcompl,
		txcredvc0 => wire_n0l1il_txcredvc0,
		txdata => wire_n0l1il_txdata,
		txdatak => wire_n0l1il_txdatak,
		txdatavc00 => wire_n0l1il_txdatavc00,
		txdatavc01 => wire_n0l1il_txdatavc01,
		txdatavc10 => wire_n0l1il_txdatavc10,
		txdatavc11 => wire_n0l1il_txdatavc11,
		txdeemph => wire_n0l1il_txdeemph,
		txdetectrx => wire_n0l1il_txdetectrx,
		txelecidle => wire_n0l1il_txelecidle,
		txeopvc00 => tx_st_eop0,
		txeopvc01 => tx_st_eop0_p1,
		txeopvc10 => wire_gnd,
		txeopvc11 => wire_gnd,
		txerrvc0 => tx_st_err0,
		txerrvc1 => wire_gnd,
		txfifoemptyvc0 => wire_n0l1il_txfifoemptyvc0,
		txfifofullvc0 => wire_n0l1il_txfifofullvc0,
		txfifordpvc0 => wire_n0l1il_txfifordpvc0,
		txfifowrpvc0 => wire_n0l1il_txfifowrpvc0,
		txmargin => wire_n0l1il_txmargin,
		txreadyvc0 => wire_n0l1il_txreadyvc0,
		txsopvc00 => tx_st_sop0,
		txsopvc01 => tx_st_sop0_p1,
		txsopvc10 => wire_gnd,
		txsopvc11 => wire_gnd,
		txvalidvc0 => tx_st_valid0,
		txvalidvc1 => wire_gnd,
		wakeoen => wire_n0l1il_wakeoen
	  );
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n010ii45 <= n010ii46;
		END IF;
		if (now = 0 ns) then
			n010ii45 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n010ii46 <= n010ii45;
		END IF;
	END PROCESS;
	wire_n010ii46_w_lg_w_lg_q3582w3583w(0) <= wire_n010ii46_w_lg_q3582w(0) AND n00OiO;
	wire_n010ii46_w_lg_q3582w(0) <= n010ii46 XOR n010ii45;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n010il43 <= n010il44;
		END IF;
		if (now = 0 ns) then
			n010il43 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n010il44 <= n010il43;
		END IF;
	END PROCESS;
	wire_n010il44_w_lg_w_lg_q3577w3578w(0) <= wire_n010il44_w_lg_q3577w(0) AND n00O0O;
	wire_n010il44_w_lg_q3577w(0) <= n010il44 XOR n010il43;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n010iO41 <= n010iO42;
		END IF;
		if (now = 0 ns) then
			n010iO41 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n010iO42 <= n010iO41;
		END IF;
	END PROCESS;
	wire_n010iO42_w_lg_w_lg_q3574w3575w(0) <= wire_n010iO42_w_lg_q3574w(0) AND n00O0l;
	wire_n010iO42_w_lg_q3574w(0) <= n010iO42 XOR n010iO41;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n010li39 <= n010li40;
		END IF;
		if (now = 0 ns) then
			n010li39 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n010li40 <= n010li39;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n010ll37 <= n010ll38;
		END IF;
		if (now = 0 ns) then
			n010ll37 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n010ll38 <= n010ll37;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n010lO35 <= n010lO36;
		END IF;
		if (now = 0 ns) then
			n010lO35 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n010lO36 <= n010lO35;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n010OO33 <= n010OO34;
		END IF;
		if (now = 0 ns) then
			n010OO33 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n010OO34 <= n010OO33;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01i0l29 <= n01i0l30;
		END IF;
		if (now = 0 ns) then
			n01i0l29 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01i0l30 <= n01i0l29;
		END IF;
	END PROCESS;
	wire_n01i0l30_w_lg_w_lg_q3491w3492w(0) <= wire_n01i0l30_w_lg_q3491w(0) AND n00lli;
	wire_n01i0l30_w_lg_q3491w(0) <= n01i0l30 XOR n01i0l29;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01i0O27 <= n01i0O28;
		END IF;
		if (now = 0 ns) then
			n01i0O27 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01i0O28 <= n01i0O27;
		END IF;
	END PROCESS;
	wire_n01i0O28_w_lg_w_lg_q3456w3457w(0) <= wire_n01i0O28_w_lg_q3456w(0) AND n00OiO;
	wire_n01i0O28_w_lg_q3456w(0) <= n01i0O28 XOR n01i0O27;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01i1l31 <= n01i1l32;
		END IF;
		if (now = 0 ns) then
			n01i1l31 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01i1l32 <= n01i1l31;
		END IF;
	END PROCESS;
	wire_n01i1l32_w_lg_q3540w(0) <= n01i1l32 XOR n01i1l31;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01iii25 <= n01iii26;
		END IF;
		if (now = 0 ns) then
			n01iii25 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01iii26 <= n01iii25;
		END IF;
	END PROCESS;
	wire_n01iii26_w_lg_w_lg_q3441w3442w(0) <= wire_n01iii26_w_lg_q3441w(0) AND wire_n0l1il_w_txcredvc0_range1647w(0);
	wire_n01iii26_w_lg_q3441w(0) <= n01iii26 XOR n01iii25;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01iil23 <= n01iil24;
		END IF;
		if (now = 0 ns) then
			n01iil23 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01iil24 <= n01iil23;
		END IF;
	END PROCESS;
	wire_n01iil24_w_lg_w_lg_q3437w3438w(0) <= wire_n01iil24_w_lg_q3437w(0) AND wire_n0l1il_w_txcredvc0_range1644w(0);
	wire_n01iil24_w_lg_q3437w(0) <= n01iil24 XOR n01iil23;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01iiO21 <= n01iiO22;
		END IF;
		if (now = 0 ns) then
			n01iiO21 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01iiO22 <= n01iiO21;
		END IF;
	END PROCESS;
	wire_n01iiO22_w_lg_w_lg_q3421w3422w(0) <= wire_n01iiO22_w_lg_q3421w(0) AND wire_n0l1il_w_txcredvc0_range1638w(0);
	wire_n01iiO22_w_lg_q3421w(0) <= n01iiO22 XOR n01iiO21;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01ill19 <= n01ill20;
		END IF;
		if (now = 0 ns) then
			n01ill19 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01ill20 <= n01ill19;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01iOl17 <= n01iOl18;
		END IF;
		if (now = 0 ns) then
			n01iOl17 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01iOl18 <= n01iOl17;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01l0O11 <= n01l0O12;
		END IF;
		if (now = 0 ns) then
			n01l0O11 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01l0O12 <= n01l0O11;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01l1i15 <= n01l1i16;
		END IF;
		if (now = 0 ns) then
			n01l1i15 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01l1i16 <= n01l1i15;
		END IF;
	END PROCESS;
	wire_n01l1i16_w_lg_w_lg_q3399w3400w(0) <= NOT wire_n01l1i16_w_lg_q3399w(0);
	wire_n01l1i16_w_lg_q3399w(0) <= n01l1i16 XOR n01l1i15;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01l1O13 <= n01l1O14;
		END IF;
		if (now = 0 ns) then
			n01l1O13 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01l1O14 <= n01l1O13;
		END IF;
	END PROCESS;
	wire_n01l1O14_w_lg_w_lg_q3394w3395w(0) <= NOT wire_n01l1O14_w_lg_q3394w(0);
	wire_n01l1O14_w_lg_q3394w(0) <= n01l1O14 XOR n01l1O13;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01liO10 <= n01liO9;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01liO9 <= n01liO10;
		END IF;
		if (now = 0 ns) then
			n01liO9 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01llO7 <= n01llO8;
		END IF;
		if (now = 0 ns) then
			n01llO7 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01llO8 <= n01llO7;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01lOl5 <= n01lOl6;
		END IF;
		if (now = 0 ns) then
			n01lOl5 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01lOl6 <= n01lOl5;
		END IF;
	END PROCESS;
	wire_n01lOl6_w_lg_q3374w(0) <= n01lOl6 XOR n01lOl5;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01O1i3 <= n01O1i4;
		END IF;
		if (now = 0 ns) then
			n01O1i3 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01O1i4 <= n01O1i3;
		END IF;
	END PROCESS;
	wire_n01O1i4_w_lg_q3364w(0) <= n01O1i4 XOR n01O1i3;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01O1O1 <= n01O1O2;
		END IF;
		if (now = 0 ns) then
			n01O1O1 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n01O1O2 <= n01O1O1;
		END IF;
	END PROCESS;
	PROCESS (pld_clk, n00OOl, wire_n00l0i_CLRN)
	BEGIN
		IF (n00OOl = '0') THEN
				n00l0l <= '1';
				n00l1O <= '1';
		ELSIF (wire_n00l0i_CLRN = '0') THEN
				n00l0l <= '0';
				n00l1O <= '0';
		ELSIF (pld_clk = '1' AND pld_clk'event) THEN
				n00l0l <= wire_n0i1ii_dataout;
				n00l1O <= wire_n0i10O_dataout;
		END IF;
		if (now = 0 ns) then
			n00l0l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00l1O <= '1' after 1 ps;
		end if;
	END PROCESS;
	wire_n00l0i_CLRN <= (n010li40 XOR n010li39);
	PROCESS (pld_clk, wire_n00OlO_CLRN)
	BEGIN
		IF (wire_n00OlO_CLRN = '0') THEN
				n00ilO <= '0';
				n00iOi <= '0';
				n00iOl <= '0';
				n00iOO <= '0';
				n00l0O <= '0';
				n00l1i <= '0';
				n00l1l <= '0';
				n00lii <= '0';
				n00lil <= '0';
				n00liO <= '0';
				n00lli <= '0';
				n00lll <= '0';
				n00llO <= '0';
				n00lOi <= '0';
				n00lOl <= '0';
				n00lOO <= '0';
				n00O0i <= '0';
				n00O0l <= '0';
				n00O0O <= '0';
				n00O1i <= '0';
				n00O1l <= '0';
				n00O1O <= '0';
				n00Oii <= '0';
				n00Oil <= '0';
				n00OiO <= '0';
				n00Oli <= '0';
				n00Oll <= '0';
				n00OOi <= '0';
		ELSIF (pld_clk = '1' AND pld_clk'event) THEN
				n00ilO <= wire_n0i11i_dataout;
				n00iOi <= wire_n0i11l_dataout;
				n00iOl <= wire_n00OOO_dataout;
				n00iOO <= wire_n0i11O_dataout;
				n00l0O <= wire_n0i1il_dataout;
				n00l1i <= wire_n0i10i_dataout;
				n00l1l <= wire_n0i10l_dataout;
				n00lii <= wire_n0i1iO_dataout;
				n00lil <= wire_n0i1li_dataout;
				n00liO <= wire_n0i1ll_dataout;
				n00lli <= wire_n0i1lO_dataout;
				n00lll <= wire_n0i1Oi_dataout;
				n00llO <= wire_n0i1Ol_dataout;
				n00lOi <= wire_n0i1OO_dataout;
				n00lOl <= wire_n0i01i_dataout;
				n00lOO <= wire_n0i01l_dataout;
				n00O0i <= wire_n0i00O_dataout;
				n00O0l <= wire_n0i0ii_dataout;
				n00O0O <= wire_n0i0il_dataout;
				n00O1i <= wire_n0i01O_dataout;
				n00O1l <= wire_n0i00i_dataout;
				n00O1O <= wire_n0i00l_dataout;
				n00Oii <= wire_n0i0iO_dataout;
				n00Oil <= wire_n0i0li_dataout;
				n00OiO <= wire_n0i0ll_dataout;
				n00Oli <= wire_n0i0lO_dataout;
				n00Oll <= wire_n0i0Oi_dataout;
				n00OOi <= wire_n0i0Ol_dataout;
		END IF;
		if (now = 0 ns) then
			n00ilO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00iOi <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00iOl <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00iOO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00l0O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00l1i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00l1l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00lii <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00lil <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00liO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00lli <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00lll <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00llO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00lOi <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00lOl <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00lOO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00O0i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00O0l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00O0O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00O1i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00O1l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00O1O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00Oii <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00Oil <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00OiO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00Oli <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00Oll <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n00OOi <= '1' after 1 ps;
		end if;
	END PROCESS;
	wire_n00OlO_CLRN <= ((n010ll38 XOR n010ll37) AND n00OOl);
	wire_n00OlO_w_lg_n00l0O3714w(0) <= NOT n00l0O;
	wire_n00OlO_w_lg_n00lii3717w(0) <= NOT n00lii;
	wire_n00OlO_w_lg_n00lil3719w(0) <= NOT n00lil;
	wire_n00OlO_w_lg_n00liO3721w(0) <= NOT n00liO;
	wire_n00OlO_w_lg_n00lli3723w(0) <= NOT n00lli;
	wire_n00OlO_w_lg_n00lll3725w(0) <= NOT n00lll;
	wire_n00OlO_w_lg_n00llO3727w(0) <= NOT n00llO;
	wire_n00OlO_w_lg_n00lOi3729w(0) <= NOT n00lOi;
	wire_n00OlO_w_lg_n00lOl3731w(0) <= NOT n00lOl;
	wire_n00OlO_w_lg_n00lOO3733w(0) <= NOT n00lOO;
	wire_n00OlO_w_lg_n00O0i3629w(0) <= NOT n00O0i;
	wire_n00OlO_w_lg_n00O0l3632w(0) <= NOT n00O0l;
	wire_n00OlO_w_lg_n00O0O3634w(0) <= NOT n00O0O;
	wire_n00OlO_w_lg_n00O1i3735w(0) <= NOT n00O1i;
	wire_n00OlO_w_lg_n00O1l3737w(0) <= NOT n00O1l;
	wire_n00OlO_w_lg_n00Oii3636w(0) <= NOT n00Oii;
	wire_n00OlO_w_lg_n00Oil3638w(0) <= NOT n00Oil;
	wire_n00OlO_w_lg_n00OiO3640w(0) <= NOT n00OiO;
	wire_n00OlO_w_lg_n00Oli3642w(0) <= NOT n00Oli;
	wire_n00OlO_w_lg_n00Oll3644w(0) <= NOT n00Oll;
	PROCESS (pld_clk, wire_n0iOil_CLRN)
	BEGIN
		IF (wire_n0iOil_CLRN = '0') THEN
				n00OOl <= '0';
				n0iOiO <= '0';
		ELSIF (pld_clk = '1' AND pld_clk'event) THEN
				n00OOl <= n0iOiO;
				n0iOiO <= n01ilO;
		END IF;
		if (now = 0 ns) then
			n00OOl <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n0iOiO <= '1' after 1 ps;
		end if;
	END PROCESS;
	wire_n0iOil_CLRN <= ((n01ill20 XOR n01ill19) AND npor);
	wire_n0000i_dataout <= (NOT wire_n0000l_o(4)) AND wire_n0000O_o;
	wire_n0001i_dataout <= wire_n0000l_o(1) AND wire_n0000O_o;
	wire_n0001l_dataout <= wire_n0000l_o(2) AND wire_n0000O_o;
	wire_n0001O_dataout <= wire_n0000l_o(3) AND wire_n0000O_o;
	wire_n000iO_dataout <= wire_n00iil_o(0) WHEN n0100O = '1'  ELSE wire_n00i1l_dataout;
	wire_n000iO_w_lg_dataout3835w(0) <= NOT wire_n000iO_dataout;
	wire_n000li_dataout <= wire_n00iil_o(1) WHEN n0100O = '1'  ELSE wire_n00i1O_dataout;
	wire_n000li_w_lg_dataout3833w(0) <= NOT wire_n000li_dataout;
	wire_n000ll_dataout <= wire_n00iil_o(2) WHEN n0100O = '1'  ELSE wire_n00i0i_dataout;
	wire_n000ll_w_lg_dataout3831w(0) <= NOT wire_n000ll_dataout;
	wire_n000lO_dataout <= wire_n00iil_o(3) WHEN n0100O = '1'  ELSE wire_n00i0l_dataout;
	wire_n000lO_w_lg_dataout3829w(0) <= NOT wire_n000lO_dataout;
	wire_n000Oi_dataout <= wire_n00iil_o(4) WHEN n0100O = '1'  ELSE wire_n00i0l_dataout;
	wire_n000Oi_w_lg_dataout3827w(0) <= NOT wire_n000Oi_dataout;
	wire_n000Ol_dataout <= wire_n00iil_o(5) WHEN n0100O = '1'  ELSE wire_n00i0l_dataout;
	wire_n000Ol_w_lg_dataout3825w(0) <= NOT wire_n000Ol_dataout;
	wire_n000OO_dataout <= wire_n00iil_o(6) WHEN n0100O = '1'  ELSE wire_n00i0l_dataout;
	wire_n000OO_w_lg_dataout3823w(0) <= NOT wire_n000OO_dataout;
	wire_n0010i_dataout <= wire_n000ii_o(0) WHEN n0100l = '1'  ELSE wire_n0001i_dataout;
	wire_n0010i_w_lg_dataout3858w(0) <= NOT wire_n0010i_dataout;
	wire_n0010l_dataout <= wire_n000ii_o(1) WHEN n0100l = '1'  ELSE wire_n0001l_dataout;
	wire_n0010l_w_lg_dataout3856w(0) <= NOT wire_n0010l_dataout;
	wire_n0010O_dataout <= wire_n000ii_o(2) WHEN n0100l = '1'  ELSE wire_n0001O_dataout;
	wire_n0010O_w_lg_dataout3854w(0) <= NOT wire_n0010O_dataout;
	wire_n001ii_dataout <= wire_n000ii_o(3) WHEN n0100l = '1'  ELSE wire_n0000i_dataout;
	wire_n001ii_w_lg_dataout3852w(0) <= NOT wire_n001ii_dataout;
	wire_n001il_dataout <= wire_n000ii_o(4) WHEN n0100l = '1'  ELSE wire_n0000i_dataout;
	wire_n001il_w_lg_dataout3850w(0) <= NOT wire_n001il_dataout;
	wire_n001iO_dataout <= wire_n000ii_o(5) WHEN n0100l = '1'  ELSE wire_n0000i_dataout;
	wire_n001iO_w_lg_dataout3848w(0) <= NOT wire_n001iO_dataout;
	wire_n001li_dataout <= wire_n000ii_o(6) WHEN n0100l = '1'  ELSE wire_n0000i_dataout;
	wire_n001li_w_lg_dataout3846w(0) <= NOT wire_n001li_dataout;
	wire_n001ll_dataout <= wire_n000ii_o(7) WHEN n0100l = '1'  ELSE wire_n0000i_dataout;
	wire_n001ll_w_lg_dataout3844w(0) <= NOT wire_n001ll_dataout;
	wire_n001lO_dataout <= wire_n000ii_o(8) WHEN n0100l = '1'  ELSE wire_n0000i_dataout;
	wire_n001lO_w_lg_dataout3842w(0) <= NOT wire_n001lO_dataout;
	wire_n001Oi_dataout <= wire_n000ii_o(9) WHEN n0100l = '1'  ELSE wire_n0000i_dataout;
	wire_n001Oi_w_lg_dataout3840w(0) <= NOT wire_n001Oi_dataout;
	wire_n001Ol_dataout <= wire_n000ii_o(10) WHEN n0100l = '1'  ELSE wire_n0000i_dataout;
	wire_n001Ol_w_lg_dataout3838w(0) <= NOT wire_n001Ol_dataout;
	wire_n001OO_dataout <= wire_n000ii_o(11) WHEN n0100l = '1'  ELSE wire_n0000i_dataout;
	wire_n001OO_w_lg_dataout3837w(0) <= NOT wire_n001OO_dataout;
	wire_n00i0i_dataout <= wire_n00i0O_o(3) AND wire_n00iii_o;
	wire_n00i0l_dataout <= (NOT wire_n00i0O_o(4)) AND wire_n00iii_o;
	wire_n00i1i_dataout <= wire_n00iil_o(7) WHEN n0100O = '1'  ELSE wire_n00i0l_dataout;
	wire_n00i1i_w_lg_dataout3822w(0) <= NOT wire_n00i1i_dataout;
	wire_n00i1l_dataout <= wire_n00i0O_o(1) AND wire_n00iii_o;
	wire_n00i1O_dataout <= wire_n00i0O_o(2) AND wire_n00iii_o;
	wire_n00OOO_dataout <= wire_n0iO1l_dataout AND NOT(srst);
	wire_n0i00i_dataout <= wire_n0iiOO_dataout AND NOT(srst);
	wire_n0i00l_dataout <= wire_n0iOli_dataout AND NOT(srst);
	wire_n0i00O_dataout <= wire_n0il1l_dataout AND NOT(srst);
	wire_n0i01i_dataout <= wire_n0iilO_dataout AND NOT(srst);
	wire_n0i01l_dataout <= wire_n0iiOi_dataout AND NOT(srst);
	wire_n0i01O_dataout <= wire_n0iiOl_dataout AND NOT(srst);
	wire_n0i0ii_dataout <= wire_n0il1O_dataout AND NOT(srst);
	wire_n0i0il_dataout <= wire_n0il0i_dataout AND NOT(srst);
	wire_n0i0iO_dataout <= wire_n0il0l_dataout AND NOT(srst);
	wire_n0i0li_dataout <= wire_n0il0O_dataout AND NOT(srst);
	wire_n0i0ll_dataout <= wire_n0ilii_dataout AND NOT(srst);
	wire_n0i0lO_dataout <= wire_n0ilil_dataout AND NOT(srst);
	wire_n0i0Oi_dataout <= wire_n0iliO_dataout AND NOT(srst);
	wire_n0i0Ol_dataout <= wire_n0iOll_dataout AND NOT(srst);
	wire_n0i10i_dataout <= wire_n0illl_dataout AND NOT(srst);
	wire_n0i10l_dataout <= wire_n0ilOl_dataout AND NOT(srst);
	wire_n0i10O_dataout <= wire_n0illO_dataout OR srst;
	wire_n0i11i_dataout <= wire_n0iO1O_dataout AND NOT(srst);
	wire_n0i11l_dataout <= (((wire_n0iOli_dataout AND n010Ol) AND (n010lO36 XOR n010lO35)) OR n00iOi) AND NOT(srst);
	wire_n0i11O_dataout <= (wire_n0iOll_w_lg_w_lg_w_lg_dataout3538w3541w3542w(0) OR (NOT (n010OO34 XOR n010OO33))) AND NOT(srst);
	wire_n0i1ii_dataout <= wire_n0ilOO_dataout OR srst;
	wire_n0i1il_dataout <= wire_n0ii0i_dataout AND NOT(srst);
	wire_n0i1iO_dataout <= wire_n0ii0l_dataout AND NOT(srst);
	wire_n0i1li_dataout <= wire_n0ii0O_dataout AND NOT(srst);
	wire_n0i1ll_dataout <= wire_n0iiii_dataout AND NOT(srst);
	wire_n0i1lO_dataout <= wire_n0iiil_dataout AND NOT(srst);
	wire_n0i1Oi_dataout <= wire_n0iiiO_dataout AND NOT(srst);
	wire_n0i1Ol_dataout <= wire_n0iili_dataout AND NOT(srst);
	wire_n0i1OO_dataout <= wire_n0iill_dataout AND NOT(srst);
	wire_n0ii0i_dataout <= wire_n0il1i_o(0) WHEN n00O1O = '1'  ELSE n00l0O;
	wire_n0ii0l_dataout <= wire_n0il1i_o(1) WHEN n00O1O = '1'  ELSE n00lii;
	wire_n0ii0O_dataout <= wire_n0il1i_o(2) WHEN n00O1O = '1'  ELSE n00lil;
	wire_n0iiii_dataout <= wire_n0il1i_o(3) WHEN n00O1O = '1'  ELSE n00liO;
	wire_n0iiil_dataout <= wire_n0il1i_o(4) WHEN n00O1O = '1'  ELSE n00lli;
	wire_n0iiiO_dataout <= wire_n0il1i_o(5) WHEN n00O1O = '1'  ELSE n00lll;
	wire_n0iili_dataout <= wire_n0il1i_o(6) WHEN n00O1O = '1'  ELSE n00llO;
	wire_n0iill_dataout <= wire_n0il1i_o(7) WHEN n00O1O = '1'  ELSE n00lOi;
	wire_n0iilO_dataout <= wire_n0il1i_o(8) WHEN n00O1O = '1'  ELSE n00lOl;
	wire_n0iiOi_dataout <= wire_n0il1i_o(9) WHEN n00O1O = '1'  ELSE n00lOO;
	wire_n0iiOl_dataout <= wire_n0il1i_o(10) WHEN n00O1O = '1'  ELSE n00O1i;
	wire_n0iiOO_dataout <= wire_n0il1i_o(11) WHEN n00O1O = '1'  ELSE n00O1l;
	wire_n0il0i_dataout <= wire_n0illi_o(2) WHEN n00OOi = '1'  ELSE n00O0O;
	wire_n0il0l_dataout <= wire_n0illi_o(3) WHEN n00OOi = '1'  ELSE n00Oii;
	wire_n0il0O_dataout <= wire_n0illi_o(4) WHEN n00OOi = '1'  ELSE n00Oil;
	wire_n0il1l_dataout <= wire_n0illi_o(0) WHEN n00OOi = '1'  ELSE n00O0i;
	wire_n0il1O_dataout <= wire_n0illi_o(1) WHEN n00OOi = '1'  ELSE n00O0l;
	wire_n0ilii_dataout <= wire_n0illi_o(5) WHEN n00OOi = '1'  ELSE n00OiO;
	wire_n0ilil_dataout <= wire_n0illi_o(6) WHEN n00OOi = '1'  ELSE n00Oli;
	wire_n0iliO_dataout <= wire_n0illi_o(7) WHEN n00OOi = '1'  ELSE n00Oll;
	wire_n0illl_dataout <= (wire_n0l1il_w_lg_w_txcredvc0_range1644w3447w(0) AND (NOT wire_n0l1il_txcredvc0(20))) WHEN n00l1O = '1'  ELSE n00l1i;
	wire_n0illO_dataout <= wire_n0ilOi_w_lg_o3445w(0) AND n00l1O;
	wire_n0ilOl_dataout <= (wire_n0l1il_w_lg_w_txcredvc0_range1635w3427w(0) AND (NOT wire_n0l1il_txcredvc0(17))) WHEN n00l0l = '1'  ELSE n00l1l;
	wire_n0ilOO_dataout <= wire_n0iO1i_w_lg_o3425w(0) AND n00l0l;
	wire_n0iO0i_dataout <= (n01lil AND (tx_st_data0(30) AND n01l0l)) WHEN n01l0l = '1'  ELSE n00iOl;
	wire_n0iO0l_dataout <= n01lil WHEN n01l0l = '1'  ELSE n00ilO;
	wire_n0iO1l_dataout <= wire_n0iO0i_dataout AND NOT(n01ili);
	wire_n0iO1O_dataout <= wire_n0iO0l_dataout AND NOT(n01ili);
	wire_n0iOli_dataout <= n00iOl AND n01iOi;
	wire_n0iOll_dataout <= n00ilO AND n01iOi;
	wire_n0iOll_w_lg_w_lg_dataout3538w3541w(0) <= wire_n0iOll_w_lg_dataout3538w(0) AND wire_n01i1l32_w_lg_q3540w(0);
	wire_n0iOll_w_lg_dataout3538w(0) <= wire_n0iOll_dataout AND n01i0i;
	wire_n0iOll_w_lg_w_lg_w_lg_dataout3538w3541w3542w(0) <= wire_n0iOll_w_lg_w_lg_dataout3538w3541w(0) OR n00iOO;
	wire_n0000l_a <= ( "0" & wire_n0l1il_txcredvc0(20 DOWNTO 18) & "1");
	wire_n0000l_b <= ( "0" & "1" & "1" & "0" & "1");
	n0000l :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 5,
		width_b => 5,
		width_o => 5
	  )
	  PORT MAP ( 
		a => wire_n0000l_a,
		b => wire_n0000l_b,
		cin => wire_gnd,
		o => wire_n0000l_o
	  );
	wire_n000ii_a <= ( wire_n00OlO_w_lg_n00O1l3737w & wire_n00OlO_w_lg_n00O1i3735w & wire_n00OlO_w_lg_n00lOO3733w & wire_n00OlO_w_lg_n00lOl3731w & wire_n00OlO_w_lg_n00lOi3729w & wire_n00OlO_w_lg_n00llO3727w & wire_n00OlO_w_lg_n00lll3725w & wire_n00OlO_w_lg_n00lli3723w & wire_n00OlO_w_lg_n00liO3721w & wire_n00OlO_w_lg_n00lil3719w & wire_n00OlO_w_lg_n00lii3717w & wire_n00OlO_w_lg_n00l0O3714w);
	wire_n000ii_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "1");
	n000ii :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 12,
		width_b => 12,
		width_o => 12
	  )
	  PORT MAP ( 
		a => wire_n000ii_a,
		b => wire_n000ii_b,
		cin => wire_gnd,
		o => wire_n000ii_o
	  );
	wire_n00i0O_a <= ( "0" & wire_n0l1il_txcredvc0(17 DOWNTO 15) & "1");
	wire_n00i0O_b <= ( "0" & "1" & "1" & "0" & "1");
	n00i0O :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 5,
		width_b => 5,
		width_o => 5
	  )
	  PORT MAP ( 
		a => wire_n00i0O_a,
		b => wire_n00i0O_b,
		cin => wire_gnd,
		o => wire_n00i0O_o
	  );
	wire_n00iil_a <= ( wire_n00OlO_w_lg_n00Oll3644w & wire_n00OlO_w_lg_n00Oli3642w & wire_n00OlO_w_lg_n00OiO3640w & wire_n00OlO_w_lg_n00Oil3638w & wire_n00OlO_w_lg_n00Oii3636w & wire_n00OlO_w_lg_n00O0O3634w & wire_n00OlO_w_lg_n00O0l3632w & wire_n00OlO_w_lg_n00O0i3629w);
	wire_n00iil_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "1");
	n00iil :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 8,
		width_b => 8,
		width_o => 8
	  )
	  PORT MAP ( 
		a => wire_n00iil_a,
		b => wire_n00iil_b,
		cin => wire_gnd,
		o => wire_n00iil_o
	  );
	wire_n0il1i_a <= ( n00O1l & n00O1i & n00lOO & n00lOl & n00lOi & n00llO & n00lll & wire_n01i0l30_w_lg_w_lg_q3491w3492w & n00liO & n00lil & n00lii & n00l0O);
	wire_n0il1i_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "1");
	n0il1i :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 12,
		width_b => 12,
		width_o => 12
	  )
	  PORT MAP ( 
		a => wire_n0il1i_a,
		b => wire_n0il1i_b,
		cin => wire_gnd,
		o => wire_n0il1i_o
	  );
	wire_n0illi_a <= ( n00Oll & n00Oli & wire_n01i0O28_w_lg_w_lg_q3456w3457w & n00Oil & n00Oii & n00O0O & n00O0l & n00O0i);
	wire_n0illi_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "1");
	n0illi :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 8,
		width_b => 8,
		width_o => 8
	  )
	  PORT MAP ( 
		a => wire_n0illi_a,
		b => wire_n0illi_b,
		cin => wire_gnd,
		o => wire_n0illi_o
	  );
	wire_n0000O_a <= ( "0" & "0" & "1");
	wire_n0000O_b <= ( wire_n0l1il_txcredvc0(20 DOWNTO 18));
	n0000O :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 3,
		width_b => 3
	  )
	  PORT MAP ( 
		a => wire_n0000O_a,
		b => wire_n0000O_b,
		cin => wire_gnd,
		o => wire_n0000O_o
	  );
	wire_n00iii_a <= ( "0" & "0" & "1");
	wire_n00iii_b <= ( wire_n0l1il_txcredvc0(17 DOWNTO 15));
	n00iii :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 3,
		width_b => 3
	  )
	  PORT MAP ( 
		a => wire_n00iii_a,
		b => wire_n00iii_b,
		cin => wire_gnd,
		o => wire_n00iii_o
	  );
	wire_n00ili_a <= ( "0" & "1" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n00ili_b <= ( n00O1l & n00O1i & n00lOO & n00lOl & n00lOi & n00llO & n00lll & n00lli & n00liO & n00lil & n00lii & n00l0O);
	n00ili :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 12,
		width_b => 12
	  )
	  PORT MAP ( 
		a => wire_n00ili_a,
		b => wire_n00ili_b,
		cin => wire_gnd,
		o => wire_n00ili_o
	  );
	wire_n00ill_a <= ( "0" & "1" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n00ill_b <= ( n00Oll & n00Oli & wire_n010ii46_w_lg_w_lg_q3582w3583w & n00Oil & n00Oii & wire_n010il44_w_lg_w_lg_q3577w3578w & wire_n010iO42_w_lg_w_lg_q3574w3575w & n00O0i);
	n00ill :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 8,
		width_b => 8
	  )
	  PORT MAP ( 
		a => wire_n00ill_a,
		b => wire_n00ill_b,
		cin => wire_gnd,
		o => wire_n00ill_o
	  );
	wire_n0ilOi_w_lg_o3445w(0) <= NOT wire_n0ilOi_o;
	wire_n0ilOi_a <= ( "0" & "0" & "0");
	wire_n0ilOi_b <= ( wire_n0l1il_txcredvc0(20) & wire_n01iii26_w_lg_w_lg_q3441w3442w & wire_n01iil24_w_lg_w_lg_q3437w3438w);
	n0ilOi :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 3,
		width_b => 3
	  )
	  PORT MAP ( 
		a => wire_n0ilOi_a,
		b => wire_n0ilOi_b,
		cin => wire_gnd,
		o => wire_n0ilOi_o
	  );
	wire_n0iO1i_w_lg_o3425w(0) <= NOT wire_n0iO1i_o;
	wire_n0iO1i_a <= ( "0" & "0" & "0");
	wire_n0iO1i_b <= ( wire_n0l1il_txcredvc0(17) & wire_n01iiO22_w_lg_w_lg_q3421w3422w & wire_n0l1il_txcredvc0(15));
	n0iO1i :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 3,
		width_b => 3
	  )
	  PORT MAP ( 
		a => wire_n0iO1i_a,
		b => wire_n0iO1i_b,
		cin => wire_gnd,
		o => wire_n0iO1i_o
	  );

 END RTL; --Hard_IP_x1_core
--synopsys translate_on
--VALID FILE
