--------------------------------------------------------------------------------
-- Title         : DMA for VME Interface
-- Project       : 16z002-01
--------------------------------------------------------------------------------
-- File          : dma.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 24/06/03
--------------------------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
--------------------------------------------------------------------------------
-- Description :
--
-- The vme core has a DMA controller for high performance data transfers between 
-- the SRAM, PCI space and VMEbus. It is operated through a series of registers 
-- that control the source/destination for the data, length of the transfer and 
-- the transfer protocol (A24 or A32) to be used. These registers are not 
-- directly  accessible, but they will be loaded with the content of the Buffer 
-- Descriptor(s) located in the local SRAM.
-- One buffer descriptor may be linked to the next buffer descriptor, such that 
-- when the DMA has completed the operations described by one buffer descriptor, 
-- it automatically moves on to the next buffer descriptor in the local SRAM 
-- list. The last buffer descriptor is reached, when the DMA_NULL bit is set in 
-- the corresponding buffer descriptor. The maximum number of linked buffer 
-- descriptors is 112.
-- The DMA supports interrupt assertion when all specified buffer descriptors 
-- are processed (signaled via dma_irq to PCIe, see DMA_IEN).
-- The DMA controller is able to transfer data from the SRAM, PCI space and 
-- VMEbus to each other. For this reason source and/or destination address can 
-- be incremented or not – depending on the settings. The source and destination 
-- address must be 8-byte aligned to each other.
-- The scatter-gather list is located in the local SRAM area, so a DMA can also 
-- be initiated by an external VME master by accessing the SRAM via A24/A32 
-- slave and the DMA Status Register via A16 slave. 
-- If transfers to PCI space has to be done, the used memory space must be 
-- allocated for this function in order to prevent data mismatch!
-- If DMA functionality is used, the entire local SRAM cannot be used by other 
-- functions, because the buffer descriptors are located at the end of this!
--------------------------------------------------------------------------------
-- Hierarchy:
--
-- wbb2vme
--    vme_dma
--       vme_dma_mstr
--       vme_dma_slv
--       vme_dma_arbiter
--       vme_dma_du
--       vme_dma_au
--       vme_dma_fifo
--          fifo_256x32bit
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
-- $Revision: 1.2 $
--
-- $Log: vme_dma.vhd,v $
-- Revision 1.2  2013/09/12 08:45:30  mmiehling
-- added bit 8 of tga for address modifier extension (supervisory, non-privileged data/program)
--
-- Revision 1.1  2012/03/29 10:14:48  MMiehling
-- Initial Revision
--
-- Revision 1.4  2006/05/18 14:02:16  MMiehling
-- changed comment
--
-- Revision 1.1  2005/10/28 17:52:20  mmiehling
-- Initial Revision
--
-- Revision 1.3  2004/08/13 15:41:08  mmiehling
-- removed dma-slave and improved timing
--
-- Revision 1.2  2004/07/27 17:23:15  mmiehling
-- removed slave port
--
-- Revision 1.1  2004/07/15 09:28:46  MMiehling
-- Initial Revision
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY vme_dma IS
PORT (
   rst           : IN std_logic;
   clk            : IN std_logic;
   irq_o          : OUT std_logic;

   -- vme_du
   dma_sta        : IN std_logic_vector(9 DOWNTO 0);
   clr_dma_en     : OUT std_logic;
   set_dma_err    : OUT std_logic;
   dma_act_bd     : OUT std_logic_vector(7 DOWNTO 4);

   -- wb-slave
   stb_i          : IN std_logic;
   ack_o          : OUT std_logic;
   we_i           : IN std_logic;
   cyc_i          : IN std_logic;
   sel_i          : IN std_logic_vector(3 DOWNTO 0);
   adr_i          : IN std_logic_vector(31 DOWNTO 0);
   slv_dat_i      : IN std_logic_vector(31 DOWNTO 0);
   slv_dat_o      : OUT std_logic_vector(31 DOWNTO 0);
   
   -- wb-master
   stb_o          : OUT std_logic;
   ack_i          : IN std_logic;
   we_o           : OUT std_logic;
   cti            : OUT std_logic_vector(2 DOWNTO 0);
   tga_o          : OUT std_logic_vector(8 DOWNTO 0);      -- type of dma
   err_i          : IN std_logic;
   cyc_o_sram     : OUT std_logic;
   cyc_o_vme      : OUT std_logic;
   cyc_o_pci      : OUT std_logic;
   sel_o          : OUT std_logic_vector(3 DOWNTO 0);
   adr_o          : OUT std_logic_vector(31 DOWNTO 0);
   mstr_dat_o     : OUT std_logic_vector(31 DOWNTO 0);
   mstr_dat_i     : IN std_logic_vector(31 DOWNTO 0)

     );
