---------------------------------------------------------------
-- Title         :
-- Project       :
---------------------------------------------------------------
-- File          : wbmon.vhd
-- Author        : Michael Ernst
-- Email         :
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 21/09/04
---------------------------------------------------------------
-- Simulator     : Modelsim Altera 5.8g
-- Synthesis     : --
---------------------------------------------------------------
-- Description : This Wishbone Monitor asserts that all signals
--               and transaction on a wishbone bus are handled
--               correct. It outputs errors on std_out and the
--               rest into a file
---------------------------------------------------------------
-- Hierarchy:
--
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
--   Version| Author   | Mod. Date  | Changes Made:
--   v0.1   | Ernst    |  21/09/04  | first code
--
-- $Revision: 1.8 $
--
-- $Log: wbmon.vhd,v $
-- Revision 1.8  2015/06/15 16:40:04  AGeissler
-- R1: In 16z100- version 1.30 the bte signal was removed from the wb_pkg.vhd
-- M1: Removed bte signals from wishbone monitor
-- R2: Clearness
-- M2: Replaced tabs with spaces
--
-- Revision 1.7  2010/03/01 09:28:34  SKrieger
-- R: Evaluation of master outputs / slave inputs should be done when stb and cyc are both different from '0'.
-- M: Changed accordingly
--
-- Revision 1.6  2008/10/27 08:42:22  skrieger
-- R: The wrong address is displayed during an access (lower than 32 bit) to a not 32-bit-alligned address. Example: 8-bit access to address 0x00000001
--    is displayed as 8-bit access to address 0x00000000 but with the same data.
-- M: Changed data output that a 32-bit-alligned address will be output but with the correct data and with the corresponding select-lines.
--
-- Revision 1.5  2008/07/04 11:25:09  mernst
-- - Added enable signal for simulation (use signal_force to deactivate output temporarily)
-- - Data lines are only checked while they have to be valid now
--
-- Revision 1.4  2007/11/20 11:55:46  FWombacher
-- Cosmetics: Removed obsoltete address decoding
--
-- Revision 1.3  2005/09/15 08:18:17  flenhardt
-- Fixed bug in error indication
--
-- Revision 1.2  2005/04/29 08:23:05  MMiehling
-- added reset values
--
-- Revision 1.1  2005/02/07 13:09:30  mmiehling
-- Initial Revision
--
--
---------------------------------------------------------------
--
--Errorcoding:
--
-- 0x00
-- Acknowledge without Strobe or cycle:
-- an Acknowledge was given by the module alltough the module was not
-- addressed with strobe or cycle
--
-- 0x01
-- Address changed during transaction!
-- The address changed during a normal cycle or within a burst cycle
-- Not if it happens in a burst cycle it only asserts inside a single
-- transaction of the burst, address increment is handled in error 0x09
--
-- 0x02
-- Data in of slave changed during transaction!
-- data in of the slave changed during a write cycle
--
-- 0x03
-- Select Bits changed during transaction!
--
-- 0x04
-- CTI changed during transaction!
--
-- 0x05
-- Burst with not allowed cti:
-- in the current wishbone specification only cti of 000,010,111 are defined
--
-- 0x07
-- WE changed during burst!
--
-- 0x08
-- SEL changed during burst!
--
-- 0x09
-- wrong address increment or address changed during burst cycle:
-- the address has to increment by 4 in burst mode
--
-- 0x0a
-- Missing End Of Burst:
-- the end of a burst has to be shown by setting cti to 111 in the last
-- burst cycle. This signal is missing here
--
-- 0x0b
-- We changed during transaction!
--
-- 0x0c
-- Sel changed during transaction!
--
-- 0x0d
-- Strobe went low without acknowledge:
-- no acknowledge was given by the module but strobe was reset to 0
--
-- 0x0e
-- U Z X in statement

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- synthesis translate_off
USE std.textio.all;
USE ieee.std_logic_textio.all;
-- synthesis translate_on
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY wbmon IS
   GENERIC(
         wbname         : string := "wbmon";
         -- Output Settings
         sets       : std_logic_vector(3 DOWNTO 0) := "1110";
               --   1110
               --   ||||
               --   |||+- write notes to Modelsim out
               --   ||+-- write errors to Modelsim out
               --   |+--- write notes to file out
               --   +---- write errors to file out
         timeout    : integer := 100
         );
   PORT(
        clk            : IN std_logic;
         rst            : IN std_logic;
         adr            : IN std_logic_vector(31 DOWNTO 0);
         sldat_i        : IN std_logic_vector(31 DOWNTO 0);
         sldat_o        : IN std_logic_vector(31 DOWNTO 0);
         cti            : IN std_logic_vector(2 DOWNTO 0);
         sel            : IN std_logic_vector(3 DOWNTO 0);
         cyc            : IN std_logic;
         stb            : IN std_logic;
         ack            : IN std_logic;
         err            : IN std_logic;
         we             : IN std_logic;
         er              : OUT std_logic;
         co              : OUT std_logic_vector(7 DOWNTO 0)
         );
   PROCEDURE outp(
                  VARIABLE e              : OUT std_logic;
                  VARIABLE c              : OUT std_logic_vector(7 DOWNTO 0);
                  message        : string := "Unknown Error";
                  code           : std_logic_vector(7 DOWNTO 0):= x"FF";
                  enable         : std_logic;
                  sev            : severity_level := NOTE;
                  condition      : boolean := FALSE
      );

   PROCEDURE outp_cycle(
                  message        : string := "Not Defined";
                  sev            : severity_level := NOTE;
                  adr            : std_logic_vector(31 DOWNTO 0);
                  data           : std_logic_vector(31 DOWNTO 0);
                  ende           : string := "OK"
                  );

