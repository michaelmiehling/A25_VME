/****************************************************************************
 ************                                                    ************
 ************                    FPGA_ADDHEADER                  ************
 ************                                                    ************
 ****************************************************************************/
/*!
 *         \file fpga_addheader.c
 *       \author kp
 *        $Date: 2007/08/21 10:20:03 $
 *    $Revision: 1.7 $
 *
 *  	\brief FPGA_ADDHEADER tool adds a fileheader to a binary FPGA file
 *
 *
 *     Required: -
 *     \switches _BIG_ENDIAN_/_LITTLE_ENDIAN_
 */
 /*-------------------------------[ History ]---------------------------------
 *
 * $Log: fpga_addheader.c,v $
 * Revision 1.7  2007/08/21 10:20:03  MRoth
 * -fixed usage message
 * -removed debug output
 *
 * Revision 1.6  2007/08/20 17:30:27  MRoth
 * added:
 *   + timestamp field for long header
 *   + header dump function (parameter -d)
 *   + doxygen documentation
 * cosmetics
 *
 * Revision 1.5  2004/12/23 15:21:50  cs
 * added closing of opened files (needed for VxWorks)
 *
 * Revision 1.4  2004/12/22 12:51:35  cs
 * adapted to changes in fpga_header.h (extra structure added for long headers)
 *
 * Revision 1.3  2004/12/10 12:03:15  cs
 * added functionality for long header (0x100 Bytes)
 * changed defines _BIG_ENDIAN/_LITTLE_ENDIAN to _BIG_ENDIAN_/_LITTLE_ENDIAN_
 * cosmetics
 *
 * Revision 1.2  2002/09/10 14:19:28  kp
 * some endian fixes...
 *
 * Revision 1.1  2002/09/02 11:40:59  kp
 * Initial Revision
 *
 *---------------------------------------------------------------------------
 * Copyright (c) 2016, MEN Mikro Elektronik GmbH
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 ****************************************************************************/

static const char RCSid[]="$Id: fpga_addheader.c,v 1.7 2007/08/21 10:20:03 MRoth Exp $";

/*! \mainpage
    This is the documentation of the FPGA_ADDHEADER Tool.

    <br>This tool is written in common code and has been tested and verified under Windows, Linux and VxWorks

 	<br>This tool works under <I>_BIG_ENDIAN_</I> (e.g. PPC) and <I>_LITTLE_ENDIAN_</I> (e.g. x86) CPU types
 	if it is build with MDIS building environment

	<br><br><b>Syntax:</b>

	<br><PRE>fpga_addheader [-l] [-d] infile outfile fpgatype (boardtype) [(offset)]</code>
<br>Options:
	<b>[-l]</b>		use long fpga fileheader
	<b>[-d]</b>		dump fileheader
	<b>infile</b>		FPGA data in .BIN format (e.g. from ttf2bin)
	<b>outfile</b>		filename and format of output file
	<b>fpgatype</b>	Identifier string for FPGA type (upper case)
			e.g. FLEX1K100, FLEX1K30, EP1C12, EP1C20
Options for long fpga fileheader only:
	<b>boardtype</b>	board identifier
			(must match boardtype specified in fallback config)
	<b>[offset 0-4]</b>	offset of FPGA configurations in the flash
			offset parameters are only evaluated from the
			fallback configuration fileheader
			and are specified as hex values </PRE>

	<b>Examples for calling (DOS): </b>

	<br>- add short fileheader:

	<code> fpga_addheader_big_e a15.rbf a15_sh.fp0 EP1C12  </code>

	<br>- add long fileheader:

	<code> fpga_addheader_big_e -l EM01N00IC002A3.rbf EM01N00IC002A3.fp0 EP2C20  EM01N00 40000 80000 </code>

	<br>- dump fileheader:

	<code> fpga_addheader_big_e -d a15_lh.fp0 </code>

*/

/*! \page dummy
  \menimages
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <MEN/men_typs.h>
#include <MEN/usr_utl.h>
#include <MEN/fpga_header.h>


/*--------------------------------------+
|   TYPDEFS                             |
+--------------------------------------*/
/* none */

/*--------------------------------------+
|   DEFINES                             |
+--------------------------------------*/
#ifdef WINNT
# define stat _stat
#elif VXWORKS
# include <MEN/usr_oss.h>
#endif

