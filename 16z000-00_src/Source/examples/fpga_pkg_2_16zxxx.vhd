---------------------------------------------------------------
-- Title         : fpga_pkg_2 example for IP-Core top file
-- Project       : 
---------------------------------------------------------------
-- File          : fpga_pkg_2_16zxxx.vhd
-- Author        : Florian Wombacher
-- Email         : florian.wombacher@men.de
-- Organization  : MEN Mikro Elektronik Nuremberg GmbH
-- Created       : 2008-04-01
---------------------------------------------------------------
-- Simulator     :
-- Synthesis     :
---------------------------------------------------------------
-- Description :  
--                
---------------------------------------------------------------
-- Hierarchy: 
-- fpga_pkg_2_16zxxx.vhd
-- - one_device.vhd
--
---------------------------------------------------------------
-- Copyright (C) 2008, MEN Mikro Elektronik Nuremberg GmbH
--
--   All rights reserved. Reproduction in whole or part is
--      prohibited without the written permission of the
--                    copyright owner.
---------------------------------------------------------------
--                         History                                    
---------------------------------------------------------------
-- $Revision: 1.2 $
--  
-- $Log: fpga_pkg_2_16zxxx.vhd,v $
-- Revision 1.2  2009/02/17 11:37:40  FWombacher
-- cosmetics due to rule checker
--
-- Revision 1.1  2008/11/21 15:16:56  FWombacher
-- Initial Revision
--
-- Revision 1.1  2008/10/24 16:39:57  FWombacher
-- Initial Revision
--
-- Revision 1.1  2008/10/22 14:19:16  FWombacher
-- Initial Revision
--
--
--  
--
---------------------------------------------------------------
  
LIBRARY ieee;
USE ieee.std_logic_1164.ALL; 

LIBRARY work;
USE work.fpga_pkg_2.all;    
  
ENTITY fpga_pkg_2_16zxxx IS
   GENERIC (
      FPGA_FAMILY : family_type := CYCLONE
   );
   PORT(
      dummy : OUT std_logic
     );
END ENTITY;

ARCHITECTURE fpga_pkg_2_16zxxx_arch OF fpga_pkg_2_16zxxx IS

   CONSTANT SUPPORTED_DEVICES : supported_family_type := (CYCLONE); 

   COMPONENT one_device
   GENERIC (
      FPGA_FAMILY : family_type := NONE -- use NONE to force definiton in top level file
      );
   PORT
   (
      dummy : OUT std_logic
   );
   END COMPONENT;
   
BEGIN  
   
-- coverage off                     
ASSERT NOT NO_VALID_DEVICE(supported_device => SUPPORTED_DEVICES, device => FPGA_FAMILY) REPORT "No valid DEVICE!" SEVERITY failure; 
-- coverage on
   
   the_one_device : one_device
      GENERIC MAP (
         FPGA_FAMILY    => FPGA_FAMILY       -- use NONE to force definiton in top level file
      )
      PORT MAP (
         dummy => dummy
      );

END ARCHITECTURE fpga_pkg_2_16zxxx_arch;
  
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   