END wbmon;

ARCHITECTURE wbmon_arch OF wbmon IS
   function to_string
    (
    constant val           : in std_logic_vector
    ) return string is

      constant reglen      : INTEGER := val'LENGTH;
      variable result_str  : string(1 to reglen);
      variable slv         : std_logic_vector(1 to reglen) := val;
    begin
      for i in reglen downto 1  loop
        case slv(i) is
          when 'U'           => result_str(i) := 'U';
          when 'X'           => result_str(i) := 'X';
          when '0'           => result_str(i) := '0';
          when '1'           => result_str(i) := '1';
          when 'Z'           => result_str(i) := 'Z';
          when 'W'           => result_str(i) := 'W';
          when 'L'           => result_str(i) := 'L';
          when 'H'           => result_str(i) := 'H';
          when '-'           => result_str(i) := '-';
          when others        => -- an unknown std_logic value was passed
            assert false
              report "to_string -- unknown std_logic_vector value"
              severity error;
        end case;
      end loop;
      return result_str;
    end;

   FUNCTION to_hstring
    (
    CONSTANT bitaccess     : IN natural;
    CONSTANT val           : in std_logic_vector--(7 DOWNTO 0)
    ) RETURN string is

      VARIABLE reglen      : natural := 1;
      VARIABLE result_str  : string(1 to (bitaccess / 4));
      VARIABLE slv         : std_logic_vector(bitaccess-1 DOWNTO 0);-- := val;
      VARIABLE temp        : std_logic_vector(3 DOWNTO 0);
    BEGIN
      slv := val;
      IF bitaccess = 8 THEN
         reglen   := 1;
      ELSIF bitaccess = 16 THEN
         reglen   := 3;
      ELSIF bitaccess = 32 THEN
         reglen   := 7;
      ELSIF bitaccess = 64 THEN
         reglen   := 15;
      ELSE
         
      END IF;
                  
      FOR i in reglen DOWNTO 0 LOOP
        temp := slv(i*4 + 3 DOWNTO (i *4));
        CASE temp IS
          WHEN "0000"   => result_str(reglen + 1 - i) := '0';
          WHEN "0001"   => result_str(reglen + 1 - i) := '1';
          WHEN "0010"   => result_str(reglen + 1 - i) := '2';
          WHEN "0011"   => result_str(reglen + 1 - i) := '3';
          WHEN "0100"   => result_str(reglen + 1 - i) := '4';
          WHEN "0101"   => result_str(reglen + 1 - i) := '5';
          WHEN "0110"   => result_str(reglen + 1 - i) := '6';
          WHEN "0111"   => result_str(reglen + 1 - i) := '7';
          WHEN "1000"   => result_str(reglen + 1 - i) := '8';
          WHEN "1001"   => result_str(reglen + 1 - i) := '9';
          WHEN "1010"   => result_str(reglen + 1 - i) := 'A';
          WHEN "1011"   => result_str(reglen + 1 - i) := 'B';
          WHEN "1100"   => result_str(reglen + 1 - i) := 'C';
          WHEN "1101"   => result_str(reglen + 1 - i) := 'D';
          WHEN "1110"   => result_str(reglen + 1 - i) := 'E';
          WHEN "1111"   => result_str(reglen + 1 - i) := 'F';
          WHEN others   => result_str(reglen + 1 - i) := ' ';
            -- an unknown std_logic value was passed
          END CASE;
      END LOOP;
      RETURN result_str;
    END;
   

   FUNCTION data_out (sel : std_logic_vector(3 downto 0); dat : std_logic_vector(31 downto 0)) RETURN string IS
      variable byte0 : string(1 to 2);
      variable byte1 : string(1 to 2);
      variable byte2 : string(1 to 2);
      variable byte3 : string(1 to 2);

   BEGIN

      if sel(0) = '1' then
         byte0 := to_hstring(8,dat( 7 downto  0));
      else
         byte0 := "XX";
      end if;
      
      if sel(1) = '1' then
         byte1 := to_hstring(8,dat(15 downto  8));
      else
         byte1 := "XX";
      end if;
      
      if sel(2) = '1' then
         byte2 := to_hstring(8,dat(23 downto 16));
      else
         byte2 := "XX";
      end if;
      
      if sel(3) = '1' then
         byte3 := to_hstring(8,dat(31 downto 24));
      else
         byte3 := "XX";
      end if;
         
      return (byte3 & byte2 & "_" & byte1 & byte0);
   
   end data_out;


   PROCEDURE outp(
                  VARIABLE e              : OUT std_logic;
                  VARIABLE c              : OUT std_logic_vector(7 DOWNTO 0);
                  message        : string := "Unknown Error";
                  code           : std_logic_vector(7 DOWNTO 0):= x"FF";
                  enable         : std_logic;
                  sev            : severity_level := NOTE;
                  condition      : boolean := FALSE
      )
   IS
   -- synthesis translate_off
      FILE DataOut: TEXT OPEN Append_Mode
      IS wbname & "_transcript.txt"; -- Write- File

      VARIABLE wl : line;
      VARIABLE ol : line;
   -- synthesis translate_on
   BEGIN
      IF NOT(condition) AND enable = '1' THEN