#ifdef _BIG_ENDIAN_
# define SWAPWORD(w) (w)
# define SWAPLONG(l) (l)
#elif defined(_LITTLE_ENDIAN_)
# define SWAPWORD(w) ((((w)&0xff)<<8) + (((w)&0xff00)>>8))
# define SWAPLONG(l) ((((l)&0xff)<<24) + (((l)&0xff00)<<8) + \
                     (((l)&0xff0000)>>8) + (((l)&0xff000000)>>24))
#else
# error "Must define _BIG_ENDIAN_ or _LITTLE_ENDIAN_"
#endif

#if defined(_BIG_ENDIAN_) && defined(_LITTLE_ENDIAN_)
# error "Don't define _BIG/_LITTLE_ENDIAN_ together"
#endif


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
static void usage( void );
static int SetTimestamp( FPGA_LONGHEADER*, const char*);
static int HeaderDump( const char * );



/********************************* usage ***********************************/
/**  Print program usage
 */
static void usage( void )
{
	printf(
	"Syntax:      fpga_addheader [-l] [-d] <infile> <outfile> <fpgatype>\n"
	"               [<boardtype>] [<offset>]\n"
	"Function:    Add FPGA fileheader to FPGA .BIN file or dump fileheader\n"
	"Options:\n"
	"    [-l]        use long fpga fileheader\n"
	"    [-d]        dump fileheader\n"
	"    <infile>    FPGA data in binary format (e.g. *.bin from ttf2bin or *.rbf)\n"
	"    <outfile>   filename of output file\n"
	"    <fpgatype>  Identifier string for FPGA type (upper case)\n"
	"                e.g. \"FLEX1K100\", \"FLEX1K30\", \"EP1C12\", \"EP1C20\"\n"
	"Options for long fpga fileheader only:\n"
	"    <boardtype> board identifier\n"
	"                (must match boardtype specified in fallback config)\n"
	"   [offset 0-3] offset of FPGA configurations in the flash\n"
	"                offset parameters are only evaluated from the\n"
	"                fallback configuration file header\n"
	"                and are specified as hex values\n"
	"Examples:\n"
	"- add short fileheader:\n"
	"  fpga_addheader EM01N00IC002A3.rbf EM01N00IC002A3.fp0 EP2C20\n"
	"- add long fileheader:\n"
	"  fpga_addheader -l EM01N00IC002A3.rbf EM01N00IC002A3.fp0 EP2C20 EM01N00 40000 80000\n"
	"- dump fileheader\n"
	"  fpga_addheader -d EM01N00IC002A3.fp0\n"
	"\n"
	"Copyright 2002-2007 by MEN Mikro Elektronik GmbH\n%s\n", RCSid
	);
}

/********************************* main ***********************************/
/** Program main function
 *
 *
 *  \param argc       \IN  argument counter
 *  \param argv       \IN  argument vector
 *
 *  \return           success (0) or error (1)
 */
