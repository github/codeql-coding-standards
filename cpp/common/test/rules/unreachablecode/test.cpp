// NOTICE: SOME OF THE TEST CASES BELOW ARE ALSO INCLUDED IN THE C TEST CASE AND
// CHANGES SHOULD BE REFLECTED THERE AS WELL.

void test_switch(int p1) {
  int l1 = 0;
  switch (p1) {
    l1 = p1; // NON_COMPLIANT[FALSE_NEGATIVE]
  case 1:
    break;
  default:
    break;
  }
}

int test_after_return() {
  return 0;
  int l1 = 0; // NON_COMPLIANT - function has returned by this point
}

int test_constant_condition() {
  if (0) { // NON_COMPLIANT
    return 1;
  } else { // COMPLIANT
    return 2;
  }
}

// NOTICE: THE TEST CASES ABOVE ARE ALSO INCLUDED IN THE C TEST CASE AND CHANGES
//         SHOULD BE REFLECTED THERE AS WELL.

template <class T> int f() {
  if (0) { // NON_COMPLIANT - block is unreachable in all instances
    return 3;
  }
  if (T::isVal()) { // COMPLIANT - block is reachable in at least one template
                    // instantiation, so we do not flag it as dead code
    return 2;
  }

  return 1; // COMPLIANT - block is reachable in the uninstantiated template
}

class A {
public:
  static bool isVal() { return true; }
};

void test_f() { f<A>(); }

template <class T> class B {
public:
  int h1(T t) {
    if (0) { // NON_COMPLIANT - block is unreachable in all instances
      return 3;
    }
  }
  int h2() {
    if (0) { // NON_COMPLIANT - block is unreachable in all instances
      return 3;
    }
  }
};

class C {};

void test_template() {
  B<A> b1;
  A a;
  b1.h1(a);
  b1.h2();
  B<C> b2;
  C c;
  b2.h1(c);
  b2.h2();
}