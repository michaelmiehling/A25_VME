---------------------------------------------------------------
-- Title         : fpga_pkg_2 example for one device
-- Project       : 
---------------------------------------------------------------
-- File          : one_device.vhd
-- Author        : Florian Wombacher
-- Email         : Florian.Wombacher@men.de
-- Organization  : MEN Mikro Elektronik Nuremberg GmbH
-- Created       : 08/10/17
---------------------------------------------------------------
-- Simulator     : 
-- Synthesis     : 
---------------------------------------------------------------
-- Description :
-- exampel for fpga_pkg_2 usage
---------------------------------------------------------------
-- Hierarchy:
-- 
---------------------------------------------------------------
-- Copyright (C) 2008, MEN Mikroelektronik Nuernberg GmbH
--
--   All rights reserved. Reproduction in whole or part is 
--      prohibited without the written permission of the 
--                    copyright owner.           
---------------------------------------------------------------
--                         History
---------------------------------------------------------------
-- $Revision: 1.3 $
--
-- $Log: one_device.vhd,v $
-- Revision 1.3  2008/11/21 15:17:01  FWombacher
-- changed name of the fpga_pkg to allow use together with local version
--
-- Revision 1.2  2008/10/24 16:40:02  FWombacher
-- more deatiled exampels
--
-- Revision 1.1  2008/10/22 14:19:19  FWombacher
-- Initial Revision
--
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY work;
USE work.fpga_pkg_2.all;

ENTITY one_device IS
GENERIC (
   FPGA_FAMILY : family_type := NONE -- use NONE to force definiton in top level file
   );
PORT
(
   dummy : OUT std_logic
);
END one_device;


ARCHITECTURE one_device_arch OF one_device IS

COMPONENT cyclone_implementation
PORT
(
   dummy : OUT std_logic
); 
END COMPONENT;

BEGIN
            
   gen_cyc : IF (FPGA_FAMILY = CYCLONE) GENERATE
      the_cyclone_implementation : cyclone_implementation
      PORT MAP (
         dummy => dummy
      );
   END GENERATE;



END one_device_arch;
      
