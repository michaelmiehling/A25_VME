CC = g++
CFLAGS = -I . 
DEPS = 
OBJ = bin2ihex.o

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

bin2ihex: $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS) 
	mv $@ ../Bin
	
clean:
	rm -f *.o