END vme_dma;

ARCHITECTURE vme_dma_arch OF vme_dma IS 

COMPONENT vme_dma_arbiter 
PORT (
   rst               : IN std_logic;
   clk               : IN std_logic;
   
   -- vme_dma_slv
   slv_req            : IN std_logic;
   slv_ack            : OUT std_logic;
   
   -- vme_dma_mstr
   mstr_req            : IN std_logic;
   mstr_ack            : OUT std_logic;
   
   -- result
   arbit_slv         : OUT std_logic      -- if set, vme_dma_slv has access and vica verse

     );
END COMPONENT;

COMPONENT vme_dma_slv
PORT (
   rst         : IN std_logic;
   clk         : IN std_logic;
   
   stb_i         : IN std_logic;
   ack_o         : OUT std_logic;
   we_i         : IN std_logic;
   cyc_i         : IN std_logic;
   
   slv_req      : OUT std_logic;
   slv_ack      : IN std_logic
     );
END COMPONENT;

COMPONENT vme_dma_au 
PORT (
   rst               : IN std_logic;
   clk               : IN std_logic;
      
   -- wb_signals
   adr_o               : OUT std_logic_vector(31 DOWNTO 0);   -- adress for wb-bus
   sel_o               : OUT std_logic_vector(3 DOWNTO 0);      -- byte enables for wb_bus
   we_o               : OUT std_logic;                        -- write/read
   tga_o               : OUT std_logic_vector(8 DOWNTO 0);      -- type of dma
   cyc_o_sram         : OUT std_logic;                        -- chip select for sram
   cyc_o_pci         : OUT std_logic;                        -- chip select for pci
   cyc_o_vme         : OUT std_logic;                        -- chip select for vme
   stb_o               : IN std_logic;                        -- request signal for cyc switching
   
   -- vme_dma_mstr
   sour_dest         : IN std_logic;                        -- if set, source adress will be used, otherwise destination ad. for adr_o
   inc_adr            : IN std_logic;                        -- flag indicates when adr should be incremented (depend on sour_dest and get_bd)
   get_bd            : IN std_logic;                        -- if set, adress for next bd reading is switched to adr_o
   reached_size      : OUT std_logic;                        -- if all data from one bd was read and stored in the fifo
   load_cnt            : IN std_logic;                        -- after new bd was stored in register, counters must be loaded with new values
   boundary            : OUT std_logic;                        -- indicates 256 byte boundary if D16 or D32 burst
   almost_boundary      : out std_logic;                        -- indicates 256 byte boundary if D16 or D32 burst
   almost_reached_size  : out std_logic;                        -- if all data from one bd was read and stored in the fifo
   clr_dma_act_bd      : IN std_logic;                        -- clears dma_act_bd if dma_mstr has done without error or
                                                            -- when dma_err will be cleared
   
   -- vme_dma_du
   start_dma         : IN std_logic;                        -- flag starts dma-fsm and clears counters
   dma_act_bd         : OUT std_logic_vector(7 DOWNTO 2);      -- [7:3] = active bd number
   dma_dest_adr      : IN std_logic_vector(31 DOWNTO 2);      -- active bd destination adress
   dma_sour_adr      : IN std_logic_vector(31 DOWNTO 2);      -- active bd source adress
   dma_sour_device   : IN std_logic_vector(2 DOWNTO 0);      -- selects the source device
   dma_dest_device   : IN std_logic_vector(2 DOWNTO 0);      -- selects the destination device
   dma_vme_am         : IN std_logic_vector(4 DOWNTO 0);      -- type of dma transmission
   inc_sour            : IN std_logic;                        -- indicates if source adress should be incremented
   inc_dest            : IN std_logic;                        -- indicates if destination adress should be incremented
   dma_size            : IN std_logic_vector(15 DOWNTO 0)      -- size of data package

     );
