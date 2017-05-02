/***********************  I n c l u d e  -  F i l e  ************************
 *
 *         Name: usr_oss.h
 *
 *       Author: uf
 *        $Date: 2010/10/27 10:11:58 $
 *    $Revision: 1.24 $
 *
 *  Description: User mode system services
 *
 *     Switches: NO_CALLBACK, NO_SHARED_MEM, __MAPILIB
 *
 *-------------------------------[ History ]---------------------------------
 *
 * $Log: usr_oss.h,v $
 * Revision 1.24  2010/10/27 10:11:58  cs
 * R: unbind USR_OSS from MDIS_API
 * M: change prototypes using MDIS_PATH to use U_INT32_OR64
 *
 * Revision 1.23  2010/02/25 18:05:00  amorbach
 * R: driver ported to MDIS5, new MDIS_API and men_typs
 * M: Change type of path to MDIS_PATH
 *
 * Revision 1.22  2008/10/16 11:51:08  CKauntz
 * R: stack overflow at signalHandler call
 * M: Fixed calling convention for UOS_SigInit
 *
 * Revision 1.21  2007/02/22 17:22:57  DPfeuffer
 * UOS_SigInit() declaration changed back
 * (because backward compatibility problems with common example programs)
 *
 * Revision 1.20  2007/02/22 16:25:18  DPfeuffer
 * UOS_SigInit() declaration changed
 *
 * Revision 1.19  2003/05/07 12:22:54  kp
 * added UOS_ErrStringTs
 *
 * Revision 1.18  2003/02/21 12:17:55  kp
 * added UOS_ErrnoSet
 *
 * Revision 1.17  2000/08/03 15:43:43  Schmidt
 * __MAPILIB added to all prototypes to enable OS specific calling convention
 *
 * Revision 1.16  2000/03/31 12:08:19  Schmidt
 * NO_SHARED_MEM/NO_CALLBACK switch added for MDIS without shared mem/callback
 *
 * Revision 1.15  1999/07/09 15:09:38  Franke
 * changed UOS_CallbackMask()/UOS_CallbackUnMask() now return with an error code
 *
 * Revision 1.14  1999/04/23 13:31:18  kp
 * Added double linked list typedefs and prototypes
 *
 * Revision 1.13  1999/02/15 14:08:38  see
 * OSS_FKT_VOIDP1/2 typedefs added for easy casting function pointers
 * UOS_SharedMemXXX prototypes changed
 *
 * Revision 1.12  1998/11/03 12:58:49  Schmidt
 * prototype UOS_Errstring() removed
 *
 * Revision 1.11  1998/09/18 12:32:23  see
 * UOS_ErrString prototype added
 * error codes removed (now in usr_err.h)
 *
 * Revision 1.10  1998/09/18 11:39:26  Schmidt
 * error codes changed because ERR_UOS_TIMEOUT and ERR_UOS_OVERRUN was the same
 *
 * Revision 1.9  1998/08/26 16:48:08  Schmidt
 * prototype UOS_Errstring() added
 *
 * Revision 1.8  1998/08/20 11:27:02  see
 * ERR_UOS_MEM_ALLOC error added
 * ERR_UOS_GETSTAT, ERR_UOS_SETSTAT errors added
 * callback prototypes added
 *
 * Revision 1.7  1998/08/07 14:04:38  see
 * prototype was wrong
 *
 * Revision 1.6  1998/08/07 13:52:05  see
 * rechanged prototypes UOS_Delay()
 * error codes added
 * prototypes added
 *
 * Revision 1.5  1998/07/16 12:00:54  Franke
 * rechanged prototypes UOS_ErrnoGet() UOS_Delay()
 *
 * Revision 1.4  1998/07/02 16:12:28  see
 * prototypes changed
 *
 * Revision 1.3  1998/07/02 15:34:15  see
 * prototypes added
 *
 * Revision 1.2  1998/07/02 11:11:05  see
 * UOS_Delay prototype changed: return type is now int32
 * UOS_ErrnoGet prototype changed: return type is now int32
 * error codes added (ERR_UOS is defined in usr_os.h)
 * prototypes added
 *
 * Revision 1.1  1998/02/23 11:29:46  franke
 * initial
 *
 *---------------------------------------------------------------------------
 * (c) Copyright 1997-2000 by MEN mikro elektronik GmbH, Nuernberg, Germany
 ****************************************************************************/

#ifndef _USR_OSS_H_
#	define _USR_OSS_H_

