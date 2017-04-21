--IP Functional Simulation Model
--VERSION_BEGIN 15.1 cbx_mgl 2015:10:21:18:12:49:SJ cbx_simgen 2015:10:21:18:09:23:SJ  VERSION_END


-- Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus Prime License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- You may only use these simulation model output files for simulation
-- purposes and expressly not for synthesis or any other purposes (in which
-- event Altera disclaims all warranties of any kind).


--synopsys translate_off

 LIBRARY cycloneiv_pcie_hip;
 USE cycloneiv_pcie_hip.cycloneiv_pcie_hip_components.all;

 LIBRARY sgate;
 USE sgate.sgate_pack.all;

--synthesis_resources = cycloneiv_hssi_pcie_hip 1 lut 181 mux21 268 oper_add 6 oper_less_than 6 
 LIBRARY ieee;
 USE ieee.std_logic_1164.all;

 ENTITY  Hard_IP_x4_core IS 
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
		 phystatus1_ext	:	IN  STD_LOGIC;
		 phystatus2_ext	:	IN  STD_LOGIC;
		 phystatus3_ext	:	IN  STD_LOGIC;
		 pld_clk	:	IN  STD_LOGIC;
		 pll_fixed_clk	:	IN  STD_LOGIC;
		 pm_auxpwr	:	IN  STD_LOGIC;
		 pm_data	:	IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
		 pm_event	:	IN  STD_LOGIC;
		 pme_to_cr	:	IN  STD_LOGIC;
		 pme_to_sr	:	OUT  STD_LOGIC;
		 powerdown0_ext	:	OUT  STD_LOGIC_VECTOR (1 DOWNTO 0);
		 powerdown1_ext	:	OUT  STD_LOGIC_VECTOR (1 DOWNTO 0);
		 powerdown2_ext	:	OUT  STD_LOGIC_VECTOR (1 DOWNTO 0);
		 powerdown3_ext	:	OUT  STD_LOGIC_VECTOR (1 DOWNTO 0);
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
		 rxdata1_ext	:	IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 rxdata2_ext	:	IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 rxdata3_ext	:	IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 rxdatak0_ext	:	IN  STD_LOGIC;
		 rxdatak1_ext	:	IN  STD_LOGIC;
		 rxdatak2_ext	:	IN  STD_LOGIC;
		 rxdatak3_ext	:	IN  STD_LOGIC;
		 rxelecidle0_ext	:	IN  STD_LOGIC;
		 rxelecidle1_ext	:	IN  STD_LOGIC;
		 rxelecidle2_ext	:	IN  STD_LOGIC;
		 rxelecidle3_ext	:	IN  STD_LOGIC;
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
		 rxpolarity1_ext	:	OUT  STD_LOGIC;
		 rxpolarity2_ext	:	OUT  STD_LOGIC;
		 rxpolarity3_ext	:	OUT  STD_LOGIC;
		 rxstatus0_ext	:	IN  STD_LOGIC_VECTOR (2 DOWNTO 0);
		 rxstatus1_ext	:	IN  STD_LOGIC_VECTOR (2 DOWNTO 0);
		 rxstatus2_ext	:	IN  STD_LOGIC_VECTOR (2 DOWNTO 0);
		 rxstatus3_ext	:	IN  STD_LOGIC_VECTOR (2 DOWNTO 0);
		 rxvalid0_ext	:	IN  STD_LOGIC;
		 rxvalid1_ext	:	IN  STD_LOGIC;
		 rxvalid2_ext	:	IN  STD_LOGIC;
		 rxvalid3_ext	:	IN  STD_LOGIC;
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
		 txcompl1_ext	:	OUT  STD_LOGIC;
		 txcompl2_ext	:	OUT  STD_LOGIC;
		 txcompl3_ext	:	OUT  STD_LOGIC;
		 txdata0_ext	:	OUT  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 txdata1_ext	:	OUT  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 txdata2_ext	:	OUT  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 txdata3_ext	:	OUT  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 txdatak0_ext	:	OUT  STD_LOGIC;
		 txdatak1_ext	:	OUT  STD_LOGIC;
		 txdatak2_ext	:	OUT  STD_LOGIC;
		 txdatak3_ext	:	OUT  STD_LOGIC;
		 txdetectrx0_ext	:	OUT  STD_LOGIC;
		 txdetectrx1_ext	:	OUT  STD_LOGIC;
		 txdetectrx2_ext	:	OUT  STD_LOGIC;
		 txdetectrx3_ext	:	OUT  STD_LOGIC;
		 txelecidle0_ext	:	OUT  STD_LOGIC;
		 txelecidle1_ext	:	OUT  STD_LOGIC;
		 txelecidle2_ext	:	OUT  STD_LOGIC;
		 txelecidle3_ext	:	OUT  STD_LOGIC;
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
 END Hard_IP_x4_core;

 ARCHITECTURE RTL OF Hard_IP_x4_core IS

	 ATTRIBUTE synthesis_clearbox : natural;
	 ATTRIBUTE synthesis_clearbox OF RTL : ARCHITECTURE IS 1;
	 SIGNAL  wire_n00Oil_w_lg_w_txcredvc0_range1458w3465w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00Oil_w_lg_w_txcredvc0_range1467w3487w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00Oil_w_lg_w_txcredvc0_range1461w3464w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00Oil_w_lg_w_txcredvc0_range1470w3486w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_gnd	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_coreclkout	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_corepor	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_corerst	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_cplerr	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_n00Oil_dbgpipex1rx	:	STD_LOGIC_VECTOR (14 DOWNTO 0);
	 SIGNAL  wire_n00Oil_derrcorextrcv0	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_derrcorextrpl	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_derrrpl	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_dlctrllink2	:	STD_LOGIC_VECTOR (12 DOWNTO 0);
	 SIGNAL  wire_n00Oil_dldataupfc	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n00Oil_dlhdrupfc	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00Oil_dlltssm	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n00Oil_dlmaxploaddcr	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n00Oil_dlreqphycfg	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00Oil_dlreqphypm	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00Oil_dltxtyppm	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n00Oil_dltypupfc	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n00Oil_dlupexit	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_dlvcctrl	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00Oil_dlvcidmap	:	STD_LOGIC_VECTOR (23 DOWNTO 0);
	 SIGNAL  wire_n00Oil_dlvcidupfc	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_vcc	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_eidleinfersel	:	STD_LOGIC_VECTOR (23 DOWNTO 0);
	 SIGNAL  wire_n00Oil_ev128ns	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_ev1us	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_extraclkout	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n00Oil_gen2rate	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_hotrstexit	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_intstatus	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00Oil_l2exit	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_laneact	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00Oil_lmiack	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_lmiaddr	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n00Oil_lmidin	:	STD_LOGIC_VECTOR (31 DOWNTO 0);
	 SIGNAL  wire_n00Oil_lmidout	:	STD_LOGIC_VECTOR (31 DOWNTO 0);
	 SIGNAL  wire_n00Oil_mode	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n00Oil_phyrst	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_phystatus	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00Oil_pldrst	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_powerdown	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	 SIGNAL  wire_n00Oil_r2cerr0ext	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_resetstatus	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_rxbardecvc0	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00Oil_rxbevc00	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00Oil_rxbevc01	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00Oil_rxdata	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n00Oil_rxdatak	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00Oil_rxdatavc00	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n00Oil_rxdatavc01	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n00Oil_rxelecidle	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00Oil_rxeopvc00	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_rxeopvc01	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_rxerrvc0	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_rxfifoemptyvc0	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_rxfifofullvc0	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_rxpolarity	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00Oil_rxsopvc00	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_rxsopvc01	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_rxstatus	:	STD_LOGIC_VECTOR (23 DOWNTO 0);
	 SIGNAL  wire_n00Oil_rxvalid	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00Oil_rxvalidvc0	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_serrout	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_successspeednegoint	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_swdnin	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n00Oil_swdnwake	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_swuphotrst	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_swupin	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_n00Oil_testin	:	STD_LOGIC_VECTOR (39 DOWNTO 0);
	 SIGNAL  wire_n00Oil_testout	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n00Oil_tlaermsinum	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n00Oil_tlappintaack	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_tlappmsiack	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_tlappmsinum	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n00Oil_tlappmsitc	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n00Oil_tlcfgadd	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00Oil_tlcfgctl	:	STD_LOGIC_VECTOR (31 DOWNTO 0);
	 SIGNAL  wire_n00Oil_tlcfgctlwr	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_tlcfgsts	:	STD_LOGIC_VECTOR (52 DOWNTO 0);
	 SIGNAL  wire_n00Oil_tlcfgstswr	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_tlhpgctrler	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n00Oil_tlpexmsinum	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n00Oil_tlpmdata	:	STD_LOGIC_VECTOR (9 DOWNTO 0);
	 SIGNAL  wire_n00Oil_tlpmetosr	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_txcompl	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00Oil_txcredvc0	:	STD_LOGIC_VECTOR (35 DOWNTO 0);
	 SIGNAL  wire_n00Oil_txdata	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n00Oil_txdatak	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00Oil_txdatavc00	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n00Oil_txdatavc01	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n00Oil_txdatavc10	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n00Oil_txdatavc11	:	STD_LOGIC_VECTOR (63 DOWNTO 0);
	 SIGNAL  wire_n00Oil_txdeemph	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00Oil_txdetectrx	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00Oil_txelecidle	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n00Oil_txfifoemptyvc0	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_txfifofullvc0	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_txfifordpvc0	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00Oil_txfifowrpvc0	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00Oil_txmargin	:	STD_LOGIC_VECTOR (23 DOWNTO 0);
	 SIGNAL  wire_n00Oil_txreadyvc0	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_wakeoen	:	STD_LOGIC;
	 SIGNAL  wire_n00Oil_w_txcredvc0_range1458w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00Oil_w_txcredvc0_range1461w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00Oil_w_txcredvc0_range1467w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n00Oil_w_txcredvc0_range1470w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n110ii53	:	STD_LOGIC := '0';
	 SIGNAL	 n110ii54	:	STD_LOGIC := '0';
	 SIGNAL  wire_n110ii54_w_lg_w_lg_q3655w3656w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n110ii54_w_lg_q3655w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n110il51	:	STD_LOGIC := '0';
	 SIGNAL	 n110il52	:	STD_LOGIC := '0';
	 SIGNAL  wire_n110il52_w_lg_w_lg_q3652w3653w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n110il52_w_lg_q3652w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n110iO49	:	STD_LOGIC := '0';
	 SIGNAL	 n110iO50	:	STD_LOGIC := '0';
	 SIGNAL  wire_n110iO50_w_lg_w_lg_q3620w3621w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n110iO50_w_lg_q3620w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n110li47	:	STD_LOGIC := '0';
	 SIGNAL	 n110li48	:	STD_LOGIC := '0';
	 SIGNAL  wire_n110li48_w_lg_w_lg_q3615w3616w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n110li48_w_lg_q3615w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n110ll45	:	STD_LOGIC := '0';
	 SIGNAL	 n110ll46	:	STD_LOGIC := '0';
	 SIGNAL	 n110lO43	:	STD_LOGIC := '0';
	 SIGNAL	 n110lO44	:	STD_LOGIC := '0';
	 SIGNAL	 n110Oi41	:	STD_LOGIC := '0';
	 SIGNAL	 n110Oi42	:	STD_LOGIC := '0';
	 SIGNAL	 n11i0O35	:	STD_LOGIC := '0';
	 SIGNAL	 n11i0O36	:	STD_LOGIC := '0';
	 SIGNAL  wire_n11i0O36_w_lg_w_lg_q3498w3499w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n11i0O36_w_lg_q3498w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n11i1i39	:	STD_LOGIC := '0';
	 SIGNAL	 n11i1i40	:	STD_LOGIC := '0';
	 SIGNAL	 n11i1O37	:	STD_LOGIC := '0';
	 SIGNAL	 n11i1O38	:	STD_LOGIC := '0';
	 SIGNAL  wire_n11i1O38_w_lg_q3578w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n11iii33	:	STD_LOGIC := '0';
	 SIGNAL	 n11iii34	:	STD_LOGIC := '0';
	 SIGNAL  wire_n11iii34_w_lg_w_lg_q3478w3479w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n11iii34_w_lg_q3478w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n11iil31	:	STD_LOGIC := '0';
	 SIGNAL	 n11iil32	:	STD_LOGIC := '0';
	 SIGNAL	 n11ili29	:	STD_LOGIC := '0';
	 SIGNAL	 n11ili30	:	STD_LOGIC := '0';
	 SIGNAL  wire_n11ili30_w_lg_w_lg_q3459w3460w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n11ili30_w_lg_q3459w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n11ill27	:	STD_LOGIC := '0';
	 SIGNAL	 n11ill28	:	STD_LOGIC := '0';
	 SIGNAL	 n11iOl25	:	STD_LOGIC := '0';
	 SIGNAL	 n11iOl26	:	STD_LOGIC := '0';
	 SIGNAL	 n11l0l19	:	STD_LOGIC := '0';
	 SIGNAL	 n11l0l20	:	STD_LOGIC := '0';
	 SIGNAL  wire_n11l0l20_w_lg_w_lg_q3432w3433w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n11l0l20_w_lg_q3432w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n11l1i23	:	STD_LOGIC := '0';
	 SIGNAL	 n11l1i24	:	STD_LOGIC := '0';
	 SIGNAL	 n11l1O21	:	STD_LOGIC := '0';
	 SIGNAL	 n11l1O22	:	STD_LOGIC := '0';
	 SIGNAL	 n11lli17	:	STD_LOGIC := '0';
	 SIGNAL	 n11lli18	:	STD_LOGIC := '0';
	 SIGNAL  wire_n11lli18_w_lg_q3421w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n11llO15	:	STD_LOGIC := '0';
	 SIGNAL	 n11llO16	:	STD_LOGIC := '0';
	 SIGNAL  wire_n11llO16_w_lg_q3411w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	 n11lOl13	:	STD_LOGIC := '0';
	 SIGNAL	 n11lOl14	:	STD_LOGIC := '0';
	 SIGNAL	 n11O0l7	:	STD_LOGIC := '0';
	 SIGNAL	 n11O0l8	:	STD_LOGIC := '0';
	 SIGNAL	 n11O0O5	:	STD_LOGIC := '0';
	 SIGNAL	 n11O0O6	:	STD_LOGIC := '0';
	 SIGNAL	 n11O1l11	:	STD_LOGIC := '0';
	 SIGNAL	 n11O1l12	:	STD_LOGIC := '0';
	 SIGNAL	 n11O1O10	:	STD_LOGIC := '0';
	 SIGNAL	 n11O1O9	:	STD_LOGIC := '0';
	 SIGNAL	 n11Oil3	:	STD_LOGIC := '0';
	 SIGNAL	 n11Oil4	:	STD_LOGIC := '0';
	 SIGNAL	 n11Oll1	:	STD_LOGIC := '0';
	 SIGNAL	 n11Oll2	:	STD_LOGIC := '0';
	 SIGNAL	n10liO	:	STD_LOGIC := '0';
	 SIGNAL	n10lll	:	STD_LOGIC := '0';
	 SIGNAL	wire_n10lli_PRN	:	STD_LOGIC;
	 SIGNAL	n10l0i	:	STD_LOGIC := '0';
	 SIGNAL	n10l0l	:	STD_LOGIC := '0';
	 SIGNAL	n10l0O	:	STD_LOGIC := '0';
	 SIGNAL	n10l1O	:	STD_LOGIC := '0';
	 SIGNAL	n10lii	:	STD_LOGIC := '0';
	 SIGNAL	n10lil	:	STD_LOGIC := '0';
	 SIGNAL	n10llO	:	STD_LOGIC := '0';
	 SIGNAL	n10lOi	:	STD_LOGIC := '0';
	 SIGNAL	n10lOl	:	STD_LOGIC := '0';
	 SIGNAL	n10lOO	:	STD_LOGIC := '0';
	 SIGNAL	n10O0i	:	STD_LOGIC := '0';
	 SIGNAL	n10O0l	:	STD_LOGIC := '0';
	 SIGNAL	n10O0O	:	STD_LOGIC := '0';
	 SIGNAL	n10O1i	:	STD_LOGIC := '0';
	 SIGNAL	n10O1l	:	STD_LOGIC := '0';
	 SIGNAL	n10O1O	:	STD_LOGIC := '0';
	 SIGNAL	n10Oii	:	STD_LOGIC := '0';
	 SIGNAL	n10Oil	:	STD_LOGIC := '0';
	 SIGNAL	n10OiO	:	STD_LOGIC := '0';
	 SIGNAL	n10Oli	:	STD_LOGIC := '0';
	 SIGNAL	n10Oll	:	STD_LOGIC := '0';
	 SIGNAL	n10OlO	:	STD_LOGIC := '0';
	 SIGNAL	n10OOi	:	STD_LOGIC := '0';
	 SIGNAL	n10OOl	:	STD_LOGIC := '0';
	 SIGNAL	n10OOO	:	STD_LOGIC := '0';
	 SIGNAL	n1i10i	:	STD_LOGIC := '0';
	 SIGNAL	n1i11i	:	STD_LOGIC := '0';
	 SIGNAL	n1i11l	:	STD_LOGIC := '0';
	 SIGNAL	wire_n1i11O_PRN	:	STD_LOGIC;
	 SIGNAL  wire_n1i11O_w_lg_n10llO3753w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n10lOi3756w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n10lOl3758w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n10lOO3760w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n10O0i3768w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n10O0l3770w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n10O0O3772w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n10O1i3762w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n10O1l3764w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n10O1O3766w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n10Oii3774w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n10Oil3776w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n10Oli3669w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n10Oll3672w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n10OlO3674w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n10OOi3676w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n10OOl3678w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n10OOO3680w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n1i11i3682w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1i11O_w_lg_n1i11l3684w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	n1i10l	:	STD_LOGIC := '0';
	 SIGNAL	n1iOOO	:	STD_LOGIC := '0';
	 SIGNAL	wire_n1iOOl_PRN	:	STD_LOGIC;
	 SIGNAL	n1l00i	:	STD_LOGIC := '0';
	 SIGNAL	n1l00l	:	STD_LOGIC := '0';
	 SIGNAL	n1l00O	:	STD_LOGIC := '0';
	 SIGNAL	n1l01i	:	STD_LOGIC := '0';
	 SIGNAL	n1l01l	:	STD_LOGIC := '0';
	 SIGNAL	n1l01O	:	STD_LOGIC := '0';
	 SIGNAL	n1l0ii	:	STD_LOGIC := '0';
	 SIGNAL	n1l0il	:	STD_LOGIC := '0';
	 SIGNAL	n1l0iO	:	STD_LOGIC := '0';
	 SIGNAL	n1l0li	:	STD_LOGIC := '0';
	 SIGNAL	n1l0ll	:	STD_LOGIC := '0';
	 SIGNAL	n1l0lO	:	STD_LOGIC := '0';
	 SIGNAL	n1l0Oi	:	STD_LOGIC := '0';
	 SIGNAL	n1l0Ol	:	STD_LOGIC := '0';
	 SIGNAL	n1l0OO	:	STD_LOGIC := '0';
	 SIGNAL	n1l1Ol	:	STD_LOGIC := '0';
	 SIGNAL	n1l1OO	:	STD_LOGIC := '0';
	 SIGNAL	n1li0i	:	STD_LOGIC := '0';
	 SIGNAL	n1li0l	:	STD_LOGIC := '0';
	 SIGNAL	n1li0O	:	STD_LOGIC := '0';
	 SIGNAL	n1li1i	:	STD_LOGIC := '0';
	 SIGNAL	n1li1l	:	STD_LOGIC := '0';
	 SIGNAL	n1li1O	:	STD_LOGIC := '0';
	 SIGNAL	n1liii	:	STD_LOGIC := '0';
	 SIGNAL	n1liil	:	STD_LOGIC := '0';
	 SIGNAL	n1liiO	:	STD_LOGIC := '0';
	 SIGNAL	n1lili	:	STD_LOGIC := '0';
	 SIGNAL	n1lill	:	STD_LOGIC := '0';
	 SIGNAL	n1lilO	:	STD_LOGIC := '0';
	 SIGNAL	n1liOi	:	STD_LOGIC := '0';
	 SIGNAL	n1liOl	:	STD_LOGIC := '0';
	 SIGNAL	n1liOO	:	STD_LOGIC := '0';
	 SIGNAL	n1ll0i	:	STD_LOGIC := '0';
	 SIGNAL	n1ll0l	:	STD_LOGIC := '0';
	 SIGNAL	n1ll0O	:	STD_LOGIC := '0';
	 SIGNAL	n1ll1i	:	STD_LOGIC := '0';
	 SIGNAL	n1ll1l	:	STD_LOGIC := '0';
	 SIGNAL	n1ll1O	:	STD_LOGIC := '0';
	 SIGNAL	n1llii	:	STD_LOGIC := '0';
	 SIGNAL	n1llil	:	STD_LOGIC := '0';
	 SIGNAL	n1lliO	:	STD_LOGIC := '0';
	 SIGNAL	n1llli	:	STD_LOGIC := '0';
	 SIGNAL	n1llll	:	STD_LOGIC := '0';
	 SIGNAL	n1lllO	:	STD_LOGIC := '0';
	 SIGNAL	n1llOi	:	STD_LOGIC := '0';
	 SIGNAL	n1llOl	:	STD_LOGIC := '0';
	 SIGNAL	n1llOO	:	STD_LOGIC := '0';
	 SIGNAL	n1lO0i	:	STD_LOGIC := '0';
	 SIGNAL	n1lO0l	:	STD_LOGIC := '0';
	 SIGNAL	n1lO0O	:	STD_LOGIC := '0';
	 SIGNAL	n1lO1i	:	STD_LOGIC := '0';
	 SIGNAL	n1lO1l	:	STD_LOGIC := '0';
	 SIGNAL	n1lO1O	:	STD_LOGIC := '0';
	 SIGNAL	n1lOii	:	STD_LOGIC := '0';
	 SIGNAL	n1lOil	:	STD_LOGIC := '0';
	 SIGNAL	n1lOiO	:	STD_LOGIC := '0';
	 SIGNAL	n1lOli	:	STD_LOGIC := '0';
	 SIGNAL	n1lOll	:	STD_LOGIC := '0';
	 SIGNAL	n1lOlO	:	STD_LOGIC := '0';
	 SIGNAL	n1lOOi	:	STD_LOGIC := '0';
	 SIGNAL	n1lOOl	:	STD_LOGIC := '0';
	 SIGNAL	n1lOOO	:	STD_LOGIC := '0';
	 SIGNAL	n1O00i	:	STD_LOGIC := '0';
	 SIGNAL	n1O00l	:	STD_LOGIC := '0';
	 SIGNAL	n1O00O	:	STD_LOGIC := '0';
	 SIGNAL	n1O01i	:	STD_LOGIC := '0';
	 SIGNAL	n1O01l	:	STD_LOGIC := '0';
	 SIGNAL	n1O01O	:	STD_LOGIC := '0';
	 SIGNAL	n1O0ii	:	STD_LOGIC := '0';
	 SIGNAL	n1O0il	:	STD_LOGIC := '0';
	 SIGNAL	n1O0iO	:	STD_LOGIC := '0';
	 SIGNAL	n1O0li	:	STD_LOGIC := '0';
	 SIGNAL	n1O0ll	:	STD_LOGIC := '0';
	 SIGNAL	n1O0lO	:	STD_LOGIC := '0';
	 SIGNAL	n1O0Oi	:	STD_LOGIC := '0';
	 SIGNAL	n1O0OO	:	STD_LOGIC := '0';
	 SIGNAL	n1O10i	:	STD_LOGIC := '0';
	 SIGNAL	n1O10l	:	STD_LOGIC := '0';
	 SIGNAL	n1O10O	:	STD_LOGIC := '0';
	 SIGNAL	n1O11i	:	STD_LOGIC := '0';
	 SIGNAL	n1O11l	:	STD_LOGIC := '0';
	 SIGNAL	n1O11O	:	STD_LOGIC := '0';
	 SIGNAL	n1O1ii	:	STD_LOGIC := '0';
	 SIGNAL	n1O1il	:	STD_LOGIC := '0';
	 SIGNAL	n1O1iO	:	STD_LOGIC := '0';
	 SIGNAL	n1O1li	:	STD_LOGIC := '0';
	 SIGNAL	n1O1ll	:	STD_LOGIC := '0';
	 SIGNAL	n1O1lO	:	STD_LOGIC := '0';
	 SIGNAL	n1O1Oi	:	STD_LOGIC := '0';
	 SIGNAL	n1O1Ol	:	STD_LOGIC := '0';
	 SIGNAL	n1O1OO	:	STD_LOGIC := '0';
	 SIGNAL	wire_n1O0Ol_CLRN	:	STD_LOGIC;
	 SIGNAL	wire_n1O0Ol_PRN	:	STD_LOGIC;
	 SIGNAL	n1Oi0l	:	STD_LOGIC := '0';
	 SIGNAL	n1Oi1i	:	STD_LOGIC := '0';
	 SIGNAL	n1Oi1l	:	STD_LOGIC := '0';
	 SIGNAL	n1Oi1O	:	STD_LOGIC := '0';
	 SIGNAL	wire_n1Oi0i_CLRN	:	STD_LOGIC;
	 SIGNAL	wire_n1Oi0i_PRN	:	STD_LOGIC;
	 SIGNAL	wire_n0000i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0000l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0000O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0001i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0001l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0001O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n000ii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n000il_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n000iO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n000li_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n000ll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n000lO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n000Oi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n000Ol_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n000OO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0010i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0010l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0010O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0011i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0011l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0011O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n001ii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n001il_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n001iO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n001li_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n001ll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n001lO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n001Ol_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n001OO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00i0i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00i0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00i0O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00i1i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00i1l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00i1O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00iii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00iil_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00iiO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00ili_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00ill_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00ilO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00iOi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00iOl_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00iOO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00l0i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00l0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00l0O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00l1i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00l1l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00l1O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00lii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00lil_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00liO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00lli_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00lll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00llO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00lOi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00lOl_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00lOO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00O0i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00O0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00O0O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00O1i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00O1l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00O1O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0100i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0100l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0100O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0101i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0101l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0101O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n010ii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n010il_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n010iO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n010li_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n010ll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n010lO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n010Oi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n010Ol_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n010OO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0110i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0110l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0110O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0111i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0111l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0111O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n011ii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n011il_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n011iO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n011li_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n011ll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n011lO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n011Oi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n011Ol_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n011OO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01i0i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01i0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01i0O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01i1i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01i1l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01i1O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01iii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01iil_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01iiO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01ili_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01ill_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01ilO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01iOi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01iOl_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01iOO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01l0i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01l0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01l0O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01l1i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01l1l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01l1O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01lii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01lil_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01liO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01lli_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01lll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01llO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01lOi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01lOl_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01lOO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01O0i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01O0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01O0O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01O1i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01O1l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01O1O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01Oii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01Oil_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01OiO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01Oli_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01Oll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01OlO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01OOi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01OOl_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01OOO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1000i_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n1000i_w_lg_dataout3878w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n1000l_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n1000l_w_lg_dataout3876w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n1000O_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n1000O_w_lg_dataout3875w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n1001i_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n1001i_w_lg_dataout3884w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n1001l_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n1001l_w_lg_dataout3882w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n1001O_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n1001O_w_lg_dataout3880w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n100ii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n100il_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n100iO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n100li_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n100OO_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n100OO_w_lg_dataout3873w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n101li_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n101li_w_lg_dataout3896w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n101ll_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n101ll_w_lg_dataout3894w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n101lO_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n101lO_w_lg_dataout3892w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n101Oi_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n101Oi_w_lg_dataout3890w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n101Ol_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n101Ol_w_lg_dataout3888w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n101OO_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n101OO_w_lg_dataout3886w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n10i0i_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n10i0i_w_lg_dataout3865w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n10i0l_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n10i0l_w_lg_dataout3863w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n10i0O_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n10i0O_w_lg_dataout3861w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n10i1i_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n10i1i_w_lg_dataout3871w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n10i1l_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n10i1l_w_lg_dataout3869w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n10i1O_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n10i1O_w_lg_dataout3867w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n10iii_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n10iii_w_lg_dataout3860w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n10iil_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n10iiO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n10ili_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n10ill_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i00i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i00l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i00O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i01i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i01l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i01O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i0ii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i0il_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i0iO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i0li_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i0ll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i0lO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i0Oi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i0Ol_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i0OO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i10O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i1ii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i1il_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i1iO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i1li_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i1ll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i1lO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i1Oi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i1Ol_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1i1OO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1ii0i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1ii0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1ii1i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1ii1l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1ii1O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1iili_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1iill_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1iilO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1iiOi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1iiOl_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1iiOO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1il0i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1il0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1il0O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1il1i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1il1l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1il1O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1ilil_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1iliO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1illi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1illl_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1illO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1ilOi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1ilOl_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1ilOO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1iO0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1iO0O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1iO1l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1iO1O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1iOil_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1iOiO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1iOli_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1iOll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1l11i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1l11l_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n1l11l_w_lg_w_lg_dataout3576w3579w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1l11l_w_lg_dataout3576w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1l11l_w_lg_w_lg_w_lg_dataout3576w3579w3580w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n1Oi0O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1Oiii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1Oiil_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OiiO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1Oili_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1Oill_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OilO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OiOi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OiOl_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OiOO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1Ol0i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1Ol0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1Ol0O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1Ol1i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1Ol1l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1Ol1O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1Olii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1Olil_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OliO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1Olli_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1Olll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OllO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OlOi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OlOl_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OlOO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OO0i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OO0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OO0O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OO1i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OO1l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OO1O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OOii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OOil_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OOiO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OOli_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OOll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OOlO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OOOi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OOOl_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OOOO_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n100ll_a	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n100ll_b	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n100ll_o	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n100Oi_a	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n100Oi_b	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n100Oi_o	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n10ilO_a	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n10ilO_b	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n10ilO_o	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_n10iOl_a	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n10iOl_b	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n10iOl_o	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n1ilii_a	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n1ilii_b	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n1ilii_o	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n1iO1i_a	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n1iO1i_b	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n1iO1i_o	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n100lO_a	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n100lO_b	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n100lO_o	:	STD_LOGIC;
	 SIGNAL  wire_n10iOi_a	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n10iOi_b	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n10iOi_o	:	STD_LOGIC;
	 SIGNAL  wire_n10l1i_a	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n10l1i_b	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	 SIGNAL  wire_n10l1i_o	:	STD_LOGIC;
	 SIGNAL  wire_n10l1l_a	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n10l1l_b	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n10l1l_o	:	STD_LOGIC;
	 SIGNAL  wire_n1iO0i_w_lg_o3485w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1iO0i_a	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n1iO0i_b	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n1iO0i_o	:	STD_LOGIC;
	 SIGNAL  wire_n1iOii_w_lg_o3463w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_n1iOii_a	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n1iOii_b	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n1iOii_o	:	STD_LOGIC;
	 SIGNAL  wire_w_lg_w_lg_w_lg_w3412w3419w3422w3423w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_lg_w3412w3419w3422w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w3412w3419w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w3417w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w3412w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_lg_w_tx_st_data0_range2008w3413w3415w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_lg_w_tx_st_data0_range2023w3408w3409w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_lg_w_tx_st_data0_range2026w3403w3404w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_tx_st_valid03435w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_tx_st_data0_range2026w3445w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w3417w3418w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_n11liO3425w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_npor1781w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_srst3400w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_tx_st_err03428w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_tx_st_data0_range2008w3413w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_tx_st_data0_range2011w3414w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_tx_st_data0_range2014w3416w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_tx_st_data0_range2023w3408w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_tx_st_data0_range2026w3403w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_lg_tx_st_eop03430w3434w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_tx_st_eop03430w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_tx_st_eop03429w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  n1100l :	STD_LOGIC;
	 SIGNAL  n1100O :	STD_LOGIC;
	 SIGNAL  n110OO :	STD_LOGIC;
	 SIGNAL  n11i0l :	STD_LOGIC;
	 SIGNAL  n11iOi :	STD_LOGIC;
	 SIGNAL  n11l1l :	STD_LOGIC;
	 SIGNAL  n11lii :	STD_LOGIC;
	 SIGNAL  n11lil :	STD_LOGIC;
	 SIGNAL  n11liO :	STD_LOGIC;
	 SIGNAL  n11O0i :	STD_LOGIC;
	 SIGNAL  n11O1i :	STD_LOGIC;
	 SIGNAL  n11Oii :	STD_LOGIC;
	 SIGNAL  n11Oli :	STD_LOGIC;
	 SIGNAL  wire_w_tx_st_data0_range2008w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_tx_st_data0_range2011w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_tx_st_data0_range2014w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_tx_st_data0_range2023w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_tx_st_data0_range2026w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
 BEGIN

	wire_gnd <= '0';
	wire_vcc <= '1';
	wire_w_lg_w_lg_w_lg_w3412w3419w3422w3423w(0) <= wire_w_lg_w_lg_w3412w3419w3422w(0) AND n11O1i;
	wire_w_lg_w_lg_w3412w3419w3422w(0) <= wire_w_lg_w3412w3419w(0) AND wire_n11lli18_w_lg_q3421w(0);
	wire_w_lg_w3412w3419w(0) <= wire_w3412w(0) AND wire_w_lg_w3417w3418w(0);
	wire_w3417w(0) <= wire_w_lg_w_lg_w_tx_st_data0_range2008w3413w3415w(0) AND wire_w_lg_w_tx_st_data0_range2014w3416w(0);
	wire_w3412w(0) <= wire_w_lg_w_lg_w_tx_st_data0_range2023w3408w3409w(0) AND wire_n11llO16_w_lg_q3411w(0);
	wire_w_lg_w_lg_w_tx_st_data0_range2008w3413w3415w(0) <= wire_w_lg_w_tx_st_data0_range2008w3413w(0) AND wire_w_lg_w_tx_st_data0_range2011w3414w(0);
	wire_w_lg_w_lg_w_tx_st_data0_range2023w3408w3409w(0) <= wire_w_lg_w_tx_st_data0_range2023w3408w(0) AND wire_w_tx_st_data0_range2026w(0);
	wire_w_lg_w_lg_w_tx_st_data0_range2026w3403w3404w(0) <= wire_w_lg_w_tx_st_data0_range2026w3403w(0) AND n11O1i;
	wire_w_lg_tx_st_valid03435w(0) <= tx_st_valid0 AND wire_w_lg_w_lg_tx_st_eop03430w3434w(0);
	wire_w_lg_w_tx_st_data0_range2026w3445w(0) <= wire_w_tx_st_data0_range2026w(0) AND n11lii;
	wire_w_lg_w3417w3418w(0) <= NOT wire_w3417w(0);
	wire_w_lg_n11liO3425w(0) <= NOT n11liO;
	wire_w_lg_npor1781w(0) <= NOT npor;
	wire_w_lg_srst3400w(0) <= NOT srst;
	wire_w_lg_tx_st_err03428w(0) <= NOT tx_st_err0;
	wire_w_lg_w_tx_st_data0_range2008w3413w(0) <= NOT wire_w_tx_st_data0_range2008w(0);
	wire_w_lg_w_tx_st_data0_range2011w3414w(0) <= NOT wire_w_tx_st_data0_range2011w(0);
	wire_w_lg_w_tx_st_data0_range2014w3416w(0) <= NOT wire_w_tx_st_data0_range2014w(0);
	wire_w_lg_w_tx_st_data0_range2023w3408w(0) <= NOT wire_w_tx_st_data0_range2023w(0);
	wire_w_lg_w_tx_st_data0_range2026w3403w(0) <= NOT wire_w_tx_st_data0_range2026w(0);
	wire_w_lg_w_lg_tx_st_eop03430w3434w(0) <= wire_w_lg_tx_st_eop03430w(0) OR wire_n11l0l20_w_lg_w_lg_q3432w3433w(0);
	wire_w_lg_tx_st_eop03430w(0) <= tx_st_eop0 OR wire_w_lg_tx_st_eop03429w(0);
	wire_w_lg_tx_st_eop03429w(0) <= tx_st_eop0 XOR tx_st_eop0_p1;
	app_int_ack <= wire_n00Oil_tlappintaack;
	app_msi_ack <= wire_n00Oil_tlappmsiack;
	avs_pcie_reconfig_readdata <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	avs_pcie_reconfig_readdatavalid <= '0';
	avs_pcie_reconfig_waitrequest <= '1';
	core_clk_out <= wire_n00Oil_coreclkout;
	CraIrq_o <= '0';
	CraReadData_o <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	CraWaitRequest_o <= '0';
	derr_cor_ext_rcv0 <= wire_n00Oil_derrcorextrcv0;
	derr_cor_ext_rpl <= wire_n00Oil_derrcorextrpl;
	derr_rpl <= wire_n00Oil_derrrpl;
	dl_ltssm <= ( wire_n00Oil_dlltssm(4 DOWNTO 0));
	dlup_exit <= wire_n00Oil_dlupexit;
	eidle_infer_sel <= ( wire_n00Oil_eidleinfersel(23 DOWNTO 0));
	ev_128ns <= wire_n00Oil_ev128ns;
	ev_1us <= wire_n00Oil_ev1us;
	hip_extraclkout <= ( wire_n00Oil_extraclkout(1 DOWNTO 0));
	hotrst_exit <= wire_n00Oil_hotrstexit;
	int_status <= ( wire_n00Oil_intstatus(3 DOWNTO 0));
	l2_exit <= wire_n00Oil_l2exit;
	lane_act <= ( wire_n00Oil_laneact(3 DOWNTO 0));
	lmi_ack <= wire_n00Oil_lmiack;
	lmi_dout <= ( wire_n00Oil_lmidout(31 DOWNTO 0));
	n1100l <= (wire_n10l1i_o AND (((NOT wire_n00Oil_txcredvc0(18)) AND wire_n00Oil_w_lg_w_txcredvc0_range1470w3486w(0)) AND (NOT wire_n00Oil_txcredvc0(20))));
	n1100O <= (wire_n10l1l_o AND (((NOT wire_n00Oil_txcredvc0(15)) AND wire_n00Oil_w_lg_w_txcredvc0_range1461w3464w(0)) AND (NOT wire_n00Oil_txcredvc0(17))));
	n110OO <= (((((((((((wire_n1000O_w_lg_dataout3875w(0) AND wire_n1000l_w_lg_dataout3876w(0)) AND wire_n1000i_w_lg_dataout3878w(0)) AND wire_n1001O_w_lg_dataout3880w(0)) AND wire_n1001l_w_lg_dataout3882w(0)) AND wire_n1001i_w_lg_dataout3884w(0)) AND wire_n101OO_w_lg_dataout3886w(0)) AND wire_n101Ol_w_lg_dataout3888w(0)) AND wire_n101Oi_w_lg_dataout3890w(0)) AND wire_n101lO_w_lg_dataout3892w(0)) AND wire_n101ll_w_lg_dataout3894w(0)) AND wire_n101li_w_lg_dataout3896w(0));
	n11i0l <= (((((((wire_n10iii_w_lg_dataout3860w(0) AND wire_n10i0O_w_lg_dataout3861w(0)) AND wire_n10i0l_w_lg_dataout3863w(0)) AND wire_n10i0i_w_lg_dataout3865w(0)) AND wire_n10i1O_w_lg_dataout3867w(0)) AND wire_n10i1l_w_lg_dataout3869w(0)) AND wire_n10i1i_w_lg_dataout3871w(0)) AND wire_n100OO_w_lg_dataout3873w(0));
	n11iOi <= ((tx_st_err0 AND tx_st_valid0) AND (n11iOl26 XOR n11iOl25));
	n11l1l <= (wire_w_lg_tx_st_err03428w(0) AND (wire_w_lg_tx_st_valid03435w(0) AND (n11l1O22 XOR n11l1O21)));
	n11lii <= (tx_st_sop0 AND tx_st_valid0);
	n11lil <= (((wire_w_lg_w_lg_w_tx_st_data0_range2026w3403w3404w(0) AND (n11lOl14 XOR n11lOl13)) OR wire_w_lg_w_lg_w_lg_w3412w3419w3422w3423w(0)) AND wire_w_lg_n11liO3425w(0));
	n11liO <= ((((wire_w_lg_w_lg_w_tx_st_data0_range2008w3413w3415w(0) AND tx_st_data0(26)) AND (NOT tx_st_data0(27))) AND (NOT tx_st_data0(28))) AND wire_w_lg_w_tx_st_data0_range2023w3408w(0));
	n11O0i <= '1';
	n11O1i <= ((NOT tx_st_data0(27)) AND (NOT tx_st_data0(28)));
	n11Oii <= ((n1Oi0l XOR n1ll0l) XOR (NOT (n11Oil4 XOR n11Oil3)));
	n11Oli <= ((n1Oi1l XOR n1O0OO) XOR (NOT (n11Oll2 XOR n11Oll1)));
	npd_alloc_1cred_vc0 <= n10lii;
	npd_cred_vio_vc0 <= n10l0i;
	nph_alloc_1cred_vc0 <= n10lil;
	nph_cred_vio_vc0 <= n10l0O;
	pme_to_sr <= wire_n00Oil_tlpmetosr;
	powerdown0_ext <= ( wire_n00Oil_powerdown(1 DOWNTO 0));
	powerdown1_ext <= ( wire_n00Oil_powerdown(3 DOWNTO 2));
	powerdown2_ext <= ( wire_n00Oil_powerdown(5 DOWNTO 4));
	powerdown3_ext <= ( wire_n00Oil_powerdown(7 DOWNTO 6));
	r2c_err0 <= wire_n00Oil_r2cerr0ext;
	rate_ext <= wire_n00Oil_gen2rate;
	rc_gxb_powerdown <= '0';
	rc_rx_analogreset <= '0';
	rc_rx_digitalreset <= '0';
	rc_tx_digitalreset <= '0';
	reset_status <= wire_n00Oil_resetstatus;
	rx_fifo_empty0 <= wire_n00Oil_rxfifoemptyvc0;
	rx_fifo_full0 <= wire_n00Oil_rxfifofullvc0;
	rx_st_bardec0 <= ( wire_n00Oil_rxbardecvc0(7 DOWNTO 0));
	rx_st_be0 <= ( wire_n00Oil_rxbevc00(7 DOWNTO 0));
	rx_st_be0_p1 <= ( wire_n00Oil_rxbevc01(7 DOWNTO 0));
	rx_st_data0 <= ( wire_n00Oil_rxdatavc00(63 DOWNTO 0));
	rx_st_data0_p1 <= ( wire_n00Oil_rxdatavc01(63 DOWNTO 0));
	rx_st_eop0 <= wire_n00Oil_rxeopvc00;
	rx_st_eop0_p1 <= wire_n00Oil_rxeopvc01;
	rx_st_err0 <= wire_n00Oil_rxerrvc0;
	rx_st_sop0 <= wire_n00Oil_rxsopvc00;
	rx_st_sop0_p1 <= wire_n00Oil_rxsopvc01;
	rx_st_valid0 <= wire_n00Oil_rxvalidvc0;
	RxmAddress_o <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	RxmBurstCount_o <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	RxmByteEnable_o <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	RxmRead_o <= '0';
	RxmWrite_o <= '0';
	RxmWriteData_o <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	rxpolarity0_ext <= wire_n00Oil_rxpolarity(0);
	rxpolarity1_ext <= wire_n00Oil_rxpolarity(1);
	rxpolarity2_ext <= wire_n00Oil_rxpolarity(2);
	rxpolarity3_ext <= wire_n00Oil_rxpolarity(3);
	serr_out <= wire_n00Oil_serrout;
	suc_spd_neg <= wire_n00Oil_successspeednegoint;
	swdn_wake <= wire_n00Oil_swdnwake;
	swup_hotrst <= wire_n00Oil_swuphotrst;
	test_out <= ( wire_n00Oil_testout(63 DOWNTO 0));
	tl_cfg_add <= ( n1l1Ol & n1l1OO & n1l01i & n1l01l);
	tl_cfg_ctl <= ( n1l01O & n1l00i & n1l00l & n1l00O & n1l0ii & n1l0il & n1l0iO & n1l0li & n1l0ll & n1l0lO & n1l0Oi & n1l0Ol & n1l0OO & n1li1i & n1li1l & n1li1O & n1li0i & n1li0l & n1li0O & n1liii & n1liil & n1liiO & n1lili & n1lill & n1lilO & n1liOi & n1liOl & n1liOO & n1ll1i & n1ll1l & n1ll1O & n1ll0i);
	tl_cfg_ctl_wr <= n1ll0l;
	tl_cfg_sts <= ( n1ll0O & n1llii & n1llil & n1lliO & n1llli & n1llll & n1lllO & n1llOi & n1llOl & n1llOO & n1lO1i & n1lO1l & n1lO1O & n1lO0i & n1lO0l & n1lO0O & n1lOii & n1lOil & n1lOiO & n1lOli & n1lOll & n1lOlO & n1lOOi & n1lOOl & n1lOOO & n1O11i & n1O11l & n1O11O & n1O10i & n1O10l & n1O10O & n1O1ii & n1O1il & n1O1iO & n1O1li & n1O1ll & n1O1lO & n1O1Oi & n1O1Ol & n1O1OO & n1O01i & n1O01l & n1O01O & n1O00i & n1O00l & n1O00O & n1O0ii & n1O0il & n1O0iO & n1O0li & n1O0ll & n1O0lO & n1O0Oi);
	tl_cfg_sts_wr <= n1O0OO;
	tx_cred0 <= ( wire_n00Oil_txcredvc0(35 DOWNTO 0));
	tx_deemph <= ( wire_n00Oil_txdeemph(7 DOWNTO 0));
	tx_fifo_empty0 <= wire_n00Oil_txfifoemptyvc0;
	tx_fifo_full0 <= wire_n00Oil_txfifofullvc0;
	tx_fifo_rdptr0 <= ( wire_n00Oil_txfifordpvc0(3 DOWNTO 0));
	tx_fifo_wrptr0 <= ( wire_n00Oil_txfifowrpvc0(3 DOWNTO 0));
	tx_margin <= ( wire_n00Oil_txmargin(23 DOWNTO 0));
	tx_st_ready0 <= wire_n00Oil_txreadyvc0;
	txcompl0_ext <= wire_n00Oil_txcompl(0);
	txcompl1_ext <= wire_n00Oil_txcompl(1);
	txcompl2_ext <= wire_n00Oil_txcompl(2);
	txcompl3_ext <= wire_n00Oil_txcompl(3);
	txdata0_ext <= ( wire_n00Oil_txdata(7 DOWNTO 0));
	txdata1_ext <= ( wire_n00Oil_txdata(15 DOWNTO 8));
	txdata2_ext <= ( wire_n00Oil_txdata(23 DOWNTO 16));
	txdata3_ext <= ( wire_n00Oil_txdata(31 DOWNTO 24));
	txdatak0_ext <= wire_n00Oil_txdatak(0);
	txdatak1_ext <= wire_n00Oil_txdatak(1);
	txdatak2_ext <= wire_n00Oil_txdatak(2);
	txdatak3_ext <= wire_n00Oil_txdatak(3);
	txdetectrx0_ext <= wire_n00Oil_txdetectrx(0);
	txdetectrx1_ext <= wire_n00Oil_txdetectrx(1);
	txdetectrx2_ext <= wire_n00Oil_txdetectrx(2);
	txdetectrx3_ext <= wire_n00Oil_txdetectrx(3);
	txelecidle0_ext <= wire_n00Oil_txelecidle(0);
	txelecidle1_ext <= wire_n00Oil_txelecidle(1);
	txelecidle2_ext <= wire_n00Oil_txelecidle(2);
	txelecidle3_ext <= wire_n00Oil_txelecidle(3);
	TxsReadData_o <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	TxsReadDataValid_o <= '0';
	TxsWaitRequest_o <= '0';
	use_pcie_reconfig <= '0';
	wake_oen <= wire_n00Oil_wakeoen;
	wire_w_tx_st_data0_range2008w(0) <= tx_st_data0(24);
	wire_w_tx_st_data0_range2011w(0) <= tx_st_data0(25);
	wire_w_tx_st_data0_range2014w(0) <= tx_st_data0(26);
	wire_w_tx_st_data0_range2023w(0) <= tx_st_data0(29);
	wire_w_tx_st_data0_range2026w(0) <= tx_st_data0(30);
	wire_n00Oil_w_lg_w_txcredvc0_range1458w3465w(0) <= wire_n00Oil_w_txcredvc0_range1458w(0) AND wire_n00Oil_w_lg_w_txcredvc0_range1461w3464w(0);
	wire_n00Oil_w_lg_w_txcredvc0_range1467w3487w(0) <= wire_n00Oil_w_txcredvc0_range1467w(0) AND wire_n00Oil_w_lg_w_txcredvc0_range1470w3486w(0);
	wire_n00Oil_w_lg_w_txcredvc0_range1461w3464w(0) <= NOT wire_n00Oil_w_txcredvc0_range1461w(0);
	wire_n00Oil_w_lg_w_txcredvc0_range1470w3486w(0) <= NOT wire_n00Oil_w_txcredvc0_range1470w(0);
	wire_n00Oil_corepor <= wire_w_lg_npor1781w(0);
	wire_n00Oil_corerst <= wire_w_lg_npor1781w(0);
	wire_n00Oil_cplerr <= ( cpl_err(6 DOWNTO 0));
	wire_n00Oil_dbgpipex1rx <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n00Oil_dlctrllink2 <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n00Oil_dldataupfc <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n00Oil_dlhdrupfc <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n00Oil_dlmaxploaddcr <= ( "0" & "0" & "0");
	wire_n00Oil_dlreqphycfg <= ( "0" & "0" & "0" & "0");
	wire_n00Oil_dlreqphypm <= ( "0" & "0" & "0" & "0");
	wire_n00Oil_dltxtyppm <= ( "0" & "0" & "0");
	wire_n00Oil_dltypupfc <= ( "0" & "0");
	wire_n00Oil_dlvcctrl <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n00Oil_dlvcidmap <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n00Oil_dlvcidupfc <= ( "0" & "0" & "0");
	wire_n00Oil_lmiaddr <= ( lmi_addr(11 DOWNTO 0));
	wire_n00Oil_lmidin <= ( lmi_din(31 DOWNTO 0));
	wire_n00Oil_mode <= ( "0" & "1");
	wire_n00Oil_phyrst <= wire_w_lg_npor1781w(0);
	wire_n00Oil_phystatus <= ( "0" & "0" & "0" & "0" & phystatus3_ext & phystatus2_ext & phystatus1_ext & phystatus0_ext);
	wire_n00Oil_pldrst <= wire_w_lg_npor1781w(0);
	wire_n00Oil_rxdata <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & rxdata3_ext(7 DOWNTO 0) & rxdata2_ext(7 DOWNTO 0) & rxdata1_ext(7 DOWNTO 0) & rxdata0_ext(7 DOWNTO 0));
	wire_n00Oil_rxdatak <= ( "0" & "0" & "0" & "0" & rxdatak3_ext & rxdatak2_ext & rxdatak1_ext & rxdatak0_ext);
	wire_n00Oil_rxelecidle <= ( "0" & "0" & "0" & "0" & rxelecidle3_ext & rxelecidle2_ext & rxelecidle1_ext & rxelecidle0_ext);
	wire_n00Oil_rxstatus <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & rxstatus3_ext(2 DOWNTO 0) & rxstatus2_ext(2 DOWNTO 0) & rxstatus1_ext(2 DOWNTO 0) & rxstatus0_ext(2 DOWNTO 0));
	wire_n00Oil_rxvalid <= ( "0" & "0" & "0" & "0" & rxvalid3_ext & rxvalid2_ext & rxvalid1_ext & rxvalid0_ext);
	wire_n00Oil_swdnin <= ( "0" & "0" & "0");
	wire_n00Oil_swupin <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n00Oil_testin <= ( test_in(39 DOWNTO 0));
	wire_n00Oil_tlaermsinum <= ( aer_msi_num(4 DOWNTO 0));
	wire_n00Oil_tlappmsinum <= ( app_msi_num(4 DOWNTO 0));
	wire_n00Oil_tlappmsitc <= ( app_msi_tc(2 DOWNTO 0));
	wire_n00Oil_tlhpgctrler <= ( hpg_ctrler(4 DOWNTO 0));
	wire_n00Oil_tlpexmsinum <= ( pex_msi_num(4 DOWNTO 0));
	wire_n00Oil_tlpmdata <= ( pm_data(9 DOWNTO 0));
	wire_n00Oil_txdatavc00 <= ( tx_st_data0(63 DOWNTO 0));
	wire_n00Oil_txdatavc01 <= ( tx_st_data0_p1(63 DOWNTO 0));
	wire_n00Oil_txdatavc10 <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n00Oil_txdatavc11 <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n00Oil_w_txcredvc0_range1458w(0) <= wire_n00Oil_txcredvc0(15);
	wire_n00Oil_w_txcredvc0_range1461w(0) <= wire_n00Oil_txcredvc0(16);
	wire_n00Oil_w_txcredvc0_range1467w(0) <= wire_n00Oil_txcredvc0(18);
	wire_n00Oil_w_txcredvc0_range1470w(0) <= wire_n00Oil_txcredvc0(19);
	n00Oil :  cycloneiv_hssi_pcie_hip
	  GENERIC MAP (
		advanced_errors => "false",
		bar0_64bit_mem_space => "false",
		bar0_io_space => "false",
		bar0_prefetchable => "false",
		bar0_size_mask => 28,
		bar1_64bit_mem_space => "false",
		bar1_io_space => "false",
		bar1_prefetchable => "false",
		bar1_size_mask => 18,
		bar2_64bit_mem_space => "false",
		bar2_io_space => "false",
		bar2_prefetchable => "false",
		bar2_size_mask => 18,
		bar3_64bit_mem_space => "false",
		bar3_io_space => "false",
		bar3_prefetchable => "false",
		bar3_size_mask => 18,
		bar4_64bit_mem_space => "false",
		bar4_io_space => "false",
		bar4_prefetchable => "false",
		bar4_size_mask => 18,
		bar5_64bit_mem_space => "false",
		bar5_io_space => "false",
		bar5_prefetchable => "false",
		bar5_size_mask => 18,
		bar_io_window_size => "32BIT",
		bar_prefetchable => 32,
		bridge_port_ssid_support => "false",
		bridge_port_vga_enable => "false",
		bypass_cdc => "false",
		bypass_tl => "false",
		class_code => 16711680,
		completion_timeout => "NONE",
		core_clk_divider => 2,
		core_clk_source => "PLL_FIXED_CLK",
		credit_buffer_allocation_aux => "BALANCED",
		deemphasis_enable => "false",
		device_id => 4,
		device_number => 0,
		diffclock_nfts_count => 255,
		disable_cdc_clk_ppm => "false",
		disable_link_x2_support => "false",
		disable_snoop_packet => "00000000",
		dll_active_report_support => "false",
		ei_delay_powerdown_count => 10,
		eie_before_nfts_count => 4,
		enable_adapter_half_rate_mode => "false",
		enable_ch0_pclk_out => "false",
		enable_completion_timeout_disable => "false",
		enable_coreclk_out_half_rate => "false",
		enable_ecrc_check => "false",
		enable_ecrc_gen => "false",
		enable_function_msi_support => "true",
		enable_function_msix_support => "false",
		enable_gen2_core => "false",
		enable_hip_x1_loopback => "false",
		enable_l1_aspm => "false",
		enable_msi_64bit_addressing => "false",
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
		lane_mask => "11110000",
		low_priority_vc => 0,
		lpm_type => "stratixiv_hssi_pcie_hip",
		max_link_width => 4,
		max_payload_size => 0,
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
		revision_id => 1,
		rx_ptr0_nonposted_dpram_max => 0,
		rx_ptr0_nonposted_dpram_min => 0,
		rx_ptr0_posted_dpram_max => 0,
		rx_ptr0_posted_dpram_min => 0,
		rx_ptr1_nonposted_dpram_max => 0,
		rx_ptr1_nonposted_dpram_min => 0,
		rx_ptr1_posted_dpram_max => 0,
		rx_ptr1_posted_dpram_min => 0,
		sameclock_nfts_count => 255,
		single_rx_detect => 4,
		skp_os_schedule_count => 0,
		slot_number => 0,
		slot_power_limit => 0,
		slot_power_scale => 0,
		ssid => 0,
		ssvid => 0,
		subsystem_device_id => 4,
		subsystem_vendor_id => 4466,
		surprise_down_error_support => "false",
		tx_cdc_full_value => 12,
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
		vendor_id => 4466
	  )
	  PORT MAP ( 
		bistenrcv0 => wire_gnd,
		bistenrcv1 => wire_gnd,
		bistenrpl => wire_gnd,
		bistscanen => wire_gnd,
		bistscanin => wire_gnd,
		bisttesten => wire_gnd,
		coreclkin => core_clk_in,
		coreclkout => wire_n00Oil_coreclkout,
		corecrst => crst,
		corepor => wire_n00Oil_corepor,
		corerst => wire_n00Oil_corerst,
		coresrst => srst,
		cplerr => wire_n00Oil_cplerr,
		cplpending => cpl_pending,
		dbgpipex1rx => wire_n00Oil_dbgpipex1rx,
		derrcorextrcv0 => wire_n00Oil_derrcorextrcv0,
		derrcorextrpl => wire_n00Oil_derrcorextrpl,
		derrrpl => wire_n00Oil_derrrpl,
		dlaspmcr0 => wire_gnd,
		dlcomclkreg => wire_gnd,
		dlctrllink2 => wire_n00Oil_dlctrllink2,
		dldataupfc => wire_n00Oil_dldataupfc,
		dlhdrupfc => wire_n00Oil_dlhdrupfc,
		dlinhdllp => wire_gnd,
		dlltssm => wire_n00Oil_dlltssm,
		dlmaxploaddcr => wire_n00Oil_dlmaxploaddcr,
		dlreqphycfg => wire_n00Oil_dlreqphycfg,
		dlreqphypm => wire_n00Oil_dlreqphypm,
		dlrequpfc => wire_gnd,
		dlreqwake => wire_gnd,
		dlrxecrcchk => wire_gnd,
		dlsndupfc => wire_gnd,
		dltxcfgextsy => wire_gnd,
		dltxreqpm => wire_gnd,
		dltxtyppm => wire_n00Oil_dltxtyppm,
		dltypupfc => wire_n00Oil_dltypupfc,
		dlupexit => wire_n00Oil_dlupexit,
		dlvcctrl => wire_n00Oil_dlvcctrl,
		dlvcidmap => wire_n00Oil_dlvcidmap,
		dlvcidupfc => wire_n00Oil_dlvcidupfc,
		dpclk => wire_gnd,
		dpriodisable => wire_vcc,
		dprioin => wire_gnd,
		dprioload => wire_gnd,
		eidleinfersel => wire_n00Oil_eidleinfersel,
		ev128ns => wire_n00Oil_ev128ns,
		ev1us => wire_n00Oil_ev1us,
		extraclkout => wire_n00Oil_extraclkout,
		gen2rate => wire_n00Oil_gen2rate,
		hotrstexit => wire_n00Oil_hotrstexit,
		intstatus => wire_n00Oil_intstatus,
		l2exit => wire_n00Oil_l2exit,
		laneact => wire_n00Oil_laneact,
		lmiack => wire_n00Oil_lmiack,
		lmiaddr => wire_n00Oil_lmiaddr,
		lmidin => wire_n00Oil_lmidin,
		lmidout => wire_n00Oil_lmidout,
		lmirden => lmi_rden,
		lmiwren => lmi_wren,
		mode => wire_n00Oil_mode,
		mramhiptestenable => wire_gnd,
		mramregscanen => wire_gnd,
		mramregscanin => wire_gnd,
		pclkcentral => pclk_central,
		pclkch0 => pclk_ch0,
		phyrst => wire_n00Oil_phyrst,
		physrst => srst,
		phystatus => wire_n00Oil_phystatus,
		pldclk => pld_clk,
		pldrst => wire_n00Oil_pldrst,
		pldsrst => srst,
		pllfixedclk => pll_fixed_clk,
		powerdown => wire_n00Oil_powerdown,
		r2cerr0ext => wire_n00Oil_r2cerr0ext,
		resetstatus => wire_n00Oil_resetstatus,
		rxbardecvc0 => wire_n00Oil_rxbardecvc0,
		rxbevc00 => wire_n00Oil_rxbevc00,
		rxbevc01 => wire_n00Oil_rxbevc01,
		rxdata => wire_n00Oil_rxdata,
		rxdatak => wire_n00Oil_rxdatak,
		rxdatavc00 => wire_n00Oil_rxdatavc00,
		rxdatavc01 => wire_n00Oil_rxdatavc01,
		rxelecidle => wire_n00Oil_rxelecidle,
		rxeopvc00 => wire_n00Oil_rxeopvc00,
		rxeopvc01 => wire_n00Oil_rxeopvc01,
		rxerrvc0 => wire_n00Oil_rxerrvc0,
		rxfifoemptyvc0 => wire_n00Oil_rxfifoemptyvc0,
		rxfifofullvc0 => wire_n00Oil_rxfifofullvc0,
		rxmaskvc0 => rx_st_mask0,
		rxmaskvc1 => wire_gnd,
		rxpolarity => wire_n00Oil_rxpolarity,
		rxreadyvc0 => rx_st_ready0,
		rxreadyvc1 => wire_gnd,
		rxsopvc00 => wire_n00Oil_rxsopvc00,
		rxsopvc01 => wire_n00Oil_rxsopvc01,
		rxstatus => wire_n00Oil_rxstatus,
		rxvalid => wire_n00Oil_rxvalid,
		rxvalidvc0 => wire_n00Oil_rxvalidvc0,
		scanen => wire_gnd,
		scanmoden => wire_vcc,
		serrout => wire_n00Oil_serrout,
		successspeednegoint => wire_n00Oil_successspeednegoint,
		swdnin => wire_n00Oil_swdnin,
		swdnwake => wire_n00Oil_swdnwake,
		swuphotrst => wire_n00Oil_swuphotrst,
		swupin => wire_n00Oil_swupin,
		testin => wire_n00Oil_testin,
		testout => wire_n00Oil_testout,
		tlaermsinum => wire_n00Oil_tlaermsinum,
		tlappintaack => wire_n00Oil_tlappintaack,
		tlappintasts => app_int_sts,
		tlappmsiack => wire_n00Oil_tlappmsiack,
		tlappmsinum => wire_n00Oil_tlappmsinum,
		tlappmsireq => app_msi_req,
		tlappmsitc => wire_n00Oil_tlappmsitc,
		tlcfgadd => wire_n00Oil_tlcfgadd,
		tlcfgctl => wire_n00Oil_tlcfgctl,
		tlcfgctlwr => wire_n00Oil_tlcfgctlwr,
		tlcfgsts => wire_n00Oil_tlcfgsts,
		tlcfgstswr => wire_n00Oil_tlcfgstswr,
		tlhpgctrler => wire_n00Oil_tlhpgctrler,
		tlpexmsinum => wire_n00Oil_tlpexmsinum,
		tlpmauxpwr => pm_auxpwr,
		tlpmdata => wire_n00Oil_tlpmdata,
		tlpmetocr => pme_to_cr,
		tlpmetosr => wire_n00Oil_tlpmetosr,
		tlpmevent => pm_event,
		tlslotclkcfg => wire_vcc,
		txcompl => wire_n00Oil_txcompl,
		txcredvc0 => wire_n00Oil_txcredvc0,
		txdata => wire_n00Oil_txdata,
		txdatak => wire_n00Oil_txdatak,
		txdatavc00 => wire_n00Oil_txdatavc00,
		txdatavc01 => wire_n00Oil_txdatavc01,
		txdatavc10 => wire_n00Oil_txdatavc10,
		txdatavc11 => wire_n00Oil_txdatavc11,
		txdeemph => wire_n00Oil_txdeemph,
		txdetectrx => wire_n00Oil_txdetectrx,
		txelecidle => wire_n00Oil_txelecidle,
		txeopvc00 => tx_st_eop0,
		txeopvc01 => tx_st_eop0_p1,
		txeopvc10 => wire_gnd,
		txeopvc11 => wire_gnd,
		txerrvc0 => tx_st_err0,
		txerrvc1 => wire_gnd,
		txfifoemptyvc0 => wire_n00Oil_txfifoemptyvc0,
		txfifofullvc0 => wire_n00Oil_txfifofullvc0,
		txfifordpvc0 => wire_n00Oil_txfifordpvc0,
		txfifowrpvc0 => wire_n00Oil_txfifowrpvc0,
		txmargin => wire_n00Oil_txmargin,
		txreadyvc0 => wire_n00Oil_txreadyvc0,
		txsopvc00 => tx_st_sop0,
		txsopvc01 => tx_st_sop0_p1,
		txsopvc10 => wire_gnd,
		txsopvc11 => wire_gnd,
		txvalidvc0 => tx_st_valid0,
		txvalidvc1 => wire_gnd,
		wakeoen => wire_n00Oil_wakeoen
	  );
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n110ii53 <= n110ii54;
		END IF;
		if (now = 0 ns) then
			n110ii53 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n110ii54 <= n110ii53;
		END IF;
	END PROCESS;
	wire_n110ii54_w_lg_w_lg_q3655w3656w(0) <= wire_n110ii54_w_lg_q3655w(0) AND n10O1i;
	wire_n110ii54_w_lg_q3655w(0) <= n110ii54 XOR n110ii53;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n110il51 <= n110il52;
		END IF;
		if (now = 0 ns) then
			n110il51 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n110il52 <= n110il51;
		END IF;
	END PROCESS;
	wire_n110il52_w_lg_w_lg_q3652w3653w(0) <= wire_n110il52_w_lg_q3652w(0) AND n10lOO;
	wire_n110il52_w_lg_q3652w(0) <= n110il52 XOR n110il51;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n110iO49 <= n110iO50;
		END IF;
		if (now = 0 ns) then
			n110iO49 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n110iO50 <= n110iO49;
		END IF;
	END PROCESS;
	wire_n110iO50_w_lg_w_lg_q3620w3621w(0) <= wire_n110iO50_w_lg_q3620w(0) AND n1i11l;
	wire_n110iO50_w_lg_q3620w(0) <= n110iO50 XOR n110iO49;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n110li47 <= n110li48;
		END IF;
		if (now = 0 ns) then
			n110li47 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n110li48 <= n110li47;
		END IF;
	END PROCESS;
	wire_n110li48_w_lg_w_lg_q3615w3616w(0) <= wire_n110li48_w_lg_q3615w(0) AND n10OOl;
	wire_n110li48_w_lg_q3615w(0) <= n110li48 XOR n110li47;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n110ll45 <= n110ll46;
		END IF;
		if (now = 0 ns) then
			n110ll45 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n110ll46 <= n110ll45;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n110lO43 <= n110lO44;
		END IF;
		if (now = 0 ns) then
			n110lO43 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n110lO44 <= n110lO43;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n110Oi41 <= n110Oi42;
		END IF;
		if (now = 0 ns) then
			n110Oi41 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n110Oi42 <= n110Oi41;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11i0O35 <= n11i0O36;
		END IF;
		if (now = 0 ns) then
			n11i0O35 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11i0O36 <= n11i0O35;
		END IF;
	END PROCESS;
	wire_n11i0O36_w_lg_w_lg_q3498w3499w(0) <= wire_n11i0O36_w_lg_q3498w(0) AND n1i11l;
	wire_n11i0O36_w_lg_q3498w(0) <= n11i0O36 XOR n11i0O35;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11i1i39 <= n11i1i40;
		END IF;
		if (now = 0 ns) then
			n11i1i39 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11i1i40 <= n11i1i39;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11i1O37 <= n11i1O38;
		END IF;
		if (now = 0 ns) then
			n11i1O37 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11i1O38 <= n11i1O37;
		END IF;
	END PROCESS;
	wire_n11i1O38_w_lg_q3578w(0) <= n11i1O38 XOR n11i1O37;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11iii33 <= n11iii34;
		END IF;
		if (now = 0 ns) then
			n11iii33 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11iii34 <= n11iii33;
		END IF;
	END PROCESS;
	wire_n11iii34_w_lg_w_lg_q3478w3479w(0) <= wire_n11iii34_w_lg_q3478w(0) AND wire_n00Oil_w_txcredvc0_range1467w(0);
	wire_n11iii34_w_lg_q3478w(0) <= n11iii34 XOR n11iii33;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11iil31 <= n11iil32;
		END IF;
		if (now = 0 ns) then
			n11iil31 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11iil32 <= n11iil31;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11ili29 <= n11ili30;
		END IF;
		if (now = 0 ns) then
			n11ili29 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11ili30 <= n11ili29;
		END IF;
	END PROCESS;
	wire_n11ili30_w_lg_w_lg_q3459w3460w(0) <= wire_n11ili30_w_lg_q3459w(0) AND wire_n00Oil_w_txcredvc0_range1461w(0);
	wire_n11ili30_w_lg_q3459w(0) <= n11ili30 XOR n11ili29;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11ill27 <= n11ill28;
		END IF;
		if (now = 0 ns) then
			n11ill27 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11ill28 <= n11ill27;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11iOl25 <= n11iOl26;
		END IF;
		if (now = 0 ns) then
			n11iOl25 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11iOl26 <= n11iOl25;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11l0l19 <= n11l0l20;
		END IF;
		if (now = 0 ns) then
			n11l0l19 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11l0l20 <= n11l0l19;
		END IF;
	END PROCESS;
	wire_n11l0l20_w_lg_w_lg_q3432w3433w(0) <= NOT wire_n11l0l20_w_lg_q3432w(0);
	wire_n11l0l20_w_lg_q3432w(0) <= n11l0l20 XOR n11l0l19;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11l1i23 <= n11l1i24;
		END IF;
		if (now = 0 ns) then
			n11l1i23 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11l1i24 <= n11l1i23;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11l1O21 <= n11l1O22;
		END IF;
		if (now = 0 ns) then
			n11l1O21 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11l1O22 <= n11l1O21;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11lli17 <= n11lli18;
		END IF;
		if (now = 0 ns) then
			n11lli17 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11lli18 <= n11lli17;
		END IF;
	END PROCESS;
	wire_n11lli18_w_lg_q3421w(0) <= n11lli18 XOR n11lli17;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11llO15 <= n11llO16;
		END IF;
		if (now = 0 ns) then
			n11llO15 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11llO16 <= n11llO15;
		END IF;
	END PROCESS;
	wire_n11llO16_w_lg_q3411w(0) <= n11llO16 XOR n11llO15;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11lOl13 <= n11lOl14;
		END IF;
		if (now = 0 ns) then
			n11lOl13 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11lOl14 <= n11lOl13;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11O0l7 <= n11O0l8;
		END IF;
		if (now = 0 ns) then
			n11O0l7 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11O0l8 <= n11O0l7;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11O0O5 <= n11O0O6;
		END IF;
		if (now = 0 ns) then
			n11O0O5 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11O0O6 <= n11O0O5;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11O1l11 <= n11O1l12;
		END IF;
		if (now = 0 ns) then
			n11O1l11 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11O1l12 <= n11O1l11;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11O1O10 <= n11O1O9;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11O1O9 <= n11O1O10;
		END IF;
		if (now = 0 ns) then
			n11O1O9 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11Oil3 <= n11Oil4;
		END IF;
		if (now = 0 ns) then
			n11Oil3 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11Oil4 <= n11Oil3;
		END IF;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11Oll1 <= n11Oll2;
		END IF;
		if (now = 0 ns) then
			n11Oll1 <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (pld_clk)
	BEGIN
		IF (pld_clk = '1' AND pld_clk'event) THEN n11Oll2 <= n11Oll1;
		END IF;
	END PROCESS;
	PROCESS (pld_clk, wire_n10lli_PRN)
	BEGIN
		IF (wire_n10lli_PRN = '0') THEN
				n10liO <= '1';
				n10lll <= '1';
		ELSIF (pld_clk = '1' AND pld_clk'event) THEN
				n10liO <= wire_n1i1lO_dataout;
				n10lll <= wire_n1i1Oi_dataout;
		END IF;
		if (now = 0 ns) then
			n10liO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10lll <= '1' after 1 ps;
		end if;
	END PROCESS;
	wire_n10lli_PRN <= ((n110ll46 XOR n110ll45) AND n1i10l);
	PROCESS (pld_clk, wire_n1i11O_PRN, n1i10l)
	BEGIN
		IF (wire_n1i11O_PRN = '0') THEN
				n10l0i <= '1';
				n10l0l <= '1';
				n10l0O <= '1';
				n10l1O <= '1';
				n10lii <= '1';
				n10lil <= '1';
				n10llO <= '1';
				n10lOi <= '1';
				n10lOl <= '1';
				n10lOO <= '1';
				n10O0i <= '1';
				n10O0l <= '1';
				n10O0O <= '1';
				n10O1i <= '1';
				n10O1l <= '1';
				n10O1O <= '1';
				n10Oii <= '1';
				n10Oil <= '1';
				n10OiO <= '1';
				n10Oli <= '1';
				n10Oll <= '1';
				n10OlO <= '1';
				n10OOi <= '1';
				n10OOl <= '1';
				n10OOO <= '1';
				n1i10i <= '1';
				n1i11i <= '1';
				n1i11l <= '1';
		ELSIF (n1i10l = '0') THEN
				n10l0i <= '0';
				n10l0l <= '0';
				n10l0O <= '0';
				n10l1O <= '0';
				n10lii <= '0';
				n10lil <= '0';
				n10llO <= '0';
				n10lOi <= '0';
				n10lOl <= '0';
				n10lOO <= '0';
				n10O0i <= '0';
				n10O0l <= '0';
				n10O0O <= '0';
				n10O1i <= '0';
				n10O1l <= '0';
				n10O1O <= '0';
				n10Oii <= '0';
				n10Oil <= '0';
				n10OiO <= '0';
				n10Oli <= '0';
				n10Oll <= '0';
				n10OlO <= '0';
				n10OOi <= '0';
				n10OOl <= '0';
				n10OOO <= '0';
				n1i10i <= '0';
				n1i11i <= '0';
				n1i11l <= '0';
		ELSIF (pld_clk = '1' AND pld_clk'event) THEN
				n10l0i <= wire_n1i1il_dataout;
				n10l0l <= wire_n1i10O_dataout;
				n10l0O <= wire_n1i1iO_dataout;
				n10l1O <= wire_n1i1ii_dataout;
				n10lii <= wire_n1i1li_dataout;
				n10lil <= wire_n1i1ll_dataout;
				n10llO <= wire_n1i1Ol_dataout;
				n10lOi <= wire_n1i1OO_dataout;
				n10lOl <= wire_n1i01i_dataout;
				n10lOO <= wire_n1i01l_dataout;
				n10O0i <= wire_n1i00O_dataout;
				n10O0l <= wire_n1i0ii_dataout;
				n10O0O <= wire_n1i0il_dataout;
				n10O1i <= wire_n1i01O_dataout;
				n10O1l <= wire_n1i00i_dataout;
				n10O1O <= wire_n1i00l_dataout;
				n10Oii <= wire_n1i0iO_dataout;
				n10Oil <= wire_n1i0li_dataout;
				n10OiO <= wire_n1i0ll_dataout;
				n10Oli <= wire_n1i0lO_dataout;
				n10Oll <= wire_n1i0Oi_dataout;
				n10OlO <= wire_n1i0Ol_dataout;
				n10OOi <= wire_n1i0OO_dataout;
				n10OOl <= wire_n1ii1i_dataout;
				n10OOO <= wire_n1ii1l_dataout;
				n1i10i <= wire_n1ii0l_dataout;
				n1i11i <= wire_n1ii1O_dataout;
				n1i11l <= wire_n1ii0i_dataout;
		END IF;
		if (now = 0 ns) then
			n10l0i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10l0l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10l0O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10l1O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10lii <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10lil <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10llO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10lOi <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10lOl <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10lOO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10O0i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10O0l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10O0O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10O1i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10O1l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10O1O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10Oii <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10Oil <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10OiO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10Oli <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10Oll <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10OlO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10OOi <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10OOl <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n10OOO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1i10i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1i11i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1i11l <= '1' after 1 ps;
		end if;
	END PROCESS;
	wire_n1i11O_PRN <= (n110lO44 XOR n110lO43);
	wire_n1i11O_w_lg_n10llO3753w(0) <= NOT n10llO;
	wire_n1i11O_w_lg_n10lOi3756w(0) <= NOT n10lOi;
	wire_n1i11O_w_lg_n10lOl3758w(0) <= NOT n10lOl;
	wire_n1i11O_w_lg_n10lOO3760w(0) <= NOT n10lOO;
	wire_n1i11O_w_lg_n10O0i3768w(0) <= NOT n10O0i;
	wire_n1i11O_w_lg_n10O0l3770w(0) <= NOT n10O0l;
	wire_n1i11O_w_lg_n10O0O3772w(0) <= NOT n10O0O;
	wire_n1i11O_w_lg_n10O1i3762w(0) <= NOT n10O1i;
	wire_n1i11O_w_lg_n10O1l3764w(0) <= NOT n10O1l;
	wire_n1i11O_w_lg_n10O1O3766w(0) <= NOT n10O1O;
	wire_n1i11O_w_lg_n10Oii3774w(0) <= NOT n10Oii;
	wire_n1i11O_w_lg_n10Oil3776w(0) <= NOT n10Oil;
	wire_n1i11O_w_lg_n10Oli3669w(0) <= NOT n10Oli;
	wire_n1i11O_w_lg_n10Oll3672w(0) <= NOT n10Oll;
	wire_n1i11O_w_lg_n10OlO3674w(0) <= NOT n10OlO;
	wire_n1i11O_w_lg_n10OOi3676w(0) <= NOT n10OOi;
	wire_n1i11O_w_lg_n10OOl3678w(0) <= NOT n10OOl;
	wire_n1i11O_w_lg_n10OOO3680w(0) <= NOT n10OOO;
	wire_n1i11O_w_lg_n1i11i3682w(0) <= NOT n1i11i;
	wire_n1i11O_w_lg_n1i11l3684w(0) <= NOT n1i11l;
	PROCESS (pld_clk, wire_n1iOOl_PRN, npor)
	BEGIN
		IF (wire_n1iOOl_PRN = '0') THEN
				n1i10l <= '1';
				n1iOOO <= '1';
		ELSIF (npor = '0') THEN
				n1i10l <= '0';
				n1iOOO <= '0';
		ELSIF (pld_clk = '1' AND pld_clk'event) THEN
				n1i10l <= n1iOOO;
				n1iOOO <= n11O0i;
		END IF;
		if (now = 0 ns) then
			n1i10l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1iOOO <= '1' after 1 ps;
		end if;
	END PROCESS;
	wire_n1iOOl_PRN <= (n11l1i24 XOR n11l1i23);
	PROCESS (pld_clk, wire_n1O0Ol_PRN, wire_n1O0Ol_CLRN)
	BEGIN
		IF (wire_n1O0Ol_PRN = '0') THEN
				n1l00i <= '1';
				n1l00l <= '1';
				n1l00O <= '1';
				n1l01i <= '1';
				n1l01l <= '1';
				n1l01O <= '1';
				n1l0ii <= '1';
				n1l0il <= '1';
				n1l0iO <= '1';
				n1l0li <= '1';
				n1l0ll <= '1';
				n1l0lO <= '1';
				n1l0Oi <= '1';
				n1l0Ol <= '1';
				n1l0OO <= '1';
				n1l1Ol <= '1';
				n1l1OO <= '1';
				n1li0i <= '1';
				n1li0l <= '1';
				n1li0O <= '1';
				n1li1i <= '1';
				n1li1l <= '1';
				n1li1O <= '1';
				n1liii <= '1';
				n1liil <= '1';
				n1liiO <= '1';
				n1lili <= '1';
				n1lill <= '1';
				n1lilO <= '1';
				n1liOi <= '1';
				n1liOl <= '1';
				n1liOO <= '1';
				n1ll0i <= '1';
				n1ll0l <= '1';
				n1ll0O <= '1';
				n1ll1i <= '1';
				n1ll1l <= '1';
				n1ll1O <= '1';
				n1llii <= '1';
				n1llil <= '1';
				n1lliO <= '1';
				n1llli <= '1';
				n1llll <= '1';
				n1lllO <= '1';
				n1llOi <= '1';
				n1llOl <= '1';
				n1llOO <= '1';
				n1lO0i <= '1';
				n1lO0l <= '1';
				n1lO0O <= '1';
				n1lO1i <= '1';
				n1lO1l <= '1';
				n1lO1O <= '1';
				n1lOii <= '1';
				n1lOil <= '1';
				n1lOiO <= '1';
				n1lOli <= '1';
				n1lOll <= '1';
				n1lOlO <= '1';
				n1lOOi <= '1';
				n1lOOl <= '1';
				n1lOOO <= '1';
				n1O00i <= '1';
				n1O00l <= '1';
				n1O00O <= '1';
				n1O01i <= '1';
				n1O01l <= '1';
				n1O01O <= '1';
				n1O0ii <= '1';
				n1O0il <= '1';
				n1O0iO <= '1';
				n1O0li <= '1';
				n1O0ll <= '1';
				n1O0lO <= '1';
				n1O0Oi <= '1';
				n1O0OO <= '1';
				n1O10i <= '1';
				n1O10l <= '1';
				n1O10O <= '1';
				n1O11i <= '1';
				n1O11l <= '1';
				n1O11O <= '1';
				n1O1ii <= '1';
				n1O1il <= '1';
				n1O1iO <= '1';
				n1O1li <= '1';
				n1O1ll <= '1';
				n1O1lO <= '1';
				n1O1Oi <= '1';
				n1O1Ol <= '1';
				n1O1OO <= '1';
		ELSIF (wire_n1O0Ol_CLRN = '0') THEN
				n1l00i <= '0';
				n1l00l <= '0';
				n1l00O <= '0';
				n1l01i <= '0';
				n1l01l <= '0';
				n1l01O <= '0';
				n1l0ii <= '0';
				n1l0il <= '0';
				n1l0iO <= '0';
				n1l0li <= '0';
				n1l0ll <= '0';
				n1l0lO <= '0';
				n1l0Oi <= '0';
				n1l0Ol <= '0';
				n1l0OO <= '0';
				n1l1Ol <= '0';
				n1l1OO <= '0';
				n1li0i <= '0';
				n1li0l <= '0';
				n1li0O <= '0';
				n1li1i <= '0';
				n1li1l <= '0';
				n1li1O <= '0';
				n1liii <= '0';
				n1liil <= '0';
				n1liiO <= '0';
				n1lili <= '0';
				n1lill <= '0';
				n1lilO <= '0';
				n1liOi <= '0';
				n1liOl <= '0';
				n1liOO <= '0';
				n1ll0i <= '0';
				n1ll0l <= '0';
				n1ll0O <= '0';
				n1ll1i <= '0';
				n1ll1l <= '0';
				n1ll1O <= '0';
				n1llii <= '0';
				n1llil <= '0';
				n1lliO <= '0';
				n1llli <= '0';
				n1llll <= '0';
				n1lllO <= '0';
				n1llOi <= '0';
				n1llOl <= '0';
				n1llOO <= '0';
				n1lO0i <= '0';
				n1lO0l <= '0';
				n1lO0O <= '0';
				n1lO1i <= '0';
				n1lO1l <= '0';
				n1lO1O <= '0';
				n1lOii <= '0';
				n1lOil <= '0';
				n1lOiO <= '0';
				n1lOli <= '0';
				n1lOll <= '0';
				n1lOlO <= '0';
				n1lOOi <= '0';
				n1lOOl <= '0';
				n1lOOO <= '0';
				n1O00i <= '0';
				n1O00l <= '0';
				n1O00O <= '0';
				n1O01i <= '0';
				n1O01l <= '0';
				n1O01O <= '0';
				n1O0ii <= '0';
				n1O0il <= '0';
				n1O0iO <= '0';
				n1O0li <= '0';
				n1O0ll <= '0';
				n1O0lO <= '0';
				n1O0Oi <= '0';
				n1O0OO <= '0';
				n1O10i <= '0';
				n1O10l <= '0';
				n1O10O <= '0';
				n1O11i <= '0';
				n1O11l <= '0';
				n1O11O <= '0';
				n1O1ii <= '0';
				n1O1il <= '0';
				n1O1iO <= '0';
				n1O1li <= '0';
				n1O1ll <= '0';
				n1O1lO <= '0';
				n1O1Oi <= '0';
				n1O1Ol <= '0';
				n1O1OO <= '0';
		ELSIF (pld_clk = '1' AND pld_clk'event) THEN
				n1l00i <= wire_n01l1i_dataout;
				n1l00l <= wire_n01iOO_dataout;
				n1l00O <= wire_n01iOl_dataout;
				n1l01i <= wire_n01l0i_dataout;
				n1l01l <= wire_n01l1O_dataout;
				n1l01O <= wire_n01l1l_dataout;
				n1l0ii <= wire_n01iOi_dataout;
				n1l0il <= wire_n01ilO_dataout;
				n1l0iO <= wire_n01ill_dataout;
				n1l0li <= wire_n01ili_dataout;
				n1l0ll <= wire_n01iiO_dataout;
				n1l0lO <= wire_n01iil_dataout;
				n1l0Oi <= wire_n01iii_dataout;
				n1l0Ol <= wire_n01i0O_dataout;
				n1l0OO <= wire_n01i0l_dataout;
				n1l1Ol <= wire_n01l0O_dataout;
				n1l1OO <= wire_n01l0l_dataout;
				n1li0i <= wire_n01i1i_dataout;
				n1li0l <= wire_n010OO_dataout;
				n1li0O <= wire_n010Ol_dataout;
				n1li1i <= wire_n01i0i_dataout;
				n1li1l <= wire_n01i1O_dataout;
				n1li1O <= wire_n01i1l_dataout;
				n1liii <= wire_n010Oi_dataout;
				n1liil <= wire_n010lO_dataout;
				n1liiO <= wire_n010ll_dataout;
				n1lili <= wire_n010li_dataout;
				n1lill <= wire_n010iO_dataout;
				n1lilO <= wire_n010il_dataout;
				n1liOi <= wire_n010ii_dataout;
				n1liOl <= wire_n0100O_dataout;
				n1liOO <= wire_n0100l_dataout;
				n1ll0i <= wire_n0101i_dataout;
				n1ll0l <= wire_n011OO_dataout;
				n1ll0O <= wire_n011Ol_dataout;
				n1ll1i <= wire_n0100i_dataout;
				n1ll1l <= wire_n0101O_dataout;
				n1ll1O <= wire_n0101l_dataout;
				n1llii <= wire_n011Oi_dataout;
				n1llil <= wire_n011lO_dataout;
				n1lliO <= wire_n011ll_dataout;
				n1llli <= wire_n011li_dataout;
				n1llll <= wire_n011iO_dataout;
				n1lllO <= wire_n011il_dataout;
				n1llOi <= wire_n011ii_dataout;
				n1llOl <= wire_n0110O_dataout;
				n1llOO <= wire_n0110l_dataout;
				n1lO0i <= wire_n0111i_dataout;
				n1lO0l <= wire_n1OOOO_dataout;
				n1lO0O <= wire_n1OOOl_dataout;
				n1lO1i <= wire_n0110i_dataout;
				n1lO1l <= wire_n0111O_dataout;
				n1lO1O <= wire_n0111l_dataout;
				n1lOii <= wire_n1OOOi_dataout;
				n1lOil <= wire_n1OOlO_dataout;
				n1lOiO <= wire_n1OOll_dataout;
				n1lOli <= wire_n1OOli_dataout;
				n1lOll <= wire_n1OOiO_dataout;
				n1lOlO <= wire_n1OOil_dataout;
				n1lOOi <= wire_n1OOii_dataout;
				n1lOOl <= wire_n1OO0O_dataout;
				n1lOOO <= wire_n1OO0l_dataout;
				n1O00i <= wire_n1Ol1i_dataout;
				n1O00l <= wire_n1OiOO_dataout;
				n1O00O <= wire_n1OiOl_dataout;
				n1O01i <= wire_n1Ol0i_dataout;
				n1O01l <= wire_n1Ol1O_dataout;
				n1O01O <= wire_n1Ol1l_dataout;
				n1O0ii <= wire_n1OiOi_dataout;
				n1O0il <= wire_n1OilO_dataout;
				n1O0iO <= wire_n1Oill_dataout;
				n1O0li <= wire_n1Oili_dataout;
				n1O0ll <= wire_n1OiiO_dataout;
				n1O0lO <= wire_n1Oiil_dataout;
				n1O0Oi <= wire_n1Oiii_dataout;
				n1O0OO <= wire_n1Oi0O_dataout;
				n1O10i <= wire_n1OO1i_dataout;
				n1O10l <= wire_n1OlOO_dataout;
				n1O10O <= wire_n1OlOl_dataout;
				n1O11i <= wire_n1OO0i_dataout;
				n1O11l <= wire_n1OO1O_dataout;
				n1O11O <= wire_n1OO1l_dataout;
				n1O1ii <= wire_n1OlOi_dataout;
				n1O1il <= wire_n1OllO_dataout;
				n1O1iO <= wire_n1Olll_dataout;
				n1O1li <= wire_n1Olli_dataout;
				n1O1ll <= wire_n1OliO_dataout;
				n1O1lO <= wire_n1Olil_dataout;
				n1O1Oi <= wire_n1Olii_dataout;
				n1O1Ol <= wire_n1Ol0O_dataout;
				n1O1OO <= wire_n1Ol0l_dataout;
		END IF;
		if (now = 0 ns) then
			n1l00i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1l00l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1l00O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1l01i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1l01l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1l01O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1l0ii <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1l0il <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1l0iO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1l0li <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1l0ll <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1l0lO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1l0Oi <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1l0Ol <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1l0OO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1l1Ol <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1l1OO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1li0i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1li0l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1li0O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1li1i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1li1l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1li1O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1liii <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1liil <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1liiO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lili <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lill <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lilO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1liOi <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1liOl <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1liOO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1ll0i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1ll0l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1ll0O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1ll1i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1ll1l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1ll1O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1llii <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1llil <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lliO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1llli <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1llll <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lllO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1llOi <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1llOl <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1llOO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lO0i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lO0l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lO0O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lO1i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lO1l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lO1O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lOii <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lOil <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lOiO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lOli <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lOll <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lOlO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lOOi <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lOOl <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1lOOO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O00i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O00l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O00O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O01i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O01l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O01O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O0ii <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O0il <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O0iO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O0li <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O0ll <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O0lO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O0Oi <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O0OO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O10i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O10l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O10O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O11i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O11l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O11O <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O1ii <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O1il <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O1iO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O1li <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O1ll <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O1lO <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O1Oi <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O1Ol <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1O1OO <= '1' after 1 ps;
		end if;
	END PROCESS;
	wire_n1O0Ol_CLRN <= (n11O1O10 XOR n11O1O9);
	wire_n1O0Ol_PRN <= (n11O1l12 XOR n11O1l11);
	PROCESS (pld_clk, wire_n1Oi0i_PRN, wire_n1Oi0i_CLRN)
	BEGIN
		IF (wire_n1Oi0i_PRN = '0') THEN
				n1Oi0l <= '1';
				n1Oi1i <= '1';
				n1Oi1l <= '1';
				n1Oi1O <= '1';
		ELSIF (wire_n1Oi0i_CLRN = '0') THEN
				n1Oi0l <= '0';
				n1Oi1i <= '0';
				n1Oi1l <= '0';
				n1Oi1O <= '0';
		ELSIF (pld_clk = '1' AND pld_clk'event) THEN
			IF (srst = '0') THEN
				n1Oi0l <= n1Oi1O;
				n1Oi1i <= wire_n00Oil_tlcfgstswr;
				n1Oi1l <= n1Oi1i;
				n1Oi1O <= wire_n00Oil_tlcfgctlwr;
			END IF;
		END IF;
		if (now = 0 ns) then
			n1Oi0l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1Oi1i <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1Oi1l <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			n1Oi1O <= '1' after 1 ps;
		end if;
	END PROCESS;
	wire_n1Oi0i_CLRN <= (n11O0O6 XOR n11O0O5);
	wire_n1Oi0i_PRN <= (n11O0l8 XOR n11O0l7);
	wire_n0000i_dataout <= wire_n00Oil_tlcfgsts(5) WHEN n11Oli = '1'  ELSE n1O0il;
	wire_n0000l_dataout <= wire_n00Oil_tlcfgsts(6) WHEN n11Oli = '1'  ELSE n1O0ii;
	wire_n0000O_dataout <= wire_n00Oil_tlcfgsts(7) WHEN n11Oli = '1'  ELSE n1O00O;
	wire_n0001i_dataout <= wire_n00Oil_tlcfgsts(2) WHEN n11Oli = '1'  ELSE n1O0ll;
	wire_n0001l_dataout <= wire_n00Oil_tlcfgsts(3) WHEN n11Oli = '1'  ELSE n1O0li;
	wire_n0001O_dataout <= wire_n00Oil_tlcfgsts(4) WHEN n11Oli = '1'  ELSE n1O0iO;
	wire_n000ii_dataout <= wire_n00Oil_tlcfgsts(8) WHEN n11Oli = '1'  ELSE n1O00l;
	wire_n000il_dataout <= wire_n00Oil_tlcfgsts(9) WHEN n11Oli = '1'  ELSE n1O00i;
	wire_n000iO_dataout <= wire_n00Oil_tlcfgsts(10) WHEN n11Oli = '1'  ELSE n1O01O;
	wire_n000li_dataout <= wire_n00Oil_tlcfgsts(11) WHEN n11Oli = '1'  ELSE n1O01l;
	wire_n000ll_dataout <= wire_n00Oil_tlcfgsts(12) WHEN n11Oli = '1'  ELSE n1O01i;
	wire_n000lO_dataout <= wire_n00Oil_tlcfgsts(13) WHEN n11Oli = '1'  ELSE n1O1OO;
	wire_n000Oi_dataout <= wire_n00Oil_tlcfgsts(14) WHEN n11Oli = '1'  ELSE n1O1Ol;
	wire_n000Ol_dataout <= wire_n00Oil_tlcfgsts(15) WHEN n11Oli = '1'  ELSE n1O1Oi;
	wire_n000OO_dataout <= wire_n00Oil_tlcfgsts(16) WHEN n11Oli = '1'  ELSE n1O1lO;
	wire_n0010i_dataout <= wire_n00Oil_tlcfgctl(27) WHEN n11Oii = '1'  ELSE n1l0ii;
	wire_n0010l_dataout <= wire_n00Oil_tlcfgctl(28) WHEN n11Oii = '1'  ELSE n1l00O;
	wire_n0010O_dataout <= wire_n00Oil_tlcfgctl(29) WHEN n11Oii = '1'  ELSE n1l00l;
	wire_n0011i_dataout <= wire_n00Oil_tlcfgctl(24) WHEN n11Oii = '1'  ELSE n1l0li;
	wire_n0011l_dataout <= wire_n00Oil_tlcfgctl(25) WHEN n11Oii = '1'  ELSE n1l0iO;
	wire_n0011O_dataout <= wire_n00Oil_tlcfgctl(26) WHEN n11Oii = '1'  ELSE n1l0il;
	wire_n001ii_dataout <= wire_n00Oil_tlcfgctl(30) WHEN n11Oii = '1'  ELSE n1l00i;
	wire_n001il_dataout <= wire_n00Oil_tlcfgctl(31) WHEN n11Oii = '1'  ELSE n1l01O;
	wire_n001iO_dataout <= wire_n00Oil_tlcfgadd(0) WHEN n11Oii = '1'  ELSE n1l01l;
	wire_n001li_dataout <= wire_n00Oil_tlcfgadd(1) WHEN n11Oii = '1'  ELSE n1l01i;
	wire_n001ll_dataout <= wire_n00Oil_tlcfgadd(2) WHEN n11Oii = '1'  ELSE n1l1OO;
	wire_n001lO_dataout <= wire_n00Oil_tlcfgadd(3) WHEN n11Oii = '1'  ELSE n1l1Ol;
	wire_n001Ol_dataout <= wire_n00Oil_tlcfgsts(0) WHEN n11Oli = '1'  ELSE n1O0Oi;
	wire_n001OO_dataout <= wire_n00Oil_tlcfgsts(1) WHEN n11Oli = '1'  ELSE n1O0lO;
	wire_n00i0i_dataout <= wire_n00Oil_tlcfgsts(20) WHEN n11Oli = '1'  ELSE n1O1il;
	wire_n00i0l_dataout <= wire_n00Oil_tlcfgsts(21) WHEN n11Oli = '1'  ELSE n1O1ii;
	wire_n00i0O_dataout <= wire_n00Oil_tlcfgsts(22) WHEN n11Oli = '1'  ELSE n1O10O;
	wire_n00i1i_dataout <= wire_n00Oil_tlcfgsts(17) WHEN n11Oli = '1'  ELSE n1O1ll;
	wire_n00i1l_dataout <= wire_n00Oil_tlcfgsts(18) WHEN n11Oli = '1'  ELSE n1O1li;
	wire_n00i1O_dataout <= wire_n00Oil_tlcfgsts(19) WHEN n11Oli = '1'  ELSE n1O1iO;
	wire_n00iii_dataout <= wire_n00Oil_tlcfgsts(23) WHEN n11Oli = '1'  ELSE n1O10l;
	wire_n00iil_dataout <= wire_n00Oil_tlcfgsts(24) WHEN n11Oli = '1'  ELSE n1O10i;
	wire_n00iiO_dataout <= wire_n00Oil_tlcfgsts(25) WHEN n11Oli = '1'  ELSE n1O11O;
	wire_n00ili_dataout <= wire_n00Oil_tlcfgsts(26) WHEN n11Oli = '1'  ELSE n1O11l;
	wire_n00ill_dataout <= wire_n00Oil_tlcfgsts(27) WHEN n11Oli = '1'  ELSE n1O11i;
	wire_n00ilO_dataout <= wire_n00Oil_tlcfgsts(28) WHEN n11Oli = '1'  ELSE n1lOOO;
	wire_n00iOi_dataout <= wire_n00Oil_tlcfgsts(29) WHEN n11Oli = '1'  ELSE n1lOOl;
	wire_n00iOl_dataout <= wire_n00Oil_tlcfgsts(30) WHEN n11Oli = '1'  ELSE n1lOOi;
	wire_n00iOO_dataout <= wire_n00Oil_tlcfgsts(31) WHEN n11Oli = '1'  ELSE n1lOlO;
	wire_n00l0i_dataout <= wire_n00Oil_tlcfgsts(35) WHEN n11Oli = '1'  ELSE n1lOil;
	wire_n00l0l_dataout <= wire_n00Oil_tlcfgsts(36) WHEN n11Oli = '1'  ELSE n1lOii;
	wire_n00l0O_dataout <= wire_n00Oil_tlcfgsts(37) WHEN n11Oli = '1'  ELSE n1lO0O;
	wire_n00l1i_dataout <= wire_n00Oil_tlcfgsts(32) WHEN n11Oli = '1'  ELSE n1lOll;
	wire_n00l1l_dataout <= wire_n00Oil_tlcfgsts(33) WHEN n11Oli = '1'  ELSE n1lOli;
	wire_n00l1O_dataout <= wire_n00Oil_tlcfgsts(34) WHEN n11Oli = '1'  ELSE n1lOiO;
	wire_n00lii_dataout <= wire_n00Oil_tlcfgsts(38) WHEN n11Oli = '1'  ELSE n1lO0l;
	wire_n00lil_dataout <= wire_n00Oil_tlcfgsts(39) WHEN n11Oli = '1'  ELSE n1lO0i;
	wire_n00liO_dataout <= wire_n00Oil_tlcfgsts(40) WHEN n11Oli = '1'  ELSE n1lO1O;
	wire_n00lli_dataout <= wire_n00Oil_tlcfgsts(41) WHEN n11Oli = '1'  ELSE n1lO1l;
	wire_n00lll_dataout <= wire_n00Oil_tlcfgsts(42) WHEN n11Oli = '1'  ELSE n1lO1i;
	wire_n00llO_dataout <= wire_n00Oil_tlcfgsts(43) WHEN n11Oli = '1'  ELSE n1llOO;
	wire_n00lOi_dataout <= wire_n00Oil_tlcfgsts(44) WHEN n11Oli = '1'  ELSE n1llOl;
	wire_n00lOl_dataout <= wire_n00Oil_tlcfgsts(45) WHEN n11Oli = '1'  ELSE n1llOi;
	wire_n00lOO_dataout <= wire_n00Oil_tlcfgsts(46) WHEN n11Oli = '1'  ELSE n1lllO;
	wire_n00O0i_dataout <= wire_n00Oil_tlcfgsts(50) WHEN n11Oli = '1'  ELSE n1llil;
	wire_n00O0l_dataout <= wire_n00Oil_tlcfgsts(51) WHEN n11Oli = '1'  ELSE n1llii;
	wire_n00O0O_dataout <= wire_n00Oil_tlcfgsts(52) WHEN n11Oli = '1'  ELSE n1ll0O;
	wire_n00O1i_dataout <= wire_n00Oil_tlcfgsts(47) WHEN n11Oli = '1'  ELSE n1llll;
	wire_n00O1l_dataout <= wire_n00Oil_tlcfgsts(48) WHEN n11Oli = '1'  ELSE n1llli;
	wire_n00O1O_dataout <= wire_n00Oil_tlcfgsts(49) WHEN n11Oli = '1'  ELSE n1lliO;
	wire_n0100i_dataout <= wire_n01lli_dataout AND NOT(srst);
	wire_n0100l_dataout <= wire_n01lll_dataout AND NOT(srst);
	wire_n0100O_dataout <= wire_n01llO_dataout AND NOT(srst);
	wire_n0101i_dataout <= wire_n01lii_dataout AND NOT(srst);
	wire_n0101l_dataout <= wire_n01lil_dataout AND NOT(srst);
	wire_n0101O_dataout <= wire_n01liO_dataout AND NOT(srst);
	wire_n010ii_dataout <= wire_n01lOi_dataout AND NOT(srst);
	wire_n010il_dataout <= wire_n01lOl_dataout AND NOT(srst);
	wire_n010iO_dataout <= wire_n01lOO_dataout AND NOT(srst);
	wire_n010li_dataout <= wire_n01O1i_dataout AND NOT(srst);
	wire_n010ll_dataout <= wire_n01O1l_dataout AND NOT(srst);
	wire_n010lO_dataout <= wire_n01O1O_dataout AND NOT(srst);
	wire_n010Oi_dataout <= wire_n01O0i_dataout AND NOT(srst);
	wire_n010Ol_dataout <= wire_n01O0l_dataout AND NOT(srst);
	wire_n010OO_dataout <= wire_n01O0O_dataout AND NOT(srst);
	wire_n0110i_dataout <= wire_n00lll_dataout AND NOT(srst);
	wire_n0110l_dataout <= wire_n00llO_dataout AND NOT(srst);
	wire_n0110O_dataout <= wire_n00lOi_dataout AND NOT(srst);
	wire_n0111i_dataout <= wire_n00lil_dataout AND NOT(srst);
	wire_n0111l_dataout <= wire_n00liO_dataout AND NOT(srst);
	wire_n0111O_dataout <= wire_n00lli_dataout AND NOT(srst);
	wire_n011ii_dataout <= wire_n00lOl_dataout AND NOT(srst);
	wire_n011il_dataout <= wire_n00lOO_dataout AND NOT(srst);
	wire_n011iO_dataout <= wire_n00O1i_dataout AND NOT(srst);
	wire_n011li_dataout <= wire_n00O1l_dataout AND NOT(srst);
	wire_n011ll_dataout <= wire_n00O1O_dataout AND NOT(srst);
	wire_n011lO_dataout <= wire_n00O0i_dataout AND NOT(srst);
	wire_n011Oi_dataout <= wire_n00O0l_dataout AND NOT(srst);
	wire_n011Ol_dataout <= wire_n00O0O_dataout AND NOT(srst);
	wire_n011OO_dataout <= n1Oi0l AND NOT(srst);
	wire_n01i0i_dataout <= wire_n01Oli_dataout AND NOT(srst);
	wire_n01i0l_dataout <= wire_n01Oll_dataout AND NOT(srst);
	wire_n01i0O_dataout <= wire_n01OlO_dataout AND NOT(srst);
	wire_n01i1i_dataout <= wire_n01Oii_dataout AND NOT(srst);
	wire_n01i1l_dataout <= wire_n01Oil_dataout AND NOT(srst);
	wire_n01i1O_dataout <= wire_n01OiO_dataout AND NOT(srst);
	wire_n01iii_dataout <= wire_n01OOi_dataout AND NOT(srst);
	wire_n01iil_dataout <= wire_n01OOl_dataout AND NOT(srst);
	wire_n01iiO_dataout <= wire_n01OOO_dataout AND NOT(srst);
	wire_n01ili_dataout <= wire_n0011i_dataout AND NOT(srst);
	wire_n01ill_dataout <= wire_n0011l_dataout AND NOT(srst);
	wire_n01ilO_dataout <= wire_n0011O_dataout AND NOT(srst);
	wire_n01iOi_dataout <= wire_n0010i_dataout AND NOT(srst);
	wire_n01iOl_dataout <= wire_n0010l_dataout AND NOT(srst);
	wire_n01iOO_dataout <= wire_n0010O_dataout AND NOT(srst);
	wire_n01l0i_dataout <= wire_n001li_dataout AND NOT(srst);
	wire_n01l0l_dataout <= wire_n001ll_dataout AND NOT(srst);
	wire_n01l0O_dataout <= wire_n001lO_dataout AND NOT(srst);
	wire_n01l1i_dataout <= wire_n001ii_dataout AND NOT(srst);
	wire_n01l1l_dataout <= wire_n001il_dataout AND NOT(srst);
	wire_n01l1O_dataout <= wire_n001iO_dataout AND NOT(srst);
	wire_n01lii_dataout <= wire_n00Oil_tlcfgctl(0) WHEN n11Oii = '1'  ELSE n1ll0i;
	wire_n01lil_dataout <= wire_n00Oil_tlcfgctl(1) WHEN n11Oii = '1'  ELSE n1ll1O;
	wire_n01liO_dataout <= wire_n00Oil_tlcfgctl(2) WHEN n11Oii = '1'  ELSE n1ll1l;
	wire_n01lli_dataout <= wire_n00Oil_tlcfgctl(3) WHEN n11Oii = '1'  ELSE n1ll1i;
	wire_n01lll_dataout <= wire_n00Oil_tlcfgctl(4) WHEN n11Oii = '1'  ELSE n1liOO;
	wire_n01llO_dataout <= wire_n00Oil_tlcfgctl(5) WHEN n11Oii = '1'  ELSE n1liOl;
	wire_n01lOi_dataout <= wire_n00Oil_tlcfgctl(6) WHEN n11Oii = '1'  ELSE n1liOi;
	wire_n01lOl_dataout <= wire_n00Oil_tlcfgctl(7) WHEN n11Oii = '1'  ELSE n1lilO;
	wire_n01lOO_dataout <= wire_n00Oil_tlcfgctl(8) WHEN n11Oii = '1'  ELSE n1lill;
	wire_n01O0i_dataout <= wire_n00Oil_tlcfgctl(12) WHEN n11Oii = '1'  ELSE n1liii;
	wire_n01O0l_dataout <= wire_n00Oil_tlcfgctl(13) WHEN n11Oii = '1'  ELSE n1li0O;
	wire_n01O0O_dataout <= wire_n00Oil_tlcfgctl(14) WHEN n11Oii = '1'  ELSE n1li0l;
	wire_n01O1i_dataout <= wire_n00Oil_tlcfgctl(9) WHEN n11Oii = '1'  ELSE n1lili;
	wire_n01O1l_dataout <= wire_n00Oil_tlcfgctl(10) WHEN n11Oii = '1'  ELSE n1liiO;
	wire_n01O1O_dataout <= wire_n00Oil_tlcfgctl(11) WHEN n11Oii = '1'  ELSE n1liil;
	wire_n01Oii_dataout <= wire_n00Oil_tlcfgctl(15) WHEN n11Oii = '1'  ELSE n1li0i;
	wire_n01Oil_dataout <= wire_n00Oil_tlcfgctl(16) WHEN n11Oii = '1'  ELSE n1li1O;
	wire_n01OiO_dataout <= wire_n00Oil_tlcfgctl(17) WHEN n11Oii = '1'  ELSE n1li1l;
	wire_n01Oli_dataout <= wire_n00Oil_tlcfgctl(18) WHEN n11Oii = '1'  ELSE n1li1i;
	wire_n01Oll_dataout <= wire_n00Oil_tlcfgctl(19) WHEN n11Oii = '1'  ELSE n1l0OO;
	wire_n01OlO_dataout <= wire_n00Oil_tlcfgctl(20) WHEN n11Oii = '1'  ELSE n1l0Ol;
	wire_n01OOi_dataout <= wire_n00Oil_tlcfgctl(21) WHEN n11Oii = '1'  ELSE n1l0Oi;
	wire_n01OOl_dataout <= wire_n00Oil_tlcfgctl(22) WHEN n11Oii = '1'  ELSE n1l0lO;
	wire_n01OOO_dataout <= wire_n00Oil_tlcfgctl(23) WHEN n11Oii = '1'  ELSE n1l0ll;
	wire_n1000i_dataout <= wire_n100Oi_o(9) WHEN n1100l = '1'  ELSE wire_n100li_dataout;
	wire_n1000i_w_lg_dataout3878w(0) <= NOT wire_n1000i_dataout;
	wire_n1000l_dataout <= wire_n100Oi_o(10) WHEN n1100l = '1'  ELSE wire_n100li_dataout;
	wire_n1000l_w_lg_dataout3876w(0) <= NOT wire_n1000l_dataout;
	wire_n1000O_dataout <= wire_n100Oi_o(11) WHEN n1100l = '1'  ELSE wire_n100li_dataout;
	wire_n1000O_w_lg_dataout3875w(0) <= NOT wire_n1000O_dataout;
	wire_n1001i_dataout <= wire_n100Oi_o(6) WHEN n1100l = '1'  ELSE wire_n100li_dataout;
	wire_n1001i_w_lg_dataout3884w(0) <= NOT wire_n1001i_dataout;
	wire_n1001l_dataout <= wire_n100Oi_o(7) WHEN n1100l = '1'  ELSE wire_n100li_dataout;
	wire_n1001l_w_lg_dataout3882w(0) <= NOT wire_n1001l_dataout;
	wire_n1001O_dataout <= wire_n100Oi_o(8) WHEN n1100l = '1'  ELSE wire_n100li_dataout;
	wire_n1001O_w_lg_dataout3880w(0) <= NOT wire_n1001O_dataout;
	wire_n100ii_dataout <= wire_n100ll_o(1) AND wire_n100lO_o;
	wire_n100il_dataout <= wire_n100ll_o(2) AND wire_n100lO_o;
	wire_n100iO_dataout <= wire_n100ll_o(3) AND wire_n100lO_o;
	wire_n100li_dataout <= wire_n100ll_o(4) AND wire_n100lO_o;
	wire_n100OO_dataout <= wire_n10iOl_o(0) WHEN n1100O = '1'  ELSE wire_n10iil_dataout;
	wire_n100OO_w_lg_dataout3873w(0) <= NOT wire_n100OO_dataout;
	wire_n101li_dataout <= wire_n100Oi_o(0) WHEN n1100l = '1'  ELSE wire_n100ii_dataout;
	wire_n101li_w_lg_dataout3896w(0) <= NOT wire_n101li_dataout;
	wire_n101ll_dataout <= wire_n100Oi_o(1) WHEN n1100l = '1'  ELSE wire_n100il_dataout;
	wire_n101ll_w_lg_dataout3894w(0) <= NOT wire_n101ll_dataout;
	wire_n101lO_dataout <= wire_n100Oi_o(2) WHEN n1100l = '1'  ELSE wire_n100iO_dataout;
	wire_n101lO_w_lg_dataout3892w(0) <= NOT wire_n101lO_dataout;
	wire_n101Oi_dataout <= wire_n100Oi_o(3) WHEN n1100l = '1'  ELSE wire_n100li_dataout;
	wire_n101Oi_w_lg_dataout3890w(0) <= NOT wire_n101Oi_dataout;
	wire_n101Ol_dataout <= wire_n100Oi_o(4) WHEN n1100l = '1'  ELSE wire_n100li_dataout;
	wire_n101Ol_w_lg_dataout3888w(0) <= NOT wire_n101Ol_dataout;
	wire_n101OO_dataout <= wire_n100Oi_o(5) WHEN n1100l = '1'  ELSE wire_n100li_dataout;
	wire_n101OO_w_lg_dataout3886w(0) <= NOT wire_n101OO_dataout;
	wire_n10i0i_dataout <= wire_n10iOl_o(4) WHEN n1100O = '1'  ELSE wire_n10ill_dataout;
	wire_n10i0i_w_lg_dataout3865w(0) <= NOT wire_n10i0i_dataout;
	wire_n10i0l_dataout <= wire_n10iOl_o(5) WHEN n1100O = '1'  ELSE wire_n10ill_dataout;
	wire_n10i0l_w_lg_dataout3863w(0) <= NOT wire_n10i0l_dataout;
	wire_n10i0O_dataout <= wire_n10iOl_o(6) WHEN n1100O = '1'  ELSE wire_n10ill_dataout;
	wire_n10i0O_w_lg_dataout3861w(0) <= NOT wire_n10i0O_dataout;
	wire_n10i1i_dataout <= wire_n10iOl_o(1) WHEN n1100O = '1'  ELSE wire_n10iiO_dataout;
	wire_n10i1i_w_lg_dataout3871w(0) <= NOT wire_n10i1i_dataout;
	wire_n10i1l_dataout <= wire_n10iOl_o(2) WHEN n1100O = '1'  ELSE wire_n10ili_dataout;
	wire_n10i1l_w_lg_dataout3869w(0) <= NOT wire_n10i1l_dataout;
	wire_n10i1O_dataout <= wire_n10iOl_o(3) WHEN n1100O = '1'  ELSE wire_n10ill_dataout;
	wire_n10i1O_w_lg_dataout3867w(0) <= NOT wire_n10i1O_dataout;
	wire_n10iii_dataout <= wire_n10iOl_o(7) WHEN n1100O = '1'  ELSE wire_n10ill_dataout;
	wire_n10iii_w_lg_dataout3860w(0) <= NOT wire_n10iii_dataout;
	wire_n10iil_dataout <= wire_n10ilO_o(1) AND wire_n10iOi_o;
	wire_n10iiO_dataout <= wire_n10ilO_o(2) AND wire_n10iOi_o;
	wire_n10ili_dataout <= wire_n10ilO_o(3) AND wire_n10iOi_o;
	wire_n10ill_dataout <= wire_n10ilO_o(4) AND wire_n10iOi_o;
	wire_n1i00i_dataout <= wire_n1iiOO_dataout AND NOT(srst);
	wire_n1i00l_dataout <= wire_n1il1i_dataout AND NOT(srst);
	wire_n1i00O_dataout <= wire_n1il1l_dataout AND NOT(srst);
	wire_n1i01i_dataout <= wire_n1iilO_dataout AND NOT(srst);
	wire_n1i01l_dataout <= wire_n1iiOi_dataout AND NOT(srst);
	wire_n1i01O_dataout <= wire_n1iiOl_dataout AND NOT(srst);
	wire_n1i0ii_dataout <= wire_n1il1O_dataout AND NOT(srst);
	wire_n1i0il_dataout <= wire_n1il0i_dataout AND NOT(srst);
	wire_n1i0iO_dataout <= wire_n1il0l_dataout AND NOT(srst);
	wire_n1i0li_dataout <= wire_n1il0O_dataout AND NOT(srst);
	wire_n1i0ll_dataout <= wire_n1l11i_dataout AND NOT(srst);
	wire_n1i0lO_dataout <= wire_n1ilil_dataout AND NOT(srst);
	wire_n1i0Oi_dataout <= wire_n1iliO_dataout AND NOT(srst);
	wire_n1i0Ol_dataout <= wire_n1illi_dataout AND NOT(srst);
	wire_n1i0OO_dataout <= wire_n1illl_dataout AND NOT(srst);
	wire_n1i10O_dataout <= wire_n1iOil_dataout AND NOT(srst);
	wire_n1i1ii_dataout <= wire_n1iOiO_dataout AND NOT(srst);
	wire_n1i1il_dataout <= (((wire_n1l11i_dataout AND n110OO) AND (n110Oi42 XOR n110Oi41)) OR n10l0i) AND NOT(srst);
	wire_n1i1iO_dataout <= (wire_n1l11l_w_lg_w_lg_w_lg_dataout3576w3579w3580w(0) OR (NOT (n11i1i40 XOR n11i1i39))) AND NOT(srst);
	wire_n1i1li_dataout <= wire_n1iO1l_dataout AND NOT(srst);
	wire_n1i1ll_dataout <= wire_n1iO0l_dataout AND NOT(srst);
	wire_n1i1lO_dataout <= wire_n1iO1O_dataout OR srst;
	wire_n1i1Oi_dataout <= wire_n1iO0O_dataout OR srst;
	wire_n1i1Ol_dataout <= wire_n1iili_dataout AND NOT(srst);
	wire_n1i1OO_dataout <= wire_n1iill_dataout AND NOT(srst);
	wire_n1ii0i_dataout <= wire_n1ilOO_dataout AND NOT(srst);
	wire_n1ii0l_dataout <= wire_n1l11l_dataout AND NOT(srst);
	wire_n1ii1i_dataout <= wire_n1illO_dataout AND NOT(srst);
	wire_n1ii1l_dataout <= wire_n1ilOi_dataout AND NOT(srst);
	wire_n1ii1O_dataout <= wire_n1ilOl_dataout AND NOT(srst);
	wire_n1iili_dataout <= wire_n1ilii_o(0) WHEN n10OiO = '1'  ELSE n10llO;
	wire_n1iill_dataout <= wire_n1ilii_o(1) WHEN n10OiO = '1'  ELSE n10lOi;
	wire_n1iilO_dataout <= wire_n1ilii_o(2) WHEN n10OiO = '1'  ELSE n10lOl;
	wire_n1iiOi_dataout <= wire_n1ilii_o(3) WHEN n10OiO = '1'  ELSE n10lOO;
	wire_n1iiOl_dataout <= wire_n1ilii_o(4) WHEN n10OiO = '1'  ELSE n10O1i;
	wire_n1iiOO_dataout <= wire_n1ilii_o(5) WHEN n10OiO = '1'  ELSE n10O1l;
	wire_n1il0i_dataout <= wire_n1ilii_o(9) WHEN n10OiO = '1'  ELSE n10O0O;
	wire_n1il0l_dataout <= wire_n1ilii_o(10) WHEN n10OiO = '1'  ELSE n10Oii;
	wire_n1il0O_dataout <= wire_n1ilii_o(11) WHEN n10OiO = '1'  ELSE n10Oil;
	wire_n1il1i_dataout <= wire_n1ilii_o(6) WHEN n10OiO = '1'  ELSE n10O1O;
	wire_n1il1l_dataout <= wire_n1ilii_o(7) WHEN n10OiO = '1'  ELSE n10O0i;
	wire_n1il1O_dataout <= wire_n1ilii_o(8) WHEN n10OiO = '1'  ELSE n10O0l;
	wire_n1ilil_dataout <= wire_n1iO1i_o(0) WHEN n1i10i = '1'  ELSE n10Oli;
	wire_n1iliO_dataout <= wire_n1iO1i_o(1) WHEN n1i10i = '1'  ELSE n10Oll;
	wire_n1illi_dataout <= wire_n1iO1i_o(2) WHEN n1i10i = '1'  ELSE n10OlO;
	wire_n1illl_dataout <= wire_n1iO1i_o(3) WHEN n1i10i = '1'  ELSE n10OOi;
	wire_n1illO_dataout <= wire_n1iO1i_o(4) WHEN n1i10i = '1'  ELSE n10OOl;
	wire_n1ilOi_dataout <= wire_n1iO1i_o(5) WHEN n1i10i = '1'  ELSE n10OOO;
	wire_n1ilOl_dataout <= wire_n1iO1i_o(6) WHEN n1i10i = '1'  ELSE n1i11i;
	wire_n1ilOO_dataout <= wire_n1iO1i_o(7) WHEN n1i10i = '1'  ELSE n1i11l;
	wire_n1iO0l_dataout <= ((wire_n00Oil_w_lg_w_txcredvc0_range1458w3465w(0) AND (NOT wire_n00Oil_txcredvc0(17))) AND (n11iil32 XOR n11iil31)) WHEN n10lll = '1'  ELSE n10lil;
	wire_n1iO0O_dataout <= wire_n1iOii_w_lg_o3463w(0) AND n10lll;
	wire_n1iO1l_dataout <= (wire_n00Oil_w_lg_w_txcredvc0_range1467w3487w(0) AND (NOT wire_n00Oil_txcredvc0(20))) WHEN n10liO = '1'  ELSE n10lii;
	wire_n1iO1O_dataout <= wire_n1iO0i_w_lg_o3485w(0) AND n10liO;
	wire_n1iOil_dataout <= wire_n1iOli_dataout AND NOT(n11iOi);
	wire_n1iOiO_dataout <= wire_n1iOll_dataout AND NOT(n11iOi);
	wire_n1iOli_dataout <= (n11lil AND (wire_w_lg_w_tx_st_data0_range2026w3445w(0) AND (n11ill28 XOR n11ill27))) WHEN n11lii = '1'  ELSE n10l0l;
	wire_n1iOll_dataout <= n11lil WHEN n11lii = '1'  ELSE n10l1O;
	wire_n1l11i_dataout <= n10l0l AND n11l1l;
	wire_n1l11l_dataout <= n10l1O AND n11l1l;
	wire_n1l11l_w_lg_w_lg_dataout3576w3579w(0) <= wire_n1l11l_w_lg_dataout3576w(0) AND wire_n11i1O38_w_lg_q3578w(0);
	wire_n1l11l_w_lg_dataout3576w(0) <= wire_n1l11l_dataout AND n11i0l;
	wire_n1l11l_w_lg_w_lg_w_lg_dataout3576w3579w3580w(0) <= wire_n1l11l_w_lg_w_lg_dataout3576w3579w(0) OR n10l0O;
	wire_n1Oi0O_dataout <= n1Oi1l AND NOT(srst);
	wire_n1Oiii_dataout <= wire_n001Ol_dataout AND NOT(srst);
	wire_n1Oiil_dataout <= wire_n001OO_dataout AND NOT(srst);
	wire_n1OiiO_dataout <= wire_n0001i_dataout AND NOT(srst);
	wire_n1Oili_dataout <= wire_n0001l_dataout AND NOT(srst);
	wire_n1Oill_dataout <= wire_n0001O_dataout AND NOT(srst);
	wire_n1OilO_dataout <= wire_n0000i_dataout AND NOT(srst);
	wire_n1OiOi_dataout <= wire_n0000l_dataout AND NOT(srst);
	wire_n1OiOl_dataout <= wire_n0000O_dataout AND NOT(srst);
	wire_n1OiOO_dataout <= wire_n000ii_dataout AND NOT(srst);
	wire_n1Ol0i_dataout <= wire_n000ll_dataout AND NOT(srst);
	wire_n1Ol0l_dataout <= wire_n000lO_dataout AND NOT(srst);
	wire_n1Ol0O_dataout <= wire_n000Oi_dataout AND NOT(srst);
	wire_n1Ol1i_dataout <= wire_n000il_dataout AND NOT(srst);
	wire_n1Ol1l_dataout <= wire_n000iO_dataout AND NOT(srst);
	wire_n1Ol1O_dataout <= wire_n000li_dataout AND NOT(srst);
	wire_n1Olii_dataout <= wire_n000Ol_dataout AND NOT(srst);
	wire_n1Olil_dataout <= wire_n000OO_dataout AND NOT(srst);
	wire_n1OliO_dataout <= wire_n00i1i_dataout AND NOT(srst);
	wire_n1Olli_dataout <= wire_n00i1l_dataout AND NOT(srst);
	wire_n1Olll_dataout <= wire_n00i1O_dataout AND NOT(srst);
	wire_n1OllO_dataout <= wire_n00i0i_dataout AND NOT(srst);
	wire_n1OlOi_dataout <= wire_n00i0l_dataout AND NOT(srst);
	wire_n1OlOl_dataout <= wire_n00i0O_dataout AND NOT(srst);
	wire_n1OlOO_dataout <= wire_n00iii_dataout AND NOT(srst);
	wire_n1OO0i_dataout <= wire_n00ill_dataout AND NOT(srst);
	wire_n1OO0l_dataout <= wire_n00ilO_dataout AND NOT(srst);
	wire_n1OO0O_dataout <= wire_n00iOi_dataout AND NOT(srst);
	wire_n1OO1i_dataout <= wire_n00iil_dataout AND NOT(srst);
	wire_n1OO1l_dataout <= wire_n00iiO_dataout AND NOT(srst);
	wire_n1OO1O_dataout <= wire_n00ili_dataout AND NOT(srst);
	wire_n1OOii_dataout <= wire_n00iOl_dataout AND NOT(srst);
	wire_n1OOil_dataout <= wire_n00iOO_dataout AND NOT(srst);
	wire_n1OOiO_dataout <= wire_n00l1i_dataout AND NOT(srst);
	wire_n1OOli_dataout <= wire_n00l1l_dataout AND NOT(srst);
	wire_n1OOll_dataout <= wire_n00l1O_dataout AND NOT(srst);
	wire_n1OOlO_dataout <= wire_n00l0i_dataout AND NOT(srst);
	wire_n1OOOi_dataout <= wire_n00l0l_dataout AND NOT(srst);
	wire_n1OOOl_dataout <= wire_n00l0O_dataout AND NOT(srst);
	wire_n1OOOO_dataout <= wire_n00lii_dataout AND NOT(srst);
	wire_n100ll_a <= ( "0" & wire_n00Oil_txcredvc0(20 DOWNTO 18) & "1");
	wire_n100ll_b <= ( "1" & "1" & "1" & "0" & "1");
	n100ll :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 5,
		width_b => 5,
		width_o => 5
	  )
	  PORT MAP ( 
		a => wire_n100ll_a,
		b => wire_n100ll_b,
		cin => wire_gnd,
		o => wire_n100ll_o
	  );
	wire_n100Oi_a <= ( wire_n1i11O_w_lg_n10Oil3776w & wire_n1i11O_w_lg_n10Oii3774w & wire_n1i11O_w_lg_n10O0O3772w & wire_n1i11O_w_lg_n10O0l3770w & wire_n1i11O_w_lg_n10O0i3768w & wire_n1i11O_w_lg_n10O1O3766w & wire_n1i11O_w_lg_n10O1l3764w & wire_n1i11O_w_lg_n10O1i3762w & wire_n1i11O_w_lg_n10lOO3760w & wire_n1i11O_w_lg_n10lOl3758w & wire_n1i11O_w_lg_n10lOi3756w & wire_n1i11O_w_lg_n10llO3753w);
	wire_n100Oi_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "1");
	n100Oi :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 12,
		width_b => 12,
		width_o => 12
	  )
	  PORT MAP ( 
		a => wire_n100Oi_a,
		b => wire_n100Oi_b,
		cin => wire_gnd,
		o => wire_n100Oi_o
	  );
	wire_n10ilO_a <= ( "0" & wire_n00Oil_txcredvc0(17 DOWNTO 15) & "1");
	wire_n10ilO_b <= ( "1" & "1" & "1" & "0" & "1");
	n10ilO :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 5,
		width_b => 5,
		width_o => 5
	  )
	  PORT MAP ( 
		a => wire_n10ilO_a,
		b => wire_n10ilO_b,
		cin => wire_gnd,
		o => wire_n10ilO_o
	  );
	wire_n10iOl_a <= ( wire_n1i11O_w_lg_n1i11l3684w & wire_n1i11O_w_lg_n1i11i3682w & wire_n1i11O_w_lg_n10OOO3680w & wire_n1i11O_w_lg_n10OOl3678w & wire_n1i11O_w_lg_n10OOi3676w & wire_n1i11O_w_lg_n10OlO3674w & wire_n1i11O_w_lg_n10Oll3672w & wire_n1i11O_w_lg_n10Oli3669w);
	wire_n10iOl_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "1");
	n10iOl :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 8,
		width_b => 8,
		width_o => 8
	  )
	  PORT MAP ( 
		a => wire_n10iOl_a,
		b => wire_n10iOl_b,
		cin => wire_gnd,
		o => wire_n10iOl_o
	  );
	wire_n1ilii_a <= ( n10Oil & n10Oii & n10O0O & n10O0l & n10O0i & n10O1O & n10O1l & n10O1i & n10lOO & n10lOl & n10lOi & n10llO);
	wire_n1ilii_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "1");
	n1ilii :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 12,
		width_b => 12,
		width_o => 12
	  )
	  PORT MAP ( 
		a => wire_n1ilii_a,
		b => wire_n1ilii_b,
		cin => wire_gnd,
		o => wire_n1ilii_o
	  );
	wire_n1iO1i_a <= ( wire_n11i0O36_w_lg_w_lg_q3498w3499w & n1i11i & n10OOO & n10OOl & n10OOi & n10OlO & n10Oll & n10Oli);
	wire_n1iO1i_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "1");
	n1iO1i :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 8,
		width_b => 8,
		width_o => 8
	  )
	  PORT MAP ( 
		a => wire_n1iO1i_a,
		b => wire_n1iO1i_b,
		cin => wire_gnd,
		o => wire_n1iO1i_o
	  );
	wire_n100lO_a <= ( "0" & "0" & "1");
	wire_n100lO_b <= ( wire_n00Oil_txcredvc0(20 DOWNTO 18));
	n100lO :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 3,
		width_b => 3
	  )
	  PORT MAP ( 
		a => wire_n100lO_a,
		b => wire_n100lO_b,
		cin => wire_gnd,
		o => wire_n100lO_o
	  );
	wire_n10iOi_a <= ( "0" & "0" & "1");
	wire_n10iOi_b <= ( wire_n00Oil_txcredvc0(17 DOWNTO 15));
	n10iOi :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 3,
		width_b => 3
	  )
	  PORT MAP ( 
		a => wire_n10iOi_a,
		b => wire_n10iOi_b,
		cin => wire_gnd,
		o => wire_n10iOi_o
	  );
	wire_n10l1i_a <= ( "0" & "1" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n10l1i_b <= ( n10Oil & n10Oii & n10O0O & n10O0l & n10O0i & n10O1O & n10O1l & wire_n110ii54_w_lg_w_lg_q3655w3656w & wire_n110il52_w_lg_w_lg_q3652w3653w & n10lOl & n10lOi & n10llO);
	n10l1i :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 12,
		width_b => 12
	  )
	  PORT MAP ( 
		a => wire_n10l1i_a,
		b => wire_n10l1i_b,
		cin => wire_gnd,
		o => wire_n10l1i_o
	  );
	wire_n10l1l_a <= ( "0" & "1" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n10l1l_b <= ( wire_n110iO50_w_lg_w_lg_q3620w3621w & n1i11i & n10OOO & wire_n110li48_w_lg_w_lg_q3615w3616w & n10OOi & n10OlO & n10Oll & n10Oli);
	n10l1l :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 8,
		width_b => 8
	  )
	  PORT MAP ( 
		a => wire_n10l1l_a,
		b => wire_n10l1l_b,
		cin => wire_gnd,
		o => wire_n10l1l_o
	  );
	wire_n1iO0i_w_lg_o3485w(0) <= NOT wire_n1iO0i_o;
	wire_n1iO0i_a <= ( "0" & "0" & "0");
	wire_n1iO0i_b <= ( wire_n00Oil_txcredvc0(20 DOWNTO 19) & wire_n11iii34_w_lg_w_lg_q3478w3479w);
	n1iO0i :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 3,
		width_b => 3
	  )
	  PORT MAP ( 
		a => wire_n1iO0i_a,
		b => wire_n1iO0i_b,
		cin => wire_gnd,
		o => wire_n1iO0i_o
	  );
	wire_n1iOii_w_lg_o3463w(0) <= NOT wire_n1iOii_o;
	wire_n1iOii_a <= ( "0" & "0" & "0");
	wire_n1iOii_b <= ( wire_n00Oil_txcredvc0(17) & wire_n11ili30_w_lg_w_lg_q3459w3460w & wire_n00Oil_txcredvc0(15));
	n1iOii :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 3,
		width_b => 3
	  )
	  PORT MAP ( 
		a => wire_n1iOii_a,
		b => wire_n1iOii_b,
		cin => wire_gnd,
		o => wire_n1iOii_o
	  );

 END RTL; --Hard_IP_x4_core
--synopsys translate_on
--VALID FILE