END COMPONENT;

COMPONENT vme_dma_du 
PORT (
   rst               : IN std_logic;
   clk               : IN std_logic;
   
   dma_sta            : IN std_logic_vector(9 DOWNTO 0);
   irq_o               : OUT std_logic;      -- irq for cpu; asserted when done or error (if enabled)
   
   arbit_slv         : IN std_logic;      -- if set, dma_slv has access and vica verse
   slv_ack            : IN std_logic;      -- if set, write from slave side will be done
   mstr_ack            : IN std_logic;      -- if set, write from master side will be done
   
   -- slave signals
   adr_i               : IN std_logic_vector(6 DOWNTO 2);
   sel_i               : IN std_logic_vector(3 DOWNTO 0);
   slv_dat_i         : IN std_logic_vector(31 DOWNTO 0);
   slv_dat_o         : OUT std_logic_vector(31 DOWNTO 0);
   we_i               : IN std_logic;
   ack_o               : IN std_logic;
   
   -- wb_master singals
   adr_o               : IN std_logic_vector(6 DOWNTO 2);
   mstr_dat_i         : IN std_logic_vector(31 DOWNTO 0);
   
   -- vme_dma_au
   dma_act_bd         : IN std_logic_vector(7 DOWNTO 4);      -- active bd number
   dma_dest_adr      : OUT std_logic_vector(31 DOWNTO 2);   -- active bd destination adress
   dma_sour_adr      : OUT std_logic_vector(31 DOWNTO 2);   -- active bd source adress
   dma_sour_device   : OUT std_logic_vector(2 DOWNTO 0);      -- selects the source device
   dma_dest_device   : OUT std_logic_vector(2 DOWNTO 0);      -- selects the destination device
   dma_vme_am         : OUT std_logic_vector(4 DOWNTO 0);      -- type of dma transmission
   inc_sour            : OUT std_logic;                        -- indicates if source adress should be incremented
   inc_dest            : OUT std_logic;                        -- indicates if destination adress should be incremented
   dma_size            : OUT std_logic_vector(15 DOWNTO 0);   -- size of data package
   clr_dma_act_bd      : OUT std_logic;                        -- clears dma_act_bd if dma_mstr has done without error or
                                                            -- when dma_err will be cleared
   
   -- dma_mstr
--   start_dma         : OUT std_logic;                        -- flag starts dma-fsm and clears counters
   set_dma_err         : IN std_logic;                        -- sets dma error bit if vme error
   clr_dma_en         : IN std_logic;                        -- clears dma en bit if dma_mstr has done
   dma_en            : OUT std_logic;                        -- starts dma_mstr, if 0 => clears dma_act_bd counter
   dma_null            : OUT std_logic;                        -- indicates the last bd   
   en_mstr_dat_i_reg   : IN std_logic                        -- enable for data in

     );
END COMPONENT;

