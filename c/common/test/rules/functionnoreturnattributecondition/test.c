#include "setjmp.h"
#include "stdlib.h"
#include "threads.h"

_Noreturn void test_noreturn_f1(int i) { // COMPLIANT
  abort();
}

_Noreturn void test_noreturn_f2(int i) { // NON_COMPLIANT
  if (i > 0) {
    abort();
  }
  if (i < 0) {
    abort();
  }
}

_Noreturn void test_noreturn_f3(int i) { // COMPLIANT
  if (i > 0) {
    abort();
  }
  exit(1);
}

void test_noreturn_f4(int i) { // COMPLIANT
  if (i > 0) {
    abort();
  }
  if (i < 0) {
    abort();
  }
}

_Noreturn void test_noreturn_f5(int i) { // NON_COMPLIANT
  if (i > 0) {
    abort();
  }
}

_Noreturn void test_noreturn_f6(int i) { // COMPLIANT
  if (i > 0) {
    abort();
  }
  while (1) {
    i = 5;
  }
}

__attribute__((noreturn)) void test_noreturn_f7(int i) { // NON_COMPLIANT
  if (i > 0) {
    abort();
  }
}

__attribute__((noreturn)) void test_noreturn_f8(int i) { // COMPLIANT
  abort();
}

_Noreturn void test_noreturn_f9(int i) { // COMPLIANT
  test_noreturn_f1(i);
}

_Noreturn void test_noreturn_f10(int i) { // COMPLIANT
  switch (i) {
  case 0:
    abort();
    break;
  case 1:
    exit(0);
    break;
  case 2:
    _Exit(0);
    break;
  case 3:
    quick_exit(0);
    break;
  case 4:
    thrd_exit(0);
    break;
  default:;
    jmp_buf jb;
    longjmp(jb, 0);
  }
}

_Noreturn void test_noreturn_f11(int i) { // COMPLIANT
  return test_noreturn_f11(i);
}