-- synthesis translate_off
         IF (sets(0) = '1' AND sev = NOTE) OR (sets(1) = '1' AND sev = ERROR) THEN
            WRITE(wl, wbname & ": (" & severity_level'image(sev) & ") (");
            WRITE(wl,now, justified=>right,field =>10, unit=> ns );
            WRITE(wl, ") " & message & " 0x");
            hwrite(wl, code);
            WRITELINE(Output, wl);
         END IF;
         IF (sets(2) = '1' AND sev = NOTE) OR (sets(3) = '1' AND sev = ERROR) THEN
            WRITE(wl, wbname & ": (" & severity_level'image(sev) & ") (");
            WRITE(wl,now, justified=>right,field =>10, unit=> ns );
            WRITE(wl, ") " & message);
           WRITELINE(DataOut, wl);
         END IF;
-- synthesis translate_on
      IF (sev = ERROR) THEN
         e := '1';
         c := code;
      END IF;
      END IF;
   END;

   PROCEDURE outp_cycle(
                  message        : string := "Not Defined";
                  sev            : severity_level := NOTE;
                  adr            : std_logic_vector(31 DOWNTO 0);
                  data           : std_logic_vector(31 DOWNTO 0);
                  ende           : string := "OK"
                  ) IS
   -- synthesis translate_off
   FILE DataOut: TEXT OPEN Append_Mode
      IS wbname & "_transcript.txt"; -- Write- File

      VARIABLE wl : line;
   -- synthesis translate_on
   BEGIN
      -- synthesis translate_off
         IF (sets(0) = '1' AND sev = NOTE) OR (sets(1) = '1' AND sev = ERROR) THEN
            -- Output Notes to Modelsim
            WRITE(wl, wbname & ": (" & severity_level'image(sev) & ") (");
            WRITE(wl,now, justified=>right,field =>10, unit=> ns );
            WRITE(wl, ") " & message & " ADR: ");

            -- Output Data
            hwrite(wl, adr, justified=> left);
            write(wl,string'(" SEL: "));
            WRITE(wl, sel, field => 4);
            write(wl,string'(" DATA: "));
            WRITE(wl,string'(data_out(sel, data)));   


            -- Output ende
            WRITE(wl, ende);
            WRITELINE(output, wl);

         END IF;
         IF (sets(2) = '1' AND sev = NOTE) OR (sets(3) = '1' AND sev = ERROR) THEN
          -- Output Notes to Modelsim
            WRITE(wl, wbname & ": (" & severity_level'image(sev) & ") (");
            WRITE(wl,now, justified=>right,field =>10, unit=> ns );
            WRITE(wl, ") " & message & " ADR: ");

            -- Output Data
            hwrite(wl, adr, justified=> left);
            write(wl,string'(" SEL: "));
            WRITE(wl, sel, field => 8);
            write(wl,string'(" DATA: "));
            WRITE(wl,string'(data_out(sel, data)));   

            -- Output ende
            WRITE(wl, ende);
            WRITELINE(DataOut, wl);
         END IF;
         -- synthesis translate_on
   END;

-- SIGNALS
-- synthesis translate_off
FILE DataOut: TEXT OPEN Write_Mode
      IS wbname & "_transcript.txt"; -- Write- File
-- synthesis translate_on
TYPE wb_state_type IS (IDLE, CYCLE, BURST);
SIGNAL wb_state : wb_state_type;

SIGNAL adr_s      : std_logic_vector(31 DOWNTO 0);
SIGNAL sldat_i_s  : std_logic_vector(31 DOWNTO 0);
SIGNAL we_s       : std_logic;
SIGNAL cti_s      : std_logic_vector(2 DOWNTO 0);
SIGNAL sel_s      : std_logic_vector (3 DOWNTO 0);
SIGNAL cti_b      : std_logic_vector(2 DOWNTO 0);
SIGNAL sldat_i_b  : std_logic_vector(31 DOWNTO 0);
SIGNAL new_b      : std_logic;
SIGNAL enable     : std_logic;

BEGIN

enable <= '1';

-- synthesis translate_off
   PROCESS(clk)
   VARIABLE burst : string (1 TO 5);
   BEGIN
      IF rising_edge(clk) THEN
         IF (cti /= "000") THEN
            burst := "Burst";
         ELSE
            burst := "     ";
         END IF;
         IF (ack = '1' AND stb = '1' AND cyc = '1') THEN
            -- Output write or read actions
            IF (we = '1') THEN
               outp_cycle("Write Cycle " & burst, NOTE, adr, sldat_i, " --> OK");
            ELSE
               outp_cycle("Read Cycle " & burst, NOTE, adr, sldat_o, " --> OK");
            END IF;
         END IF;
         IF (err = '1' AND stb = '1' AND cyc = '1') THEN
            -- Output write or read actions
            IF (we = '1') THEN
               outp_cycle("Write Cycle " & burst, NOTE, adr, sldat_i, " --> ERROR");
            ELSE
               outp_cycle("Read Cycle " & burst, NOTE, adr, sldat_o, " --> ERROR");
            END IF;
         END IF;
      END IF;
   END PROCESS;
-- synthesis translate_on
   -- Create Cycle start time

   PROCESS(clk)
   VARIABLE c  : std_logic_vector(7 DOWNTO 0);
   VARIABLE e  : std_logic;
   BEGIN
      IF (rst = '1') THEN
         sel_s       <= (OTHERS => '0');
         adr_s       <= (OTHERS => '0');
         sldat_i_s   <= (OTHERS => '0');
         sldat_i_b   <= (OTHERS => '0');
         we_s        <= '0';
         new_b       <= '0';
         e           := '0';
         c           := (OTHERS => '0');
         er          <= '0';
         co          <= (OTHERS => '0');
         cti_b       <= (OTHERS => '0');
         cti_s       <= (OTHERS => '0');
      ELSIF (rising_edge(clk)) THEN
         CASE wb_state IS
            WHEN IDLE =>
               IF (stb = '1' AND cyc = '1') THEN
                  IF (cti = "111" OR cti = "000") THEN
                     -- Normal Cycle SAVE DATA
                     wb_state <= CYCLE;
                     cti_s       <= cti;
                     adr_s       <= adr;
                     we_s        <= we;
                     sel_s       <= sel;
                     sldat_i_s   <= sldat_i;
                  ELSIF (cti = "010") THEN
                     -- Burst cycle SAVE DATA
                     wb_state <= BURST;
                     new_b       <= '1';
                     cti_b       <= cti;
                     sldat_i_b   <= sldat_i;
                     IF ack = '1' THEN
                        adr_s    <= adr + 4;
                     ELSE
                        adr_s    <= adr;
                     END IF;
                     we_s        <= we;
                     sel_s       <= sel;
                     sldat_i_s   <= sldat_i;
                  ELSE
                     outp(e,c,"Unsupported CTI " & to_string(cti),x"05", enable , ERROR);
                  END IF;
                  IF ack = '1' THEN
                     IF cti /= "010" THEN
                        -- stay in idle if single cycle with acknowledge
                        wb_state <= IDLE;
                     END IF;
                  END IF;
               ELSE
                  IF ack = '1' THEN
                     outp(e,c,"acknowledge without cycle and/or strobe",x"00", enable , ERROR);
                  END IF;
               END IF;
            WHEN BURST =>

               IF (cti /= "010" AND cti /="111") THEN
                  -- ERROR missing End of burst
                  outp(e,c,"Missing end of burst", x"0a", enable , ERROR);
                  wb_state <= IDLE;
               END IF;

               IF (stb = '0') THEN
                  outp(e,c,"Strobe went low without Acknowledge", x"0d", enable , ERROR);
                  wb_state <= IDLE;
               END IF;

               -- CHECK SIGNALS which can change after ack
               IF (new_b = '1') THEN
                  cti_b <= cti;
                  sldat_i_b <= sldat_i;
                  new_b <= '0';
               ELSE
                  outp(e,c,"CTI changed during burst cycle ("&to_string(cti)&" sb "&to_string(cti_b)&")", x"04", enable , ERROR, cti = cti_b);
                  outp(e,c,"Master Data Out changed during burst cycle (0x"&to_hstring(32,sldat_i)&" sb 0x"&to_hstring(32,sldat_i_b)&")", x"02", enable , ERROR, sldat_i = sldat_i_b OR we = '0');
               END IF;

               IF (ack = '1' AND cti = "111") THEN
                  -- End of Burst
                  wb_state <= IDLE;
               ELSIF (ack = '1') THEN
                  -- Addrress Increment on acknowledge
                  adr_s <= adr_s + 4;
                  new_b <= '1';
                  wb_state <= BURST;
               END IF;

               -- CHECK SIGNALS:
               -- we has to stay the same throughout the burst
               outp(e,c,"We changed during burst (" & std_logic'image(we) & " sb " & std_logic'image(we_s) & ")", x"07", enable , ERROR, we = we_s);
               -- adr has to be adr_s which is inremented automatically
               outp(e,c,"Adr changed or increment wrong during burst (0x"&to_hstring(32,adr)&" sb 0x"&to_hstring(32,adr_s)&")", x"09", enable , ERROR, adr = adr_s);
               -- sel has to stay the same
               outp(e,c,"Sel changed during burst ("&to_string(sel)&" sb "&to_string(sel_s)&")", x"08", enable , ERROR, sel = sel_s);

            WHEN CYCLE =>
               IF (stb = '0') THEN
                  outp(e,c,"Strobe went low without Acknowledge ", x"0d", enable , ERROR);
                  wb_state <= IDLE;
               END IF;
               IF (ack = '1') THEN
                  wb_state <= IDLE;
               END IF;
               -- we has to stay the same throughout the burst
               outp(e,c,"We changed during cycle (" & std_logic'image(we) & " sb " & std_logic'image(we_s) & ")", x"0b", enable , ERROR, we = we_s);
               -- adr has to be adr_s which is inremented automatically
               outp(e,c,"Adr changed or increment wrong during cycle (0x"&to_hstring(32,adr)&" sb 0x"&to_hstring(32,adr_s)&")", x"01", enable , ERROR, adr = adr_s);
               -- sel has to stay the same
               outp(e,c,"Sel changed during cycle ("&to_string(sel)&" sb "&to_string(sel_s)&")", x"0c", enable , ERROR, sel = sel_s);
               outp(e,c,"CTI changed during cycle ("&to_string(cti)&" sb "&to_string(cti_s)&")", x"04", enable , ERROR, cti = cti_s);
               outp(e,c,"Master Data Out changed during cycle (0x"&to_hstring(32,sldat_i)&" sb 0x"&to_hstring(32,sldat_i_s)&")", x"02", enable , ERROR, sldat_i = sldat_i_s OR we = '0');

            WHEN OTHERS =>
               ASSERT FALSE REPORT "AHH OHHHHHHH" SEVERITY failure;
         END CASE;
         co <= c;
         er <= e;
      END IF;
   END PROCESS;










-- synthesis translate_off

-- test if signals are 'U', 'Z' or 'X'
PROCESS( clk, rst, cyc, stb, we, ack, err, cti, adr, sldat_i, sldat_o)
   VARIABLE c  : std_logic_vector(7 DOWNTO 0);
   VARIABLE e  : std_logic;
   BEGIN
   IF(NOT (NOW = 0 ps)) THEN
      IF (rst = '0' OR rst = 'U') AND (cyc = 'U' OR cyc = 'Z' OR cyc = 'X') THEN
            outp(e,c,"cyc is 'U', 'Z' or 'X'", x"0e", enable , ERROR);
      END IF;
      IF (rst = '0' OR rst = 'U') AND (clk = 'U' OR clk = 'Z' OR clk = 'X') THEN
            outp(e,c,"clk is 'U', 'Z' or 'X'", x"0e", enable , ERROR);
      END IF;
      IF (rst = '0' OR rst = 'U') AND (stb = 'U' OR stb = 'Z' OR stb = 'X') THEN
            outp(e,c,"stb is 'U', 'Z' or 'X'", x"0e", enable , ERROR);
      END IF;
      IF (rst = '0' OR rst = 'U') AND (we = 'U' OR we = 'Z' OR we = 'X') AND stb = '1' AND cyc /= '0' THEN
            outp(e,c,"we is 'U', 'Z' or 'X'", x"0e", enable , ERROR);
      END IF;
      IF (rst = '0' OR rst = 'U') AND (ack = 'U' OR ack = 'Z' OR ack = 'X') THEN
            outp(e,c,"ack is 'U', 'Z' or 'X'", x"0e", enable , ERROR);
      END IF;
      IF (rst = '0' OR rst = 'U') AND (err = 'U' OR err = 'Z' OR err = 'X') THEN
            outp(e,c,"err is 'U', 'Z' or 'X'", x"0e", enable , ERROR);
      END IF;
      IF (rst = '0' OR rst = 'U') AND is_x(sel) AND stb = '1' AND cyc /= '0' THEN
            outp(e,c,"err is 'U', 'Z' or 'X'", x"0e", enable , ERROR);
      END IF;
      IF (rst = '0' OR rst = 'U') AND is_x(cti) AND stb = '1' AND cyc /= '0' THEN
            outp(e,c,"cti is 'U', 'Z' or 'X'", x"0e", enable , ERROR);
      END IF;
      IF (rst = '0' OR rst = 'U') AND is_x(adr) AND stb = '1' AND cyc /= '0' THEN
            outp(e,c,"adr is 'U', 'Z' or 'X'", x"0e", enable , ERROR);
      END IF;
      IF (rst = '0' OR rst = 'U') AND is_x(sldat_i) AND cyc /= '0' AND stb = '1' THEN
            outp(e,c,"data_in is 'U', 'Z' or 'X'", x"0e", enable, error);
      END IF;
      IF (rst = '0' OR rst = 'U') AND is_x(sldat_o) AND ack /= '0' THEN
            outp(e,c,"data_o is 'U', 'Z' or 'X'", x"0e", enable, error);
      END IF;
   END IF;
   END PROCESS;
-- synthesis translate_on
END wbmon_arch;