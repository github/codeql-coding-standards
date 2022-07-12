#include <cstdlib>

[[noreturn]] void test_noreturn_f1(int i) { // COMPLIANT
  throw "Compliant";
}

[[noreturn]] void test_noreturn_f2(int i) { // NON_COMPLIANT
  if (i > 0) {
    throw "positive";
  }
  if (i < 0) {
    throw "negative";
  }
}

[[noreturn]] void test_noreturn_f3(int i) { // COMPLIANT
  if (i > 0) {
    throw "positive";
  }
  std::_Exit(1);
}

void test_noreturn_f4(int i) { // COMPLIANT
  if (i > 0) {
    throw "positive";
  }
  if (i < 0) {
    throw "negative";
  }
}

[[noreturn]] void test_noreturn_f5(int i) { // NON_COMPLIANT
  if (i > 0) {
    throw "positive";
  }
}

[[noreturn]] void test_noreturn_f6(int i) { // COMPLIANT
  if (i > 0) {
    throw "positive";
  }
  while (1) {
    i = 5;
  }
}
