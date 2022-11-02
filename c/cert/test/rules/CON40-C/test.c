#include <stdatomic.h>
#include <stdbool.h>

static bool fl1 = ATOMIC_VAR_INIT(false);
static bool fl2 = ATOMIC_VAR_INIT(false);
static bool fl3 = ATOMIC_VAR_INIT(false);
static bool fl4 = ATOMIC_VAR_INIT(false);

void f1() {
  atomic_store(&fl1, 0);             // NON_COMPLIANT
  atomic_store_explicit(&fl1, 0, 0); // NON_COMPLIANT
}

void f2() {
  do {
  } while (!atomic_compare_exchange_weak(&fl2, &fl2, &fl2)); // COMPLIANT

  do {
  } while (!atomic_compare_exchange_weak_explicit(&fl2, &fl2, &fl2, &fl2,
                                                  &fl2)); // COMPLIANT
}

void f3() {
  atomic_compare_exchange_weak(&fl2, &fl2, &fl2); // NON_COMPLIANT
  atomic_compare_exchange_weak_explicit(&fl2, &fl2, &fl2, &fl2,
                                        &fl2); // NON_COMPLIANT
}

void f4() { fl3 ^= true; }

void f5() {
  fl3 += 1;    // NON_COMPLIANT
  fl3 = 1 + 1; // NON_COMPLIANT
}