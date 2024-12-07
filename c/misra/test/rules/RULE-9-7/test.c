#include "stdatomic.h"
#include "threads.h"

_Atomic int g1;     // COMPLIANT
_Atomic int g2 = 0; // COMPLIANT

void f_thread(void *x);

void f_starts_thread() {
  thrd_t t;
  thrd_create(&t, f_thread, 0);
}

void main() {
  _Atomic int l1 = 1; // COMPLIANT
  f_starts_thread();

  _Atomic int l2; // COMPLIANT
  atomic_init(&l2, 0);
  f_starts_thread();

  _Atomic int l3; // NON-COMPLIANT
  f_starts_thread();

  _Atomic int l4; // NON-COMPLIANT
  f_starts_thread();
  atomic_init(&l4, 0);

  _Atomic int l5; // NON-COMPLIANT
  if (g1 == 0) {
    atomic_init(&l5, 0);
  }
  f_starts_thread();
}