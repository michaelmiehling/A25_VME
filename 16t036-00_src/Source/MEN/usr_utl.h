/***********************  I n c l u d e  -  F i l e  ************************
 *
 *         Name: usr_utl.h
 *
 *       Author: see
 *        $Date: 2000/08/03 15:43:47 $
 *    $Revision: 2.6 $
 *
 *  Description: Defines and prototypes for the UTL library.
 *
 *     Switches:  __MAPILIB
 *
 *-------------------------------[ History ]---------------------------------
 *
 * $Log: usr_utl.h,v $
 * Revision 2.6  2000/08/03 15:43:47  Schmidt
 * __MAPILIB added to all prototypes to enable OS specific calling convention
 *
 * Revision 2.5  1998/08/13 10:55:46  see
 * UTL_Ident prototype added
 *
 * Revision 2.4  1998/08/11 16:12:56  Schmidt
 * include <MEN/utl_os.h> added, cosmetics
 *
 * Revision 2.3  1998/08/10 10:58:38  see
 * prototypes changed
 *
 * Revision 2.2  1998/08/10 10:44:39  see
 * prototypes changed
 *
 * Revision 2.1  1998/07/02 15:29:20  see
 * Added by mcvs
 *
 *---------------------------------------------------------------------------
 * (c) Copyright 1998-2000 by MEN mikro elektronik GmbH, Nuernberg, Germany
 ****************************************************************************/

#ifndef _USR_UTL_H
#define _USR_UTL_H

#ifdef __cplusplus
	extern "C" {
#endif

#include <MEN/utl_os.h>

/*--------------------------------------+
|   DEFINES                             |
+--------------------------------------*/
#define UTL_TSTOPT(opt) 			UTL_Tstopt(argc,argv,(opt))
#define UTL_ILLIOPT(opts,errstr)	UTL_Illiopt(argc,argv,(opts),(errstr))

/*--------------------------------------+
|   TYPDEFS                             |
+--------------------------------------*/
/* none */

/*--------------------------------------+
|   PROTOTYPES                          |
+--------------------------------------*/
#ifndef __MAPILIB
#	define __MAPILIB
#endif

extern char*   __MAPILIB UTL_Ident(void);
extern u_int32 __MAPILIB UTL_Atox(char *str);
extern char*   __MAPILIB UTL_Bindump(u_int32 data, u_int32 bits, char *buf);
extern void    __MAPILIB UTL_Memdump(char *info, char *buf, u_int32 n, u_int32 fmt);
extern char*   __MAPILIB UTL_Tstopt(int argc, char **argv, char *option);
extern char*   __MAPILIB UTL_Illiopt(int argc, char **argv, char *opts, char *errstr);

#ifdef __cplusplus
	}
#endif

#endif	/* _USR_UTL_H */



