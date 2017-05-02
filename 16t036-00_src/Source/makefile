CC = gcc
CFLAGS = -I . -I /MEN/ -D _LITTLE_ENDIAN_
DEPS = men_typs.h usr_utl.h fpga_header.h usr_oss.h utl_os.h
OBJ = tstopt.o fpga_addheader.o 

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

fpga_addheader: $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS) 
	
clean:
	rm -f *.o
