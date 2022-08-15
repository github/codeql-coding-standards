#include "stdatomic.h"

void f1() {
  int a, b, c;
  if (!atomic_compare_exchange_weak(&a, &b, c)) { // NON_COMPLIANT
    (void)0;                                      /* no-op */
  }

  atomic_compare_exchange_weak(&a, &b, c); // NON_COMPLIANT

  if (!atomic_compare_exchange_weak_explicit(&a, &b, c, 0,
                                             0)) { // NON_COMPLIANT
    (void)0;                                       /* no-op */
  }

  atomic_compare_exchange_weak_explicit(&a, &b, c, 0, 0); // NON_COMPLIANT
}

void f2() {
  int a, b, c;
  while (1 == 1) {
    if (!atomic_compare_exchange_weak(&a, &b, c)) { // COMPLIANT
      (void)0;                                      /* no-op */
    }
  }

  while (!atomic_compare_exchange_weak(&a, &b, c)) { // COMPLIANT
    (void)0;                                         /* no-op */
  }

  do {
    (void)0;                                          /* no-op */
  } while (!atomic_compare_exchange_weak(&a, &b, c)); // COMPLIANT

  while (1 == 1) {
    if (!atomic_compare_exchange_weak_explicit(&a, &b, c, 0, 0)) { // COMPLIANT
      (void)0;                                                     /* no-op */
    }
  }

  while (!atomic_compare_exchange_weak_explicit(&a, &b, c, 0, 0)) { // COMPLIANT
    (void)0;                                                        /* no-op */
  }

  do {
    (void)0; /* no-op */
  } while (
      !atomic_compare_exchange_weak_explicit(&a, &b, c, 0, 0)); // COMPLIANT
}