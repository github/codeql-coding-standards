/**
 * This is mostly copied from `cpp/autosar/test/rules/M0-1-2/test.cpp`, however
 * there are some slight differences:
 * - Tests have been added that constexprs are considered compliant
 * - Tests related to `while(true)` have been changed to allow `while(true)`.
 * - Tests have been added for macro-generated `do {} while(false);` loops.
 * - Some examples have been removed to reduce maintenance burden
 */

void test_infeasible(unsigned int a) {
  if (a >= 0U) // NON_COMPLIANT - `a` is unsigned, therefore the comparison is
               // always true
    ;
  if (a <= 0xffffffffU) // NON_COMPLIANT - `a` is unsigned, and cannot be above
                        // 0xffffffff as 32 bit int
    ;
  if (a > 0U) // COMPLIANT - `a` is unsigned, but may be equal to zero
    ;

  int l1 = 2;
  if (l1 < 10) // NON_COMPLIANT - both variables are constants
    ;

  if (a < l1) { // COMPLIANT - `a` is not constant
    ;
  }

  volatile int l3;
  if (l3 < 10) { // COMPLIANT - `l3` is not constant
    if (l3 < 10) // COMPLIANT - `l3` is volatile, so while `l3 < 10`, the value
                 // of `l3` could change
      ;
  }
}

template <class T> int f() {
  if (0) { // NON_COMPLIANT - true path is infeasible in all circumstances
    return 3;
  }

  if (T::isVal()) { // NON_COMPLIANT - not using constexpr if.
    return 2;
  }

  if constexpr (T::isVal()) { // COMPLIANT
    return 2;
  }
}

class A {
public:
  static constexpr bool isVal() { return true; }
};

void test_f() { f<A>(); }

void test_while(int a) {
  while (a < 0) { // COMPLIANT
    a++;
  }

  while (false) { // NON_COMPLIANT
    ;
  }

  while (true) { // COMPLIANT -- by exception
    ;

    while (10) { // NON_COMPLIANT
      ;

      constexpr bool x = true;
      while (x) { // NON_COMPLIANT
        ;
      }
    }
  }
}

#define DO_WHILE_FALSE()                                                       \
  do {                                                                         \
  } while (false)

#define DO_WHILE_TRUE()                                                        \
  do {                                                                         \
  } while (true)

#define WHILE_FALSE()                                                          \
  while (false)                                                                \
    ;

void test_do() {
  do {
    ;
  } while (false); // NON_COMPLIANT

  do {
    ;
  } while (true); // NON_COMPLIANT

  DO_WHILE_FALSE(); // COMPLIANT -- by exception
  DO_WHILE_TRUE();  // NON_COMPLIANT

  WHILE_FALSE(); // NON_COMPLIANT

  do {
    WHILE_FALSE(); // NON_COMPLIANT
  } while (false); // NON_COMPLIANT
}

template <bool x> int foo() {
  if (x) { // NON_COMPLIANT - should use constexpr if
    return 1;
  }
  if constexpr (x) { // COMPLIANT - should use constexpr if
    return 1;
  }
  return 0; // COMPLIANT - block is reachable in the uninstantiated template
}

void test() {
  foo<true>();
  foo<false>();
}