int i = 0;

bool f1() {
  i++;
  return i == 1;
}

bool f2() {
  int i = 0;
  return i++ == 1;
}

void f3(bool b) {
  int j = 0;
  if (b || i++) { // NON_COMPLIANT
  }

  if (b || (j == i++)) { // NON_COMPLIANT
  }

  if (b || f1()) { // NON_COMPLIANT, f1 has global side-effects
  }

  if (b || f2()) { // COMPLIANT, f2 has local side-effects
  }
}

int g1 = 0;
int f4() { return g1++; }
int f5() { return 1; }

#include <typeinfo>

void f6() {
  if (1 && sizeof(f4())) {
  } // COMPLIANT  - sizeof operands not evaluated
  if (1 &&noexcept(f4()) &&noexcept(f4())) {
  } // COMPLIANT  - noexcept operands not evaluated

  if (1 || (typeid(f5()) == typeid(f4()))) {
  } // NON_COMPLIANT  - typeid operands not evaluated, but the ==operator is
}