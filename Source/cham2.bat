set OLDDIR=%CD%

cd ..\16t001-00_bin\Bin
chameleon_v2.exe -i=..\..\Source\chameleon_V2.xls -a=wb
copy chameleon.hex ..\..\Source\chameleon.hex 
copy wb_adr_dec.vhd ..\..\Source\wb_adr_dec.vhd 

chdir /d %OLDDIR%


pause 1