#ifdef __cplusplus
	extern "C" {
#endif

#include <MEN/usr_os.h>

/*--------------------------------------+
|   DEFINES                             |
+--------------------------------------*/
/* limits */
#define UOS_MAX_USEC	1000000		/* max mikrodelay */

/*--------------------------------------+
|   TYPDEFS                             |
+--------------------------------------*/
/* for easy casting function pointers (callback) */
typedef void (*UOS_FKT_VOIDP1)(void*);
typedef void (*UOS_FKT_VOIDP2)(void*, void*);

typedef struct UOS_DL_NODE {	/* Double linked list node */
	struct UOS_DL_NODE *next;
	struct UOS_DL_NODE *prev;
} UOS_DL_NODE;

typedef struct {		/* Double linked list header */
	UOS_DL_NODE *head;
	UOS_DL_NODE *tail;
	UOS_DL_NODE *tailpred;
} UOS_DL_LIST;

/*--------------------------------------+
|   PROTOTYPES                          |
+--------------------------------------*/
#ifndef __MAPILIB
#	define __MAPILIB
#endif

/* general */
extern char*   __MAPILIB UOS_Ident(void);
extern u_int32 __MAPILIB UOS_ErrnoGet(void);
extern u_int32 __MAPILIB UOS_ErrnoSet(u_int32 errCode);
extern char*   __MAPILIB UOS_ErrString(int32 errCode);
extern char*   __MAPILIB UOS_ErrStringTs(int32 errCode, char *strBuf);
extern int32   __MAPILIB UOS_KeyPressed(void);
extern int32   __MAPILIB UOS_KeyWait(void);
extern u_int32 __MAPILIB UOS_Random(u_int32 old);
extern u_int32 __MAPILIB UOS_RandomMap(u_int32 val, u_int32 ra, u_int32 re);
extern u_int32 __MAPILIB UOS_MsecTimerGet(void);
extern u_int32 __MAPILIB UOS_MsecTimerResolution(void);
extern int32   __MAPILIB UOS_Delay(u_int32 msec);
extern int32   __MAPILIB UOS_MikroDelayInit(void);
extern int32   __MAPILIB UOS_MikroDelay(u_int32 usec);

/* signal handling */
extern int32 __MAPILIB UOS_SigInit(void (__MAPILIB *sigHandler)(u_int32 sigCode));
extern int32 __MAPILIB UOS_SigExit(void);
extern int32 __MAPILIB UOS_SigInstall(u_int32 sigCode);
extern int32 __MAPILIB UOS_SigRemove(u_int32 sigCode);
extern int32 __MAPILIB UOS_SigMask(void);
extern int32 __MAPILIB UOS_SigUnMask(void);
extern int32 __MAPILIB UOS_SigWait(u_int32 msec, u_int32 *sigCodeP);

/* callback */
#ifndef NO_CALLBACK
extern int32 __MAPILIB UOS_CallbackInit(INT32_OR_64 path,UOS_CALLBACK_HANDLE **cbHdlP);
extern int32 __MAPILIB UOS_CallbackExit(UOS_CALLBACK_HANDLE **cbHdlP);
extern int32 __MAPILIB UOS_CallbackSet(UOS_CALLBACK_HANDLE *cbHdl,u_int32 callNr,
                                       void (*funct)(void *appArg, void *drvArg),
                                       void *appArg);
extern int32 __MAPILIB UOS_CallbackClear(UOS_CALLBACK_HANDLE *cbHdl,u_int32 callNr);
extern int32 __MAPILIB UOS_CallbackMask(UOS_CALLBACK_HANDLE *cbHdl);
extern int32 __MAPILIB UOS_CallbackUnMask(UOS_CALLBACK_HANDLE *cbHdl);
#endif

/* shared memory */
#ifndef NO_SHARED_MEM
extern int32 __MAPILIB UOS_SharedMemInit(INT32_OR_64 path,UOS_SHMEM_HANDLE **smHdlP);
extern int32 __MAPILIB UOS_SharedMemExit(UOS_SHMEM_HANDLE **smHdlP);
extern int32 __MAPILIB UOS_SharedMemSet(UOS_SHMEM_HANDLE *smHdl,u_int32 smNr,
										u_int32 size,void **appAddrP);
extern int32 __MAPILIB UOS_SharedMemLink(UOS_SHMEM_HANDLE *smHdl,u_int32 smNr,
										 u_int32 *sizeP,void **appAddrP);
extern int32 __MAPILIB UOS_SharedMemClear(UOS_SHMEM_HANDLE *smHdl,u_int32 smNr);
#endif

/* double linked list */
extern UOS_DL_LIST* __MAPILIB UOS_DL_NewList(UOS_DL_LIST *l);
extern UOS_DL_NODE* __MAPILIB UOS_DL_Remove(UOS_DL_NODE *n);
extern UOS_DL_NODE* __MAPILIB UOS_DL_RemHead(UOS_DL_LIST *l);
extern UOS_DL_NODE* __MAPILIB UOS_DL_AddTail(UOS_DL_LIST *l,UOS_DL_NODE *n);

#ifdef __cplusplus
	}
#endif

#endif /*_USR_OSS_H_*/
















