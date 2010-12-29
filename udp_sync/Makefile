

CC = $(CROSS_COMPILER)gcc
CFLAGS = 
LDFLAGS = -lpthread

TARGET_SERVER = userver
TARGET_CLIENT = uclient
SRC=udpserver.c udpclient.c

all: obj
	$(CC) -o $(TARGET_SERVER) $(LDFLAGS) udpserver.o
	$(CC) -o $(TARGET_CLIENT) $(LDFLAGS) udpclient.o
	
install:

clean:
	rm -f *.o
	rm -f $(TARGET_SERVER) $(TARGET_CLIENT)
	
obj: udpsync.h
	$(CC) $(CFLAGS) -c $(SRC) 
