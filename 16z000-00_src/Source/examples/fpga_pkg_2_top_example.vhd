---------------------------------------------------------------
-- Title         : fpga_pkg_2 example for top file
-- Project       : 
---------------------------------------------------------------
-- File          : fpga_pkg_2_top.vhd
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
-- fpga_pkg_2_top.vhd
-- - fpga_pkg_2_16zxxx.vhd
-- - - one_device.vhd
-- - fpga_pkg_2_16zyyy.vhd
-- - - many_devices.vhd         
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
-- $Log: fpga_pkg_2_top_example.vhd,v $
-- Revision 1.2  2009/02/17 11:37:37  FWombacher
-- cosmetics due to rule checker
--
-- Revision 1.1  2008/11/21 15:16:55  FWombacher
-- Initial Revision
--
-- Revision 1.2  2008/10/24 16:39:55  FWombacher
-- more deatiled exampels
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
  
ENTITY fpga_pkg_2_top IS
   PORT(
      dummy_o : OUT std_logic;
      dummy_i : IN  std_logic
     );
END ENTITY;

ARCHITECTURE fpga_pkg_2_top_arch OF fpga_pkg_2_top IS

   CONSTANT  FPGA_FAMILY : family_type := CYCLONE;
   
   COMPONENT fpga_pkg_2_16zxxx
   GENERIC (
      FPGA_FAMILY : family_type := NONE -- use NONE to force definiton in top level file
      );
   PORT
   (
      dummy : OUT std_logic
   );
   END COMPONENT;
   
   COMPONENT fpga_pkg_2_16zyyy
   GENERIC (
      FPGA_FAMILY : family_type := NONE -- use NONE to force definiton in top level file
      );
   PORT
   (
      dummy : IN std_logic
   );
   END COMPONENT;

BEGIN  

   the_one_device : fpga_pkg_2_16zxxx
      GENERIC MAP (
         FPGA_FAMILY    => FPGA_FAMILY       -- use NONE to force definiton in top level file
      )
      PORT MAP (
         dummy => dummy_o
      );

   the_fpga_pkg_2_16zyyy : fpga_pkg_2_16zyyy
      GENERIC MAP (
         FPGA_FAMILY    => FPGA_FAMILY       -- use NONE to force definiton in top level file
      )
      PORT MAP (   
         dummy => dummy_i
      );  
          
END ARCHITECTURE fpga_pkg_2_top_arch;
  
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   