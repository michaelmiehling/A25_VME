//-------------------------------------------------------------
// Title         : Binary data to intel hex
// Project       : 1303_MEN_G204
//-------------------------------------------------------------
// File          : bin2ihex.cpp
// Author        : Andreas Geissler
// Email         : Andreas.Geissler@men.de
// Organization  : MEN Mikroelektronik Nuernberg GmbH
// Created       : 30/10/13
//-------------------------------------------------------------
// Compiler      : MinGW 4.8, g++
//-------------------------------------------------------------
// Description :
// This programm converts a file to intel hex format. The bytes
// and the bits can be swapped. Any offset within the file can
// be chosen as well as the maximum bytes which should be
// converted. This intel hex file can be implemented in JIC
// files and read from quartus software directly.
//
// see http://de.wikipedia.org/wiki/Intel_HEX
//-------------------------------------------------------------
// Copyright (c) 2016, MEN Mikro Elektronik GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//-------------------------------------------------------------
//                         History
//-------------------------------------------------------------
// $Revision: 1.3 $
//
// $Log: bin2ihex.cpp,v $
// Revision 1.3  2015/09/11 16:11:16  AGeissler
// R1: Forget to update revision
// M1: Updated revision
//
// Revision 1.2  2015/09/11 15:57:16  AGeissler
// R1: Quatus seems to interpret the HEX files for RAM initial files different.
//     The address is not interpreted as byte address but as word address
// M1: Added a option (= -w) to create HEX files with word addresses
//
// Revision 1.1  2013/11/04 13:46:41  AGeissler
// Initial Revision
//
//
//
//-------------------------------------------------------------

/* Include */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <fstream>
#include <iomanip>
using namespace std;

/* Defines */
#define REVISION "1.2"

/* Functions */
void usage();
int gen_ihex(ifstream &file_in, ofstream &file_out, int max_bytes, unsigned int offset, bool big_endian, bool word_wise_count);
int swap_bits_within_byte(ifstream &file_in, ofstream &file_out);