COMPONENT vme_dma_mstr 
PORT (
   rst               : IN std_logic;
   clk               : IN std_logic;
   
   -- wb_master_bus
   stb_o               : OUT std_logic;               -- request for wb_mstr_bus
   ack_i               : IN std_logic;               -- acknoledge from wb_mstr_bus
   err_i               : IN std_logic;               -- error answer from slave
   cti                 : OUT std_logic_vector(2 DOWNTO 0);
   
   -- fifo
   fifo_empty         : IN std_logic;               -- indicates that no more data is available
   fifo_full            : in std_logic;                  -- indicates that no more data can be stored in fifo
   fifo_almost_full   : IN std_logic;               -- indicates that only one data can be stored in the fifo
   fifo_almost_empty  : IN std_logic;              -- indicates that only one data is stored in the fifo
   fifo_wr            : OUT std_logic;               -- if asserted, fifo will be filled with another data
   fifo_rd            : OUT std_logic;               -- if asserted, data will be read out from fifo
   
   -- vme_dma_au
   sour_dest         : OUT std_logic;               -- if set, source adress will be used, otherwise destination ad. for adr_o
   inc_adr            : OUT std_logic;               -- flag indicates when adr should be incremented (depend on sour_dest and get_bd)
   get_bd            : OUT std_logic;               -- if set, adress for next bd reading is switched to adr_o
   reached_size      : IN std_logic;               -- if all data from one bd was read and stored in the fifo
   dma_act_bd         : IN std_logic_vector(7 DOWNTO 2);      -- [7:3] = active bd number
   load_cnt            : OUT std_logic;               -- after new bd was stored in register, counters must be loaded with new values
   boundary            : IN std_logic;                        -- indicates 256 byte boundary if D16 or D32 burst
   almost_boundary      : IN std_logic;                        -- indicates 256 byte boundary if D16 or D32 burst
   almost_reached_size  : IN std_logic;                        -- if all data from one bd was read and stored in the fifo
   we_o_int            : IN std_logic;
   
   -- vme_dma_du
   start_dma         : IN std_logic;               -- flag starts dma-fsm and clears counters
   set_dma_err         : OUT std_logic;               -- sets dma error bit if vme error
   clr_dma_en         : OUT std_logic;               -- clears dma en bit if dma_mstr has done
   dma_en            : IN std_logic;               -- starts dma_mstr, if 0 => clears dma_act_bd counter
   dma_null            : IN std_logic;               -- indicates the last bd   
   en_mstr_dat_i_reg   : OUT std_logic;               -- enable for data in
   inc_sour            : IN std_logic;               -- indicates if source adress should be incremented
   inc_dest            : IN std_logic;               -- indicates if destination adress should be incremented
   
   -- arbiter      
   mstr_req            : OUT std_logic               -- request for internal register access
     );
END COMPONENT;


COMPONENT vme_dma_fifo
PORT (
   rst               : IN std_logic;
   clk               : IN std_logic;
   fifo_clr            : IN std_logic;
   fifo_wr            : IN std_logic;
   fifo_rd            : IN std_logic;
   fifo_dat_i         : IN std_logic_vector(31 DOWNTO 0);
   fifo_dat_o         : OUT std_logic_vector(31 DOWNTO 0);
   fifo_almost_full   : OUT std_logic;
   fifo_almost_empty  : OUT std_logic;
   fifo_full          : OUT std_logic;
   fifo_empty         : OUT std_logic
     );
