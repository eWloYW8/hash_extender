OPENSSL_SRC := $(CURDIR)/openssl
OPENSSL_BUILD := $(OPENSSL_SRC)/build
OPENSSL_INSTALL := $(OPENSSL_SRC)/install
INCLUDE_OPENSSL := $(OPENSSL_INSTALL)/include
LIB_OPENSSL := $(OPENSSL_INSTALL)/lib

# Capture the operating system name for use by the preprocessor.
OS		:= $(shell uname | tr '/[[:lower:]]' '_[[:upper:]]')

# These are the specifications of the toolchain
CC		:= gcc
CFLAGS		:= -std=c89 -g -oS -Wall -Werror -Wno-deprecated-declarations
CPPFLAGS	:= -I$(INCLUDE_OPENSSL) -D_DEFAULT_SOURCE -D$(OS)
LDFLAGS		:= -L$(LIB_OPENSSL) -lssl -lcrypto

BIN_MAIN	:= hash_extender
BIN_TEST	:= hash_extender_test
BINS		:= $(BIN_MAIN) $(BIN_TEST)

SRCS		:= $(wildcard *.c)
OBJS		:= $(patsubst %.c,%.o,$(SRCS))
OBJS_MAIN	:= $(filter-out $(BIN_TEST).o,$(OBJS))
OBJS_TEST	:= $(filter-out $(BIN_MAIN).o,$(OBJS))

all: $(OPENSSL_INSTALL)/lib/libssl.a $(BINS)

# OpenSSL build and install
$(OPENSSL_INSTALL)/lib/libssl.a: $(OPENSSL_SRC)/Makefile
	@echo "Building OpenSSL..."
	@cd $(OPENSSL_SRC) && \
		make && make install_sw

$(OPENSSL_SRC)/Makefile:
	@echo "Downloading and preparing OpenSSL source..."
	@git submodule update --init
	@cd $(OPENSSL_SRC) && \
		./config --prefix=$(OPENSSL_INSTALL) no-shared no-dso

$(BIN_MAIN): $(OPENSSL_INSTALL)/lib/libssl.a $(OBJS_MAIN)
	@echo [LD] $@
	@$(CC) $(CFLAGS) -o $(BIN_MAIN) $(OBJS_MAIN) $(LDFLAGS)

$(BIN_TEST): $(OPENSSL_INSTALL)/lib/libssl.a $(OBJS_TEST)
	@echo [LD] $@
	@$(CC) $(CFLAGS) -o $(BIN_TEST) $(OBJS_TEST) $(LDFLAGS)

%.o: %.c
	@echo [CC] $@
	@$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

clean:
	@echo [RM] *.o
	@rm -f $(OBJS)
	@echo [RM] $(BIN_MAIN)
	@rm -f $(BIN_MAIN)
	@echo [RM] $(BIN_TEST)
	@rm -f $(BIN_TEST)
	@echo [RM] OpenSSL build and install
	@make -C $(OPENSSL_SRC) clean
	@rm -rf $(OPENSSL_BUILD) $(OPENSSL_INSTALL)