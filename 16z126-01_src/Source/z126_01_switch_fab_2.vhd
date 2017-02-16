---------------------------------------------------------------
-- Title         :
-- Project       : 
---------------------------------------------------------------
-- File          : z126_01_switch_fab_2.vhd
-- Author        : Andreas Geissler
-- Email         : Andreas.Geissler@men.de
-- Organization  : MEN Mikro Elektronik Nuremberg GmbH
-- Created       : 03/02/14
---------------------------------------------------------------
-- Simulator     : ModelSim-Altera PE 6.4c
-- Synthesis     : Quartus II 12.1 SP2
---------------------------------------------------------------
-- Description :
-- This module is derived from switch_fab_2.vhd of the 16z100-.
-- It contaions an additional arbitration of control 
-- signals for the z126_01_wb2pasmi.vhd module in the 16z126-01
-- design.
---------------------------------------------------------------
-- Hierarchy:
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
-- $Revision: 1.1 $
--
-- $Log: z126_01_switch_fab_2.vhd,v $
-- Revision 1.1  2014/03/03 17:49:53  AGeissler
-- Initial Revision
--
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.z126_01_wb_pkg.ALL;
USE work.z126_01_pkg.ALL;

ENTITY z126_01_switch_fab_2 IS
   PORT (
      clk            : IN std_logic;
      rst            : IN std_logic;
      cyc_0          : IN std_logic;
      ack_0          : OUT std_logic;
      err_0          : OUT std_logic;
      wbo_0          : IN wbo_type;
      ctrlmo_0       : IN ctrl_wb2pasmi_out_type;
      ctrlmi_0       : OUT ctrl_wb2pasmi_in_type;
      
      cyc_1          : IN std_logic;
      ack_1          : OUT std_logic;
      err_1          : OUT std_logic;
      wbo_1          : IN wbo_type;
      ctrlmo_1       : IN ctrl_wb2pasmi_out_type;
      ctrlmi_1       : OUT ctrl_wb2pasmi_in_type;
   
      wbo_slave      : IN wbi_type;
      wbi_slave      : OUT wbo_type;
      wbi_slave_cyc  : OUT std_logic;
      ctrlso_0       : IN ctrl_wb2pasmi_in_type;
      ctrlsi_0       : OUT ctrl_wb2pasmi_out_type
   );
END z126_01_switch_fab_2;

ARCHITECTURE z126_01_switch_fab_2_arch OF z126_01_switch_fab_2 IS 
   SUBTYPE sw_states IS std_logic_vector(1 DOWNTO 0);
   CONSTANT sw_0        : sw_states := "01";
   CONSTANT sw_1        : sw_states := "10";
   
   SIGNAL sw_state      : sw_states;
   SIGNAL sw_nxt_state  : sw_states;
   
   SIGNAL wbi_slave_stb : std_logic;
