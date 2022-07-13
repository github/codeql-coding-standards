#include <cerrno>

bool test_errno_is_used() { // NON_COMPLIANT
  return !errno;
}

void test_errno_is_not_used() {} // COMPLIANT