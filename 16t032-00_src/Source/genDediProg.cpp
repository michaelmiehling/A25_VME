//-------------------------------------------------------------
// Title         : Generate Dediprog Programming File
// Project       : MAIN
//-------------------------------------------------------------
// File          : genDediProg.cpp
// Author        : Andreas Geissler
// Email         : Andreas.Geissler@men.de
// Organization  : MEN Mikroelektronik Nuernberg GmbH
// Created       : 09/03/14
//-------------------------------------------------------------
// Compiler      : g++
//-------------------------------------------------------------
// Description :
// This programm combines a raw binary file with a second raw
// binary file. The bytes and the bits can be swapped.
// Any offset within the file can be chosen. The programm
// shall be used to generate a DediProg programming file from
// and *.rbf(without MEN header) and a *.bin(with MEN header).
//
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
// $Revision: 1.1 $
//
// $Log: genDediProg.cpp,v $
// Revision 1.1  2014/10/24 10:17:38  AGeissler
// Initial Revision
//
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
#define REVISION "1.0"

/* Functions */
void usage();
int swap_bits_within_byte(ifstream &file_in, ofstream &file_out);

int main(int argc, char *argv[])
{

    /* Files */
    char *file1_in_name = NULL;
    char *file2_in_name = NULL;
    char *file_out_name = NULL;
    const char file1_swap_name[] = "genDediProg_inv_file1.tmp";
    const char file2_swap_name[] = "genDediProg_inv_file2.tmp";
    ifstream file1_in;
    ifstream file2_in;
    ofstream file_out;
    ofstream file1_swap;
    ofstream file2_swap;
    unsigned int file1_size = 0;
    unsigned int file2_size = 0;

    /* Configuration */
    bool file1_in_is_set = false;
    bool file2_in_is_set = false;
    bool file_out_is_set = false;
    bool swap = false;
    char filler = 0xFF;
    unsigned int offset = 0;
    int min_bytes = -1; /* -1 size is offset + second file */

    if(argc < 2)
    {
        usage();
        return -1;
    }

    /*-----------------------*/
    /*--- Check arguments ---*/
    /*-----------------------*/
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

            case 'v':
                cout << endl
                     << "Programm        : genDediProg.exe                        " << endl
                     << "Author          : Andreas Geissler                       " << endl
                     << "Email           : Andreas.Geissler@men.de                " << endl
                     << "Organization    : MEN Mikroelektronik Nuernberg GmbH     " << endl
                     << "Created         : 23/10/14                               " << endl
                     << "License         : GPLv3                                  " << endl
                     << "Current version : " << REVISION << "\n" << endl;
                return 0;
                break;

            case 'h':
                usage();
                return 0;
                break;

            case 'f':
                if(!strncmp((argv[i]+2), "=0x", 3))
				{
                    min_bytes = strtol(argv[i]+5, NULL, 16);
                    if(min_bytes != -1)
                        cout << " -> selected minimum file size = 0x" << hex << min_bytes << endl;
                    else
                        cout << " -> default" << endl;
                    break;
				}
				else
				{
                    cout << " wrong argument for option f: " << (argv[i]+2) << endl;
					usage();
					return -1;
				}

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

            case 'x':
                if(!strncmp((argv[i]+2), "=0x", 3))
                {
                    filler = strtol(argv[i]+5, NULL, 16);
                    cout << " -> filler = 0x" << hex << setw(2) << setfill('0') << ((int)filler & 0xFF) << endl;
                    break;
                }
                else
                {
                    cout << " wrong argument for option x: " << (argv[i]+2) << endl;
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
            if(file1_in_is_set == false)
            {
                cout << "File1 in  = " << argv[i] << endl;
                file1_in_name = argv[i];
                file1_in_is_set = true;
            }
            else if(file2_in_is_set == false)
            {
                cout << "File2 in  = " << argv[i] << endl;
                file2_in_name = argv[i];
                file2_in_is_set = true;
            }
            else
            {
                cout << "File out = " << argv[i] << endl;
                file_out_name = argv[i];
                file_out_is_set = true;
            }
        }
    }
    if(!file1_in_is_set)
    {
        cout << "Missing input file1!" << endl;
        return -1;
    }

    if(!file2_in_is_set)
    {
        cout << "Missing input file2!" << endl;
        return -1;
    }

    if(!file_out_is_set)
    {
        cout << "Missing output file!" << endl;
        return -1;
    }

    /*--------------------------------------------------------------------*/
    /*--- Check if given filenames are equal or equal to temp filename ---*/
    /*--------------------------------------------------------------------*/
    if(!strcmp(file1_in_name, file_out_name))
    {
        cout << "Input file name must not match output file: " << file1_in_name << "!" << endl;
        return -1;
    }
    if(!strcmp(file1_in_name, file1_swap_name))
    {
        cout << "Input file name must not match tmp file: " << file1_swap_name << "!" << endl;
        return -1;
    }
    if(!strcmp(file1_in_name, file2_swap_name))
    {
        cout << "Input file name must not match tmp file: " << file2_swap_name << "!" << endl;
        return -1;
    }
    if(!strcmp(file2_in_name, file_out_name))
    {
        cout << "Input file name must not match output file: " << file2_in_name << "!" << endl;
        return -1;
    }
    if(!strcmp(file2_in_name, file1_swap_name))
    {
        cout << "Input file name must not match tmp file: " << file1_swap_name << "!" << endl;
        return -1;
    }
    if(!strcmp(file2_in_name, file2_swap_name))
    {
        cout << "Input file name must not match tmp file: " << file2_swap_name << "!" << endl;
        return -1;
    }
    if(!strcmp(file_out_name, file1_swap_name))
    {
        cout << "Output file name must not match tmp file: " << file1_swap_name << "!" << endl;
        return -1;
    }
    if(!strcmp(file_out_name, file2_swap_name))
    {
        cout << "Output file name must not match tmp file: " << file2_swap_name << "!" << endl;
        return -1;
    }

    /*------------------*/
    /*--- Open files ---*/
    /*------------------*/
    file1_in.open(file1_in_name, ios::in | ios::binary);
    if(file1_in.fail())
    {
        if(!file1_in_is_set)
            cout << "Missing input file!" << endl;
        else
            cout << "Could not open " << file1_in_name << "!" << endl;
        return -1;
    }

    file2_in.open(file2_in_name, ios::in | ios::binary);
    if(file2_in.fail())
    {
        if(!file2_in_is_set)
            cout << "Missing input file!" << endl;
        else
            cout << "Could not open " << file2_in_name << "!" << endl;
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

    /*-------------------------*/
    /*--- Get size of files ---*/
    /*-------------------------*/
    std::streampos begin = 0;
    std::streampos end = 0;

    /* File 1 */
    begin = file1_in.tellg();
    file1_in.seekg (0, ios::end);
    end = file1_in.tellg();
    file1_in.seekg (begin);
    file1_size = end - begin;

    /* File 2 */
    begin = file2_in.tellg();
    file2_in.seekg (0, ios::end);
    end = file2_in.tellg();
    file2_in.seekg (begin);
    file2_size = end - begin;

    cout << endl;
    cout << "File1 size: " << std::dec << file1_size << " byte" << endl;
    cout << "File2 size: " << std::dec << file2_size << " byte" << endl;
    cout << endl;

	/* Swap bits if option -s */
	if(swap)
	{
        /* Generate temp file1 with swapped bits within byte */
        file1_swap.open(file1_swap_name, ios::out | ios::binary | ios_base::trunc);
        if(file1_swap.fail())
		{
            cout << "Could not open " << file1_swap_name << "!" << endl;
			return -1;
		}
        cout << "Swap all bits within a byte of file1 " << file1_in_name << endl;
        swap_bits_within_byte(file1_in, file1_swap);

        /* Generate temp file2 with swapped bits within byte */
        file2_swap.open(file2_swap_name, ios::out | ios::binary | ios_base::trunc);
        if(file2_swap.fail())
        {
            cout << "Could not open " << file2_swap_name << "!" << endl;
            return -1;
        }
        cout << "Swap all bits within a byte of file2 " << file2_in_name << endl;
        swap_bits_within_byte(file2_in, file2_swap);

        /* Close all files */
        file1_in.close();
        file2_in.close();
		file_out.close();
        file1_swap.close();
        file2_swap.close();
		
        /* Reopen out|in file */
        file1_in.open(file1_swap_name, ios::out | ios::binary);
        if(file1_in.fail())
		{
            cout << "Could not open " << file1_swap_name << "!" << endl;
			return -1;
        }

        /* Reopen out|in file */
        file2_in.open(file2_swap_name, ios::out | ios::binary);
        if(file2_in.fail())
        {
            cout << "Could not open " << file2_swap_name << "!" << endl;
            return -1;
        }

        /* Open out file as in */
        file_out.open(file_out_name, ios::out | ios::binary);
        if(file_out.fail())
        {
            cout << "Could not open " << file_out_name << "!" << endl;
            return -1;
        }
	}
	
    /*-------------------------*/
    /*---   Combine files   ---*/
    /*-------------------------*/
    cout << "Combine " << file1_in_name << "(raw binary) and " << endl
         << file2_in_name << "(raw binary with MEN-Header) to " << endl
         << file_out_name << "(binary):" << endl;
    cout << "--------------------------------------" << endl;

    begin = file1_in.tellg();
    unsigned int file_size = 0;
    std::streampos read_ptr  = begin;
    char buffer[20];


    /*--- Copy input file 1 to output file ---*/
    cout << "-> Copy " << file1_in_name << "to" << file_out_name << endl;
    while(read_ptr - begin < file1_size)
    {
        read_ptr += file1_in.readsome(buffer, 1);
        file_out << buffer[0];
    }
    file_size += file1_size;

    /*--- Fill output file until offset is reached ---*/
    if(offset > file1_size)
    {
        cout << "-> Fill " << file_out_name << " with 0x" << hex << setw(2) << setfill('0') << ((int)filler & 0xFF) << " to reach 0x" << std::hex << offset << endl;
        while(file_size < offset)
        {
            file_size += 1;
            file_out << filler;
        }
    }
    file_size = offset;

    /*--- Copy input file 2 to output file ---*/
    begin = file2_in.tellg();
    read_ptr  = begin;
    cout << "-> Add " << file2_in_name << "to" << file_out_name << endl;
    while(read_ptr - begin < file2_size)
    {
        read_ptr += file2_in.readsome(buffer, 1);
        file_out << buffer[0];
    }
    file_size += file2_size;

    /*--- Fill output file until minimum filesize is reached ---*/
    if(min_bytes != -1 && file_size < (unsigned int)min_bytes)
    {
        cout << "-> Fill " << file_out_name << " with 0x" << hex << setw(2) << setfill('0') << ((int)filler & 0xFF) << " to reach 0x" << std::hex << min_bytes << endl;
        while(file_size < (unsigned int)min_bytes)
        {
            file_size += 1;
            file_out << filler;
        }
    }

    file_size = offset;

    file1_in.close();
    file2_in.close();
	file_out.close();
    file1_swap.close();
    file2_swap.close();

    cout << endl << endl;
    if(remove(file1_swap_name) != 0)
        cout << file1_swap_name << "Error deleting file" << endl;
    else
      cout << file1_swap_name << " successfully deleted" << endl;

    if(remove(file2_swap_name) != 0)
        cout << file2_swap_name << "Error deleting file" << endl;
    else
      cout << file2_swap_name << " successfully deleted" << endl;

    cout << endl << endl;
    cout << "---------------------------" << endl;
    cout << "Successfully finished!" << endl;
    cout << "---------------------------" << endl;

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
 * Print usage of genDediprog                                                    *
 +---------------------------------------------------------------------------*/
void usage()
{
    /* Description */
    cout << "Description : " << endl;
    cout << " This programm combines two binary files. The bytes" << endl
         << " and the bits can be swapped. The offset for the second input file" << endl
         << " can be chosen as well as the minimum file size in bytes which should be" << endl
         << " fill with filler(<x>). This program shall be used to generate program files" << endl
         << " for Dedi programmer" << endl
         << "Maximal file size = 2GByte.\n" << endl;
    cout << "Usage:" << endl;
    cout << "   genDediprog.exe file1_in file2_in file_out <options>\n" << endl;
	cout << "Options:" << endl;
    cout << "  -v               => tool version" << endl;
    cout << "  -h               => print this help" << endl;
    cout << "  -s               => swap bits within a byte (e.g. 1000 0100 => 0010 0001)" << endl;
    cout << "  -x=0xXX          => configure filler for unused space in file" << endl;
    cout << "  -f=0xXXXXXXXX    => configure minimal file size. if it is less than the input" << endl
         << "                   => files, the option will be ignored" << endl;
    cout << "                      Must be set with 0x<Hexdecimal>" << endl;
    cout << "  -o=0xXXXXXXXX    => offset address to the first byte of the input file, where" << endl;
    cout << "                      the conversion should be started." << endl;
    cout << "                      Must be set with 0x<Hexdecimal>" << endl;
	cout << "Example:" << endl;
    cout << "  genDediprog.exe -x=0xFF -o=0x100000 test.rbf test.bin test.dedi" << endl;
    cout << endl;
}