int main(int argc, char *argv[])
{

    /* Files */
    char *file_in_name = NULL;
    char *file_out_name = NULL;
    const char file_tmp_name[] = "bin2ihex.tmp";
    ifstream file_in;
    ofstream file_out;
    ofstream file_tmp;

    /* Configuration */
    bool file_in_is_set = false;
    bool file_out_is_set = false;
	bool swap = false;
    bool big_endian = false;
    bool word_wise_count = false;
    unsigned int offset = 0;
    int max_bytes = -1; /* -1 for whole file */

    if(argc < 2)
    {
        usage();
        return -1;
    }

	/* Check arguments */
    for(int i = 1 ; i < argc; i++)
    {
        if (argv[i][0] == '-')
        {
            switch (argv[i][1])
            {
            case 's':
                cout << " -> selected swap option" << endl;
                swap = true;
                break;

            case 'b':
                cout << " -> selected big endian" << endl;
                big_endian = true;
                break;

            case 'v':
                cout << endl
                     << "Programm        : bin2ihex.exe                           " << endl
                     << "Author          : Andreas Geissler                       " << endl
                     << "Email           : Andreas.Geissler@men.de                " << endl
                     << "Organization    : MEN Mikroelektronik Nuernberg GmbH     " << endl
                     << "Created         : 30/10/13                               " << endl
                     << "License         : GPLv3                                  " << endl
                     << "Current version : " << REVISION << "\n" << endl;
                return 0;
                break;

            case 'h':
                usage();
                return 0;
                break;

			case 'm':
                if(!strncmp((argv[i]+2), "=0x", 3))
				{
                    max_bytes = strtol(argv[i]+5, NULL, 16);
                    if(max_bytes != -1)
                        cout << " -> selected maximum address = 0x" << hex << max_bytes << endl;
                    else
                        cout << " -> selected whole file" << endl;
                    break;
				}
				else
				{
					cout << " wrong argument for option m: " << (argv[i]+2) << endl;
					usage();
					return -1;
				}

            case 'w':
                cout << " -> selected word wise counting" << endl;
                word_wise_count = true;
                break;

            case 'o':
                if(!strncmp((argv[i]+2), "=0x", 3))
                {
                    offset = strtol(argv[i]+5, NULL, 16);
                    cout << " -> selected offset address = 0x" << hex << offset << endl;
                    break;
                }
                else
                {
                    cout << " wrong argument for option o: " << (argv[i]+2) << endl;
                    usage();
                    return -1;
                }
			
            default:
                cout << "Unkown option " << argv[i] << endl;
                usage();
                return -1;
            }
        }
        else
        {
            if(file_in_is_set == false)
            {
                cout << "File in  = " << argv[i] << endl;
                file_in_name = argv[i];
                file_in_is_set = true;
            }
            else
            {
                cout << "File out = " << argv[i] << endl;
                file_out_name = argv[i];
                file_out_is_set = true;
            }
        }
    }
	
    /* Check if given filenames are equal or equal to temp filename */
    if(!strcmp(file_in_name, file_out_name))
    {
        cout << "Input file name must not match output file: " << file_in_name << "!" << endl;
        return -1;
    }
    if(!strcmp(file_in_name, file_tmp_name))
    {
        cout << "Input file name must not match tmp file: " << file_tmp_name << "!" << endl;
        return -1;
    }
    if(!strcmp(file_out_name, file_tmp_name))
    {
        cout << "Output file name must not match tmp file: " << file_tmp_name << "!" << endl;
        return -1;
    }

	/* Open files */
    file_in.open(file_in_name, ios::in | ios::binary);
    if(file_in.fail())
    {
        if(!file_in_is_set)
            cout << "Missing input file!" << endl;
        else
            cout << "Could not open " << file_in_name << "!" << endl;
        return -1;
    }
	
	file_out.open(file_out_name, ios::out | ios::binary);
    if(file_out.fail())
    {
        if(!file_out_is_set)
            cout << "Missing output file!" << endl;
        else
            cout << "Could not open " << file_out_name << "!" << endl;
        return -1;
    }
    cout << endl;

	/* Swap bits if option -s */
	if(swap)
	{
		/* Generate temp file with swapped bits within byte */
        file_tmp.open(file_tmp_name, ios::out | ios::binary | ios_base::trunc);
        if(file_tmp.fail())
		{
            cout << "Could not open " << file_tmp_name << "!" << endl;
			return -1;
		}
        cout << "Swap all bits within a byte of file " << file_in_name << endl;
        swap_bits_within_byte(file_in, file_tmp);

        /* Close all files */
        file_in.close();
		file_out.close();
        file_tmp.close();
		
        /* Reopen out|in file */
        file_in.open(file_tmp_name, ios::out | ios::binary);
		if(file_in.fail())
		{
            cout << "Could not open " << file_tmp_name << "!" << endl;
			return -1;
        }

        /* Open out file as in for intel hex conversion */
        file_out.open(file_out_name, ios::out | ios::binary);
        if(file_out.fail())
        {
            cout << "Could not open " << file_out_name << "!" << endl;
            return -1;
        }
	}
	
	/* Generate ihex file */
    cout << "Convert " << file_in_name << "(binary) to " << file_out_name << "(intel hex):" << endl;
    gen_ihex(file_in, file_out, max_bytes, offset, big_endian, word_wise_count);
	
	file_in.close();
	file_out.close();
}

/*---------------------------------------------------------------------------------+
 * Convert file_in to intel hex format and write it back to file_out               *
 *  - max_bytes       : the conversion is stopped if the given number of bytes is  *
 *                      reached. use -1 for whole file.                            *
 *  - offset          : offset from which byte address the conversion should be    *
 *                      started                                                    *
 *  - big_endian      : if true the bytes of each word(4x bytes) are swapped       *
 *                      big-endian <=> little-endian                               *
 *  - word_wise_count : if true the addresses are counted word wise                *
 +---------------------------------------------------------------------------------*/