int main( int argc, char *argv[] )
{
	char *errstr,ebuf[40];
	char *inFileName=NULL,
		 *outFileName=NULL,
		 *fpgaType=NULL,
		 *boardType=NULL;
	u_int32 offset[4] = {0,0,0,0};
	FILE *inFp = NULL, *outFp = NULL;
	long inFileSize, paddedSize,i,j;
	FPGA_HEADER hdr;
	FPGA_LONGHEADER lhdr;
	void *buf;
	u_int8 long_header;
	u_int8 header_dump;
	u_int16 header_len;

	memset( &hdr, 0, sizeof(hdr));
	memset( &lhdr, 0, sizeof(lhdr));

	/*--------------------+
    |  check arguments    |
    +--------------------*/
	if ((errstr = UTL_ILLIOPT("?, l, d", ebuf))) {	/* check args */
		printf("*** %s\n", errstr);
		goto error_exit;
	}

	if (UTL_TSTOPT("?")) {						/* help requested ? */
		usage();
		goto error_exit;
	}

	long_header = (UTL_TSTOPT("l") ? 1 : 0);	/* use long header ? */
	header_dump = (UTL_TSTOPT("d") ? 1 : 0);	/* use header dump ? */

	/*--------------------+
	|  get arguments      |
	+--------------------*/
	for( i=1; i<argc; i++ ){
		if( *argv[i] != '-' ){
			if( inFileName == NULL )
				inFileName = argv[i];
			else if( outFileName == NULL )
				outFileName = argv[i];
			else if( fpgaType == NULL )
				fpgaType = argv[i];
			else if ( long_header ){
				if( boardType == NULL )
					boardType = argv[i];
				else {
					for( j=0; j<4; j++ ){
						if( (i+j) == argc )
							break;
						if( !sscanf(argv[i+j], "%x", &offset[j]) ) {
							printf("ERROR - offset %d is illegal\n", j);
							offset[j] = 0;
							goto error_exit;
						}
					}
					i += j+1;
				}
			}
		}
	}

	/*--------------------+
	|  dump fileheader    |
	+--------------------*/
	if( long_header && header_dump ){
		printf( "only one of these options (-l OR -d) are allowed at the same time\n" );
		usage();
		goto error_exit;
	}
	if(header_dump){
		if( HeaderDump( inFileName ) != 0 ){
			perror("error reading content of header\n");
			goto error_exit;
		}
		/* finish with success */
		return 0;
	}

	/* printf( "Args= %s, %s, %s, %s, 0x%08x, 0x%08x, 0x%08x, 0x%08x, 0x%08x\n",
		inFileName, outFileName, fpgaType, boardType, offset[0], offset[1], offset[2], offset[3], offset[4]);
	 */

	if( !inFileName || !outFileName || !fpgaType ){
		usage();
		goto error_exit;
	}

	/*--------------------+
	|  add fileheader	  |
	+--------------------*/
	if(long_header){
		printf("Using long header\n");
		header_len = FPGA_SIZE_HEADER_LONG;
		lhdr.magic 	= SWAPLONG(FPGA_LONGHEADER_MAGIC);
	}
	else {
		printf("Using short header\n");
		header_len = FPGA_SIZE_HEADER_SHORT;
		hdr.magic 	= SWAPLONG(FPGA_HEADER_MAGIC);
	}

	if( long_header && !boardType ){
		printf( "<boardtype> is missing for long FPGA fileheader (e.g. EM01N00)\n");
		usage();
		goto error_exit;
	}

	/* remove filename extension for file name in header */
	{
		char *p;
		int len = strlen(inFileName);

		if( (p = strrchr( inFileName, '.' )) != NULL )
			len = p - inFileName;

		if( (!long_header && (len > sizeof(hdr.fileName)-1)) ||
			( long_header && (len > sizeof(lhdr.fileName)-1)) ){
			fprintf(stderr,"input filename too long!\n");
			goto error_exit;
		}
		if(!long_header)
			strncpy( hdr.fileName, inFileName, len );
		else
			strncpy( lhdr.fileName, inFileName, len );
	}

	if( (!long_header && (strlen(fpgaType) > sizeof(hdr.fpgaType)-1 )) ||
		( long_header && (strlen(fpgaType) > sizeof(lhdr.fpgaType)-1 )) ){
		fprintf(stderr,"fpga type string too long!\n");
		goto error_exit;
	}
	if(!long_header)
		strcpy( hdr.fpgaType, fpgaType );
	else
		strcpy( lhdr.fpgaType, fpgaType );

	if( long_header ) {
		if( strlen(boardType) > sizeof(lhdr.boardType)-1 ){
			fprintf(stderr,"board type string too long!\n");
			goto error_exit;
		}
		strcpy( lhdr.boardType, boardType );
		for(j=0; j<4; j++)
			lhdr.offset[j] = SWAPLONG(offset[j]);
	}

	/*----------------------------------+
	|  Open input / create output file  |
	+----------------------------------*/
	inFp = fopen( inFileName, "rb" );
	if( inFp == NULL ){
		perror("Can't open input file");
		goto error_exit;
	}

	outFp = fopen( outFileName, "wb" );
	if( outFp == NULL ){
		perror("Can't open output file");
		goto error_exit;
	}

	/* Determine size of input file */
	fseek( inFp, 0, SEEK_END );
	inFileSize = ftell( inFp );
	fseek( inFp, 0, SEEK_SET );

	/* pad to 4 bytes */
	paddedSize = inFileSize;
	if( inFileSize & 3 )
		paddedSize += 4 - (inFileSize & 3);

	printf("fpga_addheader: infile=%s size=%d (padded %d) outfile=%s\n",
		   inFileName, inFileSize, paddedSize, outFileName );

	/* read in file */
	if( (buf = calloc( paddedSize, 1 )) == NULL ){
		perror("can't allocate buffer");
		goto error_exit;
	}

	if( fread( buf, 1, inFileSize, inFp ) != (size_t)inFileSize ){
		perror("error reading file");
		goto error_exit;
	}

	/* build XOR checksum over FPGA data (and padding bytes) */
	{
		u_int32 *p = (u_int32 *)buf, xor;

		for( xor=0,i=0; i<paddedSize/4; i++ )
			xor ^= *p++;

		hdr.chksum = xor;
		lhdr.chksum = xor;
	}

	hdr.size 	= SWAPLONG(paddedSize);
	lhdr.size 	= SWAPLONG(paddedSize);

	/* insert timestamp */
	if ( SetTimestamp( &lhdr, inFileName ) != 0 ){
		perror("error getting file dates");
		goto error_exit;
	}

	fclose(inFp);

	/* write output file */
	if( !long_header ) {
		if( fwrite( (void *)&hdr, 1, header_len, outFp ) != (size_t)header_len){
			perror("error writing header to file");
			goto error_exit;
		}
	} else {
		if( fwrite( (void *)&lhdr, 1, header_len, outFp ) != (size_t)header_len){
			perror("error writing long header to file");
			goto error_exit;
		}
	}

	if( fwrite( buf, 1, paddedSize, outFp ) != (size_t)paddedSize){
		perror("error writing FPGA data to file");
		goto error_exit;
	}

	fclose(outFp);

	return 0;

error_exit:
	if(inFp)
		fclose(inFp);
	if(outFp)
		fclose(outFp);
	return 1;

}

