TARGET=u-config
TARGET2 = printenv
TARGET3 = setenv
#SRCS = $(wildcard *.c)
SRCS = crc32.c u-boot-config.c
OBJS = $(patsubst %.c,%.o,$(SRCS))
INC = -I./include
CFLAGS = -g -DUSE_HOSTCC 
ifeq ($(PLATFORM), MX61)
CFLAGS += -DCONFIG_ENV_SIZE=8*1024
else
CFLAGS += -DCONFIG_ENV_SIZE=128*1024
endif
all: $(TARGET) $(TARGET2) $(TARGET3)

install:

clean:
	-rm -f $(TARGET) $(TARGET2) $(TARGET3) $(OBJS)

$(TARGET): $(OBJS)
	$(CC) $(INC) $(OBJS) $(LDFLAGS) -o $@

$(TARGET2): print_env.c
	$(CC) $(CFLAGS) $(INC) print_env.c  -o $@

$(TARGET3): set_env.c crc32.c
	$(CC) $(CFLAGS) $(INC) set_env.c crc32.c -o $@

$(OBJS): $(SRCS)
	$(CC) $(CFLAGS) $(INC) -c $^
	


