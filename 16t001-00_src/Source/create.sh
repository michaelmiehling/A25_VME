#!/bin/bash

# Author Adam Wujek, CERN 2017

# based on create_exe.bat

pp -o ../../16t001-00_bin/Bin/Chameleon_V2 Chameleon_V2.pl -M PerlIO -M XML::LibXML::SAX -M Getopt::Mixed -M XML::Simple -M XML::SAX::Expat::Incremental -M Spreadsheet::ParseExcel
if [ "$?" -ne 0 ]; then
    echo "Please verify that you have following packages installed:"
    # at least for ubuntu 14.10
    echo "libpar-packer-perl"
    echo "libspreadsheet-parseexcel-perl"
    echo "libxml-sax-expat-incremental-perl"
    echo "libxml-simple-perl"
    echo "libgetopt-mixed-perl"
fi