END COMPONENT;


   -- fifo
   SIGNAL fifo_almost_full   : std_logic;
   SIGNAL fifo_almost_empty  : std_logic;
   SIGNAL fifo_empty         : std_logic;
   SIGNAL fifo_full          : std_logic;
   
   -- slv
   SIGNAL slv_req            : std_logic;
   SIGNAL ack_o_int         : std_logic;
   
   -- arbiter
   SIGNAL slv_ack            : std_logic;
   SIGNAL mstr_ack         : std_logic;
   SIGNAL arbit_slv         : std_logic;
   
   -- mstr
   SIGNAL fifo_wr            : std_logic;
   SIGNAL fifo_rd            : std_logic;
   SIGNAL sour_dest         : std_logic;
   SIGNAL inc_adr            : std_logic;
   SIGNAL get_bd            : std_logic;
   SIGNAL load_cnt         : std_logic;
   SIGNAL set_dma_err_int   : std_logic;
   SIGNAL clr_dma_en_int   : std_logic;
   SIGNAL en_mstr_dat_i_reg: std_logic;
   SIGNAL mstr_req         : std_logic;
   SIGNAL stb_o_int         : std_logic;

   -- du
   SIGNAL dma_dest_adr      : std_logic_vector(31 DOWNTO 2);
   SIGNAL dma_sour_adr      : std_logic_vector(31 DOWNTO 2);
   SIGNAL dma_sour_device   : std_logic_vector(2 DOWNTO 0);
   SIGNAL dma_dest_device   : std_logic_vector(2 DOWNTO 0);
   SIGNAL dma_vme_am         : std_logic_vector(4 DOWNTO 0);
   SIGNAL inc_sour         : std_logic;
   SIGNAL inc_dest         : std_logic;
   SIGNAL dma_size         : std_logic_vector(15 DOWNTO 0);
   SIGNAL start_dma         : std_logic;
   SIGNAL clr_fifo         : std_logic;
   SIGNAL dma_en            : std_logic;
   SIGNAL dma_null         : std_logic;
   SIGNAL clr_dma_act_bd   : std_logic;

   -- au
   SIGNAL adr_o_int         : std_logic_vector(31 DOWNTO 0);
   SIGNAL reached_size      : std_logic;
   SIGNAL almost_reached_size      : std_logic;
   SIGNAL dma_act_bd_int   : std_logic_vector(7 DOWNTO 2);
   SIGNAL boundary         : std_logic;
   SIGNAL almost_boundary         : std_logic;
   SIGNAL we_o_int         : std_logic;

BEGIN
   adr_o <= adr_o_int;
   ack_o <= ack_o_int;
   stb_o <= stb_o_int;
   we_o <= we_o_int;

   clr_dma_en <= clr_dma_en_int;
   set_dma_err <= set_dma_err_int;
   dma_act_bd <= dma_act_bd_int(7 DOWNTO 4);
   clr_fifo <= start_dma;
   start_dma <= dma_sta(8);
   
dma_arb: vme_dma_arbiter 
PORT MAP (
   rst               => rst      ,
   clk               => clk      ,
   slv_req            => slv_req   ,
   slv_ack            => slv_ack   ,
   mstr_req            => mstr_req   ,
   mstr_ack            => mstr_ack   ,
   arbit_slv         => arbit_slv
     );

dma_slv:  vme_dma_slv
PORT MAP (
   rst               => rst      ,
   clk               => clk      ,
   stb_i               => stb_i      ,
   ack_o               => ack_o_int      ,
   we_i               => we_i      ,
   cyc_i               => cyc_i      ,
   slv_req            => slv_req  ,
   slv_ack            => slv_ack  
     );

dma_au: vme_dma_au 
PORT MAP (
   rst               => rst            ,
   clk               => clk            ,
   adr_o               => adr_o_int            ,
   sel_o               => sel_o            ,
   tga_o               => tga_o,
   we_o               => we_o_int            ,
   boundary            => boundary,
   almost_boundary            => almost_boundary,
   cyc_o_sram         => cyc_o_sram      ,
   cyc_o_pci         => cyc_o_pci      ,
   cyc_o_vme         => cyc_o_vme      ,
   stb_o               => stb_o_int,
   clr_dma_act_bd      => clr_dma_act_bd,
   sour_dest         => sour_dest      ,
   inc_adr            => inc_adr         ,
   get_bd            => get_bd         ,
   reached_size      => reached_size   ,
   almost_reached_size      => almost_reached_size   ,
   load_cnt            => load_cnt         ,
   start_dma         => start_dma      ,
   dma_act_bd         => dma_act_bd_int      ,
   dma_dest_adr      => dma_dest_adr   ,
   dma_sour_adr      => dma_sour_adr   ,
   dma_sour_device   => dma_sour_device,
   dma_dest_device   => dma_dest_device,
   dma_vme_am         => dma_vme_am      ,
   inc_sour            => inc_sour         ,
   inc_dest            => inc_dest         ,
   dma_size            => dma_size         
     );

