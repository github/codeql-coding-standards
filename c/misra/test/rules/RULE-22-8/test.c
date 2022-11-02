#include <errno.h>
#include <stdlib.h>

void f1(void) {
  strtod("0", NULL); // NON_COMPLIANT
  if (0 == errno) {
    strtod("0", NULL); // COMPLIANT
    if (0 == errno) {
    }
  } else {
    errno = 0;
    strtod("0", NULL); // COMPLIANT
    if (0 == errno) {
    }
  }
}

void f2(void) {
  if (0 != errno) {
    strtod("0", NULL); // NON_COMPLIANT
  } else {
    errno = 0;
    strtod("0", NULL); // COMPLIANT
    strtof("0", NULL); // NON_COMPLIANT
  }
}

void f3_helper() {}
void f3(void) {
  errno = 0;
  f3_helper();
  strtod("0", NULL); // NON_COMPLIANT
}

void f4(void) {
  errno = 0;
  switch (errno) {
  case 0:
    strtod("0", NULL); // COMPLIANT
  case 1:
    strtod("0", NULL); // NON_COMPLIANT
  }
}