#include <limits.h>

// UINT_MIN and UULONG_MIN isn't defined, but it's going to be zero
#define UINT_MIN ((unsigned int)0)
#define UULONG_MIN ((unsigned long long)0)

void test_unsigned_int() {
  unsigned int a;
  a = 1 + 1;        // COMPLIANT - signed integer
  a = 0 - 1;        // COMPLIANT - signed integer
  a = UINT_MIN - 1; // NON_COMPLIANT
  a = UINT_MAX + 1; // NON_COMPLIANT

  const unsigned int const_min = UINT_MIN;
  const unsigned int const_max = UINT_MAX;
  a = const_min + 1; // COMPLIANT
  a = const_max - 1; // COMPLIANT
  a = const_min - 1; // NON_COMPLIANT
  a = const_max + 1; // NON_COMPLIANT

#define UNDERFLOW(x) (UINT_MIN - (x))
#define OVERFLOW(x) (UINT_MAX + (x))
  a = UNDERFLOW(0); // COMPLIANT
  a = OVERFLOW(0);  // COMPLIANT
  a = UNDERFLOW(1); // NON_COMPLIANT
  a = OVERFLOW(1);  // NON_COMPLIANT
}

void test_long_long() {
  unsigned long long a;
  a = 1 + 1;          // COMPLIANT
  a = 0 - 1;          // COMPLIANT
  a = UULONG_MIN - 1; // NON_COMPLIANT
  a = ULLONG_MAX + 1; // NON_COMPLIANT

  const unsigned long long const_min = UULONG_MIN;
  const unsigned long long const_max = ULLONG_MAX;
  a = const_min + 1; // COMPLIANT
  a = const_max - 1; // COMPLIANT
  a = const_min - 1; // NON_COMPLIANT
  a = const_max + 1; // NON_COMPLIANT

#define UNDERFLOW(x) (UULONG_MIN - (x))
#define OVERFLOW(x) (ULLONG_MAX + (x))
  a = UNDERFLOW(0); // COMPLIANT
  a = OVERFLOW(0);  // COMPLIANT
  a = UNDERFLOW(1); // NON_COMPLIANT
  a = OVERFLOW(1);  // NON_COMPLIANT
}

void test_conversion() {
  signed int a =
      (signed int)(UINT_MAX + 1); // NON_COMPLIANT - still an unsigned integer
                                  // constant expression
}