dma_du: vme_dma_du 
PORT MAP (
   rst               => rst               ,
   clk               => clk               ,
   dma_sta            => dma_sta,
   irq_o               => irq_o               ,
   arbit_slv         => arbit_slv         ,
   slv_ack            => slv_ack            ,
   mstr_ack            => mstr_ack            ,
   ack_o               => ack_o_int         ,
   we_i               => we_i,
   adr_i               => adr_i(6 DOWNTO 2) ,
   sel_i               => sel_i               ,
   slv_dat_i         => slv_dat_i         ,
   slv_dat_o         => slv_dat_o         ,
   clr_dma_act_bd      => clr_dma_act_bd,
   adr_o               => adr_o_int(6 DOWNTO 2)               ,
   mstr_dat_i         => mstr_dat_i         ,
   dma_act_bd         => dma_act_bd_int(7 DOWNTO 4)         ,
   dma_dest_adr      => dma_dest_adr      ,
   dma_sour_adr      => dma_sour_adr      ,
   dma_sour_device   => dma_sour_device   ,
   dma_dest_device   => dma_dest_device   ,
   dma_vme_am         => dma_vme_am         ,
   inc_sour            => inc_sour            ,
   inc_dest            => inc_dest            ,
   dma_size            => dma_size            ,
--   start_dma         => start_dma         ,
   set_dma_err         => set_dma_err_int         ,
   clr_dma_en         => clr_dma_en_int         ,
   dma_en            => dma_en            ,
   dma_null            => dma_null            ,
   en_mstr_dat_i_reg   => en_mstr_dat_i_reg 

     );

dma_mstr: vme_dma_mstr 
PORT MAP (
   rst               => rst               ,
   clk               => clk               ,
   stb_o               => stb_o_int               ,
   ack_i               => ack_i               ,
   err_i               => err_i               ,
   cti               => cti,
   fifo_empty         => fifo_empty         ,
   fifo_full            => fifo_full,
   fifo_almost_full   => fifo_almost_full   ,
   fifo_almost_empty   => fifo_almost_empty   ,
   fifo_wr            => fifo_wr            ,
   fifo_rd            => fifo_rd            ,
   boundary            => boundary,
   almost_boundary            => almost_boundary,
   we_o_int            => we_o_int,
   sour_dest         => sour_dest         ,
   inc_adr            => inc_adr            ,
   get_bd            => get_bd            ,
   reached_size      => reached_size      ,
   almost_reached_size      => almost_reached_size   ,
   dma_act_bd         => dma_act_bd_int         ,
   load_cnt            => load_cnt            ,
   start_dma         => start_dma         ,
   set_dma_err         => set_dma_err_int         ,
   clr_dma_en         => clr_dma_en_int         ,
   dma_en            => dma_en            ,
   inc_sour            => inc_sour,
   inc_dest            => inc_dest,
   dma_null            => dma_null            ,
   en_mstr_dat_i_reg   => en_mstr_dat_i_reg   ,
   mstr_req            => mstr_req            
     );

dma_fifo: vme_dma_fifo
PORT MAP (
   rst               => rst               ,
   clk               => clk               ,
   fifo_clr            => clr_fifo,
   fifo_wr            => fifo_wr            ,
   fifo_rd            => fifo_rd            ,
   fifo_dat_i         => mstr_dat_i         ,
   fifo_dat_o         => mstr_dat_o         ,
   fifo_almost_full   => fifo_almost_full   ,
   fifo_almost_empty  => fifo_almost_empty,
   fifo_full         => fifo_full   ,
   fifo_empty         => fifo_empty         
     );


END vme_dma_arch;
