CC = g++
CFLAGS = -I . 
DEPS = 
OBJ = genDediProg.o

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

genDediProg: $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS) 
	mv $@ ../Bin
	
clean:
	rm -f *.o