/********************************* SetTimestamp *****************************/
/** - adds a timestamp in the longheader of the binary output file.
 *    The timestamp is the date of the last write access to the binary input file
 *
 *	\param lhdrp		\IN	ptr to FPGA_LONGHEADER
 *	\param inFileName	\IN	file name of input file
 *
 *	\return           success (0) or error (1)
 */
static int SetTimestamp( FPGA_LONGHEADER *lhdrp, const char *inFileName ) {

	struct tm *time;
	struct stat buffer;
	char *TokenP = NULL,
		 *cdateP = NULL;
	char temp[30];
	char amonth[6];
 	char aday[5];
 	char ahour[4];
 	char amin[4];
	char asec[4];
	char ayear[7];
 	int len		= 0,
		index	= 0;
	u_int8 day	= 0,
		 month	= 0,
		 hour	= 0,
		 min	= 0,
		 sec	= 0;
	u_int16 year = 0;
	u_int32 date32, time32;

	memset(temp,'\0', sizeof(temp));

	/* Get file data and check if statistics are valid */
	if ( stat( inFileName, &buffer ) != 0 ) {	/* stat() function is POSIX not ANSI Standard! */
		printf( "ERROR: getting file data\n" );
		return 1;
	}

	/* changing month time format (e.g."Jan" in "01") */
	time = localtime( &buffer.st_mtime );

	cdateP = ctime( &buffer.st_mtime );
	len = strlen( cdateP );
	strncpy( temp, cdateP, len );

	TokenP = strtok( temp, " :" );

	/* handle all tokens */
	while ( TokenP != NULL ) {
		len = strlen( TokenP ) + 1;

		/* save tokens */
		switch( index ) {
			case 1:
					strncpy( amonth, TokenP, len );
					break;
			case 2:
					strncpy( aday, TokenP, len );
					day = atoi( aday );
					break;
			case 3:
					strncpy( ahour, TokenP, len );
					hour = atoi( ahour );
					break;
			case 4:
					strncpy( amin, TokenP, len );
					min = atoi( amin );
					break;
			case 5:
					strncpy( asec, TokenP, len );
					sec = atoi( asec );
					break;
			case 6:
					strncpy( ayear, TokenP, len );
					year = atoi( ayear );
					break;
			default:
					break;
		}
		++index;
		TokenP = strtok( NULL, " :" );
	}

	/* changes String into Ascii */
	strftime( amonth, len, "%m", time );

	month = atoi( amonth );

	/* check data */
	if( year<1900 || year>2100 || month<1 || month>12 || day<1 || day>31
		|| hour>23 || min>59 || sec>59 ) {
		printf( "ERROR: input file date is out of range (only 1900-2100)\n" );
		return 1;
	}

	printf( "Date and time of last modification of %s:\n%4d-%2s-%02s  %02s:%02s:%02s\n",
	inFileName, year, amonth, aday, ahour, amin, asec );

	/* set timestamp in reserved space */
	date32 = (( day )	<<  0 ) |
			(( month )  <<  8 ) |
			(( year )	<< 16 );

	date32 = SWAPLONG( date32 );
	lhdrp->date[0] = date32;

	time32 = (( sec )  <<  8 ) |
			 (( min )  << 16 ) |
			 (( hour ) << 24 );

	time32 = SWAPLONG( time32 );
	lhdrp->date[1] = time32;

	return 0;
}

