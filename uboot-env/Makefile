TARGET=u-config

SRCS = $(wildcard *.c)
OBJS = $(patsubst %.c,%.o,$(SRCS))
INC = -I./include
CFLAGS = -DUSE_HOSTCC -DCONFIG_ENV_SIZE=128*1024
all: $(TARGET)

install:

clean:
	-rm -f $(TARGET) $(OBJS)

$(TARGET): $(OBJS)
	$(CC) $(INC) $(OBJS) $(LDFLAGS) -o $@

$(OBJS): $(SRCS)
	$(CC) $(CFLAGS) $(INC) -c $^
	


