#include <stdatomic.h>
#include <stdbool.h>

static _Atomic int fl1 = ATOMIC_VAR_INIT(false);
static _Atomic int fl2 = ATOMIC_VAR_INIT(false);
static int fl2a = ATOMIC_VAR_INIT(false);
static int fl3 = ATOMIC_VAR_INIT(false);
static int fl4 = ATOMIC_VAR_INIT(false);

void f1() {
  atomic_store(&fl1, 0);             // NON_COMPLIANT
  atomic_store_explicit(&fl1, 0, 0); // NON_COMPLIANT
}

void f2() {
  do {
  } while (!atomic_compare_exchange_weak(&fl2, &fl2a, fl2a)); // COMPLIANT

  do {
  } while (!atomic_compare_exchange_weak_explicit(&fl2, &fl2a, fl2a, 0,
                                                  0)); // COMPLIANT
}

void f3() {
  atomic_compare_exchange_weak(&fl2, &fl2a, fl2a); // NON_COMPLIANT
  atomic_compare_exchange_weak_explicit(&fl2, &fl2a, fl2a, 0,
                                        0); // NON_COMPLIANT
}

void f4() { fl3 ^= true; }

void f5() {
  fl3 += 1;    // NON_COMPLIANT
  fl3 = 1 + 1; // NON_COMPLIANT
}