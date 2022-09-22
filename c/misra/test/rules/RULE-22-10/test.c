#include <errno.h>
#include <stdlib.h>

void f1(void) {
  errno = 0;
  int i = atoi("0"); // non errno-setting function
  if (0 == errno) {  // NON_COMPLIANT
  }
  errno = 0;
  strtod("0", NULL); // errno-setting function
  if (0 == errno) {  // COMPLIANT
  }
}

void f2(void) {
  if (EAGAIN == errno      // NON_COMPLIANT
      || errno == EINTR) { // NON_COMPLIANT
  }
}

void f3(void) {
  errno = 0;
  strtod("0", NULL);
  if (errno == EAGAIN || errno == EINTR) { // COMPLIANT
  }
}