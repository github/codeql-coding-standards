#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

void f() {}

void f1(void) {
  errno = 0;
  strtod("0", NULL); // NON_COMPLIANT
  f();               // function call
  if (0 != errno) {
  }
  errno = 0;
  strtod("0", NULL); // COMPLIANT
  if (0 != errno)    // errno value tested
  {
  }
  errno = 0;
  strtod("0", NULL); // NON_COMPLIANT
}

void err(int e) {}
void f2(FILE *f, fpos_t *p) {
  errno = 0;
  if (fsetpos(f, p) == 0) { // COMPLIANT
    // out-of-band error check
  } else {
    err(errno);
  }
}