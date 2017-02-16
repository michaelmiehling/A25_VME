---------------------------------------------------------------
-- Title         : fpga_pkg_2 example for many devices
-- Project       : 
---------------------------------------------------------------
-- File          : manny_devices.vhd
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
-- $Log: many_devices.vhd,v $
-- Revision 1.3  2008/11/21 15:16:58  FWombacher
-- changed name of the fpga_pkg to allow use together with local version
--
-- Revision 1.2  2008/10/24 16:40:00  FWombacher
-- more deatiled exampels
--
-- Revision 1.1  2008/10/22 14:19:18  FWombacher
-- Initial Revision
--
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY work;
USE work.fpga_pkg_2.all;

ENTITY many_devices IS
GENERIC (
   FPGA_FAMILY : family_type := NONE -- use NONE to force definiton in top level file
   );
PORT
(
   dummy : IN std_logic
);
END many_devices;


ARCHITECTURE many_devices_arch OF many_devices IS

COMPONENT cyclone_implementation
PORT
(
   dummy : IN std_logic
); 
END COMPONENT;

COMPONENT cyclone2_implementation
PORT
(
   dummy : IN std_logic
); 
END COMPONENT;

COMPONENT a3p_implementation
PORT
(
   dummy : IN std_logic
); 
END COMPONENT;

COMPONENT arria_gx_implementation
PORT
(
   dummy : IN std_logic
); 
END COMPONENT;
 
BEGIN
            
   gen_cyc : IF (FPGA_FAMILY = CYCLONE) GENERATE
      the_cyclone_implementation : cyclone_implementation
      PORT MAP (
         dummy => dummy
      );
   END GENERATE;

   gen_cyc2 : IF (FPGA_FAMILY = CYCLONE2) GENERATE
      the_cyclone2_implementation : cyclone2_implementation
      PORT MAP (
         dummy => dummy
      );
   END GENERATE;
   
   gen_a3p : IF (FPGA_FAMILY = A3P) GENERATE
      the_a3p_implementation : a3p_implementation
      PORT MAP (
         dummy => dummy
      );
   END GENERATE;
   
   gen_ariagx : IF (FPGA_FAMILY = ARRIA_GX) GENERATE
      the_arria_gx_implementation : arria_gx_implementation
      PORT MAP (
         dummy => dummy
      );
   END GENERATE;

END many_devices_arch;
      
