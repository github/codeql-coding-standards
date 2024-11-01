#include "stdatomic.h"
#include "string.h"

typedef struct s1 {
  int x;
} s1;

_Atomic s1 atomic_s1;
// A non-atomic pointer to an atomic s1
_Atomic s1 *ptr_atomic_s1;
// An atomic pointer to a non-atomic s1
s1 *_Atomic s1_atomic_ptr;

_Atomic int g3;

void takeCopy(s1 p1);

void f1() {
  s1 l1;
  s1 *l2;
  l1 = atomic_load(&atomic_s1);     // COMPLIANT
  l1 = atomic_load(ptr_atomic_s1);  // COMPLIANT
  l2 = atomic_load(&s1_atomic_ptr); // COMPLIANT
  l1.x = 4;                         // COMPLIANT
  l2->x = 4;                        // COMPLIANT
  atomic_store(&atomic_s1, l1);     // COMPLIANT
  atomic_store(ptr_atomic_s1, l1);  // COMPLIANT
  atomic_store(&s1_atomic_ptr, l2); // COMPLIANT

  // Undefined behavior, but not banned by this rule.
  memset(&atomic_s1, sizeof(atomic_s1), 0);         // COMPLIANT
  memset(ptr_atomic_s1, sizeof(*ptr_atomic_s1), 0); // COMPLIANT

  // OK: whole loads and stores are protected from data-races.
  takeCopy(atomic_s1);      // COMPLIANT
  takeCopy(*ptr_atomic_s1); // COMPLIANT
  atomic_s1 = (s1){0};      // COMPLIANT
  *ptr_atomic_s1 = (s1){0}; // COMPLIANT
  atomic_s1 = *l2;          // COMPLIANT
  ptr_atomic_s1 = l2;       // COMPLIANT

  // Banned: circumvents data-race protection, results in UB.
  atomic_s1.x;          // NON-COMPLIANT
  ptr_atomic_s1->x;     // NON-COMPLIANT
  atomic_s1.x = 0;      // NON-COMPLIANT
  ptr_atomic_s1->x = 0; // NON-COMPLIANT

  // OK: not evaluated.
  sizeof(atomic_s1);        // COMPLIANT
  sizeof(ptr_atomic_s1);    // COMPLIANT
  sizeof(atomic_s1.x);      // COMPLIANT
  sizeof(ptr_atomic_s1->x); // COMPLIANT

  // All OK: not an atomic struct, but rather an atomic pointer to non-atomic
  // struct.
  memset(s1_atomic_ptr, sizeof(*s1_atomic_ptr), 0); // COMPLIANT
  takeCopy(*s1_atomic_ptr);                         // COMPLIANT
  *s1_atomic_ptr = (s1){0};                         // COMPLIANT
  s1_atomic_ptr = l2;                               // COMPLIANT
  s1_atomic_ptr->x;                                 // COMPLIANT
}