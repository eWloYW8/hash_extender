#ifndef _UTIL_H_
#define _UTIL_H_

#ifdef _WIN32
#define err(eval, fmt, ...) \
    do { fprintf(stderr, fmt ": %s\n", ##__VA_ARGS__, strerror(errno)); exit(eval); } while (0)

#define errx(eval, fmt, ...) \
    do { fprintf(stderr, fmt "\n", ##__VA_ARGS__); exit(eval); } while (0)

#define warn(fmt, ...) \
    fprintf(stderr, fmt ": %s\n", ##__VA_ARGS__, strerror(errno))

#define warnx(fmt, ...) \
    fprintf(stderr, fmt "\n", ##__VA_ARGS__)
#else
#include <err.h>
#endif

#include <inttypes.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void print_hex(unsigned char *data, unsigned int length);
void print_hex_fancy(uint8_t *data, uint64_t length);
void die(char *msg);
void die_MEM(void);

uint8_t *read_file(char *filename, uint64_t *out_length);

void util_test(void);

#endif
