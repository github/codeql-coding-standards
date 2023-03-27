int f1_volatile();

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
  int l2 = 10;
  if (l1 < l2) // NON_COMPLIANT - both variables are constants
    ;

  if (a < l1) { // COMPLIANT - `a` is not constant
    if (a < l2) // NON_COMPLIANT - `a` is always less than `l2`
                // because `a < l1` and `l1 < l2`
      ;
  }

  volatile int l3 = f1_volatile();
  if (l3 < l1) { // COMPLIANT - `l3` is not constant
    if (l3 < l2) // COMPLIANT - `l3` is volatile, so while `l1 < l2`, the value
                 // of `l3` could change
      ;
  }
}

template <class T> int f() {
  if (0) { // NON_COMPLIANT - true path is infeasible in all circumstances
    return 3;
  }
  if (T::isVal()) { // COMPLIANT[FALSE_POSITIVE] - `isVal` is `true` for all
                    // visible instantiations, but in the uninstantiated
                    // template both paths are feasible. This represents that
                    // this is template dependent, so we consider it compliant
    return 2;
  }

  if (T::isVal2()) { // COMPLIANT[FALSE_POSITIVE] - `isVal2` is either true or
                     // false
    return 2;
  }

  return 1; // COMPLIANT - block is reachable in the uninstantiated template
}

class A {
public:
  static bool isVal() { return true; }
  static bool isVal2() { return true; }
};

class B {
public:
  static bool isVal() { return true; }
  static bool isVal2() { return false; }
};

void test_f() {
  f<A>();
  f<B>();
}

void test_break(int a) {
  while (true) {  // COMPLIANT
    if (a++ >= 0) // COMPLIANT
      break;
  }
  return;
}
void test_infeasible_break(unsigned int a) {
  while (true) { // NON_COMPLIANT[FALSE_NEGATIVE]
    if (a < 0U)  // NON_COMPLIANT - the comparison is always false
      break;

    if (a >= 0U) { // NON_COMPLIANT - the comparison is always true
    } else
      break;
  }

  while (true) { // COMPLIANT
    if (a < 0U)  // NON_COMPLIANT - the comparison is always false
      break;
    else // COMPLIANT - the comparison is always false
      break;
  }
}

void test_loop(int a) {
  while (a < 0) { // COMPLIANT
    a++;
  }

  for (int i = a; i < 10; i++) { // COMPLIANT
    a++;
  }
}
