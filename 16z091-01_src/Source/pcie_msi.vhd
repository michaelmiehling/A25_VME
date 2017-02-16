--------------------------------------------------------------------------------
-- Title         : Interrupt request logic for processing MSI
-- Project       : 
--------------------------------------------------------------------------------
-- File          : pcie_msi.vhd
-- Author        : Michael Miehling
-- Email         : miehling@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 28/02/12
--------------------------------------------------------------------------------
-- Simulator     : 
-- Synthesis     : 
--------------------------------------------------------------------------------
-- Description :
--
-- Interrupt request handler for processing legacy and MSI on 
-- PCIe Altera.
-- Each interrupt request signal of the toplevel should be 
-- connected to the irq_req vector. The generic WIDTH controls 
-- the max size, which should be identical or less than the 
-- setting in the PCIe core.
-- If wb_int_num_allowed is smaller than the WIDTH of the irq_req 
-- vector, legacy interrupts are selected. This is also when
-- the SW does not enable the MSI capability (wb_int_num_allowed=0).
-- Else if wb_int_num_allowed greater or equal the WIDTH of the
-- irq_req vector, MSI is selected.
-- MSI:
-- The handler triggers the PCIe core interface each time if a 
-- rising edge was detected on either bit of the irq_req vector
-- (interrupt request got active). This will trigger the PCIe
-- to send a MSI packet to the CPU, with a vector number equal to 
-- the bit number of the irq_req vector. Only the rising edge will
-- trigger the MSI.
-- legacy Interrupts:
-- If one of the bit of irq_req gets active, the PCIe core will be  
-- triggered to send a INTA_asserted message. If another bit gets 
-- active, no further messages will be sent. If all bit return to
-- inactive (irq_req = 0), a INTA_deassert message will be sent.
-- 
-- SuR: added wb interrupt number wrap according to maximum
--      number of enabled MSI vectors; corrected state machine
--      behavior
--------------------------------------------------------------------------------
-- Hierarchy:
--    ip_16z091_01_top_core
--       ip_16z091_01
--       Hard_IP
--       z091_01_wb_adr_dec
-- *     pcie_msi-
-- 
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
use ieee.numeric_std.all;

entity pcie_msi is
generic (
   WIDTH                : integer range 32 downto 1 
   );
port (
   clk_i                : in  std_logic;
   rst_i                : in  std_logic;
  
   irq_req_i            : in  std_logic_vector(WIDTH -1 downto 0);
   
   wb_int_o             : out std_logic;
   wb_pwr_enable_o      : out std_logic;
   wb_int_num_o         : out std_logic_vector(4 downto 0);
   wb_int_ack_i         : in  std_logic;
   wb_int_num_allowed_i : in  std_logic_vector(5 downto 0)

   );
end pcie_msi;

architecture pcie_msi_arch of pcie_msi is 
-- +---------------------------------------------------------------------------
-- | constants
-- +--------------------------------------------------------------------------- 
   constant ZERO_5B  : std_logic_vector(4 downto 0)  := (others => '0');
   constant ZERO_6B  : std_logic_vector(5 downto 0)  := (others => '0');
   constant ZERO_32B : std_logic_vector(31 downto 0) := (others => '0');

-- +---------------------------------------------------------------------------
-- | internal signals
-- +--------------------------------------------------------------------------- 
   type msi_states is (IDLE, REQUEST_MSI, REQUEST_INTA, WAIT_ON_DEASSERT_INTA, DEASSERT_INTA, WAITONEND);
   signal msi_state       : msi_states;
   signal irq_req_q       : std_logic_vector(WIDTH -1 downto 0);
   signal irq_req_qq      : std_logic_vector(WIDTH -1 downto 0);
   signal irq_req_qqq     : std_logic_vector(WIDTH -1 downto 0);
   signal irq             : std_logic_vector(31 downto 0);
   signal clr_irq         : std_logic_vector(WIDTH -1 downto 0);
   signal wb_num          : std_logic_vector(4 downto 0);
   signal irq_type        : std_logic;                                          -- when 1: msi is selected
   signal wb_num_q        : std_logic_vector(4 downto 0);
   signal wb_num_conv_q   : std_logic_vector(4 downto 0);
   signal wb_num_conv     : std_logic_vector(4 downto 0);
   signal int_max_msi_nbr : std_logic_vector(4 downto 0);

