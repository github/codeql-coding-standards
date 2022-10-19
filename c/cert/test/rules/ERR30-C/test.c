#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

void f1(const char *c_str) {
  unsigned long number;
  char *endptr;

  number = strtoul(c_str, &endptr, 0); // NON_COMPLIANT
  if (endptr == c_str || (number == ULONG_MAX && errno == ERANGE)) {
  }
}

void f2(const char *c_str) {
  unsigned long number;
  char *endptr;

  errno = 0;
  number = strtoul(c_str, &endptr, 0); // COMPLIANT
  if (endptr == c_str || (number == ULONG_MAX && errno == ERANGE)) {
  }
}

void helper() {}
void f2c(const char *c_str) {
  unsigned long number;
  char *endptr;

  errno = 0;
  number = strtoul(c_str, &endptr, 0);
  helper(); // NON_COMPLIANT
  if (endptr == c_str || (number == ULONG_MAX && errno == ERANGE)) {
  }
}

void f3(FILE *fp) {
  errno = 0;
  ftell(fp);
  if (errno) {       // NON_COMPLIANT
    perror("ftell"); // NON_COMPLIANT
  }
}

void f4(FILE *fp) {
  if (ftell(fp) == -1) {
    perror("ftell"); // COMPLIANT
  }
}

void f4b(FILE *fp) {
  long l = ftell(fp);
  if (l == -1) {
    perror("ftell"); // COMPLIANT
  }
}

void f5(const char *filename) {
  FILE *fileptr;

  errno = 0;
  fileptr = fopen(filename, "rb");
  if (errno != 0) { // NON_COMPLIANT
    /* Handle error */
  }
}

void f6(const char *filename) {
  FILE *fileptr = fopen(filename, "rb"); // COMPLIANT
  if (fileptr == NULL) {
  }
}
