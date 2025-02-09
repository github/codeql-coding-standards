#include <stdalign.h>    //COMPLIANT
#include <stdatomic.h>   //NON-COMPLIANT
#include <stdnoreturn.h> //COMPLIANT
#include <threads.h>     //NON-COMPLIANT

#define MACRO(x) _Generic((x), int : 0, long : 1) // NON-COMPLIANT
#define __STDC_WANT_LIB_EXT1__ 1                  // NON-COMPLIANT

_Noreturn void f0(); // COMPLIANT

typedef int new_type;                     // COMPLIANT
typedef _Atomic new_type atomic_new_type; // NON-COMPLIANT

void f(int p) {
  int i0 = _Generic(p, int : 0, long : 1); // COMPLIANT

  _Atomic int i; // NON-COMPLIANT

  _Alignas(4) int i1;    // COMPLIANT
  alignas(4) int i2;     // COMPLIANT
  int a = _Alignof(int); // COMPLIANT
  int a1 = alignof(int); // COMPLIANT

  static thread_local int i3;  // NON-COMPLIANT
  static _Thread_local int i4; // NON-COMPLIANT
}