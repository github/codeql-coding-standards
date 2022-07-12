#include <stdexcept>
#include <string>

void test_const_duplicate_one(int x) {
  if (x < 10) {
    throw std::exception(); // NON_COMPLIANT
  } else if (x > 100) {
    throw std::runtime_error("x is greater than 100"); // NON_COMPLIANT
  }
}

void test_const_duplicate_two(int x) {
  if (x < 10) {
    throw std::exception(); // NON_COMPLIANT
  } else if (x > 100) {
    throw std::runtime_error("x is greater than 100"); // NON_COMPLIANT
  }
}

void test_unique() {
  throw std::runtime_error("unique"); // COMPLIANT
}

void test_parameter(const std::string &val, int x) {
  if (x < 10) {
    throw std::runtime_error("Invalid val " + val); // NON_COMPLIANT
  } else if (x > 100) {
    throw std::runtime_error("Invalid val " + val); // NON_COMPLIANT
  }
}

std::string createMessage(std::string msg) { return msg; }

void test_call(int x) {
  if (x < 10) {
    throw std::runtime_error(createMessage("Invalid val")); // NON_COMPLIANT
  } else if (x > 100) {
    throw std::runtime_error(createMessage("Invalid val")); // NON_COMPLIANT
  }
}
