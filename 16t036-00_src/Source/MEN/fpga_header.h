/***********************  I n c l u d e  -  F i l e  ***********************/
/*!
 *        \file: fpga_header.h
 *
 *       \author kp
 *        $Date: 2007/08/20 17:30:29 $
 *    $Revision: 2.6 $
 *
 *        \brief Layout of FPGA header to be put at the beginning of FPGA
 *				 code images
 *
 *     \switches -
 */
/*-------------------------------[ History ]---------------------------------
 *
 * $Log: fpga_header.h,v $
 * Revision 2.6  2007/08/20 17:30:29  MRoth
 * cosmetics in documentation
 *
 * Revision 2.5  2007/08/02 13:00:03  rt
 * added:
 * - date field in FPGA_LONGHEADER
 *
 * Revision 2.4  2005/06/23 16:03:27  kp
 * Copyright line changed
 *
 * Revision 2.3  2004/12/16 10:23:16  cs
 * Split original and long header into two seperate structures
 * cosmetics (changed comments to be doxygen compliant, enhanced docu)
 *
 * Revision 2.2  2004/11/30 18:05:03  cs
 * Added defines and struct extensions for long (0x100) FPGA headers to be used
 * with FPGA_LOAD (13Z100-xx) tool
 *
 * Revision 2.1  2002/09/02 11:38:56  kp
 * Initial Revision
 *
 *---------------------------------------------------------------------------
 * (c) Copyright 2002 by MEN Mikro Elektronik GmbH, Nuremberg, Germany
 ****************************************************************************/

#ifndef _FPGA_HEADER_H
#define _FPGA_HEADER_H

#ifdef __cplusplus
	extern "C" {
#endif

/*--------------------------------------+
|   DEFINES                             |
+--------------------------------------*/
#define FPGA_HEADER_MAGIC 0x8E26D451	 /**< Magic number for original header */
#define FPGA_LONGHEADER_MAGIC 0x8E26D452 /**< Magic number for long header */

#define FPGA_SIZE_HEADER_SHORT 0x030	/**< length of original FPGA header */
#define FPGA_SIZE_HEADER_LONG  0x100    /**< length of long FPGA header */
/*--------------------------------------+
|   TYPDEFS                             |
+--------------------------------------*/

/** Original header to be put in front of FPGA netto data (48 bytes) */
/*!
 * All 32 bit fields are in big endian format!
 * Strings are null-terminated ASCII strings.
 * header size must always be a multiple of 4
 */
typedef struct {
	u_int32 magic;				/**< magic word (see above: FPGA_HEADER_MAGIC) */
	char 	fileName[16];		/**< file name of org. FPGA file */
	char 	fpgaType[16];		/**< identifier for FPGA HW type */
	u_int32 size;				/**< size in bytes of FPGA netto data */
	u_int32 chksum;				/**< 32 bit XOR checksum over FPGA netto data */
	u_int32 rsvd[1];			/**< for future use */
} FPGA_HEADER;
/* FPGA netto data follows here. Must be padded to 4 bytes boundary */

/** Long header to be put in front of FPGA netto data (256 bytes) */
/*!
 * This header is mainly used, if FPGA configuration can be / is updated
 * with the FPGA_LOAD tool
 *
 * All 32 bit fields are in big endian format!
 * Strings are null-terminated ASCII strings.
 * header size must always be a multiple of 4
 */
typedef struct {
	u_int32 magic;			/**< magic word (see above: FPGA_LONGHEADER_MAGIC) */
	char 	fileName[28];	/**< file name of org. FPGA file */
	char 	fpgaType[16];	/**< identifier for FPGA HW type */
	u_int32 size;			/**< size in bytes of FPGA netto data */
	u_int32 chksum;			/**< 32 bit XOR checksum over FPGA netto data */
 	u_int32 date[2];		/**< date/time of creation of binary input file
								 e.g. 0x07 d7 07 13  0f 26 00 00
   								   =    2007 . 7.19  15:38 Uhr */

	char 	boardType[16];	/**< identifier for BOARD type,
							 *<br> !! fully compared before update !! */
	u_int32 offset[4];		/**< offset of FPGA configurations in the Flash */
							/*!< offset[0-3] is only used for boards which are
							 *   programmed through the fpga_load tool, and
							 *   are only meaningful in the header of the
							 *   fallback FPGA file.
							 *   The fallback fpga configuration is not to be
							 *   listed in this offsets. 0ffset[0] is the first
							 *   regular FPGA configuration. */
	u_int32 rsvd1[40];		/**< for future use */
} FPGA_LONGHEADER;
/* FPGA netto data follows here. Must be padded to 4 bytes boundary */

/*--------------------------------------+
|   EXTERNALS                           |
+--------------------------------------*/
/* none */

/*--------------------------------------+
|   GLOBALS                             |
+--------------------------------------*/
/* none */

/*--------------------------------------+
|   PROTOTYPES                          |
+--------------------------------------*/
/* none */


#ifdef __cplusplus
	}
#endif

#endif	/* _FPGA_HEADER_H */