begin
   wb_pwr_enable_o <= '0';  
   irq_type        <= '1' when to_integer(unsigned(wb_int_num_allowed_i)) > 0 else '0';

   ------------------------------
   -- calculate int_max_msi_nbr
   ------------------------------
   int_max_msi_nbr <= (others => '0') when wb_int_num_allowed_i = ZERO_6B else
                      (others => '1') when wb_int_num_allowed_i = "100000" else 
                      std_logic_vector(to_unsigned(to_integer(unsigned(wb_int_num_allowed_i)),5));

   ------------------------------------
   -- provide fixed irq vector number
   -- for every irq request
   ------------------------------------
   wb_num <=  "00000" when irq(0)  = '1' else
              "00001" when irq(1)  = '1' else
              "00010" when irq(2)  = '1' else
              "00011" when irq(3)  = '1' else
              "00100" when irq(4)  = '1' else
              "00101" when irq(5)  = '1' else
              "00110" when irq(6)  = '1' else
              "00111" when irq(7)  = '1' else
              "01000" when irq(8)  = '1' else
              "01001" when irq(9)  = '1' else
              "01010" when irq(10) = '1' else
              "01011" when irq(11) = '1' else
              "01100" when irq(12) = '1' else
              "01101" when irq(13) = '1' else
              "01110" when irq(14) = '1' else
              "01111" when irq(15) = '1' else
              "10000" when irq(16) = '1' else
              "10001" when irq(17) = '1' else
              "10010" when irq(18) = '1' else
              "10011" when irq(19) = '1' else
              "10100" WHEN irq(20) = '1' ELSE
              "10101" WHEN irq(21) = '1' ELSE
              "10110" WHEN irq(22) = '1' ELSE
              "10111" WHEN irq(23) = '1' ELSE
              "11000" WHEN irq(24) = '1' ELSE
              "11001" WHEN irq(25) = '1' ELSE
              "11010" WHEN irq(26) = '1' ELSE
              "11011" WHEN irq(27) = '1' ELSE
              "11100" WHEN irq(28) = '1' ELSE
              "11101" WHEN irq(29) = '1' ELSE
              "11110" WHEN irq(30) = '1' ELSE
              "11111" WHEN irq(31) = '1' ELSE
              "00000";

   -- set vector number to interrupt pin number
   wb_int_num_o <= wb_num_conv_q;

   -------------------------------------------
   -- if less MSI vectors are assigned than
   -- were requested wrap the vector numbers
   -------------------------------------------
   wb_num_conv <= (others => '0') when (wb_int_num_allowed_i = ZERO_6B or
                  irq = ZERO_32B or wb_num = ZERO_5B) else
                  std_logic_vector(unsigned(wb_num) mod unsigned(int_max_msi_nbr));

                
   process (clk_i, rst_i)
   begin
      if rst_i = '1' then
         wb_int_o      <= '0';
         wb_num_q      <= (others => '0');
         irq_req_q     <= (others => '0');
         irq_req_qq    <= (others => '0');
         irq_req_qqq   <= (others => '0');
         irq           <= (others => '0');
         clr_irq       <= (others => '0');
         msi_state     <= IDLE;
         wb_num_conv_q <= (others => '0');

      elsif clk_i'event and clk_i = '1' then
         irq_req_q   <= irq_req_i;
         irq_req_qq  <= irq_req_q;
         irq_req_qqq <= irq_req_qq;

         for i in 0 to WIDTH-1 loop
            if irq_req_qq(i) = '1' and irq_req_qqq(i) = '0' then
               irq(i) <= '1';
            elsif clr_irq(i) = '1' then
               irq(i) <= '0';
            end if;
         end loop;

         if WIDTH < 32 then
            irq(31 downto WIDTH) <= (others => '0');
         end if;
         
         case msi_state is
            -- wait until interrupt request is pending
            when IDLE =>
               if irq /= 0 and irq_type = '1' then          -- send msi
                  wb_num_q      <= wb_num;                  -- store number of interrupt at start of processing in order 
                                                            -- not to get confused if another irq gets active
                  wb_num_conv_q <= wb_num_conv;             -- set vector number to interrupt pin number
                  wb_int_o      <= '1';                     -- indicate interrupt request to pcie core
                  clr_irq       <= (others => '0');
                  msi_state     <= REQUEST_MSI;

               elsif irq /= 0 and irq_type = '0' then       -- send legacy
                  wb_num_q      <= wb_num;                  -- store number of interrupt at start of processing in order 
                                                            -- not to get confused if another irq gets active
                  wb_num_conv_q <= (others => '0');         -- unused for inta
                  wb_int_o      <= '1';                     -- indicate interrupt request to pcie core
                  clr_irq       <= (others => '0');
                  msi_state     <= REQUEST_INTA;

               else
                  wb_num_q      <= (others => '0');
                  wb_num_conv_q <= (others => '0');
                  wb_int_o      <= '0';
                  clr_irq       <= (others => '0');
                  msi_state     <= IDLE;
               end if;                  
                  
            -- wait until interrupt request was processed by pcie
            when REQUEST_MSI =>
               if wb_int_ack_i = '1' then              
                  wb_num_q      <= (others => '0');         -- clear
                  wb_num_conv_q <= wb_num_conv_q;
                  wb_int_o      <= '0';                     -- clear interrupt request
                  clr_irq       <= (others => '0');
                  clr_irq(conv_integer(wb_num_q)) <= '1';   -- clear processed interrupt request
                  msi_state     <= WAITONEND;

               else                  
                  wb_num_q      <= wb_num_q;
                  wb_num_conv_q <= wb_num_conv_q;
                  wb_int_o      <= '1';
                  clr_irq       <= (others => '0');
                  msi_state     <= REQUEST_MSI;
               end if;

            -------------------------------------
            -- wait until inta message was sent
            -------------------------------------
            when REQUEST_INTA =>
               if wb_int_ack_i = '1' then              
                  wb_num_q      <= wb_num_q;
                  wb_num_conv_q <= (others => '0');
                  wb_int_o      <= '1';
                  clr_irq       <= (others => '0');
                  msi_state     <= WAIT_ON_DEASSERT_INTA;

               else                  
                  wb_num_q      <= wb_num_q;
                  wb_num_conv_q <= (others => '0');
                  wb_int_o      <= '1';
                  clr_irq       <= (others => '0');
                  msi_state     <= REQUEST_INTA;
               end if;

            ----------------------------------
            -- send deassert inta message if
            -- processed irq is deasserted
            ----------------------------------
            when WAIT_ON_DEASSERT_INTA =>
               if irq_req_qq(to_integer(unsigned(wb_num_q))) = '0' then
                  wb_num_q      <= wb_num_q;
                  wb_num_conv_q <= (others => '0');         -- unused for inta
                  wb_int_o      <= '0';                     -- indicate interrupt deassert to pcie core
                  clr_irq       <= (others => '0');
                  clr_irq(to_integer(unsigned(wb_num_q))) <= '1';   -- clear processed interrupt request
                  msi_state     <= DEASSERT_INTA;

               else
                  wb_num_q      <= wb_num_q;
                  wb_num_conv_q <= (others => '0');
                  wb_int_o      <= '1';
                  clr_irq       <= (others => '0');
                  msi_state     <= WAIT_ON_DEASSERT_INTA;
               end if;            
                                 
            -----------------------------
            -- wait until deassert inta
            -- message was sent
            -----------------------------
            when DEASSERT_INTA =>
               if wb_int_ack_i = '1' then                   -- deassertion was sent
                  wb_num_q      <= wb_num_q;
                  wb_num_conv_q <= (others => '0');
                  wb_int_o      <= '0';                     -- clear interrupt request
                  --clr_irq(to_integer(unsigned(wb_num_q))) <= '1';   -- clear processed interrupt request
                  clr_irq       <= (others => '0');
                  msi_state     <= WAITONEND;

               else                  
                  wb_num_q      <= wb_num_q;
                  wb_num_conv_q <= (others => '0');
                  wb_int_o      <= '0';
                  clr_irq       <= (others => '0');
                  msi_state     <= DEASSERT_INTA;
               end if;
                                 
            -- wait until handshake has ended in order to be prepared for next interrupt
            when WAITONEND =>
               if wb_int_ack_i = '0' then                   -- handshake has ended
                  wb_num_q      <= (others => '0');         -- clear
                  wb_num_conv_q <= (others => '0');
                  wb_int_o      <= '0';
                  clr_irq       <= (others => '0');
                  msi_state     <= IDLE;

               else                  
                  wb_num_q      <= (others => '0');         -- clear
                  wb_num_conv_q <= wb_num_conv_q;
                  wb_int_o      <= '0';
                  clr_irq       <= (others => '0');
                  msi_state     <= WAITONEND;
               end if;
                                
            -- coverage_off 
            when others => 
               wb_num_q      <= (others => '0');
               wb_num_conv_q <= (others => '0');
               wb_int_o      <= '0';
               clr_irq       <= (others => '0');
               msi_state     <= IDLE;
            -- coverage_on
         end case;
         
      end if;
   end process;

end pcie_msi_arch;

