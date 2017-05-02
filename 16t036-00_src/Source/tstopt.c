/*********************  P r o g r a m  -  M o d u l e ***********************/
/*!
 *        \file  tstopt.c
 *
 *      \author  see
 *        $Date: 2009/07/22 13:27:01 $
 *    $Revision: 1.9 $
 *
 *     \project  UTL library
 *  	 \brief  Test command line options
 *    \switches  none
 */
/*-------------------------------[ History ]---------------------------------
 *
 * $Log: tstopt.c,v $
 * Revision 1.9  2009/07/22 13:27:01  dpfeuffer
 * R: Generate doxygen documentation for MDIS5
 * M: file and function headers changed for doxygen
 *
 * Revision 1.8  2009/03/31 10:56:41  ufranke
 * cosmetics
 *
 * Revision 1.7  2005/06/30 10:46:35  UFranke
 * cosmetics
 *
 * Revision 1.6  1998/11/05 09:42:59  see
 * UTL_Illiopt: check for empty option ('-')
 *
 * Revision 1.5  1998/09/18 15:31:58  see
 * include string.h for strchr() prototype
 *
 * Revision 1.4  1998/08/11 16:16:57  Schmidt
 * index() replaced with strchr()
 * UTL_Tstopt()  : prototype 'index()' removed
 * UTL_Illiopt() : prototype 'index()' removed
 *
 * Revision 1.3  1998/08/10 10:58:34  see
 * UTL_Illopt: error message buffer is now passed as arg
 *
 * Revision 1.2  1998/08/10 10:44:36  see
 * UTL_Tstopt: ":" and "!" format no longer supported
 * UTL_Tstopt: return NULL instead of exit()
 * UTL_Tstopt: default arg removed
 * UTL_Illopt: format checking is now done
 * UTL_Illopt: returns now error message
 *
 * Revision 1.1  1998/07/02 15:29:17  see
 * Added by mcvs
 *
 * cloned from UTI lib
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

char *UTL_tstopt_RCSid="$Id: tstopt.c,v 1.9 2009/07/22 13:27:01 dpfeuffer Exp $";

#include <MEN/men_typs.h>
#include <stdio.h>
#include <string.h>
#include <MEN/usr_utl.h>

/**********************************************************************/
/** Read command line options
 *
 *  Use UTL_TSTOPT macro for reading options, e.g.:
 *
 *	a) Options without argument: Usage "-f", Argv "-f"
 * \code
 *  flag = (UTL_TSTOPT("f") ? 1 : 0);
 * \endcode
 *
 *	b) Options with argument: Usage "-o=<arg>", Argv "-o=34"
 * \code
 *  option = ((str = UTL_TSTOPT("o=")) ? atoi(str) : 0x56);
 * \endcode
 *
 *	UTL_TSTOPT returns the option string or NULL if not found
 *
 *  For usage of the UTL_TSTOPT macro see also \ref _tstopt.\n
 *
 *  \param argc		\IN passed argc (from main)
 *  \param argv		\IN passed argv (from main)
 *  \param option   \IN option character to test, followed by
 *        			    nothing : no argument
 *					    '=' : argument required
 *  \return			option string or NULL if option not found
 */
char *UTL_Tstopt(
	int argc,
	char **argv,
	char *option
)	
{
	int i;
	char *p,*p1,*p2;
		
	for(i=1; i<argc; i++){
		if(*argv[i] != '-')
			continue;

		if(!(p2 = strchr(argv[i],'=')))
			p2 = (char *)-1;

		if((p = strchr(argv[i],option[0])) && (p < p2)){

			if(*(p+1) != '=')
				p1 = NULL;
			else
				p1 = (char *)-1;

			if( strlen(option) == 1 ){		/* option without argument */
				return (char *)-1;
			}
			else {
				if (option[1] == '=') {		/* option requires an argument */
					if(p1 == NULL)
						return NULL;		/* say: option not found */
					else
						return p+2;
				}
			}
		}	
	}

	return NULL;	/* say: option not found */
}

/**********************************************************************/
/** Check command line options
 *
 *  Returns error message string if failed.
 *
 *	Use UTL_ILLIOPT macro for checking options, e.g.:
 * \code
 *  if ((errstr = UTL_ILLIOPT("o=f?", errbuf))) {
 *	    printf("*** %s\n", errstr);
 *	    return(1);
 *  }
 * \endcode
 *
 *	NOTE: Don't forget to add the help request '?' to the opts
 *
 *  For usage of the UTL_ILLIOPT macro see also \ref _tstopt.\n
 *
 *  \param argc		\IN passed argc (from main)
 *  \param argv		\IN passed argv (from main)
 *  \param opts     \IN set of option characters to test, followed by
 *               	    nothing : no argument
 *               	    '=' : argument required
 *  \param errstr   \OUT filled error string buffer (size=40)
 *  \return			success (NULL) or error string
 */
char *UTL_Illiopt(
	int argc,
	char **argv,
	char *opts,
	char *errstr
)
{
	int i;
	char *p,*o;

	for(i=1; i<argc; i++){
		p = argv[i];

		/* not an argument */
		if(*p != '-')
			continue;

		p++;	/* skip '-' */

		/* empty option ('-') */
		if(*p == 0){
			sprintf(errstr,"empty option '-'");
			return(errstr);
		}

		/* option not found */
		if((o = strchr(opts,*p)) == NULL){
			sprintf(errstr,"unrecognized option '-%c'",*p);
			return(errstr);
		}

		/* missing argument */
		if (o[1]=='=' && p[1]==0){
			sprintf(errstr,"option '-%c' requires an argument",*p);
			return(errstr);
		}

		/* illegal argument */
		if (o[1]!='=' && p[1]!=0){
			sprintf(errstr,"option '-%c' expects no argument",*p);
			return(errstr);
		}
	}

	return(NULL);	/* all was ok. */
}
