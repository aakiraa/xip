CC=gcc
CFLAGS=
LDFLAGS=-lX11 -lXi
EXEC=x_input_logger

all: $(EXEC)

x_input_logger: x_input_logger.o

x_input_logger.o: x_input_logger.c
	$(CC) -o x_input_logger.o -c x_input_logger.c $(LDFLAGS)

clean:
	rm -f *.o $(EXEC)