int gen_ihex(ifstream &file_in, ofstream &file_out, int max_bytes, unsigned int offset, bool big_endian, bool word_wise_count)
{
    char char_arr[4];   /* integer 4x bytes */
    unsigned int word;
    unsigned int byte_cnt = 0;
    unsigned int checksum = 0;
    unsigned int size = 4;
    unsigned int rest;

    /* Whole file is selected */
    if (max_bytes == -1)
    {

        file_in.seekg(0, file_in.end);
        max_bytes = file_in.tellg();
        file_in.seekg(0, file_in.beg);

        cout << "File size: 0x" << hex << max_bytes << endl;
    }

    /* There is no negative address */
    if (max_bytes < 0)
        max_bytes *= -1;

    /* Rest of file when the end does not fit an integer */
    rest = max_bytes % 4;

    /* Dummy read to jump to offset */
    for(unsigned int i = 0; i < offset; i+=4)
    {
        file_in.read(char_arr, 4);
        /* check for end of file or end of Header */
        if(file_in.eof())
        {
            cout << "The offset is bigger than the file itself : offset = 0x" << hex << offset << endl;
            return -1;
        }
    }

    /* Start conversion */
    while(byte_cnt < (unsigned int)max_bytes)
    {
        /* Check if we reached the last bytes and check if there is a rest and read data from file */
        if (byte_cnt + 4 > (unsigned int)max_bytes)
        {
            file_in.read(char_arr, rest);
            size = rest;

            /* Size must never be 0 */
            if(size == 0)
                size = 1;
        }
        else
        {
            file_in.read(char_arr, 4);
            size = 4;
        }
		
        /* Swap bytes */
        word = 0;
        if(big_endian)
        {
            for(unsigned int i = 0; i < size; i++)
                word |=  ((unsigned char) char_arr[i] << ((size-1)-i)*8);
        }
        else
        {
            for(unsigned int i = 0; i < size; i++)
                word |= ((unsigned char) char_arr[i] << (i * 8));
        }

        /* Calculate checksum */
        checksum = 0;
        checksum -= size;                                   /* word size*/
        for(unsigned int i = 0; i < size; i++)
           checksum -= ((word >> ((size-1)-i)*8) & 0xff);   /* data */
        if (word_wise_count)
        {
            checksum -= ((byte_cnt/4 & 0xff00) >> 8);             /* address high */
            checksum -= ((byte_cnt/4 & 0x00ff));                  /* address low */
        }
        else
        {
            checksum -= ((byte_cnt & 0xff00) >> 8);             /* address high */
            checksum -= ((byte_cnt & 0x00ff));                  /* address low */
        }
        checksum &= 0xff;

        if (byte_cnt % 0x10000 == 0)
        {
            //-----------------------------------------------------------------------------------------
            // Intel HEX:
            //-----------------------------------------------------------------------------------------
            // Extended address (Type 4):
            // 		 || Startcode | Number of Bytes | Address | Typ |         Data          | Checksum
            // Width ||     1     |       2         |     4   |   2 |           4           |     2
            // Data  ||     :     |      02         |   0000  |  04 |  Address (high word)  | Checksum

            /* Data size bigger than 64kByte */
            /* Write intel hex data (Type 4) */
            /* add for each 64kByte an extended address */
            unsigned int ext_checksum = 0;
            ext_checksum -= 2;                          /* word size */
            ext_checksum -= 4;                          /* type */
            if (word_wise_count)
            {
                ext_checksum -= (byte_cnt/4 >> 24 & 0xff);    /* word_cnt high */
                ext_checksum -= (byte_cnt/4 >> 16 & 0xff);    /* word_cnt low */
            }
            else
            {
                ext_checksum -= (byte_cnt >> 24 & 0xff);    /* word_cnt high */
                ext_checksum -= (byte_cnt >> 16 & 0xff);    /* word_cnt low */
            }
            ext_checksum &= 0xff;

            file_out << ":02";  /* fixed word size of 4 byte */
            file_out << "0000"; /* address */
            file_out << "04";   /* type */
            file_out << std::hex << std::setw(4) <<  std::setfill('0') << ((byte_cnt >> 16) & 0xffff); /* extended address (high word) */
            file_out << std::hex << std::setw(2) <<  std::setfill('0') << ext_checksum; /* checksum */
            file_out << '\n';
        }

        //--------------------------------------------------------------------------
        // Intel HEX:
        //--------------------------------------------------------------------------
        // Normal data (Type 0):
        // 		 || Startcode | Number of Bytes | Address | Typ | Data  | Checksum
        // Width ||     1     |       2         |     4   |   2 |  2n   |     2
        // Data  ||     :     |       n         | Address |  00 | Daten | Checksum

        /* Write intel hex data (Type 0) */
        file_out << ":";                                                                                /* start symbole */
        file_out << std::hex << std::setw(2)      << std::setfill('0') << (size & 0xff);                /* fixed word size in byte */
        if (word_wise_count)
            file_out << std::hex << std::setw(4)      << std::setfill('0') << (byte_cnt/4 & 0xffff);    /* word address */
        else
            file_out << std::hex << std::setw(4)      << std::setfill('0') << (byte_cnt & 0xffff);      /* byte address */
        file_out << std::hex << std::setw(2)      << std::setfill('0') << 0;                            /* type */
        file_out << std::hex << std::setw(size*2) << std::setfill('0') << word;                         /* data */
        file_out << std::hex << std::setw(2)      << std::setfill('0') << checksum;                     /* checksum */
        file_out << '\n';
        byte_cnt += size;
    }
    /* Write end sequence */
    file_out << ":00000001FF";
    cout << "Info: BIN to QUARTUS conversion has been done" << endl;
    cout << "  0x" << hex << byte_cnt << " bytes written\n" << endl;

    return 0;
}

