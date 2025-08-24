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

void test_noreturn_f12(); // COMPLIANT

__attribute__((noreturn)) void test_noreturn_f13(int i) { // COMPLIANT
  abort();
}

// Allowed by exception. It is undefined behavior for main() to be declared with
// noreturn.
int main(int argc, char *argv[]) { // COMPLIANT
  abort();
}

_Noreturn void test_noreturn_f14(int i) { // COMPLIANT
  test_noreturn_f1(i);
}

void test_noreturn_f15(int i) { // NON_COMPLIANT
  test_noreturn_f1(i);
}

void test_noreturn_f16(int i) { // NON_COMPLIANT
  // Infinite tail recursion
  test_noreturn_f16(i);
}