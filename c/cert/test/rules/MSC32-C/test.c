#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void f1(void) {
  printf("%ld, ", random()); // NON_COMPLIANT
}

void f2(void) {
  struct timespec ts;
  timespec_get(&ts, TIME_UTC);
  srandom(ts.tv_nsec ^ ts.tv_sec);
  printf("%ld, ", random()); // COMPLIANT
}

void f3(void) {
  srandom(1);
  printf("%ld, ", random()); // NON_COMPLIANT
}

#define SEED 100

void f4(void) {
  srandom(SEED);
  printf("%ld, ", random()); // NON_COMPLIANT
}