/********************************* HeaderDump ******************************/
/** dumps the short/long header content
 *
 *	\param fileName		\IN	file name of output file
 *
 *	\return           success (0) or error (1)
*/
static int HeaderDump( const char *fileName ) {

	FILE *outFp = NULL;
	char name[28];
	char ftype[16];
	char btype[16];
	int i = 0;
	u_int32 date, time;
	u_int32 magic, chksum, size;
	u_int32 off[4];
	u_int16 y;
	u_int8 m, d, h, min, s;
	static const char smonth[][4] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
									 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

	outFp = fopen( fileName, "rb" );
	if( outFp == NULL ) {
		return 1;
	}

	fread( (void*)&magic, sizeof(u_int8), sizeof(magic), outFp );
	magic = SWAPLONG( magic );
	fseek( outFp, 0, SEEK_SET);

	if( magic == FPGA_HEADER_MAGIC ) {
		FPGA_HEADER sh;
		fread( (void*)&sh, sizeof(u_int8), sizeof(sh), outFp );

		printf("Dump fileheader\n");

		/* get data for header dump */
		magic = sh.magic;
		magic = SWAPLONG( magic );

		for ( i=0; i<16; i++ ) {
			name[i] = sh.fileName[i];
		}
		for ( i=0; i<16; i++ ) {
			ftype[i] = sh.fpgaType[i];
		}

		size = sh.size;
		size =	SWAPLONG(size);

		chksum = sh.chksum;
		chksum = SWAPLONG(chksum);

		/* output */
		printf( "\n//-------------------- Header Dump --------------------//\n" );
		printf( "\nMagic number:\t 0x%X\n", magic);
		printf( "Checksum:\t 0x%X\n", chksum );
		printf( "Size:\t\t %d\n", size );
		printf( "Input filename:\t %s.bin\n", name );
		printf( "FPGA type:\t %s\n", ftype );

	}
	else if( magic == FPGA_LONGHEADER_MAGIC ) {
		FPGA_LONGHEADER lh;
		fread( (void*)&lh, sizeof(u_int8), sizeof(lh), outFp );

		printf("Dump long fileheader\n");

		/* get data for long header dump */
		magic = lh.magic;
		magic = SWAPLONG( magic );

		size = lh.size;
		size =	SWAPLONG(size);

		chksum = lh.chksum;
		chksum = SWAPLONG(chksum);

 		date = lh.date[0];
		date =	SWAPLONG(date);

		time = lh.date[1];
		time =	SWAPLONG(time);

		y	  =	(u_int16)((date & 0xFFFF0000)	>> 16 );
		m	  =	(u_int8)((date & 0x0000FF00)	>>  8 );
		d	  =	(u_int8)((date & 0x000000FF)	>>  0 );
		h	  =	(u_int8)((time & 0xFF000000)	>> 24 );
		min   =	(u_int8)((time & 0x00FF0000)	>> 16 );
		s	  =	(u_int8)((time & 0x0000FF00)	>>  8 );

		for ( i=0; i<28; i++ ) {
			name[i] = lh.fileName[i];
		}
		for ( i=0; i<16; i++ ) {
			ftype[i] = lh.fpgaType[i];
		}
		for ( i=0; i<16; i++ ) {
			btype[i] = lh.boardType[i];
		}
		for ( i=0; i<4; i++ ) {
			off[i] = lh.offset[i];
			off[i] = SWAPLONG(off[i]);
		}

		/* output */
		printf( "\n//-------------------- Longheader Dump --------------------//\n" );
		printf( "\nDate of last modification:\n\t\t %4d %3s %02d - %02d:%02d:%02d\n",
		y, smonth[m-1], d, h, min, s );
		printf( "Magic number:\t 0x%X\n", magic);
		printf( "Checksum:\t 0x%X\n", chksum );
		printf( "Size:\t\t %d Byte\n", size );
		printf( "Input filename:\t %s.bin\n", name );
		printf( "FPGA type:\t %s\n", ftype );
		printf( "Boardtype:\t %s\n", btype );
		printf( "Offset 1-4:\t 0x%08X - 0x%08X - 0x%08X - 0x%08X \n", off[0], off[1], off[2], off[3] );
	}
	else {
		printf("*** ERR magic=0x%x\n", magic);
		return 1;
	}

	fclose(outFp);

	return 0;

}

