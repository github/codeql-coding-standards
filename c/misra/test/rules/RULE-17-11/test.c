#include "stdlib.h"

_Noreturn void test_noreturn_f1(int i) { // COMPLIANT
  abort();
}

void test_noreturn_f2(int i) { // NON_COMPLIANT
  abort();
}


_Noreturn void test_noreturn_f3(int i) { // COMPLIANT
  if (i > 0) {
    abort();
  }
  exit(1);
}

void test_noreturn_f4(int i) { // NON_COMPLIANT
  if (i > 0) {
    abort();
  }
  exit(1);
}

void test_noreturn_f5(int i) { // COMPLIANT
  if (i > 0) {
    return;
  }
  exit(1);
}

void test_noreturn_f6(int i) { // COMPLIANT
  if (i > 0) {
    abort();
  }
  if (i < 0) {
    abort();
  }
}

void test_noreturn_f7(int i) { // COMPLIANT
  if (i > 0) {
    abort();
  }
}

void test_noreturn_f8(int i) { // NON_COMPLIANT
  if (i > 0) {
    abort();
  } else {
    abort();
  }
}

_Noreturn void test_noreturn_f9(int i) { // COMPLIANT
  if (i > 0) {
    abort();
  } else {
    abort();
  }
}

void test_noreturn_f10(int i) { // NON_COMPLIANT
  if (i > 0) {
    abort();
  }
  while (1) {
    i = 5;
  }
}

_Noreturn void test_noreturn_f11(int i) { // COMPLIANT
  if (i > 0) {
    abort();
  }
  while (1) {
    i = 5;
  }
}
