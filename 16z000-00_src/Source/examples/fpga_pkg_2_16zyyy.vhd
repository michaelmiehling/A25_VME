---------------------------------------------------------------
-- Title         : fpga_pkg_2 example for IP-Core top file
-- Project       : 
---------------------------------------------------------------
-- File          : fpga_pkg_2_16zyyy.vhd
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
-- fpga_pkg_2_16zyyy.vhd
-- - many_devices.vhd         
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
-- $Log: fpga_pkg_2_16zyyy.vhd,v $
-- Revision 1.2  2009/02/17 11:37:42  FWombacher
-- cosmetics due to rule checker
--
-- Revision 1.1  2008/11/21 15:16:57  FWombacher
-- Initial Revision
--
-- Revision 1.1  2008/10/24 16:39:58  FWombacher
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
  
ENTITY fpga_pkg_2_16zyyy IS
   GENERIC (
      FPGA_FAMILY : family_type := CYCLONE
   );
   PORT(
      dummy : IN std_logic
     );
END ENTITY;

ARCHITECTURE fpga_pkg_2_16zyyy_arch OF fpga_pkg_2_16zyyy IS

   CONSTANT SUPPORTED_DEVICES : supported_family_types := (CYCLONE, CYCLONE2, A3P, ARRIA_GX); 

   COMPONENT many_devices
   GENERIC (
      FPGA_FAMILY : family_type := NONE -- use NONE to force definiton in top level file
      );
   PORT
   (
      dummy : IN std_logic
   );
   END COMPONENT;

BEGIN  
   
-- coverage off                     
ASSERT NOT NO_VALID_DEVICE(SUPPORTED_DEVICES => SUPPORTED_DEVICES, device => FPGA_FAMILY) REPORT "No valid DEVICE!" SEVERITY failure; 
-- coverage on
   
   the_many_devices : many_devices
      GENERIC MAP (
         FPGA_FAMILY    => FPGA_FAMILY       -- use NONE to force definiton in top level file
      )
      PORT MAP (   
         dummy => dummy
      );  
         
END ARCHITECTURE fpga_pkg_2_16zyyy_arch;
  
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   