BEGIN
      
   sw_fsm : PROCESS (clk, rst)
   BEGIN
      IF rst = '1' THEN
         wbi_slave_stb <= '0';
         sw_state <= sw_0;
      ELSIF clk'EVENT AND clk = '1' THEN
         sw_state <= sw_nxt_state;
         CASE sw_nxt_state IS
            WHEN sw_0 =>
               IF cyc_0 = '1' THEN
                  IF wbo_slave.err = '1' THEN                           -- error
                     wbi_slave_stb <= '0';
                  ELSIF wbo_slave.ack = '1' AND wbo_0.cti = "010" THEN  -- burst
                     wbi_slave_stb <= wbo_0.stb;
                  ELSIF wbo_slave.ack = '1' AND wbo_0.cti /= "010" THEN -- single
                     wbi_slave_stb <= '0';
                  ELSE
                     wbi_slave_stb <= wbo_0.stb;
                  END IF;
               ELSIF cyc_1 = '1' THEN
                  wbi_slave_stb <= wbo_1.stb;
               ELSE
                  wbi_slave_stb <= '0';
               END IF;              
      
            WHEN sw_1 =>
               IF cyc_1 = '1' THEN
                  IF wbo_slave.err = '1' THEN                           -- error
                     wbi_slave_stb <= '0';
                  ELSIF wbo_slave.ack = '1' AND wbo_1.cti = "010" THEN  -- burst
                     wbi_slave_stb <= wbo_1.stb;
                  ELSIF wbo_slave.ack = '1' AND wbo_1.cti /= "010" THEN -- single
                     wbi_slave_stb <= '0';
                  ELSE
                     wbi_slave_stb <= wbo_1.stb;
                  END IF;
               ELSIF cyc_0 = '1' THEN
                  wbi_slave_stb <= wbo_0.stb;
               ELSE
                  wbi_slave_stb <= '0';
               END IF;              
      
            WHEN OTHERS =>
               wbi_slave_stb <= '0';
         END CASE;
      END IF;
   END PROCESS sw_fsm;
  
   sw_fsm_sel : PROCESS(sw_state, cyc_0, cyc_1)
   BEGIN
      CASE sw_state IS
         WHEN sw_0 =>
            IF cyc_0 = '1' THEN
               sw_nxt_state <= sw_0;
            ELSIF cyc_1 = '1' THEN
               sw_nxt_state <= sw_1;
            ELSE
               sw_nxt_state <= sw_0;
            END IF;              
      
         WHEN sw_1 =>
            IF cyc_1 = '1' THEN
               sw_nxt_state <= sw_1;
            ELSIF cyc_0 = '1' THEN
               sw_nxt_state <= sw_0;
            ELSE
               sw_nxt_state <= sw_1;
            END IF;              
      
         WHEN OTHERS =>
            sw_nxt_state <= sw_0;
         
      END CASE;
   END PROCESS sw_fsm_sel;
      
   PROCESS(sw_state, wbo_0.dat, wbo_1.dat)
   BEGIN
      CASE sw_state IS
         WHEN sw_0 => wbi_slave.dat <= wbo_0.dat;     
         WHEN sw_1 => wbi_slave.dat <= wbo_1.dat;     
         WHEN OTHERS => wbi_slave.dat <= wbo_0.dat;      
      END CASE;
   END PROCESS;
      
   PROCESS(sw_state, wbo_0.adr, wbo_1.adr)
   BEGIN
      CASE sw_state IS
         WHEN sw_0 => wbi_slave.adr <= wbo_0.adr;     
         WHEN sw_1 => wbi_slave.adr <= wbo_1.adr;     
         WHEN OTHERS => wbi_slave.adr <= wbo_0.adr;      
      END CASE;
   END PROCESS;
      
   PROCESS(sw_state, wbo_0.sel, wbo_1.sel)
   BEGIN
      CASE sw_state IS
         WHEN sw_0 => wbi_slave.sel <= wbo_0.sel;     
         WHEN sw_1 => wbi_slave.sel <= wbo_1.sel;     
         WHEN OTHERS => wbi_slave.sel <= wbo_0.sel;      
      END CASE;
   END PROCESS;
      
   PROCESS(sw_state, wbo_0.we, wbo_1.we)
   BEGIN
      CASE sw_state IS
         WHEN sw_0 => wbi_slave.we <= wbo_0.we;    
         WHEN sw_1 => wbi_slave.we <= wbo_1.we;    
         WHEN OTHERS => wbi_slave.we <= wbo_0.we;     
      END CASE;
   END PROCESS;
      
   PROCESS(sw_state, wbo_0.cti, wbo_1.cti)
   BEGIN
      CASE sw_state IS
         WHEN sw_0 => wbi_slave.cti <= wbo_0.cti;     
         WHEN sw_1 => wbi_slave.cti <= wbo_1.cti;     
         WHEN OTHERS => wbi_slave.cti <= wbo_0.cti;      
      END CASE;
   END PROCESS;
      
   PROCESS(sw_state, wbo_0.bte, wbo_1.bte)
   BEGIN
      CASE sw_state IS
         WHEN sw_0 => wbi_slave.bte <= wbo_0.bte;     
         WHEN sw_1 => wbi_slave.bte <= wbo_1.bte;     
         WHEN OTHERS => wbi_slave.bte <= wbo_0.bte;      
      END CASE;
   END PROCESS;
      
   PROCESS(sw_state, wbo_0.tga, wbo_1.tga)
   BEGIN
      CASE sw_state IS
         WHEN sw_0 => wbi_slave.tga <= wbo_0.tga;     
         WHEN sw_1 => wbi_slave.tga <= wbo_1.tga;     
         WHEN OTHERS => wbi_slave.tga <= wbo_0.tga;      
      END CASE;
   END PROCESS;
   
   
   -- mux for wb2pasmi control signals
   PROCESS( sw_state, ctrlmo_0, ctrlmo_1)
   BEGIN
      CASE sw_state IS
         WHEN sw_0 => 
            ctrlsi_0.read_sid        <= ctrlmo_0.read_sid;
            ctrlsi_0.sector_protect  <= ctrlmo_0.sector_protect;
            ctrlsi_0.write           <= ctrlmo_0.write;
            ctrlsi_0.read_status     <= ctrlmo_0.read_status;
            ctrlsi_0.sector_erase    <= ctrlmo_0.sector_erase;
            ctrlsi_0.bulk_erase      <= ctrlmo_0.bulk_erase;
            
         WHEN sw_1 => 
            ctrlsi_0.read_sid        <= ctrlmo_1.read_sid;
            ctrlsi_0.sector_protect  <= ctrlmo_1.sector_protect;
            ctrlsi_0.write           <= ctrlmo_1.write;
            ctrlsi_0.read_status     <= ctrlmo_1.read_status;
            ctrlsi_0.sector_erase    <= ctrlmo_1.sector_erase;
            ctrlsi_0.bulk_erase      <= ctrlmo_1.bulk_erase;
            
         WHEN OTHERS => 
            ctrlsi_0.read_sid        <= ctrlmo_0.read_sid;
            ctrlsi_0.sector_protect  <= ctrlmo_0.sector_protect;
            ctrlsi_0.write           <= ctrlmo_0.write;
            ctrlsi_0.read_status     <= ctrlmo_0.read_status;
            ctrlsi_0.sector_erase    <= ctrlmo_0.sector_erase;
            ctrlsi_0.bulk_erase      <= ctrlmo_0.bulk_erase;
             
      END CASE;
   END PROCESS;
   
   ctrlmi_0.illegal_write  <= ctrlso_0.illegal_write  WHEN sw_state = sw_0 ELSE '0';
   ctrlmi_0.illegal_erase  <= ctrlso_0.illegal_erase  WHEN sw_state = sw_0 ELSE '0';
   ctrlmi_0.busy           <= ctrlso_0.busy           WHEN sw_state = sw_0 ELSE '0';
   
   ctrlmi_1.illegal_write  <= ctrlso_0.illegal_write  WHEN sw_state = sw_1 ELSE '0';
   ctrlmi_1.illegal_erase  <= ctrlso_0.illegal_erase  WHEN sw_state = sw_1 ELSE '0';
   ctrlmi_1.busy           <= ctrlso_0.busy           WHEN sw_state = sw_1 ELSE '0';
    
   wbi_slave.stb <= wbi_slave_stb;                 
   wbi_slave_cyc <= '1' WHEN (sw_state = sw_0 AND cyc_0 = '1') OR (sw_state = sw_1 AND cyc_1 = '1') ELSE '0';
   
   ack_0 <= '1' WHEN sw_state = sw_0 AND wbo_slave.ack = '1' AND wbi_slave_stb = '1' ELSE '0';
   ack_1 <= '1' WHEN sw_state = sw_1 AND wbo_slave.ack = '1' AND wbi_slave_stb = '1' ELSE '0';
   
   err_0 <= '1' WHEN sw_state = sw_0 AND wbo_slave.err = '1' AND wbi_slave_stb = '1' ELSE '0';
   err_1 <= '1' WHEN sw_state = sw_1 AND wbo_slave.err = '1' AND wbi_slave_stb = '1' ELSE '0';

END z126_01_switch_fab_2_arch;