/*---------------------------------------------------------------------------+
 * Read each byte of file_in, swap all bits within a byte and write it back  *
 * to file_out                                                               *
 +---------------------------------------------------------------------------*/
int swap_bits_within_byte(ifstream &file_in, ofstream &file_out)
{
	char byte;
	unsigned int byte_cnt = 0;
	char byte_swapped;

    while(1)
    {
		/* read byte from file */
		file_in.read(&byte, 1);
		
		/* check for end of file or end of Header */
        if(file_in.eof())
			break;
			
		byte_swapped = 0;
		
		/* swap bits */
		for(unsigned i = 0; i < 8; i++)
		{
			if(byte & (1 << i))
                byte_swapped |= (1 << (7 - i));
		}
		
		/* write swapped byte to file */
		file_out.write(&byte_swapped, 1);
		byte_cnt++;
    }	
    cout << "Info: Bits are swapped" << endl;
    cout << "  0x" << hex << byte_cnt << " bytes written\n" << endl;

    return 0;
}

/*---------------------------------------------------------------------------+
 * Print usage of bin2hex                                                    *
 +---------------------------------------------------------------------------*/
void usage()
{
    /* Description */
    cout << "Description : " << endl;
    cout << " This programm converts a file to intel hex format. The bytes \n"
            " and the bits can be swapped. Any offset within the file can \n"
            " be chosen as well as the maximum bytes which should be \n"
            " converted. This intel hex file can be implemented in JIC \n"
            " files and read from quartus software directly. \n"
         << "Maximal file size = 2GByte.\n" << endl;
    cout << "Usage:" << endl;
    cout << "   bin2ihex.exe file_in file_out <options>\n" << endl;
	cout << "Options:" << endl;
    cout << "  -v               => tool version" << endl;
    cout << "  -h               => print this help" << endl;
    cout << "  -w               => print the address" << endl;
    cout << "  -s               => swap bits within a byte (e.g. 1000 0100 => 0010 0001)" << endl;
    cout << "  -b               => use big endian instead of little endian (swap bytes)" << endl;
    cout << "  -m=0xXXXXXXXX    => maximum bytes are converted (cut file)" << endl;
    cout << "                      Must be set with 0x<Hexdecimal>" << endl;
    cout << "  -o=0xXXXXXXXX    => offset address to the first byte of the input file, where" << endl;
    cout << "                      the conversion should be started." << endl;
    cout << "                      Must be set with 0x<Hexdecimal>" << endl;
	cout << "Example:" << endl;
    cout << "  bin2ihex.exe -b test.bin test.hex" << endl;
    cout << endl;
}
