int i = 0;

bool f1() {
  i++;
  return i == 1;
}

bool f2() {
  int i = 0;
  return i++ == 1;
}

bool f3(int &i) {
    i++;
    return i == 1;
}

void f4(bool b) {
  int j = 0;
  if (b || i++) { // NON_COMPLIANT
  }

  if (b || (j == i++)) { // NON_COMPLIANT
  }

  if (b || f1()) { // NON_COMPLIANT, f1 has global side-effects
  }

  if (b || f3(j)) { // NON_COMPLIANT, f3 has local side-effects
  }
}

int g1 = 0;
int f5() { return g1++; }
int f6() { return 1; }

#include <typeinfo>

void f7() {
  if (1 && sizeof(f5())) {
  } // COMPLIANT  - sizeof operands not evaluated
  if (1 &&noexcept(f5()) &&noexcept(f5())) {
  } // COMPLIANT  - noexcept operands not evaluated

  if (1 || (typeid(f6()) == typeid(f5()))) {
  } // NON_COMPLIANT  - typeid operands not evaluated, but the ==operator is
}

bool f8() {
    static int k = 0;
    k++;
    return k == 1;
}

void f9(bool b) {
    if (b || f8()) { // NON_COMPLIANT, f8 has static side-effects
    }
}

bool f10() {
    volatile bool m = 0;
    return m;
}

void f11(bool b) {
    if (b || f10()) { // NON_COMPLIANT, f10 has volatile side-effects
    }
}