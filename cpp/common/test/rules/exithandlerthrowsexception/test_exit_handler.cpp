#include <cstdlib>
#include <exception>
#include <stdexcept>

void throwing_handler() { throw std::exception(); }

void non_throwing_handler() {}

void test_throwing_atexit_handler() {
  std::atexit(throwing_handler); // NON_COMPLIANT
}

void test_non_throwing_atexit_handler() {
  std::atexit(non_throwing_handler); // COMPLIANT
}

void test_throwing_at_quick_exit_handler() {
  std::at_quick_exit(throwing_handler); // NON_COMPLIANT
}

void test_non_throwing_at_quick_exit_handler() {
  std::at_quick_exit(non_throwing_handler); // COMPLIANT
}