#include <cstdlib>
#include <exception>

void test_abort() {
  std::abort(); // NON_COMPLIANT
}

void test_Exit() {
  std::_Exit(1); // NON_COMPLIANT
}

void test_quick_exit() {
  std::quick_exit(1); // NON_COMPLIANT
}

void test_terminate() {
  std::terminate(); // NON_COMPLIANT
}