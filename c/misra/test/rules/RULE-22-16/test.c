#include "threads.h"

void f1() {
  mtx_t m;
  mtx_lock(&m); // COMPLIANT
  mtx_unlock(&m);
}

void f2() {
  mtx_t m;
  mtx_unlock(&m); // COMPLIANT
}

void f3() {
  mtx_t m;
  mtx_lock(&m); // NON-COMPLIANT
}

void f4(int p) {
  mtx_t m;
  mtx_lock(&m); // NON-COMPLIANT
  if (p) {
    mtx_unlock(&m);
  }
}

void f5(int p) {
  mtx_t m;
  mtx_lock(&m); // COMPLIANT
  if (p) {
    mtx_unlock(&m);
  } else {
    mtx_unlock(&m);
  }
}

void f6(int p) {
  mtx_t m;
  mtx_lock(&m); // NON-COMPLIANT
  if (p) {
    goto skipped;
  }
  mtx_unlock(&m);
skipped:;
}

void f7(int p) {
  mtx_t *m;
  mtx_lock(m); // COMPLIANT
  mtx_unlock(m);
}

void f8(int p) {
  mtx_t *m;
  mtx_lock(m); // NON-COMPLIANT
}

void f9(int p) {
  mtx_t m;
  mtx_lock(&m); // COMPLIANT
  mtx_t *ptr_m = &m;
  mtx_unlock(ptr_m);
}

mtx_t g1;
void f10() {
  mtx_lock(&g1); // COMPLIANT
  mtx_unlock(&g1);
}

void f11() {
  mtx_lock(&g1); // NON-COMPLIANT
}

void f12() {
  struct {
    mtx_t m;
  } s;
  mtx_lock(&s.m); // NON-COMPLIANT
}

void f13() {
  struct {
    mtx_t m;
  } s;
  mtx_lock(&s.m); // COMPLIANT
  mtx_unlock(&s.m);
}

void f14() {
  for (;;) {
    mtx_t m;
    mtx_lock(&m); // COMPLIANT
    mtx_unlock(&m);
  }
}

void f15(int p) {
  for (;;) {
    mtx_t m;
    mtx_lock(&m); // NON-COMPLIANT
    if (p) {
      break;
    }
    mtx_unlock(&m);
  }
}

void f16(int p) {
  mtx_t *ptr;
  mtx_t *ptr_m1 = ptr;
  mtx_t *ptr_m2 = ptr;
  mtx_lock(ptr_m1); // COMPLIANT[FALSE_POSITIVE]
  mtx_unlock(ptr_m2);
}