#include <stdexcept>

void test_noexcept_false() { // COMPLIANT
  throw "test";
}

void test_noexcept_true() noexcept(true) { // NON_COMPLIANT
  throw "test";
}