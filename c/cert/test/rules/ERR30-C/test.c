#include <errno.h>
#include <limits.h>
#include <locale.h>
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

void f1a(const char *c_str) {
  unsigned long number;
  char *endptr;

  number = strtoul(c_str, &endptr, 0); // NON_COMPLIANT
  if (errno == ERANGE) {
  }
}

void f2a(const char *c_str) {
  unsigned long number;
  char *endptr;

  errno = 0;
  number = strtoul(c_str, &endptr, 0); // COMPLIANT
  if (errno == ERANGE) {
  }
}
void f2b(const char *c_str) {
  char *endptr;

  errno = 0;
  strtoul(c_str, &endptr, 0); // NON_COMPLIANT
  strtoul(c_str, &endptr, 0); // NON_COMPLIANT
  if (errno == ERANGE) {
  }
}

void helper() {}
void f2c(const char *c_str) {
  unsigned long number;
  char *endptr;

  errno = 0;
  number = strtoul(c_str, &endptr, 0); // NON_COMPLIANT
  helper();
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

void f5() {
  setlocale(LC_ALL, "en_US.UTF-8"); // COMPLIANT
}

void f6() {
  if (setlocale(LC_ALL, "en_US.UTF-8") == NULL) { // COMPLIANT
  }
}

void f7() {
  errno = 0;
  setlocale(LC_ALL, "en_US.UTF-8"); // NON_COMPLIANT
  if (errno != 0) {
  }
}

void f8() {
  if (setlocale(LC_ALL, "en_US.UTF-8") == NULL) { // NON_COMPLIANT
    if (errno != 0) {
    }
  }
}

void f9() {
  errno = 0;
  if (setlocale(LC_ALL, "en_US.UTF-8") == NULL) { // COMPLIANT
    if (errno != 0) {
    }
  }
}