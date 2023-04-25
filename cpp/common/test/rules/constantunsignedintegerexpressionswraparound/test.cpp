#include <climits>
#include <limits>

template <typename T> constexpr T constexpr_min() {
  return std::numeric_limits<T>::min();
}

template <typename T> constexpr T constexpr_max() {
  return std::numeric_limits<T>::max();
}

void test_unsigned_int() {
  unsigned int a;
  a = 1 + 1;                                        // COMPLIANT
  a = 0 - 1;                                        // COMPLIANT
  a = std::numeric_limits<unsigned int>::min() - 1; // NON_COMPLIANT
  a = UINT_MAX + 1;                                 // NON_COMPLIANT

  const unsigned int const_min = std::numeric_limits<unsigned int>::min();
  const unsigned int const_max = UINT_MAX;
  a = const_min + 1; // COMPLIANT
  a = const_max - 1; // COMPLIANT
  a = const_min - 1; // NON_COMPLIANT
  a = const_max + 1; // NON_COMPLIANT

#define UNDERFLOW(x) (std::numeric_limits<unsigned int>::min() - (x))
#define OVERFLOW(x) (UINT_MAX + (x))
  a = UNDERFLOW(0); // COMPLIANT
  a = OVERFLOW(0);  // COMPLIANT
  a = UNDERFLOW(1); // NON_COMPLIANT
  a = OVERFLOW(1);  // NON_COMPLIANT

  a = constexpr_min<unsigned int>() + 1; // COMPLIANT
  a = constexpr_max<unsigned int>() - 1; // COMPLIANT
  a = constexpr_min<unsigned int>() - 1; // NON_COMPLIANT
  a = constexpr_max<unsigned int>() + 1; // NON_COMPLIANT
}

void test_long_long() {
  unsigned long long a;
  a = 1 + 1;                                              // COMPLIANT
  a = 0 - 1;                                              // COMPLIANT
  a = std::numeric_limits<unsigned long long>::min() - 1; // NON_COMPLIANT
  a = ULLONG_MAX + 1;                                     // NON_COMPLIANT

  const unsigned long long const_min =
      std::numeric_limits<unsigned long long>::min();
  const unsigned long long const_max = ULLONG_MAX;
  a = const_min + 1; // COMPLIANT
  a = const_max - 1; // COMPLIANT
  a = const_min - 1; // NON_COMPLIANT
  a = const_max + 1; // NON_COMPLIANT

#define UNDERFLOW(x) (std::numeric_limits<unsigned long long>::min() - (x))
#define OVERFLOW(x) (ULLONG_MAX + (x))
  a = UNDERFLOW(0); // COMPLIANT
  a = OVERFLOW(0);  // COMPLIANT
  a = UNDERFLOW(1); // NON_COMPLIANT
  a = OVERFLOW(1);  // NON_COMPLIANT

  a = constexpr_min<unsigned long long>() + 1; // COMPLIANT
  a = constexpr_max<unsigned long long>() - 1; // COMPLIANT
  a = constexpr_min<unsigned long long>() - 1; // NON_COMPLIANT
  a = constexpr_max<unsigned long long>() + 1; // NON_COMPLIANT
}

void test_conversion() {
  signed int a =
      (signed int)(UINT_MAX + 1); // NON_COMPLIANT - still an unsigned integer
                                  // constant expression
}